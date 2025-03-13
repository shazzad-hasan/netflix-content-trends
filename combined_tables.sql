-- Step 1: Create the denormalized table
CREATE TABLE netflix_combined (
    show_id BIGINT PRIMARY KEY,
    title TEXT,
    director_name TEXT,
    cast_members TEXT,
    country_name TEXT,
    date_added DATE,
    release_year INT,
    rating_description TEXT,
    duration TEXT,
    listed_in TEXT,
    description TEXT,
    type_name TEXT
);

-- Step 2: Populate the denormalized table by joining all normalized tables
INSERT INTO netflix_combined (
    show_id,
    title,
    director_name,
    cast_members,
    country_name,
    date_added,
    release_year,
    rating_description,
    duration,
    listed_in,
    description,
    type_name
)
SELECT
    m.show_id,
    m.title,
    STRING_AGG(d.director_name, ', ') AS director_name,
    STRING_AGG(cm.cast_member, ', ') AS cast_members,
    ms.country_name,
    t.date_added,
    t.release_year,
    r.rating_description,
    mi.duration,
    STRING_AGG(li.listed_name, ', ') AS listed_in,
    md.description,
    ms.type_name
FROM
    movies m
LEFT JOIN time t ON m.show_id = t.show_id
LEFT JOIN ratings r ON m.show_id = r.show_id
LEFT JOIN movie_descriptions md ON m.show_id = md.show_id
LEFT JOIN miscellaneous ms ON m.show_id = ms.show_id
LEFT JOIN casting c ON m.show_id = c.show_id
LEFT JOIN cast_members cm ON c.cast_id = cm.cast_id
LEFT JOIN directors d ON c.director_id = d.director_id
LEFT JOIN data_listed_in dli ON m.show_id = dli.show_id
LEFT JOIN listed_in li ON dli.listed_id = li.listed_id
LEFT JOIN movie_info mi ON m.show_id = mi.show_id
GROUP BY
    m.show_id,
    m.title,
    ms.country_name,
    t.date_added,
    t.release_year,
    r.rating_description,
    mi.duration,
    md.description,
    ms.type_name;

-- Step 3: Verify the denormalized table
SELECT * FROM netflix_combined LIMIT 5;

-- To run the script
-- psql -U shazzad -d netflix_database -f combined_tables.sql