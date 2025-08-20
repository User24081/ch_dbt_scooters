select
    countIf("type" = 'cancel_search')
      / cast(countIf("type" = 'start_search') as Float64)
      * 100 as cancel_pct
from
    {{ ref('events_full') }}