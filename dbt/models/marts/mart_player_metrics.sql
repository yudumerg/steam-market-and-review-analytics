with players as (

    select *
    from {{ ref('stg_players') }}

),

purchased as (

    select
        player_id,
        count(*) as purchased_games_count
    from {{ ref('stg_purchased_games') }}
    group by player_id

),

friends as (

    select
        player_id,
        count(*) as friends_count
    from {{ ref('stg_friends') }}
    group by player_id

),
prices as (
    select

    pg.player_id,
    round(avg(pr.usd), 2) as avg_game_price,
    round(sum(pr.usd), 2) as estimated_total_value

from {{ ref('stg_purchased_games') }} pg
left join {{ ref('stg_prices') }} pr
    on pg.game_id = pr.game_id
group by pg.player_id
),
achievement_counts as (

    select *
    from {{ ref('int_player_achievements') }}

)

select

    players.player_id,
    players.country,
    players.created_year,
    coalesce(purchased.purchased_games_count, 0) as purchased_games_count,
    coalesce(friends.friends_count, 0) as friends_count,
    coalesce(prices.avg_game_price, 0) as avg_game_price,
    coalesce(prices.estimated_total_value, 0) as estimated_total_value,
    coalesce(achievement_counts.achievement_count, 0) as achievement_count,
    extract(year from current_date()) - players.created_year as account_age_years,

from players
left join purchased
    on players.player_id = purchased.player_id
left join friends
    on players.player_id = friends.player_id
left join achievement_counts
    on players.player_id = achievement_counts.player_id
left join prices
    on players.player_id = prices.player_id