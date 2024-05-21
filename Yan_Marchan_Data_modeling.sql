-- 1. Create staging tables
create table if not exists staging_order_details (
    orderid     int not null,
    productid   int not null,
    unitprice   decimal(10, 2) not null,
    qty         smallint not null,
    discount    decimal(10, 2) not null
);

create table if not exists staging_customers (
    customerid       serial primary key not null,
    companyname  varchar(40) not null,
    contactname  varchar(30) null,
    contacttitle varchar(30) null,
    address      varchar(60) null,
    city         varchar(15) null,
    region       varchar(15) null,
    postalcode   varchar(10) null,
    country      varchar(15) null,
    phone        varchar(24) null,
    fax          varchar(24) null
);

create table if not exists staging_employees (
     employeeid      serial  primary key not null, 
     lastname        varchar (20) not null, 
     firstname       varchar (10) not null, 
     title           varchar (30) null, 
     titleofcourtesy varchar (25) null, 
     birthdate       timestamp null, 
     hiredate        timestamp null, 
     address         varchar (60) null, 
     city            varchar (15) null, 
     region          varchar (15) null, 
     postalcode      varchar (10) null, 
     country         varchar (15) null, 
     phone           varchar (24) null, 
     extension       varchar (4) null, 
     photo           bytea null, 
     notes           text null, 
     mgrid           int null, 
     photopath       varchar (255) null
);

create table if not exists staging_products (
    productid       serial primary key not null,
    productname     varchar(40) not null,
    supplierid      int null,
    categoryid      int null,
    quantityperunit varchar(20) null,
    unitprice       decimal(10, 2) null,
    unitsinstock    smallint null,
    unitsonorder    smallint null,
    reorderlevel    smallint null,
    discontinued    char(1) not null
);

create table if not exists staging_categories (
    categoryid   serial primary key not null,
    categoryname varchar(15) not null,
    description  text null,
    picture      bytea null
);

create table if not exists staging_shippers (
    shipperid   serial primary key not null,
    companyname varchar(40) not null,
    phone       varchar(44) null
);

create table if not exists staging_suppliers (
    supplierid   serial primary key not null,
    companyname  varchar(40) not null,
    contactname  varchar(30) null,
    contacttitle varchar(30) null,
    address      varchar(60) null,
    city         varchar(15) null,
    region       varchar(15) null,
    postalcode   varchar(10) null,
    country      varchar(15) null,
    phone        varchar(24) null,
    fax          varchar(24) null,
    homepage     text null
);

create table if not exists staging_orders (
    orderid        serial primary key not null,
    customerid     int null,
    employeeid     int null,
    orderdate      timestamp null,
    requireddate   timestamp null,
    shippeddate    timestamp null,
    shipperid      int null,
    freight        decimal(10, 2) null,
    shipname       varchar(40) null,
    shipaddress    varchar(60) null,
    shipcity       varchar(15) null,
    shipregion     varchar(15) null,
    shippostalcode varchar(10) null,
    shipcountry    varchar(15) null
);

-- 2. Create dimension and fact tables
create table if not exists dimdate (
    dateid serial primary key,
    date date,
    day int,
    month int,
    year int,
    quarter int,
    weekofyear int
);

create table if not exists dimcustomer (
    customerid serial primary key,
    companyname varchar(255),
    contactname varchar(255),
    contacttitle varchar(255),
    address varchar(255),
    city varchar(255),
    region varchar(255),
    postalcode varchar(10),
    country varchar(255),
    phone varchar(20)
);

create table if not exists dimproduct (
    productid serial primary key,
    productname varchar(255),
    supplierid int,
    categoryid int,
    quantityperunit varchar(255),
    unitprice decimal(10, 2),
    unitsinstock int
);

create table if not exists dimemployee (
    employeeid serial primary key,
    lastname varchar(255),
    firstname varchar(255),
    title varchar(255),
    birthdate date,
    hiredate date,
    address varchar(255),
    city varchar(255),
    region varchar(255),
    postalcode varchar(10),
    country varchar(255),
    homephone varchar(20),
    extension varchar(10)
);

create table if not exists dimcategory (
    categoryid serial primary key,
    categoryname varchar(255),
    description text
);

create table if not exists dimshipper (
    shipperid serial primary key,
    companyname varchar(255),
    phone varchar(20)
);

create table if not exists dimsupplier (
    supplierid serial primary key,
    companyname varchar(255),
    contactname varchar(255),
    contacttitle varchar(255),
    address varchar(255),
    city varchar(255),
    region varchar(255),
    postalcode varchar(10),
    country varchar(255),
    phone varchar(20)
);

create table if not exists factsales (
    salesid serial primary key,
    dateid int,
    customerid int,
    productid int,
    employeeid int,
    categoryid int,
    shipperid int,
    supplierid int,
    quantitysold int,
    unitprice decimal(10, 2),
    discount decimal(10, 2),
    totalamount decimal(10, 2),
    taxamount decimal(10, 2),
    foreign key (dateid) references dimdate(dateid),
    foreign key (customerid) references dimcustomer(customerid),
    foreign key (productid) references dimproduct(productid),
    foreign key (employeeid) references dimemployee(employeeid),
    foreign key (categoryid) references dimcategory(categoryid),
    foreign key (shipperid) references dimshipper(shipperid),
    foreign key (supplierid) references dimsupplier(supplierid)
);

-- 3. Load data into staging tables
insert into staging_orders 
select * from salesorder;

insert into staging_order_details 
select * from orderdetail;

insert into staging_products 
select * from product;

insert into staging_customers 
select * from customer;

insert into staging_employees 
select * from employee;

insert into staging_categories 
select * from category;

insert into staging_shippers 
select * from shipper;

insert into staging_suppliers 
select * from supplier;

-- 4. Transform and load data into dimension tables
insert into dimproduct (productid, productname, supplierid, categoryid, quantityperunit, unitprice, unitsinstock)
select productid, productname, supplierid, categoryid, quantityperunit, unitprice, unitsinstock
from staging_products;

insert into dimcustomer (customerid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone) 
select customerid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone 
from staging_customers;

insert into dimcategory (categoryid, categoryname, description)
select categoryid, categoryname, description
from staging_categories;

insert into dimemployee (employeeid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, homephone, extension)
select employeeid, lastname, firstname, title, birthdate, hiredate, address, city, region, postalcode, country, phone, extension
from staging_employees;

insert into dimshipper (shipperid, companyname, phone)
select shipperid, companyname, phone
from staging_shippers;

insert into dimsupplier (supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone)
select supplierid, companyname, contactname, contacttitle, address, city, region, postalcode, country, phone
from staging_suppliers;

insert into dimdate (date, day, month, year, quarter, weekofyear)
select
    distinct date(orderdate) as date,
    extract(day from date(orderdate)) as day,
    extract(month from date(orderdate)) as month,
    extract(year from date(orderdate)) as year,
    extract(quarter from date(orderdate)) as quarter,
    extract(week from date(orderdate)) as weekofyear
from
    staging_orders;

-- 5. Load data into fact table
insert into factsales (dateid, customerid, productid, employeeid, categoryid, shipperid, supplierid, quantitysold, unitprice, discount, totalamount, taxamount) 
select
    d.dateid,   
    c.customerid,  
    p.productid,  
    e.employeeid,  
    cat.categoryid,  
    s.shipperid,  
    sup.supplierid, 
    od.qty, 
    od.unitprice, 
    od.discount,    
    (od.qty * od.unitprice - od.discount) as totalamount,
    (od.qty * od.unitprice - od.discount) * 0.1 as taxamount     
from staging_order_details od 
join staging_orders o on od.orderid = o.orderid 
join staging_customers c on o.customerid = c.customerid::varchar 
join staging_products p on od.productid = p.productid  
left join staging_employees e on o.employeeid = e.employeeid  
left join staging_categories cat on p.categoryid = cat.categoryid 
left join staging_shippers s on o.shipperid = s.shipperid  
left join staging_suppliers sup on p.supplierid = sup.supplierid
left join dimdate d on o.orderdate = d.date;

-- 6. Validate data integrity and completeness
select 'dimdate' as table_name, count(*) as record_count from dimdate
union all
select 'dimcustomer', count(*) from dimcustomer
union all
select 'dimproduct', count(*) from dimproduct
union all
select 'dimemployee', count(*) from dimemployee
union all
select 'dimcategory', count(*) from dimcategory
union all
select 'dimshipper', count(*) from dimshipper
union all
select 'dimsupplier', count(*) from dimsupplier
union all
select 'factsales', count(*) from factsales
union all
select 'staging_customers', count(*) from staging_customers
union all
select 'staging_products', count(*) from staging_products
union all
select 'staging_categories', count(*) from staging_categories
union all
select 'staging_employees', count(*) from staging_employees
union all
select 'staging_shippers', count(*) from staging_shippers
union all
select 'staging_suppliers', count(*) from staging_suppliers
union all
select 'staging_order_details', count(*) from staging_order_details
union all
select 'staging_orders_unique_orderdates', count(distinct orderdate) from staging_orders;

select count(*) as broken_record_count 
from factsales 
where dateid not in (select dateid from dimdate)
   or customerid not in (select customerid from dimcustomer)
   or productid not in (select productid from dimproduct)
   or employeeid not in (select employeeid from dimemployee)
   or categoryid not in (select categoryid from dimcategory)
   or shipperid not in (select shipperid from dimshipper)
   or supplierid not in (select supplierid from dimsupplier);

-- 7. Display analysis results
-- Display top 5 products by number of transactions, total sales, and tax
select
    p.productname,
    c.categoryname,
    count(*) as numberoftransactions,
    sum(fs.quantitysold * fs.unitprice) as totalsales,
    sum(fs.taxamount) as totaltax
from factsales fs
join dimproduct p on fs.productid = p.productid
join dimcategory c on p.categoryid = c.categoryid
group by
    p.productname,
    c.categoryname
order by
    numberoftransactions desc,
    totalsales desc,
    totaltax desc
limit 5;

-- Display top 5 customers by number of transactions and purchase amount
select
    c.customerid,
    c.contactname,
    c.region,
    c.country,
    count(fs.salesid) as numberoftransactions,
    sum(fs.totalamount) as purchaseamount,
    string_agg(distinct cat.categoryname, ', ') as productcategories
from factsales fs
join dimcustomer c on fs.customerid = c.customerid
join dimproduct p on fs.productid = p.productid
join dimcategory cat on p.categoryid = cat.categoryid
group by
    c.customerid,
    c.contactname,
    c.region,
    c.country
order by
    numberoftransactions asc,
    purchaseamount asc
limit 5;

-- Display a sales chart for the first week of each month
select 
    month,
    sum(totalamount) as totalsalesamount,
    sum(quantitysold) as totalquantitysold
from  factsales
join dimdate on factsales.dateid = dimdate.dateid
where day between 1 and 7
group by month
order by month;

-- Display weekly sales report by product category for one year
select 
    dp.categoryid,
    dc.categoryname,
    extract(week from dd.date) as week,
    extract(month from dd.date) as month,
    sum(fs.quantitysold) as weeklyquantitysold,
    sum(fs.totalamount) as weeklytotalamount,
    sum(sum(fs.totalamount)) over (partition by extract(month from dd.date)) as monthlytotalamount
from factsales fs
join dimdate dd on fs.dateid = dd.dateid
join dimproduct dp on fs.productid = dp.productid
join dimcategory dc on dp.categoryid = dc.categoryid
group by 
    dp.categoryid, 
    dc.categoryname, 
    extract(week from dd.date), 
    extract(month from dd.date)
order by 
    extract(month from dd.date), 
    extract(week from dd.date), 
    dp.categoryid;

-- Display median monthly sales value by product category and country
select
    extract(month from d.date) as month,
    p.categoryid as productcategory,
    c.country,
    floor(avg(fs.totalamount)) as monthlysales
from factsales fs
join dimproduct p on fs.productid = p.productid
join dimcustomer c on fs.customerid = c.customerid
join dimdate d on fs.dateid = d.dateid
group by
    extract(month from d.date),
    p.categoryid,
    c.country
order by month asc;

-- Display sales rankings by product category
select 
    dp.categoryid,
    dc.categoryname,
    sum(fs.quantitysold) as totalquantitysold
from factsales fs
join dimproduct dp on fs.productid = dp.productid
join dimcategory dc on dp.categoryid = dc.categoryid
group by 
    dp.categoryid, 
    dc.categoryname
order by totalquantitysold desc;
