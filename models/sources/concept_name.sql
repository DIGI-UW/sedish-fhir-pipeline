MODEL (
  name consolidated.concept_name,
  kind SEED (path '../../seeds/concept_name.csv'),
  columns (concept_id INT, name TEXT, locale TEXT, creator INT, date_created TIMESTAMP, concept_name_id INT, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, uuid TEXT, concept_name_type TEXT, locale_preferred INT)
);
