select

    achievementid,
    cast(gameid as string) as game_id,
    title,
    description

from {{ source('steam_raw', 'achievements') }}