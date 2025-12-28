WITH base_trips AS (
  SELECT 
    unique_key AS trip_id, 
    taxi_id,
    pickup_community_area AS pickup_zone,
    dropoff_community_area AS dropoff_zone,
    trip_start_timestamp,
    trip_miles,
    trip_seconds,
    fare,
    tolls,
    tips,
    payment_type,
    company,
    -- Temporal attribute engineering
    EXTRACT(HOUR FROM trip_start_timestamp) AS hour_of_day,
    FORMAT_DATE('%A', DATE(trip_start_timestamp)) AS day_of_week,
    -- Base Operating Cost (Fare + Tolls)
    (COALESCE(fare, 0) + COALESCE(tolls, 0)) AS base_operational_cost
  FROM `bigquery-public-data.chicago_taxi_trips.taxi_trips`
  WHERE trip_start_timestamp >= '2024-01-01'
    AND trip_miles > 0.5 
    AND fare > 0
    AND pickup_community_area IS NOT NULL 
    AND dropoff_community_area IS NOT NULL
),
metrics AS (
  SELECT 
    *,
    -- Efficiency: Operating cost per mile
    SAFE_DIVIDE(base_operational_cost, trip_miles) AS cost_per_mile,
    -- Congestion: Average Speed (Miles/Hour)
    SAFE_DIVIDE(trip_miles, (trip_seconds / 3600)) AS avg_speed_mph,
    -- Identification of Deadhead Miles (Low-profitability trips: long distance, low fare)
    CASE WHEN trip_miles > 10 AND (fare / trip_miles) < 1.5 THEN 1 ELSE 0 END AS high_deadhead_risk
  FROM base_trips
)
SELECT * FROM metrics 
WHERE avg_speed_mph < 85 AND cost_per_mile < 40;