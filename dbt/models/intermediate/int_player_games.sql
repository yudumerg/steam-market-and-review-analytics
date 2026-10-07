with purchased as (

    select *
    from {{ ref('stg_purchased_games') }}

),

games as (

    select *
    from {{ ref('stg_games') }}

)

select

    purchased.player_id,
    purchased.game_id,
    games.title,
    games.genres,
    games.developers,
    games.publishers,
    games.release_date

from purchased

left join games
    on purchased.game_id = games.game_id