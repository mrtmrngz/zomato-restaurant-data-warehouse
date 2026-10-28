-- the 10 types of cuisine with the most restaurant

SELECT
    c.cuisine_name,
    COUNT(*) AS cuisine_restaurant_count
FROM gold.dim_restaurant r
INNER JOIN gold.bridge_restaurant_cuisine brc on r.restaurant_key = brc.restaurant_key
INNER JOIN gold.dim_cuisine c on brc.cuisine_key = c.cuisine_key
GROUP BY c.cuisine_name
ORDER BY cuisine_restaurant_count DESC
LIMIT 10;

-- the 3 most common types of restaurants in each country

SELECT
	country_name,
	cuisine_name,
	total_cuisine,
	ROUND(percentage, 2) || '%' percentage_of_country,
	cuisine_country_rank
FROM (
SELECT
	l.country_name,
	c.cuisine_name,
	COUNT(*) total_cuisine,
	(COUNT(*)/SUM(COUNT(*)) OVER(PARTITION BY l.country_name)::numeric) * 100 AS percentage,
	RANK() OVER (PARTITION BY l.country_name ORDER BY COUNT(*) DESC) cuisine_country_rank
FROM gold.dim_restaurant r
INNER JOIN gold.bridge_restaurant_cuisine brc ON brc.restaurant_key = r.restaurant_key
INNER JOIN gold.dim_cuisine c ON c.cuisine_key = brc.cuisine_key
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
GROUP BY l.country_name, c.cuisine_name
)t
WHERE cuisine_country_rank<=3
ORDER BY country_name, total_cuisine DESC;

-- The 10 cuisine with the highest average ratings in the world

SELECT
	c.cuisine_name,
	ROUND(AVG(r.agg_rating), 2) avg_cuisine_rating,
    COUNT(*) rated_restaurant_count
FROM gold.dim_restaurant r
INNER JOIN gold.bridge_restaurant_cuisine brc ON brc.restaurant_key = r.restaurant_key
INNER JOIN gold.dim_cuisine c ON c.cuisine_key = brc.cuisine_key
WHERE r.agg_rating > 0
GROUP BY c.cuisine_name
HAVING COUNT(*) > 5
ORDER BY AVG(r.agg_rating) DESC
LIMIT 10;

-- The 3 highest-rated cuisine types in each country

SELECT
	country_name,
	cuisine_name,
	ROUND(avg_cuisine_country_rating, 2) avg_cuisine_country_rating,
	cuisine_country_rank,
	rated_restaurant_count
FROM (
SELECT
	l.country_name,
	c.cuisine_name,
	AVG(r.agg_rating) avg_cuisine_country_rating,
	RANK() OVER (PARTITION BY l.country_name  ORDER BY AVG(r.agg_rating) DESC) cuisine_country_rank,
	COUNT(*) rated_restaurant_count
FROM gold.dim_restaurant r
INNER JOIN gold.bridge_restaurant_cuisine brc ON brc.restaurant_key = r.restaurant_key
INNER JOIN gold.dim_cuisine c ON c.cuisine_key = brc.cuisine_key
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
WHERE r.agg_rating > 0
GROUP BY l.country_name, c.cuisine_name
)t WHERE cuisine_country_rank<=3
ORDER BY country_name, cuisine_country_rank;


SELECT
	c1.cuisine_name,
	c2.cuisine_name,
	COUNT(*) AS couple_count
FROM gold.bridge_restaurant_cuisine brc1
INNER JOIN gold.bridge_restaurant_cuisine brc2
    ON brc1.restaurant_key = brc2.restaurant_key
INNER JOIN gold.dim_cuisine c1 ON c1.cuisine_key = brc1.cuisine_key
INNER JOIN gold.dim_cuisine c2 ON c2.cuisine_key = brc2.cuisine_key
WHERE brc1.cuisine_key < brc2.cuisine_key
GROUP BY c1.cuisine_name, c2.cuisine_name
ORDER BY couple_count DESC;

-- Relationship between cuisine diversity and restaurant ratings

WITH restaurant_cuisine_counts AS (
    SELECT
        r.restaurant_key,
        r.name,
        r.agg_rating,
        r.votes,
        COUNT(brc.cuisine_key) AS cuisine_count
    FROM gold.dim_restaurant r
    LEFT JOIN gold.bridge_restaurant_cuisine brc
        ON brc.restaurant_key = r.restaurant_key
    GROUP BY r.restaurant_key
),
cuisine_groups AS (
    SELECT
        CASE
            WHEN cuisine_count >= 4 THEN '4+'
            ELSE cuisine_count::text
        END AS cuisine_group,
        agg_rating,
        votes
    FROM restaurant_cuisine_counts
)
SELECT
    cuisine_group,
    COUNT(*) AS restaurant_count,
    ROUND(
        AVG(agg_rating) FILTER (WHERE agg_rating > 0), 2
    ) AS avg_rating,
    ROUND(AVG(votes), 2) AS avg_votes
FROM cuisine_groups
GROUP BY cuisine_group
ORDER BY
    CASE
        WHEN cuisine_group = '4+' THEN 4
        ELSE cuisine_group::int
    END;