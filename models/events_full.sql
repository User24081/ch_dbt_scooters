SELECT
    *
FROM
    {{ ref('events_clean') }} AS events_clean
LEFT JOIN {{ ref('event_types') }} AS event_types
    ON events_clean.type_id = event_types.type_id