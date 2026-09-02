USE HealthcareSupplyChainDB;
GO

/* =========================================================
   1. REGION-WISE CONSUMPTION, WASTAGE & STOCK-OUT ANALYSIS
   ========================================================= */

SELECT
    Region,

    COUNT(*) AS Total_Records,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Wastage_Units) AS Total_Wastage_Units,

    CAST(
        100.0 * SUM(Wastage_Units)
        / NULLIF(
            SUM(Daily_Consumption_Units) + SUM(Wastage_Units),
            0
        )
        AS DECIMAL(10,2)
    ) AS Wastage_Rate_Percent,

    SUM(Out_of_Stock_Days) AS Total_Out_of_Stock_Days,

    SUM(Bed_Days) AS Total_Bed_Days

FROM dbo.consumption_facility

GROUP BY Region

ORDER BY
    Total_Consumption_Units DESC;


/* =========================================================
   2. STOCK-OUT EXPOSURE BY REGION
   ========================================================= */

SELECT
    Region,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Out_of_Stock_Days) AS Total_Out_of_Stock_Days,

    CAST(
        SUM(Out_of_Stock_Days) * 1.0
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(10,2)
    ) AS Avg_Out_of_Stock_Days_Per_Record,

    SUM(Wastage_Units) AS Total_Wastage_Units

FROM dbo.consumption_facility

GROUP BY Region

HAVING SUM(Daily_Consumption_Units) > 200

ORDER BY
    Total_Out_of_Stock_Days DESC;

/* =========================================================
   3. REGIONAL MEDICINE WASTAGE ANALYSIS
   ========================================================= */

SELECT
    Region,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Wastage_Units) AS Total_Wastage_Units,

    CAST(
        100.0 * SUM(Wastage_Units)
        / NULLIF(
            SUM(Daily_Consumption_Units) + SUM(Wastage_Units),
            0
        )
        AS DECIMAL(10,2)
    ) AS Wastage_Rate_Percent,

    SUM(Bed_Days) AS Total_Bed_Days

FROM dbo.consumption_facility

GROUP BY Region

HAVING SUM(Wastage_Units) > 50

ORDER BY
    Wastage_Rate_Percent DESC;


/* =========================================================
   4. MEDICINE-WISE CONSUMPTION & WASTAGE ANALYSIS
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Wastage_Units) AS Total_Wastage_Units,

    CAST(
        100.0 * SUM(Wastage_Units)
        / NULLIF(
            SUM(Daily_Consumption_Units) + SUM(Wastage_Units),
            0
        )
        AS DECIMAL(10,2)
    ) AS Wastage_Rate_Percent,

    SUM(Out_of_Stock_Days) AS Total_Out_of_Stock_Days

FROM dbo.consumption_facility

GROUP BY
    Medicine_ID,
    DrugName

HAVING
    SUM(Daily_Consumption_Units) > 20

ORDER BY
    Total_Wastage_Units DESC;


/* =========================================================
   5. REGIONAL RESOURCE UTILIZATION ANALYSIS
   ========================================================= */

/* =========================================================
   5. REGIONAL RESOURCE UTILIZATION ANALYSIS
   ========================================================= */

/* =========================================================
   5. REGIONAL RESOURCE UTILIZATION ANALYSIS
   ========================================================= */

SELECT
    Region,

    SUM(Bed_Days) AS Total_Bed_Days,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    CAST(
        1.0 * SUM(Daily_Consumption_Units)
        / NULLIF(SUM(Bed_Days), 0)
        AS DECIMAL(10,2)
    ) AS Consumption_Per_Bed_Day

FROM dbo.consumption_facility

GROUP BY
    Region

HAVING
    SUM(Bed_Days) > 0

ORDER BY
    Consumption_Per_Bed_Day DESC;


/* =========================================================
   6. HIGH-CONSUMPTION MEDICINES WITH STOCK-OUT EXPOSURE

   Business Question:
   Which medicines have high consumption but also high
   stock-out days, indicating potential demand-supply gaps?
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Out_of_Stock_Days) AS Total_Out_of_Stock_Days,

    SUM(Wastage_Units) AS Total_Wastage_Units,

    CAST(
        100.0 * SUM(Wastage_Units)
        / NULLIF(
            SUM(Daily_Consumption_Units) + SUM(Wastage_Units),
            0
        )
        AS DECIMAL(10,2)
    ) AS Wastage_Rate_Percent

FROM dbo.consumption_facility

GROUP BY
    Medicine_ID,
    DrugName

HAVING
    SUM(Daily_Consumption_Units) > 20
    AND SUM(Out_of_Stock_Days) > 5

ORDER BY
    Total_Out_of_Stock_Days DESC,
    Total_Consumption_Units DESC;


/* =========================================================
   7. INVENTORY PLANNING INEFFICIENCY ANALYSIS

   Business Question:
   Which medicines show both high wastage and high
   stock-out exposure, indicating potential inventory
   planning inefficiencies?
   ========================================================= */

SELECT
    Medicine_ID,
    DrugName,

    CAST(
        SUM(Daily_Consumption_Units)
        AS DECIMAL(10,2)
    ) AS Total_Consumption_Units,

    SUM(Wastage_Units) AS Total_Wastage_Units,

    SUM(Out_of_Stock_Days) AS Total_Out_of_Stock_Days,

    CAST(
        100.0 * SUM(Wastage_Units)
        / NULLIF(
            SUM(Daily_Consumption_Units) + SUM(Wastage_Units),
            0
        )
        AS DECIMAL(10,2)
    ) AS Wastage_Rate_Percent

FROM dbo.consumption_facility

GROUP BY
    Medicine_ID,
    DrugName

HAVING
    SUM(Wastage_Units) > 20
    AND SUM(Out_of_Stock_Days) > 5

ORDER BY
    Wastage_Rate_Percent DESC,
    Total_Out_of_Stock_Days DESC;
