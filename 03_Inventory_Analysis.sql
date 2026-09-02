USE HealthcareSupplyChainDB;
GO

/* =========================================================
   1. OVERALL INVENTORY HEALTH

   Business Question:
   What is the overall health and utilization
   of the current inventory?
   ========================================================= */

SELECT
    COUNT(*) AS Total_Inventory_Items,

    SUM(Current_Stock) AS Total_Current_Stock,

    SUM(Max_Capacity) AS Total_Max_Capacity,

    CAST(
        100.0 * SUM(Current_Stock)
        / NULLIF(SUM(Max_Capacity), 0)
        AS DECIMAL(10,2)
    ) AS Stock_Utilization_Percent,

    CAST(
        SUM(Current_Stock * Unit_Cost)
        AS DECIMAL(12,2)
    ) AS Total_Inventory_Value,

    SUM(
        CASE
            WHEN Current_Stock <= Reorder_Level
            THEN 1
            ELSE 0
        END
    ) AS Low_Stock_Items,

    SUM(
        CASE
            WHEN Current_Stock = 0
            THEN 1
            ELSE 0
        END
    ) AS Stockout_Items,

    SUM(
        CASE
            WHEN Current_Stock > Max_Capacity
            THEN 1
            ELSE 0
        END
    ) AS Overstocked_Items

FROM dbo.inventory_stock;


/* =========================================================
   2. MEDICINES AT RISK OF STOCKOUT
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,
    Current_Stock,
    Min_Required,
    Avg_Usage_Per_Day,
    Restock_Lead_Time_Days,
    Stock_Cover_Days,

    CASE
        WHEN Current_Stock = 0
            THEN 'Stockout'

        WHEN Stock_Cover_Days <= Restock_Lead_Time_Days
            THEN 'Critical'

        WHEN Current_Stock <= Min_Required
            THEN 'Low Stock'

        ELSE 'Healthy'
    END AS Stock_Status

FROM dbo.inventory_stock

WHERE
    Current_Stock = 0
    OR Stock_Cover_Days <= Restock_Lead_Time_Days
    OR Current_Stock <= Min_Required

ORDER BY
    CASE
        WHEN Current_Stock = 0 THEN 1
        WHEN Stock_Cover_Days <= Restock_Lead_Time_Days THEN 2
        WHEN Current_Stock <= Min_Required THEN 3
        ELSE 4
    END,
    Stock_Cover_Days ASC;

/* =========================================================
   3. EXPIRING INVENTORY RISK
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,
    Batch_No,
    Expiry_Date,
    Current_Stock,
    Unit_Cost,

    CAST(Current_Stock * Unit_Cost AS DECIMAL(10,2))
        AS Inventory_Value_At_Risk,

    DATEDIFF(DAY, GETDATE(), Expiry_Date)
        AS Days_To_Expiry,

    CASE
        WHEN Expiry_Date < CAST(GETDATE() AS DATE)
            THEN 'Expired'

        WHEN DATEDIFF(DAY, GETDATE(), Expiry_Date) <= 30
            THEN 'Critical'

        WHEN DATEDIFF(DAY, GETDATE(), Expiry_Date) <= 90
            THEN 'Expiring Soon'

        ELSE 'Safe'
    END AS Expiry_Status

FROM dbo.inventory_stock

WHERE
    Expiry_Date <= DATEADD(DAY, 90, CAST(GETDATE() AS DATE))

ORDER BY
    Days_To_Expiry ASC;

/* =========================================================
   4. OVERSTOCKED INVENTORY

   Business Question:
   Which medicines have excess inventory and may be
   tying up unnecessary working capital?
   ========================================================= */

SELECT TOP 15
    Medicine_ID,
    DrugName,
    Current_Stock,
    Max_Capacity,
    Avg_Usage_Per_Day,
    Stock_Cover_Days,

    CAST(
        Current_Stock * Unit_Cost
        AS DECIMAL(12,2)
    ) AS Inventory_Value,

    CAST(
        Current_Stock - (Avg_Usage_Per_Day * 30)
        AS DECIMAL(10,2)
    ) AS Excess_Stock,

    CASE
        WHEN Current_Stock > (Avg_Usage_Per_Day * 60)
            THEN 'High Overstock'

        WHEN Current_Stock > (Avg_Usage_Per_Day * 30)
            THEN 'Moderate Overstock'

        ELSE 'Normal'
    END AS Inventory_Status

FROM dbo.inventory_stock

WHERE
    Current_Stock > (Avg_Usage_Per_Day * 30)

ORDER BY
    Excess_Stock DESC;


/* =========================================================
   5. LOW STOCK & REORDER PRIORITY
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,
    Current_Stock,
    Reorder_Level,
    Avg_Usage_Per_Day,
    Restock_Lead_Time_Days,

    CAST(
        Current_Stock / NULLIF(Avg_Usage_Per_Day, 0)
        AS DECIMAL(10,2)
    ) AS Stock_Cover_Days,

    CASE
        WHEN Current_Stock <= Reorder_Level
             AND Current_Stock / NULLIF(Avg_Usage_Per_Day, 0)
                 <= Restock_Lead_Time_Days
            THEN 'Critical'

        WHEN Current_Stock <= Reorder_Level
            THEN 'High'

        ELSE 'Normal'
    END AS Reorder_Priority

FROM dbo.inventory_stock

WHERE Current_Stock <= Reorder_Level

ORDER BY
    CASE
        WHEN Current_Stock / NULLIF(Avg_Usage_Per_Day, 0)
             <= Restock_Lead_Time_Days
            THEN 1
        ELSE 2
    END,
    Stock_Cover_Days ASC;


/* =========================================================
   6. SUPPLIER COST & RELIABILITY ANALYSIS
   ========================================================= */

SELECT
    Supplier_ID,
    Supplier_Name,
    Region,

    CAST(Cost_Per_Item AS DECIMAL(10,2)) AS Cost_Per_Item,

    CAST(Reliability_Score AS DECIMAL(10,2)) AS Reliability_Score,

    On_Time_Delivery_Rate,

    Avg_Lead_Time_Days,

    CASE
        WHEN Reliability_Score >= 4.5
             AND On_Time_Delivery_Rate >= 90
             AND Cost_Per_Item <= 100
            THEN 'Best Value'

        WHEN Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 75
            THEN 'Reliable'

        ELSE 'Review Required'
    END AS Supplier_Category

FROM dbo.supplier_procurement

ORDER BY
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC,
    Cost_Per_Item ASC;

/* =========================================================
   7. REGIONAL SUPPLIER PERFORMANCE
   ========================================================= */

SELECT
    Region,

    COUNT(DISTINCT Supplier_ID) AS Total_Suppliers,

    CAST(AVG(Reliability_Score) AS DECIMAL(10,2))
        AS Avg_Reliability_Score,

    CAST(AVG(Cost_Per_Item) AS DECIMAL(10,2))
        AS Avg_Cost_Per_Item,

    CAST(AVG(On_Time_Delivery_Rate) AS DECIMAL(10,2))
        AS Avg_On_Time_Delivery_Rate,

    CAST(AVG(Avg_Lead_Time_Days) AS DECIMAL(10,2))
        AS Avg_Lead_Time_Days

FROM dbo.supplier_procurement

GROUP BY Region

ORDER BY
    Avg_On_Time_Delivery_Rate DESC,
    Avg_Reliability_Score DESC;


/* =========================================================
   8. BEST SUPPLIER VALUE ANALYSIS
   ========================================================= */

SELECT TOP 20
    Supplier_ID,
    Supplier_Name,
    Region,

    CAST(Reliability_Score AS DECIMAL(10,2))
        AS Reliability_Score,

    CAST(Cost_Per_Item AS DECIMAL(10,2))
        AS Cost_Per_Item,

    On_Time_Delivery_Rate,
    Avg_Lead_Time_Days,

    CASE
        WHEN Reliability_Score >= 4.5
             AND On_Time_Delivery_Rate >= 90
             AND Cost_Per_Item <= 100
            THEN 'Best Value'

        WHEN Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 85
             AND Cost_Per_Item <= 110
            THEN 'Good Value'

        ELSE 'Review'
    END AS Supplier_Value_Category

FROM dbo.supplier_procurement

ORDER BY
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC,
    Cost_Per_Item ASC;


