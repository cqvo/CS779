-- Searching for if a client has any open link requests
select *
    from fact_link_requests l
    where l.client_id = 5
    and l.expiration >= current_timestamp
    and l.status != 'Completed';

-- Maybe make a unique index on client_id with some filters?
-- Can't do it, index won't work with a mutable object like current_timestamp
-- Needs to be statically enforceable
create unique index fact_link_requests_client_id_open
    on public.fact_link_requests (client_id)
    where status = 'Pending' and expiration >= current_timestamp;
-- Making it statically enforceable
alter table public.fact_link_requests
    add column current_ts timestamp default current_timestamp;

create or replace function set_current_ts()
    returns trigger as $$
        begin
            NEW.current_ts := current_timestamp;
            return new;
        end;
    $$ language plppgsql;

create trigger update_current_ts
    before insert or update on public.fact_link_requests
    for each row
    execute function set_current_ts();

create unique index fact_link_requests_client_id_open
    on public.fact_link_requests (client_id)
    where status = 'Pending'
    and expiration >= current_ts;

-- Make a function that triggers before inserts
create or replace function enforce_single_open_request()
    returns trigger as $$
    begin
        if exists (
            select 1
            from public.fact_link_requests
            where client_id = NEW.client_id
            and status = 'Pending'
            and expiration >= current_timestamp
        ) then
            raise exception 'There is already an open link request for this client ID';
        end if;
        return new;
    end;
    $$ language plppgsql;

create trigger check_pending_links
    before insert on public.fact_link_requests
    for each row
    execute function enforce_single_open_request();
