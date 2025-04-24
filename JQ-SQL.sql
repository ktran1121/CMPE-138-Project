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

-- Query 2 
-- Question: Find the average hailstone size for each county from 2010-2024 and how many distinct hail events happened at those counties?
-- Show the top 10 counties where the hail was largest on average.
-- This Query will find the top counties across all the states that will have the largest average hailstone size
-- over the years of 2010 - 2024, and it will show how many distinct hail-reporting timestamps each of those counties logged.
-- Bytes processed 105.78 KB
-- Bytes billed 10 MB

SELECT state, county, 
  AVG(size)/100                         AS avg_hail_size_in_inches, -- dividing by 100 so we get the actual inches instead of raw data
    -- hailstone diameter size in inches
  COUNT(DISTINCT timestamp)         AS hail_event_count -- This is assuming that no two separate hail events in the same county 
                                                        -- share the same exact timestamp
FROM            
  `bigquery-public-data.noaa_historic_severe_storms.hail_reports`  
WHERE
  EXTRACT(YEAR FROM timestamp) BETWEEN 2010 AND 2024 -- we are extracting the YEARS from the timestamp 2010 and 2024
  AND size IS NOT NULL -- It will exclude any rows where the hail size wasn't recorded so we only use REAL measurements.
GROUP BY
  state, county  -- Groups all the filtered rows by each unique state and county combination
ORDER BY
  avg_hail_size_in_inches DESC 
LIMIT
  10;

