-- Fiyat aralığı dağılımı: Restoranların yüzde kaçı price_range 1, 2, 3 ve 4 kategorilerinde?
SELECT
    price_range,
    COUNT(*) price_range_count,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER()::numeric * 100, 2) || '%' price_range_percent
FROM gold.dim_restaurant
GROUP BY price_range
ORDER BY price_range;

-- Fiyat ve puan ilişkisi: Pahalı restoranlar gerçekten daha yüksek puan mı alıyor?

SELECT
    price_range,
    AVG(agg_rating) FILTER ( WHERE agg_rating > 0 ) avg_rating,
    COUNT(*) FILTER ( WHERE agg_rating > 0 ) rated_restaurant_count,
    COUNT(*) total_restaurant_count
FROM gold.dim_restaurant
GROUP BY price_range;

-- Online teslimat analizi: Online sipariş sunan ve sunmayan restoranların puanları, oy sayıları ve fiyat aralıkları nasıl değişiyor?

SELECT
    has_online_delivery,
    COUNT(*) AS restaurant_count,
    ROUND(AVG(agg_rating) FILTER (WHERE agg_rating > 0), 2) AS avg_rating,
    ROUND(AVG(votes), 2) AS avg_votes,
    SUM(votes) AS total_votes,
    ROUND(AVG(price_range), 2) AS avg_price_range
FROM gold.dim_restaurant
GROUP BY has_online_delivery;

-- Masa rezervasyonu analizi: Rezervasyon kabul eden restoranlarla etmeyenler arasında fiyat ve puan farkı var mı?

WITH CTE_Online_Booking_Analysis AS
(
    SELECT
    has_table_booking,
    AVG(price_range) avg_price_range,
    AVG(agg_rating) FILTER ( WHERE agg_rating > 0 ) avg_rating
FROM gold.dim_restaurant
GROUP BY has_table_booking
)
SELECT
    CASE
        WHEN has_table_booking IS TRUE THEN 'Yes'
        ELSE 'No'
    END AS table_booking_status,
    ROUND(avg_price_range, 2) avg_price_range,
    ROUND(avg_rating, 2) avg_rating
FROM CTE_Online_Booking_Analysis;

-- Ülkelere göre hizmet erişilebilirliği: Hangi ülkelerde online sipariş ve masa rezervasyonu daha yaygın?

SELECT
   country_name,
   online_delivery_accepted_count,
   online_delivery_not_accepted_count,
   ROUND(online_delivery_accepted_count / restaurant_count::numeric * 100, 2) online_delivery_percent,
   online_booking_accepted_count,
   online_booking_not_accepted_count,
   ROUND(online_booking_accepted_count / restaurant_count::numeric * 100, 2) online_booking_percent
FROM (
    SELECT
    l.country_name,
    COUNT(r.has_online_delivery) FILTER ( WHERE has_online_delivery IS TRUE ) AS online_delivery_accepted_count,
    COUNT(r.has_online_delivery) FILTER ( WHERE has_online_delivery IS FALSE ) AS online_delivery_not_accepted_count,
    COUNT(r.has_table_booking) FILTER ( WHERE has_table_booking IS TRUE ) AS online_booking_accepted_count,
    COUNT(r.has_table_booking) FILTER ( WHERE has_table_booking IS FALSE ) AS online_booking_not_accepted_count,
    COUNT(*) restaurant_count
FROM gold.dim_restaurant r
INNER JOIN gold.dim_location l ON r.location_key = l.location_key
GROUP BY l.country_name
)t;

-- Fiyat–hizmet kombinasyonları: Hem online sipariş hem masa rezervasyonu sunan restoranlar hangi fiyat kategorilerinde yoğunlaşıyor?

SELECT
    price_range,
    COUNT(*) price_range_count,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER()::numeric * 100, 2) percentege_of_online_delivery_and_table_booking
FROM gold.dim_restaurant
WHERE has_online_delivery IS TRUE AND has_table_booking IS TRUE
GROUP BY price_range
ORDER BY percentege_of_online_delivery_and_table_booking DESC;