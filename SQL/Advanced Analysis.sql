# . Sales trend over years
SELECT 
YEAR(order_date) AS order_year,
sum(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold_fact_sales
WHERE order_date !=''
GROUP BY order_year
ORDER BY order_year;

# . Sales trend over years months
SELECT 
YEAR(order_date) AS order_year,
MONTH(order_date) AS order_month,
SUM(sales_amount) as total_sales,
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM gold_fact_sales
WHERE order_date !=''
GROUP BY order_year,order_month
ORDER BY order_year,order_month;

# CUMULATIVE ANALYSIS CALCULATING TOTAL SALES PER MONTH AND THE RUNNING TOTAL OF SALES OVER TIME
SELECT 
order_month as order_date,
total_sales, 
SUM(total_sales) OVER(PARTITION BY order_month ORDER BY order_month) AS total_running_sales

FROM(
	SELECT DATE_FORMAT(order_date,'%Y-%m') as order_month, 
    SUM(sales_amount) as total_sales 
	FROM gold_fact_sales
	WHERE order_date !=''
	GROUP BY  order_month) t;
     
# BY YEAR
SELECT order_year as order_year,total_sales, 
SUM(total_sales) OVER(ORDER BY order_year) AS total_running_sales

FROM(
	SELECT YEAR(order_date) as order_year, 
    SUM(sales_amount) as total_sales 
	FROM gold_fact_sales
	WHERE order_date !=''
	GROUP BY  order_year) t;
    
    # WITH MOVING AVG PRICE
    SELECT order_year as order_year,total_sales, 
SUM(total_sales) OVER(ORDER BY order_year) AS total_running_sales,
SUM(avg_price) OVER (ORDER BY order_year) AS moving_avg_price

FROM(
	SELECT YEAR(order_date) as order_year, 
    SUM(sales_amount) as total_sales , 
    ROUND(AVG(price),0) AS avg_price
	FROM gold_fact_sales
	WHERE order_date !=''
	GROUP BY  order_year) t;

#PERFORMANCE ANALYSIS - ANALYZE THE YEARLY PERFORMANCE OF PRODUCTS BY COMPARING THEIR SALES TO BOTH THE AVG SALES PERFORMANCE OF THE PRODUCT AND PREVIOUS YEAR'S SALES
WITH yearly_product_sales AS(

SELECT 
YEAR(f.order_date) AS order_year,p.product_name,
SUM(f.sales_amount) AS current_sales
FROM gold_fact_sales f 
LEFT JOIN gold_dim_products p
ON p.product_key = f.product_key 
WHERE f.order_date !=''
GROUP BY order_year,p.product_name
ORDER BY p.product_name
)

SELECT 
order_year,
product_name,
current_sales,
ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) AS avg_sales,
current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) AS diff_sales,
CASE WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) >0 THEN 'ABOVE_AVG'
	 WHEN current_sales - ROUND(AVG(current_sales) OVER (PARTITION BY product_name),0) <0 THEN 'BELOW_AVG'
     ELSE 'AVG'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) >0 THEN 'INCREASE'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) <0 THEN 'DECREASE'
     ELSE 'NO CHANGE'
     END AS py_change
     
FROM yearly_product_sales;

# PART-TO-WHOLE ANALYSIS : WHICH CATEGORIES CONTRIBUTE TO OVERALL SALES
WITH total_sales_by_category AS(

SELECT 
p.category,
SUM(f.sales_amount) AS total_sales
FROM gold_fact_sales f
LEFT JOIN gold_dim_products p
ON p.product_key=f.product_key
WHERE order_date !=''
GROUP BY category
)

SELECT 
category,
total_sales,
SUM(total_sales) OVER () AS overall_sales,
CONCAT((total_sales / SUM(total_sales) OVER () ) * 100,'%')  AS percentage_of_total
FROM total_sales_by_category 
ORDER BY total_sales DESC;

#DATA SEGMENTATION : SEGMENT PRODUCTS INTO COST RANGES AND COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT

WITH product_segment AS (

SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN "Below 100"
	 WHEN cost BETWEEN 100 AND 500 THEN "100-500"
     WHEN cost BETWEEN 500 AND 1000 THEN "500-1000"
     ELSE "Above 1000"
END AS cost_range
FROM gold_dim_products 
) 

SELECT 
cost_range,
COUNT(product_key) as total_products
FROM product_segment
GROUP BY cost_range
ORDER BY total_products DESC;


 /* GROUP CUSTOMERS INTO THREE 3 SEGEMNTS BASED ON THEIR SHOPPING BEHAVIOR:
 VIP: CX WITH AT LEAST 12 MONTHS OF HISTORY AND SPENDING MORE THAN 5000 
 REGULAR: CX WITH AT LEAST 12 MONTHS OF HISTORY BUT SPENDING 5000 OR LESS
 NEW: CX WITH LESS THAN 12 MONTHS OF HISTORY AND FIND THE TOTAL NUMBER OF CX OF EACH GROUP */
WITH cx_info AS (

SELECT 
c.customer_key,
SUM(f.sales_amount) AS total_spending,
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
TIMESTAMPDIFF(month,MIN(order_date),MAX(order_date)) AS cx_history
FROM gold_fact_sales f 
LEFT JOIN gold_dim_customers c
ON f.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
cx_segment,
COUNT(customer_key) AS total_cx
FROM (
	SELECT
    customer_key,
	CASE WHEN total_spending > 5000 AND cx_history >=12  THEN "VIP"
		 WHEN total_spending <= 5000 AND cx_history >=12 THEN "REGULAR"
		 ELSE "NEW"
	END AS cx_segment

FROM cx_info ) t
GROUP BY cx_segment;




























