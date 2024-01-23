CREATE DATABASE IF NOT EXISTS salesDataWalmart;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(10) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6, 4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL, 
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL, 
    cogs DECIMAL(10, 2) NOT NULL,
    gross_margin_pct FLOAT(11, 9), 
    gross_income DECIMAL(12, 4) NOT NULL,
    rating FLOAT(2,1)
);

-- ------------------------------------------------------------------------
-- -----------------------Feature Engineering------------------------------

-- time_of_day
SELECT
	time,
    (CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END) AS time_of_day
FROM sales;

ALTER TABLE sales
DROP COLUMN time_of_day;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
UPDATE sales
SET time_of_day = 
(CASE 
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
        WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
    END);

-- day_name
SELECT 
	date, 
    DAYNAME(date) AS day_name
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(10);
UPDATE sales
SET day_name = (dayname(date));


-- month_name
SELECT 
	date, 
   MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);
UPDATE sales
SET month_name = monthname(date);

-- -----------------------------------------------
-- ----------------------generic------------------

-- How mant unique cities does the data have?
SELECT 
	DISTINCT city
from sales;

-- In which city each branch have?
SELECT 
	DISTINCT branch
from sales;

SELECT 
	DISTINCT city, 
    branch
FROM sales;


-- -------------------------------------------------------------
-- ------------------Product------------------------------------


-- How many unique product lines does the data have?

SELECT 
	COUNT(DISTINCT product_line)
FROM sales;

--  What is the most common payment method? / count each unique values

SELECT 
	payment_method,
	COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- What is the most selling product line?

SELECT 
	product_line,
    COUNT(product_line) AS product_line_count
FROM sales
GROUP BY product_line
ORDER BY product_line_count DESC;


-- What is total revenue by month?
SELECT 
	month_name AS month,
    SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;

-- What month had the largest COGS?
SELECT 
	month_name AS month,
    SUM(COGS) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs DESC;

-- What product line had the largest revenue?

SELECT 
	product_line AS product_line,
    SUM(total) AS total_revenue
FROM sales
GROUP BY product_line -- categories group by
ORDER BY total_revenue; -- values to sort


-- what is total revenue for each gender?
SELECT 
	gender,
    SUM(total) AS total_rev
FROM sales
GROUP BY gender;

-- How many orders for each gender?
SELECT 
	DISTINCT gender,
    COUNT(gender) AS gender_count
FROM sales
GROUP BY gender;

-- What is the city with largest revenue?
SELECT
	city,
    branch,
	SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;

-- What product line has the largest VAT? 

SELECT 
	product_line,
	AVG(VAT) AS avg_tax,
    MAX(VAT) as max_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;


-- Which branch sold more products than average product sold?
SELECT 
	branch,
    SUM(quantity) as qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);


-- What is the most product line by gender?
SELECT 
	gender,
    product_line,
    COUNT(gender) AS total_cnt
FROM sales
GROUP BY gender, product_line
ORDER BY total_cnt DESC;

-- What is the most product line by gender?
SELECT 
	product_line,
	ROUND(AVG(rating),2) AS avg_rating
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- ---------------------------------------------------------------------------
-- ------------------------------------Sales----------------------------------

-- Number of sales made in each time of the day per weekday
SELECT
	time_of_day,
    day_name,
    COUNT(*) AS total_sales
FROM sales
WHERE day_name = "Sunday"
GROUP BY time_of_day
ORDER BY total_sales;

-- Find rows from specifiC range
SELECT
	*
FROM sales
WHERE (date >= "2019-01-11 00:00:00" AND date <"2019-01-23 00:00:00" )
ORDER BY date ASC;

-- Which of the customers types brings most revenue?
SELECT 
	customer_type,
    SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/VAT(Value Added Tax)?
SELECT 
	city,
    AVG(vat) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT;

-- Which customer pays the most in VAT?
SELECT
	customer_type,
    AVG(vat) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- ----------------------------------------------------------------------------------
-- -----------------------------------------Customer---------------------------------

-- How many unique customer types does the data have?

SELECT
	customer_type,
    COUNT(customer_type) as Count
from sales
GROUP BY customer_type;


-- How many unique payment methods does the data have?
SELECT
	 DISTINCT payment_method
FROM sales;

-- Which customer type buys the most?
SELECT 
	customer_type,
    COUNT(customer_type) as ctm_count
FROM sales
GROUP BY customer_type;

-- What is the gender is the most?
SELECT 
	gender,
    COUNT(gender) as cnt
FROM sales
GROUP BY gender
ORDER BY cnt DESC;

-- What is gender distribution for each specific branch?
SELECT 
	gender,
    branch,
    COUNT(gender) as cnt
FROM sales
WHERE branch = "A" 
GROUP BY gender
ORDER BY cnt DESC;

-- Which time of the day do customers give most rating?
SELECT
	time_of_day,
    AVG(rating) AS avg_rating
FROM sales
-- WHERE payment_method = "cash"
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day of the week has the best avg ratings?
SELECT 
    day_name,
    AVG(rating) AS avg_rating
FROM sales
WHERE branch = "C"
GROUP BY day_name
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?



	