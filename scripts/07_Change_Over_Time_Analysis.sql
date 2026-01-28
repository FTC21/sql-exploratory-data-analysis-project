SELECT 
FORMAT(order_date, 'yyy-MMM') AS order_date,
SUM(sales_amount) AS Total_Sales
FROM gold.fact_sales
WHERE order_date IS NOT NULL 
GROUP BY FORMAT(order_date, 'yyy-MMM')
ORDER BY FORMAT(order_date, 'yyy-MMM')