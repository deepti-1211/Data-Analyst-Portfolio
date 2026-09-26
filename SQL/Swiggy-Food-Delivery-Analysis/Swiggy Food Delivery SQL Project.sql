CREATE DATABASE swiggy_project;

USE swiggy_project;

SHOW TABLES;

SELECT * FROM swiggy;

SELECT * FROM swiggy
LIMIT 10;

SELECT COUNT(*) AS total_records
FROM swiggy;

DESC swiggy;

##data cleaning
##check null

SELECT 
SUM(ID IS NULL) AS null_id,
SUM(AREA IS NULL) AS null_area,
SUM(CITY IS NULL) AS null_city,
SUM(RESTAURANT IS NULL) AS null_restaurant,
SUM(PRICE IS NULL) AS null_price,
SUM(`AVG RATINGS` IS NULL) AS null_avg_ratings,
SUM(`TOTAL RATINGS` IS NULL) AS null_total_ratings,
SUM(`FOOD TYPE` IS NULL) AS null_food_type,
SUM(ADDRESS IS NULL) AS null_address,
SUM(`DELIVERY TIME` IS NULL) AS null_delivery_time
FROM swiggy;

##check duplicate
SELECT 
     ID,
     area,
     city,
     restaurant,
     price,
     `avg ratings`,
     `total ratings`,
     `food type`,
     address,
     `delivery time`,
     COUNT(*) AS duplicate_count
  FROM swiggy
  GROUP BY
	 ID,
	 area,
     city,
     restaurant,
     price,
     `avg ratings`,
     `total ratings`,
     `food type`,
     address,
     `delivery time`
   HAVING COUNT(*)>1; 
   
##Check invalid values

SELECT
     SUM(ID <= 0) AS invalid_id,
     SUM(PRICE <= 0) AS invalid_price,
     SUM(`AVG RATINGS` < 0 OR `AVG RATINGS` >5) AS invalid_avg_ratings,
     SUM(`TOTAL RATINGS` < 0) AS invalid_total_ratings,
     SUM(`DELIVERY TIME` <= 0) AS invalid_delivery_time
 FROM swiggy;
 
SELECT ID,restaurant,city,price
FROM swiggy
WHERE price <= 0;

SET SQL_SAFE_UPDATES = 0;

UPDATE swiggy
SET PRICE = null
WHERE price = 0;

SELECT * FROM swiggy    
WHERE PRICE IS NULL;

##data consistency

-- 1. Rating vs Total Ratings consistency
SELECT *
FROM swiggy
WHERE (`Avg ratings` IS NULL AND `Total ratings` > 0)
   OR (`Avg ratings` > 0 AND `Total ratings` = 0);

-- 2. Price consistency
SELECT *
FROM swiggy
WHERE Price < 0;

-- 3. Average Rating consistency
SELECT *
FROM swiggy
WHERE `Avg ratings` < 0
   OR `Avg ratings` > 5;

-- 4. Total Ratings consistency
SELECT *
FROM swiggy
WHERE `Total ratings` < 0;

-- 5. Delivery Time consistency
SELECT *
FROM swiggy
WHERE `Delivery time` <= 0;

-- 6. ID consistency
SELECT *
FROM swiggy
WHERE ID <= 0;

##check extra spaces

SELECT
    SUM(City <> TRIM(City)) AS city_spaces,
    SUM(Area <> TRIM(Area)) AS area_spaces,
    SUM(Restaurant <> TRIM(Restaurant)) AS restaurant_spaces,
    SUM(`Food type` <> TRIM(`Food type`)) AS food_type_spaces,
    SUM(Address <> TRIM(Address)) AS address_spaces
FROM swiggy;

##EDA(EXPLORATORY DATA ANALYSIS)

-- Q1 : which 5 cities have the highest number of restaurants?
		SELECT 
			city,
			COUNT(*) AS restaurant_count
        FROM swiggy
        GROUP BY City
        ORDER BY restaurant_count DESC
        LIMIT 5;
        
 -- Q2 : find the to 10 restaurants with the highest average rating
	   SELECT
             Restaurant,
             city,
             `avg ratings`
       FROM swiggy
       WHERE `avg ratings` is NOT NULL
       ORDER BY `avg ratings` DESC
       LIMIT 10;
       
  -- Q3 : find restaurant whose average rating is higher than the overall average rating
		SELECT
			Restaurant,
			City,
			`Avg ratings`
		FROM swiggy
		WHERE `Avg ratings` >
						(SELECT AVG(`Avg ratings`)
                        FROM swiggy)
                        ORDER BY `Avg ratings` DESC;
	
    -- Q4 : find the highest-rated restaurant in each city.
		        SELECT
					City,
					Restaurant,
					`Avg ratings`
					FROM (
						SELECT
						City,
						Restaurant,
						`Avg ratings`,
						RANK() OVER (
						PARTITION BY City
						ORDER BY `Avg ratings` DESC
						) AS rating_rank
								FROM swiggy
								) AS ranked_restaurants
						WHERE rating_rank = 1;

	-- Q5 : Find the 10 cities with the fastest average delivery time.
					SELECT
						City,
						ROUND(AVG(`Delivery time`), 2) AS average_delivery_time
						FROM swiggy
						GROUP BY City
						ORDER BY average_delivery_time ASC
						LIMIT 10;

	-- Q6 : Which 10 areas have the highest number of restaurants?
					SELECT
						Area,
						COUNT(*) AS restaurant_count
						FROM swiggy
						WHERE Area IS NOT NULL
						GROUP BY Area
						ORDER BY restaurant_count DESC
						LIMIT 10;

	-- Q7: Find cities where average delivery time is above the overall average delivery time.
					SELECT
						City,
						ROUND(AVG(`Delivery time`), 2) AS average_delivery_time
						FROM swiggy
						GROUP BY City
						HAVING AVG(`Delivery time`) > (
									SELECT AVG(`Delivery time`)
						FROM swiggy
									)
						ORDER BY average_delivery_time DESC;

	-- Q8: What are the top 10 most common food types?
					SELECT
						`Food type`,
						COUNT(*) AS restaurant_count
						FROM swiggy
						WHERE `Food type` IS NOT NULL
						GROUP BY `Food type`
						ORDER BY restaurant_count DESC
						LIMIT 10;






      