--EX1
SELECT 
CO.Continent,
FLOOR(AVG(CI.Population)) AS AvgCityPopulation
FROM CITY CI
JOIN COUNTRY CO
ON CI.CountryCode = CO.Code
GROUP BY CO.Continent;
--EX2
WITH confirmed_emails AS (SELECT DISTINCT email_id
FROM texts
WHERE signup_action = 'Confirmed')
SELECT 
ROUND((COUNT(DISTINCT confirmed_emails.email_id) * 1.0 / COUNT(DISTINCT emails.email_id)) * 100,2) AS confirm_rate
FROM emails
LEFT JOIN confirmed_emails
ON emails.email_id = confirmed_emails.email_id;
--EX3
WITH activity_totals AS (SELECT a.user_id,ab.age_bucket,
SUM(CASE WHEN a.activity_type = 'send' THEN a.time_spent ELSE 0 END) AS total_send_time,
SUM(CASE WHEN a.activity_type = 'open' THEN a.time_spent ELSE 0 END) AS total_open_time
FROM activities a
JOIN age_breakdown ab ON a.user_id = ab.user_id
GROUP BY a.user_id, ab.age_bucket),
age_group_totals AS (SELECT age_bucket,
SUM(total_send_time) AS total_send_time,
SUM(total_open_time) AS total_open_time
FROM activity_totals
GROUP BY age_bucket)
SELECT age_bucket,
ROUND((total_send_time / (total_send_time + total_open_time)) * 100.0, 2) AS send_perc,
ROUND((total_open_time / (total_send_time + total_open_time)) * 100.0, 2) AS open_perc
FROM age_group_totals;
--EX4
WITH distinct_categories AS (SELECT DISTINCT product_category FROM products),
customer_categories AS (SELECT cc.customer_id, p.product_category FROM customer_contracts cc
JOIN products p ON cc.product_id = p.product_id
GROUP BY cc.customer_id, p.product_category),
customer_category_count AS (SELECT customer_id,
COUNT(DISTINCT product_category) AS category_count
FROM customer_categories
GROUP BY customer_id)
SELECT customer_id
FROM customer_category_count
WHERE category_count = (SELECT COUNT(*) FROM distinct_categories);
--EX5
SELECT e.employee_id, e.name,
COUNT(r.employee_id) AS reports_count,
ROUND(AVG(r.age)) AS average_age
FROM Employees e
JOIN Employees r ON e.employee_id = r.reports_to
GROUP BY e.employee_id, e.name
ORDER BY e.employee_id;
--EX6
WITH feb_orders AS (SELECT product_id,
SUM(unit) AS total_units
FROM Orders
WHERE order_date BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY product_id
HAVING SUM(unit) >= 100)
SELECT p.product_name,f.total_units AS unit
FROM feb_orders f
JOIN Products p ON f.product_id = p.product_id;
--EX7
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes pl ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL
ORDER BY p.page_id ASC;
