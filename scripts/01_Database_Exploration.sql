-- Explore All Objects In the Database
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- Explore All Columns In The Database
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_products'