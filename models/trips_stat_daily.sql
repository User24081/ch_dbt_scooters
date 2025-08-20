
SELECT
    "date",
    count(*) AS trips,
    max(price_rub) as max_price_rub,
    avg(distance_m) / 1000 AS avg_distance_km,
    avg(price_rub) / avg(duration_s) * 60 as avg_price_rub_per_min
FROM
    {{ ref("trips_prep") }}
GROUP BY
    date
ORDER BY
    date