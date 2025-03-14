-- Step 1: Drop the database if it already exists
DROP DATABASE IF EXISTS netflix_database;

-- Step 2: Create the database
CREATE DATABASE netflix_database;

-- Step 3: Connect to the new database
\c netflix_database;

-- Step 4: Create the normalized tables
CREATE TABLE cast_members (
    cast_id SERIAL PRIMARY KEY,
    cast_member VARCHAR(255) NOT NULL
);

CREATE TABLE directors (
    director_id SERIAL PRIMARY KEY,
    director_name VARCHAR(255) NOT NULL
);

CREATE TABLE casting (
    show_id BIGINT NOT NULL,
    cast_id INT NOT NULL,
    director_id INT NOT NULL,
    PRIMARY KEY (show_id, cast_id, director_id),
    FOREIGN KEY (cast_id) REFERENCES cast_members (cast_id),
    FOREIGN KEY (director_id) REFERENCES directors (director_id)
);

CREATE TABLE genres (
    listed_id SERIAL PRIMARY KEY,
    listed_name VARCHAR(255) NOT NULL
);

CREATE TABLE genres_mapping (
    show_id BIGINT NOT NULL,
    listed_id INT NOT NULL,
    PRIMARY KEY (show_id, listed_id),
    FOREIGN KEY (listed_id) REFERENCES genres (listed_id)
);

CREATE TABLE miscellaneous (
    show_id BIGINT PRIMARY KEY,
    type_name VARCHAR(255),
    country_name VARCHAR(255)
);

CREATE TABLE movie_descriptions (
    show_id BIGINT PRIMARY KEY,
    description TEXT
);

CREATE TABLE movie_info (
    show_id BIGINT NOT NULL,
    listed_id INT NOT NULL,
    duration VARCHAR(255),
    PRIMARY KEY (show_id, listed_id),
    FOREIGN KEY (listed_id) REFERENCES genres (listed_id) -- Updated to reference genres
);

CREATE TABLE movies (
    show_id BIGINT PRIMARY KEY,
    title VARCHAR(255) NOT NULL
);

-- Create the ratings table
CREATE TABLE ratings (
    rating_id SERIAL PRIMARY KEY, -- Use SERIAL for auto-incrementing IDs
    rating_description VARCHAR(255) NOT NULL UNIQUE
);

-- Create the ratings_mapping table
CREATE TABLE ratings_mapping (
    show_id BIGINT NOT NULL,
    rating_id INT NOT NULL,
    PRIMARY KEY (show_id, rating_id),
    FOREIGN KEY (show_id) REFERENCES movies(show_id),
    FOREIGN KEY (rating_id) REFERENCES ratings(rating_id) -- Reference the correct table
);

CREATE TABLE time (
    show_id BIGINT PRIMARY KEY,
    date_added DATE,
    release_year INT
);

-- Step 5: Create a temporary table to load CSV data
CREATE TEMP TABLE temp_netflix (
    show_id BIGINT,
    title TEXT,
    director TEXT,
    cast_members TEXT, -- Renamed from "cast" to avoid reserved keyword
    country TEXT,
    date_added TEXT, -- Use TEXT for now, convert to DATE later
    release_year INT,
    rating TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT,
    type TEXT
);

-- Step 6: Load data from the CSV file into the temporary table
COPY temp_netflix (show_id, title, director, cast_members, country, date_added, release_year, rating, duration, listed_in, description, type)
FROM '/Users/macpro/Documents/Git-Repos/netflix-content-trends/netflix_titles_nov_2019.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',');

-- Step 7: Insert data into normalized tables

-- Insert into movies table
INSERT INTO movies (show_id, title)
SELECT show_id, title
FROM temp_netflix;

-- Insert into time table
INSERT INTO time (show_id, date_added, release_year)
SELECT show_id, TO_DATE(date_added, 'Month DD, YYYY'), release_year
FROM temp_netflix;

-- Insert into ratings table
INSERT INTO ratings (rating_description)
SELECT DISTINCT rating
FROM temp_netflix
WHERE rating IS NOT NULL;

-- Insert into ratings_mapping table
INSERT INTO ratings_mapping (show_id, rating_id)
SELECT t.show_id, r.rating_id
FROM temp_netflix t
JOIN ratings r ON t.rating = r.rating_description;

-- Insert into movie_descriptions table
INSERT INTO movie_descriptions (show_id, description)
SELECT show_id, description
FROM temp_netflix;

-- Insert into miscellaneous table
INSERT INTO miscellaneous (show_id, type_name, country_name)
SELECT show_id, type, country
FROM temp_netflix;

-- Insert into genres table
INSERT INTO genres (listed_name)
SELECT DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ',')))
FROM temp_netflix
WHERE listed_in IS NOT NULL;

-- Insert into genres_mapping table
INSERT INTO genres_mapping (show_id, listed_id)
SELECT t.show_id, l.listed_id
FROM temp_netflix t
JOIN genres l ON l.listed_name = ANY(STRING_TO_ARRAY(t.listed_in, ','));

-- Insert into cast_members table
INSERT INTO cast_members (cast_member)
SELECT DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(cast_members, ',')))
FROM temp_netflix
WHERE cast_members IS NOT NULL;

-- Insert into directors table
INSERT INTO directors (director_name)
SELECT DISTINCT TRIM(UNNEST(STRING_TO_ARRAY(director, ',')))
FROM temp_netflix
WHERE director IS NOT NULL;

-- Insert into casting table
INSERT INTO casting (show_id, cast_id, director_id)
SELECT t.show_id, c.cast_id, d.director_id
FROM temp_netflix t
JOIN cast_members c ON c.cast_member = ANY(STRING_TO_ARRAY(t.cast_members, ','))
JOIN directors d ON d.director_name = ANY(STRING_TO_ARRAY(t.director, ','));

-- Insert into movie_info table
INSERT INTO movie_info (show_id, listed_id, duration)
SELECT t.show_id, l.listed_id, t.duration
FROM temp_netflix t
JOIN genres l ON l.listed_name = ANY(STRING_TO_ARRAY(t.listed_in, ','));

-- Step 8: Clean up the temporary table
DROP TABLE temp_netflix;

-- Step 9: Verify the data (optional)
-- Example: Check the first 5 rows from the movies table
SELECT * FROM movies LIMIT 5;

-- Example: Check the cast members for a specific show
SELECT c.cast_member
FROM cast_members c
JOIN casting ct ON c.cast_id = ct.cast_id
WHERE ct.show_id = 81193313;

-- To run the script
-- psql -U shazzad -d postgres -f netflix_import.sql