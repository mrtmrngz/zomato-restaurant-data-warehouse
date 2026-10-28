CREATE TABLE IF NOT EXISTS silver.currency_mapping(
    source_currency VARCHAR(25),
    currency_code VARCHAR(3),

    PRIMARY KEY (source_currency)
);

CREATE TABLE IF NOT EXISTS silver.locations(
    location_id INTEGER GENERATED ALWAYS AS IDENTITY,
    country_code INTEGER NOT NULL,
    city VARCHAR(100) NOT NULL,
    locality VARCHAR(255) NOT NULL,

    PRIMARY KEY (location_id),
    UNIQUE (country_code, city, locality)
);

CREATE TABLE IF NOT EXISTS silver.restaurants(
    restaurant_id INTEGER PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    location_id INT NOT NULL,

    address VARCHAR(500),
    latitude NUMERIC(10,7),
    longitude NUMERIC(10,7),

    avg_cost_for_two NUMERIC(10,2),
    currency_code VARCHAR(3),

    price_range  INTEGER,
    agg_rating   NUMERIC(2,1),
    rating_color VARCHAR(20),
    rating_text  VARCHAR(20),
    votes        INTEGER,

    has_table_booking    BOOLEAN,
    has_online_delivery  BOOLEAN,
    is_delivering_now    BOOLEAN,
    switch_to_order_menu BOOLEAN,

    FOREIGN KEY (location_id) REFERENCES silver.locations(location_id)
);

CREATE TABLE IF NOT EXISTS silver.cuisines(
    cuisine_id INTEGER GENERATED ALWAYS AS IDENTITY,
    cuisine_name VARCHAR(150) NOT NULL,

    PRIMARY KEY (cuisine_id),
    UNIQUE (cuisine_name)
);

CREATE TABLE IF NOT EXISTS silver.restaurant_cuisines(
    cuisine_id INTEGER NOT NULL,
    restaurant_id INTEGER NOT NULL,

    PRIMARY KEY (cuisine_id, restaurant_id),

    FOREIGN KEY (cuisine_id) REFERENCES silver.cuisines(cuisine_id),
    FOREIGN KEY (restaurant_id) REFERENCES silver.restaurants(restaurant_id)
);
