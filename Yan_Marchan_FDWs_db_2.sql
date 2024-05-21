-- 1. Create a sample table named remote_table
create table if not exists remote_table (
    id serial primary key,
    name varchar(255) not null,
    age integer not null
);

-- 2. Insert sample data into the remote_table
insert into remote_table (name, age) values
    ('Yan Marchan', 20),
    ('Yana Mazurenko', 20),
    ('Mykola Lysenko', 19);

-- 3. Select all records from remote_table to verify insertion
select * from remote_table;
