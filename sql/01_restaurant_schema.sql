CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE SCHEMA restaurant;

CREATE TYPE restaurant.reservation_status AS ENUM
    ('pending', 'confirmed', 'seated', 'completed', 'cancelled', 'no_show');
CREATE TYPE restaurant.payment_status AS ENUM ('pending', 'paid', 'refunded', 'failed');

CREATE TABLE restaurant.restaurants (
    restaurant_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL CHECK (btrim(name) <> ''),
    city text NOT NULL CHECK (btrim(city) <> ''),
    address text NOT NULL CHECK (btrim(address) <> ''),
    timezone text NOT NULL DEFAULT 'Europe/Moscow',
    preparation_minutes integer NOT NULL DEFAULT 15 CHECK (preparation_minutes BETWEEN 0 AND 120),
    UNIQUE (name, city, address)
);

CREATE TABLE restaurant.opening_hours (
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants ON DELETE CASCADE,
    weekday smallint NOT NULL CHECK (weekday BETWEEN 1 AND 7),
    opens_at time NOT NULL,
    closes_at time NOT NULL,
    CHECK (opens_at < closes_at),
    PRIMARY KEY (restaurant_id, weekday)
);

CREATE TABLE restaurant.schedule_exceptions (
    exception_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants ON DELETE CASCADE,
    exception_date date NOT NULL,
    is_closed boolean NOT NULL DEFAULT false,
    opens_at time,
    closes_at time,
    note text,
    CHECK ((is_closed AND opens_at IS NULL AND closes_at IS NULL) OR
           (NOT is_closed AND opens_at IS NOT NULL AND closes_at IS NOT NULL AND opens_at < closes_at)),
    UNIQUE (restaurant_id, exception_date)
);

CREATE TABLE restaurant.dining_halls (
    hall_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants ON DELETE CASCADE,
    name text NOT NULL CHECK (btrim(name) <> ''),
    floor integer NOT NULL DEFAULT 1,
    UNIQUE (restaurant_id, name),
    UNIQUE (hall_id, restaurant_id)
);

CREATE TABLE restaurant.dining_tables (
    table_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants ON DELETE CASCADE,
    hall_id bigint NOT NULL,
    table_number text NOT NULL CHECK (btrim(table_number) <> ''),
    seats integer NOT NULL CHECK (seats BETWEEN 1 AND 30),
    is_active boolean NOT NULL DEFAULT true,
    FOREIGN KEY (hall_id, restaurant_id)
        REFERENCES restaurant.dining_halls (hall_id, restaurant_id) ON DELETE CASCADE,
    UNIQUE (restaurant_id, table_number),
    UNIQUE (table_id, restaurant_id)
);

CREATE TABLE restaurant.guests (
    guest_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name text NOT NULL CHECK (btrim(full_name) <> ''),
    phone text NOT NULL CHECK (phone ~ '^\+[1-9][0-9]{9,14}$'),
    email text CHECK (email IS NULL OR email ~* '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$'),
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (phone),
    UNIQUE NULLS NOT DISTINCT (email)
);

CREATE TABLE restaurant.employees (
    employee_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants ON DELETE CASCADE,
    full_name text NOT NULL CHECK (btrim(full_name) <> ''),
    role text NOT NULL CHECK (role IN ('host', 'manager', 'administrator')),
    is_active boolean NOT NULL DEFAULT true,
    UNIQUE (employee_id, restaurant_id)
);

CREATE TABLE restaurant.reservations (
    reservation_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    restaurant_id bigint NOT NULL REFERENCES restaurant.restaurants,
    table_id bigint NOT NULL,
    guest_id bigint NOT NULL REFERENCES restaurant.guests,
    created_by_employee_id bigint,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    party_size integer NOT NULL CHECK (party_size BETWEEN 1 AND 30),
    status restaurant.reservation_status NOT NULL DEFAULT 'pending',
    guest_comment text,
    created_at timestamptz NOT NULL DEFAULT now(),
    CHECK (starts_at < ends_at),
    CHECK (ends_at <= starts_at + interval '6 hours'),
    FOREIGN KEY (table_id, restaurant_id)
        REFERENCES restaurant.dining_tables (table_id, restaurant_id),
    FOREIGN KEY (created_by_employee_id, restaurant_id)
        REFERENCES restaurant.employees (employee_id, restaurant_id),
    EXCLUDE USING gist (table_id WITH =, tstzrange(starts_at, ends_at, '[)') WITH &&)
        WHERE (status IN ('pending', 'confirmed', 'seated'))
);

CREATE TABLE restaurant.reservation_status_history (
    history_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id bigint NOT NULL REFERENCES restaurant.reservations ON DELETE CASCADE,
    old_status restaurant.reservation_status,
    new_status restaurant.reservation_status NOT NULL,
    changed_at timestamptz NOT NULL DEFAULT now(),
    changed_by_employee_id bigint REFERENCES restaurant.employees,
    note text
);

CREATE TABLE restaurant.payments (
    payment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    reservation_id bigint NOT NULL REFERENCES restaurant.reservations ON DELETE CASCADE,
    amount numeric(12,2) NOT NULL CHECK (amount > 0),
    currency char(3) NOT NULL DEFAULT 'RUB',
    status restaurant.payment_status NOT NULL DEFAULT 'pending',
    provider_reference text,
    paid_at timestamptz,
    refunded_amount numeric(12,2) NOT NULL DEFAULT 0 CHECK (refunded_amount >= 0 AND refunded_amount <= amount),
    CHECK ((status = 'paid' AND paid_at IS NOT NULL) OR status <> 'paid'),
    UNIQUE NULLS NOT DISTINCT (provider_reference)
);

CREATE FUNCTION restaurant.validate_reservation() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
    selected_table restaurant.dining_tables%ROWTYPE;
    venue restaurant.restaurants%ROWTYPE;
    local_start timestamp;
    local_end timestamp;
    day_opens time;
    day_closes time;
    day_is_closed boolean;
BEGIN
    SELECT * INTO STRICT selected_table FROM restaurant.dining_tables
    WHERE table_id = NEW.table_id AND restaurant_id = NEW.restaurant_id;
    IF NOT selected_table.is_active THEN
        RAISE EXCEPTION 'Table % is inactive', NEW.table_id USING ERRCODE = 'check_violation';
    END IF;
    IF NEW.party_size > selected_table.seats THEN
        RAISE EXCEPTION 'Party of % exceeds table capacity %', NEW.party_size, selected_table.seats
            USING ERRCODE = 'check_violation';
    END IF;
    SELECT * INTO STRICT venue FROM restaurant.restaurants WHERE restaurant_id = NEW.restaurant_id;
    local_start := NEW.starts_at AT TIME ZONE venue.timezone;
    local_end := NEW.ends_at AT TIME ZONE venue.timezone;
    SELECT COALESCE(se.opens_at, oh.opens_at), COALESCE(se.closes_at, oh.closes_at),
           COALESCE(se.is_closed, false)
      INTO day_opens, day_closes, day_is_closed
      FROM restaurant.opening_hours oh
      LEFT JOIN restaurant.schedule_exceptions se
        ON se.restaurant_id = oh.restaurant_id AND se.exception_date = local_start::date
     WHERE oh.restaurant_id = NEW.restaurant_id
       AND oh.weekday = extract(isodow FROM local_start)::smallint;
    IF NOT FOUND OR day_is_closed OR local_start::date <> local_end::date
       OR local_start::time < day_opens OR local_end::time > day_closes THEN
        RAISE EXCEPTION 'Reservation is outside opening hours' USING ERRCODE = 'check_violation';
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER reservations_validate
BEFORE INSERT OR UPDATE OF restaurant_id, table_id, starts_at, ends_at, party_size
ON restaurant.reservations FOR EACH ROW EXECUTE FUNCTION restaurant.validate_reservation();

CREATE FUNCTION restaurant.log_reservation_status() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'INSERT' OR NEW.status IS DISTINCT FROM OLD.status THEN
        INSERT INTO restaurant.reservation_status_history
            (reservation_id, old_status, new_status, changed_by_employee_id)
        VALUES (NEW.reservation_id,
                CASE WHEN TG_OP = 'UPDATE' THEN OLD.status ELSE NULL END,
                NEW.status, NEW.created_by_employee_id);
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER reservations_status_history
AFTER INSERT OR UPDATE OF status ON restaurant.reservations
FOR EACH ROW EXECUTE FUNCTION restaurant.log_reservation_status();

CREATE INDEX reservations_schedule_idx ON restaurant.reservations (restaurant_id, starts_at, status);
CREATE INDEX reservations_guest_idx ON restaurant.reservations (guest_id, starts_at DESC);
CREATE INDEX payments_reservation_idx ON restaurant.payments (reservation_id);

CREATE VIEW restaurant.daily_schedule AS
SELECT r.reservation_id, rr.name AS restaurant, h.name AS hall, t.table_number,
       g.full_name AS guest, g.phone, r.starts_at, r.ends_at, r.party_size, r.status
FROM restaurant.reservations r
JOIN restaurant.restaurants rr USING (restaurant_id)
JOIN restaurant.dining_tables t USING (table_id, restaurant_id)
JOIN restaurant.dining_halls h USING (hall_id, restaurant_id)
JOIN restaurant.guests g USING (guest_id);

CREATE VIEW restaurant.reservation_financials AS
SELECT r.reservation_id,
       COALESCE(sum(p.amount) FILTER (WHERE p.status = 'paid'), 0)::numeric(12,2) AS paid,
       COALESCE(sum(p.refunded_amount), 0)::numeric(12,2) AS refunded
FROM restaurant.reservations r
LEFT JOIN restaurant.payments p USING (reservation_id)
GROUP BY r.reservation_id;

CREATE FUNCTION restaurant.find_available_tables(
    requested_restaurant_id bigint, requested_start timestamptz,
    requested_end timestamptz, requested_party_size integer
)
RETURNS TABLE (table_id bigint, hall_name text, table_number text, seats integer)
LANGUAGE sql STABLE AS $$
    SELECT t.table_id, h.name, t.table_number, t.seats
    FROM restaurant.dining_tables t
    JOIN restaurant.dining_halls h USING (hall_id, restaurant_id)
    WHERE t.restaurant_id = requested_restaurant_id AND t.is_active
      AND t.seats >= requested_party_size
      AND NOT EXISTS (
          SELECT 1 FROM restaurant.reservations r
          WHERE r.table_id = t.table_id AND r.status IN ('pending', 'confirmed', 'seated')
            AND tstzrange(r.starts_at, r.ends_at, '[)') && tstzrange(requested_start, requested_end, '[)')
      )
    ORDER BY t.seats, t.table_number;
$$;
