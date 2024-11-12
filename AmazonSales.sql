-- SQLBook: Code
-- Active: 1729355370781127.0.0.1@3306
select * from Locations;
select * from Products;
select * from Orders;

-- 1. List all unique regions in the locations table.
SELECT Distinct Country from Locations;
-- 2. Count the number of orders placed in each country in ascending ranking.
SELECT Country, Count (OrderID) 
FROM Orders
GROUP BY Country
ORDER BY Count (OrderID) ASC;
-- 3. Count the number of orders placed in each region in ascending ranking.
SELECT Locations.Region, Count(Orders.OrderID)
FROM Orders JOIN Locations
ON Orders.Country = Locations.Country
GROUP BY Region
ORDER BY Count (OrderID) ASC;
-- 4. Find the total revenue generated from each sales channel.
SELECT SalesChannel, Sum(TotalRevenue)
FROM Orders
GROUP BY SalesChannel;
-- 5. Create a new column 'OrderYear' in the Orders table and populate it with the year extracted from the 'OrderDate' column.  
ALTER TABLE Orders
ADD COLUMN OrderYear INT;
UPDATE Orders
SET OrderYear = SUBSTRING(OrderDate, 1, 4);
-- 6. Extract the first four characters (YYYY) from 'OrderDate'
SELECT SUBSTRING(OrderDate, 1, 4) AS OrderYear
FROM Orders;
-- 7. Calculate the average unit price of products sold.
SELECT Orders.ItemType, AVG(Products.UnitPrice) AS AvgUnitPrice
FROM Orders JOIN Products
ON Orders.ItemType = Products.ItemType
GROUP BY Orders.ItemType;
-- 8. Identify the top 5 products by total units sold.
SELECT ItemType, SUM(UnitsSold)
FROM Orders
GROUP BY ItemType
ORDER BY SUM(UnitsSOld) DESC LIMIT 5;
-- 9. Determine the total profit for each item type.
SELECT ItemType, SUM(TotalProfit)
FROM Orders
GROUP BY ItemType;
-- 10. Find the order with the highest total revenue.
SELECT OrderID, TotalRevenue
FROM Orders
ORDER BY TotalRevenue DESC LIMIT 1;
-- 11. Calculate the total cost for orders with high priority.
SELECT OrderID, TotalCost, OrderPriority
From Orders
WHERE OrderPriority = "H" OR OrderPriority = "C";
-- 12. List the top 3 countries by total sales revenue.
SELECT Country, SUM(TotalRevenue)
FROM Orders
GROUP BY Country
ORDER BY SUM(TotalRevenue) DESC LIMIT 3;
-- 13. Find the average units sold.
SELECT AVG(UnitsSold) AS AVGUnitsSold
FROM Orders;
-- 14. Identify the month with the highest sales revenue.
SELECT SUBSTRING(OrderDate,6,2) AS Month, SUM(TotalRevenue)
FROM Orders
GROUP BY Month
ORDER BY SUM(TotalRevenue) DESC LIMIT 1;
-- 15. Calculate the total profit margin (Total Profit / Total Revenue) for each order.
SELECT OrderID, TotalProfit/TotalRevenue AS ProfitMargin
FROM Orders;
-- 16. List all orders that were shipped within 5 days of the order date.
SELECT OrderID, OrderDate, ShipDate
FROM Orders
WHERE DATEDIFF(ShipDate, OrderDate) <= 5;
-- 17. Find the total number of orders placed through each sales channel.
SELECT SalesChannel, Count(OrderID)
FROM Orders
GROUP BY SalesChannel;
-- 18. Determine the average order value (Total Revenue) for each region.
SELECT Locations.Region, AVG(TotalRevenue) AS AvgOrderValue
From Orders JOIN Locations
ON Orders.Country = Locations.Country
GROUP BY Region;
-- 19. Identify the product with the highest unit cost.
SELECT ItemType, UnitCost
FROM Products
ORDER BY UnitCost DESC LIMIT 1;
-- 20. Calculate the total revenue generated in each quarter of the year.
SELECT 
    YEAR(OrderDate) AS Year,
    CASE
        WHEN MONTH(OrderDate) BETWEEN 1 AND 3 THEN 1
        WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 2
        WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN 3
        WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN 4
    END AS Quarter,
    SUM(TotalRevenue) AS TotalRevenue
FROM Orders
GROUP BY Year, Quarter
ORDER BY Year, Quarter;
-- 21. Find the total units sold for each country.
SELECT Country, SUM(UnitsSold)
FROM Orders
GROUP BY Country;
-- 22. List all orders where the total profit is greater than $1000.
SELECT OrderID, TotalProfit
FROM Orders
WHERE TotalProfit > 1000;
-- 23. Calculate the average shipping time (Ship Date - Order Date) for each item type.
SELECT ItemType, AVG(DATEDIFF(ShipDate,OrderDate)) AS AvgShippingTime
FROM Orders
GROUP BY ItemType;
-- 24. List all orders with a total cost greater than $5000.
SELECT OrderID, TotalCost
FROM orders
WHERE TotalCost > 5000;
-- 25. Calculate the total profit for each sales channel.
SELECT SalesChannel, SUM(TotalProfit)
FROM Orders
GROUP BY SalesChannel;
-- 26. Analyze the trend of total revenue over the past five years.
-- Create a table or subquery with the years you want to include
WITH Years AS (
    SELECT 2016 AS Year UNION ALL
    SELECT 2017 UNION ALL
    SELECT 2018 UNION ALL
    SELECT 2019 UNION ALL
    SELECT 2020
)
SELECT 
    y.Year, 
    COALESCE(SUM(o.TotalRevenue), 0) AS TotalRevenue
FROM 
    Years y
LEFT JOIN 
    Orders o ON y.Year = YEAR(o.OrderDate)
GROUP BY 
    y.Year
ORDER BY 
    y.Year;
-- 27. Do the sales always rise near the holiday season for all the years?
SELECT 
    YEAR(OrderDate) AS Year,
    CASE
        WHEN MONTH(OrderDate) BETWEEN 1 AND 3 THEN 'Q1_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q2_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN'Q3_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN'Q4_HolidaySeason'
    END AS SeasonType,
   COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY Year, SeasonType
ORDER BY Year, SeasonType;

WITH QuarterlyValues AS (
    SELECT 
    YEAR(OrderDate) AS Year,
    CASE
        WHEN MONTH(OrderDate) BETWEEN 1 AND 3 THEN 'Q1_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 4 AND 6 THEN 'Q2_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 7 AND 9 THEN'Q3_NormalSeason'
        WHEN MONTH(OrderDate) BETWEEN 10 AND 12 THEN'Q4_HolidaySeason'
    END AS SeasonType,
   COUNT(OrderID) AS TotalOrders
FROM Orders
GROUP BY Year, SeasonType
ORDER BY Year, SeasonType
)
SELECT Year, SeasonType, TotalOrders
FROM QuarterlyValues Q
WHERE TotalOrders = (
    SELECT max(TotalOrders)
    FROM QuarterlyValues QV
    WHERE Q.Year = QV.Year
)
ORDER BY Year;
-- 28. Calculate the year-over-year growth rate of total revenue.
WITH YearlyRevenue AS (
    SELECT 
        Year(OrderDate) AS FiscalYear,
        SUM(TotalRevenue) AS TotalRevenue
        FROM Orders
        GROUP BY Year(OrderDate))
SELECT 
    FiscalYear,
    TotalRevenue,
    ((TotalRevenue - Lag(TotalRevenue,1) OVER (ORDER BY FiscalYear)) / LAG(TotalRevenue,1) OVER (ORDER BY FiscalYear)) * 100 AS GrowthRate
FROM YearlyRevenue
ORDER BY FiscalYear;
-- 29. Calculate the year-over-year growth rate of total profit.
WITH YearlyProfit AS (
    SELECT 
        YEAR(OrderDate) AS FiscalYear,
        SUM(TotalProfit) AS TotalProfit
        FROM Orders
        GROUP BY YEAR(OrderDate))
SELECT 
    FiscalYear,
    TotalProfit,
    ((TotalProfit-Lag(TotalProfit,1) OVER (ORDER BY FiscalYear)) / LAG(TotalProfit,1) OVER (ORDER BY FiscalYear)) * 100 AS GrowthRate
    FROM YearlyProfit
    ORDER BY FiscalYear;;
-- 30. Calculate the quarter-over-quarter growth rate of total profit.
With QuarterlyProfit AS (
    SELECT
    YEAR(OrderDate) AS FiscalYear,
    CASE 
        WHEN MONTH(OrderDate) BETWEEN 1 and 3 then "Q1"
        WHEN MONTH(OrderDate) BETWEEN 4 and 6 then "Q2"
        WHEN MONTH(OrderDate) BETWEEN 7 and 9 then "Q3"
        WHEN MONTH(OrderDate) BETWEEN 10 and 12 then "Q4"
        END As Quarter,
        SUM(TotalProfit) AS TotalProfit
    FROM Orders
    GROUP BY FiscalYear, Quarter
    ORDER BY FIscalYear, Quarter
)
SELECT 
    FiscalYear,
    Quarter,
    TotalProfit,
    ((TotalProfit - Lag(TotalProfit,4) OVER (ORDER BY FiscalYear, Quarter)) / Lag(TotalProfit,4) OVER (ORDER BY FiscalYear, Quarter)) * 100 AS QuarterlyGrowthRate
    FROM QuarterlyProfit
    ORDER BY FiscalYear, Quarter;

-- 31. Calculate the month-over-month growth rate of total profit.
WITH MonthlyProfit AS (
    SELECT Year(OrderDate) AS FiscalYear,
        MONTH(OrderDate) AS Month,
        SUM(TotalProfit) AS TotalProfit
        FROM Orders
        GROUP BY FiscalYear, Month
)
SELECT
    FiscalYear,
    Month,
    TotalProfit,
    ((TotalProfit-Lag(TotalProfit,12) OVER (ORDER BY FiscalYear, Month) / Lag(TotalProfit,12) OVER (ORDER BY FiscalYear, Month)))
    FROM MonthlyProfit
    ORDER BY FiscalYear, Month;

-- 32. Identify the top 5 products with the highest profit margin.
SELECT ItemType, (TotalProfit/TotalRevenue) AS ProfitMargin
FROM Orders
ORDER BY ProfitMargin;
ORDER BY ProfitMargin DESC LIMIT 5;