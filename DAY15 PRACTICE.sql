--EX1
WITH yearly_spend AS (
  SELECT
    product_id,
    EXTRACT(YEAR FROM transaction_date) AS year,
    SUM(spend) AS total_spend
  FROM
    user_transactions
  GROUP BY
    product_id,
    EXTRACT(YEAR FROM transaction_date)
)
SELECT
  year,
  product_id,
  total_spend AS curr_year_spend,
  LAG(total_spend) OVER (PARTITION BY product_id ORDER BY year) AS prev_year_spend,
  ROUND(((total_spend - LAG(total_spend) OVER (PARTITION BY product_id ORDER BY year)) / 
         LAG(total_spend) OVER (PARTITION BY product_id ORDER BY year)) * 100, 2) AS yoy_rate
FROM
  yearly_spend
ORDER BY
  product_id,
  year;
--EX2
WITH card_launch AS (
SELECT
card_name, 
issued_amount,
issue_month,
issue_year,
ROW_NUMBER() OVER(PARTITION BY card_name ORDER BY issue_year, issue_month) AS stt 
FROM monthly_cards_issued
)
SELECT card_name,
issued_amount
FROM card_launch
WHERE stt=1
ORDER BY issued_amount DESC
--EX3
WITH ranked_transcation AS (
SELECT 
user_id,
spend,
transaction_date,
ROW_NUMBER() OVER(PARTITION BY user_id ORDER BY transaction_date) AS stt
FROM transactions
)
SELECT
user_id,
spend,
transaction_date
FROM ranked_transcation
WHERE stt=3
--EX4
WITH latest_transactions_cte AS (
SELECT 
 transaction_date, 
 user_id, 
 product_id, 
 RANK() OVER (PARTITION BY user_id ORDER BY transaction_date DESC) AS ranking 
FROM user_transactions
)
SELECT 
transaction_date,
user_id,
COUNT(product_id) AS purchase_count
FROM latest_transactions_cte
WHERE ranking=1
GROUP BY transaction_date, user_id
ORDER BY transaction_date, user_id
--EX5
SELECT
  user_id,
  tweet_date,
 ROUND(AVG(tweet_count) OVER (PARTITION BY user_id ORDER BY tweet_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS rolling_avg_3d
FROM tweets;
--EX6
