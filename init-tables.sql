create schema api;
set search_path = "api";
-- auto-generated definition
create table api.recurring_agenda_item
(
    id                   serial,
    title                varchar                             not null,
    description          varchar                             not null,
    user_id              integer                             not null
        constraint agenda_item_app_user_id_fk
            references api.app_user
            on update cascade on delete cascade,
    importance           integer                             not null,
    last_update          timestamp default CURRENT_TIMESTAMP not null,
    start                timestamp,
    "end"                timestamp,
    deleted              boolean   default false,
    recurring_for        integer                             not null,
    recurring_type_id    integer                             not null,
    recurring_separation integer                             not null,
    constraint recurring_agenda_item_id_user_id
        primary key (id, user_id)
);
drop table api.recurring_done;
create table api.recurring_done
(
    recurring_item_id integer not null
        constraint recurring_done_item_id
            references api.recurring_agenda_item
            on update cascade on delete cascade,
    recurring_number  integer not null,
    done              boolean not null default false,
    constraint recurring_agenda_item_id_recurring_id_done
        primary key (recurring_item_id, recurring_number)
);

alter table api.agenda_item
    owner to liperium;


-- Remove web_anon??
create role web_anon nologin;

create role authenticator noinherit login password '9kmSEYam7a33hd';
grant web_anon to authenticator;

create role app_user nologin;
grant app_user to authenticator;

grant usage on schema api to app_user;
grant all on api.todos to app_user;
grant usage, select on sequence api.agenda_item_id_seq to app_user;
-- JWT
-- {
--    "role": "app_user"
-- }
-- echo "$(LC_ALL=C tr -dc 'A-Za-z0-9' </dev/urandom | head -c32)\""
-- 3RbMwK6v2hp6No6lOEpP7i9petPzGdBk
-- eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJyb2xlIjoiYXBwX3VzZXIifQ.ktKohizN9wXNtbwv_XDVIK9_XQ-_NsjcZoTtzUVfz_E

CREATE OR REPLACE FUNCTION api.get_all_agenda_items(_auth_id varchar(24))
    RETURNS SETOF hdpdb.api.agenda_item
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    db_user_id INTEGER;
BEGIN
    SELECT id
    INTO db_user_id
    FROM api.app_user
    WHERE auth0_id = _auth_id
    LIMIT 1;

    RETURN QUERY
        SELECT *
        FROM hdpdb.api.agenda_item
        WHERE user_id = db_user_id
          AND deleted = false;
END
$$;

CREATE OR REPLACE FUNCTION api.add_agenda_item(_auth_id varchar(24), _title varchar(32), _description varchar(200),
                                               _importance int, _startTS timestamp, _endTS timestamp)
    RETURNS SETOF "hdpdb"."api".agenda_item
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    db_user_id INTEGER;
    added_id   INTEGER;
BEGIN
    SELECT id
    INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id = _auth_id
    LIMIT 1;

    INSERT INTO "hdpdb"."api"."agenda_item" (title, description, user_id, importance, start, "end", done)
    VALUES (_title, _description, db_user_id, _importance, _startTS, _endTS, false)
    RETURNING id INTO added_id;

    RETURN QUERY
        SELECT *
        FROM "hdpdb"."api"."agenda_item"
        WHERE user_id = db_user_id
          AND id = added_id;
END
$$;

CREATE OR REPLACE FUNCTION api.delete_agenda_item(_auth_id varchar(24), _item_id integer)
    RETURNS SETOF "hdpdb"."api".agenda_item
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    db_user_id INTEGER;
BEGIN
    SELECT id
    INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id = _auth_id
    LIMIT 1;

    UPDATE api.agenda_item
    SET deleted = true
    WHERE id = _item_id
      AND user_id = db_user_id;
END
$$;

CREATE OR REPLACE FUNCTION api.update_from_ts(_auth_id varchar(24), _update_from_ts timestamp)
    RETURNS SETOF "hdpdb"."api".agenda_item
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    db_user_id INTEGER;
BEGIN
    SELECT id
    INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id = _auth_id
    LIMIT 1;

    SELECT * FROM api.agenda_item WHERE agenda_item.user_id = db_user_id AND _update_from_ts < agenda_item.last_update;
END
$$;

CREATE FUNCTION api.update_timestamp()
    RETURNS TRIGGER AS
$$
BEGIN
    NEW.last_update = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER timestamp_on_update
    BEFORE UPDATE
    ON api.agenda_item
    FOR EACH ROW
EXECUTE PROCEDURE update_timestamp();

CREATE OR REPLACE FUNCTION api.update_agenda_item(_auth_id varchar(24), _id INTEGER, _title varchar(32),
                                                  _description varchar(200), _done boolean, _importance int,
                                                  _startTS timestamp, _endTS timestamp)
    RETURNS SETOF "hdpdb"."api".agenda_item
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    db_user_id INTEGER;
    added_id   INTEGER;
BEGIN
    SELECT id
    INTO db_user_id
    FROM "hdpdb"."api"."app_user"
    WHERE auth0_id = _auth_id
    LIMIT 1;

    UPDATE "hdpdb"."api"."agenda_item"
    SET title       = _title,
        description = _description,
        importance  = _importance,
        start       = _startTS,
        "end"       = _endTS,
        done        = _done
    WHERE agenda_item.id = _id
    RETURNING id INTO added_id;

    RETURN QUERY
        SELECT *
        FROM "hdpdb"."api"."agenda_item"
        WHERE user_id = db_user_id
          AND id = added_id;
END
$$;

NOTIFY pgrst, 'reload schema';

CREATE TABLE recurring_meta
(
    id    SERIAL       NOT NULL,
    title varchar(255) NOT NULL,
    PRIMARY KEY (id)
);

--
-- Dumping data for table 'events'
--

INSERT INTO recurring_meta (id, title)
VALUES (1, 'Sample event'),
       (2, 'Another event'),
       (3, 'Third event...');

CREATE TABLE recurring_rules
(
    id              int                         NOT NULL,
    meta_id         SERIAL                      NOT NULL,
    repeat_start    timestamp without time zone NOT NULL,
    repeat_interval int                     NOT NULL,
    repeat_year     int                     NOT NULL,
    repeat_month    int                     NOT NULL,
    repeat_day      int                     NOT NULL,
    repeat_week     int                     NOT NULL,
    repeat_weekday  int                     NOT NULL,
    PRIMARY KEY (ID),
    UNIQUE (id)
);

--
-- Dumping data for table 'events_meta'
--

INSERT INTO recurring_rules (id, meta_id, repeat_start, repeat_interval, repeat_year, repeat_month, repeat_day,
                             repeat_week, repeat_weekday)
VALUES (1, 1, '2024-02-05 10:27:53.000000', 0, 0, 0, 0, 0, 0),
       (2, 2, '2024-02-05 10:27:53.000000', 0, 2014, -1, -1, 2, 5),
       (3, 3, '2024-02-05 10:27:53.000000', 0, -1, -1, -1, -1, 1);

SELECT EV.*
FROM recurring_rules EV
         RIGHT JOIN recurring_meta EM1 ON EM1.id = EV.meta_id
WHERE ((1370563200 - EXTRACT(EPOCH FROM repeat_start)) % repeat_interval = 0)
   OR (
    (repeat_year = 2014 OR repeat_year = -1)
        AND
    (repeat_month = 7 OR repeat_month = -1)
        AND
    (repeat_day = 4 OR repeat_day = -1)
        AND
    (repeat_week = 2 OR repeat_week = -1)
        AND
    (repeat_weekday = 1 OR repeat_weekday = -1)
        AND (1370563200 - EXTRACT(EPOCH FROM repeat_start)) <= 1370563200
    );