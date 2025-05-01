--Sohum Tiwary

--Unoptimized query #1
--Daily sales performance categorized by product category
--6.11 MB
--1 Second

SELECT
  DATE(oi.created_at) AS sales_date,
  p.category,
  ROUND(SUM(oi.sale_price),2) AS total_sales,
  COUNT(DISTINCT oi.order_id) AS orders
FROM bigquery-public-data.thelook_ecommerce.order_items oi
JOIN bigquery-public-data.thelook_ecommerce.products p
  ON oi.product_id = p.id
GROUP BY 1, 2
ORDER BY sales_date DESC;

--Unoptimized query #2
--Utilizing age cohort for customer lifetime value

SELECT
  u.age,
  COUNT(DISTINCT u.id) AS customers,
  SUM(oi.sale_price) AS total_spent
FROM `bigquery-public-data.thelook_ecommerce.users` u
JOIN `bigquery-public-data.thelook_ecommerce.order_items` oi
  ON u.id = oi.user_id
GROUP BY u.age
ORDER BY u.age

--Optimized query #1
--4.72 MB compared to the 6.11 MB from before

WITH active_sales AS (
  SELECT
    p.category,
    p.name AS product_name,
    oi.sale_price,
    oi.created_at
  FROM bigquery-public-data.thelook_ecommerce.order_items AS oi
  JOIN bigquery-public-data.thelook_ecommerce.products AS p
    ON oi.product_id = p.id
)

SELECT
  DATE(created_at) AS sales_date,
  category,
  ROUND(SUM(sale_price), 2) AS total_sales,
  COUNT(*) AS total_items_sold
FROM active_sales
GROUP BY sales_date, category
ORDER BY sales_date DESC;

