select
    cast(playerid as string) as player_id,
    country,
    cast(created as timestamp) as created_at,
    date(cast(created as timestamp)) as created_date,
    extract(year from cast(created as timestamp)) as created_year

from {{ source('steam_raw', 'players') }}