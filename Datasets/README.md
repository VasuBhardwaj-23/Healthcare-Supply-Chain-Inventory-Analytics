# Dataset Documentation

This project uses four cleaned datasets to analyze healthcare demand, facility consumption, inventory health, and supplier performance.

The datasets support the complete analytical workflow from data preparation and SQL Server analysis to Power BI reporting.

## Dataset Overview

| Dataset | Records | Fields | Primary Use |
|---|---:|---:|---|
| Demand & Sales | 14,218 | 16 | Orders, demand, sales, returns, and delivery analysis |
| Facility Consumption | 11,111 | 9 | Consumption, stock-out exposure, wastage, and facility usage |
| Inventory Stock | 841 | 16 | Stock levels, reorder requirements, coverage, and expiry risk |
| Supplier Procurement | 538 | 9 | Supplier cost, lead time, reliability, and delivery performance |

---

## 1. Demand & Sales

**File:** `demand_sales_cleaned.csv`  
**Records:** 14,218  
**Fields:** 16  
**Order period:** 1 January 2024 to 27 December 2024

### Fields

- `Order_ID`
- `Order_Date`
- `Patient_ID`
- `Dept`
- `Specialisation`
- `Medicine_ID`
- `DrugName`
- `Formulation`
- `Quantity`
- `ReturnQuantity`
- `Final_Cost`
- `Final_Sales`
- `RtnMRP`
- `Order_Status`
- `Delivery_Date`
- `Lead_Time_Days`

### Key Metrics

- Total sales: **$3.33M**
- Total ordered quantity: **31,731 units**
- Average order value: **$234.04**
- Delivered orders: **11,310**
- Returned orders: **1,681**
- Cancelled orders: **633**
- Pending orders: **594**

### Business Use

This dataset supports analysis of:

- Sales performance
- Order volume
- Demand by department
- Demand by medicine and category
- Monthly demand patterns
- Average order value
- Return behavior
- Order and delivery status

This dataset is the primary source for the Demand Analytics and sales-related KPIs in the Power BI report.

---

## 2. Facility Consumption

**File:** `consumption_facility_cleaned.csv`  
**Records:** 11,111  
**Fields:** 9

### Fields

- `Patient_ID`
- `Region`
- `Medicine_ID`
- `DrugName`
- `Daily_Consumption_Units`
- `Out_of_Stock_Days`
- `Wastage_Units`
- `Bed_Days`
- `Supplies_Used`

### Key Metrics

- Patients represented: **499**
- Medicines represented: **841**
- Regions represented: **19**
- Daily consumption recorded: **7,421 units**
- Out-of-stock days recorded: **624**
- Wastage recorded: **4,151 units**
- Bed days recorded: **81,282**

### Business Use

The facility consumption data was used to understand operational usage across facilities, including:

- Medicine consumption
- Out-of-stock exposure
- Wastage
- Bed-day utilization
- Supply usage
- Regional consumption patterns

The dataset was profiled and cleaned before SQL Server analysis. SQL queries were used to examine consumption and operational patterns and to support the broader understanding of demand and inventory behavior.

### Reporting Scope

Facility consumption was analyzed as part of the **SQL Server analytical layer** rather than as a separate Power BI page.

The Power BI reporting layer was focused on the main management reporting areas:

- Demand
- Inventory
- Supplier performance

This approach keeps the dashboard focused while retaining facility consumption analysis within the underlying analytical workflow.

---

## 3. Inventory Stock

**File:** `inventory_stock_cleaned.csv`  
**Records:** 841  
**Fields:** 16

### Fields

- `Medicine_ID`
- `DrugName`
- `Formulation`
- `Category`
- `Batch_No`
- `Manufacture_Date`
- `Expiry_Date`
- `Current_Stock`
- `Min_Required`
- `Max_Capacity`
- `Unit_Cost`
- `Avg_Usage_Per_Day`
- `Restock_Lead_Time_Days`
- `Reorder_Level`
- `Stock_Cover_Days`
- `Vendor_ID`

### Key Metrics

- Current stock: **224,674 units**
- Average stock cover: **49.1 days**
- Items at or below reorder level: **29**
- Items below minimum required stock: **22**
- Product categories represented: **5**

### Business Use

This dataset supports analysis of:

- Current stock levels
- Reorder requirements
- Stock coverage
- Low-stock exposure
- Inventory health
- Expiry risk
- Stock levels by category
- Inventory capacity and usage

This dataset is the primary source for the Inventory Analytics page in the Power BI report.

---

## 4. Supplier Procurement

**File:** `supplier_procurement_cleaned.csv`  
**Records:** 538  
**Fields:** 9

### Fields

- `Supplier_ID`
- `Supplier_Name`
- `Region`
- `Avg_Lead_Time_Days`
- `Reliability_Score`
- `Cost_Per_Item`
- `Last_Order_Date`
- `Next_Delivery_Date`
- `On_Time_Delivery_Rate`

### Key Metrics

- Suppliers: **538**
- Average cost per item: **$101.37**
- Average lead time: **8.4 days**
- Average on-time delivery rate: **82.13%**
- Average reliability score: **4.3 / 5**
- Suppliers meeting the 90% on-time threshold: **115**
- Suppliers below the 90% threshold: **423**

### Business Use

This dataset supports analysis of:

- Supplier performance
- Procurement cost
- Lead time
- On-time delivery performance
- Supplier reliability
- Regional supplier performance
- Cost versus supplier performance

This dataset is the primary source for the Suppliers Analytics page in the Power BI report.

---

## Data Quality Checks

The cleaned datasets were reviewed before analytical use.

Key checks included:

- Record and field validation
- Duplicate checks
- Missing-value assessment
- Data-type validation
- Date-field validation
- Field standardization
- Business-rule validation

The final cleaned files contain no duplicate rows.

Missing values were reviewed based on their business context rather than being replaced without justification. For example, the Demand & Sales dataset contains **633 missing delivery dates**, corresponding to cancelled orders.

---

## Data Preparation Workflow

The analytical workflow follows these stages:

**Data Profiling → Data Cleaning → SQL Server Analysis → Power BI Data Model → Dashboard Reporting**

### Python and Jupyter

Used for:

- Data profiling
- Data quality checks
- Data cleaning
- Field standardization
- Initial validation

Notebooks:

- `01_Data_Profiling.ipynb`
- `02_Data_Cleaning.ipynb`

### SQL Server

Used for:

- Business-oriented analysis
- KPI calculations
- Demand analysis
- Facility consumption analysis
- Inventory analysis
- Supplier analysis
- Data validation

### Power BI

Used for the final reporting layer:

1. Executive Overview
2. Demand Analytics
3. Inventory Analytics
4. Suppliers Analytics
5. Business Insights & Recommendations

---

## Data Scope

The four datasets provide a connected view of the healthcare supply chain across:

**Demand → Consumption → Inventory → Suppliers**

The Power BI report focuses on the primary management reporting areas, while SQL Server provides deeper operational analysis supporting the overall business understanding.
