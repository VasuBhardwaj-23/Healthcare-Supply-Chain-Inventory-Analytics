USE HealthcareSupplyChainDB;
GO

SELECT 
    'demand_sales' AS Table_Name,
    COUNT(*) AS Row_Count
FROM dbo.demand_sales

UNION ALL

SELECT 
    'consumption_facility',
    COUNT(*)
FROM dbo.consumption_facility

UNION ALL

SELECT 
    'inventory_stock',
    COUNT(*)
FROM dbo.inventory_stock

UNION ALL

SELECT 
    'supplier_procurement',
    COUNT(*)
FROM dbo.supplier_procurement;

/* =========================================
   SQL DATA QUALITY VALIDATION
   ========================================= */

-- 1. Duplicate Order IDs
SELECT 
    'demand_sales' AS Table_Name,
    COUNT(*) AS Duplicate_Order_IDs
FROM (
    SELECT Order_ID
    FROM dbo.demand_sales
    GROUP BY Order_ID
    HAVING COUNT(*) > 1
) d;


-- 2. Duplicate Medicine IDs in Inventory
SELECT 
    'inventory_stock' AS Table_Name,
    COUNT(*) AS Duplicate_Medicine_IDs
FROM (
    SELECT Medicine_ID
    FROM dbo.inventory_stock
    GROUP BY Medicine_ID
    HAVING COUNT(*) > 1
) d;


-- 3. NULL checks: Demand & Sales
SELECT
    SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Order_ID,
    SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Patient_ID,
    SUM(CASE WHEN Medicine_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Medicine_ID,
    SUM(CASE WHEN DrugName IS NULL THEN 1 ELSE 0 END) AS Missing_DrugName,
    SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Date
FROM dbo.demand_sales;


-- 4. Invalid financial values
SELECT
    SUM(CASE WHEN Final_Cost < 0 THEN 1 ELSE 0 END) AS Negative_Final_Cost,
    SUM(CASE WHEN Final_Sales < 0 THEN 1 ELSE 0 END) AS Negative_Final_Sales,
    SUM(CASE WHEN RtnMRP < 0 THEN 1 ELSE 0 END) AS Negative_RtnMRP
FROM dbo.demand_sales;


-- 5. Return quantity validation
SELECT
    SUM(CASE 
        WHEN ReturnQuantity > Quantity 
        THEN 1 ELSE 0 
    END) AS Invalid_Return_Quantity
FROM dbo.demand_sales;


-- 6. Cancelled orders with Delivery Date
SELECT
    COUNT(*) AS Invalid_Cancelled_Delivery_Date
FROM dbo.demand_sales
WHERE Order_Status = 'Cancelled'
  AND Delivery_Date IS NOT NULL;


-- 7. Inventory stock validation
SELECT
    SUM(CASE WHEN Current_Stock < 0 THEN 1 ELSE 0 END) AS Negative_Current_Stock,
    SUM(CASE WHEN Min_Required < 0 THEN 1 ELSE 0 END) AS Negative_Min_Required,
    SUM(CASE WHEN Max_Capacity < 0 THEN 1 ELSE 0 END) AS Negative_Max_Capacity,
    SUM(CASE WHEN Current_Stock > Max_Capacity THEN 1 ELSE 0 END) AS Stock_Above_Capacity,
    SUM(CASE WHEN Expiry_Date < Manufacture_Date THEN 1 ELSE 0 END) AS Invalid_Expiry_Date
FROM dbo.inventory_stock;


-- 8. Consumption Facility validation
SELECT
    SUM(CASE WHEN Daily_Consumption_Units < 0 THEN 1 ELSE 0 END) AS Negative_Consumption,
    SUM(CASE WHEN Out_of_Stock_Days < 0 THEN 1 ELSE 0 END) AS Negative_Stockout_Days,
    SUM(CASE WHEN Wastage_Units < 0 THEN 1 ELSE 0 END) AS Negative_Wastage,
    SUM(CASE WHEN Bed_Days < 0 THEN 1 ELSE 0 END) AS Negative_Bed_Days
FROM dbo.consumption_facility;


-- 9. Supplier Procurement validation
SELECT
    SUM(CASE WHEN Avg_Lead_Time_Days < 0 THEN 1 ELSE 0 END) AS Negative_Lead_Time,
    SUM(CASE WHEN Cost_Per_Item < 0 THEN 1 ELSE 0 END) AS Negative_Cost,
    SUM(CASE 
        WHEN Next_Delivery_Date < Last_Order_Date 
        THEN 1 ELSE 0 
    END) AS Invalid_Delivery_Date,
    SUM(CASE 
        WHEN Reliability_Score < 1 OR Reliability_Score > 5 
        THEN 1 ELSE 0 
    END) AS Invalid_Reliability,
    SUM(CASE 
        WHEN On_Time_Delivery_Rate < 0 OR On_Time_Delivery_Rate > 100 
        THEN 1 ELSE 0 
    END) AS Invalid_Delivery_Rate
FROM dbo.supplier_procurement;

SELECT TOP 20
    Order_ID,
    Order_Date,
    Medicine_ID,
    DrugName,
    Quantity,
    ReturnQuantity,
    Final_Sales,
    RtnMRP,
    Order_Status
FROM dbo.demand_sales
WHERE ReturnQuantity > Quantity
ORDER BY ReturnQuantity DESC;


SELECT COUNT(*) AS Invalid_Returned_Orders
FROM dbo.demand_sales
WHERE Order_Status = 'Returned'
  AND ReturnQuantity <= 0;

SELECT COUNT(*) AS Invalid_Non_Returned_Orders
FROM dbo.demand_sales
WHERE Order_Status <> 'Returned'
  AND ReturnQuantity > 0;

