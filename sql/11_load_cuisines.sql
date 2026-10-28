INSERT INTO silver.cuisines(cuisine_name)
SELECT
    DISTINCT TRIM(cuisine)
FROM staging.raw_zomato,
     UNNEST(STRING_TO_ARRAY(cuisines, ',')) AS cuisine
ON CONFLICT (cuisine_name) DO NOTHING ;

SELECT count(*) FROM silver.cuisines;