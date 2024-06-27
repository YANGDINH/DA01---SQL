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
WHEN b.signup_action = 'Confirmed'THEN 1 ELSE 0
END)::DECIMAL / count(*), 2)
FROM emails AS a
INNER JOIN texts AS b ON a.email_id = b.email_id
--EX3
SELECT age_bucket,
ROUND(100*sum(CASE 
WHEN ac.activity_type = 'send' THEN ac.time_spent
END) :: DECIMAL /sum(CASE 
WHEN ac.activity_type in ('open','send')THEN ac.time_spent
END),2) as send_perc, ROUND(100* sum(CASE 
WHEN ac.activity_type = 'open'THEN ac.time_spent
END) :: DECIMAL /sum(CASE 
WHEN ac.activity_type in ('open','send')THEN ac.time_spent
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

--MID_COURSE_TEST
--EX1
/* Tạo danh sách tất cả chi phí thay thế (replacement cost) khác nhau của các film. 
Chi phí thay thế thấp nhất là bao nhiêu? */

SELECT MIN(DISTINCT replacement_cost) FROM film
--EX2
/* Viết một truy vấn cung cấp cái nhìn tổng quan về số lượng phim 
có chi phí thay thế trong các phạm vi chi phí sau
1.	low: 9.99 - 19.99
2.	medium: 20.00 - 24.99
3.	high: 25.00 - 29.99
Question: Có bao nhiêu phim có chi phí thay thế thuộc nhóm “low”? */

SELECT 
CASE
WHEN replacement_cost BETWEEN 9.99 AND 19.99 THEN 'low' ELSE NULL
END AS category,
COUNT (*) AS SO_LUONG
FROM film
GROUP BY category
--EX3
/* Tạo danh sách các film_title bao gồm tiêu đề (title), độ dài (length) 
và tên danh mục (category_name) được sắp xếp theo độ dài giảm dần. 
Lọc kết quả để chỉ các phim trong danh mục 'Drama' hoặc 'Sports'.
Question: Phim dài nhất thuộc thể loại nào và dài bao nhiêu? *? */

SELECT a.film_id, a.title, a.length, c.name AS category_name
FROM film AS a
JOIN film_category AS b ON a.film_id=b.film_id
JOIN category AS c ON b.category_id=c.category_id
WHERE c.name IN ('Drama','Sports')
ORDER BY a.length DESC
LIMIT 1;
--EX4
/* Topic: JOIN & GROUP BY
Task: Đưa ra cái nhìn tổng quan về số lượng phim (tilte) trong mỗi danh mục (category).
Question:Thể loại danh mục nào là phổ biến nhất trong số các bộ phim? */

SELECT c.name AS category_name,
COUNT(a.film_id) AS so_luong
FROM film AS a
JOIN film_category AS b ON a.film_id=b.film_id
JOIN category AS c ON b.category_id=c.category_id
GROUP BY c.name
ORDER BY so_luong DESC
LIMIT 1
--EX5
/* Topic: JOIN & GROUP BY
Task:Đưa ra cái nhìn tổng quan về họ và tên của các diễn viên 
cũng như số lượng phim họ tham gia.
Question: Diễn viên nào đóng nhiều phim nhất? */

SELECT a.first_name, a.last_name,
COUNT (*) AS so_luong
FROM actor AS a
JOIN film_actor AS b ON a.actor_id=b.actor_id
JOIN film AS c ON b.film_id=c.film_id
GROUP BY a.first_name, a.last_name
ORDER BY so_luong DESC
LIMIT 1
--EX6
/* Topic: LEFT JOIN & FILTERING
Task: Tìm các địa chỉ không liên quan đến bất kỳ khách hàng nào.
Question: Có bao nhiêu địa chỉ như vậy? */

SELECT  
COUNT(a.address_id) AS so_luong
FROM address AS a
LEFT JOIN customer AS b ON a.address_id=b.address_id
WHERE b.customer_id is NULL 
--EX7
/* Topic: JOIN & GROUP BY
Task: Danh sách các thành phố và doanh thu tương ừng trên từng thành phố 
Question:Thành phố nào đạt doanh thu cao nhất? */

SELECT a.city,
SUM (d.amount) AS total_venue
FROM city AS a
JOIN address AS b ON a.city_id=b.city_id
JOIN customer AS c ON b.address_id=c.address_id
JOIN payment AS d ON c.customer_id=d.customer_id
GROUP BY a.city
ORDER BY total_venue DESC
LIMIT 1
--EX8
/* Topic: JOIN & GROUP BY
Task: Tạo danh sách trả ra 2 cột dữ liệu: 
-	cột 1: thông tin thành phố và đất nước ( format: “city, country")
-	cột 2: doanh thu tương ứng với cột 1
Question: thành phố của đất nước nào đat doanh thu cao nhất
Answer: United States, Tallahassee : 50.85. */

SELECT a.city || ',' || e.country AS city_country,
SUM (d.amount) AS total_venue
FROM city AS a
JOIN address AS b ON a.city_id=b.city_id
JOIN customer AS c ON b.address_id=c.address_id
JOIN payment AS d ON c.customer_id=d.customer_id
JOIN country AS e ON e.country_id=a.country_id
GROUP BY a.city, e.country
ORDER BY total_venue DESC
LIMIT 1
