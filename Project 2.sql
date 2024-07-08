/* Ad-hoc tasks */
--Ex1
SELECT 
    FORMAT_TIMESTAMP('%Y-%m', created_at) AS month_year, 
    COUNT(DISTINCT user_id) AS total_user, 
    COUNT(order_id) AS total_order
FROM bigquery-public-data.thelook_ecommerce.orders
WHERE created_at BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY month_year
ORDER BY month_year;
--Ex2
SELECT 
    FORMAT_TIMESTAMP('%Y-%m', a.created_at) AS month_year, 
    COUNT(DISTINCT a.user_id) AS distinct_users, 
    ROUND(AVG(b.sale_price),2) AS average_order_value
FROM bigquery-public-data.thelook_ecommerce.orders as a
JOIN bigquery-public-data.thelook_ecommerce.order_items as b 
ON a.order_id = b.order_id
WHERE a.created_at BETWEEN '2019-01-01' AND '2022-04-30'
GROUP BY month_year
ORDER BY month_year;
--Ex3
-- Tìm khách hàng trẻ tuổi nhất
WITH youngest_customers AS (
    SELECT 
        first_name, 
        last_name, 
        gender, 
        age, 
        'youngest' AS tag
    FROM bigquery-public-data.thelook_ecommerce.users
    WHERE age IS NOT NULL
    ORDER BY age ASC
    LIMIT 1
),
-- Tìm khách hàng lớn tuổi nhất
oldest_customers AS (
    SELECT 
        first_name, 
        last_name, 
        gender, 
        age, 
        'oldest' AS tag
    FROM bigquery-public-data.thelook_ecommerce.users
    WHERE age IS NOT NULL
    ORDER BY age DESC
    LIMIT 1
)
SELECT * FROM youngest_customers
UNION ALL
SELECT * FROM oldest_customers;
--Ex4
WITH product_profit AS (
    SELECT 
        FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS month_year, 
        p.id AS product_id, 
        p.name AS product_name, 
        SUM(oi.sale_price) AS sales, 
        SUM(p.cost) AS cost, 
        SUM(oi.sale_price - p.cost) AS profit
    FROM bigquery-public-data.thelook_ecommerce.orders as o
    JOIN bigquery-public-data.thelook_ecommerce.order_items as oi 
    ON o.order_id = oi.order_id
    JOIN bigquery-public-data.thelook_ecommerce.products as p 
    ON oi.product_id = p.id
    WHERE o.created_at BETWEEN '2019-01-01' AND '2022-04-30'
    GROUP BY month_year, p.id, product_name
)
SELECT 
    month_year, 
    product_id, 
    product_name, 
    sales, 
    cost, 
    profit, 
    DENSE_RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) AS rank_per_month
FROM product_profit
QUALIFY DENSE_RANK() OVER (PARTITION BY month_year ORDER BY profit DESC) <= 5
ORDER BY month_year, rank_per_month
--EX5
SELECT 
    FORMAT_TIMESTAMP('%Y-%m-%d', o.created_at) AS dates, 
    p.category AS product_categories, 
    SUM(oi.sale_price) AS revenue
FROM `bigquery-public-data.thelook_ecommerce.orders` o
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi 
ON o.order_id = oi.order_id
JOIN `bigquery-public-data.thelook_ecommerce.products` p 
ON oi.id = p.id
WHERE o.created_at BETWEEN '2022-01-15' AND '2022-04-15'
GROUP BY dates, product_categories
ORDER BY dates, product_categories;
