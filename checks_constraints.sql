create type day_names as enum ('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
create type month_names as enum ('January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December');
create table public.dim_date
(
    id           serial      not null
        constraint dim_date_pk
            primary key,
    date         date        not null
        constraint dim_date_pk_2
            unique,
    year         int         not null,
    quarter      int         not null,
    month        int         not null,
    mont_name    month_names not null,
    day          int         not null,
    day_of_week  int         not null,
    day_name     day_names   not null,
    is_weekend   bool        not null,
    week_of_year int         not null,
    constraint valid_day
        check (dim_date.day between 1 and 31),
    constraint valid_day_of_week
        check (dim_date.day_of_week between 1 and 7),
    constraint valid_month
        check (dim_date.month between 1 and 12),
    constraint valid_quarter
        check (dim_date.quarter between 1 and 4)
);
