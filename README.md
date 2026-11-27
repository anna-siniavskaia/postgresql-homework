# PostgreSQL Homework Lab

A reproducible PostgreSQL database project based on five SQL assignments by Anna Siniavskaia. Docker builds the database from scratch with tables, relationships, views, functions, triggers, synthetic data, and automated integrity checks.

## Quick start

Docker Desktop with Docker Compose is required.

```bash
sh scripts/demo.sh
```

After startup, browse the tables in Adminer at [http://localhost:8088](http://localhost:8088).

| Adminer field | Value |
| --- | --- |
| System | PostgreSQL |
| Server | `db` |
| Username | `homework` |
| Password | `homework_local` |
| Database | `homework` |

Set `POSTGRES_PASSWORD` to use a different local password. The ports bind to `127.0.0.1`, keeping the database accessible only from the local machine.

## Database contents

| Assignment | Schema | Implementation |
| --- | --- | --- |
| HW1 | `restaurant` | restaurants, opening hours and exceptions, dining halls, tables, guests, employees, reservations, status history, and payments |
| HW2 | `hw2` | a table containing nine aircraft models |
| HW3 | `hw3` | numeric types, identity and serial columns, booleans, arrays, dates, and JSONB |
| HW4 | `hw4` | students and academic progress, aviation tables, constraints, views, and JSONB |
| HW5 | `hw5` | LIKE, aggregates, LEFT JOIN, recursive CTE, EXCEPT, and self-join examples |

The restaurant schema enforces the following rules in PostgreSQL.

- The party size must fit the selected table.
- Reservations must fall within opening hours.
- Active reservations for the same table cannot overlap.
- Guest contact details, payment amounts, and refunds are validated.
- Every reservation status change is recorded automatically.

The `restaurant.find_available_tables(...)` function returns suitable free tables. The `restaurant.daily_schedule` and `restaurant.reservation_financials` views provide an operational schedule and a payment summary. See the [ER diagram](docs/schema.md) for the relationships.

## Repository structure

```text
docker/    automatic container initialization
docs/      data model notes and ER diagram
reports/   original HW1–HW5 reports
scripts/   one-command demo runner
sql/       DDL, synthetic data, and example queries
tests/     database-level verification
```

Key files include the following.

- [`sql/01_restaurant_schema.sql`](sql/01_restaurant_schema.sql) defines the complete restaurant schema.
- [`sql/02_restaurant_seed.sql`](sql/02_restaurant_seed.sql) loads fictional demonstration data.
- [`sql/60_demo_queries.sql`](sql/60_demo_queries.sql) contains queries for exploring the database.
- [`tests/verify.sql`](tests/verify.sql) verifies row counts, constraints, views, and query results.

Stop the containers with this command.

```bash
docker compose down
```

Remove the local database volume and rebuild everything from scratch with these commands.

```bash
docker compose down --volumes
sh scripts/demo.sh
```

## Assignment reports

The original [HW1](reports/DZ1_Sinyavskaya_MINDA261.pdf), [HW2](reports/DZ2_Sinyavskaya_MINDA261.pdf), [HW3](reports/DZ3_Sinyavskaya_MINDA261.pdf), [HW4](reports/DZ4_Sinyavskaya_MINDA261.pdf), and [HW5](reports/DZ5_Sinyavskaya_MINDA261.pdf) reports document the source assignments. Executable SQL is stored in the `sql/` directory. All personal data in the demonstration dataset is fictional.
