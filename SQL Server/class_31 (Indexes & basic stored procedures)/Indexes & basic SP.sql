CREATE TABLE production.parts (
	part_id INT NOT NULL,
	part_name VARCHAR(100)
);

INSERT INTO
	production.parts(part_id, part_name)
VALUES
	(1, 'Frame'),
	(2, 'Head Tube'),
	(3, 'Handlebar Grip'),
	(4, 'Shock Absorber'),
	(5, 'Fork');

SELECT * FROM production.parts;

SELECT
	part_id,
	part_name
FROM production.parts
WHERE part_id = 5;

-- Clustered Indexes AND Non-Clustered Indexes

-- Clustered Indexes

CREATE CLUSTERED INDEX ix_parts_id
ON production.parts(part_id);

SELECT
	part_id,
	part_name
FROM production.parts
WHERE part_id = 5;

-- Non-Clustered Indexes
SELECT
	customer_id,
	city
FROM sales.customers
WHERE city = 'Atwater';

CREATE INDEX ix_customers_city
ON sales.customers(city);

SELECT
	customer_id,
	city
FROM sales.customers
WHERE city = 'Atwater';

-- renaming index
EXEC sp_rename
	@objname = N'sales.customers.ix_customers_city',
	@newname = N'ix_cust_city',
	@objtype = N'INDEX';

-- disabling index
ALTER INDEX ix_cust_city
ON sales.customers
DISABLE;

-- enabling index
ALTER INDEX ix_cust_city
ON sales.customers
REBUILD;

-- Practice
SELECT
	product_name
FROM production.products;

create index ix_products_name
on production.products(product_name);

ALTER INDEX ix_products_name
ON production.products
rebuild;

-- Unique Indexes
-- finding duplicates
SELECT 
	*
FROM sales.customers

SELECT
	email,
	COUNT(email)
FROM sales.customers
GROUP BY email
HAVING COUNT(email) > 1;

CREATE UNIQUE INDEX ix_cust_email_uni
ON sales.customers(email);

SELECT email FROM sales.customers;

--Droping Index
DROP INDEX IF EXISTS 
ix_cust_email_uni ON sales.customers,
ix_cust_city ON sales.customers;

--Include columns
SELECT 
	first_name,
	last_name,
	email
FROM sales.customers
WHERE email = 'lyndsey.bean@hotmail.com';

CREATE UNIQUE INDEX ix_cust_email_inc
ON sales.customers(email)
INCLUDE(first_name, last_name);

SELECT 
	first_name,
	last_name,
	email
FROM sales.customers
WHERE email = 'lyndsey.bean@hotmail.com';

--Filtered Indexes
SELECT * FROM sales.customers;

SELECT
	SUM(CASE
		WHEN phone IS NULL
		THEN 1
		ELSE 0
	END) AS no_phone,
	SUM(CASE
		WHEN phone IS NULL
		THEN 0
		ELSE 1
	END) AS has_phone
FROM sales.customers;

SELECT COUNT(*)
FROM sales.customers
WHERE phone IS NULL;

CREATE INDEX ix_cust_phone
ON sales.customers(phone)
WHERE phone IS NOT NULL;

SELECT
	*
FROM sales.customers
WHERE phone IS NOT NULL AND phone = '(516) 583-7761';

SELECT * FROM sales.customers;

SELECT
	first_name, last_name, email
FROM sales.customers
WHERE SUBSTRING(
	email,
	0,
	CHARINDEX('@', email, 0)
) = 'daryl.spence';

ALTER TABLE sales.customers
ADD email_local_part AS
	SUBSTRING(
	email,
	0,
	CHARINDEX('@', email, 0)
);

SELECT * FROM sales.customers;

CREATE INDEX ix_cust_email_local_part
ON sales.customers(email_local_part);

SELECT email_local_part
FROM sales.customers;

-- Stored Procedure
SELECT
	product_name,
	list_price
FROM production.products
ORDER BY product_name;

CREATE PROCEDURE product_list
AS
BEGIN
SELECT
	product_name,
	list_price
FROM production.products
ORDER BY product_name
END;

EXEC product_list;

-- modifing sp
ALTER PROCEDURE product_list
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	ORDER BY list_price
END;

DROP PROCEDURE product_list;