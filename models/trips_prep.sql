
select
    id,
    user_id,
    scooter_hw_id,
    started_at,
    finished_at,
    start_lat,
    start_lon,
    finish_lat,
    finish_lon,
    distance as distance_m,
    CAST(price AS Decimal(20, 2)) / 100 as price_rub,
    dateDiff('second', started_at, finished_at) as duration_s,
    if((finished_at != started_at) and (price = 0), 1, 0) as is_free,
    toDate(started_at) as "date"
from
    {{ source("dev", "trips") }}