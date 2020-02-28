SELECT
  user,
  ${NAME},
  timestamp AS timestamp_start,
  LEAD(timestamp, 1, CURRENT_TIMESTAMP()) OVER (PARTITION BY user ORDER BY timestamp ASC)
    AS timestamp_end
FROM
  `${OPERATIONS}`
WHERE
  timestamp > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)