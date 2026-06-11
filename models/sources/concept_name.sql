MODEL (
  name consolidated.concept_name,
  kind SEED (path '../../seeds/concept_name.csv'),
  columns (concept_name_id INT, concept_id INT, name TEXT, locale TEXT, locale_preferred INT, concept_name_type TEXT, voided INT)
);
