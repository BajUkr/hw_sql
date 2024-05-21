-- 1) Create a fact table: factsupplierpurchases
create table if not exists factsupplierpurchases (
    purchaseid serial primary key,
    supplierid int not null,
    totalpurchaseamount decimal(10, 2),
    purchasedate date not null,
    numberofproducts int not null,
    foreign key (supplierid) references dimsupplier(supplierid)
);

-- Populate the factsupplierpurchases table with data aggregated from the staging tables
insert into factsupplierpurchases (supplierid, totalpurchaseamount, purchasedate, numberofproducts)
select 
    p.supplierid, 
    sum(od.unitprice * od.qty) as totalpurchaseamount, 
    current_date as purchasedate, 
    count(distinct od.productid) as numberofproducts
from staging_order_details od
join staging_products p on od.productid = p.productid
group by p.supplierid;

-- Supplier spending analysis
select
    s.companyname,
    sum(fsp.totalpurchaseamount) as totalspend,
    extract(year from fsp.purchasedate) as year,
    extract(month from fsp.purchasedate) as month
from factsupplierpurchases fsp
join dimsupplier s on fsp.supplierid = s.supplierid
group by s.companyname, year, month
order by totalspend desc;

-- Product cost breakdown by supplier
select
    s.companyname,
    p.productname,
    avg(od.unitprice) as averageunitprice,
    sum(od.qty) as totalquantitypurchased,
    sum(od.unitprice * od.qty) as totalspend
from staging_order_details od
join staging_products p on od.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname, p.productname
order by s.companyname, totalspend desc;

-- Top five products by total purchases per supplier
select
    s.companyname,
    p.productname,
    sum(od.unitprice * od.qty) as totalspend
from staging_order_details od
join staging_products p on od.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname, p.productname
order by s.companyname, totalspend desc
limit 5;

-- 2) Create a fact table: factproductsales
create table if not exists factproductsales (
    factsalesid serial primary key,
    dateid int not null,
    productid int not null,
    quantitysold int not null,
    totalsales decimal(10,2) not null,
    foreign key (dateid) references dimdate(dateid),
    foreign key (productid) references dimproduct(productid)
);

-- Insert into factproductsales table
insert into factproductsales (dateid, productid, quantitysold, totalsales)
select 
    (select dateid from dimdate where date = s.orderdate) as dateid,
    p.productid, 
    sod.qty, 
    (sod.qty * sod.unitprice) as totalsales
from staging_order_details sod
join staging_orders s on sod.orderid = s.orderid
join staging_products p on sod.productid = p.productid;

-- Top-selling products
select 
    p.productname,
    sum(fps.quantitysold) as totalquantitysold,
    sum(fps.totalsales) as totalrevenue
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
group by p.productname
order by totalrevenue desc
limit 5;

-- Sales trends by product category
select 
    c.categoryname, 
    extract(year from d.date) as year,
    extract(month from d.date) as month,
    sum(fps.quantitysold) as totalquantitysold,
    sum(fps.totalsales) as totalrevenue
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
join dimcategory c on p.categoryid = c.categoryid
join dimdate d on fps.dateid = d.dateid
group by c.categoryname, year, month
order by year, month, totalrevenue desc;

-- Inventory valuation
select 
    p.productname,
    p.unitsinstock,
    p.unitprice,
    (p.unitsinstock * p.unitprice) as inventoryvalue
from 
    dimproduct p
order by inventoryvalue desc;

-- Supplier performance based on product sales
select 
    s.companyname,
    count(distinct fps.factsalesid) as numberofsalestransactions,
    sum(fps.quantitysold) as totalproductssold,
    sum(fps.totalsales) as totalrevenuegenerated
from 
    factproductsales fps
join dimproduct p on fps.productid = p.productid
join dimsupplier s on p.supplierid = s.supplierid
group by s.companyname
order by totalrevenuegenerated desc;

-- 3) Sales performance by employee
select 
    e.firstname, 
    e.lastname, 
    count(fs.salesid) as numberofsales, 
    sum(fs.totalamount) as totalsales
from factsales fs
join dimemployee e on fs.employeeid = e.employeeid
group by e.firstname, e.lastname
order by totalsales desc;

-- 4) Aggregate sales by month and category
select 
    d.month, 
    d.year, 
    c.categoryname, 
    sum(fs.totalamount) as totalsales
from factsales fs
join dimdate d on fs.dateid = d.dateid
join dimcategory c on fs.categoryid = c.categoryid
group by d.month, d.year, c.categoryname
order by d.year, d.month, totalsales desc;

-- Top-selling products per quarter
select 
    d.quarter, 
    d.year, 
    p.productname, 
    sum(fs.quantitysold) as totalquantitysold
from factsales fs
join dimdate d on fs.dateid = d.dateid
join dimproduct p on fs.productid = p.productid
group by d.quarter, d.year, p.productname
order by d.year, d.quarter, totalquantitysold desc
limit 5;

-- Customer sales overview
select 
    cu.companyname, 
    sum(fs.totalamount) as totalspent, 
    count(distinct fs.salesid) as transactionscount
from factsales fs
join dimcustomer cu on fs.customerid = cu.customerid
group by cu.companyname
order by totalspent desc;

-- Monthly sales growth rate
with monthlysales as (
    select
        d.year,
        d.month,
        sum(fs.totalamount) as totalsales
    from factsales fs
    join dimdate d on fs.dateid = d.dateid
    group by d.year, d.month
),
monthlygrowth as (
    select
        year,
        month,
        totalsales,
        lag(totalsales) over (order by year, month) as previousmonthsales,
        (totalsales - lag(totalsales) over (order by year, month)) / lag(totalsales) over (order by year, month) as growthrate
    from monthlysales
)
select * from monthlygrowth;
