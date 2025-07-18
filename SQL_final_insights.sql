use final
---------------------------------------------------------------------------------
select * from Fact_Shipment
select * from Dim_Shipment_Mode
select * from Dim_Shipment_Date
select * from Dim_Warehouse
select * from Fact_Orders
select * from Dim_Customer
select * from Dim_Product
select * from Dim_Order_Date
select * from inventory
select * from fulfillment
----------------------------------------------------------------------------------
--1-What are the total sales, profit by year/month?
select d.Order_Month,d.Order_Year,sum(f.Gross_Sales) Total_Sales,sum(f.Profit) Total_Prpfit
from Fact_Orders f
join Dim_Order_Date d on f.Order_Date_ID=d.Order_Date_ID
group by d.Order_Month,d.Order_Year
order by d.Order_Month

--2-Which product categories generate the most profit?
select top 5 d.Product_Category,sum(f.Profit) Total_Profit
from Dim_Product d
join Fact_Orders f on f.Product_ID=d.Product_ID
group by Product_Category
order by Total_Profit desc

--3-What is the trend of order quantity over time?
select d.Order_Month,avg(f.Order_Quantity) Avg_Quantity
from Fact_Orders f
join Dim_Order_Date d on f.Order_Date_ID=d.Order_Date_ID
group by d.Order_Month
order by d.Order_Month

--4-What is the average order value per customer region or market?
select d.Customer_Market,d.Customer_Region,
avg(f.Gross_Sales) / count(distinct f.Order_ID) average_order_value
from Fact_Orders f
join Dim_Customer d on f.Customer_ID=d.Customer_ID
group by d.Customer_Market,d.Customer_Region
order by average_order_value desc

--5-Top 10 customers by total sales or profit
select  top 10 d.Customer_ID,sum(f.Gross_Sales) total_sales
from Dim_Customer d
join Fact_Orders f on f.Customer_ID=d.Customer_ID
group by d.Customer_ID
order by total_sales desc

--6-Which products have the highest return on profit?
select top 10 d.Product_Name,sum(f.Profit) Total_Profit
from Dim_Product d
join Fact_Orders f on f.Product_ID=d.Product_ID
group by d.Product_Name
order by Total_Profit desc

--7-What is the average shipment delay per mode (using Shipment_Days_Scheduled)?
select m.Shipment_Mode,avg(d.Shipment_Day-m.Shipment_Days_Scheduled) average_shipment_Delays
from Dim_Shipment_Mode m
join Fact_Shipment f on f.Shipment_Mode_ID=m.Shipment_Mode_ID
join Dim_Shipment_Date d on f.Shipment_Date_ID=d.Shipment_Date_ID
group by m.Shipment_Mode
order by average_shipment_Delays desc

--8-How many orders are shipped by each shipment mode?
select m.Shipment_Mode,sum(fo.Order_Quantity) Total_Quantities
from Dim_Shipment_Mode m
join Fact_Shipment fs on fs.Shipment_Mode_ID=m.Shipment_Mode_ID
join Fact_Orders fo on fo.Order_Item_ID=fs.Order_Item_ID
group by m.Shipment_Mode
order by Total_Quantities desc

--9-Which warehouses are  the most orders?
select dw.Warehouse_Country,count(*) Total_Orders
from Dim_Warehouse dw
join Fact_Shipment fs on dw.Warehouse_ID=fs.Warehouse_ID
join Fact_Orders fo on fs.Order_Item_ID=fo.Order_Item_ID
group by dw.Warehouse_Country
order by Total_Orders desc

--10-Compare planned vs. actual shipment days by shipment mode.
select m.Shipment_Mode,avg(m.Shipment_Days_Scheduled) avg_scheduled_days,
avg(d.Shipment_Day) avg_actual_days,avg(d.Shipment_Day-m.Shipment_Days_Scheduled) average_shipment_Delays
from Dim_Shipment_Mode m
join Fact_Shipment f on f.Shipment_Mode_ID=m.Shipment_Mode_ID
join Dim_Shipment_Date d on f.Shipment_Date_ID=d.Shipment_Date_ID
group by m.Shipment_Mode


