--Kenny Khoi Tran
--Unoptimized Queries
-- Count how many times each event type occurred and calculate the total number of direct and indirect injuries and deaths, along with total property and crop damage. 
--The results are grouped by event type and sorted by the number of events in descending order.
--Unoptimized: This query will process 5 MB when run.

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








