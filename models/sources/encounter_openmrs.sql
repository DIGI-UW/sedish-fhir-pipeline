MODEL (
  name consolidated.encounter_openmrs,
  kind SEED (path '../../seeds/encounter_openmrs.csv'),
  columns (encounter_id INT, patient_id INT, mspp_code TEXT, encounter_type INT, visit_id INT, location_id INT, encounter_datetime TIMESTAMP, uuid TEXT, voided INT)
);
