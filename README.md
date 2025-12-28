# 🚕 Chicago Fleet Operations  
## Logistics Telemetry & Efficiency Optimization

![Dashboard Preview](./dashboard_preview.png)

---

## 📝 Table of Contents
1. [Business Problem](#-business-problem)
2. [Project Objective](#-project-objective)
3. [The Data](#-the-data)
4. [Technical Solution Stack](#-technical-solution-stack)
5. [Data Engineering (SQL)](#-data-engineering-sql)
6. [Key Insights & Business Impact](#-key-insights--business-impact)
7. [How to Use This Dashboard](#-how-to-use-this-dashboard)
8. [Author](#-author)

---

## 📉 Business Problem

Urban transportation fleets in **Chicago** operate in a highly dynamic and cost-sensitive environment.  
Prior to this project, fleet operators lacked consolidated visibility into key operational risks, including:

- **Cost Inefficiency:** Elevated *Operational Cost Per Mile (OCPM)* on specific routes went undetected.
- **Traffic Impact:** Limited understanding of how peak-hour congestion reduced fleet velocity (MPH) and increased idle time.
- **Profitability Leakage:** Long-distance, low-yield trips (*Deadhead Trips*) were not quantified, gradually eroding margins.

This lack of insight constrained data-driven operational and pricing decisions.

---

## 🎯 Project Objective

The goal of this project was to design and implement a **Logistics Control Tower** dashboard that delivers actionable insights into fleet performance.

The dashboard enables operations teams to:

- Monitor efficiency using a custom **Efficiency Index (OCPM)**.
- Identify congestion patterns to optimize driver schedules and shift allocation.
- Minimize **Deadhead Risk** while maximizing **Gratuity Yield (Tips)**.
- Support strategic decisions related to routing, pricing, and payment methods.

---

## 📊 The Data

- **Source:** `bigquery-public-data.chicago_taxi_trips`
- **Period:** 2024–2025
- **Scale:** +100,000 trip records

### Key Engineered Metrics

- **Operational Cost Per Mile (OCPM):**  
  `(Fare + Tolls) / Distance`
- **Fleet Velocity:**  
  Average speed in Miles Per Hour (MPH)
- **Deadhead Risk Rate:**  
  Percentage of trips longer than 10 miles with a yield below `$1.50 / mile`

---

## 🛠️ Technical Solution Stack

- **Google BigQuery (SQL):**  
  Advanced data extraction, cleansing, and feature engineering.
- **Power BI:**  
  Data modeling, DAX measures, and executive-level analytics.
- **Power Query:**  
  Data transformation, weekday normalization, and custom sorting.
- **UI / UX:**  
  Industrial *Dark Mode* theme optimized for high-contrast telemetry monitoring.

---

## 💻 Data Engineering (SQL)

Data processing was performed in **BigQuery** using layered **CTEs** to ensure scalability, readability, and analytical accuracy before ingestion into Power BI.

```sql
/* Final Query for Logistics Optimization
   Target: BigQuery Public Dataset
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
    AND trip_miles > 0.5
    AND fare > 0
    AND pickup_community_area IS NOT NULL 
    AND dropoff_community_area IS NOT NULL
),

metrics AS (
  SELECT *,
    SAFE_DIVIDE(base_operational_cost, trip_miles) AS cost_per_mile,
    SAFE_DIVIDE(trip_miles, (trip_seconds / 3600)) AS avg_speed_mph,
    CASE 
      WHEN trip_miles > 10 AND (fare / trip_miles) < 1.5 THEN 1 
      ELSE 0 
    END AS high_deadhead_risk
  FROM base_trips
)

SELECT *
FROM metrics
WHERE avg_speed_mph < 85
  AND cost_per_mile < 40;
---
🔍 Key Insights & Business Impact
1️⃣ Fleet Velocity & Congestion Impact

Insight:
The fleet operates at an average speed of 18.44 MPH, with significant performance degradation during peak congestion windows. Critical bottlenecks occur between 3:00 PM and 6:00 PM, where velocity consistently falls below the daily average.

Business Impact:
Reduced speed increases idle time, lowers trip frequency, and amplifies operational cost per mile.

Actionable Recommendation:
Prioritize short-distance trips in high-density zones during peak hours and redesign shift rotations to preserve throughput.

2️⃣ Operational Cost Per Mile (OCPM) Optimization

Insight:
The average OCPM is $4.36, with specific pickup–dropoff routes showing extreme cost spikes driven by toll infrastructure and congested zones.

Business Impact:
Persistently high OCPM erodes margins and limits route-level profitability.

Actionable Recommendation:

Renegotiate pricing for high-OCPM routes.

Explore alternative, non-toll paths for non-priority fleet movements.

3️⃣ Deadhead Risk & Trip Profitability

Insight:
Only 0.1% of trips fall into the high deadhead risk category, but these trips have a disproportionate impact on total margin.

Business Impact:
Even a small volume of low-yield long-distance trips can generate material revenue leakage over time.

Actionable Recommendation:
Flag high-risk trips in real time and apply dynamic pricing or route reassignment strategies.

4️⃣ Payment Method & Gratuity Yield

Insight:
Trips paid via digital methods (Credit Card / Mobile) consistently generate higher gratuities than cash transactions.

Business Impact:
Higher tip yield improves driver earnings and enhances revenue transparency.

Actionable Recommendation:
Incentivize digital payment adoption to maximize gratuity yield and financial traceability.

5️⃣ Executive-Level Decision Enablement

Insight:
The integration of OCPM, velocity, congestion, and payment metrics creates a unified Logistics Control Tower view.

Business Impact:
Operations leaders gain real-time visibility into cost drivers, congestion exposure, and profitability risks.

Actionable Recommendation:
Use this dashboard as a daily monitoring tool and a strategic planning asset for routing, pricing, and capacity decisions.

Developed by: Helian Fierro

LinkedIn: (https://www.linkedin.com/in/helian-fierro-oyola-143798206/)

Portfolio / GitHub: (https://helian1505.github.io/Projects/)
