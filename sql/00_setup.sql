\set ON_ERROR_STOP on
DROP SCHEMA IF EXISTS hw5 CASCADE;
DROP SCHEMA IF EXISTS hw4 CASCADE;
DROP SCHEMA IF EXISTS hw3 CASCADE;
DROP SCHEMA IF EXISTS hw2 CASCADE;
DROP SCHEMA IF EXISTS restaurant CASCADE;

\ir 01_restaurant_schema.sql
\ir 02_restaurant_seed.sql
\ir 10_aircrafts.sql
\ir 20_types_lab.sql
\ir 40_constraints_views_jsonb.sql
\ir 50_query_patterns.sql
