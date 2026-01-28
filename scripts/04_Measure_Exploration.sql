-- Find Total Sales
SELECT SUM(sales_amount) Total_Sales FROM gold.fact_sales
-- How many items are sold
SELECT SUM(quantity) AS Total_Items_Sold FROM gold.fact_sales

-- Average selling price 
SELECT AVG(price) AS Average_Price FROM gold.fact_sales

-- Total Number of Orders
SELECT COUNT(order_number) AS Total_Orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) AS Total_Orders FROM gold.fact_sales

-- Total Number of Products
SELECT COUNT(product_key) FROM gold.dim_products
SELECT COUNT(DISTINCT product_key) FROM gold.dim_products

-- Total Number of Customers 
SELECT COUNT(customer_id) FROM gold.dim_customers
SELECT COUNT(DISTINCT customer_id) FROM gold.dim_customers

-- Total Number of Customers that has placed an order
SELECT COUNT(DISTINCT customer_key) FROM gold.fact_sales

-- Generate a Report that shows all key metrics of the business
SELECT 'Total Sales' AS measure_name ,SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Quantity',SUM(quantity)  FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price',AVG(price)  FROM gold.fact_sales
UNION ALL 
SELECT 'Total Orders',COUNT(DISTINCT order_number)  FROM gold.fact_sales
UNION ALL 
SELECT 'Total Nbr of Products',COUNT(DISTINCT product_key)  FROM gold.dim_products
UNION ALL 
SELECT 'Total Nbr of customers',COUNT(DISTINCT customer_id)  FROM gold.dim_customers
