CREATE TABLE IF NOT EXISTS gold.dim_location(
    location_key INT GENERATED ALWAYS AS IDENTITY,
    country_code INT NOT NULL,
    country_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(255) NOT NULL,

    PRIMARY KEY (location_key),
    UNIQUE (country_code, city, locality)
);

CREATE TABLE IF NOT EXISTS gold.dim_cuisine(
    cuisine_key INT GENERATED ALWAYS AS IDENTITY,
    cuisine_name VARCHAR(150) NOT NULL,

    PRIMARY KEY (cuisine_key),
    UNIQUE (cuisine_name)
);

CREATE TABLE IF NOT EXISTS gold.dim_restaurant(
    restaurant_key INT GENERATED ALWAYS AS IDENTITY,
    restaurant_id INT NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    location_key INT NOT NULL,
    address VARCHAR(500),
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),
    avg_cost_for_two NUMERIC(10,2),
    currency_code VARCHAR(3),
    price_range  INTEGER,
    agg_rating   NUMERIC(2,1),
    votes        INTEGER,
    has_table_booking    BOOLEAN,
    has_online_delivery  BOOLEAN,
    is_delivering_now    BOOLEAN,
    switch_to_order_menu BOOLEAN,

    PRIMARY KEY (restaurant_key),
    FOREIGN KEY (location_key) REFERENCES gold.dim_location(location_key)
);

CREATE TABLE IF NOT EXISTS gold.bridge_restaurant_cuisine(
    cuisine_key INT NOT NULL,
    restaurant_key INT NOT NULL,

    PRIMARY KEY (cuisine_key, restaurant_key),

    FOREIGN KEY (cuisine_key) REFERENCES gold.dim_cuisine(cuisine_key),
    FOREIGN KEY (restaurant_key) REFERENCES gold.dim_restaurant(restaurant_key)
);