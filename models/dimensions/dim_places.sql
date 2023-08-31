{% if target.name == 'prod' %}
{% set tb = "bq" %}
{% else %}
{% set tb = "local" %}
{% endif %}

with grouped as (
    select 
    placename as name,
    street,
    house
    from {{ source(tb, 'raw_orders') }}
    group by 
        placename,
        street,
        house
)
, ranked as (
    select 
        *,
        row_number() OVER () as rownumber
    from grouped
)

SELECT
    md5( 
        COALESCE(name, 'n/a') || 
        COALESCE(street, 'n/a') || 
        COALESCE(house, 'n/a') || 
        CAST(rownumber as STRING)
    ) as id,
    name,
    street,
    house
FROM ranked
order by rownumber