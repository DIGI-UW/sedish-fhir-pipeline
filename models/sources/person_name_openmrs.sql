MODEL (
  name consolidated.person_name_openmrs,
  kind SEED (path '../../seeds/person_name_openmrs.csv'),
  columns (person_name_id INT, person_id INT, mspp_code TEXT, prefix TEXT, given_name TEXT, middle_name TEXT, family_name TEXT, family_name2 TEXT, preferred INT, voided INT)
);
