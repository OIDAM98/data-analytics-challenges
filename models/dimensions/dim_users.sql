{% if target.name == 'prod' %}
{% set tb = "bq" %}
{% else %}
{% set tb = "local" %}
{% endif %}

select 
    user_id as id,
    name as name,
from {{ source(tb, 'raw_orders') }}
group by 
    user_id,
    name
order by
    user_id