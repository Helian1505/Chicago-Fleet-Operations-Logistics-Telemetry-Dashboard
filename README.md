🚕 Chicago Fleet Operations: Logistics Telemetry & Efficiency Optimization
📋 Table of Contents
Business Problem

Project Objective

The Data

Technical Solution Stack

Data Engineering (SQL)

Insights & Strategic Recommendations

How to Use this Dashboard

📉 1. Business Problem
Urban transportation fleets in Chicago face a complex and high-cost environment. Before this project, the fleet lacked visibility into:

Cost Inefficiency: High Operational Cost Per Mile (OCPM) in specific routes went undetected.

Traffic Impact: No data on how peak-hour congestion directly degraded velocity (MPH) and increased idle time.

Profitability Leakage: "Deadhead" trips (long distances with low fares) were not quantified, affecting the overall margin.

🎯 2. Project Objective
To design and implement a Logistics Control Tower dashboard that provides real-time visibility into fleet performance, allowing the operations team to:

Monitor efficiency through a custom Efficiency Index (OCPM).

Analyze congestion patterns to optimize driver shifts.

Minimize Deadhead Risk and maximize Gratuity Yield (Tips).

📊 3. The Data
Source: bigquery-public-data.chicago_taxi_trips (2024-2025 Dataset).

Scale: +100,000 trip records.

Key Engineered Metrics:

OCPM: Operational Cost Per Mile (Fare + Tolls / Distance).

Fleet Velocity: Average speed in Miles Per Hour (MPH).

Deadhead Risk: Flag for trips >10 miles with a yield < $1.5/mile.

🛠️ 4. Technical Solution Stack
Google BigQuery (SQL): Advanced data extraction and feature engineering.

Power BI: Data modeling and DAX for business logic.

Power Query: Data cleaning and custom sorting for chronological weekdays.

UI/UX: "Industrial Dark Mode" theme for high-contrast telemetry monitoring.

💻 5. Data Engineering (SQL)
The data was processed in BigQuery using CTEs to ensure scalability and clean metrics before importing to Power BI.

SQL

/* Final Query for Logistics Optimization 
Script located at: /sql_scripts/logistics_query.sql 
*/
WITH base_trips AS (
  SELECT 
    unique_key AS trip_id,
    pickup_community_area AS pickup_zone,
    dropoff_community_area AS dropoff_zone,
    trip_start_timestamp,
    trip_miles,
    trip_seconds,
    fare,
    tolls,
    payment_type,
    EXTRACT(HOUR FROM trip_start_timestamp) AS hour_of_day,
    FORMAT_DATE('%A', DATE(trip_start_timestamp)) AS day_of_week,
    (COALESCE(fare, 0) + COALESCE(tolls, 0)) AS base_operational_cost
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE trip_start_timestamp >= '2024-01-01'
    AND trip_miles > 0.5 AND fare > 0
    AND pickup_community_area IS NOT NULL 
    AND dropoff_community_area IS NOT NULL
),
metrics AS (
  SELECT *,
    SAFE_DIVIDE(base_operational_cost, trip_miles) AS cost_per_mile,
    SAFE_DIVIDE(trip_miles, (trip_seconds / 3600)) AS avg_speed_mph,
    CASE WHEN trip_miles > 10 AND (fare / trip_miles) < 1.5 THEN 1 ELSE 0 END AS high_deadhead_risk
  FROM base_trips
)
SELECT * FROM metrics 
WHERE avg_speed_mph < 85 AND cost_per_mile < 40;

💡 6. Insights & Strategic Recommendations (Verified)
A. Velocity & Congestion Patterns
Discovery: The Fleet Velocity averages 18.44 MPH. However, the Congestion Heatmap reveals "Red Zones" between 3:00 PM and 6:00 PM, where velocity drops significantly below the average.

Recommendation: Implement shift rotations that prioritize "short-hop" trips in high-density zones during peak hours to maintain trip frequency.

B. Operational Cost Per Mile (OCPM)
Discovery: The average OCPM stands at $4.36. The Efficiency Matrix identifies specific routes (e.g., Zone 8 to Zone 24) where costs spike due to infrastructure tolls.

Recommendation: Renegotiate base rates for these high-OCPM routes or analyze alternative non-toll paths for non-priority fleet movements.

C. Profitability & Payment Yield
Discovery: The Deadhead Risk Rate is controlled at 0.1%, but the Revenue Stream Analysis shows that "Credit Card" and "Mobile" payments generate significantly higher tips than "Cash".

Recommendation: Increase digital payment adoption through driver incentives to maximize total earnings and improve financial transparency.

🖥️ 7. How to Use this Dashboard
Global Filters: Use the top button slicers to filter by Day of the Week and Company.

Congestion Heatmap: Identify temporal bottlenecks (Hour vs. Day).

Efficiency Matrix: Visualize the "Pure Heatmap" (color-coded) to find high-cost route patterns without numerical noise.

Infrastructure Leakage: Monitor the impact of tolls on different payment methods over time.

Developed by: Helian Fierroo LinkedIn: (https://www.linkedin.com/in/helian-fierro-oyola-143798206/) Portfolio:(https://helian1505.github.io/Projects/)
