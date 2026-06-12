MODEL (
  name consolidated.person_address_openmrs,
  kind SEED (path '../../seeds/person_address_openmrs.csv'),
  columns (person_address_id INT, person_id INT, preferred INT, address1 TEXT, address2 TEXT, city_village TEXT, state_province TEXT, postal_code TEXT, country TEXT, latitude TEXT, longitude TEXT, start_date TIMESTAMP, end_date TIMESTAMP, creator INT, date_created TIMESTAMP, voided INT, voided_by INT, date_voided TIMESTAMP, void_reason TEXT, county_district TEXT, address3 TEXT, address4 TEXT, address5 TEXT, address6 TEXT, date_changed TIMESTAMP, changed_by INT, uuid TEXT, address7 TEXT, address8 TEXT, address9 TEXT, address10 TEXT, address11 TEXT, address12 TEXT, address13 TEXT, address14 TEXT, address15 TEXT, synced INT, synced_date TIMESTAMP, date_updated TIMESTAMP, location_id INT, mspp_code TEXT)
);
