# PostgreSQL homework lab

An executable companion to Anna Siniavskaia's SQL homework. This repository contains real PostgreSQL tables, synthetic example rows, queries, and database checks. The written reports are preserved alongside reproducible implementations of their core exercises.

## Layout

```text
sql/      schema, synthetic rows, and sample queries
tests/    checks against the running PostgreSQL database
 reports/  original DZ1–DZ5 PDFs and the DZ2 aircrafts database backup
```

| Homework | Runnable part |
| --- | --- |
| DZ1 | `restaurant` schema: venues, dining tables, guests, reservations; foreign keys and an overlap constraint |
| DZ2 | `hw2.aircrafts`: the nine aircraft rows used in the original PostgreSQL exercise setup |
| DZ3 | `hw3` tables for numeric, serial, boolean, arrays, dates, and JSONB exercises |
| DZ4 | `hw4` student progress constraints plus a compact aviation schema, role-oriented views, and JSONB attributes |
| DZ5 | `hw5` views demonstrating LIKE, route deduplication, aggregates, LEFT JOIN, recursive CTE, EXCEPT, and a self-join |

The sample guests are fictional. No database passwords, course datasets, or personal records are committed.

## Run

Requires Docker Compose. Create a local `.env` from `.env.example`, replace the placeholder with a password, then run:

```bash
docker compose up -d
docker compose exec -T db psql -X -v ON_ERROR_STOP=1 -U homework -d homework -f /sql/00_setup.sql
docker compose exec -T db psql -X -v ON_ERROR_STOP=1 -U homework -d homework -f /sql/30_queries.sql
docker compose exec -T db psql -X -v ON_ERROR_STOP=1 -U homework -d homework -f /tests/verify.sql
```

The setup script is intended for a fresh database and creates the tables and sample rows once. The database is not published to a host port. PostgreSQL stores its data in a local Docker volume.

## What the checks cover

The verification script checks row counts and proves that PostgreSQL rejects overlapping reservations, whitespace-only names, and marks incompatible with a test form. It also checks the DZ5 recursive CTE, unsold-route handling, reverse-route deduplication, and set difference. The suite is run against PostgreSQL 16 in a disposable container. The restaurant schema does not yet enforce that `party_size` is at most the selected table's `seats`; callers should validate that rule before using it as an application database.

## Reports

The original [DZ1](reports/DZ1_Sinyavskaya_MINDA261.pdf), [DZ2](reports/DZ2_Sinyavskaya_MINDA261.pdf), [DZ3](reports/DZ3_Sinyavskaya_MINDA261.pdf), [DZ4](reports/DZ4_Sinyavskaya_MINDA261.pdf), and [DZ5](reports/DZ5_Sinyavskaya_MINDA261.pdf) reports are included. The [DZ2 aircrafts backup](reports/DZ2_aircrafts_backup.sql) is preserved for comparison; the runnable setup uses `sql/10_aircrafts.sql`. The repository remains private while redistribution rights for exercise text are reviewed.
