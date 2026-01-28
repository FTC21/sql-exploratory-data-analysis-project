/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and performance behaviors.
    - Provides a holistic view of sales, customer reach, and product health.

Highlights:
    1. Descriptive: Product details (Name, Category, Subcategory, Cost).
    2. Quantitative: Aggregated sales volume, order counts, and customer reach.
    3. Qualitative: Product segmentation based on Revenue (Total Sales).
    4. Temporal: Lifespan and Recency (How long we've sold it vs. last sale).
    5. Financial KPIs: Average Order Revenue (AOR) and Average Monthly Revenue.
===============================================================================*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL 
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS ( 
/*-----------------------------------------------------------------------------
1) Base Query: Fetch core transactional data and link to product attributes
-----------------------------------------------------------------------------*/
SELECT 
    f.order_number, 
    f.product_key,
    f.order_date,
    f.customer_key,
    f.sales_amount,
    f.quantity,
    p.product_number,
    p.product_name,
    p.category,
    p.subcategory,
    p.cost
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
    ON f.product_key = p.product_key -- FIXED: Changed from customer_key to product_key
WHERE f.order_date IS NOT NULL
),  

product_aggregation AS (
/*-----------------------------------------------------------------------------
2) Aggregations: Collapse transactions into a single row per product
-----------------------------------------------------------------------------*/
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    MAX(order_date) AS last_order,
    COUNT(DISTINCT order_number) AS total_orders, 
    SUM(sales_amount) AS total_sales, 
    SUM(quantity) AS total_quantity_sold, -- Improved: SUM is better than COUNT for qty
    COUNT(DISTINCT customer_key) AS total_customers,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan, 
    -- Calculate average selling price per unit
    ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 2) AS avg_selling_price
FROM base_query
GROUP BY 
    product_key, 
    product_name, 
    category, 
    subcategory, 
    cost
),

product_segmentation AS (
/*-----------------------------------------------------------------------------
3) Segmentation: Categorize products based on revenue thresholds
-----------------------------------------------------------------------------*/
SELECT 
    *,
    CASE 
        WHEN total_sales < 200 THEN 'Low-Performers'
        WHEN total_sales BETWEEN 200 AND 5000 THEN 'Mid-Range'
        ELSE 'High-Performers'
    END AS product_segment
FROM product_aggregation 
) 

/*-----------------------------------------------------------------------------
4) Final Selection: Calculate derivative KPIs (Recency, AOR, AMR)
-----------------------------------------------------------------------------*/
SELECT 
    product_key,
    product_name,
    category,
    subcategory,
    product_segment,
    cost,
    total_orders, 
    total_sales, 
    total_quantity_sold, 
    total_customers,
    avg_selling_price,
    lifespan,
    -- KPI: Months since the last sale occurred
    DATEDIFF(MONTH, last_order, GETDATE()) AS recency_months,
    -- KPI: Revenue earned per month of product life
    CASE  
        WHEN lifespan <= 0 THEN total_sales -- If sold in only 1 month, use total sales
        ELSE total_sales / lifespan 
    END AS average_monthly_revenue,
    -- KPI: Revenue earned per unique order
    CASE 
        WHEN total_orders = 0 THEN 0 
        ELSE total_sales / total_orders 
    END AS average_order_revenue
FROM product_segmentation;
GO