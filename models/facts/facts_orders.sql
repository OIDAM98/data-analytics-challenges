{% if target.name == 'prod' %}
{% set tb = "bq" %}
{% else %}
{% set tb = "local" %}
{% endif %}

select 
    t.id as created_id,
    p.id as place_id,
    u.id as user_id,
    SUM(ro.orderprice) as price,
    SUM(ro.sumorders) as num_orders
from {{ source(tb, 'raw_orders') }} ro
inner join {{ ref('dim_time' )}} as t 
    {% if target.name == 'prod' %}
    on unix_seconds(ro.createdate) = t.id
    {% else %}
    on datepart('epoch', ro.createdate) = t.id
    {% endif %}
inner join {{ ref('dim_places') }} as p
    on COALESCE(ro.placename, 'n/a') = COALESCE(p.name, 'n/a') AND
    COALESCE(ro.house, 'n/a') = COALESCE(p.house, 'n/a') AND 
    COALESCE(ro.street, 'n/a') = COALESCE(p.street, 'n/a')
inner join {{ ref('dim_users') }} as u
    on ro.user_id = u.id
group by 
    t.id,
    p.id,
    u.id
