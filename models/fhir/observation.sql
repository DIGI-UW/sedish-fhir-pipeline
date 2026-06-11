MODEL (
  name fhir.observation,
  kind FULL,
  grain (mspp_code, obs_id),
  audits (assert_observation_has_subject)
);

/*
  obs_openmrs -> FHIR Observation. code via concept_name (CIEL codings would be
  added here once the concept_reference_* tables are confirmed). The polymorphic
  value[x] and the optional encounter reference are merged in conditionally.
*/
SELECT
  o.mspp_code,
  o.obs_id,
  o.uuid AS fhir_id,
  JSON_MERGE_PATCH(
    JSON_MERGE_PATCH(
      JSON_OBJECT(
        'resourceType', 'Observation',
        'id', o.uuid,
        'status', 'final',
        'code', JSON_OBJECT(
                  'coding', JSON_ARRAY(JSON_OBJECT(
                              'system', 'http://isanteplus.org/openmrs/concept',
                              'code', CAST(o.concept_id AS VARCHAR),
                              'display', cn.name)),
                  'text', cn.name),
        'subject', JSON_OBJECT('reference', 'Patient/' || per.uuid),
        'effectiveDateTime', CAST(o.obs_datetime AS VARCHAR)
      ),
      -- value[x]: exactly one source column is populated
      CASE
        WHEN o.value_numeric IS NOT NULL THEN JSON_OBJECT('valueQuantity', JSON_OBJECT('value', o.value_numeric))
        WHEN o.value_coded   IS NOT NULL THEN JSON_OBJECT('valueCodeableConcept',
                                              JSON_OBJECT('coding', JSON_ARRAY(JSON_OBJECT(
                                                'system', 'http://isanteplus.org/openmrs/concept',
                                                'code', CAST(o.value_coded AS VARCHAR)))))
        WHEN o.value_datetime IS NOT NULL THEN JSON_OBJECT('valueDateTime', CAST(o.value_datetime AS VARCHAR))
        WHEN o.value_text    IS NOT NULL THEN JSON_OBJECT('valueString', o.value_text)
        ELSE JSON_OBJECT()
      END
    ),
    -- optional encounter link
    CASE WHEN enc.uuid IS NOT NULL
         THEN JSON_OBJECT('encounter', JSON_OBJECT('reference', 'Encounter/' || enc.uuid))
         ELSE JSON_OBJECT() END
  ) AS resource
FROM consolidated.obs_openmrs o
JOIN consolidated.person_openmrs per
  ON per.mspp_code = o.mspp_code AND per.person_id = o.person_id
LEFT JOIN consolidated.encounter_openmrs enc
  ON enc.mspp_code = o.mspp_code AND enc.encounter_id = o.encounter_id
LEFT JOIN consolidated.concept_name cn
  ON cn.concept_id = o.concept_id AND cn.locale_preferred = 1 AND COALESCE(cn.voided, 0) = 0
WHERE COALESCE(o.voided, 0) = 0
