# openmrs-fhir-sqlmesh

Map the **CHARESS consolidated OpenMRS database → FHIR R4** using **SQLMesh**, for
loading into SEDISH's **OpenCR (MPI)** and **SHR**. The SQL models *are* the
mapping; SQLMesh provides incrementality, environments, audits, tests and lineage.

```
consolidated_db (OpenMRS-shaped, multi-site)
   └─ SQLMesh models ──▶ fhir.patient / fhir.encounter / fhir.observation   (FHIR-JSON, one doc per resource)
        → (loader, separate) → OpenHIM → OpenCR (identity) + SHR (clinical)
```

## How it runs
- **Dev / CI:** **DuckDB** + **seed fixtures** (`seeds/`, loaded as `consolidated.*` SEED models) — fully self-contained, no live DB. `sqlmesh plan` builds everything and runs audits + tests.
- **Production:** point the default gateway at the real **MySQL `consolidated_db`** (read-only) and materialize outputs/state into a **writable** schema (see `config.yaml`).

```bash
make install         # pip install sqlmesh duckdb
make plan            # build all models in duckdb from the seed fixtures
make test            # unit tests
sqlmesh fetchdf "SELECT resource FROM fhir.patient"   # inspect produced FHIR
```

## Layout (separation of concerns)
```
models/sources/   SEED models mirroring consolidated_db (dev fixtures)
models/ref_*      reference mappings (identifier_type → FHIR system)
models/fhir/      the mapping: patient.sql, encounter.sql, observation.sql  (→ FHIR JSON)
seeds/            sample source rows + ref data
audits/           data assertions (e.g. every Patient has an identifier)
tests/            SQLMesh unit tests (run without a DB)
config.yaml       gateways (duckdb dev / mysql prod), variables (FHIR system URIs)
```

## Mapping rules encoded (per the CHARESS spec)
- Composite key **`(mspp_code, patient_id)`**; `person_id = patient_id`; `voided` filtered; `preferred=1` preferred.
- Resource id = OpenMRS `uuid`.
- Per-site MRNs → `Patient.identifier` via `ref.identifier_systems` (systems must match OpenCR's `internalid`).
- `national_id` attached only for `statut ∈ {UNIQUE, DOUBLON}`; **DOUBLON reuses the shared id** (cross-site link) — verified: 11106/11 and 22207/3 resolve to the same `HT-00001830`.
- `obs` → `Observation` with `value[x]` by type and `concept_name` labels.

## Status & open items
Verified end-to-end on the seed fixtures: `sqlmesh plan` builds, audits pass, the unit test passes, and the produced `fhir.patient`/`encounter`/`observation` JSON is correct (incl. DOUBLON/A_REVOIR identity handling). Pending:
- **Prod engine + JSON dialect:** dev is DuckDB; on MySQL the JSON functions differ — the `models/fhir/*` SQL needs a MySQL pass (or stage via DuckDB/Postgres). SQLMesh transpiles, but hand-written JSON is the least portable part.
- **CIEL codings:** Observation currently emits `concept_name` labels + local code; wire `concept_reference_*` once confirmed present in `consolidated_db`.
- **iSantePlus domain tables** (labs/ARV/TB/…): out of scope until CHARESS confirms (avoid double-counting `obs`).
- **Incremental kind:** models are `FULL` for the scaffold; switch to `INCREMENTAL_BY_*` (keyed on `mspp_code`/`date_changed`) for the real volumes.
- **Empty repeating elements** currently render as `null` (e.g. `address`) — omit for strict FHIR validity.
- A **loader** (consolidated FHIR rows → OpenHIM `/SHR/fhir` + `/CR/fhir`) is a separate step.
