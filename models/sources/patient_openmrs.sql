MODEL (
  name consolidated.patient_openmrs,
  kind SEED (path '../../seeds/patient_openmrs.csv'),
  columns (patient_id INT, creator INT, date_created TIMESTAMP, changed_by INT, date_changed TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, allergy_status TEXT, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, location_id INT, mspp_code TEXT)
);
