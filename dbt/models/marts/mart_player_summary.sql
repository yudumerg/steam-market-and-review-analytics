with players as (

    select *
    from {{ ref('stg_players') }}

),

purchased as (

    select *
    from {{ ref('stg_purchased_games') }}

),

friends as (

    select *
    from {{ ref('stg_friends') }}

)

select

    players.player_id,
    players.country,
    players.created_year,
    purchased.game_id,
    friends.friends

from players

left join purchased
    on players.player_id = purchased.player_id
left join friends
    on players.player_id = friends.player_id