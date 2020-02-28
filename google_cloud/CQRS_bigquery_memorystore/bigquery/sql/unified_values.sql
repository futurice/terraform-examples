WITH
    vendor1 AS (
        SELECT
            user as user,
            value as value,
            timestamp as timestamp,
            "vendor1" as source
        FROM
            `${vendor1}`
    ),
    prober AS (
        SELECT
            user as user,
            value as value,
            timestamp as timestamp,
            "prober" as source
        FROM
            `${prober}`
    ),
    combined AS (
        SELECT * FROM vendor1
        UNION ALL
        SELECT * FROM prober
    )
SELECT *, DATE(timestamp) as DAY FROM combined;
