-- try catch
DROP PROC usp_divide;

CREATE PROC usp_divide(
	@a decimal,
	@b decimal,
	@c decimal output
) AS
BEGIN
	BEGIN TRY
		SET @c = @a /@b;
	END TRY
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_SEVERITY() AS ErrorSeverity  
            ,ERROR_STATE() AS ErrorState  
            ,ERROR_PROCEDURE() AS ErrorProcedure  
            ,ERROR_LINE() AS ErrorLine  
            ,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END;

DECLARE @r decimal;
EXEC usp_divide 10, 2, @r output;
PRINT @r;


DECLARE @r1 decimal;
EXEC usp_divide 10, 0, @r1 output;
PRINT @r1;

-- throw statement
THROW 50005, N'An error occurred', 1;

-- User defined functions
--scaler function
CREATE FUNCTION sales.udfNetSales(
	@quantity INT,
	@list_price DEC(10, 2),
	@discount DEC(4, 2)
)
RETURNS DEC(10, 2)
AS
BEGIN
	RETURN @quantity * @list_price * (1 - @discount);
END;

SELECT
	sales.udfNetSales(10, 100, 0.1) net_sales;

SELECT
	order_id,
	SUM(sales.udfNetSales(quantity, list_price, discount)) net_amount
FROM sales.order_items
GROUP BY order_id;

--table-valued-functions
CREATE FUNCTION udfProductInYear (
    @model_year INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year = @model_year;

SELECT
	*
FROM udfProductInYear(2017);

--Task: Modify the UDF to accept start_year and end_year
--and select data within the specified year range.
ALTER FUNCTION udfProductInYear (
    @start_year INT,
    @end_year INT
)
RETURNS TABLE
AS
RETURN
    SELECT 
        product_name,
        model_year,
        list_price
    FROM
        production.products
    WHERE
        model_year BETWEEN @start_year AND @end_year;

SELECT 
    product_name,
    model_year,
    list_price
FROM 
    udfProductInYear(2017,2018)
ORDER BY
    product_name;

-- RANK Function
CREATE TABLE sales.rank_demo (
	v VARCHAR(10)
);

INSERT INTO sales.rank_demo(v)
VALUES('A'),('B'),('B'),('C'),('C'),('D'),('E');

select v
from sales.rank_demo;

select
	v,
	RANK() OVER (ORDER BY v) rank_no
from sales.rank_demo;

--products-table
select
	product_id,
	product_name,
	list_price,
	RANK() OVER (ORDER BY list_price DESC) price_rank
from production.products;

select *
from (
	select
		product_id,
		product_name,
		brand_id,
		list_price,
		RANK() OVER(
			PARTITION BY brand_id
			ORDER BY list_price DESC
		) price_rank
	from production.products
) t
where price_rank <= 3;

--dense rank
select * from sales.rank_demo;

select
	v,
	DENSE_RANK() OVER (ORDER BY v) my_dense_rank,
	RANK() OVER (ORDER BY v) my_rank
from sales.rank_demo;

--triggers
CREATE TABLE Employee
(
	Emp_ID INT IDENTITY,
	Emp_name VARCHAR(30),
	Emp_sal DECIMAL(10, 2)
);

INSERT INTO Employee (Emp_name, Emp_sal)
VALUES
	('Umair', 1000),        
	('Salman', 2000),
	('Noman', 3000);

CREATE TABLE Employee_Audit (
	Emp_ID INT,
	Emp_name VARCHAR(30),
	Emp_sal DECIMAL(10, 2), 
	Audit_Action VARCHAR(100),
	Audit_Timestamp DATETIME
)
--trigger for insertion
CREATE TRIGGER audit_insertion_employees
ON Employee
FOR INSERT
AS
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(30);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.Emp_ID from inserted i;
	SELECT @empname = i.Emp_name from inserted i;
	SELECT @empsal = i.Emp_sal from inserted i;
	SELECT @audit = 'Insert Record = After Insert Trigger';

	INSERT INTO Employee_Audit
	VALUES (
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	)

	PRINT 'AFTER INSERT TRIGGER FIRED';

INSERT INTO Employee (Emp_name, Emp_sal)
VALUES
	('Arsalan', 4000);

SELECT * FROM Employee_Audit;

-- trigger for update
CREATE TRIGGER trg_after_update
ON Employee
FOR UPDATE
AS
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(30);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.Emp_ID FROM INSERTED i;
	SELECT @empname = i.Emp_name FROM INSERTED i;
	SELECT @empsal = i.Emp_sal FROM INSERTED i;
	
	IF UPDATE (Emp_Name)
		SET @audit = 'Update Record, After Update Trigger, Name Updated';
	IF UPDATE (Emp_sal)
		SET @audit = 'Update Record, After Update Trigger, Sal Updated';

	INSERT INTO Employee_Audit
	VALUES (
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	);

	PRINT 'AFTER UPDATE TRIGGER FIRED';

UPDATE Employee
SET Emp_name = 'Luqman'
WHERE Emp_ID = '2';
	
--trigger for delete
CREATE TRIGGER trg_after_delete
ON Employee
AFTER DELETE
AS 
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(30);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.Emp_ID FROM INSERTED i;
	SELECT @empname = i.Emp_name FROM INSERTED i;
	SELECT @empsal = i.Emp_sal FROM INSERTED i;
	SELECT @audit = 'Deleted, After Delete Trigger';

	INSERT INTO Employee_Audit
	VALUES (
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	);

	PRINT 'AFTER DELETE TRIGGER FIRED';

DELETE FROM Employee
WHERE Emp_name = 'Luqman';



