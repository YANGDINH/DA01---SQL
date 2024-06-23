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

