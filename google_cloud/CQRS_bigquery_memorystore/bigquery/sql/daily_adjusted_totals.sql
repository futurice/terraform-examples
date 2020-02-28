WITH values_controls AS (
  SELECT *
  FROM `${values}`
  %{ for field in control_fields ~}
    JOIN `${control_prefix}${field}` ${field} USING (user)
  %{ endfor ~}
  WHERE TRUE
  %{ for field in control_fields ~}
    AND (timestamp >= ${field}.timestamp_start AND timestamp < ${field}.timestamp_end)
  %{ endfor ~}
)

SELECT
  user,
  day,
  SUM(value * multiplier) as adjusted_total  
FROM values_controls
GROUP BY user, day
