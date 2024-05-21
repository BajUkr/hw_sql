-- 1. Create the main table with range partitioning
create table if not exists sales_data(
    sale_id serial,
    product_id integer not null,
    region_id integer not null,
    salesperson_id integer not null,
    sale_amount numeric not null,
    sale_date date not null,
    primary key (sale_id, sale_date)
) partition by range (sale_date);

-- 2. Create partitions for the past 12 months
do $$ 
declare 
    start_date date := '2023-01-01';
    end_date date := '2024-01-01';
    partition_date date;
begin 
    partition_date := start_date;
    while partition_date < end_date loop 
        execute format('create table if not exists sales_data_%s partition of sales_data for values from (%L) to (%L)', 
                       to_char(partition_date, 'YYYY_MM'), partition_date, partition_date + interval '1 month');
        partition_date := partition_date + interval '1 month';
    end loop;
end $$;

-- 3. Function to generate and insert synthetic data
create or replace function generate_insert_data()
returns void
language plpgsql
as $$
declare
    sale_date date;
    new_sale_id integer;
begin
    for counter in 1..1000 loop
        sale_date := '2023-01-01'::date + (floor(random() * 365) * interval '1 day');
        new_sale_id := counter;

        insert into sales_data (sale_id, sale_date, salesperson_id, region_id, product_id, sale_amount)
        values (
            new_sale_id,
            sale_date,
            1 + floor(random() * 6),  -- salesperson_id
            1 + floor(random() * 10), -- region_id
            1 + floor(random() * 8),  -- product_id
            40 + floor(random() * 1000)  -- sale_amount
        );
    end loop;
end;
$$;

-- Generate and insert synthetic data
select generate_insert_data();

-- 4. Queries for analysis

-- Retrieve all sales in a specific month
select 
    extract(month from sale_date) as month_sale,
    count(*) as month_total
from sales_data
group by month_sale
order by month_sale;

-- Calculate the total sale_amount for each month
select 
  extract(month from sale_date) as month_sale, 
  sum(sale_amount) as total_amount
from sales_data
group by month_sale
order by month_sale;

-- Identify the top three salesperson_id values by sale_amount within a specific region
with person_sale as (
    select 
        salesperson_id,
        region_id,
        sum(sale_amount) as total_amount,
        rank() over (partition by region_id order by sum(sale_amount) desc) as person_rank
    from 
        sales_data
    group by 
        region_id, salesperson_id
)
select 
    salesperson_id,
    region_id,
    total_amount
from 
    person_sale
where 
    person_rank <= 3;

-- 5. Procedure for partition management
create or replace procedure manage_partitions()
language plpgsql
as $$
declare
    current_date date := current_date;
    last_year_date date := current_date - interval '1 year';
    next_month_start date := date_trunc('month', current_date + interval '1 month');
    next_month_end date := next_month_start + interval '1 month';
    partition_date_to_remove date;
    partition_date_to_add date;
    partition_name varchar;
    next_month_name varchar;
begin
    -- Drop partitions older than 12 months
    for counter in 0..11 loop
        partition_date_to_remove := last_year_date - (interval '1 month' * counter);
        partition_name := 'sales_data_' || to_char(partition_date_to_remove, 'yyyy_mm');
        if to_regclass(partition_name) is not null then
            execute format('drop table %I', partition_name);
            raise notice 'Dropped partition: %', partition_name;
        else
            raise notice 'Partition % does not exist, skipping drop.', partition_name;
        end if;
    end loop;

    -- Create partitions for the next month
    for counter in 0..11 loop
        partition_date_to_add := next_month_start - (interval '1 month' * counter);
        next_month_name := 'sales_data_' || to_char(partition_date_to_add, 'yyyy_mm');
        if to_regclass(next_month_name) is null then
            execute format('create table %I partition of sales_data for values from (%L) to (%L)', 
                           next_month_name, partition_date_to_add, partition_date_to_add + interval '1 month');
            raise notice 'Created partition: %', next_month_name;
        else
            raise notice 'Partition % already exists, skipping creation.', next_month_name;
        end if;
    end loop;
end;
$$;

-- Call the procedure to manage partitions
call manage_partitions();
