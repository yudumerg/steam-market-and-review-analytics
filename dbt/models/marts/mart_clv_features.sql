with player_metrics as (
    select *
from {{ ref('mart_player_metrics') }}
)

select
player_metrics.player_id,
player_metrics.purchased_games_count,
player_metrics.avg_game_price,
player_metrics.estimated_total_value,
player_metrics.achievement_count,
player_metrics.friends_count,
player_metrics.account_age_years,
safe_divide(
    player_metrics.achievement_count,
    nullif(player_metrics.purchased_games_count, 0)
) as achievement_per_game,

(
    coalesce(player_metrics.achievement_count,0) * 0.5
    +
    coalesce(player_metrics.purchased_games_count,0) * 0.3
    +
    coalesce(player_metrics.friends_count,0) * 0.2
) as engagement_score,

coalesce(player_metrics.estimated_total_value,0)
as monetary_score,

(
(
    coalesce(player_metrics.achievement_count,0) * 0.5
    +
    coalesce(player_metrics.purchased_games_count,0) * 0.3
    +
    coalesce(player_metrics.friends_count,0) * 0.2
) * 0.6
+
coalesce(player_metrics.estimated_total_value,0) * 0.4
)
as hybrid_score,

case
    when player_metrics.estimated_total_value >= 500 then 'VIP'
    when player_metrics.estimated_total_value >= 200 then 'HIGH'
    when player_metrics.estimated_total_value >= 50 then 'MEDIUM'
    else 'LOW'
end as clv_segment
,

case
    when (
        coalesce(player_metrics.achievement_count,0) * 0.5
        +
        coalesce(player_metrics.purchased_games_count,0) * 0.3
        +
        coalesce(player_metrics.friends_count,0) * 0.2
    ) >= 500 then 'HARDCORE'

    when (
        coalesce(player_metrics.achievement_count,0) * 0.5
        +
        coalesce(player_metrics.purchased_games_count,0) * 0.3
        +
        coalesce(player_metrics.friends_count,0) * 0.2
    ) >= 200 then 'ACTIVE'

    when (
        coalesce(player_metrics.achievement_count,0) * 0.5
        +
        coalesce(player_metrics.purchased_games_count,0) * 0.3
        +
        coalesce(player_metrics.friends_count,0) * 0.2
    ) >= 50 then 'CASUAL'

    else 'LOW_ACTIVITY'
end as engagement_segment,

case
    when player_metrics.estimated_total_value >= 1000 then 'WHALE'
    when player_metrics.estimated_total_value >= 500 then 'BIG_SPENDER'
    when player_metrics.estimated_total_value >= 100 then 'SPENDER'
    else 'LOW_SPENDER'
end as monetary_segment

from player_metrics