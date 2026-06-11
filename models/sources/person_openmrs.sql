MODEL (
  name consolidated.person_openmrs,
  kind SEED (path '../../seeds/person_openmrs.csv'),
  columns (person_id INT, mspp_code TEXT, gender TEXT, birthdate DATE, dead INT, death_date TIMESTAMP, uuid TEXT, voided INT)
);
