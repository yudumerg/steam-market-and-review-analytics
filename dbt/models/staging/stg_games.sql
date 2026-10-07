select

    cast(gameid as string) as game_id,
    title,
    developers,
    publishers,
    genres,
    supported_languages,
    release_date

from {{ source('steam_raw', 'games') }}