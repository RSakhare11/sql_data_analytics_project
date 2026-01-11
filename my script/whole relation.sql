/* 1. Gather essntial feilds such as names, age and transcation details.
   2. Segment customer as VIP, Regular,New and by age group.
   3. Aggregates customer level metrics:
	   -total orders
	   -total sales
	   -total quantity purschased
	   -total product
	   -lifespan(in month,years)
   4. Calculate valueable KIPs: 
       - recency(month since last order)
	   - avg order value
	   - avg monthly spending 
*/
-- BASE QUERY 
WITH base_query AS(
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name, ' ' ,c.last_name) AS cus_name,
DATEDIFF(year, c.birthdate, GETDATE()) AS age
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key
WHERE order_date IS NOT NULL
)
, customer_agg AS(
-- Customer aggeration: Summarize key metrics ast customer level
SELECT
customer_key,
cus_name,
customer_number,
age,
COUNT(DISTINCT order_number) AS total_order,
COUNT(DISTINCT product_key) AS total_product,
SUM(sales_amount) AS total_sales,
SUM(quantity) AS total_quantity,
MAX(order_date) AS last_order_date,
DATEDIFF(month, MIN(order_date) , MAX(order_date)) AS lifespan

FROM base_query
GROUP BY
customer_key,
cus_name,
customer_number,
age
)
SELECT
customer_key,
cus_name,
customer_number,
age,

CASE 
	WHEN age< 20 THEN 'below 20'
	WHEN age BETWEEN 20 AND 29 THEN '20-29'
	WHEN age BETWEEN 30 AND 39 THEN '30-39'
	WHEN age BETWEEN 40 AND 49 THEN '40-49'
	ELSE '50 nd above'
END AS age_group,

CASE 
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ELSE 'New'
END AS customer_segment,

total_order,
total_quantity,
total_product,
DATEDIFF(MONTH,last_order_date, GETDATE()) AS recency,
lifespan,
-- Compute avg value
CASE WHEN total_sales = 0 THEN '0'
ELSE total_sales/ total_order 
END AS avg_order_value,
-- AVG montly spend
CASE WHEN lifespan = 0 THEN total_sales
ELSE total_sales / lifespan
END AS avg_rmonthly_spend
FROM customer_agg
