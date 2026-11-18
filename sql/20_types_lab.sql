CREATE SCHEMA IF NOT EXISTS hw3;

CREATE TABLE hw3.type_examples (
    example_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    event_date date NOT NULL,
    measured_value numeric(10, 2) NOT NULL,
    meal_plan text[] NOT NULL,
    details jsonb NOT NULL
);

INSERT INTO hw3.type_examples
    (event_date, measured_value, meal_plan, details) VALUES
    (DATE '2026-11-18', 12.50, ARRAY['breakfast', 'lunch'],
     '{"topic":"arrays","verified":true}'::jsonb),
    (DATE '2026-11-19', 7.25, ARRAY['lunch', 'dinner'],
     '{"topic":"jsonb","verified":false}'::jsonb);

-- DZ3, exercise 2: unrestricted numeric precision and scale.
CREATE TABLE hw3.test_numeric (
    measurement numeric,
    description text NOT NULL
);
INSERT INTO hw3.test_numeric VALUES
    (1234567890.0987654321, 'precision 20, scale 10'),
    (1.5, 'precision 2, scale 1'),
    (0.12345678901234567890, 'precision 21, scale 20'),
    (1234567890, 'precision 10, scale 0');

-- DZ3, exercise 8: the failed insert consumes a serial value.
CREATE TABLE hw3.test_serial (
    id serial PRIMARY KEY,
    name text NOT NULL
);
INSERT INTO hw3.test_serial (name) VALUES ('Вишневая');
INSERT INTO hw3.test_serial (id, name) VALUES (2, 'Прохладная');
DO $$
BEGIN
    BEGIN
        INSERT INTO hw3.test_serial (name) VALUES ('Грушевая');
        RAISE EXCEPTION 'Expected duplicate key was not raised';
    EXCEPTION WHEN unique_violation THEN
        RAISE NOTICE 'Expected serial duplicate key was rejected';
    END;
END $$;
INSERT INTO hw3.test_serial (name) VALUES ('Грушевая'), ('Зеленая');
DELETE FROM hw3.test_serial WHERE id = 4;
INSERT INTO hw3.test_serial (name) VALUES ('Луговая');

-- DZ3, exercise 30: the eight accepted boolean/text combinations.
CREATE TABLE hw3.test_bool (
    a boolean,
    b text
);
INSERT INTO hw3.test_bool VALUES
    (TRUE, 'yes'),
    ('yes', true),
    ('yes', TRUE),
    ('1', 'true'),
    ('t', 'true'),
    (true, true),
    (1::boolean, 'true'),
    (111::boolean, 'true');

-- DZ3, exercise 33: a four-day, three-item meal array per pilot.
CREATE TABLE hw3.pilots (
    pilot_name text PRIMARY KEY,
    schedule integer[] NOT NULL,
    meal text[][] NOT NULL
);
INSERT INTO hw3.pilots VALUES
    ('Ivan', ARRAY[1,3,5,6,7], ARRAY[
        ARRAY['сосиска','макароны','кофе'], ARRAY['котлета','каша','чай'],
        ARRAY['рыба','рис','вода'], ARRAY['омлет','овощи','сок']]),
    ('Petr', ARRAY[1,2,5,7], ARRAY[
        ARRAY['котлета','каша','кофе'], ARRAY['рыба','рис','чай'],
        ARRAY['суп','хлеб','вода'], ARRAY['курица','гречка','сок']]),
    ('Pavel', ARRAY[2,5], ARRAY[
        ARRAY['сосиска','каша','кофе'], ARRAY['омлет','овощи','чай'],
        ARRAY['курица','рис','вода'], ARRAY['рыба','гречка','сок']]),
    ('Boris', ARRAY[3,5,6], ARRAY[
        ARRAY['котлета','каша','чай'], ARRAY['сосиска','макароны','кофе'],
        ARRAY['суп','хлеб','вода'], ARRAY['рыба','рис','сок']]);
UPDATE hw3.pilots SET meal[3][3] = 'компот' WHERE pilot_name = 'Ivan';
UPDATE hw3.pilots SET meal[4][1] = 'паста', meal[4][2] = 'салат'
WHERE pilot_name = 'Petr';
