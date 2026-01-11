WITH category_sales AS(
SELECT
category,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales AS g
LEFT JOIN gold.dim_products AS P
ON g.product_key = p.product_key
GROUP BY category
)
SELECT
category,
total_sales,
SUM(total_sales) OVER()  AS overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER()) * 100, 2), '%')AS percent_of_total

FROM category_sales