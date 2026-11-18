INSERT INTO restaurant.venues (name, city) VALUES
    ('Cafe North', 'Moscow'),
    ('Garden Kitchen', 'Moscow');

INSERT INTO restaurant.dining_tables (venue_id, label, seats)
SELECT venue_id, label, seats
FROM restaurant.venues
CROSS JOIN LATERAL (
    VALUES ('A1', 2), ('A2', 4), ('A3', 6)
) AS tables(label, seats)
WHERE name = 'Cafe North';

INSERT INTO restaurant.dining_tables (venue_id, label, seats)
SELECT venue_id, 'B1', 4
FROM restaurant.venues WHERE name = 'Garden Kitchen';

INSERT INTO restaurant.guests (display_name) VALUES
    ('Guest A'), ('Guest B'), ('Guest C');

INSERT INTO restaurant.reservations
    (venue_id, table_id, guest_id, starts_at, ends_at, party_size)
SELECT v.venue_id, t.table_id, g.guest_id,
       TIMESTAMPTZ '2026-12-01 18:00:00+03',
       TIMESTAMPTZ '2026-12-01 19:30:00+03', 2
FROM restaurant.venues v
JOIN restaurant.dining_tables t USING (venue_id)
CROSS JOIN restaurant.guests g
WHERE v.name = 'Cafe North' AND t.label = 'A1' AND g.display_name = 'Guest A';

INSERT INTO restaurant.reservations
    (venue_id, table_id, guest_id, starts_at, ends_at, party_size)
SELECT v.venue_id, t.table_id, g.guest_id,
       TIMESTAMPTZ '2026-12-01 18:30:00+03',
       TIMESTAMPTZ '2026-12-01 20:00:00+03', 4
FROM restaurant.venues v
JOIN restaurant.dining_tables t USING (venue_id)
CROSS JOIN restaurant.guests g
WHERE v.name = 'Cafe North' AND t.label = 'A2' AND g.display_name = 'Guest B';

INSERT INTO restaurant.reservations
    (venue_id, table_id, guest_id, starts_at, ends_at, party_size)
SELECT v.venue_id, t.table_id, g.guest_id,
       TIMESTAMPTZ '2026-12-02 19:00:00+03',
       TIMESTAMPTZ '2026-12-02 20:30:00+03', 3
FROM restaurant.venues v
JOIN restaurant.dining_tables t USING (venue_id)
CROSS JOIN restaurant.guests g
WHERE v.name = 'Garden Kitchen' AND t.label = 'B1' AND g.display_name = 'Guest C';
