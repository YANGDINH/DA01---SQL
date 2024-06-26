--EX1
SELECT 
CO.Continent,
FLOOR(AVG(CI.Population)) AS AvgCityPopulation
FROM CITY CI
JOIN COUNTRY CO
ON CI.CountryCode = CO.Code
GROUP BY CO.Continent;
--EX2
SELECT ROUND(sum(CASE 
				WHEN b.signup_action = 'Confirmed'
					THEN 1
				ELSE 0
				END)::DECIMAL / count(*), 2)
FROM emails AS a
INNER JOIN texts AS b ON a.email_id = b.email_id
--EX3
SELECT age_bucket,
	ROUND(100*sum(CASE 
			WHEN ac.activity_type = 'send'
				THEN ac.time_spent
			END) :: DECIMAL /sum(CASE 
			WHEN ac.activity_type in ('open','send')
				THEN ac.time_spent
			END),2) as send_perc
	, ROUND(100* sum(CASE 
			WHEN ac.activity_type = 'open'
				THEN ac.time_spent
			END) :: DECIMAL /sum(CASE 
			WHEN ac.activity_type in ('open','send')
				THEN ac.time_spent
			END),2) as open_perc
FROM activities AS ac
JOIN age_breakdown AS ab ON ac.user_id = ab.user_id
GROUP BY ab.age_bucket
--EX4
SELECT customer_id FROM customer_contracts as a 
inner join 
products as b on a.product_id = b.product_id
GROUP BY customer_id
having count(distinct b.product_category) = 3
--EX5
SELECT e.employee_id, e.name,
COUNT(r.employee_id) AS reports_count,
ROUND(AVG(r.age)) AS average_age
FROM Employees e
JOIN Employees r ON e.employee_id = r.reports_to
GROUP BY e.employee_id, e.name
ORDER BY e.employee_id;
--EX6
select a. product_name,sum(b.unit) as unit from  Products as a inner join Orders as b 
on a.product_id = b.product_id 
where b.order_date between '2020-02-01' and '2020-02-29'
 group by a.product_name
 having sum(b.unit)>=100
 order by sum(b.unit) desc
--EX7
SELECT p.page_id
FROM pages p
LEFT JOIN page_likes pl ON p.page_id = pl.page_id
WHERE pl.page_id IS NULL
ORDER BY p.page_id ASC;
