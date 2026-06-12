# FHIR output examples

These are the **actual FHIR resources the SQLMesh models emit** — the `resource`
column of `fhir.patient` / `fhir.encounter` / `fhir.observation` — dumped from a run
against the sample fixtures. They show what `consolidated_db` rows turn into before the
loader sends them to OpenCR (`/CR/fhir`) and the SHR (`/SHR/fhir`).

| File | What it shows |
|------|----------------|
| `patient.json` | A patient **with** the national fingerprint id (statut `UNIQUE`/`DOUBLON`). Two identifiers: the per-site MRN and the national id — the latter is what lets OpenCR link this person across facilities. |
| `patient-no-national-id.json` | A patient **without** a national id (statut `A_REVOIR`). Same shape, but the `identifier` array has only the per-site MRN — so OpenCR can't cross-link it. |
| `encounter.json` | An Encounter; `subject` references the patient by uuid, `period.start` is a proper T-separated FHIR `dateTime`. |
| `observation.json` | A numeric Observation: `code` from `concept_name`, `valueQuantity`, `subject`, and an `encounter` reference. |
| `shr-transaction-bundle.json` | The transaction `Bundle` the loader POSTs to `/SHR/fhir` for one patient — the Patient plus its Encounters/Observations, each as a `PUT` entry keyed by uuid. |

## How the mapping works (source → FHIR)
- **id** = the OpenMRS `uuid` (stable, globally unique → used as the FHIR resource id and the merge key).
- **Patient.identifier** = per-site MRNs via `ref.identifier_systems` (system URIs must match OpenCR's `internalid`), plus the national fingerprint id for `statut ∈ {UNIQUE, DOUBLON}` only.
- **gender** accepts code or label (`M`/`Male`→`male`, `F`/`Female`→`female`).
- **Observation.value[x]** is chosen by the populated `value_*` column (numeric / coded / datetime / text).
- References (`subject`, `encounter`) point at uuids. The **SHR re-points** `subject` onto OpenCR's golden record after matching, so cross-facility data for one person unifies.

> Note: the models also emit `changed_at` / `patient_fhir_id` *columns* used for incremental
> loading — those are pipeline metadata, **not** part of the FHIR `resource` shown here.

## Regenerate
```bash
sqlmesh plan --auto-apply
sqlmesh fetchdf "SELECT resource FROM fhir.patient"      # raw FHIR JSON, one row per resource
```
