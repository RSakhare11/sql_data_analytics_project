WITH yearly_product_sales AS(
SELECT 
YEAR(g.order_date) AS order_yearly,
p.product_name,
SUM(g.sales_amount) AS current_sales
FROM gold.fact_sales AS g
LEFT JOIN gold.dim_products AS p
ON g.product_key  = p.product_key
WHERE g.order_date IS NOT NULL
GROUP BY p.product_name, YEAR(g.order_date)
) 
SELECT 
order_yearly,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
CASE
WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0  THEN 'above avg'
WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0  THEN 'below avg'
ELSE 'AVG'
END avg_change,
LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_yearly) AS prev_year_sale,
current_sales - LAG(current_sales) OVER(PARTITION BY product_name ORDER BY order_yearly) AS sales_diff
FROM yearly_product_sales
ORDER BY product_name,order_yearly