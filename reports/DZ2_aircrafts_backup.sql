--
-- PostgreSQL database dump
--

\restrict fUmoIjJmP0RGyga0YiLO7m2YQzgymkm9eWiPDP7gYI0s5KANEbrUCFEcCDhPUcW

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: aircrafts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aircrafts (
    aircraft_code character(3) NOT NULL,
    model text NOT NULL,
    range integer NOT NULL,
    CONSTRAINT aircrafts_range_check CHECK ((range > 0))
);


--
-- Data for Name: aircrafts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aircrafts (aircraft_code, model, range) FROM stdin;
SU9	Sukhoi SuperJet-100	3000
773	Boeing 777-300	11100
763	Boeing 767-300	7900
733	Boeing 737-300	4200
320	Airbus A320-200	5700
321	Airbus A321-200	5600
319	Airbus A319-100	6700
CN1	Cessna 208 Caravan	1200
CR2	Bombardier CRJ-200	2700
\.


--
-- Name: aircrafts aircrafts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aircrafts
    ADD CONSTRAINT aircrafts_pkey PRIMARY KEY (aircraft_code);


--
-- PostgreSQL database dump complete
--

\unrestrict fUmoIjJmP0RGyga0YiLO7m2YQzgymkm9eWiPDP7gYI0s5KANEbrUCFEcCDhPUcW

