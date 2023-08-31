{% if target.name == 'prod' %}
{% set tb = "bq" %}
{% else %}
{% set tb = "local" %}
{% endif %}

with all_dates as (
    select 
        distinct createdate as created_ts
    from {{ source(tb, 'raw_orders') }}
)
, final as (
    select
    {% if target.name == 'prod' %}
        unix_seconds(created_ts) as id,
        created_ts,
        extract(DATE FROM created_ts) as created_date,
        extract(YEAR FROM created_ts) as created_year,
        extract(MONTH FROM created_ts) as created_month,
        format_timestamp('%B', created_ts) as created_month_dsc,
        extract(DAYOFWEEK FROM created_ts) as created_day,
        format_timestamp('%A', created_ts) as created_day_dsc,
        extract(TIME FROM created_ts) as created_time,
        extract(HOUR FROM created_ts) as created_hour,
        extract(MINUTE FROM created_ts) as created_minute
    {% else %}
        datepart('epoch', created_ts) as id,
        created_ts,
        datetrunc('day', created_ts) as created_date,
        datepart('year', created_ts) as created_year,
        datepart('month', created_ts) as created_month,
        monthname(created_ts) as created_month_dsc,
        datepart('day', created_ts) as created_day,
        dayname(created_ts) as created_day_dsc,
        cast(created_ts as time) as created_time,
        datepart('hour', created_ts) as created_hour,
        datepart('minute', created_ts) as created_minute
    {% endif %}
    from all_dates
    order by id
)
select * from final order by id