WITH query_ranked AS (
    SELECT 
        searchid,
        "year",
        "month",
        "day",
        userid,
        devicetype,
        deviceid,
        query,
        ts,
        LEAD(ts) OVER (PARTITION BY userid, devicetype, deviceid ORDER BY ts) AS next_ts,
        LEAD(query) OVER (PARTITION BY userid, devicetype, deviceid ORDER BY ts) AS next_query
    FROM search
)
SELECT 
    searchid,
    "year",
    "month",
    "day",
    userid,
    ts,
    devicetype,
    deviceid,
    query,
    CASE
        WHEN next_ts IS NULL THEN 1
        WHEN next_ts - ts > 180 THEN 1
        WHEN next_query IS NOT NULL AND LENGTH(next_query) < LENGTH(query) AND next_ts - ts > 60 THEN 2
        ELSE 0
    END AS is_final
FROM query_ranked
WHERE day = 20 and month = 11 and year = 2024 AND devicetype = 'android' AND (
    CASE
        WHEN next_ts IS NULL THEN 1
        WHEN next_ts - ts > 180 THEN 1
        WHEN next_query IS NOT NULL AND LENGTH(next_query) < LENGTH(query) AND next_ts - ts > 60 THEN 2
        ELSE 0
    END IN (1, 2));