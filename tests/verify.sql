DO $$
DECLARE
    reservation_count integer;
    aircraft_count integer;
    type_count integer;
    serial_ids integer[];
BEGIN
    SELECT count(*) INTO reservation_count FROM restaurant.reservations;
    SELECT count(*) INTO aircraft_count FROM hw2.aircrafts;
    SELECT count(*) INTO type_count FROM hw3.type_examples;
    IF reservation_count <> 3 OR aircraft_count <> 9 OR type_count <> 2 THEN
        RAISE EXCEPTION 'Unexpected row counts: reservations %, aircrafts %, types %',
            reservation_count, aircraft_count, type_count;
    END IF;
    SELECT array_agg(id ORDER BY id) INTO serial_ids FROM hw3.test_serial;
    IF serial_ids <> ARRAY[1, 2, 3, 5] THEN
        RAISE EXCEPTION 'Serial experiment produced unexpected IDs: %', serial_ids;
    END IF;
    IF (SELECT count(*) FROM hw3.test_numeric) <> 4
       OR (SELECT count(*) FROM hw3.test_bool) <> 8
       OR (SELECT count(*) FROM hw3.pilots) <> 4 THEN
        RAISE EXCEPTION 'DZ3 tables have unexpected row counts';
    END IF;
    IF (SELECT meal[3][3] FROM hw3.pilots WHERE pilot_name = 'Ivan') <> 'компот'
       OR (SELECT meal[4][1] FROM hw3.pilots WHERE pilot_name = 'Petr') <> 'паста' THEN
        RAISE EXCEPTION 'Pilot array updates were not persisted';
    END IF;
END $$;

DO $$
BEGIN
    IF (SELECT count(*) FROM hw4.students) <> 2
       OR (SELECT count(*) FROM hw4.progress) <> 3
       OR (SELECT count(*) FROM hw4.flights) <> 9
       OR (SELECT count(*) FROM hw4.view_inventory) <> 4 THEN
        RAISE EXCEPTION 'DZ4 tables or views have unexpected row counts';
    END IF;

    BEGIN
        INSERT INTO hw4.students VALUES (99901, '   ', 9999, 999999);
        RAISE EXCEPTION 'Whitespace-only student name was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Visible student name constraint verified';
    END;

    BEGIN
        INSERT INTO hw4.progress VALUES
            (12300, 'Физика', '2025/2026', 2, 2, 'зачет');
        RAISE EXCEPTION 'Invalid pass/fail mark was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Form-dependent mark constraint verified';
    END;

    IF (SELECT count(*) FROM hw5.canonical_routes) <> 4 THEN
        RAISE EXCEPTION 'Reverse-route deduplication produced an unexpected count';
    END IF;
    IF (SELECT count(*) FROM hw5.route_price_summary WHERE max_price IS NULL) <> 5 THEN
        RAISE EXCEPTION 'Unsold routes were not retained by LEFT JOIN';
    END IF;
    IF (SELECT count(*) FROM hw5.booking_ranges) <> 13 THEN
        RAISE EXCEPTION 'Recursive booking ranges produced an unexpected count';
    END IF;
    IF EXISTS (
        SELECT 1 FROM hw5.cities_without_moscow_flights
        WHERE city NOT IN ('Казань', 'Пермь')
    ) OR (SELECT count(*) FROM hw5.cities_without_moscow_flights) <> 2 THEN
        RAISE EXCEPTION 'EXCEPT query returned unexpected cities';
    END IF;
END $$;

-- The database rejects overlapping active reservations for one table.
DO $$
DECLARE
    existing restaurant.reservations%ROWTYPE;
BEGIN
    SELECT * INTO existing FROM restaurant.reservations ORDER BY reservation_id LIMIT 1;
    BEGIN
        INSERT INTO restaurant.reservations
            (venue_id, table_id, guest_id, starts_at, ends_at, party_size)
        VALUES (existing.venue_id, existing.table_id, existing.guest_id,
                existing.starts_at + INTERVAL '30 minutes',
                existing.ends_at + INTERVAL '30 minutes', 2);
        RAISE EXCEPTION 'Overlapping reservation was accepted';
    EXCEPTION WHEN exclusion_violation THEN
        RAISE NOTICE 'Overlap constraint verified';
    END;
END $$;
