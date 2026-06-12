# Patient
Source: `person_openmrs` (+ `person_name_openmrs`, `person_address_openmrs`,
`patient_identifier_openmrs`, `national_fingerprint_mapping`), keyed on
`(mspp_code, patient_id)` with `person_id = patient_id`.
- `id` = `person.uuid`; `gender` M/Male→male, F/Female→female; `birthDate` = `birthdate`.
- `name`/`address`: `voided=0`, `preferred` first.
- `identifier`: per-site MRNs via `ref.identifier_systems` (must match OpenCR `internalid`),
  plus `national_id` for `statut ∈ {UNIQUE, DOUBLON}` (DOUBLON reuses the shared id).
