CREATE TABLE IF NOT EXISTS silver.countries(
    country_code INT NOT NULL UNIQUE,
    country_name VARCHAR(150) NOT NULL UNIQUE,

    PRIMARY KEY(country_code),
    UNIQUE(country_code, country_name)
);

INSERT INTO silver.countries(country_code, country_name)
VALUES (1, 'India'),
       (14, 'Australia'),
       (30, 'Brazil'),
       (37, 'Canada'),
       (94, 'Indonesia'),
       (148, 'New Zealand'),
       (162, 'Philippines'),
       (166, 'Qatar'),
       (184, 'Singapore'),
       (189, 'South Africa'),
       (191, 'Sri Lanka'),
       (208, 'Turkey'),
       (214, 'United Arab Emirates'),
       (215, 'United Kingdom'),
       (216 , 'United States');

SELECT * FROM silver.countries;