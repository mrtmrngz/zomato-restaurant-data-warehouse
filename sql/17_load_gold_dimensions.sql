INSERT INTO gold.dim_location(country_code, country_name, city, locality)
SELECT
    l.country_code AS country_code,
    c.country_name AS country_name,
    l.city AS city,
    l.locality AS locality
FROM silver.locations l
INNER JOIN silver.countries c ON c.country_code = l.country_code
ON CONFLICT (country_code, city, locality) DO NOTHING;

INSERT INTO gold.dim_cuisine(cuisine_name)
SELECT
    cuisine_name
FROM silver.cuisines
ON CONFLICT (cuisine_name) DO NOTHING;

INSERT INTO gold.dim_restaurant(restaurant_id, name, location_key, address, latitude, longitude, avg_cost_for_two, currency_code, price_range, agg_rating, votes, has_table_booking, has_online_delivery, is_delivering_now, switch_to_order_menu)
SELECT
    r.restaurant_id,
    r.name,
    dl.location_key,
    r.address,
    r.latitude,
    r.longitude,
    r.avg_cost_for_two,
    r.currency_code,
    r.price_range,
    r.agg_rating,
    r.votes,
    r.has_table_booking,
    r.has_online_delivery,
    r.is_delivering_now,
    r.switch_to_order_menu
FROM silver.restaurants r
INNER JOIN silver.locations sl ON sl.location_id = r.location_id
INNER JOIN gold.dim_location dl ON dl.country_code = sl.country_code AND
                                   dl.city = sl.city AND dl.locality = sl.locality;

INSERT INTO gold.bridge_restaurant_cuisine(cuisine_key, restaurant_key)
SELECT
    dc.cuisine_key AS cuisine_key,
    r.restaurant_key AS restaurant_key
FROM gold.dim_restaurant r
INNER JOIN silver.restaurant_cuisines rc
    ON rc.restaurant_id = r.restaurant_id
INNER JOIN silver.cuisines sc
    ON sc.cuisine_id = rc.cuisine_id
INNER JOIN gold.dim_cuisine dc
    ON dc.cuisine_name = sc.cuisine_name
ON CONFLICT (cuisine_key, restaurant_key) DO NOTHING;

select count(*) from gold.bridge_restaurant_cuisine;