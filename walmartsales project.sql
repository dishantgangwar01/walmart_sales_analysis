SELECT * FROM walmart;
-- DROP TABLE walmart

-- 
SELECT COUNT(*)
FROM walmart;

SELECT 
 	payment_method,
	COUNT(*)
FROM walmart
GROUP BY payment_method;


SELECT COUNT(DISTINCT branch)
FROM walmart;

SELECT MAX(quantity) FROM walmart;



-- Business Problems
--Q.1 Find different payment method and number of transactions, number of qty sold

SELECT 
	payment_method,
	COUNT(*) AS no_of_trans,
	SUM(quantity) AS no_of_qty	
FROM walmart
GROUP BY payment_method;


-- Project Question #2
-- Identify the highest-rated category in each branch, displaying the branch, category
-- AVG RATING
SELECT *
FROM(
		SELECT 
			branch,
			category,
			AVG(rating) AS avg_rating,
			RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
		FROM walmart
		GROUP BY 1,2
)
WHERE rank=1

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM (
	SELECT
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'),'Day') AS day_name,
	 	COUNT(*) AS no_of_trans,
		 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) as RANK
	FROM walmart
	GROUP BY 1,2
)
WHERE rank = 1;

-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	payment_method,
	SUM(quantity) AS total_quantity
FROM walmart
GROUP BY payment_method;

-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	city,
	category,
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating
FROM walmart
GROUP BY 1,2;


-- Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY 1;


-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH pay_method
AS
(
	SELECT 
		branch,
		payment_method,
		COUNT(*) AS total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
	FROM walmart
	GROUP BY 1,2
)
SELECT * 
FROM pay_method
WHERE rank = 1;

-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT 
	branch,
	CASE 
		WHEN EXTRACT (HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT (HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*) 
FROM walmart
GROUP BY 1,2
ORDER BY 1, 3 DESC;

-- 
-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100

SELECT *,
	EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formated_date
FROM walmart;

SELECT 
	branch,
	SUM(total) AS revenue
FROM walmart
GROUP BY 1;

-- 2022 sales
WITH revenue_2022
AS
(SELECT 
	branch,
	SUM(total) AS revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
GROUP BY 1
),
revenue_2023
AS
(SELECT 
	branch,
	SUM(total) AS revenue
FROM walmart
WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
GROUP BY 1
)
SELECT 
	ls.branch,
	ls.revenue AS last_yr_revenue,
	cs.revenue AS current_yr_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 AS ls
JOIN 
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
;

