create database projects;
use projects;
select * from `Zomato data simplified`;
desc `Zomato data simplified`;

-- 1)Total Restaurant count,total countries,cities,avg rating of all restaurants
SELECT
    COUNT(RestaurantName) AS `Total Restaurants`,
    COUNT(DISTINCT Countryname) AS `Total Countries`,
    COUNT(DISTINCT City) AS `Total Cities`,
    AVG(Rating) AS `Average Rating`
FROM `Zomato data simplified`;

-- 2) percentage of restaurants having table book delivery,online delivery

SELECT 
    COUNT(CASE WHEN Has_Table_booking = 'Yes' THEN 1 END) * 100 
    / COUNT(RestaurantName) AS Table_booking_percentage,
    COUNT(CASE WHEN Has_Online_delivery = 'Yes' THEN 1 END) * 100 
    / COUNT(RestaurantName) AS Online_delivery_percentage
FROM `Zomato data simplified`;

-- 3)Restaurant count yearwise,quarterwise,monthwise

CREATE OR REPLACE VIEW yearwise_count_rn AS
SELECT
    Year,
    COUNT(RestaurantName) AS year_count,
    ROW_NUMBER() OVER (ORDER BY Year) AS rn
FROM `Zomato data simplified`
GROUP BY Year;

CREATE OR REPLACE VIEW quarterwise_count_rn AS
SELECT
    Quarter,
    COUNT(RestaurantName) AS quarter_count,
    ROW_NUMBER() OVER (ORDER BY Quarter) AS rn
FROM `Zomato data simplified`
GROUP BY Quarter;

CREATE OR REPLACE VIEW monthwise_count_rn AS
SELECT
    `Month Name`,
    COUNT(RestaurantName) AS month_count,
    ROW_NUMBER() OVER (
        ORDER BY FIELD(
            `Month Name`,
            'January','February','March','April','May','June',
            'July','August','September','October','November','December'
        )
    ) AS rn
FROM `Zomato data simplified`
GROUP BY `Month Name`;

SELECT
    y.Year,
    y.year_count,
    q.Quarter,
    q.quarter_count,
    m.`Month Name`,
    m.month_count
FROM monthwise_count_rn m
LEFT JOIN yearwise_count_rn y
    ON m.rn = y.rn
LEFT JOIN quarterwise_count_rn q
    ON m.rn = q.rn
ORDER BY m.rn;

-- 4)restaurant count rating wise
SELECT 
    CASE
        WHEN Rating >= 1 AND Rating < 2 THEN '1–2'
        WHEN Rating >= 2 AND Rating < 3 THEN '2–3'
        WHEN Rating >= 3 AND Rating < 4 THEN '3–4'
        WHEN Rating >= 4 AND Rating < 5 THEN '4-5'
        ELSE 'Not Rated'
    END AS rating_range,
    COUNT(RestaurantName) AS restaurant_count
FROM `Zomato data simplified`
GROUP BY rating_range
ORDER BY rating_range;

-- 5)city and country count for restaurants together ---
CREATE OR REPLACE VIEW country_counts AS
SELECT
    Countryname,
    COUNT(RestaurantName) AS country_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(RestaurantName) DESC) AS rn
FROM `Zomato data simplified`
GROUP BY Countryname;

CREATE OR REPLACE VIEW city_counts AS
SELECT
    City,
    COUNT(RestaurantName) AS city_count,
    ROW_NUMBER() OVER (ORDER BY COUNT(RestaurantName) DESC) AS rn
FROM `Zomato data simplified`
GROUP BY City;

SELECT
    c.Countryname,
    c.country_count,
    ct.City,
    ct.city_count
FROM country_counts c
LEFT JOIN city_counts ct
    ON c.rn = ct.rn
ORDER BY c.rn;

-- 6) No of restaurants in bucket cost range

select `Bucket Cost Range`,count(RestaurantName) as `restaurant_count`
from `Zomato data simplified`
group by `Bucket Cost Range`
order by count(RestaurantName) desc;

-- 7) Average cost for 2 person in each country

CREATE OR REPLACE VIEW `average for 2` AS
SELECT
    Countryname,
    AVG(`USD Cost`) AS `avg cost for 2 in dollars`
FROM `Zomato data simplified`
GROUP BY `Countryname`
ORDER BY `Countryname` asc;

select * from `average for 2`
order by `avg cost for 2 in dollars` asc;
