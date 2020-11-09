CREATE TABLE ARTISTS
(
artist   TEXT  ,
artwork TEXT ,
wiki    TEXT,
PRIMARY KEY(artist)
);

CREATE TABLE ALBUMS
(
album   TEXT ,
artist  TEXT,
artwork TEXT,
wiki    TEXT,
PRIMARY KEY(album, artist),
FOREIGN KEY(artist) REFERENCES artists(artist)
);

CREATE TABLE SOURCES_TYPES
(
id INTEGER PRIMARY KEY,
name TEXT NOT NULL
);

CREATE TABLE SOURCES
(
url TEXT PRIMARY KEY ,
sourcetype INTEGER NOT NULL,
FOREIGN KEY(sourcetype) REFERENCES SOURCES_TYPES(id)
);

CREATE TABLE TRACKS
(
url TEXT ,
source TEXT  ,
track   INTEGER ,
title   TEXT NOT NULL,
artist  TEXT NOT NULL,
album    TEXT NOT NULL,
duration    INTEGER  ,
comment     TEXT,
count      INTEGER  ,
rate       INTEGER NOT NULL,
releasedate DATE ,
adddate     DATE NOT NULL,
lyrics     TEXT NOT NULL,
genre      TEXT,
wiki    TEXT NOT NULL,
PRIMARY KEY (url),
FOREIGN KEY(source) REFERENCES SOURCES(url),
FOREIGN KEY(album, artist) REFERENCES albums(album, artist)
);

--First insertions

INSERT INTO SOURCES_TYPES VALUES (1,"LOCAL");
INSERT INTO SOURCES_TYPES VALUES (2,"ONLINE");
INSERT INTO SOURCES_TYPES VALUES (3,"DEVICE");
