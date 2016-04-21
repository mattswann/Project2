CREATE DATABASE bookshelf;

\c bookshelf

CREATE TABLE my_books(
  id SERIAL4 PRIMARY KEY,
  title VARCHAR(300),
  author VARCHAR(300),
  year VARCHAR(50),
  cover VARCHAR(1000),
  page_count INTEGER,
  category VARCHAR(50),
  isbn VARCHAR(50)
);


SELECT * FROM books;

CREATE TABLE categories(
  id SERIAL4 PRIMARY KEY,
  name VARCHAR(50) NOT NULL
);

INSERT INTO categories (name) VALUES ('art-music');
INSERT INTO categories (name) VALUES ('biography');
INSERT INTO categories (name) VALUES ('business');
INSERT INTO categories (name) VALUES ('classics');
INSERT INTO categories (name) VALUES ('fiction');
INSERT INTO categories (name) VALUES ('history');
INSERT INTO categories (name) VALUES ('non-fiction');
INSERT INTO categories (name) VALUES ('romance');
INSERT INTO categories (name) VALUES ('science');

CREATE TABLE authors(
  id SERIAL4 PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50)
);

CREATE TABLE reviews(
  id SERIAL4 PRIMARY KEY,
  body VARCHAR(1000) NOT NULL,
  book_id INTEGER
);

CREATE TABLE users (
  id SERIAL4 PRIMARY KEY,
  email VARCHAR(50) NOT NULL,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  password_digest VARCHAR(400) NOT NULL
);

CREATE TABLE favourites(
  id SERIAL4 PRIMARY KEY,
  user_id INTEGER,
  book_id INTEGER
);
