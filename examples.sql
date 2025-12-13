-- Successful
INSERT INTO user (username, email) VALUES ('Alice22', 'alice22@example.com');
-- With NOT NULL violation
INSERT INTO user (username, email) VALUES (NULL, 'alice22@example.com');
-- With type violation
INSERT INTO user (username, email) VALUES ('Bob33', 12345);
-- Another type violation
INSERT INTO user (username, email) VALUES ('Charlie44', TRUE);
-- A varchar length violation
INSERT INTO user (username, email) VALUES ('ThisUsernameIsWayTooLongToBeValid', 'thisemailisalsowaytoolongtobevalid121212212@example.com');
-- Unique constraint violation
INSERT INTO user (username, email) VALUES ('Alice22', 'alice22@example.com');
INSERT INTO user (username, email) VALUES ('Alice22', 'alice22@example.com');
-- PK constraint violation
INSERT INTO user (id, username, email) VALUES (1, 'David55', 'david55@example.com');
INSERT INTO user (id, username, email) VALUES (1, 'Eve66', 'eve66@example.com');

-- Update
UPDATE user SET email = 'none@none.none' WHERE id = 1;
-- With NOT NULL violation
UPDATE user SET username = NULL WHERE id = 2;

-- Delete
DELETE FROM user WHERE id = 1;