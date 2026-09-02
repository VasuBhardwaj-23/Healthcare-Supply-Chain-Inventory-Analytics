USE HealthcareSupplyChainDB;
GO

/* =====================================================
   02 - DEMAND & SALES ANALYSIS
   ===================================================== */


/* 1. Overall Business Performance */
SELECT
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    COUNT(DISTINCT Patient_ID) AS Total_Patients,
    COUNT(DISTINCT Medicine_ID) AS Total_Medicines,

    CAST(SUM(Final_Sales) AS DECIMAL(18,2)) AS Total_Sales,
    CAST(SUM(Final_Cost) AS DECIMAL(18,2)) AS Total_Cost,
    CAST(SUM(Final_Sales - Final_Cost) AS DECIMAL(18,2)) AS Total_Margin

FROM dbo.demand_sales;

/* =====================================================
   2. Order Status & Return Performance
   ===================================================== */

SELECT
    Order_Status,

    COUNT(*) AS Total_Orders,

    CAST(SUM(Final_Sales) AS DECIMAL(18,2)) AS Total_Sales,

    SUM(ReturnQuantity) AS Total_Returned_Units,

    SUM(
        CASE
            WHEN ReturnQuantity > 0 THEN 1
            ELSE 0
        END
    ) AS Returned_Orders

FROM dbo.demand_sales
GROUP BY Order_Status
ORDER BY Total_Orders DESC;


/* Overall Order Status KPIs */

SELECT
    COUNT(*) AS Total_Orders,

    SUM(CASE
        WHEN Order_Status = 'Returned' THEN 1
        ELSE 0
    END) AS Returned_Orders,

    SUM(CASE
        WHEN Order_Status = 'Cancelled' THEN 1
        ELSE 0
    END) AS Cancelled_Orders,

    SUM(ReturnQuantity) AS Total_Returned_Units,

    CAST(
        100.0 * SUM(CASE
            WHEN Order_Status = 'Returned' THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(18,2)
    ) AS Return_Rate_Percent,

    CAST(
        100.0 * SUM(CASE
            WHEN Order_Status = 'Cancelled' THEN 1
            ELSE 0
        END) / COUNT(*)
        AS DECIMAL(18,2)
    ) AS Cancellation_Rate_Percent

FROM dbo.demand_sales;


/* =====================================================
   3. Monthly Sales Trend & Month-over-Month Growth
   ===================================================== */

WITH Monthly_Sales AS
(
    SELECT
        YEAR(Order_Date) AS Order_Year,
        MONTH(Order_Date) AS Order_Month,
        DATENAME(MONTH, Order_Date) AS Month_Name,

        COUNT(DISTINCT Order_ID) AS Total_Orders,

        CAST(
            SUM(Final_Sales) AS DECIMAL(18,2)
        ) AS Total_Sales,

        CAST(
            SUM(Final_Cost) AS DECIMAL(18,2)
        ) AS Total_Cost,

        CAST(
            SUM(Final_Sales - Final_Cost) AS DECIMAL(18,2)
        ) AS Total_Margin

    FROM dbo.demand_sales

    GROUP BY
        YEAR(Order_Date),
        MONTH(Order_Date),
        DATENAME(MONTH, Order_Date)
),

Monthly_Trend AS
(
    SELECT
        *,
        
        LAG(Total_Sales) OVER (
            ORDER BY Order_Year, Order_Month
        ) AS Previous_Month_Sales

    FROM Monthly_Sales
)

SELECT
    Order_Year,
    Order_Month,
    Month_Name,
    Total_Orders,
    Total_Sales,
    Total_Cost,
    Total_Margin,

    CAST(
        CASE
            WHEN Previous_Month_Sales IS NULL
                OR Previous_Month_Sales = 0
            THEN NULL

            ELSE
                ((Total_Sales - Previous_Month_Sales)
                * 100.0 / Previous_Month_Sales)
        END
        AS DECIMAL(18,2)
    ) AS MoM_Growth_Percent

FROM Monthly_Trend

ORDER BY
    Order_Year,
    Order_Month;

/* =========================================================
   4. TOP PERFORMING MEDICINES BY SALES & PROFIT
   ========================================================= */

SELECT TOP 10
    Medicine_ID,
    MAX(DrugName) AS Drug_Name,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,
    CAST(SUM(Final_Sales) AS DECIMAL(18,2)) AS Total_Sales,
    CAST(SUM(Final_Cost) AS DECIMAL(18,2)) AS Total_Cost,
    CAST(SUM(Final_Sales - Final_Cost) AS DECIMAL(18,2)) AS Total_Profit,
    CAST(
        SUM(Final_Sales - Final_Cost) * 100.0 /
        NULLIF(SUM(Final_Sales), 0)
        AS DECIMAL(10,2)
    ) AS Profit_Margin_Percent
FROM dbo.demand_sales
GROUP BY Medicine_ID
ORDER BY Total_Profit DESC;

/* =========================================================
   5. DEPARTMENT-WISE SALES & PROFIT PERFORMANCE
   ========================================================= */

SELECT
    Dept AS Department,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,
    CAST(SUM(Final_Sales) AS DECIMAL(18,2)) AS Total_Sales,
    CAST(SUM(Final_Cost) AS DECIMAL(18,2)) AS Total_Cost,
    CAST(
        SUM(Final_Sales - Final_Cost)
        AS DECIMAL(18,2)
    ) AS Total_Profit,
    CAST(
        SUM(Final_Sales - Final_Cost) * 100.0
        / NULLIF(SUM(Final_Sales), 0)
        AS DECIMAL(10,2)
    ) AS Profit_Margin_Percent
FROM dbo.demand_sales
GROUP BY Dept
ORDER BY Total_Profit DESC;

/* =========================================================
   6. RETURN & CANCELLATION IMPACT ANALYSIS
   ========================================================= */

SELECT
    Order_Status,
    COUNT(DISTINCT Order_ID) AS Total_Orders,

    CAST(SUM(Final_Sales) AS DECIMAL(18,2)) AS Total_Sales,

    SUM(ReturnQuantity) AS Total_Returned_Units,

    COUNT(DISTINCT CASE
        WHEN ReturnQuantity > 0
        THEN Order_ID
    END) AS Returned_Orders,

    CAST(
        COUNT(DISTINCT CASE
            WHEN ReturnQuantity > 0
            THEN Order_ID
        END) * 100.0
        / NULLIF(COUNT(DISTINCT Order_ID), 0)
        AS DECIMAL(10,2)
    ) AS Return_Rate_Percent

FROM dbo.demand_sales
GROUP BY Order_Status
ORDER BY Total_Orders DESC;

/* =========================================================
   7. SPECIALISATION-WISE SALES & PROFIT PERFORMANCE
   ========================================================= */

SELECT
    Specialisation,
    COUNT(DISTINCT Order_ID) AS Total_Orders,
    SUM(Quantity) AS Total_Units_Sold,

    CAST(
        SUM(Final_Sales)
        AS DECIMAL(18,2)
    ) AS Total_Sales,

    CAST(
        SUM(Final_Cost)
        AS DECIMAL(18,2)
    ) AS Total_Cost,

    CAST(
        SUM(Final_Sales - Final_Cost)
        AS DECIMAL(18,2)
    ) AS Total_Profit,

    CAST(
        SUM(Final_Sales - Final_Cost) * 100.0
        / NULLIF(SUM(Final_Sales), 0)
        AS DECIMAL(10,2)
    ) AS Profit_Margin_Percent

FROM dbo.demand_sales

GROUP BY Specialisation

ORDER BY Total_Profit DESC;


/* =========================================================
   8. INVENTORY STOCKOUT RISK ANALYSIS
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,
    Current_Stock,
    Min_Required,
    Avg_Usage_Per_Day,
    Stock_Cover_Days,
    Restock_Lead_Time_Days,
    Reorder_Level,

    CASE
        WHEN Current_Stock <= Min_Required
             OR Stock_Cover_Days <= Restock_Lead_Time_Days
            THEN 'High Risk'

        WHEN Current_Stock <= Reorder_Level
             OR Stock_Cover_Days <= Restock_Lead_Time_Days + 5
            THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS Stock_Risk

FROM dbo.inventory_stock

ORDER BY
    CASE
        WHEN Current_Stock <= Min_Required
             OR Stock_Cover_Days <= Restock_Lead_Time_Days
            THEN 1
        WHEN Current_Stock <= Reorder_Level
             OR Stock_Cover_Days <= Restock_Lead_Time_Days + 5
            THEN 2
        ELSE 3
    END,
    Stock_Cover_Days ASC;


    /* =========================================================
   9. SUPPLIER PERFORMANCE ANALYSIS
   ========================================================= */

SELECT
    Supplier_ID,
    Supplier_Name,
    Region,
    Avg_Lead_Time_Days,

    CAST(Reliability_Score AS DECIMAL(10,2)) AS Reliability_Score,

    CAST(Cost_Per_Item AS DECIMAL(10,2)) AS Cost_Per_Item,

    On_Time_Delivery_Rate,

    CASE
        WHEN Reliability_Score >= 4.5
             AND On_Time_Delivery_Rate >= 90
            THEN 'Excellent'

        WHEN Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 75
            THEN 'Good'

        ELSE 'Needs Attention'
    END AS Supplier_Performance

FROM dbo.supplier_procurement

ORDER BY
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC;


/* =========================================================
   10. HIGH-SALES, LOW-MARGIN MEDICINES

   Business Question:
   Which medicines generate high sales but relatively
   low profit margins?
   ========================================================= */

WITH Medicine_Performance AS
(
    SELECT
        Medicine_ID,
        DrugName,

        SUM(Final_Sales) AS Total_Sales,
        SUM(Final_Cost) AS Total_Cost,

        SUM(Final_Sales - Final_Cost) AS Total_Profit,

        CAST(
            100.0 * SUM(Final_Sales - Final_Cost)
            / NULLIF(SUM(Final_Sales), 0)
            AS DECIMAL(10,2)
        ) AS Profit_Margin_Percent

    FROM dbo.demand_sales

    GROUP BY
        Medicine_ID,
        DrugName
)

SELECT TOP 15
    Medicine_ID,
    DrugName,

    CAST(Total_Sales AS DECIMAL(12,2)) AS Total_Sales,
    CAST(Total_Cost AS DECIMAL(12,2)) AS Total_Cost,
    CAST(Total_Profit AS DECIMAL(12,2)) AS Total_Profit,
    Profit_Margin_Percent

FROM Medicine_Performance
WHERE Profit_Margin_Percent < 30
ORDER BY
    Total_Sales DESC;

