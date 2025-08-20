SELECT
    t.*,
    u.sex,
    toYear(t.started_at) - toYear(u.birth_date) AS age
FROM
    {{ ref('trips_prep') }} AS t
LEFT JOIN
    {{ source('dev', 'users') }} AS u
    ON t.user_id = u.id
{% if is_incremental() %}
    where
        t.id > (select max(id) from {{ this }})
    order by
        t.id
    limit
        75000
{% else %}
    where
        t.id <= 75000
{% endif %}