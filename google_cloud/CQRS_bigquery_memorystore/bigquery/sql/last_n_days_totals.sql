WITH
  historical_window AS (
    SELECT
      user,
      day,
      adjusted_total
    FROM
      `${daily_totals}`
    WHERE
      day >= DATE_SUB(CURRENT_DATE, INTERVAL ${n_days} DAY) AND
      day <= CURRENT_DATE
  ),
  withKeyPrefix AS (
    SELECT
      *, CONCAT('${PREFIX}', user) AS KEY
    FROM 
      historical_window
  )
SELECT
  *
FROM
  withKeyPrefix

