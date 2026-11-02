--
-- PostgreSQL database dump
--

\restrict Yd4GFmxBhncuDkI3AzRBfd3eVgOmqxExCGUVBnUsXYKYyxKUc3qGg5CfPPBTAQs

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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

ALTER TABLE IF EXISTS ONLY public.usecase17_backup_test DROP CONSTRAINT IF EXISTS usecase17_backup_test_pkey;
DROP TABLE IF EXISTS public.usecase17_backup_test;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: usecase17_backup_test; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usecase17_backup_test (
    id integer NOT NULL,
    record_name character varying(100) NOT NULL,
    record_status character varying(30) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Data for Name: usecase17_backup_test; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usecase17_backup_test (id, record_name, record_status, created_at) FROM stdin;
1701	Use Case 17 recovery record	READY_FOR_BACKUP	2026-11-02 06:26:06.480806
\.


--
-- Name: usecase17_backup_test usecase17_backup_test_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usecase17_backup_test
    ADD CONSTRAINT usecase17_backup_test_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

\unrestrict Yd4GFmxBhncuDkI3AzRBfd3eVgOmqxExCGUVBnUsXYKYyxKUc3qGg5CfPPBTAQs

