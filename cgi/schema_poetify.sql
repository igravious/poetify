
--
-- make sure that the Apache (Web Server) user or group has read/write
-- access to the sqlite file _and_ folder
--

DROP TABLE TreePaths;
DROP TABLE ePages;
DROP TABLE KindConstants;

--

CREATE TABLE KindConstants
(
kind INT UNIQUE,
user_visible CHAR(32) NOT NULL,
klass_name CHAR(32) NOT NULL,
body_check TEXT,
PRIMARY KEY (kind)
);

-- ...Poem - these are inherited from class Poem in actuality

INSERT INTO KindConstants VALUES (NULL, 'Folder', 'Folder', NULL);
INSERT INTO KindConstants VALUES (1, 'Singular', 'SingularPoem', NULL);
INSERT INTO KindConstants VALUES (2, 'Re:Verse', 'ReversePoem', NULL);
INSERT INTO KindConstants VALUES (3, 'Multi:Verse', 'MultiversePoem', NULL);
INSERT INTO KindConstants VALUES (4, 'Trace:Verse', 'TraceversePoem', NULL);

--
-- even though we found a poem with a title length of 352
-- let's keep it to tweet/
--

CREATE TABLE ePages
(
epage_id INTEGER UNIQUE NOT NULL,
label CHAR(32) NOT NULL,
title CHAR(140),
kind INT,
body TEXT,
FOREIGN KEY (kind) REFERENCES KindConstants(kind),
PRIMARY KEY (epage_id)
);

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