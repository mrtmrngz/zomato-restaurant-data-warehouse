SELECT
    country_code,
    COUNT(*) AS restaurant_count
FROM staging.raw_zomato
GROUP BY country_code
ORDER BY restaurant_count DESC;

SELECT
    locality,
    locality_verbose
FROM staging.raw_zomato
WHERE locality_verbose IS NOT NULL
  AND (
      LENGTH(locality_verbose)
      - LENGTH(REPLACE(locality_verbose, ',', ''))
  ) > 1
ORDER BY locality_verbose;

SELECT
    restaurant_id,
    locality,
    locality_verbose
FROM staging.raw_zomato
WHERE locality_verbose IS NOT NULL
  AND locality IS NOT NULL
  AND NOT (
      TRIM(locality_verbose) LIKE TRIM(locality) || '%'
  );

SELECT DISTINCT
    country_code,
    locality,
    locality_verbose
FROM staging.raw_zomato
WHERE locality_verbose = locality
ORDER BY country_code, locality;

SELECT
    length(TRIM(locality)) AS LEN
FROM staging.raw_zomato
ORDER BY LEN desc
LIMIT 1;