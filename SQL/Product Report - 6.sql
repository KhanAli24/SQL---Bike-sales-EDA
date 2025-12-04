/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    3. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/

# 1) BASE QUERY : RETRIEVING CORE COLUMNS FROM THE TABLES

CREATE VIEW gold_report_products AS
WITH base_query AS (
	SELECT 
		f.order_number,
		f.order_date,
        f.customer_key,
		f.sales_amount,
		f.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
	FROM gold_fact_sales f
	LEFT JOIN gold_dim_products p
	ON f.product_key=p.product_key
	WHERE order_date !=''
),

product_aggregations AS (
# 2)AGGREGATES PRODUCT-LEVEL METRICS

SELECT 
		product_key,
		product_name,
		category,
		subcategory,
        cost,
        TIMESTAMPDIFF(month,MIN(order_date),MAX(order_date)) AS cx_history,
        MAX(order_date) AS last_sale_date,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
		SUM(sales_amount) AS total_sales,
		SUM(quantity) AS total_quantity,
        ROUND(AVG(CAST(sales_amount AS FLOAT)/ NULLIF(quantity ,0)),1) AS avg_selling_price
FROM base_query
GROUP BY product_key,
		product_name,
		category,
		subcategory,
        cost
        )
        
        # 3) SEGMENTS PRODUCTS BY REVENUE TO IDENTIFY HIGH-PERFORMERS, MID-RANGE, OR LOW-PERFORMERS.
        # 4) CALCULATING VALUABLE KPI'S
SELECT 
		product_key,
		product_name,
		category,
		subcategory,
        cost,
        last_sale_date,
        TIMESTAMPDIFF(month, last_sale_date, CURDATE()) AS recency,
        CASE WHEN total_sales > 50000 THEN 'High Performers'
			 WHEN total_sales >=10000 THEN 'Mid-Range'
             ELSE 'Low Performers'
		END AS product_segment,
        cx_history,
        total_orders,
        total_sales,
        total_quantity,
        total_customers,
        avg_selling_price,
        CASE WHEN total_orders = 0 THEN 0   # MAKING SURE THAN WE NEVER DIVIDE BY ZERO
		ELSE ROUND(total_sales/total_orders,0)
		END AS avg_order_revenue,
		CASE WHEN cx_history = 0 THEN total_sales
			 ELSE ROUND(total_sales/cx_history,0)
		END AS avg_monthly_revenue
FROM product_aggregations