MODEL (
  name consolidated.national_fingerprint_mapping,
  kind SEED (path '../../seeds/national_fingerprint_mapping.csv'),
  columns (id INT, mspp_code TEXT, patient_id INT, national_id TEXT, statut TEXT)
);
