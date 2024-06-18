--EX1
SELECT  
SUM(CASE
WHEN device_type='laptop' THEN 1
ELSE 0
END) AS laptop_views,
SUM(CASE
WHEN device_type IN ('tablet','phone') THEN 1
ELSE 0
END) AS moblie_views
FROM viewership
--EX2
SELECT 
*,
CASE
WHEN x+y>z AND y+z>x AND x+z>y THEN 'Yes'
ELSE 'No'
END triangle
FROM Triangle
--EX3
SELECT 
ROUND(SUM(CASE
WHEN call_category ='n/a' THEN 1
WHEN call_category IS NULL THEN 1
ELSE 0 END)*100.0/COUNT(*),1) AS uncategorised_call_pct
FROM callers;
--EX4: Bản ghi nào bị NULL thì thay thế = '' 
SELECT 
name 
FROM Customer
WHERE COALESCE(referee_id,'')!=2
--EX5
select 
survived,
SUM (CASE
WHEN pclass=1 THEN 1 ELSE 0
END) AS first_class,
SUM (CASE
WHEN pclass=2 THEN 1 ELSE 0
END) AS second_class,
SUM (CASE
WHEN pclass=3 THEN 1 ELSE 0
END) AS third_class
from titanic
group by survived
