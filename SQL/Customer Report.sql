 /*
===============================================================================
Customer Report
===============================================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    3. Segments customers into categories (VIP, Regular, New) and age groups.
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================

.-------------------------------------------------------------------------------------------------------------------------------------------------------
# 1) BASE QUERY: RETRIEVE CORE COLUMNS FROM THE TABLES
----------------------------------------------------------------------------------------------------------------------------------------------------
*/
CREATE VIEW gold_report_customers AS 
WITH base_query AS (
SELECT 
f.order_number,
f.product_key,
f.order_date,
f.sales_amount,
f.quantity,
c.customer_key,
c.customer_number,
CONCAT(c.first_name ,' ', c.last_name) AS customer_name,
TIMESTAMPDIFF(YEAR,c.birthdate, CURDATE()) age
FROM gold_fact_sales f
LEFT JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
WHERE order_date!=''
)
 /* -------------------------------------------------------------------------------------------------------------------------------
 2) AGGREGATING CUSTOMER-LEVEL METRICS: TOTAL ORDERS,SALES,QUANTITY PURCHASED,PRODUCTS AND CUSTOMER HISTORY
	-------------------------------------------------------------------------------------------------------------------------------*/
 , customer_aggregations AS (
 SELECT 
	customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order,
    TIMESTAMPDIFF(month,MIN(order_date),MAX(order_date)) AS cx_history
FROM base_query
GROUP BY 
	customer_key,
    customer_number,
    customer_name,
    age
)
/*---------------------------------------------------------------------------------------------------------------------------------------
  3) SEGMENTING CUSTOMERS INTO CATEGORIES (VIP,REGULAR,NEW) AND AGE GROUPS
  4) CALCULATING VALUABLE KPI'S : RECENCY (MONTHS SINCE LAST ORDER) , AVG ORDER VALUE AND AVG MONTHLY SPEND
  -------------------------------------------------------------------------------------------------------------------------------------*/
SELECT 
	customer_key,
    customer_number,
    customer_name,
    age,
    CASE WHEN age <20 THEN 'below 20'
		 WHEN age BETWEEN 20 AND 29 THEN '20-29'
         WHEN age BETWEEN 30 AND 39 THEN '30-39'
         WHEN age BETWEEN 40 AND 49 THEN '40-49'
         ELSE '50 and above'
	END AS age_group,
    CASE WHEN total_sales > 5000 AND cx_history >=12  THEN "VIP"
		 WHEN total_sales <= 5000 AND cx_history >=12 THEN "REGULAR"
		 ELSE "NEW"
	END AS cx_segment,
    last_order,
    TIMESTAMPDIFF(month, last_order, CURDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    cx_history,
    CASE WHEN total_orders = 0 THEN 0   # MAKING SURE THAN WE NEVER DIVIDE BY ZERO
		ELSE ROUND(total_sales/total_orders,0)
    END AS avg_order_value,
    CASE WHEN cx_history = 0 THEN total_sales
		 ELSE ROUND(total_sales/cx_history,0)
	END AS avg_monthly_spend
FROM customer_aggregations;


SELECT * FROM gold_report_customers;



