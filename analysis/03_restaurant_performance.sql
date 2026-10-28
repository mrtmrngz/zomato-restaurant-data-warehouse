

WITH CTE_Restaurant_Engagement_Analysis AS
(
    SELECT
        CASE
            WHEN votes = 0 THEN 'Not Rated'
            WHEN votes BETWEEN 1 AND 99 THEN 'Low Engagement'
            WHEN votes BETWEEN 100 AND 499 THEN 'Medium Engagement'
            WHEN votes BETWEEN 500 AND 999 THEN 'High Engagement'
            ELSE 'Very High Engagement'
        END AS engagement_group,
        agg_rating,
        votes
    FROM gold.dim_restaurant
)
SELECT
    engagement_group,
    COUNT(*) AS restaurant_count,
    ROUND(
        AVG(agg_rating) FILTER (WHERE agg_rating  > 0), 2
    ) AS average_rating,
    ROUND(AVG(votes), 2) AS average_votes,
    MIN(agg_rating) FILTER (WHERE agg_rating  > 0) minimum_rating,
    MAX(agg_rating) FILTER (WHERE agg_rating  > 0) maximum_rating,
    STDDEV_SAMP(agg_rating) FILTER (WHERE agg_rating  > 0) rating_stddev
FROM CTE_Restaurant_Engagement_Analysis
GROUP BY engagement_group
ORDER BY MIN(votes);


SELECT
    agg_rating,
    COUNT(*)
FROM gold.dim_restaurant
WHERE votes BETWEEN 1 AND 99 AND agg_rating > 0
GROUP BY agg_rating
ORDER BY agg_rating;

-- POPULAR BUT LOW RATED RESTAURANTS

SELECT
    l.country_name country,
    l.city,
    r.name,
    r.agg_rating,
    r.votes
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
WHERE r.votes >= 1000 AND agg_rating < 3
ORDER BY agg_rating, votes DESC;

WITH CTE_Vote_Gap_Freq_Analysis AS
(
    SELECT
        CASE
            WHEN agg_rating BETWEEN 0 AND 2.9 THEN '0–2.9'
            WHEN agg_rating BETWEEN 3.0 AND 3.4 THEN '3.0–3.4'
            WHEN agg_rating BETWEEN 3.5 AND 3.9 THEN '3.5–3.9'
            WHEN agg_rating BETWEEN 4 AND 4.4 THEN '4–4.4'
            WHEN agg_rating BETWEEN 4.5 AND 5.0 THEN '4.5–5.0'
        ELSE 'Unknown'
        END AS rating_gap
    FROM gold.dim_restaurant
    WHERE votes >= 1000
)
SELECT
    rating_gap,
    COUNT(*) restaurant_count,
    ROUND((COUNT(*) / SUM(COUNT(*)) OVER())::numeric * 100, 2) || '%'
FROM CTE_Vote_Gap_Freq_Analysis
GROUP BY rating_gap
ORDER BY rating_gap;

SELECT
    l.country_name country,
    COUNT(*) restaurant_count,
    COUNT(*) FILTER ( WHERE agg_rating > 0 ) rated_restaurant_count,
    COUNT(*) FILTER ( WHERE agg_rating >= 4 ) high_rated_count,
    COUNT(*) FILTER ( WHERE agg_rating > 0 )::numeric / COUNT(*) * 100 rated_percentage,
    ROUND(COUNT(*) FILTER ( WHERE agg_rating >= 4 )::numeric / COUNT(*) FILTER ( WHERE agg_rating > 0 ) * 100, 2) high_rated_percentage
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
GROUP BY l.country_name
HAVING COUNT(*) FILTER ( WHERE agg_rating > 0 ) >= 20
ORDER BY high_rated_percentage DESC;

WITH CTE_Country_Average AS
(
    SELECT
        l.country_name,
        r.name,
        r.votes,
        r.agg_rating,
        AVG(agg_rating) OVER(PARTITION BY l.country_name) country_average,
        ROW_NUMBER() OVER(PARTITION BY l.country_name ORDER BY r.agg_rating DESC, r.votes DESC, r.restaurant_key) restaurant_rank
    FROM gold.dim_restaurant r
    INNER JOIN gold.dim_location l ON r.location_key = l.location_key
    WHERE r.agg_rating > 0
)
SELECT
    country_name,
    name,
    votes,
    agg_rating,
    ROUND(country_average, 2) country_average,
    agg_rating - country_average AS rating_difference,
    restaurant_rank
FROM CTE_Country_Average
WHERE agg_rating > country_average AND restaurant_rank <= 3
ORDER BY country_name, restaurant_rank;