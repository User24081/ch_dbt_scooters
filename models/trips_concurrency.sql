
SELECT
    "timestamp",
    sum(increment) OVER (ORDER BY "timestamp") AS concurrency
FROM
(
    SELECT
        "timestamp",
        sum(increment) AS increment,
        true as preserve_row
    FROM
     
    (
        SELECT
            started_at,
            finished_at
        FROM {{ source('dev', 'trips') }}
    ) t
    ARRAY JOIN
        [t.started_at, t.finished_at] AS "timestamp",
        [1, -1] AS increment
    where
    {% if is_incremental() %}
        "timestamp" > (select max("timestamp") from {{ this }})
    {% else %}
        "timestamp" < (toDate('2023-06-01') + toIntervalHour(7))
    {% endif %}
    group by
        "timestamp"
    {% if is_incremental() %}
    union all
    select
        "timestamp",
        concurrency as increment,
        false as preserve_row
    from
        {{ this }}
    where
        "timestamp" = (select max("timestamp") from {{ this }})
    {% endif %}
    
)
ORDER BY "timestamp"