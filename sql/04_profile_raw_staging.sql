-- first 10 row
SELECT
    *
FROM staging.raw_zomato
LIMIT 10;

-- check null counts
SELECT
    COUNT(*) AS total_rows,
    COUNT(restaurant_id) AS restaurant_id_filled,
    COUNT(country_code) AS country_code_filled,
    COUNT(city) AS city_filled,
    COUNT(address) AS address_filled,
    COUNT(locality) AS locality_filled,
    COUNT(locality_verbose) AS locality_verbose_filled,
    COUNT(long) AS long_filled,
    COUNT(lat) AS lat_filled,
    COUNT(cuisines) AS cuisines_filled,
    COUNT(avg_cost_for_two_currency) AS avg_cost_for_two_currency_filled,
    COUNT(has_table_booking) AS has_table_booking_filled,
    COUNT(has_online_delivery) AS has_online_delivery_filled,
    COUNT(is_delivering_now) AS is_delivering_now_filled,
    COUNT(switch_to_order_menu) AS switch_to_order_menu_filled,
    COUNT(price_range) AS price_range_filled,
    COUNT(agg_rating) AS agg_rating_filled,
    COUNT(rating_text) AS rating_text_filled,
    COUNT(votes) AS votes_filled
FROM staging.raw_zomato;

-- check duplicates
SELECT
    restaurant_id,
    COUNT(*) AS row_count
FROM staging.raw_zomato
GROUP BY restaurant_id
HAVING COUNT(*) > 1
ORDER BY row_count DESC;

-- check restaurant id unique

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT restaurant_id) AS distinct_restaurant
FROM staging.raw_zomato;

SELECT
    COUNT(*),
    COUNT(DISTINCT cuisines)
FROM staging.raw_zomato;

SELECT DISTINCT
    locality,
    locality_verbose
FROM staging.raw_zomato
ORDER BY locality
LIMIT 100;

SELECT
    locality,
    locality_verbose,
    COUNT(*) AS restaurant_count
FROM staging.raw_zomato
GROUP BY
    locality,
    locality_verbose
ORDER BY restaurant_count DESC;

SELECT
    locality,
    COUNT(DISTINCT locality_verbose) AS verbose_count
FROM staging.raw_zomato
GROUP BY locality
HAVING COUNT(DISTINCT locality_verbose) > 1
ORDER BY verbose_count DESC;

SELECT
    locality,
    locality_verbose
FROM staging.raw_zomato
WHERE locality = 'Civil Lines'
ORDER BY locality_verbose;

SELECT
    COUNT(DISTINCT locality_verbose) AS locality_verbose_count,
    COUNT(DISTINCT split_part(locality_verbose, ',', 2)) AS city_count
FROM staging.raw_zomato
WHERE locality = 'Civil Lines';

SELECT
    COUNT(*) AS total_rows,
    COUNT(*) FILTER (
        WHERE locality_verbose LIKE '%,%'
    ) AS comma_rows,
    COUNT(*) FILTER (
        WHERE locality_verbose NOT LIKE '%,%'
    ) AS no_comma_rows
FROM staging.raw_zomato;

SELECT
    restaurant_id,
    address,
    locality,
    locality_verbose
FROM staging.raw_zomato
WHERE locality_verbose NOT LIKE '%,%'
   OR locality_verbose IS NULL;
