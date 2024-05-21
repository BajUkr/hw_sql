-- 1. Install the required extension
create extension if not exists postgres_fdw;

-- 2. Create a foreign server that connects to 'db_two'
create server if not exists same_server_postgres
    foreign data wrapper postgres_fdw
    options (dbname 'db_two');

-- 3. Create a user mapping for the current user
create user mapping if not exists for current_user
    server same_server_postgres
    options (user 'postgres', password 'frog2003'); 

-- 4. Define a foreign table that maps to 'remote_table' in 'db_two'
create foreign table if not exists local_remote_table (
   id integer,
   name varchar(255),
   age integer
)
server same_server_postgres
options (schema_name 'public', table_name 'remote_table');

-- 5. Select all records from the foreign table
select * from local_remote_table;

-- 6. Insert a new record into the foreign table
insert into local_remote_table (id, name, age) values (4, 'Yan Marchan', 20);

-- 7. Update an existing record in the foreign table
update local_remote_table set age = 20 where name = 'Yana Mazurenko';

-- 8. Delete a record from the foreign table
delete from local_remote_table where name = 'Mykola Lysenko';

-- 9. Create a local table
create table if not exists local_table (
    id serial primary key,
    name varchar(255),
    email varchar(255) unique not null
);

-- 10. Insert sample data into the local table
insert into local_table (name, email) values
    ('Yan Marchan', 'marchan.yan@student.ehu.lt'),
    ('Yana Mazurenko', 'mazurenko.yana@student.ehu.lt'),
    ('Mykola Lysenko', 'lysenko.mykola@student.ehu.lt');

-- 11. Join the local table with the foreign table to fetch combined data
select r.*, l.email
from local_remote_table as r 
left join local_table as l on r.name = l.name;