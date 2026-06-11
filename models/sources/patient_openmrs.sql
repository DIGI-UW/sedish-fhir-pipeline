MODEL (
  name consolidated.patient_openmrs,
  kind SEED (path '../../seeds/patient_openmrs.csv'),
  columns (patient_id INT, mspp_code TEXT, voided INT, date_created TIMESTAMP, date_changed TIMESTAMP, location_id INT)
);
