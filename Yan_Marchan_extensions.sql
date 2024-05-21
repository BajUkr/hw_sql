-- 1. Install necessary extensions
create extension if not exists pg_stat_statements;
create extension if not exists pgcrypto;

-- 2. List installed extensions to verify
select * from pg_extension;

-- 3. Create a new table called "employees"
create table if not exists employees (
   id serial primary key,
   first_name varchar(255) not null,
   last_name varchar(255) not null,
   email varchar(255) not null unique,
   encrypted_password text not null
);

-- 4. Insert sample employee data into the table
insert into employees (first_name, last_name, email, encrypted_password) values
   ('Yan', 'Marchieeeee', 'marchan.yan@student.ehu.lt', crypt('mypassword200', gen_salt('bf'))),
   ('Yana', 'Mazurenko', 'mazurenko.yana@student.ehu.lt', crypt('mypassword202', gen_salt('bf')),
   ('Mykola', 'Lysenko', 'lysenko.mykola@student.ehu.lt', crypt('mypassword203', gen_salt('bf')));

-- 5. Select all employees to verify data insertion
select * from employees;

-- 6. Update an employee's personal information
update employees 
set last_name = 'Marchan' 
where email = 'marchan.yan@student.ehu.lt';

-- Verify the update
select * from employees;

-- 7. Delete an employee record using the email column
delete from employees 
where email = 'marchan.yan@student.ehu.lt';

-- Verify the deletion
select * from employees;

-- 8. Configure the pg_stat_statements extension
-- Note: These changes require a restart of the PostgreSQL server to take effect.
alter system set shared_preload_libraries = 'pg_stat_statements';
alter system set pg_stat_statements.track = 'all';

-- 9. Run the following query to gather statistics for the executed statements
select * from pg_stat_statements;

-- 10. Analyze the output of the pg_stat_statements view
-- 10.1 Identify the most frequently executed queries
select query, calls 
from pg_stat_statements
order by calls desc;

-- 10.2 Determine which queries have the highest average and total runtime
select query, total_plan_time as total_time, total_plan_time / calls as avg_time
from pg_stat_statements
order by avg_time desc, total_time desc;