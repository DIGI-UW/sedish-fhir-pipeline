# consolidated-fhir-mapper

Maps the **CHARESS consolidated OpenMRS database → FHIR R4** with **SQLMesh**, and
loads it into SEDISH's **OpenCR (MPI)** and **SHR**. In the Roaming Care architecture
this repo is the **"Script Py"** between the *Consolidé* server and *SEDISH* — it turns
consolidated medical data into FHIR and pushes it through OpenHIM.

This is a **continuous** pipeline, not a one-time/batch job. A patient created at any site
reaches the consolidated server (CDC), and from that moment must flow into OpenCR + SHR on
its own — so the transform + load run on a loop (or off CDC events) in near-real-time. See
[Continuous operation](#continuous-operation-not-a-one-time-run).

## Where it fits

![SEDISH / Roaming Care architecture](docs/architecture.png)

Reading the whiteboard left-to-right:

- **Sites iSantePlus (HUEH, HUP, HFSCJ, …)** — the EMRs at each facility. Every site is
  identified by its **`mspp_code`**.
- **Consolidé** — the consolidated server. It continuously ingests each site's OpenMRS
  data (CDC over the MySQL binlog) into one **`consolidated_db`** (*Consolidated Medical
  Data*), and holds biometric fingerprints (*Consolidated Fingerprint*).
- **This repo (the ETL / "Script Py")** — reads `consolidated_db`, maps it to FHIR, and
  delivers it to SEDISH over OpenHIM:
  - **Identity → OpenCR (MPI):** Patients, with their per-site MRNs and the national
    fingerprint id. **OpenCR does the de-duplication / cross-site linking**, not us.
  - **Clinical → SHR:** Encounters + Observations as a transaction Bundle.
- **SEDISH** — **OpenHIM** is the front door (channels `/CR/fhir` and `/SHR/fhir`);
  **OpenCR** is the client registry / MPI; **SHR** is the shared health record (HAPI FHIR).

```
 Site 1 ┐
 Site 2 ┤── CDC ──▶  Consolidé: consolidated_db ──▶  [ consolidated-fhir-mapper ]
 Site N ┘            (OpenMRS-shaped, multi-site)        │ 1. transform (SQLMesh)
                                                         │     consolidated_db → fhir.patient/encounter/observation
                                                         │ 2. load (loader/)
                                                         ▼
                                              OpenHIM ──┬─▶ /CR/fhir  → OpenCR (identity, dedup, golden records)
                                                        └─▶ /SHR/fhir → SHR → HAPI FHIR (clinical)
```

### What's in this repo, and what isn't
- **In scope:** the *transform* (SQLMesh models → FHIR) and the *load* (`loader/`).
- **Out of scope:** the *extract* — getting site data into `consolidated_db` is the
  Consolidé server's job (binlog CDC). This repo treats `consolidated_db` as a read-only source.

## Why a single multi-site DB needs an MPI

Each site keeps its own patient ids, so the same person appears under different MRNs at
different facilities. We don't try to resolve that here — we attach every identifier we
have (per-site MRN + national fingerprint id) and let **OpenCR** decide. The national
fingerprint id (`HT-…`, statut `UNIQUE`/`DOUBLON`) is the strong cross-site key: a
`DOUBLON` reuses the canonical id, so the same person at two facilities collapses to **one
golden record** in OpenCR, and the SHR re-points all their clinical data onto it.

## Use it in a SEDISH setup

**Prerequisites**
- Network reach to the Consolidé `consolidated_db` (read-only) **and** to OpenHIM (`:5001`).
- A **writable** MySQL/schema for SQLMesh to materialize outputs + state into.
- OpenHIM channels `/CR/fhir` (→ OpenCR) and `/SHR/fhir` (→ SHR) configured, with client creds.

**1. Configure**
```bash
cp config.template.yaml config.yaml      # git-ignored; fill in connection + creds
uv sync                                  # or: pip install -e .
```
- `connection` → the Consolidé `consolidated_db` (read) + your writable output db (`digi_fhir`).
- `variables.national_id_system` → the FHIR system URI OpenCR expects for the fingerprint id.

**2. Transform — build the FHIR**
```bash
sqlmesh plan --auto-apply     # materializes fhir.patient / fhir.encounter / fhir.observation
sqlmesh test                  # unit tests (against test_connection)
```

**3. Load — push to OpenCR + SHR through OpenHIM**
```bash
# points at the fhir.* views from step 2 and the OpenHIM channels (env-configurable)
FHIR_DB_HOST=<output-mysql> OPENCR_URL=http://openhim-core:5001/CR/fhir \
SHR_URL=http://openhim-core:5001/SHR/fhir \
python loader/push_to_openhim.py          # add DRY_RUN=1 to preview without writing
```
The loader is **idempotent** (PUT by uuid) so it's safe to re-run. Defaults match a stock
SEDISH swarm (`openhim-core:5001`, clients `openshr` / `shr-pipeline`); override via env.

**4. Run it continuously** (the production mode — see below)
```bash
INTERVAL=30 bash loader/run_continuous.sh    # loop: sqlmesh run → load → sleep
```

**5. Verify**
```bash
# identity: the two facilities' records for one person share ONE golden record
curl -su openshr:openshr 'http://openhim-core:5001/CR/fhir/Patient?identifier=<national-id>'
# clinical: the encounters/observations landed (SHR normalizes subject → golden record)
curl -s 'http://hapi-fhir:8080/fhir/Encounter/<uuid>'
```

## Continuous operation (not a one-time run)

The pipeline is **always on**: the instant a new/updated patient lands in
`consolidated_db`, it propagates to OpenCR + SHR. Two layers make that work, both implemented:

1. **Incremental models.** The `fhir.*` models are `INCREMENTAL_BY_UNIQUE_KEY (unique_key
   fhir_id)` with `allow_partials true` and `cron '*/5 * * * *'`. They **merge by uuid**
   (an updated record upserts in place — no stale duplicates), and each carries a
   **`changed_at`** column = the latest `date_updated` from its source tables (the moment
   the consolidated server wrote the row). `date_updated` is the right watermark:
   `date_changed` is NULL on never-edited rows (misses new patients), `date_created` misses
   updates.
2. **A delta loader on a loop.** `loader/run_continuous.sh` loops *`sqlmesh run` → load →
   sleep `INTERVAL`*. The loader keeps a per-resource high-water mark (in an isolated
   `loader_state` table) and pushes **only rows with `changed_at` > last mark** — patients
   that changed, plus patients with any changed encounter/observation (their `changed_at`
   advances; the loader fetches the current Patient and bundles only the changed clinical).

```
consolidated_db (changed rows)  ──sqlmesh run──▶  fhir.* (merged by uuid)  ──loader (Δ only)──▶  OpenCR + SHR
        ▲ CDC from sites                  └──────────────────── every cycle, forever ───────────────────┘
```

**Two drivers** (pick with `RUN_MODE` on the Docker image, default `kafka`):
- **`loader/run_kafka.py` (event-driven, default).** Consumes the consolidated server's
  existing `fhir.patient.changed` Kafka topic, debounces a burst, and runs one cycle
  (`sqlmesh run` → loader). No idle work; events buffer/replay in Kafka if OpenHIM is down.
  The payload is ignored — events are a *trigger*; correctness is the incremental models +
  the loader watermark, so a missed/duplicate event only causes a redundant idempotent cycle.
- **`loader/run_continuous.sh` (poll).** The no-Kafka fallback: `sqlmesh run` → load →
  sleep `INTERVAL`.

**Latency** ≈ 5 min — SQLMesh's minimum `cron` — regardless of driver; Kafka mainly buys
idle-efficiency + buffering, not sub-cron latency.

**Deploy:** the `Dockerfile` builds the pipeline image (renders `config.yaml` from env,
applies the initial `sqlmesh plan`, then serves `RUN_MODE`). It runs as the `fhir-pipeline`
service of the SEDISH **`hie`** stack, alongside the consolidated server + Kafka.

**Why re-running is safe.** Both stages are **idempotent**: SQLMesh merges by uuid, and the
loader **PUTs by uuid** (OpenCR de-dups identities; the SHR re-points clinical refs). Overlaps
and retries converge — never a duplicate patient or encounter.

### Verified end-to-end behaviour
Against a SEDISH stack (two+ sites in `consolidated_db`): two source patients at different
facilities sharing one national fingerprint id collapsed to a **single OpenCR golden
record**, a patient with no fingerprint id stayed **separate**, and **all** their
Encounters/Observations persisted in HAPI with `subject` re-pointed onto the golden record
— i.e. one unified cross-facility record, which is the point of the HIE.

## Mapping rules encoded (per the CHARESS spec)
- Composite key **`(mspp_code, patient_id)`**; `person_id = patient_id`; `voided` filtered; `preferred=1` first.
- Resource id = OpenMRS `uuid`; `gender` accepts code or label (`M`/`Male`→`male`).
- Per-site MRNs → `Patient.identifier` via `ref.identifier_systems` (systems must match OpenCR's `internalid`).
- `national_id` attached only for `statut ∈ {UNIQUE, DOUBLON}`; **DOUBLON reuses the shared id**.
- `obs` → `Observation` (`value[x]` by type, `concept_name` label); dateTimes T-separated.

See **[`examples/`](examples/)** for real FHIR output the models emit (Patient with/without a
national id, Encounter, Observation, and the SHR transaction Bundle the loader sends).

## Layout
```
config.template.yaml   gateways (mysql connection + test_connection), FHIR-system variables
external_models.yaml   typed schemas of the consolidated_db source tables (read live)
models/fhir/           the mapping: patient.sql, encounter.sql, observation.sql  (→ FHIR JSON)
models/ref_*           reference mappings (identifier_type → FHIR system), SEED
loader/                push_to_openhim.py (delta load → OpenCR /CR + SHR /SHR), run_continuous.sh (loop)
audits/                data assertions (e.g. every Patient has an identifier)
tests/<domain>/        SQLMesh unit tests by domain (patient / encounter / observation)
documentation/domains/ per-resource mapping notes
examples/              real FHIR output the models emit (patient/encounter/observation + SHR bundle)
docs/architecture.png  the Roaming Care / SEDISH architecture
schema/                the real consolidated_db DDL dump (authoritative source reference)
```

## Status & open items
Transform + load verified end-to-end on MySQL against the real schema. Pending — all
gated on data CHARESS still owes, not on the pipeline:
- **`national_fingerprint_mapping` not in the dump** — identity/DOUBLON core wired + tested via fixtures, inert until delivered.
- **No `concept_reference_*`** → Observations use `concept_name` labels + local code (no CIEL codings yet).
- **Dimension tables data-less** (`patient_identifier_type`, `encounter_type`, `site`, visit-type) — need the rows to finalize identifier systems / `Encounter.type`.
- **iSantePlus domain tables are derived denormalizations** (incl. `patient_isanteplus`, declared as a source) — publish canonical `obs`/`encounter`, not these (avoid double-counting).
- **Source-side pruning (optimization):** models merge by uuid over the full source each cycle (correct, and the delta loader bounds what's pushed). Adding `WHERE changed_at BETWEEN @start_dt AND @end_dt` would prune the source scan too — worthwhile only at large volume.
