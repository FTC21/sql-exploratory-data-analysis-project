-- Find Total customers by countries
SELECT 
country, 
COUNT(DISTINCT customer_id) total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- Find Total Number of Customer by gender
SELECT 
gender, 
COUNT(gender) gender_quantity, 
CAST(CAST(100.00 * COUNT(gender) / SUM(COUNT(gender)) OVER() AS DECIMAL(5,2)) AS VARCHAR) + '%' AS percentage
FROM gold.dim_customers
GROUP BY gender

-- Find Total Product by Category 

SELECT 
category, 
COUNT(product_key) AS Total_nbr_of_products
FROM gold.dim_products
GROUP BY category
ORDER BY Total_nbr_of_products DESC

-- What is the AVG cost in Each Category 
SELECT 
category, 
AVG(cost) AS average_cost
FROM gold.dim_products
GROUP BY category
ORDER BY average_cost DESC

-- What is the Total Revenue Generated for Each Categories
SELECT
p.category AS category,
SUM(sales_amount) Total_sales
FROM gold.fact_sales as fs
LEFT JOIN gold.dim_products p
ON fs.product_key = p.product_key
GROUP BY category
ORDER BY Total_sales DESC

-- What is the Total Revenue Generated for each customers
SELECT
fs.customer_key,
c.first_name,
c.last_name,
SUM(sales_amount) total_revenue
FROM gold.fact_sales as fs
LEFT JOIN gold.dim_customers c
ON fs.customer_key = c.customer_key
GROUP BY fs.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC

-- What is the distribution of sold item across countries 

SELECT 
c.country,
SUM(quantity) AS nbr_item_sold
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c
ON fs.customer_key = c.customer_key
GROUP BY c.country
ORDER BY nbr_item_sold DESC
