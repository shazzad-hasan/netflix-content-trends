---------- Content Strategy Development ------------
-- Investigate which genres or type of contents are most popular
-- based on distributions of shows or movies across different genres and ratings over time

WITH show_data AS (
    SELECT
        gm.show_id,
        t.release_year,
        g.listed_name AS genre,
        m.type_name AS type,
        rm.rating_id
    FROM genres_mapping gm
    JOIN genres g ON g.listed_id = gm.listed_id
    JOIN ratings_mapping rm ON gm.show_id = rm.show_id
    JOIN ratings r ON rm.rating_id = r.rating_id
    JOIN miscellaneous m ON gm.show_id = m.show_id
    JOIN time t ON gm.show_id = t.show_id
)
SELECT
    release_year,
    genre,
    type,
    COUNT(DISTINCT show_id) AS total_shows,
    ROUND(AVG(rating_id), 2) AS average_rating
FROM show_data
GROUP BY release_year, genre, type
ORDER BY release_year, total_shows DESC, average_rating DESC;

---------- Market Analysis -------------
-- Analyze the distribution of content across different countries  to tailor marketing strategies
-- based on the type of content each country spends the most time watching

WITH content_duration AS (
    -- CTE 1
    SELECT
        m.country_name,
        m.type_name,
        SUM(
            CASE 
                -- Extract numeric part if min
                WHEN mi.duration LIKE '% min' THEN CAST(SUBSTRING(mi.duration FROM '^\d+') AS INTEGER)
                --  Assuming 1 season = 600 minutes (10 hours)
                WHEN mi.duration LIKE '% Season%' THEN CAST(SUBSTRING(mi.duration FROM '^\d+') AS INTEGER) * 600 
                ELSE 0 -- Default for unknown formats
            END
        ) AS total_duration_minutes
    FROM miscellaneous m
    JOIN movie_info mi ON m.show_id = mi.show_id
    GROUP BY m.country_name, m.type_name
),
ranked_content AS (
    -- CTE 2 using CTE 1
    SELECT
        country_name,
        type_name,
        total_duration_minutes,
        RANK() OVER (PARTITION BY country_name ORDER BY total_duration_minutes DESC) AS rank
    FROM content_duration
)
-- Main query using CTE 3
SELECT
    country_name,
    type_name AS most_watched_content_type,
    total_duration_minutes
FROM ranked_content
WHERE rank = 1 -- Filter out the most-watched content type
ORDER BY country_name;

-------------- Release Timing Analysis ------------
-- Query: Analyze which month have had historically the most releases
-- based on the best time of the year
SELECT
    EXTRACT(MONTH FROM t.date_added) AS release_month,
    COUNT(*) AS total_releases,
    ROUND(AVG(rm.rating_id), 2) AS average_rating
FROM time t
JOIN ratings_mapping rm ON t.show_id = rm.show_id
GROUP BY release_month
ORDER BY total_releases, average_rating DESC;

-------------- Director and Cast Analysis ----------
-- Examine previous collaboration between directors and cast members the resulted highly 
-- rated shows and movies
with director_cast AS (
    SELECT 
        d.director_name,
        cm.cast_member,
        rm.rating_id,
        r.rating_description
    FROM casting c
    JOIN directors  d ON c.director_id = d.director_id
    JOIN cast_members cm ON c.cast_id = cm.cast_id
    JOIN ratings_mapping rm ON c.show_id = rm.show_id
    JOIN ratings r ON rm.rating_id = r.rating_id
)
SELECT 
    director_name,
    cast_member,
    COUNT(*) AS total_collaboration,
    ROUND(AVG(rating_id), 2) AS average_rating
FROM director_cast
GROUP BY director_name, cast_memberq
HAVING AVG(rating_id) >= 7
ORDER BY total_collaboration DESC, average_rating DESC; 

---------------- Viewer Preferences Analysis ---------------------
-- Analyze viewer preferences based on genres and ratings over time
with viewer_preferences AS (
    SELECT 
        g.listed_name AS genre,
        t.release_year,
        ROUND(AVG(rm.rating_id), 2) AS average_rating
    FROM genres_mapping gm
    JOIN genres g ON gm.listed_id = g.listed_id
    JOIN ratings_mapping rm ON gm.show_id = rm.show_id
    JOIN ratings r ON rm.rating_id = r.rating_id
    JOIN time t ON gm.show_id = t.show_id
    GROUP BY g.listed_name, t.release_year
)
SELECT
    genre,
    release_year,
    average_rating
FROM viewer_preferences
ORDER BY release_year, average_rating;

--------------- Content Localization Strategy -------------
-- Optimizing content strategies for specific countries by identifying most common genre
-- and type of movies/shows for each specific countries
with country_preference AS (
    SELECT 
        m.country_name,
        g.listed_name AS genre,
        m.type_name AS content_type,
        COUNT(*) AS total_shows
    FROM genres_mapping gm
    JOIN genres g ON gm.listed_id = g.listed_id
    JOIN miscellaneous m ON gm.show_id = m.show_id
    GROUP BY m.country_name, g.listed_name, m.type_name
)
SELECT
    country_name,
    genre,
    content_type,
    total_shows
FROM country_preference
ORDER BY country_name, total_shows DESC;

-------------- Budget Allocation for New Production -------------
-- Determine budget allocation strategy based on correlation between 
-- genre type and ratings/popularity
with genre_popularity AS (
    SELECT
        g.listed_name AS genre,
        m.type_name AS content_type,
        COUNT(*) AS total_shows,
        ROUND(AVG(rm.rating_id), 2) AS average_rating
    FROM genres_mapping gm
    JOIN genres g ON gm.listed_id = g.listed_id
    JOIN ratings_mapping rm ON gm.show_id = rm.show_id
    JOIN miscellaneous m ON gm.show_id = m.show_id
    GROUP BY g.listed_name, m.type_name
)
SELECT
    genre,
    content_type,
    total_shows,
    average_rating
FROM genre_popularity
ORDER BY average_rating DESC, total_shows DESC;