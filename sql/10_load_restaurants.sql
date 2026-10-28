INSERT INTO silver.restaurants(restaurant_id, name, location_id, address, latitude, longitude, avg_cost_for_two, currency_code, price_range, agg_rating, rating_color, rating_text, votes, has_table_booking, has_online_delivery, is_delivering_now, switch_to_order_menu)
SELECT
    rz.restaurant_id AS restaurant_id,
    rz.restaurant_name AS name,
    l.location_id AS location_id,
    rz.address AS address,
    NULLIF(TRIM(rz.lat), '')::NUMERIC(10,7) AS latitude,
    NULLIF(TRIM(rz.long), '')::NUMERIC(10,7) AS longitude,
    rz.avg_cost_for_two_currency AS avg_cost_for_two,
    cm.currency_code AS currency_code,
    rz.price_range AS price_range,
    rz.agg_rating AS agg_rating,
    rz.rating_color AS rating_color,
    rz.rating_text AS rating_text,
    rz.votes AS votes,
    CASE
        WHEN rz.has_table_booking = 'Yes' THEN TRUE
        WHEN rz.has_table_booking = 'No' THEN FALSE
        ELSE NULL
    END AS has_table_booking,
    CASE
        WHEN rz.has_online_delivery = 'Yes' THEN TRUE
        WHEN rz.has_online_delivery = 'No' THEN FALSE
        ELSE NULL
    END AS has_online_delivery,
    CASE
        WHEN rz.is_delivering_now = 'Yes' THEN TRUE
        WHEN rz.is_delivering_now = 'No' THEN FALSE
        ELSE NULL
    END AS is_delivering_now,
    CASE
        WHEN rz.switch_to_order_menu = 'Yes' THEN TRUE
        WHEN rz.switch_to_order_menu = 'No' THEN FALSE
        ELSE NULL
    END AS switch_to_order_menu
FROM staging.raw_zomato rz
LEFT JOIN silver.locations l ON l.country_code = rz.country_code
                                     AND l.locality = rz.locality
                                     AND l.city = rz.city
LEFT JOIN silver.currency_mapping cm ON cm.source_currency = rz.currency
LEFT JOIN silver.restaurants sr ON sr.restaurant_id = rz.restaurant_id
WHERE sr.restaurant_id IS NULL;


SELECT * FROM silver.restaurants LIMIT 10;
