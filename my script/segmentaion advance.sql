/* Group customers into three segements based on their spending behaviour:
- VIP: Customers from 12 months and spend above $5000
- Regular customer: customer with at least few month of history and spend 500$ or less.
- New: Customer with lifespan less than 12 months. 
And find total number of customer in eacg group. */

WITH customer_spending AS(

SELECT
c.customer_key,
SUM(f.sales_amount) AS total_sales,
MIN(order_date) AS frist_order,
MAX(order_date) AS last_order,
DATEDIFF(month,MIN(order_date), MAX(order_date)) AS lifespan
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)
SELECT
customer_segment,
COUNT(customer_key) AS total_customer
FROM(
SELECT
customer_key,
total_sales,
lifespan,
CASE 
WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
WHEN lifespan >= 12 AND total_sales<= 5000 THEN 'RC'
ELSE 'NEW CUSTOMER'
END AS customer_segment
FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customer DESC 
