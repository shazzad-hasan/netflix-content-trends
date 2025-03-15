-- Investigate which genres or type of contents are most popular
-- based on distributions of shows or movies across different genres and ratings over time

SELECT 
    t.release_year,
    g.listed_name AS genre,
    m.type_name AS type,
    COUNT(DISTINCT gm.show_id) AS total_shows,
    ROUND(AVG(rm.rating_id), 2) AS average_rating
FROM genres_mapping gm
JOIN genres g ON g.listed_id = gm.listed_id
JOIN ratings_mapping rm ON gm.show_id = rm.show_id
JOIN ratings r ON rm.rating_id = r.rating_id
JOIN miscellaneous m ON gm.show_id = m.show_id
JOIN time t ON gm.show_id = t.show_id
GROUP BY t.release_year, g.listed_name, m.type_name
ORDER BY t.release_year, total_shows DESC, average_rating DESC;