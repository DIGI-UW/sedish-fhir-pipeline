MODEL (
  name consolidated.obs_openmrs,
  kind SEED (path '../../seeds/obs_openmrs.csv'),
  columns (obs_id INT, person_id INT, mspp_code TEXT, concept_id INT, encounter_id INT, obs_datetime TIMESTAMP, value_coded INT, value_numeric DOUBLE, value_datetime TIMESTAMP, value_text TEXT, value_drug INT, uuid TEXT, voided INT)
);
