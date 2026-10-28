SELECT
    COUNT(*) AS orphan_restaurants
FROM silver.restaurants r
LEFT JOIN silver.locations l ON l.location_id=r.location_id
WHERE l.location_id IS NULL;

SELECT
    COUNT(*) AS restaurants_without_cuisine
FROM silver.restaurants r
LEFT JOIN silver.restaurant_cuisines rc ON rc.restaurant_id = r.restaurant_id
WHERE rc.restaurant_id IS NULL;

SELECT
    COUNT(*) AS orphan_cuisine_relations
FROM silver.restaurant_cuisines rc
LEFT JOIN silver.cuisines c ON c.cuisine_id = rc.cuisine_id
WHERE c.cuisine_id IS NULL;

SELECT
    COUNT(*) AS orphan_cuisine_relations
FROM silver.restaurant_cuisines rc
LEFT JOIN silver.restaurants r ON r.restaurant_id = rc.restaurant_id
WHERE r.restaurant_id IS NULL;

SELECT
    COUNT(*) FILTER ( WHERE (
        (agg_rating NOT BETWEEN 0 AND 5) OR
        (price_range NOT BETWEEN 1 AND 4) OR
        (votes < 0) OR
        (latitude NOT BETWEEN -90 AND 90) OR
        (longitude NOT BETWEEN -180 AND 180)
        ))
FROM silver.restaurants;

SELECT
    COUNT(*) FILTER ( WHERE
            (restaurant_id IS NULL) OR
            (name IS NULL) OR
            (location_id IS NULL) OR
            (currency_code IS NULL) OR
            (price_range IS NULL) OR
            (agg_rating IS NULL) OR
            (votes IS NULL) OR
            (latitude IS NULL) OR
            (longitude IS NULL)
        )
FROM silver.restaurants;