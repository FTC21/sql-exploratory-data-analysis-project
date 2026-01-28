/* Analyze the yearly performance of products by comparing their sales to both 
the average sales performance of the product and the previous year's sales */ 

WITH yearly_product_sales AS (
	SELECT 
	YEAR(order_date) AS order_year,
	p.product_name, 
	SUM(sales_amount) AS current_sales
	FROM gold.fact_sales as fs
	LEFT JOIN gold.dim_products as p
	ON fs.product_key = p.product_key
	WHERE fs.order_date IS NOT NULL 
	GROUP BY YEAR(order_date), p.product_name
)

SELECT
	order_year, 
	product_name,
	current_sales, 
	AVG(current_sales) OVER (PARTITION BY product_name) AS Avg_sales, 
	current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_in_avg, 
	CASE 
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Average'
		WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Average'
		ELSE 'Avg'
	END AS [Status],
	-- Year Over Year Analysis (Long Term Trends Analysis)  // MOM (month over month is for short terms analysis)
	LAG(current_sales,1,0) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales, 
	current_sales - LAG(current_sales,1,0) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_year_perf,
	CASE 
		WHEN current_sales - LAG(current_sales,1,0) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
		WHEN current_sales - LAG(current_sales,1,0) OVER (PARTITION BY product_name ORDER BY order_year) < 0THEN 'Decrease'
		ELSE 'No Change'
	END AS [Yearly Performance]
FROM yearly_product_sales
ORDER BY product_name, order_year