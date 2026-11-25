-- DZ1: reservations are rows in real related PostgreSQL tables.
SELECT v.name AS venue, t.label AS table_label, g.display_name AS guest,
       r.starts_at, r.ends_at, r.party_size
FROM restaurant.reservations r
JOIN restaurant.venues v USING (venue_id)
JOIN restaurant.dining_tables t USING (table_id, venue_id)
JOIN restaurant.guests g USING (guest_id)
ORDER BY r.starts_at, venue, table_label;

-- DZ2: aircraft range queries against the seeded aircrafts table.
SELECT aircraft_code, model, range
FROM hw2.aircrafts
WHERE range >= 6000
ORDER BY range DESC;

-- DZ3: date, array, and JSONB operations against persisted rows.
SELECT event_date, to_char(event_date, 'YYYY-MM-DD') AS formatted_date,
       cardinality(meal_plan) AS meals,
       details ->> 'topic' AS topic
FROM hw3.type_examples
WHERE details @> '{"verified":true}'::jsonb;

SELECT measurement, description
FROM hw3.test_numeric
ORDER BY description;

SELECT id, name FROM hw3.test_serial ORDER BY id;
SELECT a, b FROM hw3.test_bool;

SELECT pilot_name, array_dims(meal) AS meal_dimensions,
       meal[1][1] AS day1_main, meal[4][3] AS day4_drink
FROM hw3.pilots ORDER BY pilot_name;

-- DZ4: constraints, role-oriented views, and JSONB fields.
SELECT record_book, subject, mark, test_form
FROM hw4.progress
ORDER BY record_book, subject;

SELECT role_name, row_count
FROM hw4.view_inventory
ORDER BY role_name;

SELECT model, specifications #>> '{engines,type}' AS engine_type
FROM hw4.aircrafts
ORDER BY aircraft_code;

-- DZ5: reusable query results over the persisted aviation tables.
SELECT * FROM hw5.five_letter_surnames ORDER BY passenger_name;
SELECT * FROM hw5.canonical_routes ORDER BY city_1, city_2;
SELECT * FROM hw5.route_price_summary ORDER BY departure_city, arrival_city;
SELECT * FROM hw5.booking_ranges ORDER BY min_sum;
SELECT * FROM hw5.cities_without_moscow_flights ORDER BY city;
