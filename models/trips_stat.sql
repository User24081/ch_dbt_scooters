SELECT
    count(*) AS trips,
    count(DISTINCT user_id) AS users,
    avg(duration_s) / 60 AS avg_duration_m,
    sum(price_rub) as revenue_rub,
    countIf(price_rub = 0) / toFloat64(count()) * 100 AS free_trips_pct
FROM
    {{ ref("trips_prep") }}


