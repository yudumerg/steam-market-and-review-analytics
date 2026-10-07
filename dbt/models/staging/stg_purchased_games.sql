select

    cast(playerid as string) as player_id,
    cast(game as string) as game_id
from {{ source('steam_raw', 'purchased_games') }},
unnest(
    split(
        replace(
            replace(library, '[', ''),
            ']',
            ''
        ),
        ','
    )
) as game