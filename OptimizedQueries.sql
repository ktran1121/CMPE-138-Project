--insert all optimized queries here


--Top 20 best-selling products in the “Active” category by total items sold in descending order. (Optimized)
--Kenny Khoi Tran
--(415 + 395 + 474 + 392 + 399)/5 = 415 ms
--This query will process 4.72 MB when run.

WITH active_products AS (
  SELECT
    id AS product_id,
    name AS product_name,
    category
  FROM
    `bigquery-public-data.thelook_ecommerce.products`
  WHERE
    category = "Active"
),
product_sales AS (
  SELECT
    oi.product_id,
    oi.sale_price
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  JOIN
    active_products AS ap
    ON oi.product_id = ap.product_id
)

SELECT
  ps.product_id,
  ap.category,
  ap.product_name,
  ROUND(SUM(ps.sale_price), 2) AS total_sales,
  COUNT(*) AS total_items_sold
FROM
  product_sales AS ps
JOIN
  active_products AS ap
  ON ps.product_id = ap.product_id
GROUP BY
  ps.product_id,
  ap.category,
  ap.product_name
ORDER BY
  total_items_sold DESC,
  total_sales DESC
LIMIT
  20;




--add more later
