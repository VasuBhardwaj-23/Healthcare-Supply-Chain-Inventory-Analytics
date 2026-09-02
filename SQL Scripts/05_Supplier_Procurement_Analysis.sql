use HealthcareSupplyChainDB

/* =========================================================
   1. SUPPLIER PERFORMANCE OVERVIEW

   Business Question:
   Which suppliers are performing best based on reliability,
   cost, delivery performance, and lead time?
   ========================================================= */

SELECT
    Supplier_ID,
    Supplier_Name,
    Region,

    Avg_Lead_Time_Days,

    CAST(
        Reliability_Score AS DECIMAL(10,2)
    ) AS Reliability_Score,

    CAST(
        Cost_Per_Item AS DECIMAL(10,2)
    ) AS Cost_Per_Item,

    On_Time_Delivery_Rate,

    CASE
        WHEN Reliability_Score >= 4.5
             AND On_Time_Delivery_Rate >= 90
             AND Avg_Lead_Time_Days <= 10
            THEN 'Excellent'

        WHEN Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 75
             THEN 'Good'

        ELSE 'Needs Attention'
    END AS Supplier_Performance

FROM dbo.supplier_procurement

ORDER BY
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC,
    Avg_Lead_Time_Days ASC;


/* =========================================================
   2. REGION-WISE SUPPLIER PERFORMANCE

   Business Question:
   Which regions have the strongest supplier network in terms
   of reliability, cost, on-time delivery, and lead time?
   ========================================================= */

SELECT
    Region,

    COUNT(*) AS Total_Suppliers,

    CAST(
        AVG(Reliability_Score)
        AS DECIMAL(10,2)
    ) AS Avg_Reliability_Score,

    CAST(
        AVG(Cost_Per_Item)
        AS DECIMAL(10,2)
    ) AS Avg_Cost_Per_Item,

    CAST(
        AVG(On_Time_Delivery_Rate)
        AS DECIMAL(10,2)
    ) AS Avg_On_Time_Delivery_Rate,

    CAST(
        AVG(Avg_Lead_Time_Days)
        AS DECIMAL(10,2)
    ) AS Avg_Lead_Time_Days

FROM dbo.supplier_procurement

GROUP BY
    Region

ORDER BY
    Avg_On_Time_Delivery_Rate DESC,
    Avg_Reliability_Score DESC;


/* =========================================================
   3. BEST-VALUE SUPPLIER ANALYSIS

   Business Question:
   Which suppliers provide the best value by balancing low
   procurement cost, high reliability, and strong
   on-time delivery performance?
   ========================================================= */

SELECT TOP 20
    Supplier_ID,
    Supplier_Name,
    Region,

    CAST(
        Reliability_Score
        AS DECIMAL(10,2)
    ) AS Reliability_Score,

    CAST(
        Cost_Per_Item
        AS DECIMAL(10,2)
    ) AS Cost_Per_Item,

    On_Time_Delivery_Rate,

    Avg_Lead_Time_Days,

    CASE
        WHEN Reliability_Score >= 4.5
             AND On_Time_Delivery_Rate >= 90
             AND Cost_Per_Item <= 100
            THEN 'Best Value'

        WHEN Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 80
             AND Cost_Per_Item <= 110
            THEN 'Good Value'

        ELSE 'Review'
    END AS Supplier_Value_Category

FROM dbo.supplier_procurement

ORDER BY
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC,
    Cost_Per_Item ASC;


/* =========================================================
   4. SUPPLIER DELIVERY RISK ANALYSIS

   Business Question:
   Which suppliers have long lead times combined with weak
   on-time delivery, indicating potential supply-chain risk?
   ========================================================= */

SELECT
    Supplier_ID,
    Supplier_Name,
    Region,

    Avg_Lead_Time_Days,

    CAST(
        Reliability_Score
        AS DECIMAL(10,2)
    ) AS Reliability_Score,

    CAST(
        Cost_Per_Item
        AS DECIMAL(10,2)
    ) AS Cost_Per_Item,

    On_Time_Delivery_Rate,

    CASE
        WHEN Avg_Lead_Time_Days >= 12
             AND On_Time_Delivery_Rate < 80
            THEN 'High Risk'

        WHEN Avg_Lead_Time_Days >= 10
             AND On_Time_Delivery_Rate < 90
            THEN 'Medium Risk'

        ELSE 'Low Risk'
    END AS Supply_Risk

FROM dbo.supplier_procurement

WHERE
    Avg_Lead_Time_Days >= 10
    AND On_Time_Delivery_Rate < 90

ORDER BY
    CASE
        WHEN Avg_Lead_Time_Days >= 12
             AND On_Time_Delivery_Rate < 80
            THEN 1
        WHEN Avg_Lead_Time_Days >= 10
             AND On_Time_Delivery_Rate < 90
            THEN 2
        ELSE 3
    END,
    Avg_Lead_Time_Days DESC,
    On_Time_Delivery_Rate ASC;


/* =========================================================
   5. COST-EFFICIENT SUPPLIER ANALYSIS

   Business Question:
   Which suppliers offer the lowest cost per item while
   maintaining acceptable reliability and delivery performance?
   ========================================================= */

SELECT TOP 20
    Supplier_ID,
    Supplier_Name,
    Region,

    CAST(
        Cost_Per_Item
        AS DECIMAL(10,2)
    ) AS Cost_Per_Item,

    CAST(
        Reliability_Score
        AS DECIMAL(10,2)
    ) AS Reliability_Score,

    On_Time_Delivery_Rate,

    Avg_Lead_Time_Days,

    CASE
        WHEN Cost_Per_Item <= 90
             AND Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 85
            THEN 'Highly Cost Efficient'

        WHEN Cost_Per_Item <= 100
             AND Reliability_Score >= 4.0
             AND On_Time_Delivery_Rate >= 80
            THEN 'Cost Efficient'

        ELSE 'Review'
    END AS Cost_Efficiency_Category

FROM dbo.supplier_procurement

WHERE
    Reliability_Score >= 4.0
    AND On_Time_Delivery_Rate >= 80

ORDER BY
    Cost_Per_Item ASC,
    Reliability_Score DESC,
    On_Time_Delivery_Rate DESC;


/* =========================================================
   6. REGIONAL SUPPLIER DELIVERY PERFORMANCE

   Business Question:
   Which regions have suppliers with the strongest on-time
   delivery performance, and how reliable are those suppliers
   on average?
   ========================================================= */

SELECT
    Region,

    COUNT(*) AS Total_Suppliers,

    CAST(
        AVG(On_Time_Delivery_Rate)
        AS DECIMAL(10,2)
    ) AS Avg_On_Time_Delivery_Rate,

    CAST(
        AVG(Reliability_Score)
        AS DECIMAL(10,2)
    ) AS Avg_Reliability_Score,

    CAST(
        AVG(Avg_Lead_Time_Days)
        AS DECIMAL(10,2)
    ) AS Avg_Lead_Time_Days

FROM dbo.supplier_procurement

GROUP BY
    Region

ORDER BY
    Avg_On_Time_Delivery_Rate DESC,
    Avg_Reliability_Score DESC;
