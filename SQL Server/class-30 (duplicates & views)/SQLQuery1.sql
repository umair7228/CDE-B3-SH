SELECT
	order_status,
	COUNT(order_id) order_count
FROM sales.orders
GROUP BY order_status;

SELECT
	CASE
		WHEN order_status = 1 THEN 'Pending'
		WHEN order_status = 2 THEN 'Processing'
		WHEN order_status = 3 THEN 'Rejected'
		WHEN order_status = 4 THEN 'Completed'
	END AS order_status,
	COUNT(order_id)
FROM sales.orders
GROUP BY order_status;

SELECT
	COALESCE(NULL, 'Hi', 'Hello', NULL) AS result;


SELECT
	COALESCE(NULL, NULL, '10', '20', NULL) AS result;

SELECT *
FROM sales.customers;

SELECT
	first_name,
	last_name,
	COALESCE(phone, 'N/A') AS phone
FROM sales.customers;

CREATE TABLE salaries (
    staff_id INT PRIMARY KEY,
    hourly_rate decimal,
    weekly_rate decimal,
    monthly_rate decimal,
    CHECK(
        hourly_rate IS NOT NULL OR 
        weekly_rate IS NOT NULL OR 
        monthly_rate IS NOT NULL)
);

INSERT INTO 
    salaries(
        staff_id, 
        hourly_rate, 
        weekly_rate, 
        monthly_rate
    )
VALUES
    (1,20, NULL,NULL),
    (2,30, NULL,NULL),
    (3,NULL, 1000,NULL),
    (4,NULL, NULL,6000),
    (5,NULL, NULL,6500);

SELECT *
FROM salaries;

SELECT
	staff_id,
	COALESCE(
		hourly_rate*22*8,
		weekly_rate*4,
		monthly_rate
	) AS monthly_salary
FROM salaries;

SELECT 
    NULLIF(10, 10) result;

SELECT 
    NULLIF(20, 10) result;

CREATE TABLE sales.leads
(
    lead_id    INT	PRIMARY KEY IDENTITY, 
    first_name VARCHAR(100) NOT NULL, 
    last_name  VARCHAR(100) NOT NULL, 
    phone      VARCHAR(20), 
    email      VARCHAR(255) NOT NULL
);

INSERT INTO sales.leads
(
    first_name, 
    last_name, 
    phone, 
    email
)
VALUES
(
    'John', 
    'Doe', 
    '(408)-987-2345', 
    'john.doe@example.com'
),
(
    'Jane', 
    'Doe', 
    '', 
    'jane.doe@example.com'
),
(
    'David', 
    'Doe', 
    NULL, 
    'david.doe@example.com'
);

SELECT *
FROM sales.leads;

SELECT *
FROM sales.leads
WHERE phone IS NULL;

SELECT *
FROM sales.leads
WHERE phone = '';

SELECT
	*
FROM sales.leads
WHERE
	NULLIF(phone, '') IS NULL;

DROP TABLE IF EXISTS t1;
CREATE TABLE t1 (
    id INT IDENTITY(1, 1), 
    a  INT, 
    b  INT, 
    PRIMARY KEY(id)
);

INSERT INTO
    t1(a,b)
VALUES
    (1,1),
    (1,2),
    (1,3),
    (2,1),
    (1,2),
    (1,3),
    (2,1),
    (2,2);

SELECT * 
FROM t1;

-- Finding Duplicates using GROUP BY Clause
SELECT
	a,
	b,
	COUNT(*)
FROM t1
GROUP BY a, b
HAVING COUNT(*) > 1;

-- Finding Duplicates using ROWNUMBER
WITH dup_cte
AS (
SELECT
	id,
	a,
	b,
	ROW_NUMBER() OVER(PARTITION BY a, b ORDER BY a, b) AS rownumber
FROM t1
)
SELECT *
FROM dup_cte
WHERE rownumber > 1;

WITH dup_cte
AS (
SELECT
	id,
	a,
	b,
	ROW_NUMBER() OVER(PARTITION BY a, b ORDER BY a, b) AS rownumber
FROM t1
)
DELETE
FROM dup_cte
WHERE rownumber > 1;

SELECT * FROM t1;

-- VIEWS
SELECT
	product_name,
	brand_name,
	list_price
FROM production.products p
INNER JOIN production.brands b
	ON b.brand_id = p.brand_id

CREATE VIEW sales
AS
SELECT
	product_name,
	brand_name,
	list_price
FROM production.products p
INNER JOIN production.brands b
	ON b.brand_id = p.brand_id

SELECT * FROM sales;

CREATE VIEW sales1 (product, brand, price)
AS
SELECT
	product_name,
	brand_name,
	list_price
FROM production.products p
INNER JOIN production.brands b
	ON b.brand_id = p.brand_id

SELECT * FROM sales1;

SELECT
	YEAR(order_date) y,
	MONTH(order_date) m,
	DAY(order_date) d,
	p.product_id,
	product_name,
	quantity * ot.list_price AS sales
FROM sales.orders o
INNER JOIN sales.order_items ot
	ON o.order_id = ot.order_id
INNER JOIN production.products p
	ON p.product_id = ot.product_id

CREATE VIEW daily_sales (year, month, day, product_id, product_name, sales)
AS
SELECT
	YEAR(order_date),
	MONTH(order_date),
	DAY(order_date),
	p.product_id,
	product_name,
	quantity * ot.list_price
FROM sales.orders o
INNER JOIN sales.order_items ot
	ON o.order_id = ot.order_id
INNER JOIN production.products p
	ON p.product_id = ot.product_id;

SELECT * FROM daily_sales
WHERE sales > 1000;


CREATE OR ALTER VIEW daily_sales (year, month, day, product_id, customer_name, product_name, sales)
AS
SELECT
	YEAR(order_date),
	MONTH(order_date),
	DAY(order_date),
	p.product_id,
	CONCAT(
		first_name,
		' ',
		last_name
	),
	product_name,
	quantity * ot.list_price
FROM sales.orders o
INNER JOIN sales.order_items ot
	ON o.order_id = ot.order_id
INNER JOIN production.products p
	ON p.product_id = ot.product_id
INNER JOIN sales.customers c
	ON c.customer_id = o.customer_id;

SELECT * FROM daily_sales;

SELECT * FROM sales;

DROP VIEW IF EXISTS sales;

SELECT 
	OBJECT_SCHEMA_NAME(v.object_id) schema_name,
	v.name
FROM 
	sys.views as v;

SELECT
    definition,
    uses_ansi_nulls,
    uses_quoted_identifier,
    is_schema_bound
FROM
    sys.sql_modules
WHERE
    object_id
    = object_id(
            'dbo.daily_sales'
        );

CREATE VIEW product_master
WITH SCHEMABINDING
AS
SELECT
    product_id,
    product_name,
    model_year,
    list_price,
    brand_name,
    category_name
FROM
    production.products p
INNER JOIN production.brands b 
    ON b.brand_id = p.brand_id
INNER JOIN production.categories c 
    ON c.category_id = p.category_id;

SELECT * FROM sales.customers;

CREATE UNIQUE CLUSTERED INDEX product_index
ON product_master(product_id);

SELECT COUNT(*) FROM product_master;

SELECT * FROM production.categories;

INSERT INTO production.categories
VALUES ('Test')


