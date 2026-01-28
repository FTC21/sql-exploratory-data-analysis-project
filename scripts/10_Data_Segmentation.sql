
WITH customer_spending AS(
	SELECT 
	c.customer_key,
	SUM(fs.sales_amount) AS total_spending,
	MIN(order_date) first_order, 
	MAX(order_date) last_order,
	DATEDIFF(month,MIN(order_date) ,MAX(order_date)) AS lifespan
	FROM gold.fact_sales fs
	LEFT JOIN gold.dim_customers c
	ON fs.customer_key = c.customer_key
	GROUP BY c.customer_key
), 
customer_segmentation AS (
SELECT 
customer_key,
total_spending,
lifespan,
CASE 
	WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
	ElSE 'New'
END customer_segment
FROM customer_spending
)

SELECT
customer_segment,
COUNT(customer_key) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customers DESC