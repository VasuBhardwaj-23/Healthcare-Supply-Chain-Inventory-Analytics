\# Dataset Documentation



This project uses four cleaned datasets to analyze healthcare demand, facility consumption, inventory health, and supplier performance.



The datasets support an end-to-end workflow from data preparation and SQL Server analysis to Power BI reporting.



\## Dataset Overview



| Dataset | Records | Fields | Primary Use |

|---|---:|---:|---|

| Demand \& Sales | 14,218 | 16 | Orders, demand, sales, returns, and delivery analysis |

| Facility Consumption | 11,111 | 9 | Consumption, stock-out exposure, wastage, and facility usage |

| Inventory Stock | 841 | 16 | Stock levels, reorder requirements, coverage, and expiry risk |

| Supplier Procurement | 538 | 9 | Supplier cost, lead time, reliability, and delivery performance |



\---



\## 1. Demand \& Sales



\*\*File:\*\* `demand\_sales\_cleaned.csv`  

\*\*Records:\*\* 14,218  

\*\*Fields:\*\* 16  

\*\*Order period:\*\* 1 January 2024 to 27 December 2024



\### Fields



\- `Order\_ID`

\- `Order\_Date`

\- `Patient\_ID`

\- `Dept`

\- `Specialisation`

\- `Medicine\_ID`

\- `DrugName`

\- `Formulation`

\- `Quantity`

\- `ReturnQuantity`

\- `Final\_Cost`

\- `Final\_Sales`

\- `RtnMRP`

\- `Order\_Status`

\- `Delivery\_Date`

\- `Lead\_Time\_Days`



\### Key Data Points



\- Total sales: \*\*$3.33M\*\*

\- Total ordered quantity: \*\*31,731 units\*\*

\- Average order value: \*\*$234.04\*\*

\- Delivered orders: \*\*11,310\*\*

\- Returned orders: \*\*1,681\*\*

\- Cancelled orders: \*\*633\*\*

\- Pending orders: \*\*594\*\*



\### Business Use



This dataset supports analysis of:



\- Sales performance

\- Order volume

\- Demand by department

\- Demand by medicine and category

\- Monthly demand patterns

\- Average order value

\- Return behavior

\- Order and delivery status



The dataset is the primary source for the Demand Analytics and sales-related KPIs in the Power BI report.



\---



\## 2. Facility Consumption



\*\*File:\*\* `consumption\_facility\_cleaned.csv`  

\*\*Records:\*\* 11,111  

\*\*Fields:\*\* 9



\### Fields



\- `Patient\_ID`

\- `Region`

\- `Medicine\_ID`

\- `DrugName`

\- `Daily\_Consumption\_Units`

\- `Out\_of\_Stock\_Days`

\- `Wastage\_Units`

\- `Bed\_Days`

\- `Supplies\_Used`



\### Key Data Points



\- Patients represented: \*\*499\*\*

\- Medicines represented: \*\*841\*\*

\- Regions represented: \*\*19\*\*

\- Daily consumption recorded: \*\*7,421 units\*\*

\- Out-of-stock days recorded: \*\*624\*\*

\- Wastage recorded: \*\*4,151 units\*\*

\- Bed days recorded: \*\*81,282\*\*



\### Business Use



The facility consumption data was used to understand operational usage across facilities, including:



\- Medicine consumption

\- Out-of-stock exposure

\- Wastage

\- Bed-day utilization

\- Supply usage

\- Regional consumption patterns



The dataset was profiled and cleaned before SQL Server analysis. SQL queries were used to examine consumption and operational patterns and to support the broader understanding of demand and inventory behavior.



\### Reporting Scope



Facility consumption was analyzed as part of the \*\*SQL Server analytical layer\*\* rather than as a separate Power BI page.



The Power BI reporting layer was intentionally focused on the management-level decision areas that required consolidated visual reporting:



\- Demand

\- Inventory

\- Supplier performance



This keeps the dashboard focused while retaining facility consumption analysis within the underlying analytical workflow.



\---



\## 3. Inventory Stock



\*\*File:\*\* `inventory\_stock\_cleaned.csv`  

\*\*Records:\*\* 841  

\*\*Fields:\*\* 16



\### Fields



\- `Medicine\_ID`

\- `DrugName`

\- `Formulation`

\- `Category`

\- `Batch\_No`

\- `Manufacture\_Date`

\- `Expiry\_Date`

\- `Current\_Stock`

\- `Min\_Required`

\- `Max\_Capacity`

\- `Unit\_Cost`

\- `Avg\_Usage\_Per\_Day`

\- `Restock\_Lead\_Time\_Days`

\- `Reorder\_Level`

\- `Stock\_Cover\_Days`

\- `Vendor\_ID`



\### Key Data Points



\- Current stock: \*\*224,674 units\*\*

\- Average stock cover: \*\*49.1 days\*\*

\- Items at or below reorder level: \*\*29\*\*

\- Items below minimum required stock: \*\*22\*\*

\- Product categories represented: \*\*5\*\*



\### Business Use



This dataset supports analysis of:



\- Current stock levels

\- Reorder requirements

\- Stock coverage

\- Low-stock exposure

\- Inventory health

\- Expiry risk

\- Stock levels by category

\- Inventory capacity and usage



The dataset is the primary source for the Inventory Analytics page in the Power BI report.



\---



\## 4. Supplier Procurement



\*\*File:\*\* `supplier\_procurement\_cleaned.csv`  

\*\*Records:\*\* 538  

\*\*Fields:\*\* 9



\### Fields



\- `Supplier\_ID`

\- `Supplier\_Name`

\- `Region`

\- `Avg\_Lead\_Time\_Days`

\- `Reliability\_Score`

\- `Cost\_Per\_Item`

\- `Last\_Order\_Date`

\- `Next\_Delivery\_Date`

\- `On\_Time\_Delivery\_Rate`



\### Key Data Points



\- Suppliers: \*\*538\*\*

\- Average cost per item: \*\*$101.37\*\*

\- Average lead time: \*\*8.4 days\*\*

\- Average on-time delivery rate: \*\*82.13%\*\*

\- Average reliability score: \*\*4.3 / 5\*\*

\- Suppliers meeting the 90% on-time threshold: \*\*115\*\*

\- Suppliers below the 90% threshold: \*\*423\*\*



\### Business Use



This dataset supports analysis of:



\- Supplier performance

\- Procurement cost

\- Lead time

\- On-time delivery performance

\- Supplier reliability

\- Regional supplier performance

\- Cost versus supplier performance



The dataset is the primary source for the Suppliers Analytics page in the Power BI report.



\---



\## Data Quality Checks



The cleaned datasets were reviewed before analytical use.



Key checks included:



\- Record and field validation

\- Duplicate checks

\- Missing-value assessment

\- Data-type validation

\- Date-field validation

\- Field standardization

\- Business-rule validation



The final cleaned files contain no duplicate rows.



Some missing values remain where they have an analytical meaning or require business interpretation. For example, the Demand \& Sales dataset contains \*\*633 missing delivery dates\*\*, corresponding to the cancelled-order records. The cleaned Inventory and Facility Consumption datasets also retain a small number of missing `DrugName` values rather than introducing unsupported replacements.



\---



\## Data Preparation Workflow



The preparation and analysis workflow was:



\*\*Data Profiling → Data Cleaning → SQL Server Analysis → Power BI Data Model → Dashboard Reporting\*\*



\### Python / Jupyter



Used for:



\- Data profiling

\- Data quality checks

\- Cleaning and standardization

\- Initial validation



Notebooks:



\- `01\_Data\_Profiling.ipynb`

\- `02\_Data\_Cleaning.ipynb`



\### SQL Server



Used for:



\- Business-oriented analysis

\- KPI calculations

\- Consumption analysis

\- Inventory analysis

\- Supplier analysis

\- Data validation



\### Power BI



Used for the final reporting layer:



1\. Executive Overview

2\. Demand Analytics

3\. Inventory Analytics

4\. Suppliers Analytics

5\. Business Insights \& Recommendations



\---



\## Data Scope



The four datasets provide a view of the healthcare supply chain across:



\*\*Demand → Consumption → Inventory → Suppliers\*\*



The Power BI report focuses on the areas most relevant to management reporting, while the SQL Server layer provides deeper operational analysis behind the reporting model.

