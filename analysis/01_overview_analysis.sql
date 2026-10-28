SELECT
    COUNT(r.*) AS total_restaurant_count,
    COUNT(DISTINCT l.country_name) AS total_countries_count,
    COUNT(DISTINCT (l.country_code, l.city)) AS total_city_count,
    AVG(r.agg_rating) AS general_avg_rating,
    AVG(r.agg_rating) FILTER ( WHERE r.votes > 0 ) AS general_avg_rating_without_not_rated,
    SUM(r.votes) AS total_votes,
    CAST(SUM(CASE WHEN r.has_online_delivery = true THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS percantage_of_online_delivery,
    CAST(SUM(CASE WHEN r.has_table_booking = true THEN 1 ELSE 0 END) AS FLOAT) / COUNT(*) * 100 AS percantage_of_table_booking
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON l.location_key = r.location_key;