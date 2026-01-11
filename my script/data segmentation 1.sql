/*        DATA SEGMENTATION 
Group the data based on specific range.
Helps understand the  correlation between two measures.
Formula [Measure] BY [Measure] like 
Total product by sales range or Total Customer by Age*/ 

--Q Segment the data in into cost ranges and count How many product fall into eac segment

WITH product_segment AS (
SELECT
product_key,
product_name,
cost,
CASE
WHEN cost < 100 THEN 'Below 100'
WHEN cost BETWEEN 100 AND 500 THEN '100-500'
WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
ELSE 'Above 100'
END AS cost_range
FROM gold.dim_products 
)
SELECT  
cost_range,
COUNT(product_key) AS total_product
FROM product_segment
GROUP BY cost_range
ORDER BY total_product DESC