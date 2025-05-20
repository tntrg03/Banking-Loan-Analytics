-- 1. Data Wrangling:
-- a) Handle Missing Values
USE Banking_loan
SELECT *
FROM [dbo].[Bank_Personal_Loan_Modelling];

SELECT * 
FROM [dbo].[Bank_Personal_Loan_Modelling] bplm
WHERE Age IS NULL 
   OR Experience IS NULL 
   OR Income IS NULL 
   OR Family IS NULL; 
-- Insight: No missing values found in the dataset. This indicates data integrity regarding demographic variables.

-- b) Check for Duplicates
SELECT ID, COUNT(*) AS Duplicate_Count 
FROM Bank_Personal_Loan_Modelling
GROUP BY ID 
HAVING COUNT(*) > 1;
-- Insight: All IDs are duplicated. This suggests that we need to ensure uniqueness in our dataset for accurate analysis.

-- b) 1.) Delete Duplicates
DELETE FROM [dbo].[Bank_Personal_Loan_Modelling]
WHERE rowid NOT IN (
    SELECT MIN(rowid)
    FROM [dbo].[Bank_Personal_Loan_Modelling]
    GROUP BY ID
);
WITH CTE AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS rn
    FROM Bank_Personal_Loan_Modelling
)
DELETE FROM CTE WHERE rn > 1;

-- b) 2.) Verify Duplicate Removal
SELECT ID, COUNT(*) AS Duplicate_Count 
FROM [dbo].[Bank_Personal_Loan_Modelling] bplm 
GROUP BY ID 
HAVING COUNT(*) > 1;
-- Insight: All duplicates deleted successfully. The dataset is now cleaned up for analysis.

-- c) Outliers Detection: Calculate Average Income and Standard Deviation
SELECT 
    AVG(Income * 1.0) AS Average_Income,
    STDEV(Income) AS StdDev_Income
FROM 
    Bank_Personal_Loan_Modelling
WHERE 
    Income IS NOT NULL;

-- Insight: Average Income: 73.7742, Standard Deviation: 46.0257. This gives us an understanding of the income distribution; a high standard deviation indicates a wide income range among applicants.

-- 2. Exploratory Data Analysis (EDA):
-- a) Summary Statistics for Age, Income, and Credit Card Average Usage
SELECT 
    AVG(Age * 1.0) AS Avg_Age,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age,
    AVG(Income * 1.0) AS Avg_Income,
    MIN(Income) AS Min_Income,
    MAX(Income) AS Max_Income,
    AVG(CCAvg * 1.0) AS Avg_CCAvg,
    MIN(CCAvg) AS Min_CCAvg,
    MAX(CCAvg) AS Max_CCAvg
FROM 
    Bank_Personal_Loan_Modelling;

-- Insight: Avg_Age: 45.34, Min_Age: 23, Max_Age: 67, Avg_Income: 73.77, Min_Income: 8, Max_Income: 224, Avg_CCAvg: 194.
-- These statistics show the general profile of the applicants, which helps in targeting potential customers.

-- b) Distribution of Personal Loans
SELECT 
    [Personal_Loan],
    COUNT(*) AS Count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Bank_Personal_Loan_Modelling) AS Percentage
FROM 
    Bank_Personal_Loan_Modelling
GROUP BY 
    [Personal_Loan];

-- Insight: Personal Loan 0: 4520 (90.4%), Personal Loan 1: 480 (9.6%). 
-- The overwhelming majority of applicants do not have personal loans, indicating a potential market for targeted marketing campaigns.

-- c) Income Distribution Across Loan Applicants
SELECT 
    Personal_Loan, 
    AVG(Income * 1.0) AS Avg_Income 
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: Avg_Income: 66.24, Personal Loan 1: Avg_Income: 144.75. 
-- Those who take personal loans tend to have significantly higher incomes, suggesting income as a potential factor in loan approval.

-- 3. Answering Business Questions:
-- a) Relationship Between Income and Loan Approval
SELECT 
    Personal_Loan, 
    AVG(Income) AS Avg_Income
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: 66.24, Personal Loan 1: 144.75. 
-- This reinforces the previous finding that higher income levels are associated with loan approvals.

-- b) Average Credit Card Usage Related to Loan Approval
SELECT 
    Personal_Loan, 
    AVG(CCAvg) AS Avg_Credit_Card_Usage
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: 1.73, Personal Loan 1: 3.91. 
-- Higher credit card usage among approved loan applicants may indicate responsible credit management, which could be a criterion for loan eligibility.

-- c) Typical Profile of Approved Loan Customers
SELECT 
    AVG(Age) AS Avg_Age, 
    AVG(Income) AS Avg_Income, 
    AVG(CCAvg) AS Avg_CC_Usage, 
    AVG(Family) AS Avg_Family_Size, 
    AVG(Mortgage) AS Avg_Mortgage 
FROM 
    Bank_Personal_Loan_Modelling bplm 
WHERE 
    Personal_Loan = 1;

-- Insight: Avg_Age: 45.07, Avg_Income: 144.75, Avg_CC_Usage: 3.91, Avg_Family_Size: 2.61, Avg_Mortgage: 100.85. 
-- This profile helps in understanding the demographic characteristics of loan applicants and assists in tailoring marketing strategies.

-- 4. Create a New Table for Submission and Approval Datetimes
CREATE TABLE submission_approval_datetime_new (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    submission_datetime TEXT, 
    approval_datetime TEXT 
);

-- Step 2: Insert Data from the Old Table into the New Table
INSERT INTO submission_approval_datetime_new (submission_datetime, approval_datetime)
SELECT submission_datetime, approval_datetime
FROM submission_approval_datetime;

-- Step 3: Drop the Old Table
DROP TABLE submission_approval_datetime;

-- Step 4: Rename the New Table
ALTER TABLE submission_approval_datetime_new RENAME TO submission_approval_datetime;

SELECT id FROM submission_approval_datetime; 
-- Query result: 5000 rows of IDs. This confirms that we have successfully transitioned the data.

-- 5. Create Combined Data Table
CREATE TABLE combined_loan_data AS 
SELECT
    bplm.ID,
    bplm.Age,
    bplm.Experience,
    bplm.Income,
    bplm.`ZIP Code`,
    bplm.Family,
    bplm.CCAvg,
    bplm.Education,
    bplm.Mortgage,
    bplm.`Personal Loan`,
    bplm.`Securities Account`,
    bplm.`CD Account`,
    bplm.Online,
    bplm.CreditCard,
    sa.submission_datetime,
    sa.approval_datetime
FROM
    Bank_Personal_Loan_Modelling bplm 
JOIN
    submission_approval_datetime sa ON bplm.ID = sa.id;

-- Insight: The combined data table now includes all relevant information, allowing for a comprehensive analysis of loan submissions and approvals.

-- Add a Column for Turnaround Time
ALTER TABLE combined_loan_data ADD COLUMN turnaround_time REAL;

-- Update Turnaround Time Calculation
UPDATE combined_loan_data
SET turnaround_time = (
    (julianday(
        substr(approval_datetime, 7, 4) || '-' || 
        substr(approval_datetime, 1, 2) || '-' || 
        substr(approval_datetime, 4, 2) || 
        ' ' || 
        substr(approval_datetime, 12, 8)
    ) -
    julianday(
        substr(submission_datetime, 7, 4) || '-' || 
        substr(submission_datetime, 1, 2) || '-' || 
        substr(submission_datetime, 4, 2) || 
        ' ' || 
        substr(submission_datetime, 12, 8)
    )) * 24 -- Difference in hours
);

-- Verify Combined Data
SELECT * FROM combined_loan_data;

-- 6. Average Turnaround Time for Loan Approvals
SELECT
    AVG(turnaround_time) AS Average_Turnaround_Hours
FROM
    combined_loan_data;

-- Insight: Average Turnaround Hours: 95.75. This metric indicates the average time taken for loan approvals, which can inform process improvements.

-- 7. Approval Rate by Month
SELECT
    strftime('%Y-%m', 
        substr(submission_datetime, 7, 4) || '-' ||  
        substr(submission_datetime, 1, 2) || '-' ||  
        substr(submission_datetime, 4, 2)
    ) AS Submission_Month,  
    COUNT(*) AS Total_Submissions,  
    COUNT(CASE WHEN approval_datetime IS NOT NULL THEN 1 END) AS Total_Approved,  
    (COUNT(CASE WHEN approval_datetime IS NOT NULL THEN 1 END) * 100.0 / COUNT(*)) AS Approval_Rate  
FROM
    combined_loan_data  
GROUP BY
    Submission_Month  
ORDER BY
    Submission_Month; 

-- Insight: This query will show the approval rate trends over time, which can help identify seasonal variations or the impact of policy changes.

-- 8. Percentage of Applications Approved Within 1 Week
SELECT
    COUNT(CASE WHEN 
        julianday(
            substr(approval_datetime, 7, 4) || '-' || 
            substr(approval_datetime, 1, 2) || '-' || 
            substr(approval_datetime, 4, 2) || 
            ' ' || 
            substr(approval_datetime, 12, 8)
        ) - 
        julianday(
            substr(submission_datetime, 7, 4) || '-' || 
            substr(submission_datetime, 1, 2) || '-' || 
            substr(submission_datetime, 4, 2) || 
            ' ' || 
            substr(submission_datetime, 12, 8)
        ) <= 7 
    THEN 1 END) * 100.0 / COUNT(*) AS Percentage_Approved_Within_1_Week
FROM
    combined_loan_data;

-- Insight: The percentage of applications approved within a week is a critical performance metric indicating the efficiency of the loan processing system.

-- 9. Monthly Trend of Approved Loans
SELECT 
    strftime('%Y-%m', 
        substr(approval_datetime, 7, 4) || '-' ||  
        substr(approval_datetime, 1, 2) || '-' ||  
        substr(approval_datetime, 4, 2)
    ) AS Approval_Month, 
    COUNT(*) AS Total_Approved_Loans
FROM 
    combined_loan_data
WHERE 
    approval_datetime IS NOT NULL
GROUP BY 
    Approval_Month
ORDER BY 
    Approval_Month;

-- Insight: Analyzing the monthly trends of approved loans can help understand market demand and assess the impact of various factors on loan approvals.
-- Query: Calculate Maximum Turnaround Time for Loan Approvals
SELECT 
    MAX(turnaround_time) AS Max_Turnaround_Time 
FROM 
    combined_loan_data;

-- Query result: max(turnaround_time)
-- --------------------+
--                               168.0|

-- Insight: The maximum turnaround time for loan approvals is 168 hours (7 days). 
-- This indicates the longest time taken from loan submission to approval in the dataset.
-- Understanding this maximum duration can help identify potential bottlenecks in the approval process 
-- and inform strategies to improve efficiency and customer satisfaction.

