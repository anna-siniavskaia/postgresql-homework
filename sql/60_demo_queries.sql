-- Examples for exploring the live database after `sh scripts/demo.sh`.
SELECT table_schema, table_name
FROM information_schema.tables
WHERE table_type = 'BASE TABLE'
  AND table_schema IN ('restaurant', 'hw2', 'hw3', 'hw4')
ORDER BY table_schema, table_name;

TABLE restaurant.daily_schedule;
TABLE restaurant.reservation_financials;

SELECT *
FROM restaurant.find_available_tables(
    (SELECT restaurant_id FROM restaurant.restaurants WHERE name = 'Север'),
    TIMESTAMPTZ '2026-12-01 18:30:00+03',
    TIMESTAMPTZ '2026-12-01 19:30:00+03',
    4
);
