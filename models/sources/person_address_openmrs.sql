MODEL (
  name consolidated.person_address_openmrs,
  kind SEED (path '../../seeds/person_address_openmrs.csv'),
  columns (person_address_id INT, person_id INT, mspp_code TEXT, address1 TEXT, city_village TEXT, state_province TEXT, country TEXT, postal_code TEXT, preferred INT, voided INT)
);
