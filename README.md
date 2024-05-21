# Yan Marchan's Homework Repository

This repository contains the SQL homework assignments completed by Yan Marchan. Each homework is organized into its own file with specific SQL queries and commands to address the given tasks.

## Files Overview

### Yan_Marchan_Data_Mart.sql

This file includes various SQL queries for creating data marts. It contains queries for aggregating sales data, calculating monthly sales growth, and performing sales analysis by different dimensions such as employee performance, top-selling products, and customer sales overview.

### Yan_Marchan_partitioning.sql

Contains SQL commands for creating a partitioned table `sales_data`, partition management procedures, and synthetic data generation.

### Yan_Marchan_FDWs_db_1.sql & Yan_Marchan_FDWs_db_2.sql

These files demonstrate the use of Foreign Data Wrappers (FDWs) in PostgreSQL. They include steps to create foreign servers, user mappings, foreign tables, and local tables, as well as queries to manipulate and join data across different databases.

### Yan_Marchan_Data_modeling.sql

This file contains SQL queries for data modeling. It includes the creation of staging tables, transformation and loading of data into dimension and fact tables, and various analytical queries for data integrity and reporting.

### Yan_Marchan_extensions.sql

This file includes the installation of PostgreSQL extensions such as pg_stat_statements and pgcrypto, and demonstrates their usage.

### Yan_Marchan_SCD.sql

Demonstrates the implementation of a Slowly Changing Dimension (SCD) with SQL commands to alter the `dimemployee` table and manage historical data using triggers.

## How to Use

Each SQL file can be executed within a PostgreSQL environment. Make sure to adjust the connection settings to your database instance and ensure that any referenced tables or schemas exist before running the scripts.

## Contributing

As this is a personal homework repository, contributions are not requested. However, feedback and suggestions are always welcome.

## License

This project is licensed under the MIT License - see the LICENSE.md file for details.

## Contact

- Yan Marchan - marchan.yan@student.ehu.lt