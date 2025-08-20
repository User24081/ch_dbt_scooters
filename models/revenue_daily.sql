SELECT
    sum(price_rub) AS revenue_rub,
    "date",
    now() as updated_at
FROM
    {{ ref('trips_prep') }}
{% if is_incremental() %}
WHERE
    date >= (
        SELECT subtractDays(max(date), 2)
        FROM {{ this }}
    )
{% endif %}
GROUP BY
    "date"
ORDER BY
    "date"