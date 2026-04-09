-- Automatically runs as it's an .sql file in the entrypoint folder
USE wordpress
INSERT INTO posts (title, content) VALUES ('Hello World', 'Preloaded post');