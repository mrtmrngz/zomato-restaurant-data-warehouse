SELECT
    COUNT(*)
FROM gold.dim_restaurant r
LEFT JOIN gold.dim_location l ON l.location_key=r.location_key
WHERE l.location_key IS NULL;

SELECT
    COUNT(*)
FROM gold.dim_restaurant r
RIGHT JOIN gold.bridge_restaurant_cuisine brc ON brc.restaurant_key=r.restaurant_key
WHERE r.restaurant_key IS NULL;

SELECT
    COUNT(*)
FROM gold.dim_cuisine c
RIGHT JOIN gold.bridge_restaurant_cuisine brc ON brc.cuisine_key=c.cuisine_key
WHERE c.cuisine_key IS NULL;

SELECT
    COUNT(*)
FROM silver.restaurants sr
LEFT JOIN gold.dim_restaurant dr ON dr.restaurant_id=sr.restaurant_id
WHERE dr.restaurant_id IS NULL;

SELECT
    COUNT(*)
FROM silver.cuisines sc
LEFT JOIN gold.dim_cuisine dc ON dc.cuisine_name=sc.cuisine_name
WHERE dc.cuisine_name IS NULL;

SELECT
    count(*)
FROM silver.restaurants sr
INNER JOIN gold.dim_restaurant dr ON dr.restaurant_id = sr.restaurant_id
INNER JOIN silver.restaurant_cuisines rc ON rc.restaurant_id = sr.restaurant_id
INNER JOIN silver.cuisines sc ON rc.cuisine_id = sc.cuisine_id
INNER JOIN gold.dim_cuisine dc ON dc.cuisine_name = sc.cuisine_name
LEFT JOIN gold.bridge_restaurant_cuisine brc ON brc.cuisine_key = dc.cuisine_key AND brc.restaurant_key = dr.restaurant_key
WHERE brc.restaurant_key IS NULL;

SELECT
    restaurant_key,
    cuisine_key,
    COUNT(*) AS duplicate_relationships
FROM gold.bridge_restaurant_cuisine
GROUP BY restaurant_key, cuisine_key
HAVING COUNT(*) > 1;