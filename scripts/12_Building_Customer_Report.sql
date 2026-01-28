/*
======================================================================
Customer Report
======================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
======================================================================
*/
CREATE VIEW gold.report_customers AS 
WITH base_query AS (
/*-----------------------------------------------------------------
1) Base Query: Retrieves core columns from tables 
------------------------------------------------------------------*/
   SELECT 
        fs.order_number,
        fs.product_key,
        fs.order_date,
        fs.sales_amount,
        fs.quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name,' ',c.last_name) AS customer_name,
        DATEDIFF(year,c.birthdate,GETDATE()) AS age
   FROM gold.fact_sales fs
   LEFT JOIN gold.dim_customers c 
   ON fs.customer_key = c.customer_key
   WHERE order_date IS NOT NULL)
   ,
customer_aggregation AS (
/*-----------------------------------------------------------------
1) Customer Aggregations: Summarizes key metrics at customer level 
------------------------------------------------------------------*/
    SELECT 
        customer_key,
        customer_number,
        customer_name,
        age, 
        COUNT(DISTINCT order_number) AS total_orders, 
        SUM(sales_amount) AS total_sales, 
        SUM(quantity) AS total_quantities, 
        COUNT(DISTINCT product_key) AS total_products, 
        MAX(order_date) AS last_order,
        DATEDIFF(Month,MIN(order_date),MAX(order_date)) AS lifespan
    FROM base_query
    GROUP BY customer_key,customer_number,customer_name,age
    )

SELECT
customer_key,
customer_number,
customer_name,
age,
total_orders, 
total_sales, 
total_quantities,   
total_products, 
lifespan,
CASE 
    WHEN age < 18  THEN 'Under 18'
    WHEN age BETWEEN 18 AND 25 THEN 'Under 25'
    WHEN age BETWEEN 25 AND 35 THEN 'Under 35'
    WHEN age BETWEEN 35 AND 50 THEN 'Under 50'
    ELSE '50 and above'
END AS age_segmentation,
CASE 
	WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
	WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
	ElSE 'New'
END customer_segment,
last_order,
DATEDIFF(month,last_order,GETDATE()) AS recency, 
-- compute Average order value (AVO)
CASE WHEN total_orders = 0 THEN 0
ELSE total_sales / total_orders 
END AS avg_order_value,
-- Avg monthly spend
CASE WHEN lifespan = 0 THEN total_sales 
ELSE total_sales / lifespan
END AS avg_monthly_spend 
FROM customer_aggregation