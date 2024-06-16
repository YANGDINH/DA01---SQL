--EX1
SELECT Name
FROM STUDENTS
WHERE Marks>75
ORDER BY RIGHT(Name,3), ID 
--EX2
SELECT 
user_id, 
CONCAT(UPPER(LEFT(name,1)), LOWER(RIGHT(name,LENGTH(name)-1))) AS name
CONCAT(UPPER(LEFT(name,1)), LOWER(SUBSTRING(name,2)) AS name
FROM Users
ORDER BY user_id
/* substring('learn data with Julie',3,5) => 'arn d'
   substring('learn data with Julie',3) => lấy từ kí tự 3 trở về sau */
--EX3
SELECT 
manufacturer,
'$'||ROUND(SUM(total_sales)/1000000,0) || ' ' || 'million'
FROM pharmacy_sales
GROUP BY manufacturer
ORDER BY SUM(total_sales) DESC,manufacturer
--EX4
SELECT 
product_id,
EXTRACT(month FROM submit_date) AS mth,
ROUND(AVG(stars),2) AS avg_stars
FROM reviews
GROUP BY mth, product_id
ORDER BY mth, product_id
--EX5
SELECT 
sender_id,
COUNT(message_id) as message_count
FROM messages
WHERE EXTRACT(month FROM sent_date)=8
AND EXTRACT(year FROM sent_date)=2022
GROUP BY sender_id
ORDER BY message_count DESC
LIMIT 2
--EX6
SELECT tweet_id
FROM Tweets
WHERE length(content)>15
--EX7
select
activity_date as day,
count(distinct user_id) as active_users
from Activity
where activity_date between '2019-06-28' and '2019-07-27'
group by activity_date
--EX8
select 
count(id) as number_employee
from employees
where extract(month from joining_date) between 1 and 7
and extract(year from joining_date)=2022
--EX9
select 
first_name,
position('a' in first_name)
from worker
where first_name='Amitah'
--EX10
select substring(title, length(winery)+2,4)
from winemag_p2
where country='Macedonia'
