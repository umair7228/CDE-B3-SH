-- ALTER TABLE ADD column
CREATE TABLE sales.quotations (
    quotation_no INT IDENTITY PRIMARY KEY,
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL
);

ALTER TABLE sales.quotations
ADD description VARCHAR(250) NOT NULL;

SELECT * FROM sales.quotations;

-- ALTER TABLE ALTER COLUMN
CREATE TABLE t1 (c INT);

INSERT INTO t1
VALUES
    (1),
    (2),
    (3);

SELECT * FROM t1;

ALTER TABLE t1
ALTER COLUMN c VARCHAR(2);

INSERT INTO t1(c)
VALUES ('@');

ALTER TABLE t1
ALTER COLUMN c INT;

CREATE TABLE sales.price_lists(
    product_id int,
    valid_from DATE,
    price DEC(10,2) NOT NULL CONSTRAINT ck_positive_price CHECK(price >= 0),
    discount DEC(10,2) NOT NULL,
    surcharge DEC(10,2) NOT NULL,
    note VARCHAR(255),
    PRIMARY KEY(product_id, valid_from)
);

SELECT * FROM sales.price_lists;

ALTER TABLE sales.price_lists
DROP COLUMN note;

ALTER TABLE sales.price_lists
DROP COLUMN price;

CREATE TABLE persons
(
    person_id  INT PRIMARY KEY IDENTITY, 
    first_name NVARCHAR(100) NOT NULL, 
    last_name  NVARCHAR(100) NOT NULL, 
    dob        DATE
);

INSERT INTO 
    persons(first_name, last_name, dob)
VALUES
    ('John','Doe','1990-05-01'),
    ('Jane','Doe','1995-03-01');

SELECT
	first_name + ' ' + last_name AS full_name
FROM persons;

ALTER TABLE persons
ADD full_name AS (first_name + ' ' + last_name);

SELECT * FROM persons;

SELECT * FROM t1;

DROP TABLE IF EXISTS t1;

CREATE TABLE sales.customer_groups (
    group_id INT PRIMARY KEY IDENTITY,
    group_name VARCHAR (50) NOT NULL
);

INSERT INTO sales.customer_groups (group_name)
VALUES
    ('Intercompany'),
    ('Third Party'),
    ('One time');

SELECT * FROM sales.customer_groups;

DELETE FROM sales.customer_groups;

TRUNCATE TABLE sales.customer_groups;

SELECT
	product_name,
	list_price
INTO  #trek_products
FROM production.products;

SELECT * FROM #trek_products;

CREATE SYNONYM orders FOR sales.orders;

SELECT * FROM orders;

CREATE SYNONYM orders FOR BikeStores.sales.orders;

SELECT * FROM orders;

CREATE TABLE test (c CHAR(20));

SELECT * FROM test;

INSERT INTO test (c)
VALUES ('abc');

INSERT INTO test (c)
VALUES ('你好');

DROP TABLE test;

CREATE TABLE test (c VARCHAR(500));

SELECT * FROM test;

INSERT INTO test (c)
VALUES ('abc');

INSERT INTO test (c)
VALUES ('你好');

ALTER TABLE test
ALTER COLUMN c NVARCHAR(500);

INSERT INTO test (c)
VALUES (N'你好');

SELECT 
    NEWID() AS GUID;

CREATE SCHEMA procurement;
GO;

CREATE TABLE procurement.vendor_groups (
    group_id INT IDENTITY PRIMARY KEY,
    group_name VARCHAR (100) NOT NULL
);

CREATE TABLE procurement.vendors (
        vendor_id INT IDENTITY PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL,
        group_id INT NOT NULL,
);

INSERT INTO procurement.vendor_groups(group_name)
VALUES
	('Third-Party Vendors'),
	('One-time Vendors'),
	('Interco Vendors');

SELECT * FROM procurement.vendor_groups;
SELECT * FROM procurement.vendors;

INSERT INTO procurement.vendors(vendor_name, group_id)
VALUES
	('ABC', 2);

DROP TABLE procurement.vendors;

CREATE TABLE procurement.vendors (
        vendor_id INT IDENTITY PRIMARY KEY,
        vendor_name VARCHAR(100) NOT NULL,
        group_id INT NOT NULL,
        CONSTRAINT fk_group FOREIGN KEY (group_id) 
        REFERENCES procurement.vendor_groups(group_id)
);

CREATE SCHEMA hr;
GO

CREATE TABLE hr.persons(
    person_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE
);

INSERT INTO hr.persons(first_name, last_name)
VALUES('John','Doe');

SELECT * FROM hr.persons;

CREATE SCHEMA test;
GO

CREATE TABLE test.products(
    product_id INT IDENTITY PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    unit_price DEC(10,2) CHECK(unit_price > 0)
);

INSERT INTO test.products(product_name, unit_price)
VALUES ('Awesome Free Bike', 1);

INSERT INTO test.products(product_name, unit_price)
VALUES ('Another Awesome Bike', NULL);

SELECT    
    order_status, 
    COUNT(order_id) order_count
FROM    
    sales.orders
WHERE 
    YEAR(order_date) = 2018
GROUP BY 
    order_status;

SELECT
	CASE order_status
		WHEN 1 THEN 'Pending'
		WHEN 2 THEN 'Processing'
		WHEN 3 THEN 'Rejected'
		WHEN 4 THEN 'Completed'
	END AS order_status,
	COUNT(order_id) AS order_count
FROM sales.orders
WHERE YEAR(order_date) = 2018
GROUP BY order_status;

SELECT    
    SUM(CASE
            WHEN order_status = 1
            THEN 1
            ELSE 0
        END) AS 'Pending', 
    SUM(CASE
            WHEN order_status = 2
            THEN 1
            ELSE 0
        END) AS 'Processing', 
    SUM(CASE
            WHEN order_status = 3
            THEN 1
            ELSE 0
        END) AS 'Rejected', 
    SUM(CASE
            WHEN order_status = 4
            THEN 1
            ELSE 0
        END) AS 'Completed', 
    COUNT(*) AS Total
FROM    
    sales.orders
WHERE 
    YEAR(order_date) = 2018;

SELECT
	SUM(CASE
		WHEN order_status = 1 THEN 1 ELSE 0
	END) AS 'Pending',
	SUM(CASE
		WHEN order_status = 2 THEN 1 ELSE 0
	END) AS 'Processing'
FROM    
    sales.orders
WHERE 
    YEAR(order_date) = 2018;

SELECT    
    o.order_id, 
    SUM(quantity * list_price) order_value,
    CASE
        WHEN SUM(quantity * list_price) <= 500 
            THEN 'Very Low'
        WHEN SUM(quantity * list_price) > 500 AND 
            SUM(quantity * list_price) <= 1000 
            THEN 'Low'
        WHEN SUM(quantity * list_price) > 1000 AND 
            SUM(quantity * list_price) <= 5000 
            THEN 'Medium'
        WHEN SUM(quantity * list_price) > 5000 AND 
            SUM(quantity * list_price) <= 10000 
            THEN 'High'
        WHEN SUM(quantity * list_price) > 10000 
            THEN 'Very High'
    END order_priority
FROM    
    sales.orders o
INNER JOIN sales.order_items i ON i.order_id = o.order_id
WHERE 
    YEAR(order_date) = 2018
GROUP BY 
    o.order_id;
