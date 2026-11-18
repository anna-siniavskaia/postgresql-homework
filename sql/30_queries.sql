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
