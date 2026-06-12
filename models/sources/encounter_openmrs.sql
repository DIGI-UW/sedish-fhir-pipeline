MODEL (
  name consolidated.encounter_openmrs,
  kind SEED (path '../../seeds/encounter_openmrs.csv'),
  columns (encounter_id INT, encounter_type INT, patient_id INT, location_id INT, form_id INT, encounter_datetime TIMESTAMP, creator INT, date_created TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, changed_by INT, date_changed TIMESTAMP, visit_id INT, uuid TEXT, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, mspp_code TEXT)
);
