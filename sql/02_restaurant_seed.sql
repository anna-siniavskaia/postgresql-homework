INSERT INTO restaurant.restaurants (name, city, address, preparation_minutes) VALUES
    ('Север', 'Москва', 'ул. Лесная, 12', 15),
    ('Сад', 'Москва', 'Большой проспект, 8', 20);

INSERT INTO restaurant.opening_hours (restaurant_id, weekday, opens_at, closes_at)
SELECT restaurant_id, weekday, TIME '10:00', TIME '23:00'
FROM restaurant.restaurants CROSS JOIN generate_series(1, 7) AS weekday;

INSERT INTO restaurant.schedule_exceptions
    (restaurant_id, exception_date, is_closed, note)
SELECT restaurant_id, DATE '2027-01-01', true, 'Выходной после Нового года'
FROM restaurant.restaurants;

INSERT INTO restaurant.dining_halls (restaurant_id, name, floor)
SELECT restaurant_id, 'Основной зал', 1 FROM restaurant.restaurants
UNION ALL
SELECT restaurant_id, 'Терраса', 1 FROM restaurant.restaurants WHERE name = 'Сад';

INSERT INTO restaurant.dining_tables (restaurant_id, hall_id, table_number, seats)
SELECT h.restaurant_id, h.hall_id, x.table_number, x.seats
FROM restaurant.dining_halls h
CROSS JOIN (VALUES ('A1', 2), ('A2', 4), ('A3', 6)) AS x(table_number, seats)
WHERE h.name = 'Основной зал';

INSERT INTO restaurant.dining_tables (restaurant_id, hall_id, table_number, seats)
SELECT h.restaurant_id, h.hall_id, 'T1', 4
FROM restaurant.dining_halls h WHERE h.name = 'Терраса';

INSERT INTO restaurant.guests (full_name, phone, email) VALUES
    ('Анна Орлова', '+79990000001', 'anna.orlova@example.test'),
    ('Михаил Петров', '+79990000002', 'mikhail.petrov@example.test'),
    ('Елена Соколова', '+79990000003', NULL);

INSERT INTO restaurant.employees (restaurant_id, full_name, role)
SELECT restaurant_id, 'Мария Волкова', 'administrator' FROM restaurant.restaurants;

INSERT INTO restaurant.reservations
    (restaurant_id, table_id, guest_id, created_by_employee_id,
     starts_at, ends_at, party_size, status, guest_comment)
SELECT r.restaurant_id, t.table_id, g.guest_id, e.employee_id,
       TIMESTAMPTZ '2026-12-01 18:00:00+03', TIMESTAMPTZ '2026-12-01 19:30:00+03',
       2, 'confirmed', 'Столик у окна'
FROM restaurant.restaurants r
JOIN restaurant.dining_tables t USING (restaurant_id)
JOIN restaurant.employees e USING (restaurant_id)
CROSS JOIN restaurant.guests g
WHERE r.name = 'Север' AND t.table_number = 'A1' AND g.full_name = 'Анна Орлова';

INSERT INTO restaurant.reservations
    (restaurant_id, table_id, guest_id, created_by_employee_id,
     starts_at, ends_at, party_size, status)
SELECT r.restaurant_id, t.table_id, g.guest_id, e.employee_id,
       TIMESTAMPTZ '2026-12-01 18:30:00+03', TIMESTAMPTZ '2026-12-01 20:00:00+03',
       4, 'confirmed'
FROM restaurant.restaurants r
JOIN restaurant.dining_tables t USING (restaurant_id)
JOIN restaurant.employees e USING (restaurant_id)
CROSS JOIN restaurant.guests g
WHERE r.name = 'Север' AND t.table_number = 'A2' AND g.full_name = 'Михаил Петров';

INSERT INTO restaurant.reservations
    (restaurant_id, table_id, guest_id, created_by_employee_id,
     starts_at, ends_at, party_size, status)
SELECT r.restaurant_id, t.table_id, g.guest_id, e.employee_id,
       TIMESTAMPTZ '2026-12-02 19:00:00+03', TIMESTAMPTZ '2026-12-02 20:30:00+03',
       3, 'pending'
FROM restaurant.restaurants r
JOIN restaurant.dining_tables t USING (restaurant_id)
JOIN restaurant.employees e USING (restaurant_id)
CROSS JOIN restaurant.guests g
WHERE r.name = 'Сад' AND t.table_number = 'T1' AND g.full_name = 'Елена Соколова';

UPDATE restaurant.reservations SET status = 'confirmed'
WHERE guest_id = (SELECT guest_id FROM restaurant.guests WHERE full_name = 'Елена Соколова');

INSERT INTO restaurant.payments
    (reservation_id, amount, status, provider_reference, paid_at)
SELECT reservation_id, 1500.00, 'paid', 'demo-payment-001', now()
FROM restaurant.reservations r
JOIN restaurant.guests g USING (guest_id)
WHERE g.full_name = 'Анна Орлова';
