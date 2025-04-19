--Kenny Khoi Tran

--Unoptimized Queries

--Query 1:
-- Count how many times each event type occurred and calculate the total number of direct and indirect injuries and deaths, along with total property and crop damage. 
--The results are grouped by event type and sorted by the number of events in descending order.
--This query will process 5 MB when run.

SELECT
  event_type,
  COUNT(*) AS event_count,
  SUM(IFNULL(injuries_direct, 0)) AS total_injuries_direct,
  SUM(IFNULL(injuries_indirect, 0)) AS total_injuries_indirect,
  SUM(IFNULL(deaths_direct, 0)) AS total_deaths_direct,
  SUM(IFNULL(deaths_indirect, 0)) AS total_deaths_indirect,
  SUM(IFNULL(damage_property, 0)) AS total_property_damage,
  SUM(IFNULL(damage_crops, 0)) AS total_crop_damage
FROM
  `bigquery-public-data.noaa_historic_severe_storms.storms_2024`
GROUP BY
  event_type
ORDER BY
  event_count DESC;


--Query 2:
--Top 10 states and event type combinations with the highest total number of severe storm events across 2023 and 2024 in descending order. 
--This query will process 4.8 MB when run. Elapsed time: 18 sec

SELECT
  s23.state,
  s23.event_type,
  s23.state_fips_code,
  COUNT(DISTINCT s23.event_id) AS event_count_2023,
  COUNT(DISTINCT s24.event_id) AS event_count_2024,
  COUNT(DISTINCT s23.event_id) + COUNT(DISTINCT s24.event_id) AS total_event_count
FROM
  `bigquery-public-data.noaa_historic_severe_storms.storms_2023` s23
JOIN
  `bigquery-public-data.noaa_historic_severe_storms.storms_2024` s24
ON
  s23.state_fips_code = s24.state_fips_code
  AND s23.event_type = s24.event_type
WHERE
  s23.state_fips_code IS NOT NULL
GROUP BY
  s23.state, s23.state_fips_code, s23.event_type
ORDER BY
  total_event_count DESC
LIMIT 10;



--Query 3:
--Top 100 tornado events from 2017 by fatality count, removing exact duplicates using DISTINCT. 
--Joins storm event data with tornado path data based on state FIPS codes and event dates, filtering only for 'tornado' events. 
--The result includes property damage costs, crop damage costs, injuries, fatalities, magnitude, and size of the tornado. 
--Sorted by fatality count in descending order.

--This query will process 7.39 MB when run.

SELECT DISTINCT
  s.event_id,
  s.state,
  DATE(s.event_begin_time) AS event_date,
  t.storm_date,
  t.storm_time,
  s.damage_property,
  s.damage_crops,
  t.magnitude AS tornado_magnitude,
  t.injured_count,
  t.fatality_count,
  t.length,
  t.width
FROM
  `bigquery-public-data.noaa_historic_severe_storms.storms_2017` s
JOIN
  `bigquery-public-data.noaa_historic_severe_storms.tornado_paths` t
ON
  s.state_fips_code = t.state_fips_code
  AND DATE(s.event_begin_time) = t.storm_date
WHERE
  LOWER(s.event_type) = 'tornado'
ORDER BY
  t.fatality_count DESC
  LIMIT 100;



--Query 4:
--Top 10 highest recorded sizes of hail in descending order.
--This query will process 3.42 MB when run.
SELECT
  MIN(h.timestamp) AS hail_time,
  MIN(s.event_id) AS event_id,
  h.state AS hail_state,
  h.county,
  h.location,
  h.size / 100.0 AS hail_size_inches,
  s.damage_property AS damage_property
FROM
  `bigquery-public-data.noaa_historic_severe_storms.hail_reports` h
LEFT JOIN
  `bigquery-public-data.noaa_historic_severe_storms.storms_2021` s
ON
  LOWER(h.state) = LOWER(s.state)
  AND DATE(h.timestamp) = DATE(s.event_begin_time)
  AND LOWER(s.event_type) = 'hail'
WHERE
  h.size IS NOT NULL
GROUP BY
  h.state, h.county, h.location, hail_size_inches, damage_property
ORDER BY
  hail_size_inches DESC
LIMIT 10;


--Query 5:
--Top 10 highest wind speeds from the wind_reports table in 2019 and joins them with related storm events from the storms_2019 table.
--Only includes storm events categorized as 'thunderstorm wind', 'high wind', or 'strong wind'. 
--Returns timestamp, wind speed, location, event type, and property damage. 
--Uses LEFT JOIN to include values from the wind reports table that do not match with the storms table.

--This query will process 4.53 MB when run.

SELECT
  MIN(w.timestamp) AS wind_time,
  s.event_type,
  w.state AS wind_state,
  w.county,
  w.location,
  w.speed AS wind_speed_mph,
  MIN(s.event_id) AS event_id,
  s.damage_property
FROM
  `bigquery-public-data.noaa_historic_severe_storms.wind_reports` w
LEFT JOIN
  `bigquery-public-data.noaa_historic_severe_storms.storms_2019` s
ON
  LOWER(w.state) = LOWER(s.state)
  AND DATE(w.timestamp) = DATE(s.event_begin_time)
  AND LOWER(s.event_type) IN ('thunderstorm wind', 'high wind', 'strong wind')
WHERE
  w.speed IS NOT NULL
GROUP BY
  w.state, w.county, w.location, wind_speed_mph, s.damage_property, s.event_type
ORDER BY
  wind_speed_mph DESC
LIMIT 10;


--Query 6:
--Top 10 tornadoes with the longest length of the path in miles in descending order.
--This query will process 2.8 MB when run.

SELECT
  storm_time,
  state_abbreviation,
  magnitude,
  length,              -- Length of the tornado path in miles
  width,               -- Width in feet
  injured_count,
  fatality_count,
FROM
  `bigquery-public-data.noaa_historic_severe_storms.tornado_paths`
WHERE
  length IS NOT NULL
ORDER BY
  length DESC
LIMIT 10;


--Query 7:
--Top 10 tornadoes with the highest fatality count in descending order.
--This query will process 2.8 MB when run.

SELECT
  storm_time,
  state_abbreviation,
  magnitude,
  length,
  width,
  injured_count,
  fatality_count,
FROM
  `bigquery-public-data.noaa_historic_severe_storms.tornado_paths`
WHERE
  fatality_count IS NOT NULL
ORDER BY
  fatality_count DESC
LIMIT 10;



--Query 8:
--Top 10 states with the highest recorded size of hail in descending order.
--This query will process 321.6 KB when run.

SELECT
  MIN(h.timestamp) AS hail_timestamp,
  h.state,
  h.county,
  h.location,
  h.size / 100.0 AS hail_size_inches,  --Size in 1/100 of an Inch (175 = 1.75in)
  STRING_AGG(h.comments, ' | ') AS all_comments  -- Concatenate all comments for the event since there are duplicate events with different comments
FROM
  `bigquery-public-data.noaa_historic_severe_storms.hail_reports` h
WHERE
  h.size IS NOT NULL
GROUP BY
  h.state, h.county, h.location, hail_size_inches
ORDER BY
  hail_size_inches DESC
LIMIT 10;

-- Jin Chen 
-- Unoptimized Queries
-- This query shows the Top 10 states with the Total Amount of casulaties by doing direct + indirect injuries/deaths from 2010 - 2024. 

SELECT
  state,
  COUNT(*) AS event_count,
  SUM(
    IFNULL(injuries_direct, 0) 
   + IFNULL(injuries_indirect, 0)
     + IFNULL(deaths_direct, 0)
    + IFNULL(deaths_indirect, 0)
  ) AS total_casualties
FROM
  `bigquery-public-data.noaa_historic_severe_storms.storms_*`
WHERE
  _TABLE_SUFFIX BETWEEN '2010' AND '2024'  -- using storms_* thus we can use _TABLE_SUFFIX to show which table each row comes from
GROUP BY
  state
ORDER BY
  total_casualties DESC
LIMIT
  10;



