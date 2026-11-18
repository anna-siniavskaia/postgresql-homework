CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE SCHEMA IF NOT EXISTS restaurant;

CREATE TABLE restaurant.venues (
    venue_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    city text NOT NULL,
    UNIQUE (name, city)
);

CREATE TABLE restaurant.dining_tables (
    table_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_id integer NOT NULL REFERENCES restaurant.venues (venue_id),
    label text NOT NULL,
    seats integer NOT NULL CHECK (seats > 0),
    UNIQUE (venue_id, label),
    UNIQUE (table_id, venue_id)
);

CREATE TABLE restaurant.guests (
    guest_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    display_name text NOT NULL
);

CREATE TABLE restaurant.reservations (
    reservation_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_id integer NOT NULL REFERENCES restaurant.venues (venue_id),
    table_id integer NOT NULL,
    guest_id integer NOT NULL REFERENCES restaurant.guests (guest_id),
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    party_size integer NOT NULL CHECK (party_size > 0),
    status text NOT NULL DEFAULT 'confirmed'
        CHECK (status IN ('confirmed', 'seated', 'cancelled')),
    CHECK (starts_at < ends_at),
    FOREIGN KEY (table_id, venue_id)
        REFERENCES restaurant.dining_tables (table_id, venue_id),
    EXCLUDE USING gist (
        table_id WITH =,
        tstzrange(starts_at, ends_at, '[)') WITH &&
    ) WHERE (status IN ('confirmed', 'seated'))
);

CREATE INDEX reservations_by_venue_start
    ON restaurant.reservations (venue_id, starts_at);
