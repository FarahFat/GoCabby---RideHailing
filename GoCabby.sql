#Data Cleaning & Exploratory Analysis
-- Remove columns with high proportion of null values or irrelevant information
ALTER TABLE gocabby_data
DROP COLUMN Unnamed: 14, DROP COLUMN Unnamed: 15, DROP COLUMN Unnamed: 16, DROP COLUMN `Max Online Minutes`, DROP COLUMN 700, DROP COLUMN `2018-04-23 00:00:00`, DROP COLUMN Unnamed: 20, DROP COLUMN Unnamed: 21;

#-- Handle rows with missing values (Example: Removing rows where 'Driver ID' is null)
DELETE FROM gocabby_data WHERE `Driver ID` IS NULL;

#-- Basic Summary Statistics
SELECT 
    AVG(`Online Minutes`) AS Avg_Online_Minutes, 
    MIN(`Online Minutes`) AS Min_Online_Minutes, 
    MAX(`Online Minutes`) AS Max_Online_Minutes,
    -- More aggregations for other numeric columns
FROM gocabby_data;

-- Unique Value Counts for Categorical Data
SELECT `Driver City`, COUNT(*) AS Count 
FROM gocabby_data 
GROUP BY `Driver City`;

-- Date Range Analysis for 'Sign Up Date'
SELECT MIN(`Sign up Date`) AS Earliest_Date, MAX(`Sign up Date`) AS Latest_Date 
FROM gocabby_data;

#Advanced Analysis
1. Driver Performance Analysis:
SELECT 
    `Driver ID`,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    SUM(`Rides Presented`) AS Total_Rides_Presented,
    SUM(`Rides accepted`) AS Total_Rides_Accepted,
    SUM(`Rides rejected`) AS Total_Rides_Rejected,
    AVG(`Rejection Rate`) AS Avg_Rejection_Rate
FROM gocabby_data
GROUP BY `Driver ID`;

2. City-wise Analysis:
SELECT 
    `Driver City`,
    COUNT(DISTINCT `Driver ID`) AS Total_Drivers,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    -- More aggregations
FROM gocabby_data
GROUP BY `Driver City`;

3. Time Analysis:
SELECT 
    strftime('%Y', `Sign up Date`) AS Year,
    COUNT(DISTINCT `Driver ID`) AS Total_Drivers,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    -- More aggregations
FROM gocabby_data
GROUP BY Year;

4. Driver Engagement Analysis:
SELECT 
    CASE 
        WHEN `Driver tenure - in days` < 365 THEN 'Less than a year'
        WHEN `Driver tenure - in days` BETWEEN 365 AND 729 THEN '1-2 years'
        ELSE 'More than 2 years'
    END AS Tenure_Group,
    COUNT(DISTINCT `Driver ID`) AS Total_Drivers,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    -- More aggregations
FROM gocabby_data
GROUP BY Tenure_Group;

5. Ride Request Analysis:
SELECT 
    AVG(`Rides Presented`) AS Avg_Rides_Presented,
    AVG(`Rides accepted`) AS Avg_Rides_Accepted,
    AVG(`Rides rejected`) AS Avg_Rides_Rejected,
    AVG(`Rides Timeout`) AS Avg_Rides_Timeout
FROM gocabby_data;

6. Peak Performance Analysis:
SELECT 
    `Driver ID`, 
    `Online Minutes`, 
    `Rides accepted`, 
    `Rides rejected`,
    (`Rides accepted` * 1.0 / (`Rides accepted` + `Rides rejected`)) AS Acceptance_Rate,
    `Rejection Rate`
FROM gocabby_data
WHERE `Rides accepted` > 0 AND `Online Minutes` > (SELECT AVG(`Online Minutes`) FROM gocabby_data)
ORDER BY Acceptance_Rate DESC, `Online Minutes` DESC
LIMIT 10;

7. Analysis of Rides by Hour:
SELECT 
    strftime('%H', Ride_Timestamp) AS Hour, 
    COUNT(*) AS Total_Rides,
    AVG(`Rides accepted`) AS Avg_Accepted_Rides
FROM gocabby_data
GROUP BY Hour
ORDER BY Total_Rides DESC;

8. Longevity Analysis:
SELECT 
    `Driver tenure - in days`,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    AVG(`Rides Presented`) AS Avg_Rides_Presented,
    AVG(`Rides accepted`) AS Avg_Rides_Accepted,
    AVG(`Rejection Rate`) AS Avg_Rejection_Rate
FROM gocabby_data
GROUP BY `Driver tenure - in days`
ORDER BY `Driver tenure - in days`;

9. City-wise Demand-Supply Gap Analysis:
SELECT 
    `Driver City`,
    SUM(`Rides Presented`) AS Total_Rides_Presented,
    SUM(`Rides accepted`) AS Total_Rides_Accepted,
    (SUM(`Rides Presented`) - SUM(`Rides accepted`)) AS Demand_Supply_Gap
FROM gocabby_data
GROUP BY `Driver City`;

10. Analysis of Rejection Reasons:
SELECT 
    Rejection_Reason,
    COUNT(*) AS Total_Rejections
FROM gocabby_data
GROUP BY Rejection_Reason
ORDER BY Total_Rejections DESC;

