/*==============================================================================================================================================================
  RANKING ANALYSIS
  ==============================================================================================================================================================*/
  

-- WHICH 5 PRODUCTS GENERATE HIGHEST REVENUE?
SELECT 
p.product_name, 
SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC LIMIT 5;

-- USING WINDOW FUNCTIONS
SELECT* FROM(
	SELECT p.product_name, 
	SUM(f.sales_amount) AS total_sales,
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC) AS rank_products
	FROM gold_fact_sales f
	JOIN gold_dim_products p
	ON f.product_key=p.product_key
	GROUP BY p.product_name
)t 
WHERE rank_products <=5;


-- WHAT ARE THE 5 WORST PERFORMING PRODUCTS IN TERMS OF SALE
SELECT 
p.product_name, 
SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
JOIN gold_dim_products p
ON f.product_key=p.product_key
GROUP BY p.product_name
ORDER BY total_sales  LIMIT 5;

-- FIND TOP 10 CUSTOMERS WHO HAVE GENERATED HIGHEST REVENUE
SELECT 
c.customer_key,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
SUM(sales_amount) AS total_revenue
FROM gold_fact_sales f 
JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
GROUP BY c.customer_key,customer_name
ORDER BY total_revenue DESC LIMIT 10;

-- FIND THE 3 CUSTOMERS WITH FEWSEST ORDERS PLACED
SELECT 
f.order_number,
c.customer_key,
CONCAT(c.first_name,' ',c.last_name) AS customer_name,
COUNT(DISTINCT order_number) AS total_orders
FROM gold_fact_sales f
JOIN gold_dim_customers c
ON f.customer_key=c.customer_key
GROUP BY c.customer_key,customer_name,f.order_number
ORDER BY total_orders LIMIT 3;