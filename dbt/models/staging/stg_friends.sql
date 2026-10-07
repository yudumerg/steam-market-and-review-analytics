select

    cast(playerid as string) as player_id,
    friends

from {{ source('steam_raw', 'friends') }}