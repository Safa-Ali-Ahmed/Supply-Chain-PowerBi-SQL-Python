--Use Database
use final
-- Display Tables
select * from orders_and_shipments

select * from inventory

select * from fulfillment

-----------------------------------------------------Normalization----------------------------------------------------
--first we will break big table int 2 tables one for shipment and the other for orders-- 
--then we will break each one into other tables one of them will be fact and the others will be dim--

---------------------------------------shipment-------------------------------------------------------------------------

-- Dim_Shipment_Date--
CREATE TABLE Dim_Shipment_Date (
    Shipment_Date_ID INT PRIMARY KEY IDENTITY(1,1),
    Shipment_Year INT,
    Shipment_Month INT,
    Shipment_Day INT
);

--Dim_Shipment_Mode--
CREATE TABLE Dim_Shipment_Mode (
    Shipment_Mode_ID INT PRIMARY KEY IDENTITY(1,1),
    Shipment_Mode VARCHAR(50),
    Shipment_Days_Scheduled INT
);

--Dim_Warehouse--
CREATE TABLE Dim_Warehouse (
    Warehouse_ID INT PRIMARY KEY IDENTITY(1,1),
    Warehouse_Country VARCHAR(100)
);

--Fact_Shipment--
CREATE TABLE Fact_Shipment (
    Shipment_ID INT PRIMARY KEY IDENTITY(1,1),
    Warehouse_ID INT FOREIGN KEY REFERENCES Dim_Warehouse(Warehouse_ID),
    Shipment_Date_ID INT FOREIGN KEY REFERENCES Dim_Shipment_Date(Shipment_Date_ID),
    Shipment_Mode_ID INT FOREIGN KEY REFERENCES Dim_Shipment_Mode(Shipment_Mode_ID),
);

----------------------------------orders-------------------------------------------------------------------------------

--Dim_Order_Date--
CREATE TABLE Dim_Order_Date (
    Order_Date_ID INT PRIMARY KEY IDENTITY(1,1),
    Order_Year INT,
    Order_Month INT,
    Order_Day INT,
    Order_Time TIME,
    Order_YearMonth DATE
);

--Dim_Product--
CREATE TABLE Dim_Product (
    Product_ID INT PRIMARY KEY IDENTITY(1,1),
    Product_Name VARCHAR(255),
    Product_Category VARCHAR(100),
    Product_Department VARCHAR(100)
);

--Dim_Customer--
CREATE TABLE Dim_Customer (
    Customer_ID INT PRIMARY KEY,
    Customer_Market VARCHAR(100),
    Customer_Region VARCHAR(100),
    Customer_Country VARCHAR(100)
);

--Fact_Orders--
CREATE TABLE Fact_Orders (
    Order_ID INT,
    Order_Item_ID INT PRIMARY KEY,
    Order_Date_ID INT FOREIGN KEY REFERENCES Dim_Order_Date(Order_Date_ID),
    Product_ID INT FOREIGN KEY REFERENCES Dim_Product(Product_ID),
    Customer_ID INT FOREIGN KEY REFERENCES Dim_Customer(Customer_ID),
    Order_Quantity INT,
    Gross_Sales DECIMAL(10,2),
    Discount TIME,
    Profit DECIMAL(10,2)
);

----------------------------------------------Insert Data---------------------------------------------------------------
------------------------------------------Shipment---------------------------------------------------------------------

--Dim_Shipment_Date--
INSERT INTO Dim_Shipment_Date (Shipment_Year, Shipment_Month, Shipment_Day)
SELECT DISTINCT 
    Shipment_Year, Shipment_Month, Shipment_Day
FROM orders_and_shipments;

select * from Dim_Shipment_Date

--Dim_Shipment_Mode--
INSERT INTO Dim_Shipment_Mode (Shipment_Mode, Shipment_Days_Scheduled)
SELECT DISTINCT 
    Shipment_Mode, Shipment_Days_Scheduled
FROM orders_and_shipments;

select * from Dim_Shipment_Mode

--Dim_Warehouse--
INSERT INTO Dim_Warehouse (Warehouse_Country)
SELECT DISTINCT 
    Warehouse_Country
FROM orders_and_shipments;

select * from Dim_Warehouse

--Fact_Shipment--
INSERT INTO Fact_Shipment (
    Warehouse_ID, Shipment_Date_ID, Shipment_Mode_ID
)
SELECT 
    w.Warehouse_ID,
    d.Shipment_Date_ID,
    m.Shipment_Mode_ID
FROM orders_and_shipments os
JOIN Dim_Warehouse w ON os.Warehouse_Country = w.Warehouse_Country
JOIN Dim_Shipment_Date d ON os.Shipment_Year = d.Shipment_Year 
 AND os.Shipment_Month = d.Shipment_Month 
 AND os.Shipment_Day = d.Shipment_Day
JOIN Dim_Shipment_Mode m ON os.Shipment_Mode = m.Shipment_Mode 
 AND os.Shipment_Days_Scheduled = m.Shipment_Days_Scheduled;

 select * from Fact_Shipment

 -------------------------------------------orders----------------------------------------------

 --Dim_Product--
INSERT INTO Dim_Product (Product_Name, Product_Category, Product_Department)
SELECT DISTINCT 
    Product_Name, Product_Category, Product_Department
FROM orders_and_shipments;

select * from Dim_Product


--Dim_Customer--
INSERT INTO Dim_Customer (Customer_ID, Customer_Market, Customer_Region, Customer_Country)
SELECT DISTINCT 
    Customer_ID, Customer_Market, Customer_Region, Customer_Country
FROM orders_and_shipments;
----------------------we found duplicates so used row_number---------------------------------------

INSERT INTO Dim_Customer (Customer_ID, Customer_Market, Customer_Region, Customer_Country)
SELECT Customer_ID, Customer_Market, Customer_Region, Customer_Country
FROM (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY Customer_ID ORDER BY Customer_ID) AS rn
    FROM orders_and_shipments
) AS sub
WHERE rn = 1;

select * from Dim_Customer

--Dim_Order_Date--
INSERT INTO Dim_Order_Date (Order_Year, Order_Month, Order_Day, Order_Time, Order_YearMonth)
SELECT DISTINCT 
    Order_Year, Order_Month, Order_Day, Order_Time, Order_YearMonth
FROM orders_and_shipments;

select * from Dim_Order_Date

--Fact_Orders--
INSERT INTO Fact_Orders (
    Order_ID, Order_Item_ID, Order_Date_ID, Product_ID,
    Customer_ID, Order_Quantity, Discount, Gross_Sales, Profit
)
SELECT 
    os.Order_ID,
    os.Order_Item_ID,
    d.Order_Date_ID,
    p.Product_ID,
    c.Customer_ID,
    os.Order_Quantity,
    os.Discount,
    os.Gross_Sales,
    os.Profit
FROM orders_and_shipments os
JOIN Dim_Order_Date d
  ON os.Order_Year = d.Order_Year AND os.Order_Month = d.Order_Month 
                                  AND os.Order_Day = d.Order_Day AND os.Order_Time = d.Order_Time
JOIN Dim_Product p
  ON os.Product_Name = p.Product_Name AND os.Product_Category = p.Product_Category 
                                      AND os.Product_Department = p.Product_Department
JOIN Dim_Customer c
  ON os.Customer_ID = c.Customer_ID;

  select * from Fact_Orders

  --------------------------------link 2 tables together by Order_Item_ID--------------------------
ALTER TABLE Fact_Shipment
DROP COLUMN Order_ID;

ALTER TABLE Fact_Shipment
ADD Order_Item_ID INT;
--------------------------------------insert values from raw table----------------------
UPDATE s
SET s.Order_Item_ID = r.Order_Item_ID
FROM Fact_Shipment s
JOIN orders_and_shipments r
  ON s.Warehouse_ID = (
        SELECT Warehouse_ID 
        FROM Dim_Warehouse 
        WHERE Warehouse_Country = r.Warehouse_Country
     )
 AND s.Shipment_Mode_ID = (
        SELECT Shipment_Mode_ID 
        FROM Dim_Shipment_Mode 
        WHERE Shipment_Mode = r.Shipment_Mode 
          AND Shipment_Days_Scheduled = r.Shipment_Days_Scheduled
     )
 AND s.Shipment_Date_ID = (
        SELECT Shipment_Date_ID 
        FROM Dim_Shipment_Date 
        WHERE Shipment_Year = r.Shipment_Year 
          AND Shipment_Month = r.Shipment_Month 
          AND Shipment_Day = r.Shipment_Day
     );

select * from Fact_Shipment
---------------------------make it FK------------------------------------------------
ALTER TABLE Fact_Shipment
ADD CONSTRAINT FK_FactShipment_Order_Item_ID
FOREIGN KEY (Order_Item_ID)
REFERENCES Fact_Orders(Order_Item_ID);

SELECT Order_Item_ID 
FROM Fact_Shipment
------------------------------------link fulfillment and inentory---------------------------------------------
ALTER TABLE fulfillment
ADD Product_ID INT;

ALTER TABLE inventory
ADD Product_ID INT;

--fulfillment--
UPDATE f
SET f.Product_ID = d.Product_ID
FROM fulfillment f
JOIN Dim_Product d
  ON f.Product_Name = d.Product_Name;

-- inventory--
UPDATE i
SET i.Product_ID = d.Product_ID
FROM inventory i
JOIN Dim_Product d
  ON i.Product_Name = d.Product_Name;

  select * from fulfillment

  select Product_ID from fulfillment

  select * from inventory

  select Product_ID from inventory

  ----------------------make FK---------------------------------------------------------------
ALTER TABLE fulfillment
ADD CONSTRAINT fulfillment_Product
FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID);

ALTER TABLE inventory
ADD CONSTRAINT FK_inventory_Product
FOREIGN KEY (Product_ID) REFERENCES Dim_Product(Product_ID);
------------------------------------------------------------------------------------------------------
