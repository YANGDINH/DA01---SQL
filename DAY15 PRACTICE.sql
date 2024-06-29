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
/* EPOCH được sử dụng để chuyển đổi khoảng thời gian giữa hai thời điểm thành số giây. 
Ở đây, câu lệnh EXTRACT(EPOCH FROM ...), trong đó ... là biểu thức tính toán khoảng thời gian, sẽ trả về số giây giữa hai thời điểm. */
WITH payments AS (
  SELECT 
  merchant_id, 
  EXTRACT(EPOCH FROM 
  transaction_timestamp - LAG(transaction_timestamp) 
  OVER(PARTITION BY merchant_id, credit_card_id, amount 
  ORDER BY transaction_timestamp)
    )/60 AS minute_difference 
  FROM transactions) 

SELECT COUNT(merchant_id) AS payment_count
FROM payments 
WHERE minute_difference <= 10
--EX7
SELECT 
  category, 
  product, 
  total_spend 
FROM 
(SELECT category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER (PARTITION BY category ORDER BY SUM(spend) DESC) AS ranking 
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
) AS ranked_spending
WHERE ranking <= 2 
ORDER BY category, ranking;
--EX8
WITH top_10 AS (
SELECT 
artists.artist_name,
DENSE_RANK() OVER (ORDER BY COUNT(songs.song_id) DESC) AS artist_rank
FROM artists
INNER JOIN songs ON artists.artist_id = songs.artist_id
INNER JOIN global_song_rank AS ranking ON songs.song_id = ranking.song_id
WHERE ranking.rank <= 10
GROUP BY artists.artist_name
)
SELECT artist_name, artist_rank
FROM top_10
WHERE artist_rank <= 5;
