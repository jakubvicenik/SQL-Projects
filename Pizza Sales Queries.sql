SELECT * FROM pizza_sales

ALTER TABLE pizza_sales
ALTER COLUMN order_date DATE;

ALTER TABLE pizza_sales
ALTER COLUMN order_time TIME;

--KPIs

SELECT SUM(total_price) AS Total_Revenue
FROM pizza_sales;

SELECT SUM(total_price) / COUNT (DISTINCT order_id) AS Avg_Order_Value
FROM pizza_sales;

SELECT SUM(quantity) AS Total_Pizza_Sold
FROM pizza_sales;

SELECT COUNT (DISTINCT order_id) AS Total_orders
FROM pizza_sales;

SELECT CAST(CAST(SUM(quantity) AS DECIMAL (10,2))
	 / CAST(COUNT(DISTINCT order_id) AS DECIMAL (10,2)) AS DECIMAL (10,2))
AS Avg_Pizzas_Per_order
FROM pizza_sales;

-- Daily Trend

SELECT DATENAME(DW, order_date) AS order_day, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATENAME(DW, order_date);

--Hourly Trend

SELECT DATEPART(HOUR, order_time) AS order_hours, COUNT(DISTINCT order_id) AS Total_orders
FROM pizza_sales
GROUP BY DATEPART(HOUR, order_time)
ORDEr BY DATEPART(HOUR, order_time);

-- Percentage of Sales by Pizza category, sizes

SELECT pizza_category, SUM(total_price) AS Total_Sales, SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales) AS PCT
FROM pizza_sales
GROUP BY pizza_category;

SELECT pizza_size, ROUND(SUM(total_price), 2) AS Total_Sales,  ROUND(SUM(total_price) * 100 / (SELECT SUM(total_price) from pizza_sales),2) AS PCT
FROM pizza_sales
GROUP BY pizza_size
ORDER BY PCT DESC;

SELECT pizza_category, SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_category;

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY SUM(quantity) DESC;

SELECT TOP 5 pizza_name, SUM(quantity) AS Total_Pizzas_Sold
FROM pizza_sales
GROUP BY pizza_name
ORDER BY SUM(quantity);