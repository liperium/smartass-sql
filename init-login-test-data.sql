--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg120+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

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

--
-- Name: api; Type: SCHEMA; Schema: -; Owner: liperium
--

CREATE SCHEMA api;


ALTER SCHEMA api OWNER TO liperium;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: agenda_item; Type: TABLE; Schema: api; Owner: liperium
--

CREATE TABLE api.agenda_item (
    id integer NOT NULL,
    title character varying NOT NULL,
    description character varying NOT NULL,
    user_id integer NOT NULL,
    importance integer NOT NULL,
    done boolean NOT NULL,
    last_update timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    start timestamp without time zone,
    "end" timestamp without time zone
);


ALTER TABLE api.agenda_item OWNER TO liperium;

--
-- Name: add_agenda_item(character varying, character varying, character varying, integer, timestamp without time zone, timestamp without time zone); Type: FUNCTION; Schema: api; Owner: liperium
--

CREATE FUNCTION api.add_agenda_item(_auth_id character varying, _title character varying, _description character varying, _importance integer, _startts timestamp without time zone, _endts timestamp without time zone) RETURNS SETOF api.agenda_item
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    db_user_id INTEGER;
    added_id INTEGER;
BEGIN
    SELECT id INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id=_auth_id
    LIMIT 1;

    INSERT INTO "hdpdb"."api"."agenda_item" (title,description,user_id,importance,start,"end",done)
    VALUES (_title,_description,db_user_id,_importance,_startTS,_endTS,false)
    RETURNING id INTO added_id;

    RETURN QUERY
    SELECT * FROM "hdpdb"."api"."agenda_item"
    WHERE user_id = db_user_id AND id = added_id;
END
$$;


ALTER FUNCTION api.add_agenda_item(_auth_id character varying, _title character varying, _description character varying, _importance integer, _startts timestamp without time zone, _endts timestamp without time zone) OWNER TO liperium;

--
-- Name: delete_agenda_item(character varying, integer); Type: FUNCTION; Schema: api; Owner: liperium
--

CREATE FUNCTION api.delete_agenda_item(_auth_id character varying, _item_id integer) RETURNS SETOF api.agenda_item
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    db_user_id INTEGER;
BEGIN
    SELECT id INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id=_auth_id
    LIMIT 1;

    DELETE FROM api.agenda_item
        WHERE id = _item_id AND user_id=db_user_id;
END
$$;


ALTER FUNCTION api.delete_agenda_item(_auth_id character varying, _item_id integer) OWNER TO liperium;

--
-- Name: get_agenda_item(character varying); Type: FUNCTION; Schema: api; Owner: liperium
--

CREATE FUNCTION api.get_agenda_item(_auth_id character varying) RETURNS SETOF api.agenda_item
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    db_user_id INTEGER;
BEGIN
    SELECT id INTO db_user_id
    FROM api.app_user
    WHERE auth0_id=_auth_id
    LIMIT 1;

    RETURN QUERY
    SELECT * FROM hdpdb.api.agenda_item
    WHERE user_id = db_user_id;
END
$$;


ALTER FUNCTION api.get_agenda_item(_auth_id character varying) OWNER TO liperium;

--
-- Name: agenda_item_id_seq; Type: SEQUENCE; Schema: api; Owner: liperium
--

CREATE SEQUENCE api.agenda_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE api.agenda_item_id_seq OWNER TO liperium;

--
-- Name: agenda_item_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: liperium
--

ALTER SEQUENCE api.agenda_item_id_seq OWNED BY api.agenda_item.id;


--
-- Name: app_user; Type: TABLE; Schema: api; Owner: liperium
--

CREATE TABLE api.app_user (
    id integer NOT NULL,
    auth0_id character varying(24) NOT NULL
);


ALTER TABLE api.app_user OWNER TO liperium;

--
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: api; Owner: liperium
--

CREATE SEQUENCE api.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE api.app_user_id_seq OWNER TO liperium;

--
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: api; Owner: liperium
--

ALTER SEQUENCE api.app_user_id_seq OWNED BY api.app_user.id;


--
-- Name: agenda_item id; Type: DEFAULT; Schema: api; Owner: liperium
--

ALTER TABLE ONLY api.agenda_item ALTER COLUMN id SET DEFAULT nextval('api.agenda_item_id_seq'::regclass);


--
-- Name: app_user id; Type: DEFAULT; Schema: api; Owner: liperium
--

ALTER TABLE ONLY api.app_user ALTER COLUMN id SET DEFAULT nextval('api.app_user_id_seq'::regclass);


--
-- Data for Name: agenda_item; Type: TABLE DATA; Schema: api; Owner: liperium
--

COPY api.agenda_item (id, title, description, user_id, importance, done, last_update, start, "end") FROM stdin;
8	Cuisine	Manger	1	0	f	2024-02-05 10:27:49	2024-02-05 10:27:53	2024-02-05 12:27:58
11	Menage	Faire le ménage... Lol	1	1	t	2024-02-05 16:22:28.596304	2024-02-07 11:21:15	2024-02-07 14:21:19
12	Menage 2	Faire le ménage... Lol	1	1	t	2024-02-05 16:22:28.596304	2024-02-07 13:21:15	2024-02-07 16:21:19
13	Menage 3	Manger dans la cuisine	1	0	t	2024-02-09 16:17:40.62844	2024-02-09 13:21:15	2024-02-09 16:21:19
22	Menage 3	Manger dans la cuisine	1	0	f	2024-02-09 16:59:48.672238	2024-02-09 13:21:15	2024-02-09 16:21:19
23	Menage 3	Manger dans la cuisine	1	0	f	2024-02-09 16:59:53.228238	2024-02-09 13:21:15	2024-02-09 16:21:19
26	dsadas	s	1	0	f	2024-02-14 19:20:56.586472	2024-02-14 14:20:00	2024-02-14 15:20:00
27	Jaime ta grand emre	dsadasjjhjh	1	1	f	2024-02-14 19:22:45.527128	2024-02-14 13:22:00	2024-02-14 14:22:00
31	dsa		1	0	f	2024-02-14 19:33:19.872674	2024-02-14 14:33:00	2024-02-14 15:33:00
32	Ahh c'est les conditions qui chient?	tyu	1	0	f	2024-02-14 19:33:39.370494	2024-02-14 14:33:00	2024-02-14 17:33:00
33	I CAN ADD??!	YESSSS	1	0	f	2024-02-14 19:34:37.922712	2024-02-14 14:34:00	2024-02-14 14:34:00
34	AHAHHAHAHHAHAA		1	0	f	2024-02-14 19:36:41.662658	2024-02-14 14:36:00	2024-02-14 14:36:00
35	Bonjour	marie est jolie	1	1	f	2024-02-14 19:37:48.875013	2024-02-14 14:37:00	2024-02-14 18:37:00
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: api; Owner: liperium
--

COPY api.app_user (id, auth0_id) FROM stdin;
1	65a5758ad4b8f0d7b410f1a0
\.


--
-- Name: agenda_item_id_seq; Type: SEQUENCE SET; Schema: api; Owner: liperium
--

SELECT pg_catalog.setval('api.agenda_item_id_seq', 36, true);


--
-- Name: app_user_id_seq; Type: SEQUENCE SET; Schema: api; Owner: liperium
--

SELECT pg_catalog.setval('api.app_user_id_seq', 1, true);


--
-- Name: agenda_item agenda_item_id_user_id; Type: CONSTRAINT; Schema: api; Owner: liperium
--

ALTER TABLE ONLY api.agenda_item
    ADD CONSTRAINT agenda_item_id_user_id PRIMARY KEY (id, user_id);


--
-- Name: app_user app_user_pk; Type: CONSTRAINT; Schema: api; Owner: liperium
--

ALTER TABLE ONLY api.app_user
    ADD CONSTRAINT app_user_pk PRIMARY KEY (id);


--
-- Name: agenda_item agenda_item_app_user_id_fk; Type: FK CONSTRAINT; Schema: api; Owner: liperium
--

ALTER TABLE ONLY api.agenda_item
    ADD CONSTRAINT agenda_item_app_user_id_fk FOREIGN KEY (user_id) REFERENCES api.app_user(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA api; Type: ACL; Schema: -; Owner: liperium
--

GRANT USAGE ON SCHEMA api TO web_anon;
GRANT USAGE ON SCHEMA api TO app_user;


--
-- Name: FUNCTION get_agenda_item(_auth_id character varying); Type: ACL; Schema: api; Owner: liperium
--

GRANT ALL ON FUNCTION api.get_agenda_item(_auth_id character varying) TO app_user;


--
-- PostgreSQL database dump complete
--

