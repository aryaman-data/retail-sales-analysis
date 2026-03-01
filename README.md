#  Retail Chain Sales Data Analysis & Reporting

An end-to-end data analytics project analyzing 125,000 retail transactions
across 5 years using **Python**, **SQL Server**, and **Excel**.

---

##  Project Overview

| Detail | Info |
|---|---|
| **Type** | End-to-End Data Analytics Project |
| **Tools** | Python · SQL Server (SSMS 21) · Excel · Google Colab |
| **Dataset** | 125,000 transactions · 6,889 customers · 2011–2015 |
| **Libraries** | pandas · matplotlib · seaborn · openpyxl |

---

## 📁 Repository Structure

```
📦 retail-sales-analysis
├── 📄 README.md
├── 📂 data/
│   ├── Retail_Data_Transactions.csv
│   └── Retail_Data_Response.csv
├── 📂 sql/
│   ├── Database Setup.sql
├── 📂 python/
│   └── python analysis and charts.ipynb
├── 📂 excel/
│   └── Excel Dashboard.xlsx
└── 📂 charts/
    ├── chart1_sales_by_year.png
    ├── chart2_monthly_trend.png
    ├── chart3_sales_by_quarter.png
    ├── chart4_amount_distribution.png
    ├── chart5_top10_customers.png
    ├── chart6_response_rate.png
    ├── chart7_responders_vs_non.png
    ├── chart8_txn_frequency.png
    ├── chart9_time_series.png
    └── chart10_cohort_analysis.png
```

---

##  Dataset

| File | Rows | Description |
|---|---|---|
| `Retail_Data_Transactions.csv` | 125,000 | Customer transactions with date and amount |
| `Retail_Data_Response.csv` | 6,884 | Campaign response data (0 = No, 1 = Yes) |

### Fields
| Column | Description |
|---|---|
| `customer_id` | Unique customer identifier |
| `trans_date` | Date of transaction |
| `tran_amount` | Transaction amount ($10–$105) |
| `response` | Campaign response (0 = No, 1 = Yes) |

---

##  Project Phases

---

### Phase 1 — Database Setup
`Database Setup.sql`

- Designed a **3-table relational schema** in SQL Server
- Created `customers`, `transactions` and `customer_response` tables with Primary and Foreign Keys
- Loaded 125,000+ records using `BULK INSERT` with proper date format conversion

```sql
CREATE TABLE transactions (
    transaction_id  INT IDENTITY(1,1) PRIMARY KEY,
    customer_id     VARCHAR(10)       NOT NULL,
    trans_date      DATE              NOT NULL,
    tran_amount     DECIMAL(10,2)     NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

---

### Phase 2 — Data Cleaning & Preparation
`Database Setup.sql`

- Checked for **NULL values, duplicates, outliers** and invalid dates
- Used **IQR method** to flag outliers in transaction amounts
- Added 5 calculated columns: `trans_year`, `trans_month`, `trans_month_name`, `trans_quarter`, `total_sales`
- Created two reusable **SQL Views** for downstream analysis:
  - `vw_retail_master` — joined transactions + response data
  - `vw_customer_summary` — per-customer KPIs (total spent, avg value, lifespan)

---

### Phase 3 — Data Analysis & Visualization
`python analysis and charts.ipynb`

10 charts generated using **pandas, matplotlib and seaborn**:

| # | Chart | Type |
|---|---|---|
| 1 | Total Sales Revenue by Year | Bar |
| 2 | Monthly Sales Trend by Year | Line |
| 3 | Sales by Quarter | Bar |
| 4 | Transaction Amount Distribution | Histogram + Boxplot |
| 5 | Top 10 Customers by Total Spend | Horizontal Bar |
| 6 | Campaign Response Rate | Pie |
| 7 | Responders vs Non-Responders Avg Spend | Bar |
| 8 | Customer Transaction Frequency | Histogram |
| 9 | Daily Sales with 30-Day Rolling Average | Time Series |
| 10 | Cohort Analysis by First Purchase Year | Dual Axis |

---

### Phase 4 — Excel Dashboard
`Excel Dashboard.xlsx`

3-sheet professional Excel workbook:

| Sheet | Contents |
|---|---|
| **Dashboard** | 5 KPI boxes · Year-over-year summary table · Embedded Python charts |
| **Summary Tables** | Sales by year/quarter/month · Top 15 customers · Native Excel charts |
| **Raw Data** | Formatted transaction data with frozen headers and alternating rows |

---

##  Key Insights

| Metric | Value |
|---|---|
| Total Revenue (2011–2015) | $8,124,875 |
| Average Transaction Value | $64.99 |
| Unique Customers | 6,889 |
| Campaign Response Rate | 9.4% |
| Transaction Amount Range | $10 – $105 |

---

##  Skills Demonstrated

- Relational database design with Primary & Foreign Keys
- SQL DDL/DML — `CREATE`, `ALTER`, `INSERT`, `BULK INSERT`
- SQL Views, Window Functions, `TRY_CONVERT`, `PERCENTILE_CONT`
- Data cleaning — NULL handling, duplicate detection, IQR outlier analysis
- Python EDA with `pandas` — groupby, aggregations, rolling averages
- Data visualization with `matplotlib` and `seaborn`
- Time series analysis and cohort analysis
- Professional Excel dashboard design with KPI boxes and native charts

---

##  How to Run

### SQL 
1. Open **SSMS 21** and connect to your SQL Server instance
2. Update the file paths in `BULK INSERT` to your local CSV location
3. Run `Database_Setup.sql` 

### Python 
1. Open **Google Colab**
2. Copy cells from `python analysis and charts.ipynb`
3. Run Cell 1 to install libraries
4. Run Cell 2 to upload the 3 CSV files exported from SSMS
5. Run Cells 3–16 to generate and download all 10 charts as a ZIP

### Excel 
1. Open `Excel Dashboard.xlsx`
2. Insert Phase 3 chart PNGs into the Dashboard placeholder boxes
3. Explore the Summary Tables sheet for interactive native Excel charts


##  Author

**Aryaman Vishnoi**
[LinkedIn](https://www.linkedin.com/in/aryamanvishnoi-data/)

---

## 📜 License

This project is intended for educational and portfolio purposes.
