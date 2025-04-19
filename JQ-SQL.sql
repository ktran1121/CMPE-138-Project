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
