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
WITH DL AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY ID ORDER BY ID) AS rn
    FROM Bank_Personal_Loan_Modelling
)
DELETE FROM DL WHERE rn > 1;

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

-- Insight: Thu nhập trung bình: 73,7742, Độ lệch chuẩn: 46,0257. 
--Điều này giúp chúng ta hiểu được sự phân bổ thu nhập; độ lệch chuẩn cao cho thấy phạm vi thu nhập rộng giữa những người nộp đơn.

-- 2. Exploratory Data Analysis (EDA):
-- a) Summary Statistics for Age, Income, and Credit Card Average Usage
SELECT 
    AVG(Age * 1.0) AS Avg_Age,
    MIN(Age) AS Min_Age,
    MAX(Age) AS Max_Age,
	STDEV(Age) AS StdDev_Age,
    AVG(Income * 1.0) AS Avg_Income,
    MIN(Income) AS Min_Income,
    MAX(Income) AS Max_Income,
	STDEV(Income) AS StdDev_Income,
    AVG(CCAvg * 1.0) AS Avg_CCAvg,
    MIN(CCAvg) AS Min_CCAvg,
    MAX(CCAvg) AS Max_CCAvg,
	STDEV(CCAvg) AS StdDev_CCAvg
FROM 
    Bank_Personal_Loan_Modelling;

-- Insight: Avg_Age: 45.34, Min_Age: 23, Max_Age: 67, Avg_Income: 73.77, Min_Income: 8, Max_Income: 224, Avg_CCAvg: 194.
-- These statistics show the general profile of the applicants, which helps in targeting potential customers.
-- Độ lệch chuẩn của tuổi, thu nhập và mức chi tiêu trung bình trên thẻ tín dụng cao=>chênh lệch độ tuổi, mức thu nhập và chi tiêu trên thẻ tín dụng

-- b) Distribution of Personal Loans
SELECT 
    [Personal_Loan],
    COUNT(*) AS Count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Bank_Personal_Loan_Modelling) AS Percentage
FROM 
    Bank_Personal_Loan_Modelling
GROUP BY 
    [Personal_Loan];

-- Insight: với 5000 khách hàng thì chỉ có 480 (chiếm 9,6%) là chấp nhận khoản vay cá nhân ngân hàng đề xuất gần nhất, còn lại 90,4% khách hàng là từ chối
-- Phần lớn khách hàng không có khoản vay cá nhân, cho thấy đây là thị trường tiềm năng cho các chiến dịch tiếp thị có mục tiêu..

-- c) Income Distribution Across Loan Applicants
SELECT 
    Personal_Loan, 
    AVG(Income * 1.0) AS Avg_Income 
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: Avg_Income: 66.24, Personal Loan 1: Avg_Income: 144.75. 
-- Những người vay vốn cá nhân thường có thu nhập cao hơn đáng kể, cho thấy thu nhập có thể là một yếu tố tiềm năng trong việc phê duyệt khoản vay.

-- 3. Answering Business Questions:
-- a) Mối quan hệ giữa thu nhập và Personal_Loan
SELECT 
    Personal_Loan, 
    AVG(Income*1.0) AS Avg_Income
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: 66.24, Personal Loan 1: 144.75. 
-- Điều này củng cố thêm phát hiện trước đó rằng mức thu nhập cao hơn có liên quan đến việc phê duyệt khoản vay.

-- b) Average Credit Card Usage Related to Loan Approval
SELECT 
    Personal_Loan, 
    AVG(CCAvg) AS Avg_Credit_Card_Usage
FROM 
    Bank_Personal_Loan_Modelling bplm
GROUP BY 
    Personal_Loan;

-- Insight: Personal Loan 0: 172.9, Personal Loan 1: 390.5
--Việc sử dụng thẻ tín dụng cao hơn ở những người xin vay được chấp thuận có thể cho thấy họ quản lý tín dụng có trách nhiệm, đây có thể là tiêu chí để xét duyệt khoản vay.

-- c) Typical Profile of Approved Loan Customers
SELECT 
    AVG(Age*1.0) AS Avg_Age, 
    AVG(Income*1.0) AS Avg_Income, 
    AVG(CCAvg) AS Avg_CC_Usage, 
    AVG(Family*1.0) AS Avg_Family_Size, 
    AVG(Mortgage*1.0) AS Avg_Mortgage 
FROM 
    Bank_Personal_Loan_Modelling bplm 
WHERE 
    Personal_Loan = 1;

-- Insight: Avg_Age: 45.07, Avg_Income: 144.75, Avg_CC_Usage: 390.5, Avg_Family_Size: 2.61, Avg_Mortgage: 100.85. 
--Nhóm khách hàng đã vay tiền cá nhân có:

--Tuổi trung bình cao hơn khách hàng bình thường (có thể có nhu cầu tiêu dùng lớn hơn).

--Thu nhập cao → dễ đạt điều kiện vay.

--Chi tiêu thẻ tín dụng cao → có hành vi sử dụng tài chính năng động.

--Có thể đã vay thế chấp → quen với việc dùng sản phẩm tín dụng.



-- 4. Create a New Table for Submission and Approval Datetimes
CREATE TABLE submission_approval_datetime_new (
    id INT IDENTITY(1,1) PRIMARY KEY,
    submission_datetime DATETIME, 
    approval_datetime DATETIME
);

-- Step 2: Insert Data from the Old Table into the New Table
INSERT INTO submission_approval_datetime_new (submission_datetime, approval_datetime)
SELECT submission_datetime, approval_datetime
FROM submission_approval_datetime;

-- Step 3: Drop the Old Table
DROP TABLE submission_approval_datetime;

-- Step 4: Rename the New Table
EXEC sp_rename 'submission_approval_datetime_new', 'submission_approval_datetime';

-- Kiểm tra lại bảng đã đổi tên
SELECT id FROM submission_approval_datetime;
-- Query result: 5000 rows of IDs. This confirms that we have successfully transitioned the data.

-- 5. Create Combined Data Table
-- Bước 1: Tạo bảng mới với đầy đủ kiểu dữ liệu
CREATE TABLE combined_loan_data (
    ID INT,
    Age INT,
    Experience INT,
    Income FLOAT,
    [ZIP Code] INT,
    Family INT,
    CCAvg FLOAT,
    Education INT,
    Mortgage FLOAT,
    [Personal Loan] INT,
    [Securities Account] INT,
    [CD_Account] INT,
    Online INT,
    CreditCard INT,
    submission_datetime DATETIME,
    approval_datetime DATETIME
);

-- Bước 2: Chèn dữ liệu từ bảng gốc vào bảng mới
INSERT INTO combined_loan_data (
    ID, Age, Experience, Income, [ZIP Code], Family, CCAvg, Education,
    Mortgage, [Personal Loan], [Securities Account], [CD_Account], Online, CreditCard,
    submission_datetime, approval_datetime
)
SELECT
    bplm.ID,
    bplm.Age,
    bplm.Experience,
    bplm.Income,
    bplm.[ZIP_Code],
    bplm.Family,
    bplm.CCAvg,
    bplm.Education,
    bplm.Mortgage,
    bplm.[Personal_Loan],
    bplm.[Securities_Account],
    bplm.[CD_Account],
    bplm.Online,
    bplm.CreditCard,
    sa.submission_datetime,
    sa.approval_datetime
FROM
    Bank_Personal_Loan_Modelling bplm
JOIN
    submission_approval_datetime sa ON bplm.ID = sa.id;


-- Thông tin chi tiết: Bảng dữ liệu kết hợp hiện bao gồm tất cả thông tin có liên quan, cho phép phân tích toàn diện các hồ sơ vay và phê duyệt.

-- Add a Column for Turnaround Time
-- Thêm cột turnaround_time kiểu FLOAT (hoặc DECIMAL nếu muốn kiểm soát độ chính xác)
ALTER TABLE combined_loan_data
ADD turnaround_time FLOAT;

-- Tính turnaround_time = số giờ giữa approval_datetime và submission_datetime
UPDATE combined_loan_data
SET turnaround_time = 
    DATEDIFF(MINUTE, submission_datetime, approval_datetime) / 60.0;


-- Verify Combined Data
-- Xem toàn bộ dữ liệu
SELECT * FROM combined_loan_data;

-- Tính thời gian xử lý trung bình (tính theo giờ)
SELECT
    AVG(turnaround_time) AS Average_Turnaround_Hours
FROM
    combined_loan_data;


-- Insight:Giờ xử lý trung bình: 95,75. Chỉ số này cho biết thời gian trung bình để phê duyệt khoản vay, có thể giúp cải thiện quy trình.

-- 7. Approval Rate by Month (SQL Server)
SELECT
    FORMAT(CAST(submission_datetime AS DATETIME), 'yyyy-MM') AS Submission_Month,
    COUNT(*) AS Total_Submissions,
    COUNT(CASE WHEN approval_datetime IS NOT NULL THEN 1 END) AS Total_Approved,
    COUNT(CASE WHEN approval_datetime IS NOT NULL THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM
    combined_loan_data
GROUP BY
    FORMAT(CAST(submission_datetime AS DATETIME), 'yyyy-MM')
ORDER BY
    Submission_Month;


-- Thông tin chi tiết: Truy vấn này sẽ hiển thị xu hướng tỷ lệ chấp thuận theo thời gian, 
--có thể giúp xác định những biến động theo mùa hoặc tác động của những thay đổi về chính sách.

-- 8. Percentage of Applications Approved Within 1 Week
SELECT
    COUNT(CASE 
        WHEN DATEDIFF(DAY, CAST(submission_datetime AS DATETIME), CAST(approval_datetime AS DATETIME)) <= 7 
             AND approval_datetime IS NOT NULL 
        THEN 1 
    END) * 100.0 / COUNT(*) AS Percentage_Approved_Within_1_Week
FROM
    combined_loan_data;


-- Thông tin chi tiết: Tỷ lệ đơn xin vay được chấp thuận trong vòng một tuần là một chỉ số đánh giá hiệu quả quan trọng của hệ thống xử lý khoản vay.

-- 9. Monthly Trend of Approved Loans
-- Tổng số khoản vay được phê duyệt theo tháng (SQL Server)
SELECT 
    FORMAT(CAST(approval_datetime AS DATETIME), 'yyyy-MM') AS Approval_Month,
    COUNT(*) AS Total_Approved_Loans
FROM 
    combined_loan_data
WHERE 
    approval_datetime IS NOT NULL
GROUP BY 
    FORMAT(CAST(approval_datetime AS DATETIME), 'yyyy-MM')
ORDER BY 
    Approval_Month;

-- Thông tin chi tiết: Phân tích xu hướng hàng tháng của các khoản vay được chấp thuận có thể giúp hiểu được nhu cầu thị trường và đánh giá tác động của nhiều yếu tố khác nhau đối với việc phê duyệt khoản vay.
-- Query: Calculate Maximum Turnaround Time for Loan Approvals
SELECT 
    MAX(turnaround_time) AS Max_Turnaround_Time 
FROM 
    combined_loan_data;

-- Kết quả truy vấn: max(turnaround_time)
-- --------------------+
-- 168.0|

-- Thông tin chi tiết: Thời gian xử lý tối đa để phê duyệt khoản vay là 168 giờ (7 ngày).
-- Điều này cho biết thời gian dài nhất từ ​​khi nộp khoản vay đến khi phê duyệt trong tập dữ liệu.
-- Hiểu được thời gian tối đa này có thể giúp xác định các nút thắt tiềm ẩn trong quy trình phê duyệt
-- và đưa ra các chiến lược để cải thiện hiệu quả và sự hài lòng của khách hàng.
--1. Tỷ lệ chấp thuận theo nhóm độ tuổi
--Xem nhóm tuổi nào có tỷ lệ được duyệt vay cao nhất, từ đó tập trung chính sách hoặc chiến dịch phù hợp.
SELECT 
    CASE 
        WHEN Age < 30 THEN '<30'
        WHEN Age BETWEEN 30 AND 45 THEN '30-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '>60'
    END AS Age_Group,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM combined_loan_data
GROUP BY CASE 
        WHEN Age < 30 THEN '<30'
        WHEN Age BETWEEN 30 AND 45 THEN '30-45'
        WHEN Age BETWEEN 46 AND 60 THEN '46-60'
        ELSE '>60'
    END
ORDER BY Age_Group;

--2. Tỷ lệ chấp thuận theo mức độ giáo dục (Education)
--Hiểu xem trình độ học vấn có ảnh hưởng thế nào tới việc phê duyệt.
SELECT 
    Education,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate,
    AVG(Income) AS Avg_Income_of_Group
FROM combined_loan_data
GROUP BY Education
ORDER BY Education;
--3. Tỷ lệ sử dụng tài khoản chứng khoán/CD tài khoản theo nhóm vay được duyệt
--Xem xét việc khách hàng sở hữu tài khoản chứng khoán hay tài khoản tiết kiệm có ảnh hưởng tới quyết định duyệt vay hay không.

SELECT 
    [Securities_Account],
    [CD_Account],
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM combined_loan_data
GROUP BY [Securities_Account], [CD_Account]
ORDER BY [Securities_Account], [CD_Account];

--4. Ảnh hưởng của số lượng người trong gia đình (Family) đến tỷ lệ duyệt vay
--Kiểm tra xem quy mô gia đình có tác động gì tới khả năng duyệt vay không.
SELECT 
    Family,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate,
    AVG(Income) AS Avg_Income
FROM combined_loan_data
GROUP BY Family
ORDER BY Family;

--5. Phân tích ảnh hưởng của thời gian xử lý (Turnaround time) đến tỷ lệ chấp thuận
--Xem có mối liên hệ giữa thời gian xử lý khoản vay và khả năng được duyệt hay không.

SELECT 
    CASE 
        WHEN turnaround_time <= 24 THEN '0-24 hours'
        WHEN turnaround_time BETWEEN 24 AND 72 THEN '24-72 hours'
        WHEN turnaround_time BETWEEN 73 AND 168 THEN '3-7 days'
        ELSE '>7 days'
    END AS Processing_Time_Group,
    COUNT(*) AS Total_Applications,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate,
    AVG(Income) AS Avg_Income
FROM combined_loan_data
GROUP BY 
    CASE 
        WHEN turnaround_time <= 24 THEN '0-24 hours'
        WHEN turnaround_time BETWEEN 24 AND 72 THEN '24-72 hours'
        WHEN turnaround_time BETWEEN 73 AND 168 THEN '3-7 days'
        ELSE '>7 days'
    END
ORDER BY Processing_Time_Group;

--6. Tỷ lệ duyệt vay theo thu nhập (Income) phân đoạn
--Xác định các ngưỡng thu nhập có ảnh hưởng rõ ràng đến phê duyệt khoản vay.
SELECT 
    CASE 
        WHEN Income < 30 THEN '<30k'
        WHEN Income BETWEEN 30 AND 70 THEN '30k-70k'
        WHEN Income BETWEEN 71 AND 120 THEN '71k-120k'
        ELSE '>120k'
    END AS Income_Group,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM combined_loan_data
GROUP BY 
    CASE 
        WHEN Income < 30 THEN '<30k'
        WHEN Income BETWEEN 30 AND 70 THEN '30k-70k'
        WHEN Income BETWEEN 71 AND 120 THEN '71k-120k'
        ELSE '>120k'
    END
ORDER BY Income_Group;

--7. Tỷ lệ duyệt vay và điểm sử dụng thẻ tín dụng (CCAvg) phân đoạn
--Đánh giá mức độ chi tiêu trên thẻ tín dụng ảnh hưởng tới khả năng được duyệt.
SELECT 
    CASE 
        WHEN CCAvg < 100 THEN '<100'
        WHEN CCAvg BETWEEN 100 AND 300 THEN '100-300'
        ELSE '>300'
    END AS CCAvg_Group,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM combined_loan_data
GROUP BY 
    CASE 
        WHEN CCAvg < 100 THEN '<100'
        WHEN CCAvg BETWEEN 100 AND 300 THEN '100-300'
        ELSE '>300'
    END
ORDER BY CCAvg_Group;

--8. Phân tích mối quan hệ giữa việc sở hữu thẻ tín dụng (CreditCard) và khoản vay được duyệt

SELECT
    CreditCard,
    COUNT(*) AS Total_Applicants,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) AS Approved_Count,
    COUNT(CASE WHEN Personal_Loan = 1 THEN 1 END) * 100.0 / COUNT(*) AS Approval_Rate
FROM combined_loan_data
GROUP BY CreditCard
ORDER BY CreditCard;

--Tổng kết:
--Những phân tích trên giúp khai thác dữ liệu sâu hơn về đặc điểm khách hàng, từ đó phân nhóm và phát hiện các yếu tố ảnh hưởng lớn tới việc phê duyệt vay.

--Từ các insight này, ngân hàng có thể tinh chỉnh chính sách tín dụng, nhắm mục tiêu marketing, và cải thiện quy trình phê duyệt.
