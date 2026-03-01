create database retailsalesdb
use retailsalesdb

CREATE TABLE customers (
        customer_id   VARCHAR(10)  NOT NULL,
        CONSTRAINT PK_customers PRIMARY KEY (customer_id)
    );


CREATE TABLE transactions (
        transaction_id   INT IDENTITY(1,1)  NOT NULL,
        customer_id      VARCHAR(10)        NOT NULL,
        trans_date       DATE               NOT NULL,
        tran_amount      DECIMAL(10,2)      NOT NULL,
        CONSTRAINT PK_transactions  PRIMARY KEY (transaction_id),
        CONSTRAINT FK_trans_cust    FOREIGN KEY (customer_id)
                                    REFERENCES customers(customer_id)
    );


CREATE TABLE customer_response (
        response_id   INT IDENTITY(1,1)  NOT NULL,
        customer_id   VARCHAR(10)        NOT NULL,
        response      TINYINT            NOT NULL,  -- 0 or 1
        CONSTRAINT PK_response       PRIMARY KEY (response_id),
        CONSTRAINT FK_resp_cust      FOREIGN KEY (customer_id)
                                     REFERENCES customers(customer_id)
    );

--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
CREATE TABLE stg_transactions (
        customer_id   VARCHAR(10),
        trans_date    VARCHAR(20),  
        tran_amount   INT
    );


CREATE TABLE stg_response (
        customer_id   VARCHAR(10),
        response      TINYINT
    );

BULK INSERT stg_transactions
FROM 'C:\Users\Aryaman\Downloads\Retail_Data_Transactions.csv'
WITH (
    FIELDTERMINATOR  = ',',
    ROWTERMINATOR    = '\n',
    FIRSTROW         = 2,      
    TABLOCK
);

BULK INSERT stg_response
FROM 'C:\Users\Aryaman\Downloads\Retail_Data_Response.csv'
WITH (
    FIELDTERMINATOR  = ',',
    ROWTERMINATOR    = '\n',
    FIRSTROW         = 2,       
    TABLOCK
);
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
INSERT INTO customers (customer_id)
SELECT DISTINCT customer_id FROM stg_transactions
UNION                                             
SELECT DISTINCT customer_id FROM stg_response;

INSERT INTO transactions (customer_id, trans_date, tran_amount)
SELECT
    customer_id,
    TRY_CONVERT(DATE, trans_date, 106),   -- converts 'DD-Mon-YY' to DATE
    tran_amount
FROM stg_transactions
WHERE TRY_CONVERT(DATE, trans_date, 106) IS NOT NULL; 

INSERT INTO customer_response (customer_id, response)
SELECT customer_id, response
FROM stg_response;
--^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

SELECT 'customers' AS table_union, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'transactions',COUNT(*) FROM transactions
UNION ALL SELECT 'customer_response', COUNT(*) FROM customer_response;

SELECT TOP 5 * FROM customers;
SELECT TOP 5 * FROM transactions;
SELECT TOP 5 * FROM customer_response;

SELECT
    MIN(trans_date) AS earliest_transaction,
    MAX(trans_date) AS latest_transaction
FROM transactions;

SELECT
    response,
    COUNT(*) AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)  AS percentage
FROM customer_response
GROUP BY response;

SELECT COUNT(*) AS unmatched_customers
FROM transactions t
LEFT JOIN customers c ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

DROP TABLE stg_transactions;
DROP TABLE stg_response;
--------------------------------------------------------------------------------------------------------
-- DATA CLEANING PREPARATION --

SELECT SUM(CASE WHEN customer_id  IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
SUM(CASE WHEN trans_date   IS NULL THEN 1 ELSE 0 END) AS null_trans_date,
SUM(CASE WHEN tran_amount  IS NULL THEN 1 ELSE 0 END) AS null_tran_amount
FROM transactions;

SELECT SUM(CASE WHEN customer_id  IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
SUM(CASE WHEN response     IS NULL THEN 1 ELSE 0 END) AS null_response
FROM customer_response;
----------------------------------------------------------------------------------------
SELECT
    customer_id,
    trans_date,
    tran_amount,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY customer_id, trans_date, tran_amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM customer_response
GROUP BY customer_id
HAVING COUNT(*) > 1;
--------------------------------------------------------------------------------------

SELECT
    MIN(tran_amount) AS min_amount,
    MAX(tran_amount) AS max_amount,
    ROUND(AVG(tran_amount), 2) AS avg_amount,
    ROUND(STDEV(tran_amount), 2) AS std_dev FROM TRANSACTIONS;

SELECT DISTINCT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY TRAN_AMOUNT) OVER () AS Q1,
PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY TRAN_AMOUNT) OVER () AS Median,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY TRAN_AMOUNT) OVER () AS Q3
FROM transactions;

WITH percentiles AS (
    SELECT DISTINCT
        PERCENTILE_CONT(0.25) WITHIN GROUP 
            (ORDER BY tran_amount) OVER () AS Q1,
        PERCENTILE_CONT(0.75) WITHIN GROUP 
            (ORDER BY tran_amount) OVER () AS Q3
    FROM transactions
),
iqr_bounds AS (
    SELECT
        Q1,
        Q3,
        Q3 - Q1                  AS IQR,
        Q1 - 1.5 * (Q3 - Q1)    AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1)    AS upper_bound
    FROM percentiles
)
SELECT
    i.lower_bound,
    i.upper_bound,
    i.IQR,
    COUNT(t.transaction_id)      AS outlier_count
FROM transactions t
CROSS JOIN iqr_bounds i
WHERE t.tran_amount < i.lower_bound
   OR t.tran_amount > i.upper_bound
GROUP BY i.lower_bound, i.upper_bound, i.IQR;

----------------------------------------------------------
SELECT COUNT(*) AS invalid_dates
FROM transactions
WHERE trans_date IS NULL
OR trans_date > GETDATE() OR trans_date < '2000-01-01';    

---------------------------------------------------------

SELECT DISTINCT response
FROM customer_response
ORDER BY response;

SELECT COUNT(*) AS invalid_responses
FROM customer_response
WHERE response NOT IN (0, 1);

SELECT COUNT(DISTINCT t.customer_id) AS in_transactions_not_in_response
FROM transactions t
LEFT JOIN customer_response cr ON t.customer_id = cr.customer_id
WHERE cr.customer_id IS NULL;

SELECT COUNT(DISTINCT cr.customer_id) AS in_response_not_in_transactions
FROM customer_response cr
LEFT JOIN transactions t ON cr.customer_id = t.customer_id
WHERE t.customer_id IS NULL;

----------------------------------------------------------
ALTER TABLE transactions ADD trans_year INT;
ALTER TABLE transactions ADD trans_month INT;
ALTER TABLE transactions ADD trans_month_name VARCHAR(15)
ALTER TABLE transactions ADD trans_quarter VARCHAR(5)

ALTER TABLE transactions ADD total_sales DECIMAL(10,2)

UPDATE transactions
SET
    trans_year       = YEAR(trans_date),
    trans_month      = MONTH(trans_date),
    trans_month_name = DATENAME(MONTH, trans_date),
    trans_quarter    = 'Q' + CAST(DATEPART(QUARTER, trans_date) AS VARCHAR),
    total_sales      = tran_amount;


CREATE OR ALTER VIEW vw_retail_master AS
SELECT  t.transaction_id,t.customer_id, t.trans_date, t.trans_year, t.trans_month, t.trans_month_name,  t.trans_quarter, t.tran_amount,t.total_sales,
ISNULL(CAST(cr.response AS SMALLINT), -1) AS response 
FROM transactions t
LEFT JOIN customer_response cr ON t.customer_id = cr.customer_id;

CREATE OR ALTER VIEW vw_customer_summary AS
SELECT t.customer_id,
COUNT(t.transaction_id) AS total_transactions,
SUM(t.total_sales)  AS total_spent,
ROUND(AVG(t.total_sales), 2) AS avg_transaction_value,
MIN(t.tran_amount) AS min_transaction,
MAX(t.tran_amount) AS max_transaction,
MIN(t.trans_date)  AS first_purchase_date,
MAX(t.trans_date) AS last_purchase_date,
DATEDIFF(DAY,
MIN(t.trans_date),
MAX(t.trans_date)) AS customer_lifespan_days,
MAX(ISNULL(cr.response, 0)) AS campaign_response
FROM transactions t
LEFT JOIN customer_response cr ON t.customer_id = cr.customer_id
GROUP BY t.customer_id;

----------------------------------------------------------------------------
SELECT TOP 10 * FROM transactions

SELECT
SUM(CASE WHEN trans_year IS NULL THEN 1 ELSE 0 END) AS null_year,
SUM(CASE WHEN trans_month IS NULL THEN 1 ELSE 0 END) AS null_month,
SUM(CASE WHEN trans_month_name IS NULL THEN 1 ELSE 0 END) AS null_month_name,
SUM(CASE WHEN trans_quarter IS NULL THEN 1 ELSE 0 END) AS null_quarter,
SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) AS null_total_sales
FROM transactions;


SELECT DISTINCT trans_year
FROM transactions
ORDER BY trans_year;


SELECT TOP 10 * FROM vw_retail_master;


SELECT TOP 10 * FROM vw_customer_summary
ORDER BY total_spent DESC;


SELECT
    (SELECT COUNT(*) FROM transactions)                        AS total_transactions,
    (SELECT COUNT(DISTINCT customer_id) FROM transactions)     AS unique_customers,
    (SELECT MIN(trans_date) FROM transactions)                 AS date_from,
    (SELECT MAX(trans_date) FROM transactions)                 AS date_to,
    (SELECT ROUND(AVG(total_sales),2) FROM transactions)       AS avg_sale,
    (SELECT SUM(total_sales) FROM transactions)                AS total_revenue,
    (SELECT COUNT(*) FROM customer_response WHERE response=1)  AS responded_to_campaign,
    (SELECT COUNT(*) FROM customer_response WHERE response=0)  AS did_not_respond;

-------------------------------------------------------------------------------------------------







