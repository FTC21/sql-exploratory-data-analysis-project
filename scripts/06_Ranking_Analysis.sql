-- Which 5 Product Generate the Highest Revenue
SELECT TOP 5
p.product_name,
SUM(sales_amount) AS Total_Revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p
ON fs.product_key = p.product_key
GROUP BY product_name
ORDER BY Total_Revenue DESC

 -- Use window function
	SELECT
	*
	FROM
		(SELECT 
		p.product_name, 
		SUM(fs.sales_amount) Total_sales,
		RANK() OVER (ORDER BY SUM(fs.sales_amount) DESC) AS RankFlag
		FROM gold.fact_sales fs
		LEFT JOIN gold.dim_products p
		ON fs.product_key = p.product_key
		GROUP BY p.product_name)t WHERE RankFlag <= 5

-- Which 5 Worst performing products in terms of sales
SELECT TOP 5
p.product_name,
category,
SUM(sales_amount) AS Total_Revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p
ON fs.product_key = p.product_key
GROUP BY product_name, category
ORDER BY Total_Revenue

-- Find Top 10 customer who havegenerate the Highest Revenue 

SELECT TOP 10
c.customer_id, 
c.first_name,
c.last_name,
SUM(sales_amount) AS Totals_Revenue
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_customers c
ON fs.customer_key = c.customer_key
GROUP BY c.customer_id, c.first_name,c.last_name
ORDER BY SUM(sales_amount) DESC

-- Find 3 customers with the fewer orders placed

SELECT TOP 3
fs.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT order_number)
FROM gold.fact_sales fs 
LEFT JOIN gold.dim_customers c
ON fs.customer_key = c.customer_key
GROUP BY fs.customer_key, c.first_name, c.last_name
ORDER BY COUNT(DISTINCT order_number) ASC

SELECT
fs.customer_key,
COUNT(DISTINCT fs.order_number)
FROM gold.fact_sales fs
WHERE fs.customer_key = 92
GROUP BY fs.customer_key