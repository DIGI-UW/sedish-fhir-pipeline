MODEL (
  name fhir.excluded_obs_concepts,
  kind SEED (path '../seeds/ref_excluded_obs_concepts.csv'),
  columns (uuid TEXT, name TEXT)
);

/*
  Demographic / address / social-registration concepts that are stored as OpenMRS obs but are NOT
  clinical observations (address components, place of birth, civil status, occupation, religion,
  education). They are redundant with Patient.address / demographics and must not surface in the FHIR
  Observation feed (they were cluttering the IPS "Results & Observations" section). Referenced by
  models/fhir/observation.sql to filter the obs feed. Keyed by the stable concept UUID so it is
  portable across installs; edit this seed to tune the exclusion list — no query change needed.
*/
