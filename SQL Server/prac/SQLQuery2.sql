--clustered index
CREATE TABLE production.parts(
    part_id   INT NOT NULL, 
    part_name VARCHAR(100)
);

INSERT INTO 
    production.parts(part_id, part_name)
VALUES
    (1,'Frame'),
    (2,'Head Tube'),
    (3,'Handlebar Grip'),
    (4,'Shock Absorber'),
    (5,'Fork');

--table scan
SELECT 
    part_id, 
    part_name
FROM 
    production.parts
WHERE 
    part_id = 5;

--creating clustered index
CREATE CLUSTERED INDEX ix_parts_id
ON production.parts (part_id);

SELECT 
    part_id, 
    part_name
FROM 
    production.parts
WHERE 
    part_id = 5;

-- non-clustered index
SELECT 
    customer_id, 
    city
FROM 
    sales.customers
WHERE 
    city = 'Atwater';

CREATE INDEX ix_customers_city
ON sales.customers(city);

--renaming index
EXEC sp_rename 
    @objname = N'sales.customers.ix_customers_city',
    @newname = N'ix_cust_city' ,
    @objtype = N'INDEX';

--disabling index
ALTER INDEX ix_cust_city
ON sales.customers
DISABLE;

select
	first_name, last_name, city
from sales.customers
where city = 'Fairport';

--enabling index
ALTER INDEX ix_cust_city
ON sales.customers
REBUILD;

-- creating unique index
SELECT
    customer_id, 
    email 
FROM
    sales.customers
WHERE 
    email = 'caren.stephens@msn.com';

--checking duplicates
select
	email,
	count(email)
from sales.customers
group by email
having count(email) > 1;


create unique index ix_cust_email
on sales.customers(email);

--drop index
drop index ix_cust_email
on sales.customers;

--drop multiple index
DROP INDEX if exists
    ix_cust_city ON sales.customers,
    ix_cust_fullname ON sales.customers;

-- include columns
SELECT    
	first_name,
	last_name, 
	email
FROM    
	sales.customers
WHERE email = 'aide.franco@msn.com';

DROP INDEX ix_cust_email_inc
ON sales.customers;

--include statment
create unique index ix_cust_email_inc
on sales.customers(email)
include(first_name, last_name);

--filtered index
SELECT 
    SUM(CASE
            WHEN phone IS NULL
            THEN 1
            ELSE 0
        END) AS [Has Phone], 
    SUM(CASE
            WHEN phone IS NULL
            THEN 0
            ELSE 1
        END) AS [No Phone]
FROM 
    sales.customers;

create index ix_cust_phone
on sales.customers(phone)
where phone is not null;

SELECT    
    first_name,
    last_name, 
    phone
FROM    
    sales.customers
WHERE phone is null;

--indexes on computed columns
select first_name, last_name, email
from sales.customers
where SUBSTRING(
	email,
	0,
	CHARINDEX('@', email, 0)
) = 'garry.espinoza';

alter table sales.customers
add
	email_local_part AS 
        SUBSTRING(email, 
            0, 
            CHARINDEX('@', email, 0)
        );

select * from sales.customers;

CREATE INDEX ix_cust_email_local_part
ON sales.customers(email_local_part);

SELECT    
    first_name,
    last_name,
    email
FROM    
    sales.customers
WHERE 
    email_local_part = 'garry.espinoza';

-- stored procedure
SELECT 
	product_name, 
	list_price
FROM 
	production.products
ORDER BY 
	product_name;

-- simple sp
create procedure product_list
AS
Begin
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	ORDER BY 
		product_name
END;

EXEC product_list;

--modifying sp
alter procedure product_list
AS
Begin
	SELECT 
		product_name, 
		list_price
	FROM 
		production.products
	ORDER BY 
		list_price
END;

exec product_list;

--drop sp
drop procedure product_list;

--sp with parameters
create procedure usp_find_procedure(@min_list_price AS Decimal)
AS
BEGIN
	select
		product_name,
		list_price
	from production.products
	where list_price >= @min_list_price
END;

exec usp_find_procedure 1000;

--sp with multi params
alter procedure usp_find_procedure(@min_list_price AS Decimal, @max_list_price AS Decimal)
AS
BEGIN
	select
		product_name,
		list_price
	from production.products
	where list_price >= @min_list_price AND
	list_price <= @max_list_price
END;

exec usp_find_procedure 1000, 2000;

--named params
exec usp_find_procedure 
	@min_list_price = 1000, @max_list_price = 2000;

-- sp with text params
alter procedure usp_find_procedure(@min_list_price AS Decimal, @max_list_price AS Decimal, @name AS VARCHAR(max))
AS
BEGIN
	select
		product_name,
		list_price
	from production.products
	where list_price >= @min_list_price AND
	list_price <= @max_list_price AND
	product_name LIKE '%' + @name + '%'
END;

exec usp_find_procedure 
	@min_list_price = 1000, @max_list_price = 2000,
	@name = 'Trek';

-- sp with optional params
ALTER PROCEDURE usp_find_procedure(
    @min_list_price AS DECIMAL = 0
    ,@max_list_price AS DECIMAL = 999999
    ,@name AS VARCHAR(max)
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM 
        production.products
    WHERE
        list_price >= @min_list_price AND
        list_price <= @max_list_price AND
        product_name LIKE '%' + @name + '%'
    ORDER BY
        list_price;
END;

EXECUTE usp_find_procedure
    @name = 'Trek';

--sp with null optional params
ALTER PROCEDURE usp_find_procedure(
    @min_list_price AS DECIMAL = 0
    ,@max_list_price AS DECIMAL = NULL
    ,@name AS VARCHAR(max)
)
AS
BEGIN
    SELECT
        product_name,
        list_price
    FROM 
        production.products
    WHERE
        list_price >= @min_list_price AND
        (@max_list_price IS NULL OR list_price <= @max_list_price) AND
        product_name LIKE '%' + @name + '%'
    ORDER BY
        list_price;
END;

EXECUTE usp_find_procedure
    @min_list_price = 500,
    @name = 'Haro';

-- simple variables
DECLARE @model_year SMALLINT;

SET @model_year = 2018;

select
	product_name, list_price, model_year
from production.products
where model_year = @model_year;

--setting a result of select into variable
DECLARE @product_count INT;

set @product_count = (
	select count(*)
	from production.products
);

print @product_count;

--selecting a record into variables
DECLARE 
    @product_name VARCHAR(MAX),
    @list_price DECIMAL(10,2);

SELECT 
    @product_name = product_name,
    @list_price = list_price
FROM
    production.products
WHERE
    product_id = 100;

SELECT 
    @product_name AS product_name, 
    @list_price AS list_price;

--creating output parameters
CREATE PROCEDURE uspFindProductByModel (
    @model_year SMALLINT,
    @product_count INT OUTPUT
) AS
BEGIN
    SELECT 
        product_name,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

    SELECT @product_count = @@ROWCOUNT;
END;

DECLARE @count INT;

EXEC uspFindProductByModel
    @model_year = 2018,
    @product_count = @count OUTPUT;

SELECT @count AS 'Number of products found';



