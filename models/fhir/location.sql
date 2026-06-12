MODEL (
  name fhir.location,
  kind FULL,
  grain (fhir_id),
  audits (not_null(columns := (fhir_id)))
);

/*
  locations -> FHIR Location. GLOBAL reference resource: not patient-scoped, no mspp_code,
  no change timestamp — so kind FULL (small table) and the loader pushes it via its global
  path (not the per-patient bundle). id = value_reference (the table's PK).
*/
SELECT
  l.value_reference AS fhir_id,
  JSON_OBJECT(
    'resourceType', 'Location',
    'id', l.value_reference,
    'name', l.name,
    'status', CASE WHEN COALESCE(l.active, 1) = 1 THEN 'active' ELSE 'inactive' END,
    'address', JSON_OBJECT('city', l.city_village, 'state', l.state_province)
  ) AS resource
FROM consolidated_db.locations l
WHERE l.value_reference IS NOT NULL
