MODEL (
  name fhir.condition,
  kind INCREMENTAL_BY_UNIQUE_KEY (unique_key fhir_id),
  cron '*/5 * * * *',
  allow_partials true,
  start '2026-01-01',
  grain (fhir_id),
  columns (
    mspp_code VARCHAR(10),
    patient_id INT,
    fhir_id VARCHAR(37),
    patient_fhir_id VARCHAR(36),
    changed_at DATETIME,
    resource JSON
  ),
  audits (not_null(columns := (mspp_code, fhir_id)))
);

/*
  diagnosis (iSantePlus DERIVED) -> FHIR Condition.

  Reads `diagnosis`, not `patient_diagnosis`: the latter is in the schema but no site has ever sent a
  row of it, while the sites do send `diagnosis`. Reading the empty one is why the summary's problem
  list was blank for every patient.

  Only nature='diagnosis' becomes a Condition. The same table also carries nature='reason' — why the
  patient attended — which is an Encounter.reasonCode, not something the patient has.

  clinicalStatus / verificationStatus / category are kept to match the OpenMRS fhir2 runtime
  ConditionTranslator (it emits all three); the IG profile prohibits them, but we mirror what the EMRs
  actually send so SHR records reconcile, and we don't stamp meta.profile. Condition.encounter is NOT
  emitted: the runtime doesn't set it and the IG prohibits it. No uuid in the source, so the id is a
  stable MD5 over the natural key.
*/
SELECT
  d.mspp_code,
  d.patient_id,
  CONCAT('cond-', MD5(CONCAT_WS('|', d.mspp_code, d.encounter_id, d.location_id,
            d.group_id, d.code, d.diagnosed))) AS fhir_id,
  @FHIR_ID(per.uuid) AS patient_fhir_id,
  COALESCE(d.date_updated, d.date_inserted, '1970-01-01 00:00:00') AS changed_at,
  JSON_OBJECT(
    'resourceType', 'Condition',
    'id', CONCAT('cond-', MD5(CONCAT_WS('|', d.mspp_code, d.encounter_id, d.location_id,
            d.group_id, d.code, d.diagnosed))),
    'meta', JSON_OBJECT('tag', JSON_ARRAY(JSON_OBJECT(
              'system', @VAR('mspp_site_system', 'http://sedish-haiti.org/fhir/mspp-site'), 'code', d.mspp_code))),
    'clinicalStatus', JSON_OBJECT(
              'coding', JSON_ARRAY(JSON_OBJECT(
                'system', 'http://terminology.hl7.org/CodeSystem/condition-clinical',
                'code', 'active', 'display', 'Active')),
              'text', 'Active'),
    -- the source states whether the clinician confirmed or suspected it; publishing everything as
    -- confirmed would overstate a suspicion to whoever reads the summary next
    'verificationStatus', JSON_OBJECT(
              'coding', JSON_ARRAY(JSON_OBJECT(
                'system', 'http://terminology.hl7.org/CodeSystem/condition-ver-status',
                'code', CASE LOWER(COALESCE(d.certainty, 'confirmed'))
                          WHEN 'suspected' THEN 'provisional' ELSE 'confirmed' END,
                'display', CASE LOWER(COALESCE(d.certainty, 'confirmed'))
                          WHEN 'suspected' THEN 'Provisional' ELSE 'Confirmed' END)),
              'text', CASE LOWER(COALESCE(d.certainty, 'confirmed'))
                          WHEN 'suspected' THEN 'Provisional' ELSE 'Confirmed' END),
    'category', JSON_ARRAY(JSON_OBJECT('coding', JSON_ARRAY(JSON_OBJECT(
              'system', 'http://terminology.hl7.org/CodeSystem/condition-category',
              'code', 'encounter-diagnosis', 'display', 'Encounter Diagnosis')))),
    'code', JSON_OBJECT(
              'coding', JSON_ARRAY(JSON_OBJECT(
                'code', COALESCE(dc.uuid, RPAD(CAST(d.code AS CHAR), 36, 'A')),
                'display', COALESCE(NULLIF(d.name, ''), cn.name))),
              'text', COALESCE(NULLIF(d.name, ''), cn.name)),
    'subject', JSON_OBJECT('reference', CONCAT('Patient/', @FHIR_ID(per.uuid)), 'type', 'Patient'),
    'recordedDate', REPLACE(CAST(d.diagnosed AS CHAR), ' ', 'T')
  ) AS resource
FROM consolidated_db.diagnosis d
JOIN consolidated_db.person_openmrs per
  ON per.mspp_code = d.mspp_code AND per.person_id = d.patient_id
LEFT JOIN consolidated_db.concept dc
  ON dc.concept_id = d.code
-- one preferred name per concept (a concept can have a preferred name per locale, which would
-- otherwise fan the row out N times); prefer English, else any preferred name. The source usually
-- carries the name itself, so this only fills the gaps.
LEFT JOIN (
  SELECT concept_id, COALESCE(MAX(CASE WHEN locale = 'en' THEN name END), MAX(name)) AS name
  FROM consolidated_db.concept_name
  WHERE locale_preferred = 1 AND COALESCE(voided, 0) = 0
  GROUP BY concept_id
) cn ON cn.concept_id = d.code
WHERE COALESCE(d.voided, 0) = 0
  AND LOWER(COALESCE(d.nature, 'diagnosis')) = 'diagnosis'
