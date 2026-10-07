select

    cast(gameid as string) as game_id,
    usd,
    eur,
    gbp,
    jpy,
    rub,
    date_acquired

from {{ source('steam_raw', 'prices') }}