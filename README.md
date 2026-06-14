# sedish-fhir-pipeline

FHIR R4 transformation and load pipeline for the **SEDISH Haiti Health Information Exchange**.
Reads patient demographics and clinical data from the CHARESS consolidated OpenMRS database,
maps it to FHIR R4 using [SQLMesh](https://sqlmesh.com), and delivers it to **OpenCR** (MPI)
and the **Shared Health Record** (SHR) through OpenHIM — continuously, in near-real time.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the Pipeline](#running-the-pipeline)
- [Continuous Operation](#continuous-operation)
- [Deployment](#deployment)
- [Mapping Reference](#mapping-reference)
- [Testing](#testing)
- [Project Structure](#project-structure)
- [Known Limitations](#known-limitations)

---

## Overview

SEDISH is Haiti's national Health Information Exchange. Multiple iSantePlus EMR sites
(HUEH, HUP, HFSCJ, and others) each maintain their own OpenMRS instance. The CHARESS
*Consolidé* server aggregates all site data into a single `consolidated_db` via MySQL
binlog CDC. This pipeline sits between the Consolidé server and SEDISH:

1. **Transform** — SQLMesh models read `consolidated_db` and emit FHIR R4 JSON for each
   patient and their clinical record.
2. **Load** — a Python loader pushes changed records through OpenHIM to two destinations:
   - **OpenCR** receives patient identity (demographics, per-site MRNs, national fingerprint
     ID) and performs cross-site deduplication into golden records.
   - **SHR** (HAPI FHIR) receives the clinical record (Encounters, Observations, Conditions,
     Allergies, Medications) linked to the same patient.

This repo covers the *transform* and *load* steps only. The *extract* — replicating site
data into `consolidated_db` — is the Consolidé server's responsibility.

---

## Architecture

![SEDISH / Roaming Care architecture](docs/architecture.png)

```
 Site 1 (iSantePlus) ┐
 Site 2 (iSantePlus) ┤── binlog CDC ──▶  Consolidé: consolidated_db
 Site N (iSantePlus) ┘                   (OpenMRS-shaped, multi-site)
                                                    │
                                     ┌──────────────┘
                                     │  sedish-fhir-pipeline
                                     │  ① SQLMesh models
                                     │     consolidated_db → fhir.*
                                     │  ② loader/push_to_openhim.py
                                     └──────────────────────────────▶ OpenHIM
                                                                          │
                                                      ┌───────────────────┴────────────────────┐
                                                      ▼                                        ▼
                                             /CR/fhir → OpenCR                    /SHR/fhir → SHR
                                             (MPI: identity, dedup,               (HAPI FHIR: clinical)
                                              golden records)
```

### Why an MPI is necessary

Each iSantePlus site assigns its own patient IDs, so the same person appears under different
MRNs at different facilities. This pipeline does not attempt cross-site resolution; instead,
it attaches every available identifier — per-site MRNs and the national biometric fingerprint
ID — to the FHIR Patient resource and lets OpenCR perform deduplication.

The national fingerprint ID (`HT-…`) is the authoritative cross-site key. Records with
`statut = UNIQUE` carry a unique fingerprint; records with `statut = DOUBLON` share the
canonical ID of another site's record for the same person. OpenCR collapses both into a
single golden record, and the SHR re-points all clinical references onto it.

---

## Prerequisites

| Requirement | Notes |
|---|---|
| Python ≥ 3.11 | `uv` recommended for dependency management |
| MySQL ≥ 8.0 | Read access to `consolidated_db`; a writable schema for SQLMesh state |
| OpenHIM | Channels `/CR/fhir` and `/SHR/fhir` configured with client credentials |
| SQLMesh | Installed via `uv sync` or `pip install -e .` |

Network access to the Consolidé server's `consolidated_db` and to OpenHIM (default port
`5001`) is required for both the transform and load stages.

---

## Installation

```bash
git clone https://github.com/uwdigi/sedish-fhir-pipeline.git
cd sedish-fhir-pipeline
uv sync          # or: pip install -e .
```

---

## Configuration

Copy the configuration template and fill in your connection details and credentials:

```bash
cp config.template.yaml config.yaml
```

`config.yaml` is git-ignored. Key sections to configure:

```yaml
gateways:
  default:
    connection:
      host: <consolidated-db-host>      # Consolidé server (read-only)
      database: consolidated_db
      ...
  output:
    connection:
      host: <output-db-host>            # writable schema for SQLMesh materialisation
      database: digi_fhir
      ...

variables:
  national_id_system: <uri>             # FHIR system URI OpenCR expects for the fingerprint ID
                                        # e.g. http://isanteplus.org/openmrs/fhir2/6-biometrics-national-reference-code
```

Environment variables accepted by the loader (all optional; defaults target a stock SEDISH
swarm):

| Variable | Default | Description |
|---|---|---|
| `OPENCR_URL` | `http://openhim-core:5001/CR/fhir` | OpenHIM channel for OpenCR |
| `SHR_URL` | `http://openhim-core:5001/SHR/fhir` | OpenHIM channel for the SHR |
| `FHIR_DB_HOST` | `localhost` | Host of the SQLMesh output database |
| `MPI_ONLY` | `1` | `1` = Phase 1 (identity to OpenCR only); `0` = Phase 2 (identity + clinical) |
| `DRY_RUN` | `0` | `1` = preview changes without writing to OpenHIM |
| `INTERVAL` | `30` | Poll interval in seconds (continuous mode) |

---

## Running the Pipeline

### Step 1 — Transform: build the FHIR views

```bash
sqlmesh plan --auto-apply
```

This materialises `fhir.patient`, `fhir.encounter`, `fhir.observation`, `fhir.condition`,
`fhir.allergy_intolerance`, `fhir.medication_request`, and `fhir.location` into the output
database. On subsequent runs, only rows whose `changed_at` watermark has advanced are
reprocessed.

### Step 2 — Load: push to OpenCR and SHR

```bash
python loader/push_to_openhim.py
```

The loader reads the `fhir.*` views, compares each row's `changed_at` against a per-resource
high-water mark stored in `loader_state`, and issues `PUT` requests to OpenHIM for any record
that has changed since the last run. Both stages are **idempotent** — re-running is always
safe.

```bash
# Preview changes without writing (recommended on first run)
DRY_RUN=1 python loader/push_to_openhim.py
```

### Step 3 — Verify

```bash
# Confirm two site records share one golden record in OpenCR
curl -su openshr:openshr \
  'http://openhim-core:5001/CR/fhir/Patient?identifier=<national-id>'

# Confirm clinical resources landed in the SHR
curl -s 'http://hapi-fhir:8080/fhir/Encounter/<uuid>'
```

---

## Continuous Operation

The pipeline is designed to run indefinitely. A new or updated record in `consolidated_db`
propagates to OpenCR and the SHR within one cycle — typically within five minutes.

Two runtime drivers are available:

### Kafka (default, event-driven)

```bash
RUN_MODE=kafka python loader/run_kafka.py
```

Consumes the Consolidé server's `fhir.patient.changed` Kafka topic. Each event debounces a
burst and triggers one `sqlmesh run` → load cycle. The event payload is intentionally ignored
— events are a trigger only; correctness is guaranteed by the incremental models and the
loader watermark. A missed or duplicate event results in at most one redundant idempotent
cycle. Events replay from Kafka if OpenHIM is temporarily unavailable.

### Poll (fallback)

```bash
INTERVAL=30 bash loader/run_continuous.sh
```

Runs `sqlmesh run` → load → sleep in a tight loop. Use this where Kafka is not available.

### Latency

End-to-end latency is approximately **5 minutes**, determined by SQLMesh's minimum cron
interval (`*/5 * * * *`). Kafka reduces idle overhead but does not reduce latency below the
cron floor.

---

## Deployment

The included `Dockerfile` builds the production pipeline image:

1. Renders `config.yaml` from environment variables at container start.
2. Applies the initial `sqlmesh plan` on first boot.
3. Starts the runtime driver selected by `RUN_MODE` (`kafka` or `poll`).

The image runs as the `fhir-pipeline` service in the SEDISH `hie` Docker Swarm stack,
alongside the Consolidé server, OpenHIM, OpenCR, and HAPI FHIR.

---

## Mapping Reference

All mapping rules are derived from the CHARESS specification. Key decisions:

| Concern | Rule |
|---|---|
| Composite key | `(mspp_code, patient_id)` — `patient_id` alone is not unique across sites |
| Resource ID | OpenMRS `uuid` (globally unique per row); MD5-derived stable key for tables without a uuid |
| Gender | Accepts both code (`M`/`F`) and label (`Male`/`Female`) |
| Per-site MRNs | Mapped to `Patient.identifier` via `ref.identifier_systems` (must match OpenCR's `internalid` config) |
| National fingerprint ID | Attached only for `statut ∈ {UNIQUE, DOUBLON}`; DOUBLON reuses the canonical shared ID |
| Status downgrade | A `UNIQUE → A_REVOIR` change advances `changed_at` via the `fp_chg` CTE, triggering a re-push to OpenCR even though the national ID is removed from the resource |
| Observations | `value[x]` dispatched by type (numeric, coded, datetime, text, drug); concept label from `concept_name` |
| Deceased | `deceasedDateTime` when death date is known; `deceasedBoolean` otherwise |
| Phone | Emitted as `Patient.telecom` from the `Telephone Number` person attribute (feeds OpenCR's phone match rule) |

See [`examples/`](examples/) for representative FHIR output — Patient (with and without a
national ID), Encounter, Observation, Condition, AllergyIntolerance, MedicationRequest, and a
complete SHR transaction Bundle.

---

## Testing

SQLMesh unit tests cover each FHIR resource type in isolation, using in-memory fixtures
against the `test_connection` gateway:

```bash
sqlmesh test
```

Tests live in `tests/<domain>/` and are structured as YAML fixtures (input rows → expected
output rows). Each test is self-contained: all required `vars` are declared inline, and input
tables provide only the columns the model touches.

---

## Project Structure

```
config.template.yaml        gateway definitions (source + output DB), FHIR variable defaults
external_models.yaml        typed column declarations for consolidated_db source tables
models/fhir/                FHIR R4 mapping models (one .sql per resource type)
models/ref_*/               reference seed data (identifier_type → FHIR system URI)
loader/
  push_to_openhim.py        delta loader — reads fhir.* views, PUTs to OpenHIM
  run_continuous.sh         poll driver (sqlmesh run → load → sleep loop)
  run_kafka.py              Kafka driver (event-triggered cycles)
audits/                     SQLMesh data quality assertions
tests/<domain>/             unit tests by resource domain
examples/                   representative FHIR JSON output from the models
documentation/domains/      per-resource mapping notes
docs/architecture.png       SEDISH / Roaming Care architecture diagram
schema/                     consolidated_db DDL dump (authoritative source reference)
```

---

## Known Limitations

The transform and load are verified end-to-end against the real schema. The following items
are pending upstream data delivery from CHARESS and do not block the pipeline itself:

- **`national_fingerprint_mapping` absent from the DDL dump** — the identity and DOUBLON
  logic is fully implemented and tested via fixtures; the feature is inert until the table
  is present in a live `consolidated_db`.
- **No `concept_reference_*` table** — Observations currently use `concept_name` labels and
  local concept codes. CIEL/SNOMED codings will be added once the reference table is confirmed
  in the schema.
- **Dimension tables unpopulated** — `patient_identifier_type`, `encounter_type`, and
  visit-type tables exist in the schema but contain no data. Identifier system URIs and
  `Encounter.type` codes cannot be finalised until reference rows are delivered.
- **No `provider` table** — `MedicationRequest.requester` and `Encounter` practitioner
  references are omitted. The `encounter_provider_openmrs` table carries per-link UUIDs
  (not per-provider), making stable Practitioner stubs impossible without a dedicated
  provider table.
- **Source-side scan optimisation** — models currently merge over the full source on each
  cycle (correct, and the delta loader bounds what is pushed to OpenHIM). Adding
  `WHERE changed_at BETWEEN @start_dt AND @end_dt` to each model would prune the source
  scan as well; this is worthwhile only at high row volumes.
