WITH Total_SALES AS (
SELECT 
	p.category, 
	SUM(sales_amount) AS sales_tt
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p
ON fs.product_key = p.product_key	
GROUP BY p.category
)

SELECT 
*, 
SUM(sales_tt) OVER () overall_sales, 
CONCAT(ROUND((CAST(sales_tt AS FLOAT) / NULLIF(SUM(sales_tt) OVER (),0) ) * 100, 2),'%')AS percentage_value_2
FROM Total_SALES