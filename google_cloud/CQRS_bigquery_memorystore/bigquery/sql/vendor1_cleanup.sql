WITH
  ingress AS (
    SELECT
      timestamp,
      /* Assumed payload structure:
      {"user": "29837", "values": [5, 4, 3, 5, 2, 1]}
      */
      payload
    FROM
      `${ingress}`
  ), 
  extraction AS (
    SELECT *,
      JSON_EXTRACT_SCALAR(payload, '$.user') as user,
      `${urdfs}`.CUSTOM_JSON_EXTRACT_ARRAY_FLOAT(payload, '$.values[*]') as values
    FROM ingress
  )

SELECT user, timestamp, value
FROM extraction
JOIN UNNEST(values) as value
