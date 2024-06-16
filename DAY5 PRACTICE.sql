/* Bước 1: Phân tích yêu cầu
1. output (gốc/phái sinh): candidate_id
2. input
3. điều kiện lọc theo trường nào (gốc hay phái sinh) */

--EX1
SELECT DISTINCT CITY FROM STATION
WHERE ID%2=0
--EX2
SELECT 
(SELECT COUNT(CITY) FROM STATION ) -
(SELECT COUNT(DISTINCT CITY) FROM STATION) AS difference
--EX4
SELECT 
ROUND(CAST(SUM(item_count * order_occurrences)/SUM(order_occurrences) AS
DECIMAL),1) as mean
FROM items_per_order
--EX5
SELECT candidate_id
FROM candidates
WHERE skill IN ('Python', 'Tableau', 'PostgreSQL')
GROUP BY candidate_id
HAVING count(skill)=3
--EX6
SELECT user_id
DATE(MAX(post_date))-DATE(MIN(post_date)) AS days_between
FROM posts
WHERE post_date>='2021-01-01' AND post_date<'2022-01-01'
group by user_id
having count(post_id)>=2
--EX7
SELECT card_name
MAX(issued_amount) - MIN(issued_amount) AS difference
FROM monthly_cards_issued
GROUP BY card_name
ORDER BY difference DESC
--EX8
SELECT manufacturer
COUNT(drug) AS drug_count,
ABS(SUM(cogs-total_sales)) AS total_loss
FROM pharmacy_Sales
WHERE total_sales<cogs
GROUP BY manufacturer
ORDER BY total_loss DESC
--EX9
SELECT * FROM Cinema
WHERE id%2=1 AND description<>'boring'
ORDER BY rating DESC
--EX10
SELECT teacher_id
COUNT(DISTINCT subject_id) AS cnt
FROM Teacher
GROUP BY teacher_id
--EX11
SELECT user_id, COUNT(follower_id) AS followers_count
FROM Followers
GROUP BY user_id
ORDER BY user_id
--EX12
SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(student)>=5
