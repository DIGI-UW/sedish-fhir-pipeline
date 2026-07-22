MODEL (
  name fhir.immunization,
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
  OpenMRS immunization obs-group construct -> FHIR Immunization.

  iSantePlus records a vaccination as an obs GROUP whose parent concept is IMMUNIZATION HISTORY
  (concept 1421) or the local "Immunization history Other group" (concept 509165705). The group's
  child obs (obs_group_id = the parent's obs_id) carry the details:
    * IMMUNIZATIONS               (concept 984)  -> the vaccine  (value_coded)   -> vaccineCode
    * VACCINATION DATE            (concept 1410) -> date given   (value_datetime)-> occurrenceDateTime
    * IMMUNIZATION SEQUENCE NUMBER(concept 1418) -> dose number  (value_numeric) -> protocolApplied.doseNumber

  The generic obs -> Observation model would otherwise flatten each of those members into its own
  loose Observation ("VACCINATION DATE --", "IMMUNIZATION SEQUENCE NUMBER 0", ...), which is why the
  construct concepts (984/1410/1418/1421/509165705) are excluded there (seeds/ref_excluded_obs_concepts.csv).
  Here we recompose one Immunization per group parent. A group with no vaccine member is not a valid
  immunization and is dropped. occurrenceDateTime falls back to the parent obs_datetime when the group
  carries no VACCINATION DATE (occurrence is 1..1 in FHIR). protocolApplied is emitted only for a
  positive dose number (doseNumberPositiveInt requires >= 1; a 0/"birth dose" is left unspecified).
*/
WITH vaccine AS (
  SELECT m.mspp_code, m.obs_group_id,
         MAX(m.value_coded) AS vaccine_concept,
         MAX(COALESCE(m.date_updated, m.date_created, '1970-01-01 00:00:00')) AS chg
  FROM consolidated_db.obs_openmrs m
  WHERE m.concept_id = 984 AND COALESCE(m.voided, 0) = 0 AND m.value_coded IS NOT NULL
  GROUP BY m.mspp_code, m.obs_group_id
),
vax_date AS (
  SELECT m.mspp_code, m.obs_group_id,
         MAX(m.value_datetime) AS vdate,
         MAX(COALESCE(m.date_updated, m.date_created, '1970-01-01 00:00:00')) AS chg
  FROM consolidated_db.obs_openmrs m
  WHERE m.concept_id = 1410 AND COALESCE(m.voided, 0) = 0
  GROUP BY m.mspp_code, m.obs_group_id
),
dose AS (
  SELECT m.mspp_code, m.obs_group_id,
         MAX(m.value_numeric) AS dose_num,
         MAX(COALESCE(m.date_updated, m.date_created, '1970-01-01 00:00:00')) AS chg
  FROM consolidated_db.obs_openmrs m
  WHERE m.concept_id = 1418 AND COALESCE(m.voided, 0) = 0
  GROUP BY m.mspp_code, m.obs_group_id
)
SELECT
  p.mspp_code,
  p.obs_id,
  @FHIR_ID(p.uuid) AS fhir_id,
  @FHIR_ID(per.uuid) AS patient_fhir_id,
  GREATEST(
    COALESCE(p.date_updated, p.date_created, '1970-01-01 00:00:00'),
    COALESCE(vaccine.chg,  '1970-01-01 00:00:00'),
    COALESCE(vax_date.chg, '1970-01-01 00:00:00'),
    COALESCE(dose.chg,     '1970-01-01 00:00:00')
  ) AS changed_at,
  JSON_MERGE_PATCH(
   JSON_MERGE_PATCH(
    JSON_OBJECT(
      'resourceType', 'Immunization',
      'id', @FHIR_ID(p.uuid),
      'meta', JSON_OBJECT('tag', JSON_ARRAY(JSON_OBJECT(
                'system', @VAR('mspp_site_system', 'http://sedish-haiti.org/fhir/mspp-site'), 'code', p.mspp_code))),
      'status', 'completed',
      'vaccineCode', JSON_OBJECT(
                'coding', JSON_ARRAY(JSON_OBJECT(
                  'code', COALESCE(vc.uuid, RPAD(CAST(vaccine.vaccine_concept AS CHAR), 36, 'A')),
                  'display', vcn.name)),
                'text', vcn.name),
      'patient', JSON_OBJECT('reference', CONCAT('Patient/', @FHIR_ID(per.uuid)), 'type', 'Patient'),
      'occurrenceDateTime', REPLACE(CAST(COALESCE(vax_date.vdate, p.obs_datetime) AS CHAR), ' ', 'T')
    ),
    CASE WHEN enc.uuid IS NOT NULL
         THEN JSON_OBJECT('encounter', JSON_OBJECT('reference', CONCAT('Encounter/', @FHIR_ID(enc.uuid))))
         ELSE JSON_OBJECT() END
   ),
   CASE WHEN dose.dose_num >= 1
        THEN JSON_OBJECT('protocolApplied', JSON_ARRAY(JSON_OBJECT(
               'doseNumberPositiveInt', CAST(dose.dose_num AS UNSIGNED))))
        ELSE JSON_OBJECT() END
  ) AS resource
FROM consolidated_db.obs_openmrs p
JOIN consolidated_db.person_openmrs per
  ON per.mspp_code = p.mspp_code AND per.person_id = p.person_id
JOIN vaccine
  ON vaccine.mspp_code = p.mspp_code AND vaccine.obs_group_id = p.obs_id
LEFT JOIN vax_date
  ON vax_date.mspp_code = p.mspp_code AND vax_date.obs_group_id = p.obs_id
LEFT JOIN dose
  ON dose.mspp_code = p.mspp_code AND dose.obs_group_id = p.obs_id
LEFT JOIN consolidated_db.encounter_openmrs enc
  ON enc.mspp_code = p.mspp_code AND enc.encounter_id = p.encounter_id
LEFT JOIN consolidated_db.concept vc ON vc.concept_id = vaccine.vaccine_concept
-- one preferred name per vaccine concept (prefer English, else any preferred name)
LEFT JOIN (
  SELECT concept_id, COALESCE(MAX(CASE WHEN locale = 'en' THEN name END), MAX(name)) AS name
  FROM consolidated_db.concept_name
  WHERE locale_preferred = 1 AND COALESCE(voided, 0) = 0
  GROUP BY concept_id
) vcn ON vcn.concept_id = vaccine.vaccine_concept
WHERE p.concept_id IN (1421, 509165705)
  AND COALESCE(p.voided, 0) = 0
