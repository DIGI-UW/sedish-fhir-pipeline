MODEL (
  name consolidated.person_name_openmrs,
  kind SEED (path '../../seeds/person_name_openmrs.csv'),
  columns (person_name_id INT, preferred INT, person_id INT, prefix TEXT, given_name TEXT, middle_name TEXT, family_name_prefix TEXT, family_name TEXT, family_name2 TEXT, family_name_suffix TEXT, degree TEXT, creator INT, date_created TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, changed_by INT, date_changed TIMESTAMP, uuid TEXT, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, location_id INT, mspp_code TEXT)
);
