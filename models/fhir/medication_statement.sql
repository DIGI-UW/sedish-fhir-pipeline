MODEL (
  name fhir.medication_statement,
  kind INCREMENTAL_BY_UNIQUE_KEY (unique_key fhir_id),
  cron '*/5 * * * *',
  allow_partials true,
  start '2026-01-01',
  grain (mspp_code, obs_id),
  columns (
    mspp_code VARCHAR(10),
    obs_id INT,
    fhir_id VARCHAR(36),
    patient_fhir_id VARCHAR(36),
    changed_at DATETIME,
    resource JSON
  ),
  audits (not_null(columns := (mspp_code, fhir_id, patient_fhir_id)))
);

/*
  OpenMRS medication obs-group construct -> FHIR MedicationStatement.

  iSantePlus records a medication as an obs GROUP whose parent concept is one of:
    * Current medication order               (1442)
    * Current medication dispensed construct  (163711)
    * MEDICATION HISTORY                      (1281)
    * Medication history                      (160741)
  Child obs (obs_group_id = the parent's obs_id):
    * Medication(s) name  (1282)  -> the drug (value_coded)  -> medicationCodeableConcept
    * Medication strength (1444)  -> value_text/numeric       -> dosage.text
    * Medication duration (159368)-> value_numeric (days)     -> dosage.text
    * Indication for med  (160742)-> value_coded              -> reasonCode

  The generic obs -> Observation model would flatten each member into a loose Observation
  ("Medication orders TAZOBACTAM", "Medication strength 500 mg", ...); those construct concepts are
  excluded there (seeds/ref_excluded_obs_concepts.csv) and recomposed here, one MedicationStatement
  per group parent. A group with no drug member is dropped. History groups (1281/160741) are
  status=completed; order/dispense groups are status=active. dosage/reasonCode omitted when absent.
*/
WITH drug AS (
  SELECT m.mspp_code, m.obs_group_id,
         MAX(m.value_coded) AS drug_concept,
         MAX(COALESCE(m.date_updated, m.date_created, '1970-01-01 00:00:00')) AS chg
  FROM consolidated_db.obs_openmrs m
  WHERE m.concept_id = 1282 AND COALESCE(m.voided, 0) = 0 AND m.value_coded IS NOT NULL
  GROUP BY m.mspp_code, m.obs_group_id
),
-- dosage text assembled from strength + duration; CONVERT to utf8mb4 so the concat/NULLIF don't hit
-- the mixed utf8mb3/latin1 collation error on value_text vs CAST(value_numeric).
dose AS (
  SELECT mspp_code, obs_group_id,
         NULLIF(CONCAT_WS(' | ',
           MAX(CASE WHEN concept_id = 1444
                    THEN CONVERT(COALESCE(value_text, CAST(value_numeric AS CHAR)) USING utf8mb4) END),
           MAX(CASE WHEN concept_id = 159368 AND value_numeric IS NOT NULL
                    THEN CONCAT(CONVERT(CAST(value_numeric AS CHAR) USING utf8mb4), ' day(s)') END)
         ), '') AS text
  FROM consolidated_db.obs_openmrs
  WHERE concept_id IN (1444, 159368) AND COALESCE(voided, 0) = 0
  GROUP BY mspp_code, obs_group_id
),
indication AS (
  SELECT mspp_code, obs_group_id, MAX(value_coded) AS vc
  FROM consolidated_db.obs_openmrs WHERE concept_id = 160742 AND COALESCE(voided, 0) = 0
  GROUP BY mspp_code, obs_group_id
)
SELECT
  p.mspp_code,
  p.obs_id,
  @FHIR_ID(p.uuid) AS fhir_id,
  @FHIR_ID(per.uuid) AS patient_fhir_id,
  GREATEST(
    COALESCE(p.date_updated, p.date_created, '1970-01-01 00:00:00'),
    COALESCE(drug.chg, '1970-01-01 00:00:00')
  ) AS changed_at,
  JSON_MERGE_PATCH(
   JSON_MERGE_PATCH(
    JSON_OBJECT(
      'resourceType', 'MedicationStatement',
      'id', @FHIR_ID(p.uuid),
      'meta', JSON_OBJECT('tag', JSON_ARRAY(JSON_OBJECT(
                'system', @VAR('mspp_site_system', 'http://sedish-haiti.org/fhir/mspp-site'), 'code', p.mspp_code))),
      'status', CASE WHEN p.concept_id IN (1281, 160741) THEN 'completed' ELSE 'active' END,
      'medicationCodeableConcept', JSON_OBJECT(
                'coding', JSON_ARRAY(JSON_OBJECT(
                  'code', COALESCE(dc.uuid, RPAD(CAST(drug.drug_concept AS CHAR), 36, 'A')),
                  'display', dcn.name)),
                'text', dcn.name),
      'subject', JSON_OBJECT('reference', CONCAT('Patient/', @FHIR_ID(per.uuid)), 'type', 'Patient'),
      'effectiveDateTime', REPLACE(CAST(p.obs_datetime AS CHAR), ' ', 'T')
    ),
    CASE WHEN dose.text IS NOT NULL
         THEN JSON_OBJECT('dosage', JSON_ARRAY(JSON_OBJECT('text', dose.text)))
         ELSE JSON_OBJECT() END
   ),
   CASE WHEN ind.vc IS NOT NULL
        THEN JSON_OBJECT('reasonCode', JSON_ARRAY(JSON_OBJECT('coding', JSON_ARRAY(JSON_OBJECT(
               'code', COALESCE(ic.uuid, RPAD(CAST(ind.vc AS CHAR), 36, 'A')),
               'display', icn.name)))))
        ELSE JSON_OBJECT() END
  ) AS resource
FROM consolidated_db.obs_openmrs p
JOIN consolidated_db.person_openmrs per
  ON per.mspp_code = p.mspp_code AND per.person_id = p.person_id
JOIN drug
  ON drug.mspp_code = p.mspp_code AND drug.obs_group_id = p.obs_id
LEFT JOIN dose        ON dose.mspp_code = p.mspp_code AND dose.obs_group_id = p.obs_id
LEFT JOIN indication ind ON ind.mspp_code = p.mspp_code AND ind.obs_group_id = p.obs_id
LEFT JOIN consolidated_db.concept dc ON dc.concept_id = drug.drug_concept
LEFT JOIN consolidated_db.concept ic ON ic.concept_id = ind.vc
LEFT JOIN (
  SELECT concept_id, COALESCE(MAX(CASE WHEN locale = 'en' THEN name END), MAX(name)) AS name
  FROM consolidated_db.concept_name WHERE locale_preferred = 1 AND COALESCE(voided, 0) = 0
  GROUP BY concept_id
) dcn ON dcn.concept_id = drug.drug_concept
LEFT JOIN (
  SELECT concept_id, COALESCE(MAX(CASE WHEN locale = 'en' THEN name END), MAX(name)) AS name
  FROM consolidated_db.concept_name WHERE locale_preferred = 1 AND COALESCE(voided, 0) = 0
  GROUP BY concept_id
) icn ON icn.concept_id = ind.vc
WHERE p.concept_id IN (1442, 163711, 1281, 160741)
  AND COALESCE(p.voided, 0) = 0
