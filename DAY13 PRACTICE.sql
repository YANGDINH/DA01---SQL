--EX1
SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM (SELECT company_id, title, description
FROM job_listings
GROUP BY company_id, title, description
HAVING COUNT(*)>1) AS duplicate_jobs
--EX2 Cầu cứu đáp án
--EX3
SELECT COUNT(DISTINCT policy_holder_id) AS policy_holder_count
FROM 
(SELECT policy_holder_id, 
COUNT(case_id) AS call_count
FROM callers
GROUP BY policy_holder_id
HAVING COUNT(case_id)>=3) AS frequent_callers;
--EX4
SELECT a.page_id
FROM pages AS a
LEFT JOIN page_likes AS b
ON a.page_id=b.page_id
WHERE b.page_id IS NULL
ORDER BY a.page_id 
--EX5
WITH June_Actions AS 
(SELECT DISTINCT user_id
FROM user_actions 
WHERE event_date BETWEEN '2022-06-01' AND '2022-07-01'),
July_Actions 
AS 
(SELECT DISTINCT user_id
FROM user_actions
WHERE event_date BETWEEN '2022-07-01' AND '2022-08-01')
SELECT 
July AS month, 
COUNT(DISTINCT b.user_id) AS monthly_active_users
FROM July_Actions AS b
JOIN June_Actions AS a ON b.user_id = a.user_id;
--EX6
WITH tr_by_month_country
AS (
SELECT 
DATE_FORMAT(trans_date, '%Y-%M') AS month,
country,
COUNT(id) AS trans_count,
SUM(amount) AS trans_total_amount
FROM Transactions
GROUP BY DATE_FORMAT(trans_date, '%Y-%M'), country),
aprproved_tr_by_month_country
AS (
SELECT 
DATE_FORMAT(trans_date, '%Y-%M') AS month,
country,
COUNT(id) AS approved_count,
SUM(amount) AS approved_total_amount
WHERE state='approved'
GROUP BY DATE_FORMAT(trans_date, '%Y-%M'), country)
SELECT a.country, a.month, a.trans_count, a.trans_total_amount, b.approved_count, b.approved_total_amount
FROM tr_by_month_country AS a
LEFT JOIN aprproved_tr_by_month_country AS b
ON a.country=b.country AND a.month=b.month
ORDER BY a.month, a.country
--EX7
SELECT 
a.product_id, 
a.year AS first_year, 
a.quantity, 
a.price
FROM Sales AS a
JOIN 
(SELECT product_id, MIN(year) AS first_year
FROM Sales
GROUP BY product_id) AS b
ON a.product_id = b.product_id AND a.year = b.first_year;
--EX8
WITH product_count 
AS (
SELECT 
COUNT(*) AS total_products
FROM Product),
customer_product_count AS (
SELECT customer_id, 
COUNT(DISTINCT product_key) AS product_count
FROM Customer
GROUP BY customer_id)
SELECT a.customer_id, b.product_count
FROM customer_product_count AS a
JOIN product_count AS b
ON b.product_count = a.total_products;
--EX9
SELECT a.employee_id
FROM Employees AS a
LEFT JOIN Employees AS b ON a.manager_id = b.employee_id
WHERE a.salary < 30000 
AND a.manager_id IS NOT NULL 
AND b.employee_id IS NULL
ORDER BY a.employee_id;
--EX10
SELECT COUNT(DISTINCT company_id) AS duplicate_companies
FROM (SELECT company_id, title, description
FROM job_listings
GROUP BY company_id, title, description
HAVING COUNT(*)>1) AS duplicate_jobs
--EX11
WITH TopUser 
AS (
SELECT a.name
FROM Users AS a
JOIN MovieRating AS b ON a.user_id = b.user_id
GROUP BY a.user_id, a.name
ORDER BY COUNT(b.movie_id) DESC, a.name
LIMIT 1),
TopMovie AS (
SELECT c.title
FROM Movies AS c
JOIN MovieRating AS b ON c.movie_id = b.movie_id
WHERE b.created_at BETWEEN '2020-02-01' AND '2020-02-29'
GROUP BY c.movie_id, c.title
ORDER BY AVG(b.rating) DESC, c.title
LIMIT 1)
SELECT (SELECT name FROM TopUser) AS results
UNION ALL
SELECT (SELECT title FROM TopMovie) AS results;
--EX12
WITH FriendCount 
AS (
SELECT requester_id AS id
FROM RequestAccepted
UNION ALL
SELECT accepter_id AS id
FROM RequestAccepted), 
Friends 
AS (
SELECT id, 
COUNT(*) AS num
FROM FriendCount
GROUP BY id)
SELECT id, num
FROM Friends
ORDER BY num DESC
LIMIT 1;
