--Kenny Khoi Tran

--Unoptimized Queries

--First Query
--Show products that have a low stock of less than ten and have not been sold yet.
--This query will process 11.15 MB when run.

SELECT
  p.id AS product_id,
  p.name AS product_name,
  p.category AS product_category,
  p.brand  AS product_brand,
  COUNT(*) AS current_stock,
  MIN(inv.created_at) AS first_stock_date,
FROM
  `bigquery-public-data.thelook_ecommerce.inventory_items` AS inv
JOIN
  `bigquery-public-data.thelook_ecommerce.products`       AS p
  ON inv.product_id = p.id
WHERE
  inv.sold_at IS NULL 
GROUP BY
  p.id, p.name, p.category, p.brand
HAVING
  current_stock < 10                
ORDER BY
  current_stock ASC;


--Second Query
--Counts how many items were sold in each season and month, ordered by units sold in descending order.
--This query will process 4.67 MB when run.

SELECT
  CASE
    WHEN EXTRACT(MONTH FROM o.created_at) IN (12, 1, 2) THEN 'Winter'
    WHEN EXTRACT(MONTH FROM o.created_at) IN (3, 4, 5)  THEN 'Spring'
    WHEN EXTRACT(MONTH FROM o.created_at) IN (6, 7, 8)  THEN 'Summer'
    ELSE 'Fall'
  END                                          AS season,
  EXTRACT(MONTH FROM o.created_at)             AS month,
  COUNT(oi.id)                                 AS units_sold
FROM
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN
  `bigquery-public-data.thelook_ecommerce.orders`      AS o
  ON oi.order_id = o.order_id
GROUP BY
  season,
  month
ORDER BY
  units_sold DESC;


--Third Query
--Count how many unique users in each U.S. state have placed an order for products by the brand “Under Armour.” 
--Top 10 states with the highest number of such customers in descending order.
--This script will process 8.03 MB when run.

SELECT
  u.state,
  COUNT(DISTINCT u.id) AS number_of_customers
FROM
  `bigquery-public-data.thelook_ecommerce.users` AS u
JOIN
  `bigquery-public-data.thelook_ecommerce.orders`      AS o
  ON u.id = o.user_id
JOIN
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
  ON o.order_id = oi.order_id
JOIN
  `bigquery-public-data.thelook_ecommerce.products`    AS p
  ON oi.product_id = p.id
WHERE
  p.brand = "Under Armour"
  AND u.country = 'United States'
  AND u.state IS NOT NULL          
GROUP BY
  u.state
ORDER BY
  number_of_customers DESC
LIMIT 10;


--Fourth Query (Unoptimized)
--Top 20 best-selling products in the “Active” category by total items sold in descending order. 
--This query will process 6.1 MB when run.
--Elapsed Times in ms:
--(397 + 521 + 499 + 344 + 434)/5 = 439 ms (Average run time)

SELECT
  oi.product_id,
  p.category,
  p.name AS product_name,
  ROUND(SUM(oi.sale_price), 2) AS total_sales,
  COUNT(oi.id) AS total_items_sold
FROM
  `bigquery-public-data.thelook_ecommerce.order_items` AS oi
JOIN
  `bigquery-public-data.thelook_ecommerce.products` AS p
  ON oi.product_id = p.id
WHERE
  p.category = "Active"
GROUP BY
  oi.product_id, p.name, p.category
ORDER BY
  total_items_sold DESC,
  total_sales DESC  
LIMIT 20;

Query 5:
--Top 20 best-selling products in the “Active” category by total items sold in descending order. (Optimized)
--(388 + 326 + 360 + 330 + 321)/5 = 345 ms
--This query will process 4.75 MB when run.

WITH active_sales AS (
  SELECT
    oi.product_id,
    p.category,
    p.name AS product_name,
    oi.sale_price
  FROM
    `bigquery-public-data.thelook_ecommerce.products` AS p
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
  COUNT(*) AS total_items_sold
FROM
  active_sales
GROUP BY
  product_id,
  category,
  product_name
ORDER BY
  total_items_sold DESC,
  total_sales DESC
LIMIT
  20;











