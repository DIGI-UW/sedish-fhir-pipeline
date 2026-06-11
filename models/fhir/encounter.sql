MODEL (
  name fhir.encounter,
  kind FULL,
  grain (mspp_code, encounter_id)
);

/* encounter_openmrs -> FHIR Encounter; subject references the patient (person uuid). */
SELECT
  e.mspp_code,
  e.encounter_id,
  e.uuid AS fhir_id,
  JSON_OBJECT(
    'resourceType', 'Encounter',
    'id', e.uuid,
    'status', 'finished',
    'class', JSON_OBJECT('system', 'http://terminology.hl7.org/CodeSystem/v3-ActCode', 'code', 'AMB'),
    'subject', JSON_OBJECT('reference', 'Patient/' || per.uuid),
    'period', JSON_OBJECT('start', CAST(e.encounter_datetime AS VARCHAR))
  ) AS resource
FROM consolidated.encounter_openmrs e
JOIN consolidated.person_openmrs per
  ON per.mspp_code = e.mspp_code AND per.person_id = e.patient_id
WHERE COALESCE(e.voided, 0) = 0
