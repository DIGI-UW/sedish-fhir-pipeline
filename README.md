# openmrs-fhir-sqlmesh

Map the **CHARESS consolidated OpenMRS database → FHIR R4** using **SQLMesh**, for
loading into SEDISH's **OpenCR (MPI)** and **SHR**. The SQL models *are* the
mapping; SQLMesh provides incrementality, environments, audits, tests and lineage.

```
consolidated_db (OpenMRS-shaped, multi-site MySQL)
   └─ SQLMesh models ──▶ fhir.patient / fhir.encounter / fhir.observation   (FHIR-JSON, one doc per resource)
        → (loader, separate) → OpenHIM → OpenCR (identity) + SHR (clinical)
```

MySQL-only (dialect `mysql`) — the source `consolidated_db` is MySQL 8 and the FHIR
JSON is built with native MySQL JSON functions, so dev, CI and prod all run the same
engine (no transpilation surprises). Aligned with the
[DIGI-UW/malawi-omop-pipeline](https://github.com/DIGI-UW/malawi-omop-pipeline) conventions.

## How it runs
Everything runs against **MySQL 8**. Copy the template and fill in your connection:

```bash
cp config.template.yaml config.yaml      # config.yaml is git-ignored
uv sync                                  # or: pip install -e .
sqlmesh plan --auto-apply                # build fhir.* into the target schema
sqlmesh test                             # unit tests (run against test_connection)
sqlmesh fetchdf "SELECT resource FROM fhir.patient"
```

- `connection` reads the source `consolidated_db` (read-only) and writes the `fhir.*`
  outputs + SQLMesh state into a **separate writable** database (`digi_fhir`).
- `test_connection` points at a throwaway database (`digi_fhir_test`) for unit tests.

## Layout (separation of concerns)
```
config.template.yaml   gateways (mysql connection + test_connection), variables (FHIR system URIs)
external_models.yaml   typed schemas of the consolidated_db source tables (not seeds — read live)
models/ref_*           reference mappings (identifier_type → FHIR system), SEED (we own this data)
models/fhir/           the mapping: patient.sql, encounter.sql, observation.sql  (→ FHIR JSON)
seeds/                 ref data only (identifier systems)
audits/                data assertions (e.g. every Patient has an identifier)
tests/<domain>/        SQLMesh unit tests, by domain (patient / encounter / observation)
documentation/domains/ per-resource mapping notes
schema/                the real consolidated_db DDL dump (authoritative source reference)
```

## Mapping rules encoded (per the CHARESS spec)
- Composite key **`(mspp_code, patient_id)`**; `person_id = patient_id`; `voided` filtered; `preferred=1` preferred.
- Resource id = OpenMRS `uuid`.
- `gender` accepts both code and label (`M`/`Male`→`male`, `F`/`Female`→`female`).
- Per-site MRNs → `Patient.identifier` via `ref.identifier_systems` (systems must match OpenCR's `internalid`).
- `national_id` attached only for `statut ∈ {UNIQUE, DOUBLON}`; **DOUBLON reuses the shared id** (cross-site link) — verified: `11106/11` and `22207/3` resolve to the same `HT-00001830`.
- `obs` → `Observation` with `value[x]` by type and `concept_name` labels; dateTimes emitted T-separated.

## Status & open items
Verified end-to-end against a real MySQL 8 loaded with the consolidated_db schema +
fixtures: `sqlmesh plan` builds `fhir.patient`/`encounter`/`observation`, audits pass,
the 3 unit tests pass, and the produced FHIR JSON is correct (incl. DOUBLON/A_REVOIR
identity handling and `valueQuantity` + encounter refs on Observation). Pending — these
depend on data CHARESS still owes us, not on the mapping engine:
- **`national_fingerprint_mapping` is NOT in the dump** — the biometric national_id /
  DOUBLON identity core is pending separate delivery. The national_id logic is wired
  (and tested via fixtures) but inert until the real table arrives.
- **No `concept_reference_*`** → no CIEL codings; Observation uses `concept_name`
  labels + local concept code (the graceful default).
- **Dimension tables present but data-less** in the dump (`patient_identifier_type`,
  `encounter_type`, `person_attribute_type`, `site`, visit-type) — need the rows to
  finalize identifier systems / `Encounter.type` / telecom.
- **iSantePlus domain tables are derived denormalizations** of obs/encounters — publish
  `obs`/`encounter` (canonical), not the domain tables (avoid double-counting).
  `patient_isanteplus` is declared in `external_models.yaml` (column names verbatim from
  the dump, incl. camelCase `maritalStatus`) so it's available for identity cross-checks,
  but it is **not** yet mapped to a FHIR resource.
- **Mixed collation:** clinical `*_openmrs` are utf8mb3 while several dimension tables
  are utf8mb4 — varchar joins across them (e.g. `mspp_code` → `site`) need explicit COLLATE.
- **Incremental kind:** models are `FULL` for the scaffold; switch to `INCREMENTAL_BY_*`
  (keyed on `mspp_code`/`date_changed`) for the real volumes.
- A **loader** (consolidated FHIR rows → OpenHIM `/SHR/fhir` + `/CR/fhir`) is a separate step.
