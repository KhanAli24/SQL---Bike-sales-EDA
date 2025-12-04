# Bike Sales Analysis: End-to-End Exploratory Data Analysis Using SQL

## Project overview
This project performs an end-to-end Exploratory Data Analysis (EDA) on a bike sales dataset using pure SQL.  
The analysis is modularized into six SQL scripts that compute business measures, magnitude breakdowns, rankings, advanced time-series and segmentation EDA, and two production-ready reports (customer & product). The goal is to extract actionable business insights such as top products, customer segments, revenue by category, sales trends, and product performance tiers.

---

## Files included
- `sql/measures_exploration.sql`  
  Quick business KPIs (total sales, total orders, avg selling price, counts of products/customers).

- `sql/magnitude_analysis.sql`  
  Aggregations by country, gender, product category, revenue by category and customer-level revenue.

- `sql/ranking_analysis.sql`  
  Top/bottom product rankings, top customers by revenue, low-order customers; includes window-function examples.

- `sql/advance_eda.sql`  
  Yearly/monthly sales trends, cumulative & running totals, moving averages, yearly product performance vs avg & previous year, part-to-whole category contributions, product cost segmentation, customer segmentation by behavior.

- `sql/customer_report.sql`  
  Creates a view `gold_report_customers` that aggregates customer-level KPIs: total_orders, total_sales, avg_order_value, recency, cx_segment (VIP/REGULAR/NEW), age groups, etc. Includes a final `SELECT *` for quick inspection.

- `sql/product_report.sql`  
  Creates a view `gold_report_products` that aggregates product-level KPIs: total_sales, total_orders, total_customers, avg_selling_price, recency, product_segment (High/Mid/Low performers), avg_monthly_revenue.

---

## How to run
1. Create a database (e.g., `bike_sales_db`) and import the raw dataset into `gold_fact_sales`, `gold_dim_customers`, and `gold_dim_products` tables.  
2. Run scripts in this order (all located in `sql/`):
   - `measures_exploration.sql`
   - `magnitude_analysis.sql`
   - `ranking_analysis.sql`
   - `advance_eda.sql`
   - `customer_report.sql` (creates view `gold_report_customers`)
   - `product_report.sql`  (creates view `gold_report_products`)
3. Inspect outputs via `SELECT * FROM gold_report_customers` and `SELECT * FROM gold_report_products` and export CSVs if needed (stored in `outputs/`).

---

## Key insights (examples you can refine with real numbers)
- Top 5 revenue-generating products (from `ranking_analysis`) drive a large share of sales — prioritize these for promotions.
- Category-level revenue shows [Category X] and [Category Y] as top contributors (from `magnitude_analysis` and `advance_eda` part-to-whole).
- Monthly and yearly cumulative sales show seasonality — clear spikes (advance_eda running totals) during festive months.
- Customer segmentation (customer_report): VIPs (high spend + >12 months) contribute a disproportionate share of revenue.
- Product segmentation (product_report): identify high-performers (>50,000 total_sales), mid-range (10k–50k), and low-performers for inventory/discount decisions.

---

## What to include as outputs / screenshots in README
- KPI snapshot (result of the UNION ALL report in `measures_exploration.sql`) as a small table image.
- Top 5 / Bottom 5 product ranking table (from `ranking_analysis`).
- Sales trend chart (export monthly/yearly totals from `advance_eda` and include a line chart screenshot).
- Customer segmentation counts and a table of VIP customers (from `customer_report` view).
- Product segment distribution (pie/treemap screenshot or table) and sample top products (from `product_report`).

---

## Skills demonstrated
- SQL (aggregations, window functions, CTEs, joins, CASE)
- Data modeling for analytics (customer/product reporting views)
- Customer & product segmentation, time-series aggregation, ranking & cumulative metrics
- Creating production-ready analytical views

---

## Next steps / improvements
- Add index recommendations for large tables to improve view performance.
- Export key outputs to CSV and build a Power BI / Tableau dashboard using those CSVs.
- Add automated data-refresh scripts (ETL) and schedule reports for daily/weekly refresh.

