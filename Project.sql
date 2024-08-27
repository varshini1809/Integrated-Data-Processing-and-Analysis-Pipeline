USE youtube;

select * from df_orders

select top 10 
	Category,
	product_id, 
	sum(sale_price)as sales
from 
	df_orders
group by 
	Category,
	Product_Id
order by 
	sales desc


WITH RankedSales AS (
    SELECT
        region,
        product_id,
        SUM(sale_price) AS sales,
        ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(sale_price) DESC) AS rn
    FROM
        df_orders
    GROUP BY
        region, product_id
)
SELECT
    region,
    product_id,
    sales
FROM
    RankedSales
WHERE
    rn <= 5
ORDER BY
    region, sales DESC;

WITH monthly_sales AS (
    SELECT 
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY 
        YEAR(order_date),
        MONTH(order_date)
)

SELECT 
    order_month,
    SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
    SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM 
    monthly_sales
GROUP BY 
    order_month
ORDER BY 
    order_month;

WITH ranked_sales AS (
    SELECT
        Category,
        YEAR(order_date) AS order_year,
        MONTH(order_date) AS order_month,
        SUM(sale_price) AS sales,
        row_number() over(partition by Category order by SUM(sale_price) desc) AS sales_rank
    FROM 
        df_orders
    GROUP BY
        Category,
        YEAR(order_date),
        MONTH(order_date)
)

SELECT 
    Category,
    order_year,
    order_month,
    sales
FROM 
    ranked_sales
WHERE 
    sales_rank = 1
ORDER BY 
    Category,
    order_year,
    order_month;

WITH yearly_profits AS (
    SELECT
        sub_category,
        YEAR(order_date) AS order_year,
        SUM(profit) AS total_profit
    FROM 
        df_orders
    WHERE 
        YEAR(order_date) IN (2022, 2023)
    GROUP BY
        sub_category,
        YEAR(order_date)
)

SELECT TOP 1
    sub_category,
    SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_2022,
    SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) AS profit_2023,
    SUM(CASE WHEN order_year = 2023 THEN total_profit ELSE 0 END) - SUM(CASE WHEN order_year = 2022 THEN total_profit ELSE 0 END) AS profit_growth
FROM 
    yearly_profits
GROUP BY 
    sub_category
ORDER BY 
    profit_growth DESC;

