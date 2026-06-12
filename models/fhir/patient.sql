MODEL (
  name fhir.patient,
  kind FULL,
  grain (mspp_code, patient_id),
  audits (
    assert_patient_has_identifier,
    not_null(columns := (mspp_code, patient_id, fhir_id))
  )
);

/*
  consolidated_db identity rows -> FHIR Patient (one JSON document per patient).
  Key = (mspp_code, patient_id); person_id = patient_id. voided filtered out.
  Repeating elements built in CTEs (JSON_ARRAYAGG) then composed by JSON_OBJECT.
  MySQL dialect (JSON_OBJECT / JSON_ARRAYAGG; booleans via CAST(... AS JSON)).
*/
WITH names AS (
  SELECT mspp_code, person_id,
         JSON_ARRAYAGG(JSON_OBJECT(
           'use', CASE WHEN preferred = 1 THEN 'official' ELSE 'usual' END,
           'family', family_name,
           'given', JSON_ARRAY(given_name))) AS arr
  FROM consolidated_db.person_name_openmrs
  WHERE COALESCE(voided, 0) = 0
  GROUP BY mspp_code, person_id
),
addresses AS (
  SELECT mspp_code, person_id,
         JSON_ARRAYAGG(JSON_OBJECT(
           'use', 'home',
           'line', JSON_ARRAY(address1),
           'city', city_village,
           'state', state_province,
           'country', country)) AS arr
  FROM consolidated_db.person_address_openmrs
  WHERE COALESCE(voided, 0) = 0
  GROUP BY mspp_code, person_id
),
idents AS (
  SELECT pi.mspp_code, pi.patient_id,
         JSON_OBJECT(
           'use', CASE WHEN pi.preferred = 1 THEN 'official' ELSE 'usual' END,
           'system', s.system,
           'value', pi.identifier) AS ident
  FROM consolidated_db.patient_identifier_openmrs pi
  LEFT JOIN ref.identifier_systems s ON s.identifier_type = pi.identifier_type
  WHERE COALESCE(pi.voided, 0) = 0
  UNION ALL
  SELECT m.mspp_code, m.patient_id,
         JSON_OBJECT(
           'use', 'official',
           'type', JSON_OBJECT('text', 'National FP ID'),
           'system', @VAR('national_id_system'),
           'value', m.national_id)
  FROM consolidated_db.national_fingerprint_mapping m
  WHERE m.national_id IS NOT NULL AND m.statut IN ('UNIQUE', 'DOUBLON')
),
identifiers AS (
  SELECT mspp_code, patient_id, JSON_ARRAYAGG(ident) AS arr
  FROM idents GROUP BY mspp_code, patient_id
)
SELECT
  pt.mspp_code,
  pt.patient_id,
  per.uuid AS fhir_id,
  JSON_OBJECT(
    'resourceType', 'Patient',
    'id', per.uuid,
    'active', CAST(IF(COALESCE(per.voided, 0) = 0, 'true', 'false') AS JSON),
    'gender', CASE
                WHEN per.gender IN ('M', 'Male') THEN 'male'
                WHEN per.gender IN ('F', 'Female') THEN 'female'
                WHEN per.gender IN ('O', 'Other') THEN 'other' ELSE 'unknown' END,
    'birthDate', CAST(per.birthdate AS CHAR),
    'name', nm.arr,
    'address', ad.arr,
    'identifier', ids.arr
  ) AS resource
FROM consolidated_db.patient_openmrs pt
JOIN consolidated_db.person_openmrs per
  ON per.mspp_code = pt.mspp_code AND per.person_id = pt.patient_id
LEFT JOIN names nm ON nm.mspp_code = pt.mspp_code AND nm.person_id = pt.patient_id
LEFT JOIN addresses ad ON ad.mspp_code = pt.mspp_code AND ad.person_id = pt.patient_id
LEFT JOIN identifiers ids ON ids.mspp_code = pt.mspp_code AND ids.patient_id = pt.patient_id
WHERE COALESCE(pt.voided, 0) = 0
