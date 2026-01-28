-- Date Exploration for Sales
SELECT 
MIN(order_date) MinOrder, 
MAX(order_date) MaxOrder,
MIN(shipping_date) MinShip, 
MAX(shipping_date) MaxShip
FROM gold.fact_sales

-- Date Exploration for Customers
SELECT 
first_name, 
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AGE
FROM gold.dim_customers
GROUP BY first_name
ORDER BY MIN(birthdate)



SELECT * FROM gold.dim_customers