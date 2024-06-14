/* 

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
