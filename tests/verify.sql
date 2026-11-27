\set ON_ERROR_STOP on

DO $$
DECLARE
    serial_ids integer[];
BEGIN
    IF (SELECT count(*) FROM restaurant.restaurants) <> 2
       OR (SELECT count(*) FROM restaurant.dining_halls) <> 3
       OR (SELECT count(*) FROM restaurant.dining_tables) <> 7
       OR (SELECT count(*) FROM restaurant.guests) <> 3
       OR (SELECT count(*) FROM restaurant.reservations) <> 3
       OR (SELECT count(*) FROM restaurant.reservation_status_history) <> 4
       OR (SELECT count(*) FROM restaurant.payments) <> 1 THEN
        RAISE EXCEPTION 'Restaurant seed has unexpected row counts';
    END IF;
    IF (SELECT count(*) FROM restaurant.daily_schedule) <> 3
       OR (SELECT paid FROM restaurant.reservation_financials WHERE reservation_id = 1) <> 1500 THEN
        RAISE EXCEPTION 'Restaurant views returned unexpected data';
    END IF;

    IF (SELECT count(*) FROM hw2.aircrafts) <> 9
       OR (SELECT count(*) FROM hw3.type_examples) <> 2
       OR (SELECT count(*) FROM hw3.test_numeric) <> 4
       OR (SELECT count(*) FROM hw3.test_bool) <> 8
       OR (SELECT count(*) FROM hw3.pilots) <> 4 THEN
        RAISE EXCEPTION 'DZ2 or DZ3 tables have unexpected row counts';
    END IF;
    SELECT array_agg(id ORDER BY id) INTO serial_ids FROM hw3.test_serial;
    IF serial_ids <> ARRAY[1, 2, 3, 5] THEN
        RAISE EXCEPTION 'Serial experiment produced unexpected IDs: %', serial_ids;
    END IF;
    IF (SELECT meal[3][3] FROM hw3.pilots WHERE pilot_name = 'Ivan') <> 'компот'
       OR (SELECT meal[4][1] FROM hw3.pilots WHERE pilot_name = 'Petr') <> 'паста' THEN
        RAISE EXCEPTION 'Pilot array updates were not persisted';
    END IF;

    IF (SELECT count(*) FROM hw4.students) <> 2
       OR (SELECT count(*) FROM hw4.progress) <> 3
       OR (SELECT count(*) FROM hw4.flights) <> 9
       OR (SELECT count(*) FROM hw4.view_inventory) <> 4 THEN
        RAISE EXCEPTION 'DZ4 tables or views have unexpected row counts';
    END IF;
    IF (SELECT count(*) FROM hw5.canonical_routes) <> 4
       OR (SELECT count(*) FROM hw5.route_price_summary WHERE max_price IS NULL) <> 5
       OR (SELECT count(*) FROM hw5.booking_ranges) <> 13 THEN
        RAISE EXCEPTION 'DZ5 query views returned unexpected data';
    END IF;
    IF EXISTS (SELECT 1 FROM hw5.cities_without_moscow_flights WHERE city NOT IN ('Казань', 'Пермь'))
       OR (SELECT count(*) FROM hw5.cities_without_moscow_flights) <> 2 THEN
        RAISE EXCEPTION 'EXCEPT query returned unexpected cities';
    END IF;
END $$;

DO $$
DECLARE
    existing restaurant.reservations%ROWTYPE;
BEGIN
    SELECT * INTO existing FROM restaurant.reservations ORDER BY reservation_id LIMIT 1;

    BEGIN
        INSERT INTO restaurant.reservations
            (restaurant_id, table_id, guest_id, created_by_employee_id,
             starts_at, ends_at, party_size, status)
        VALUES (existing.restaurant_id, existing.table_id, existing.guest_id,
                existing.created_by_employee_id, existing.starts_at + interval '15 minutes',
                existing.ends_at + interval '15 minutes', 2, 'confirmed');
        RAISE EXCEPTION 'Overlapping reservation was accepted';
    EXCEPTION WHEN exclusion_violation THEN
        RAISE NOTICE 'Overlap constraint verified';
    END;

    BEGIN
        INSERT INTO restaurant.reservations
            (restaurant_id, table_id, guest_id, created_by_employee_id,
             starts_at, ends_at, party_size, status)
        VALUES (existing.restaurant_id, existing.table_id, existing.guest_id,
                existing.created_by_employee_id,
                TIMESTAMPTZ '2026-12-03 11:00:00+03', TIMESTAMPTZ '2026-12-03 12:00:00+03',
                3, 'confirmed');
        RAISE EXCEPTION 'Table capacity violation was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Table capacity constraint verified';
    END;

    BEGIN
        INSERT INTO restaurant.reservations
            (restaurant_id, table_id, guest_id, created_by_employee_id,
             starts_at, ends_at, party_size, status)
        VALUES (existing.restaurant_id, existing.table_id, existing.guest_id,
                existing.created_by_employee_id,
                TIMESTAMPTZ '2026-12-03 08:00:00+03', TIMESTAMPTZ '2026-12-03 09:00:00+03',
                2, 'confirmed');
        RAISE EXCEPTION 'Reservation outside opening hours was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Opening-hours constraint verified';
    END;

    BEGIN
        INSERT INTO hw4.students VALUES (99901, '   ', 9999, 999999);
        RAISE EXCEPTION 'Whitespace-only student name was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Visible student name constraint verified';
    END;

    BEGIN
        INSERT INTO hw4.progress VALUES (12300, 'Физика', '2025/2026', 2, 2, 'зачет');
        RAISE EXCEPTION 'Invalid pass/fail mark was accepted';
    EXCEPTION WHEN check_violation THEN
        RAISE NOTICE 'Form-dependent mark constraint verified';
    END;
END $$;

DO $$
DECLARE
    venue_id bigint;
BEGIN
    SELECT restaurant_id INTO venue_id FROM restaurant.restaurants WHERE name = 'Север';
    IF (SELECT count(*) FROM restaurant.find_available_tables(
            venue_id, TIMESTAMPTZ '2026-12-01 18:30:00+03',
            TIMESTAMPTZ '2026-12-01 19:30:00+03', 4)) <> 1 THEN
        RAISE EXCEPTION 'Available-table search returned an unexpected result';
    END IF;
END $$;
