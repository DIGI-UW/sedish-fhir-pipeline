MODEL (
  name consolidated.patient_identifier_openmrs,
  kind SEED (path '../../seeds/patient_identifier_openmrs.csv'),
  columns (patient_identifier_id INT, patient_id INT, identifier TEXT, identifier_type INT, location_id INT, preferred INT, date_created TIMESTAMP, date_changed TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, creator INT, uuid TEXT, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, mspp_code TEXT)
);
