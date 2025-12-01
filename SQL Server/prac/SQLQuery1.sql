select first_name, last_name
from sales.staffs
UNION
select first_name, last_name
from sales.customers

select count(*)
from sales.staffs

select COUNT(*)
from sales.customers

select first_name, last_name
from sales.staffs
UNION ALL
select first_name, last_name
from sales.customers

select city
from sales.customers
INTERSECT
select city
from sales.stores

select * from sales.stores

select product_id
from production.products
EXCEPT
select product_id
from sales.order_items


select full_name, total_sales, order_year
from (
	select 
		first_name + ' ' + last_name as full_name,
		SUM(list_price * quantity * (1 - discount)) as total_sales,
		YEAR(order_date) as order_year
	from sales.orders o
	inner join sales.order_items ot on o.order_id = ot.order_id
	inner join sales.staffs s on o.staff_id = s.staff_id
	group by first_name + ' ' + last_name, YEAR(order_date)
) t
where order_year = 2017

select *
from (
	select full_name, total_sales, order_year
	from (
		select 
			first_name + ' ' + last_name as full_name,
			SUM(list_price * quantity * (1 - discount)) as total_sales,
			YEAR(order_date) as order_year
		from sales.orders o
		inner join sales.order_items ot on o.order_id = ot.order_id
		inner join sales.staffs s on o.staff_id = s.staff_id
		group by first_name + ' ' + last_name, YEAR(order_date)
	) t
	where order_year = 2017
) a
where total_sales > 1370320

WITH sales_cte(staff, total_sales, year)
AS (
	select 
		first_name + ' ' + last_name,
		SUM(list_price * quantity * (1 - discount)),
		YEAR(order_date)
	from sales.orders o
	inner join sales.order_items ot on o.order_id = ot.order_id
	inner join sales.staffs s on o.staff_id = s.staff_id
	group by first_name + ' ' + last_name, YEAR(order_date)
),
filtered_cte AS (
select staff, total_sales, year
from sales_cte
where year = 2018)

select *
from filtered_cte;

WITH cte_numbers(n, weekday) 
AS (
    SELECT 
        0, 
        DATENAME(DW, 0)
    UNION ALL
    SELECT    
        n + 1, 
        DATENAME(DW, n + 1)
    FROM    
        cte_numbers
    WHERE n < 6
)
SELECT 
    weekday
FROM 
    cte_numbers;

SELECT 
    0, 
    DATENAME(DW, 0)

with rec_cte(n, weekday) AS
(
	select
		0,
		datename(DW, 0)
	UNION ALL
	select
		n + 1,
		DATENAME(DW, n + 1)
	from rec_cte
	where n < 6
)
select * from rec_cte

SELECT       
    staff_id, 
    first_name,
    manager_id
        
FROM       
    sales.staffs
WHERE manager_id IS NULL


WITH cte_org AS (
    SELECT       
        staff_id, 
        first_name,
        manager_id
        
    FROM       
        sales.staffs
    WHERE manager_id IS NULL
    UNION ALL
    SELECT 
        e.staff_id, 
        e.first_name,
        e.manager_id
    FROM 
        sales.staffs e
        INNER JOIN cte_org o 
            ON o.staff_id = e.manager_id
)
SELECT * FROM cte_org;

select category_name, count(product_id)
from production.products p
JOIN production.categories c
	on p.category_id = c.category_id
group by category_name

select * from (
select category_name, product_id
from production.products p
JOIN production.categories c
	on p.category_id = c.category_id
) t
PIVOT (
	count(product_id)
	for category_name IN (
		[Children Bicycles],
		[Comfort Bicycles],
		[Cruisers Bicycles],
		[Cyclocross Bicycles],
		[Electric Bikes],
		[Mountain Bikes],
		[Road Bikes]
	)
) AS pivot_table;

select * from (
select category_name, product_id, model_year
from production.products p
JOIN production.categories c
	on p.category_id = c.category_id
) t
PIVOT (
	count(product_id)
	for category_name IN (
		[Children Bicycles],
		[Comfort Bicycles],
		[Cruisers Bicycles],
		[Cyclocross Bicycles],
		[Electric Bikes],
		[Mountain Bikes],
		[Road Bikes]
	)
) AS pivot_table;

CREATE TABLE sales.taxes (
	tax_id INT PRIMARY KEY IDENTITY (1, 1),
	state VARCHAR (50) NOT NULL UNIQUE,
	state_tax_rate DEC (3, 2),
	avg_local_tax_rate DEC (3, 2),
	combined_rate AS state_tax_rate + avg_local_tax_rate,
	max_local_tax_rate DEC (3, 2),
	updated_at datetime
);

select * from sales.taxes

select GETDATE()

update sales.taxes
set updated_at = GETDATE();

select * from sales.taxes;

update sales.taxes
set max_local_tax_rate += 0.02,
	avg_local_tax_rate += 0.01
where max_local_tax_rate = 0.07;

select * from sales.taxes;

DROP TABLE IF EXISTS sales.targets;

CREATE TABLE sales.targets
(
    target_id  INT	PRIMARY KEY, 
    percentage DECIMAL(4, 2) 
        NOT NULL DEFAULT 0
);

INSERT INTO 
    sales.targets(target_id, percentage)
VALUES
    (1,0.2),
    (2,0.3),
    (3,0.5),
    (4,0.6),
    (5,0.8);

CREATE TABLE sales.commissions
(
    staff_id    INT PRIMARY KEY, 
    target_id   INT, 
    base_amount DECIMAL(10, 2) 
        NOT NULL DEFAULT 0, 
    commission  DECIMAL(10, 2) 
        NOT NULL DEFAULT 0, 
    FOREIGN KEY(target_id) 
        REFERENCES sales.targets(target_id), 
    FOREIGN KEY(staff_id) 
        REFERENCES sales.staffs(staff_id),
);

INSERT INTO 
    sales.commissions(staff_id, base_amount, target_id)
VALUES
    (1,100000,2),
    (2,120000,1),
    (3,80000,3),
    (4,900000,4),
    (5,950000,5);

select * from sales.commissions
select * from sales.targets

update sales.commissions
set commissions.commission = c.base_amount * t.percentage
from sales.commissions c
INNER JOIN sales.targets t
	on c.target_id = t.target_id

select * from sales.commissions

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

select * from sales.category
select * from sales.category_staging

merge sales.category t
	using sales.category_staging s
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

BEGIN TRANSACTION;

INSERT INTO invoices (customer_id, total)
VALUES (101, 0);

INSERT INTO invoice_items (id, invoice_id, item_name, amount, tax)
VALUES (30, 2, 'Keyboard', 70, 0.08),
       (40, 2, 'Mouse', 50, 0.08);

UPDATE invoices
SET total = (
	SELECT SUM(amount * (1 + tax))
	FROM invoice_items
	WHERE invoice_id = 2
);

COMMIT;

select * from invoices
select * from invoice_items

BEGIN TRANSACTION;

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
);

ROLLBACK;   -- Undo all changes
