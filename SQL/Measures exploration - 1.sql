/*==========================================================================================================================================================
  MEASURES EXPLORATION
  ==========================================================================================================================================================
  */

--  FIND THE TOTAL SALES
SELECT SUM(sales_amount) AS total_sales FROM gold_fact_sales;

-- FIND HOW MANY ITEMS ARE SOLD
SELECT COUNT(quantity) AS total_quantity FROM gold_fact_sales;

--  FIND THE AVG SELLING PRICE
SELECT AVG(sales_amount) AS avg_selling_price FROM gold_fact_sales;

-- FIND THE TOTAL NUMBER OF ORDERS
SELECT COUNT(order_number) AS total_orders FROM gold_fact_sales;
SELECT COUNT(DISTINCT order_number) AS total_unique_orders FROM gold_fact_sales;

--  FIND THE TOTAL NUMBER OF PRODUCTS
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold_dim_products;

--  FIND TOTAL NUMBER OF CUSTOMERS 
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold_dim_customers;

--  FIND THE TOTAL NUMBER OF CUSTOMERS WHO HAVE PLACED AN ORDER
SELECT COUNT(DISTINCT customer_key) AS total_cx_who_placed_order FROM gold_fact_sales;


-- GENREATE A REPORT THAT SHOWS ALL KEY METRICS OF THE BUSINESS

SELECT 'Total Sales' AS Metrics, CAST(SUM(sales_amount) AS UNSIGNED) AS Value FROM gold_fact_sales
UNION ALL
SELECT 'Total Quantity', CAST(COUNT(quantity) AS UNSIGNED) FROM gold_fact_sales
UNION ALL
SELECT 'Average Sales', ROUND(AVG(sales_amount),0) FROM gold_fact_sales
UNION ALL
SELECT 'Total no. of Orders', CAST(COUNT(DISTINCT order_number) AS UNSIGNED) FROM gold_fact_sales
UNION ALL
SELECT 'Total no. of Products' , CAST(COUNT(DISTINCT product_key) AS UNSIGNED) FROM gold_dim_products
UNION ALL
SELECT 'Total Customrs', CAST(COUNT(DISTINCT customer_key) AS UNSIGNED) FROM gold_dim_customers

