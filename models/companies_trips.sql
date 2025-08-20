SELECT
    t.company,
    t.trips,
    c.scooters,
    t.trips / toFloat64(c.scooters) AS trips_per_scooter
FROM
    (
        SELECT
            s.company,
            count(*) AS trips
        FROM
            {{ ref("trips_prep") }} AS t
            JOIN {{ ref("scooters") }} AS s
                ON t.scooter_hw_id = s.hardware_id
        GROUP BY
            s.company
    ) AS t
    JOIN {{ ref("companies") }} AS c
        ON t.company = c.company