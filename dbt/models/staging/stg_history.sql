select

    cast(playerid as string) as player_id,
    achievementid,
    cast(date_acquired as timestamp) as acquired_at,
    date(cast(date_acquired as timestamp)) as acquired_date

from {{ source('steam_raw', 'history') }}