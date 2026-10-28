SELECT
    restaurant_id,
    name,
    l.country_name
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON r.location_key = l.location_key
WHERE NOT EXISTS(
    SELECT 1
    FROM gold.bridge_restaurant_cuisine brc
    WHERE brc.restaurant_key = r.restaurant_key
);

-- VALID COORDINATES

SELECT
    restaurant_id,
    name,
    longitude,
    latitude
FROM gold.dim_restaurant
INNER JOIN gold.dim_location l ON dim_restaurant.location_key = l.location_key
WHERE latitude IS NULL
    OR longitude IS NULL
    OR (latitude NOT BETWEEN -90 AND 90)
    OR (longitude NOT BETWEEN -180 AND 180)
    OR (longitude = 0 AND latitude = 0);

-- ZERO COORDINATES countries

SELECT
    *,
    ROUND(zero_coordinates_count / total_restaurants::numeric * 100, 2) || '%' zero_coordinates_percentage
FROM (
      SELECT
    l.country_name,
    COUNT(*) total_restaurants,
    COUNT(*) FILTER ( WHERE (longitude = 0 AND latitude = 0) ) zero_coordinates_count
FROM gold.dim_restaurant
INNER JOIN gold.dim_location l ON dim_restaurant.location_key = l.location_key
GROUP BY l.country_name
)t
ORDER BY zero_coordinates_count DESC;

-- rate and vote issue check

SELECT
    restaurant_id,
    name,
    agg_rating,
    votes,
    CASE
        WHEN agg_rating > 0 AND votes = 0 THEN 'Rating gt zero but votes eq zero'
        WHEN agg_rating = 0 AND votes > 0 THEN 'Rating eq zero but votes gt zero'
    END AS issue_type
FROM gold.dim_restaurant
WHERE (agg_rating > 0 AND votes = 0)
    OR (agg_rating = 0 AND votes > 0);

SELECT
    issue_type,
    COUNT(*) issue_count,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER()::numeric * 100, 2) issue_count_percentage_over_total
FROM (
    SELECT
    CASE
        WHEN agg_rating > 0 AND votes = 0 THEN 'Rating gt zero but votes eq zero'
        WHEN agg_rating = 0 AND votes > 0 THEN 'Rating eq zero but votes gt zero'
        ELSE 'No Issue'
    END AS issue_type
FROM gold.dim_restaurant
)t
GROUP BY issue_type
ORDER BY issue_count_percentage_over_total DESC;

SELECT
    restaurant_key,
    cuisine_key,
    COUNT(*)
FROM gold.bridge_restaurant_cuisine
GROUP BY restaurant_key, cuisine_key
HAVING COUNT(*) > 1;

-- RESTAURANT ID DUPLICATE CHECK

SELECT
    restaurant_id,
    COUNT(*) duplicate_count
FROM gold.dim_restaurant
GROUP BY restaurant_id
HAVING COUNT(*) > 1;

SELECT
    rating_text,
    MIN(agg_rating),
    MAX(agg_rating),
    COUNT(*)
FROM silver.restaurants
GROUP BY rating_text
ORDER BY MIN(agg_rating);

SELECT
    restaurant_key,
    restaurant_id,
    avg_cost_for_two,
    currency_code
FROM gold.dim_restaurant;

SELECT
    r.restaurant_key,
    r.restaurant_id,
    r.avg_cost_for_two,
    r.currency_code
FROM gold.dim_restaurant r
LEFT JOIN gold.bridge_restaurant_cuisine brc ON brc.restaurant_key = r.restaurant_key
WHERE brc.restaurant_key IS NULL AND r.avg_cost_for_two <= 0;

SELECT
    r.price_range,
    COUNT(r.restaurant_id) restaunrat_count,
    AVG(avg_cost_for_two) avg_cost_for_two
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
WHERE l.country_name = 'India' AND r.avg_cost_for_two > 0
GROUP BY r.price_range
ORDER BY r.price_range;

SELECT
    *
FROM (
    SELECT
    r.restaurant_id,
    name,
    price_range,
    avg_cost_for_two,
    AVG(avg_cost_for_two) OVER(PARTITION BY price_range) category_avg_cost,
    avg_cost_for_two - AVG(avg_cost_for_two) OVER(PARTITION BY price_range) diffrence
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
WHERE l.country_name = 'India' AND r.avg_cost_for_two > 0
)t
ORDER BY diffrence DESC
LIMIT 10;

WITH CTE_RestaurantAvgCost_Deviation_Percentage AS
(
     SELECT
        r.restaurant_id,
        name,
        price_range,
        avg_cost_for_two,
        AVG(avg_cost_for_two) OVER(PARTITION BY price_range) category_avg_cost
    FROM gold.dim_restaurant r
    INNER JOIN gold.dim_location l ON l.location_key = r.location_key
    WHERE l.country_name = 'India' AND r.avg_cost_for_two > 0
)
SELECT
    *,
    ROUND((avg_cost_for_two - category_avg_cost) / category_avg_cost * 100, 2) deviation_percentage
FROM CTE_RestaurantAvgCost_Deviation_Percentage
ORDER BY deviation_percentage DESC
LIMIT 10;

SELECT
    l.country_name,
    COUNT(r.restaurant_key) restaurant_count,
    ROUND(AVG(avg_cost_for_two), 2) avg_cost,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_cost_for_two) median_cost,
    ROUND(
    (
        AVG(r.avg_cost_for_two)
        - PERCENTILE_CONT(0.5)
          WITHIN GROUP (ORDER BY r.avg_cost_for_two)
    )::numeric,
    2
) AS difference
FROM gold.dim_location l
INNER JOIN gold.dim_restaurant r ON l.location_key = r.location_key
WHERE avg_cost_for_two > 0
GROUP BY l.country_name;

WITH CTE_Country_Median_Percent AS
(
SELECT
    country_name,
    COUNT(r.restaurant_key) restaurant_count,
    AVG(avg_cost_for_two) avg_cost,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_cost_for_two) median_cost
FROM gold.dim_location l
INNER JOIN gold.dim_restaurant r ON l.location_key = r.location_key
WHERE avg_cost_for_two > 0
GROUP BY l.country_name
)
SELECT
    country_name,
    restaurant_count,
    ROUND(avg_cost::numeric, 2) avg_cost,
    median_cost,
    ROUND(avg_cost - median_cost::numeric, 2) difference,
    ROUND((avg_cost - median_cost)::numeric / median_cost::numeric * 100, 2) difference_percentage
FROM CTE_Country_Median_Percent
ORDER BY difference_percentage DESC;

WITH CTE_QUARTER_ANLYSIS AS
(
SELECT
    country_name,
    COUNT(r.restaurant_key) restaurant_count,
    PERCENTILE_CONT(0.25) WITHIN GROUP ( ORDER BY avg_cost_for_two ) q1_cost,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY avg_cost_for_two) median_cost,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY avg_cost_for_two) q3_cost
FROM gold.dim_location l
INNER JOIN gold.dim_restaurant r ON l.location_key = r.location_key
WHERE avg_cost_for_two > 0
GROUP BY l.country_name
)
SELECT
    *,
    q3_cost-q1_cost AS iqr
FROM CTE_QUARTER_ANLYSIS
ORDER BY iqr DESC;

-- IQR yöntemiyle aykırı maliyetleri bulma

WITH CTE_IQR1 AS
(
SELECT
    price_range,
    PERCENTILE_CONT(0.25) WITHIN GROUP ( ORDER BY avg_cost_for_two ) q1,
    PERCENTILE_CONT(0.75) WITHIN GROUP ( ORDER BY avg_cost_for_two ) q3
FROM gold.dim_location l
INNER JOIN gold.dim_restaurant r ON l.location_key = r.location_key
WHERE l.country_name = 'India' AND avg_cost_for_two > 0
GROUP BY price_range
)
SELECT
    restaurant_key,
    name,
    r.price_range,
    avg_cost_for_two,
    ct.q3 + (1.5 * (ct.q3 - ct.q1)) upper_fence
FROM gold.dim_restaurant r
INNER JOIN CTE_IQR1 ct ON ct.price_range = r.price_range
INNER JOIN gold.dim_location l ON l.location_key = r.location_key
WHERE r.avg_cost_for_two > ct.q3 + 1.5 * (ct.q3 - ct.q1) AND l.country_name = 'India'
ORDER BY (r.avg_cost_for_two - (ct.q3 + 1.5 * (ct.q3 - ct.q1))) DESC;

SELECT
    restaurant_id,
    restaurant_name
FROM staging.raw_zomato rz
WHERE NOT EXISTS(
    SELECT 1
    FROM silver.restaurants sr
    WHERE sr.restaurant_id = rz.restaurant_id
) OR NOT EXISTS(
    SELECT 1
    FROM gold.dim_restaurant gr
    WHERE gr.restaurant_id = rz.restaurant_id
);