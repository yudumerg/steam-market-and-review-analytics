with player_metrics as (

    select *
    from {{ ref('mart_player_metrics') }}

)

select

    country,
    count(distinct player_id) as total_players,
    avg(purchased_games_count) as avg_games_per_player,
    avg(friends_count) as avg_friends_per_player

from player_metrics
where country is not null
group by country