#!/bin/sh
set -eu

docker compose down --volumes --remove-orphans
docker compose up --detach --wait
docker compose exec -T db psql -X -v ON_ERROR_STOP=1 -U homework -d homework \
  -f /tests/verify.sql
docker compose exec -T db psql -X -U homework -d homework -P pager=off -c \
  "SELECT table_schema, count(*) AS real_tables FROM information_schema.tables WHERE table_type = 'BASE TABLE' AND table_schema IN ('restaurant','hw2','hw3','hw4') GROUP BY table_schema ORDER BY table_schema;"
docker compose exec -T db psql -X -U homework -d homework -P pager=off -c \
  "TABLE restaurant.daily_schedule;"

printf '\nDatabase is ready. Open http://localhost:%s\n' "${ADMINER_PORT:-8088}"
printf 'System: PostgreSQL | Server: db | User: homework | Password: %s | Database: homework\n' "${POSTGRES_PASSWORD:-homework_local}"
