## GoCabby---RideHailing
GoCabby - Data Cleaning & Transformation, EDA, Advanced Analysis & insights.

Use Case Summary:
Objective: The primary objective was to perform comprehensive data analysis on the "GoCabby" dataset, a collection of data related to a ride-hailing service. This analysis involved thorough data cleaning, exploratory analysis, and advanced SQL-based analytical queries to derive valuable insights about driver behavior, performance, and operational dynamics.

Data Overview:
The "GoCabby" dataset initially contained various columns such as 'Driver ID', 'Online Minutes', 'Rides Presented', 'Rides Timeout', 'Rides Rejected', 'Rides Accepted', 'Driver City', 'Sign Up Date', along with several other metrics and rates. However, the dataset also included unnamed and irrelevant columns, indicating the need for data cleaning.

Data Cleaning & Preparation:
Irrelevant Columns Removal: Dropped columns that were unnamed or contained meta-information not relevant to the analysis.
Handling Missing Values: Identified and removed rows with missing 'Driver ID' as they were essential for our analyses.
Data Type Corrections: Ensured proper data types, especially for dates and numerical values.

## Data Cleaning & Transformation:
To clean the `gocabby_data` table, we start by removing columns that have a high proportion of null values or contain irrelevant information:

```sql
ALTER TABLE gocabby_data
DROP COLUMN Unnamed: 14,
DROP COLUMN Unnamed: 15,
DROP COLUMN Unnamed: 16,
DROP COLUMN `Max Online Minutes`,
DROP COLUMN 700,
DROP COLUMN `2018-04-23 00:00:00`,
DROP COLUMN Unnamed: 20,
DROP COLUMN Unnamed: 21;
DELETE FROM gocabby_data WHERE `Driver ID` IS NULL;
```

## Exploratory Analysis:
Summary Statistics: Calculated basic statistics (mean, min, max) for numeric columns like 'Online Minutes' and 'Rides Presented'.
Unique Value Counts: Analyzed the distribution of categorical data like 'Driver City'.
Date Range Analysis: Examined the range of 'Sign up Date' to understand the dataset's time frame.

```sql
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
```

## Advanced Analysis: 
#1. Driver Performance Analysis: Focused on individual driver metrics, calculating averages and sums of online minutes, rides presented/accepted/rejected, and rejection rates. 

```sql
SELECT 
    `Driver ID`,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    SUM(`Rides Presented`) AS Total_Rides_Presented,
    SUM(`Rides accepted`) AS Total_Rides_Accepted,
    SUM(`Rides rejected`) AS Total_Rides_Rejected,
    AVG(`Rejection Rate`) AS Avg_Rejection_Rate
FROM gocabby_data
GROUP BY `Driver ID`;
```

#2. City-wise Analysis: Explored operational differences across cities, looking at metrics like total drivers and average online minutes per city. 
```sql
SELECT 
    `Driver City`,
    COUNT(DISTINCT `Driver ID`) AS Total_Drivers,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    -- More aggregations
FROM gocabby_data
GROUP BY `Driver City`;
```

#3. Time Analysis: Investigated trends over time, such as changes in driver performance metrics across different years. 
```sql
SELECT 
    strftime('%Y', `Sign up Date`) AS Year,
    COUNT(DISTINCT `Driver ID`) AS Total_Drivers,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    -- More aggregations
FROM gocabby_data
GROUP BY Year;
```

#4. Driver Engagement Analysis: Assessed the relationship between driver tenure and performance, categorizing drivers based on their tenure and comparing their average metrics.
```sql
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
```

#5. Ride Request Analysis: Analyzed the behavior of drivers in response to ride requests, focusing on averages of rides presented, accepted, rejected, and timeout. 
```sql
SELECT 
    AVG(`Rides Presented`) AS Avg_Rides_Presented,
    AVG(`Rides accepted`) AS Avg_Rides_Accepted,
    AVG(`Rides rejected`) AS Avg_Rides_Rejected,
    AVG(`Rides Timeout`) AS Avg_Rides_Timeout
FROM gocabby_data;
```

#6. Peak Performance Analysis: Identified top-performing drivers based on acceptance rate, rejection rate, and online minutes. 
```sql
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
```

#7. Hourly Ride Analysis: (Hypothetical) Assessed busiest hours for drivers by counting rides per hour, assuming timestamp data was available. 
```sql
SELECT 
    strftime('%H', Ride_Timestamp) AS Hour, 
    COUNT(*) AS Total_Rides,
    AVG(`Rides accepted`) AS Avg_Accepted_Rides
FROM gocabby_data
GROUP BY Hour
ORDER BY Total_Rides DESC;
```

#8. Longevity Analysis: Correlated driver tenure with performance metrics. 
```sql
SELECT 
    `Driver tenure - in days`,
    AVG(`Online Minutes`) AS Avg_Online_Minutes,
    AVG(`Rides Presented`) AS Avg_Rides_Presented,
    AVG(`Rides accepted`) AS Avg_Rides_Accepted,
    AVG(`Rejection Rate`) AS Avg_Rejection_Rate
FROM gocabby_data
GROUP BY `Driver tenure - in days`
ORDER BY `Driver tenure - in days`;
```

#9. Demand-Supply Gap Analysis: Evaluated the gap between rides presented and accepted in different cities, indicating potential demand-supply issues. 
```sql
SELECT 
    `Driver City`,
    SUM(`Rides Presented`) AS Total_Rides_Presented,
    SUM(`Rides accepted`) AS Total_Rides_Accepted,
    (SUM(`Rides Presented`) - SUM(`Rides accepted`)) AS Demand_Supply_Gap
FROM gocabby_data
GROUP BY `Driver City`;
```

#10. Rejection Reasons Analysis: (Hypothetical) Explored common reasons for ride rejections, assuming detailed rejection data was available.
```sql
SELECT 
    Rejection_Reason,
    COUNT(*) AS Total_Rejections
FROM gocabby_data
GROUP BY Rejection_Reason
ORDER BY Total_Rejections DESC;
```

Insights Driven: 
Driver Behavior: Insights into how different drivers perform and respond to ride requests, including variations in acceptance and rejection behaviors. 
Operational Insights: Understanding of city-wise operational differences and potential areas for improvement, such as addressing demand-supply gaps. 
Temporal Trends: Identification of trends over time, offering a view of how driver engagement and performance have evolved. 
Performance Benchmarking: Ability to identify top-performing drivers and understand the characteristics of high performance.
Strategic Decision Making: The analysis provides a data-driven foundation for making strategic decisions to enhance operational efficiency and driver engagement. 
I was able to get multi-dimensional insights into driver performance, operational efficiency, and customer engagement, which are crucial for strategic decision-making in the ride-hailing service domain.
