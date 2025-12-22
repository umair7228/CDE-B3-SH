-- TRY CATCH
CREATE PROC usp_divide(
	@a DECIMAL,
	@b DECIMAL,
	@c DECIMAL OUTPUT
) AS
BEGIN
	BEGIN TRY
		SET @c = @a / @b;
	END TRY
	BEGIN CATCH
		SELECT
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine,
			ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END;

DECLARE @result DECIMAL;
EXEC usp_divide 10, 2, @result OUTPUT;
PRINT @result;

DECLARE @result1 DECIMAL;
EXEC usp_divide 10, 0, @result1 OUTPUT;
PRINT @result1;

THROW 50005, N'An error occurred', 1;

-- User-defined functions
--scalar function
-- table-valued function

--scaler function
CREATE FUNCTION sales.udf_Net_Sales(
	@quantity INT,
	@list_price DEC(10, 2),
	@discount DEC(4, 2)
)
RETURNS DEC(10, 2)
AS
BEGIN
	RETURN @quantity * @list_price * (1 - @discount)
END;

SELECT
	sales.udf_Net_Sales(15, 50, 0.2) net_amount;

SELECT
	order_id,
	SUM(sales.udf_Net_Sales(quantity, list_price, discount))
FROM sales.order_items
GROUP BY order_id;

-- table-valued function
CREATE FUNCTION udf_Product(
	@model_year INT
)
RETURNS TABLE
AS
RETURN
	SELECT
		product_id,
		product_name,
		model_year
	FROM production.products
	WHERE model_year = @model_year;

SELECT *
FROM udf_Product(2017);

-- TASK: Modify the udf_Product function to accept start_year and end_year
-- and select data within the specified year range.

ALTER FUNCTION udf_Product(
	@start_year INT,
	@end_year INT
)
RETURNS TABLE
AS
RETURN
	SELECT
		product_id,
		product_name,
		model_year
	FROM production.products
	WHERE model_year BETWEEN @start_year AND @end_year;

SELECT *
FROM udf_Product(2017, 2018);

-- RANK Function
CREATE TABLE sales.rank_test(
	a VARCHAR(10)
);

INSERT INTO sales.rank_test(a)
VALUES('A'), ('B'), ('B'), ('C'), ('C'), ('D'), ('E');

SELECT *
FROM sales.rank_test;

SELECT
	a,
	RANK() OVER(ORDER BY a) rank_no
FROM sales.rank_test;

SELECT
	a,
	RANK() OVER(ORDER BY a) rank_no,
	DENSE_RANK() OVER (ORDER BY a) dense_rank_no
FROM sales.rank_test;

SELECT
	product_id,
	product_name,
	brand_id,
	list_price,
	RANK() OVER(
		PARTITION BY brand_id
		ORDER BY list_price DESC
	) dem_rank
FROM production.products;

-- Triggers
CREATE TABLE Employee
(
	emp_id INT IDENTITY,
	emp_name VARCHAR(50),
	emp_sal DECIMAL(10, 2)
);

INSERT INTO Employee(emp_name, emp_sal)
VALUES
	('Umair', 3000),
	('Salman', 2000),
	('Noman', 4000);

CREATE TABLE Employee_Audit(
	emp_id INT,
	emp_name VARCHAR(50),
	emp_sal DECIMAL(10,2),
	audit_action VARCHAR(100),
	audit_timestamp DATETIME
);

--trigger for insertion
CREATE TRIGGER audit_insertion
ON Employee
FOR INSERT
AS
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(50);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.emp_id FROM inserted i;
	SELECT @empname = i.emp_name FROM inserted i;
	SELECT @empsal = i.emp_sal FROM inserted i;
	SELECT @audit = 'Inserted Record';

	INSERT INTO Employee_Audit
	VALUES(
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	)

	PRINT 'AFTER INSERT TRIGGER FIRED';

INSERT INTO Employee(emp_name, emp_sal)
VALUES
	('Arsalan', 3000);

SELECT * FROM Employee_Audit;

--trigger for updation
ALTER TRIGGER audit_insertion
ON Employee
FOR UPDATE
AS
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(50);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.emp_id FROM inserted i;
	SELECT @empname = i.emp_name FROM inserted i;
	SELECT @empsal = i.emp_sal FROM inserted i;
	
	IF UPDATE (emp_name)
		SET @audit = 'Name Updated'
	IF UPDATE (emp_sal)
		SET @audit = 'Salary Updated'

	INSERT INTO Employee_Audit
	VALUES(
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	)

	PRINT 'AFTER UPDATE TRIGGER FIRED';

UPDATE Employee
SET emp_name = 'Naqeeb'
WHERE emp_id = 2;

--trigger for deletion
ALTER TRIGGER audit_insertion
ON Employee
FOR DELETE
AS
	DECLARE @empid INT;
	DECLARE @empname VARCHAR(50);
	DECLARE @empsal DECIMAL(10, 2);
	DECLARE @audit VARCHAR(100);

	SELECT @empid = i.emp_id FROM inserted i;
	SELECT @empname = i.emp_name FROM inserted i;
	SELECT @empsal = i.emp_sal FROM inserted i;
	SELECT @audit = 'Data Deleted';

	INSERT INTO Employee_Audit
	VALUES(
		@empid,
		@empname,
		@empsal,
		@audit,
		GETDATE()
	)

	PRINT 'AFTER DELETION TRIGGER FIRED';

DELETE FROM Employee
WHERE emp_name = 'Naqeeb';