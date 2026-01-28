WITH TotalSales AS (
	SELECT
	DATETRUNC(YEAR,order_date) AS order_date,
	SUM(sales_amount) AS total_sales,
	AVG(price) AS avg_price
	FROM gold.fact_sales
	GROUP BY DATETRUNC(YEAR,order_date)
)

SELECT
	*,
	SUM(total_sales) OVER (
	ORDER BY order_date
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS runnning_total,
	AVG(avg_price) OVER (
	ORDER BY order_date
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS moving_avg
FROM TotalSales
WHERE order_date IS NOT NULL