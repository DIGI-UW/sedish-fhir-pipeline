MODEL (
  name consolidated.patient_identifier_openmrs,
  kind SEED (path '../../seeds/patient_identifier_openmrs.csv'),
  columns (patient_identifier_id INT, patient_id INT, mspp_code TEXT, identifier TEXT, identifier_type INT, preferred INT, voided INT)
);
