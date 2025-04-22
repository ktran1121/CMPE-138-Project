-- Jin Chen 
-- Unoptimized Queries
-- This query shows the Top 10 states with the Total Amount of casulaties by doing direct + indirect injuries/deaths 
-- from 2023 - 2024. 
-- Changing to distinct so it counts the events and casualties once.
-- Results will have the event_count and total_casualties which is UNIQUE so there are no duplicates of deaths or injuries
-- or duplicates of event_id. The total_casualties will be the sum of schemas from storms 2022-2024 in respect to the state.
-- Bytes processed 8.63 MB, Bytes billed 20 MB

SELECT   
  s.state,
  COUNT(DISTINCT s.event_id) AS event_count,
  SUM(DISTINCT                       -- Changing to DISTINCT to make sure there are no duplicates 
    IFNULL(s.injuries_direct, 0)
  + IFNULL(s.injuries_indirect, 0)
    + IFNULL(s.deaths_direct, 0)
    + IFNULL(s.deaths_indirect, 0)
  ) AS total_casualties
FROM
  `bigquery-public-data.noaa_historic_severe_storms.storms_*` AS s
JOIN
  `bigquery-public-data.noaa_historic_severe_storms.nws_forecast_regions` AS r  ON s.wfo = r.cwa
WHERE
  _TABLE_SUFFIX IN ('2023', '2024') -- using storms_* thus we can use _TABLE_SUFFIX to show which table each row comes from
GROUP BY
  s.state
ORDER BY
  total_casualties DESC
LIMIT
  10;
