INSERT INTO silver.restaurant_cuisines(cuisine_id, restaurant_id)
SELECT DISTINCT
    c.cuisine_id,
    rz.restaurant_id
FROM staging.raw_zomato rz,
     UNNEST(STRING_TO_ARRAY(rz.cuisines, ',')) AS cuisine
INNER JOIN silver.cuisines c ON c.cuisine_name = TRIM(cuisine)
ON CONFLICT (cuisine_id, restaurant_id) DO NOTHING;

SELECT COUNT(*) FROM silver.restaurant_cuisines;