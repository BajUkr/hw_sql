-- 1. Alter dimemployee table to add new columns for tracking employment history
alter table dimemployee
drop constraint dimemployee_pkey;

alter table dimemployee
add column startdate timestamp,
add column enddate timestamp,
add column iscurrent boolean default true,
add column employeehistoryid serial primary key;

-- 2. Update existing records to initialize new columns
update dimemployee
set employeehistoryid = default;

update dimemployee
set startdate = hiredate,
    enddate = '9999-12-31';

-- 3. Create or replace function for updating employee records
create or replace function employees_update_function()
returns trigger as $$
begin
    if (old.title <> new.title or old.address <> new.address) and old.iscurrent and new.iscurrent then
        -- Mark the current record as outdated
        update dimemployee
        set enddate = current_timestamp,
            iscurrent = false
        where employeeid = old.employeeid and iscurrent = true;

        -- Insert a new record with updated details
        insert into dimemployee (employeeid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, homephone, extension, startdate, enddate, iscurrent)
        values (old.employeeid, old.lastname, old.firstname, new.title, old.birthdate, old.hiredate, new.address, old.city, old.region, old.postalcode, old.country, old.homephone, old.extension, current_timestamp, '9999-12-31', true);
    end if;
    return new;
end;
$$ language plpgsql;

-- 4. Drop the existing trigger if it exists and create a new trigger
drop trigger if exists employees_update_trigger on dimemployee cascade;
create trigger employees_update_trigger
after update on dimemployee
for each row
execute function employees_update_function();

-- 5. Check if the trigger works by updating employee records
-- Update the address of Yan Marchan
update dimemployee
set address = 'Vilnius'
where firstname = 'Yan' and lastname = 'Marchan' and iscurrent = true;

-- Update the title of Yana Mazurenko
update dimemployee
set title = 'manager'
where firstname = 'Yana' and lastname = 'Mazurenko' and iscurrent = true;
