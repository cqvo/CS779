-- We receive the raw json back from Plaid and store it in this staging table
create table public.staging_report
(
    id serial
        constraint staging_report_pk
            primary key,
    created_at timestamp default current_timestamp not null,
    data jsonb not null
);

-- We can flatten the json enough to be in a much more usable format
select
    data->'report'->>'asset_report_id' as asset_report_id,
    data->'report'->>'client_report_id' as client_report_id,
    cast(data->'report'->>'date_generated' as timestamp) as created_at,
    account->>'account_id' as account_id,
    account->'transactions' as transactions,
    account->'historical_balances' as historical_balances
from staging_report
cross join lateral jsonb_array_elements(data->'report'->'items') as items(item)
cross join lateral jsonb_array_elements(items.item->'accounts') as account
where id = 1;

-- And now we need a place to store it
create table public.dim_reports
(
    id serial
        constraint dim_reports_pk
            primary key,
    plaid_id varchar not null,
    client_report_id varchar not null,
    report_request_id int not null
        constraint dim_reports_fact_report_requests
            references public.fact_report_requests (id),
    account_id varchar not null,
    created_at timestamp default current_timestamp not null,
    transactions jsonb,
    historical_balances jsonb
);
