MODEL (
  name consolidated.obs_openmrs,
  kind SEED (path '../../seeds/obs_openmrs.csv'),
  columns (obs_id INT, person_id INT, concept_id INT, encounter_id INT, order_id INT, obs_datetime TIMESTAMP, location_id INT, obs_group_id INT, accession_number TEXT, value_group_id INT, value_coded INT, value_coded_name_id INT, value_drug INT, value_datetime TIMESTAMP, value_numeric DOUBLE, value_modifier TEXT, value_text TEXT, value_complex TEXT, comments TEXT, creator INT, date_created TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, uuid TEXT, previous_version INT, form_namespace_and_path TEXT, date_changed TIMESTAMP, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, mspp_code TEXT)
);
