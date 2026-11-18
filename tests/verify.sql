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
