
--
-- make sure that the Apache (Web Server) user or group has read/write
-- access to the sqlite file _and_ folder
--

DROP TABLE TreePaths;
DROP TABLE ePages;

--

CREATE TABLE TreePaths
(
parent_id INTEGER,
epage_id INTEGER NOT NULL,
depth INTEGER,
PRIMARY KEY (parent_id, epage_id),
FOREIGN KEY (parent_id) REFERENCES ePages(epage_id),
FOREIGN KEY (epage_id) REFERENCES ePages(epage_id)
);

--

CREATE TABLE ePages
(
epage_id INTEGER UNIQUE NOT NULL,
label CHAR(32) NOT NULL,
kind INTEGER,
PRIMARY KEY (epage_id)
);