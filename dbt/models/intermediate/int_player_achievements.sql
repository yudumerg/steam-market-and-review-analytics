select

    player_id,
    count(distinct achievementid) as achievement_count

from {{ ref('stg_history') }}
group by player_id