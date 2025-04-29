--insert all optimized queries here


--Top 20 best-selling products in the “Active” category by total items sold in descending order. (Optimized)
--Kenny Khoi Tran
--(415 + 395 + 474 + 392 + 399)/5 = 415 ms
--This query will process 4.75 MB when run.

WITH active_sales AS (
  SELECT
    oi.product_id,
    p.category,
    p.name          AS product_name,
    oi.sale_price
  FROM
    `bigquery-public-data.thelook_ecommerce.products`   AS p
  JOIN
    `bigquery-public-data.thelook_ecommerce.order_items` AS oi
    ON p.id = oi.product_id
  WHERE
    p.category = "Active"
)
SELECT
  product_id,
  category,
  product_name,
  ROUND(SUM(sale_price), 2) AS total_sales,
  COUNT(1)              AS total_items_sold
FROM
  active_sales
GROUP BY
  product_id,
  category,
  product_name
ORDER BY
  total_items_sold DESC,
  total_sales      DESC
LIMIT
  20;

-- Jin
-- Bytes processed 3.32 MB
-- Bytes billed 20 MB
-- Slot milliseconds 340
-- This query is an optimized version from query 1 
WITH only_order_items AS (  -- using Common table expression to create a subquery to scan only what i need
  SELECT
    product_id,
    sale_price -- selecting only what i need from query 1 so it doesn't scan everything from order items
  FROM
    `bigquery-public-data.thelook_ecommerce.order_items`
)
SELECT
  p.category                      AS product_category,
  ROUND(SUM(oi.sale_price), 2)    AS total_sales_revenue,
  COUNT(*)                        AS total_units_sold
FROM
  only_order_items AS oi
JOIN
  `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
GROUP BY
  p.category
ORDER BY
  total_sales_revenue DESC
LIMIT
  10;

--add more later
