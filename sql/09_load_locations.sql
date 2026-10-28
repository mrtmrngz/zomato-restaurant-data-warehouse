INSERT INTO silver.locations(country_code, city, locality)
SELECT DISTINCT
    country_code,
    city,
    locality
FROM staging.raw_zomato
ON CONFLICT DO NOTHING;

SELECT COUNT(*) FROM silver.locations;