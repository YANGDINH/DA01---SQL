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

/* Tạo metric trước khi dựng dashboard */
-- Tạo VIEW vw_ecommerce_analyst với các metric cần thiết
CREATE OR REPLACE VIEW silver-treat-428807-q3.my_dataset.vw_ecommerce_analyst AS
WITH monthly_data AS (
    SELECT 
        FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS month_year,
        EXTRACT(YEAR FROM o.created_at) AS year,
        p.category AS product_category,
        SUM(oi.sale_price) AS TPV,
        COUNT(o.order_id) AS TPO,
        SUM(p.cost) AS total_cost,
        SUM(oi.sale_price - p.cost) AS total_profit
    FROM bigquery-public-data.thelook_ecommerce.orders as o
    JOIN bigquery-public-data.thelook_ecommerce.order_items as oi 
    ON o.order_id = oi.order_id
    JOIN bigquery-public-data.thelook_ecommerce.products as p 
    ON oi.product_id = p.id
    GROUP BY month_year, year, product_category
),
growth_data AS (
    SELECT 
        month_year,
        product_category,
        TPV,
        TPO,
        total_cost,
        total_profit,
        LAG(TPV) OVER (PARTITION BY product_category ORDER BY month_year) AS prev_TPV,
        LAG(TPO) OVER (PARTITION BY product_category ORDER BY month_year) AS prev_TPO
    FROM monthly_data
)
SELECT 
    month_year,
    EXTRACT(YEAR FROM PARSE_TIMESTAMP('%Y-%m', month_year)) AS year,
    product_category,
    TPV,
    TPO,
    total_cost,
    total_profit,
    (TPV - prev_TPV) / prev_TPV * 100 AS revenue_growth,
    (TPO - prev_TPO) / prev_TPO * 100 AS order_growth,
    total_profit / total_cost AS profit_to_cost_ratio
FROM growth_data
ORDER BY month_year, product_category;
--Tạo retention cohort analysis
-- Tạo VIEW vw_retention_cohort_analysis
CREATE OR REPLACE VIEW `silver-treat-428807.q3.vw_retention_cohort_analysis` AS
WITH user_orders AS (
    SELECT 
        user_id,
        MIN(FORMAT_TIMESTAMP('%Y-%m', created_at)) AS first_order_month
    FROM `bigquery-public-data.thelook_ecommerce.orders`
    GROUP BY user_id
),
cohorts AS (
    SELECT 
        u.user_id,
        u.first_order_month,
        FORMAT_TIMESTAMP('%Y-%m', o.created_at) AS order_month
    FROM user_orders u
    JOIN `bigquery-public-data.thelook_ecommerce.orders` o
    ON u.user_id = o.user_id
    WHERE FORMAT_TIMESTAMP('%Y-%m', o.created_at) BETWEEN u.first_order_month AND FORMAT_TIMESTAMP('%Y-%m', TIMESTAMP_ADD(PARSE_TIMESTAMP('%Y-%m', u.first_order_month), INTERVAL 3 MONTH))
)
SELECT 
    first_order_month,
    order_month,
    COUNT(DISTINCT user_id) AS active_users
FROM cohorts
GROUP BY first_order_month, order_month
ORDER BY first_order_month, order_month;
