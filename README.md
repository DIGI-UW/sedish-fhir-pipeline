# sedish-fhir-pipeline

[![Build & Test](https://github.com/DIGI-UW/sedish-fhir-pipeline/actions/workflows/ci.yml/badge.svg)](https://github.com/DIGI-UW/sedish-fhir-pipeline/actions/workflows/ci.yml)

[![Publish image](https://github.com/DIGI-UW/sedish-fhir-pipeline/actions/workflows/publish.yml/badge.svg)](https://github.com/DIGI-UW/sedish-fhir-pipeline/actions/workflows/publish.yml)

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
*Consolidé* server aggregates all site data into a single `consolidated_db`. This pipeline
converts that data to FHIR for SEDISH:

1. **Transform** — SQLMesh models read `consolidated_db` and emit FHIR R4 JSON for each patient
   and their clinical record, writing to a `fhir` schema. (Source and output must be co-located —
   MySQL can't JOIN across servers — which is what the two run modes below are about.)
2. **Load** — a Python loader computes what changed (per-resource watermarks) and POSTs FHIR
   transaction Bundles to a single OpenHIM channel, `/consolidated/fhir`. It does **not** split
   CR/SHR itself — the [`fhir-router-mediator`](https://github.com/mherman22/fhir-router-mediator)
   routes each bundle by resource type:
   - **Patient → OpenCR** — identity; OpenCR de-duplicates across sites into golden records.
   - **clinical → SHR** (HAPI FHIR) — Encounters, Observations, Conditions, Allergies,
     MedicationRequests, linked to the same patient.

   To run identity-only (e.g. before the SHR is validated), set `CLINICAL_VIEWS=` (empty).

**Two run modes** (chosen by whether `SRC_*` is set):
- **SYNC (default)** — Consolidé is read-only; a local MySQL holds a synced copy of `consolidated_db`
  and SQLMesh transforms there. Needs only `SELECT` on Consolidé. Steady state copies only changed
  rows; a periodic reconcile (`SYNC_RECONCILE_EVERY`) catches edits/deletes.
- **DIRECT** — with write access, SQLMesh runs on Consolidé itself (a `fhir` schema beside
  `consolidated_db`); no copy. Set `FHIR_DB_*` to Consolidé and leave `SRC_*` unset.

The *extract* — replicating site data into `consolidated_db` — is the Consolidé server's responsibility.

---

## Architecture

Full architecture diagram: [SEDISH / Roaming Care architecture](https://www.canva.com/design/DAHK9iq2S7Q/MZ10sWdDlGyRetfetoz8-Q/edit)

```
 Site 1 (iSantePlus) ┐
 Site 2 (iSantePlus) ┤──▶  Consolidé: consolidated_db
 Site N (iSantePlus) ┘            │
                                  │  SYNC: sync_source.py copies changed rows to a local MySQL
                                  │  DIRECT: SQLMesh reads consolidated_db in place (no copy)
                                  ▼
                        SQLMesh  consolidated_db → fhir.*    (one server: local copy, or Consolidé)
                                  │  loader/push_to_openhim.py  →  POST bundles → /consolidated/fhir
                                  ▼
                        OpenHIM → fhir-router mediator (splits by type)
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
| Consolidé MySQL ≥ 8.0 | **SYNC:** `SELECT` on `consolidated_db`. **DIRECT:** also `ALL` on the pre-created `fhir`/`sqlmesh`/`sqlmesh__fhir` schemas |
| Local MySQL ≥ 8.0 | **SYNC only** — holds the synced copy + the `fhir` output (`--sql-mode=` for legacy zero-dates) |
| OpenHIM | The `fhir-router` mediator on channel `/consolidated/fhir` (it forwards to `/CR/fhir` + `/SHR/fhir`) |

---

## Installation

```bash
git clone https://github.com/uwdigi/sedish-fhir-pipeline.git
cd sedish-fhir-pipeline
uv sync          # or: pip install -e .
```

---

## Configuration

Copy the configuration template and fill in your connection details:

```bash
cp config.template.yaml config.yaml
```

The container renders `config.yaml` from the environment (below); `config.template.yaml` is for
local/dev runs. SQLMesh uses **one gateway** — in SYNC it's the local MySQL (holding the synced
copy + the `fhir` output), in DIRECT it's Consolidé itself. Source and output must be on one server
(MySQL can't JOIN across servers) — that's the whole reason for the two modes.

The model variables (`national_id_system`, `source_key_system`, `phone_attribute_name`) all
**self-default** in the models, so no `variables:` block is required. Set via env:

| Variable | Default | Description |
|---|---|---|
| `FHIR_DB_HOST` / `PORT` / `USER` / `PASS` | — | the MySQL SQLMesh reads + writes — the **local** DB in SYNC, **Consolidé** in DIRECT |
| `FHIR_DB_NAME` | `fhir` | output schema |
| `SRC_HOST` / `PORT` / `USER` / `PASS` | — | **SYNC only** — the read-only Consolidé the sync copies from. Unset ⇒ DIRECT |
| `SYNC_RECONCILE_EVERY` | `3600` | SYNC: seconds between full reconciles (catches edits/deletes); `0` disables |
| `ENSURE_DBS` | `1` | `0` when schemas are pre-created and we lack `CREATE` (DIRECT) |
| `FHIR_TEST_DB` | `fhir_test` | empty omits the test gateway (prod) |
| `MEDIATOR_URL` | `http://openhim-core:5001/consolidated/fhir` | OpenHIM channel the `fhir-router` mediator serves |
| `OPENHIM_USER` / `OPENHIM_PASS` | `consolidated` | OpenHIM client (role `emr`) for the mediator channel |
| `CLINICAL_VIEWS` | `encounter,observation,allergy_intolerance,condition,medication_request` | patient-scoped views bundled per patient; empty for identity-only |
| `DRY_RUN` | `0` | `1` = preview without writing to OpenHIM |
| `INTERVAL` | `30` | seconds between cycles |

---

## Running the Pipeline

### 1. Sync — copy the source locally (SYNC mode only)

```bash
python loader/sync_source.py
```

Copies the tables the models read from the read-only Consolidé into the local MySQL — full on first
run, then only rows newer than the watermark (`GREATEST(date_updated, date_changed, date_created)`),
plus a periodic full reconcile. Skipped in DIRECT mode (no `SRC_*`).

### 2. Transform — build the FHIR views

```bash
sqlmesh plan --auto-apply
```

Materialises `fhir.patient`, `fhir.encounter`, `fhir.observation`, `fhir.condition`,
`fhir.allergy_intolerance`, `fhir.medication_request`, and `fhir.location`. On subsequent
runs only rows whose `changed_at` watermark has advanced are reprocessed.

### 3. Load — push to OpenCR and SHR

```bash
# Preview first
DRY_RUN=1 python loader/push_to_openhim.py

# Then write
python loader/push_to_openhim.py
```

The loader compares each row's `changed_at` against a per-resource high-water mark in
`loader_state` and POSTs transaction Bundles (PUT-by-id entries) to the mediator only for
records that have changed. Both stages are **idempotent** — re-running is always safe.

### 4. Verify

```bash
# Identity: two site records for one person should share one golden record
curl -su openshr:openshr \
  'http://openhim-core:5001/CR/fhir/Patient?identifier=<national-id>'

# Clinical: confirm resources landed in the SHR
curl -s 'http://hapi-fhir:8080/fhir/Encounter/<uuid>'
```

---

## Continuous Operation

The pipeline runs indefinitely. A new or updated record in `consolidated_db` propagates to
OpenCR and the SHR within one cycle (`INTERVAL`, default 30s).

```bash
INTERVAL=30 bash loader/run_continuous.sh
```

Runs **`[sync →] sqlmesh run → load → sleep`** in a loop (the sync step runs in SYNC mode only).
SQLMesh incrementally refreshes `fhir.*` (change detection via `GREATEST(date_updated, date_changed,
date_created)`, so new patients are caught on insert), then the loader POSTs the changed per-patient
bundles. Idempotent — a re-run converges.

---

## Deployment

The included `Dockerfile` builds the production image. On start it renders `config.yaml`
from environment variables (`FHIR_DB_HOST/USER/PASS` are required — the Consolidé MySQL),
applies the initial `sqlmesh plan`, then runs the continuous loop. The SEDISH
`sedish-fhir-pipeline` instant package builds this image locally (`sedish-fhir-pipeline:local`)
and runs it as the `fhir-pipeline` service.

---

## Mapping Reference

All rules are derived from the CHARESS specification.

| Concern | Rule |
|---|---|
| Composite key | `(mspp_code, patient_id)` — `patient_id` alone is not unique across sites |
| Resource ID | OpenMRS `uuid`; MD5-derived stable key for tables without a uuid |
| Gender | Accepts code (`M`/`F`) and label (`Male`/`Female`) |
| Per-site MRNs | `Patient.identifier` via `fhir.identifier_systems` (must match OpenCR's `internalid` config) |
| National fingerprint ID | Attached only for `statut ∈ {UNIQUE, DOUBLON}`; DOUBLON reuses the canonical shared ID |
| Status downgrade | `UNIQUE → A_REVOIR` advances `changed_at` via the `fp_chg` CTE, triggering a re-push to OpenCR even though the national ID is removed |
| Observations | `value[x]` dispatched by type (numeric, coded, datetime, text, drug) |
| Phone | `Patient.telecom` from the `Telephone Number` person attribute (feeds OpenCR's phone match rule) |

See [`examples/`](examples/) for representative FHIR output — Patient (with and without a
national ID), Encounter, Observation, Condition, AllergyIntolerance, MedicationRequest, and a
complete SHR transaction Bundle.

---

## Testing

```bash
sqlmesh test
```

Unit tests live in `tests/<domain>/` as self-contained YAML fixtures (input rows → expected
output rows). Each test declares its own `vars` inline and only the columns the model touches.

---

## Project Structure

```
config.template.yaml        gateway definition (Consolidé), FHIR variable defaults
external_models.yaml        typed column declarations for consolidated_db source tables
models/fhir/                FHIR R4 mapping models (one .sql per resource type)
models/ref_identifier_systems.sql   reference seed (identifier_type → FHIR system URI), in the fhir schema
loader/
  sync_source.py            SYNC mode — copy changed rows of consolidated_db into the local DB
  push_to_openhim.py        delta loader — reads fhir.* views, POSTs bundles to the mediator
  run_continuous.sh         continuous loop ([sync ->] sqlmesh run -> load -> sleep)
audits/                     SQLMesh data quality assertions
tests/<domain>/             unit tests by resource domain
examples/                   representative FHIR JSON output from the models
documentation/domains/      per-resource mapping notes
```

---

## Known Limitations

Verified against the live `consolidated_db` (2026-06-16 — a ~522-patient test set):

- **`national_fingerprint_mapping` is present and populated** — 506 rows (400 UNIQUE / 106
  DOUBLON), columns match the model. The identity/DOUBLON + fpnid path runs against real data. ✅
- **`patient_identifier_type` is empty, and every patient identifier is `identifier_type = 5`**
  (e.g. `TST11001001013`). The seed `ref_identifier_systems.csv` assumes `5 = Code National`, but
  with the dimension table empty this can't be confirmed from the DB — **CHARESS must confirm what
  type 5 is** (and 3/6) before go-live, or OpenCR will index identifiers under the wrong system.
- **`person_attribute_openmrs` is empty** — no phone data, so `Patient.telecom` is not emitted
  (OpenCR Rule 10 won't fire). Harmless; telecom is conditional.
- **`patient_isanteplus.mother_name` is 100% populated** — `Patient.contact[MTH]` is emitted for
  every patient (feeds OpenCR Rule 11).
- **No `concept_reference_*` table** — Observations use `concept_name` labels and local concept
  codes. CIEL/SNOMED codings will be added once the reference table is confirmed.
- **No `provider` table** — `MedicationRequest.requester` is omitted (`encounter_provider_openmrs`
  carries per-link UUIDs, not per-provider UUIDs)..
