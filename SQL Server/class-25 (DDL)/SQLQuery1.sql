SELECT * FROM sales.customers;

-- Merge Statment
CREATE TABLE sales.category (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);

INSERT INTO sales.category(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (2,'Comfort Bicycles',25000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',10000);


CREATE TABLE sales.category_staging (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(255) NOT NULL,
    amount DECIMAL(10 , 2 )
);


INSERT INTO sales.category_staging(category_id, category_name, amount)
VALUES(1,'Children Bicycles',15000),
    (3,'Cruisers Bicycles',13000),
    (4,'Cyclocross Bicycles',20000),
    (5,'Electric Bikes',10000),
    (6,'Mountain Bikes',10000);

SELECT * FROM sales.category;
SELECT * FROM sales.category_staging;

MERGE sales.category t
	USING sales.category_staging s
ON t.category_id = s.category_id
WHEN MATCHED
	THEN UPDATE SET
		t.category_name = s.category_name,
		t.amount = s.amount
WHEN NOT MATCHED BY TARGET
	THEN INSERT (category_id, category_name, amount)
	VALUES (s.category_id, s.category_name, s.amount)
WHEN NOT MATCHED BY SOURCE
	THEN DELETE;

CREATE TABLE invoices (
  id int IDENTITY PRIMARY KEY,
  customer_id int NOT NULL,
  total decimal(10, 2) NOT NULL DEFAULT 0 CHECK (total >= 0)
);

CREATE TABLE invoice_items (
  id int,
  invoice_id int NOT NULL,
  item_name varchar(100) NOT NULL,
  amount decimal(10, 2) NOT NULL CHECK (amount >= 0),
  tax decimal(4, 2) NOT NULL CHECK (tax >= 0),
  PRIMARY KEY (id, invoice_id),
  FOREIGN KEY (invoice_id) REFERENCES invoices (id)
	ON UPDATE CASCADE
	ON DELETE CASCADE
);

BEGIN TRAN

INSERT INTO invoices (customer_id, total)
VALUES (100, 0);

INSERT INTO invoice_items (id, invoice_id, item_name, amount, tax)
VALUES (10, 1, 'Keyboard', 70, 0.08),
       (20, 1, 'Mouse', 50, 0.08);

UPDATE invoices
SET total = (
	SELECT SUM(amount * (1 + tax))
	FROM invoice_items
	WHERE invoice_id = 1
)

COMMIT;

SELECT * FROM invoices;
SELECT * FROM invoice_items;

CREATE DATABASE TestDB;

SELECT name
FROM master.sys.databases;

EXEC sp_databases;

DROP DATABASE IF EXISTS TestDB;

SELECT 
    s.name AS schema_name, 
    u.name AS schema_owner
FROM 
    sys.schemas s
INNER JOIN sys.sysusers u ON u.uid = s.principal_id
ORDER BY 
    s.name;

CREATE TABLE dbo.offices
(
    office_id      INT
    PRIMARY KEY IDENTITY, 
    office_name    NVARCHAR(40) NOT NULL, 
    office_address NVARCHAR(255) NOT NULL, 
    phone          VARCHAR(20),
);

INSERT INTO 
    dbo.offices(office_name, office_address)
VALUES
    ('Silicon Valley','400 North 1st Street, San Jose, CA 95130'),
    ('Sacramento','1070 River Dr., Sacramento, CA 95820');


SELECT * FROM dbo.offices;

select * from sales.offices;

ALTER SCHEMA sales TRANSFER OBJECT::dbo.offices;

CREATE SCHEMA logistics;
GO

DROP SCHEMA IF EXISTS logistics;

CREATE SEQUENCE item_counter
    AS INT
    START WITH 10
    INCREMENT BY 10;

SELECT NEXT VALUE FOR item_counter;

CREATE SCHEMA procurement;
GO

CREATE TABLE procurement.purchase_orders(
    order_id INT PRIMARY KEY,
    vendor_id int NOT NULL,
    order_date date NOT NULL
);

CREATE SEQUENCE procurement.order_number 
AS INT
START WITH 1
INCREMENT BY 1;

INSERT INTO procurement.purchase_orders
    (order_id,
    vendor_id,
    order_date)
VALUES
    (NEXT VALUE FOR procurement.order_number,1,'2019-04-30');

SELECT * FROM procurement.purchase_orders;