
SELECT
    t.country_name,
    t.restaurant_count,
    ROUND(t.country_restaurant_avg_rating, 2) avg_restaurant_rating,
    t.country_restaurant_total_votes
FROM (
    SELECT
        l.country_name,
        COUNT(r.*) AS restaurant_count,
        AVG(r.agg_rating) FILTER ( WHERE r.votes > 0 ) AS country_restaurant_avg_rating,
        SUM(r.votes) country_restaurant_total_votes,
        RANK() OVER(ORDER BY COUNT(r.*) DESC) AS country_restaurant_count_rank
    FROM gold.dim_location l
    INNER JOIN gold.dim_restaurant r ON r.location_key = l.location_key
    GROUP BY l.country_name

)t WHERE t.country_restaurant_count_rank <= 10
ORDER BY restaurant_count DESC;

SELECT
    *
FROM (
    SELECT
       l.country_name,
       l.city,
       COUNT(r.*) AS city_restaurant_count,
       ROW_NUMBER() OVER(PARTITION BY l.country_name ORDER BY COUNT(r.*) DESC) city_rank
FROM gold.dim_location l
INNER JOIN gold.dim_restaurant r ON r.location_key = l.location_key
GROUP BY l.country_name, l.city
ORDER BY city_restaurant_count DESC
)t
WHERE city_rank <= 3
ORDER BY t.country_name, t.city_rank, t.city;


WITH CTE_Country_Avg AS
(
    SELECT
        l.country_name,
        AVG(r.agg_rating) FILTER ( WHERE r.votes > 0 ) country_restaurant_avg
    FROM gold.dim_location l
    INNER JOIN gold.dim_restaurant r ON r.location_key = l.location_key
    GROUP BY l.country_name
)
, CTE_City_Avg AS
(
        SELECT
            l.country_name,
            l.city,
            COUNT(r.*) city_restaunrat_count,
            COUNT(r.*) FILTER ( WHERE r.votes > 0 ) city_voted_restaunrat_count,
            AVG(r.agg_rating) FILTER ( WHERE r.votes > 0 ) city_restaurant_avg
        FROM gold.dim_location l
        INNER JOIN gold.dim_restaurant r ON r.location_key = l.location_key
        GROUP BY l.country_name, l.city
)
SELECT
    cca.country_name,
    cca.city,
    cca.city_restaunrat_count,
    cca.city_voted_restaunrat_count,
    ROUND(cca.city_restaurant_avg, 2) AS city_avg,
    ROUND(ccoa.country_restaurant_avg, 2) AS country_avg,
    cca.city_restaurant_avg - ccoa.country_restaurant_avg AS rating_difference
FROM CTE_City_Avg cca
INNER JOIN CTE_Country_Avg ccoa ON ccoa.country_name = cca.country_name AND cca.city_restaurant_avg > ccoa.country_restaurant_avg
WHERE cca.city_voted_restaunrat_count >= 5
ORDER BY rating_difference DESC;

WITH CTE_Ranked_Restaurants  AS
(
    SELECT
        l.country_name,
        r.name,
        r.votes,
        r.agg_rating,
        ROW_NUMBER() OVER(
            PARTITION BY l.country_name
            ORDER BY agg_rating DESC, votes DESC, r.restaurant_key) rank
    FROM gold.dim_location l
    INNER JOIN gold.dim_restaurant r ON r.location_key = l.location_key
    WHERE r.votes >= 100
)
SELECT
    *
FROM CTE_Ranked_Restaurants
WHERE rank <= 5
ORDER BY country_name, rank;
