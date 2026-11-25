DROP SCHEMA IF EXISTS hw5 CASCADE;
DROP SCHEMA IF EXISTS hw4 CASCADE;
CREATE SCHEMA hw4;

CREATE TABLE hw4.students (
    record_book integer PRIMARY KEY,
    name text NOT NULL CHECK (btrim(name) <> ''),
    doc_ser numeric(4) NOT NULL,
    doc_num numeric(6) NOT NULL,
    UNIQUE (doc_ser, doc_num)
);

CREATE TABLE hw4.progress (
    record_book integer NOT NULL REFERENCES hw4.students(record_book)
        ON UPDATE CASCADE ON DELETE CASCADE,
    subject text NOT NULL CHECK (btrim(subject) <> ''),
    acad_year text NOT NULL CHECK (btrim(acad_year) <> ''),
    term smallint NOT NULL CHECK (term IN (1, 2)),
    mark smallint NOT NULL,
    test_form text NOT NULL CHECK (test_form IN ('экзамен', 'зачет')),
    CONSTRAINT progress_form_mark_check CHECK (
        (test_form = 'экзамен' AND mark IN (3, 4, 5)) OR
        (test_form = 'зачет' AND mark IN (0, 1))
    ),
    CONSTRAINT progress_one_result_unique
        UNIQUE (record_book, subject, acad_year, term)
);

INSERT INTO hw4.students VALUES
    (12300, 'Иванов Иван Иванович', 402, 543281),
    (12348, 'Петров Петр', 408, 112235);

INSERT INTO hw4.progress VALUES
    (12300, 'Математика', '2025/2026', 1, 5, 'экзамен'),
    (12300, 'История', '2025/2026', 1, 1, 'зачет'),
    (12300, 'Философия', '2025/2026', 2, 0, 'зачет');

CREATE TABLE hw4.aircrafts (
    aircraft_code char(3) PRIMARY KEY,
    model text NOT NULL,
    specifications jsonb NOT NULL DEFAULT '{}'::jsonb
        CHECK (jsonb_typeof(specifications) = 'object')
);

CREATE TABLE hw4.airports (
    airport_code char(3) PRIMARY KEY,
    airport_name text NOT NULL,
    city text NOT NULL,
    facilities jsonb NOT NULL DEFAULT '{}'::jsonb
        CHECK (jsonb_typeof(facilities) = 'object')
);

CREATE TABLE hw4.seats (
    aircraft_code char(3) NOT NULL REFERENCES hw4.aircrafts,
    seat_no text NOT NULL,
    fare_conditions text NOT NULL,
    amenities jsonb NOT NULL DEFAULT '{}'::jsonb
        CHECK (jsonb_typeof(amenities) = 'object'),
    PRIMARY KEY (aircraft_code, seat_no)
);

CREATE TABLE hw4.flights (
    flight_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    flight_no text NOT NULL,
    departure_airport char(3) NOT NULL REFERENCES hw4.airports,
    arrival_airport char(3) NOT NULL REFERENCES hw4.airports,
    scheduled_departure timestamptz NOT NULL,
    scheduled_arrival timestamptz NOT NULL,
    status text NOT NULL CHECK (status IN ('Scheduled', 'On Time', 'Delayed', 'Cancelled', 'Arrived')),
    aircraft_code char(3) NOT NULL REFERENCES hw4.aircrafts,
    CHECK (departure_airport <> arrival_airport),
    CHECK (scheduled_arrival > scheduled_departure)
);

CREATE TABLE hw4.bookings (
    book_ref char(6) PRIMARY KEY,
    book_date timestamptz NOT NULL,
    total_amount numeric(12,2) NOT NULL CHECK (total_amount >= 0)
);

CREATE TABLE hw4.tickets (
    ticket_no char(13) PRIMARY KEY,
    book_ref char(6) NOT NULL REFERENCES hw4.bookings,
    passenger_name text NOT NULL CHECK (btrim(passenger_name) <> ''),
    contact_data jsonb NOT NULL DEFAULT '{}'::jsonb
        CHECK (jsonb_typeof(contact_data) = 'object')
);

CREATE TABLE hw4.ticket_flights (
    ticket_no char(13) NOT NULL REFERENCES hw4.tickets,
    flight_id integer NOT NULL REFERENCES hw4.flights,
    amount numeric(12,2) NOT NULL CHECK (amount >= 0),
    PRIMARY KEY (ticket_no, flight_id)
);

INSERT INTO hw4.aircrafts VALUES
    ('320', 'Airbus A320-200', '{"crew":2,"engines":{"type":"IAE V2500","num":2}}'),
    ('773', 'Boeing 777-300', '{"crew":2,"engines":{"type":"GE90","num":2}}');

INSERT INTO hw4.airports VALUES
    ('SVO', 'Шереметьево', 'Москва', '{"wifi":true,"lounges":2,"transport":["bus","aeroexpress"]}'),
    ('LED', 'Пулково', 'Санкт-Петербург', '{"wifi":true}'),
    ('OVB', 'Толмачёво', 'Новосибирск', '{"wifi":true}'),
    ('AER', 'Сочи', 'Сочи', '{"wifi":true}'),
    ('PEE', 'Большое Савино', 'Пермь', '{}'),
    ('SVX', 'Кольцово', 'Екатеринбург', '{"wifi":true}'),
    ('KZN', 'Казань', 'Казань', '{}');

INSERT INTO hw4.seats VALUES
    ('320', '1A', 'Business', '{"power_outlet":true,"extra_legroom":true}'),
    ('320', '12A', 'Economy', '{"power_outlet":true}'),
    ('773', '1A', 'Business', '{"power_outlet":true,"extra_legroom":true}');

INSERT INTO hw4.flights
    (flight_no, departure_airport, arrival_airport, scheduled_departure,
     scheduled_arrival, status, aircraft_code)
VALUES
    ('PG0405', 'SVO', 'LED', '2026-11-01 08:00+03', '2026-11-01 09:30+03', 'On Time', '320'),
    ('PG0406', 'LED', 'SVO', '2026-11-01 12:00+03', '2026-11-01 13:30+03', 'Arrived', '320'),
    ('PG0273', 'SVO', 'OVB', '2026-11-02 08:00+03', '2026-11-02 12:00+03', 'Delayed', '773'),
    ('PG0274', 'OVB', 'SVO', '2026-11-03 08:00+07', '2026-11-03 09:00+03', 'Scheduled', '773'),
    ('PG0611', 'SVO', 'AER', '2026-11-04 09:00+03', '2026-11-04 11:30+03', 'Scheduled', '773'),
    ('PG0612', 'AER', 'SVO', '2026-11-05 12:00+03', '2026-11-05 14:30+03', 'Scheduled', '773'),
    ('PG0771', 'PEE', 'SVO', '2026-11-06 10:00+05', '2026-11-06 10:10+03', 'Cancelled', '773'),
    ('PG0772', 'SVO', 'SVX', '2026-11-07 10:00+03', '2026-11-07 14:20+05', 'Scheduled', '773'),
    ('PG0999', 'KZN', 'LED', '2026-11-08 10:00+03', '2026-11-08 12:00+03', 'Scheduled', '320');

INSERT INTO hw4.bookings VALUES
    ('00000F', '2026-10-20 10:00+03', 265700.00),
    ('000012', '2026-10-21 10:00+03', 37900.00),
    ('000068', '2026-10-22 10:00+03', 18100.00),
    ('000099', '2026-10-23 10:00+03', 1204500.00);

INSERT INTO hw4.tickets VALUES
    ('0000000000001', '00000F', 'ALBERT BELOV', '{"email":"albert@example.test"}'),
    ('0000000000002', '000012', 'ANNA PETROVA', '{"phone":"+70000000000"}'),
    ('0000000000003', '000068', 'IVAN SIDOROV', '{}');

INSERT INTO hw4.ticket_flights VALUES
    ('0000000000001', 1, 33700.00),
    ('0000000000001', 2, 33800.00),
    ('0000000000002', 3, 5800.00),
    ('0000000000003', 5, 4900.00);

CREATE VIEW hw4.passenger_schedule AS
SELECT flight_no, departure_airport, arrival_airport,
       scheduled_departure, scheduled_arrival, status
FROM hw4.flights
WHERE status IN ('Scheduled', 'On Time', 'Delayed');

CREATE VIEW hw4.pilot_flights AS
SELECT f.flight_id, f.flight_no, f.scheduled_departure,
       f.departure_airport, f.arrival_airport, f.aircraft_code, a.model
FROM hw4.flights f
JOIN hw4.aircrafts a USING (aircraft_code);

CREATE VIEW hw4.dispatcher_issues AS
SELECT * FROM hw4.flights WHERE status IN ('Delayed', 'Cancelled');

CREATE VIEW hw4.cashier_bookings AS
SELECT book_ref, book_date, total_amount FROM hw4.bookings;

CREATE VIEW hw4.view_inventory AS
SELECT 'passengers'::text AS role_name, count(*) AS row_count FROM hw4.passenger_schedule
UNION ALL SELECT 'pilots', count(*) FROM hw4.pilot_flights
UNION ALL SELECT 'dispatchers', count(*) FROM hw4.dispatcher_issues
UNION ALL SELECT 'cashiers', count(*) FROM hw4.cashier_bookings;
