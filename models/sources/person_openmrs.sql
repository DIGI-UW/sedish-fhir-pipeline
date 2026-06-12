MODEL (
  name consolidated.person_openmrs,
  kind SEED (path '../../seeds/person_openmrs.csv'),
  columns (person_id INT, gender TEXT, birthdate DATE, birthdate_estimated INT, dead INT, death_date TIMESTAMP, cause_of_death INT, creator INT, date_created TIMESTAMP, changed_by INT, date_changed TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, uuid TEXT, deathdate_estimated INT, birthtime TIME, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, location_id INT, mspp_code TEXT)
);
