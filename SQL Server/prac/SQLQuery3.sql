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

-- BEGIN END statement
BEGIN
	SELECT
		product_id,
		product_name
	FROM production.products
	WHERE list_price > 100000;

	IF @@ROWCOUNT = 0
		PRINT 'No Product with price greater then 10000';
END;

-- nested begin end statement
begin

	declare @name VARCHAR(MAX)

	select top 1
		@name = product_name
	from production.products
	order by list_price desc

	IF @@ROWCOUNT <> 0
	begin
		PRINT 'the most expensive product is ' + @name
	end
	else
	begin
		print 'no product found'
	end

end

-- if-else statment
BEGIN
    DECLARE @sales INT;

    SELECT 
        @sales = SUM(list_price * quantity)
    FROM
        sales.order_items i
        INNER JOIN sales.orders o ON o.order_id = i.order_id
    WHERE
        YEAR(order_date) = 2018;

    SELECT @sales;

    IF @sales > 1000000
    BEGIN
        PRINT 'Great! The sales amount in 2018 is greater than 1,000,000';
    END
END

-- while statement
declare @counter INT= 1;

while @counter <= 5
begin
	print @counter;
	set @counter = @counter + 1
end

-- break statement
DECLARE @counter INT = 0;

WHILE @counter <= 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 4
        BREAK;
    PRINT @counter;
END

--continue statement
DECLARE @counter INT = 0;

WHILE @counter < 5
BEGIN
    SET @counter = @counter + 1;
    IF @counter = 3
        CONTINUE;	
    PRINT @counter;
END

-- cursor
DECLARE 
    @product_name VARCHAR(MAX), 
    @list_price   DECIMAL;

DECLARE product_cursor cursor
for select
		product_name,
		list_price
	from production.products

OPEN product_cursor;

FETCH NEXT FROM product_cursor INTO
	@product_name,
	@list_price

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @product_name + CAST(@list_price AS VARCHAR)
		FETCH NEXT FROM product_cursor INTO
			@product_name,
			@list_price
	END

CLOSE cursor_product;
DEALLOCATE cursor_product;

--TRY CATCH
CREATE PROC usp_divide(
    @a decimal,
    @b decimal,
    @c decimal output
) AS
BEGIN
    BEGIN TRY
        SET @c = @a / @b;
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
GO

DECLARE @r decimal;
EXEC usp_divide 10, 2, @r output;
PRINT @r;

DECLARE @r2 decimal;
EXEC usp_divide 20, 0, @r2 output;
PRINT @r2;

--raiseerror
--Throw
THROW 50005, N'An error occurred', 1;

drop table t1;
CREATE TABLE t1(
    id int primary key
);
GO

BEGIN TRY
    INSERT INTO t1(id) VALUES(1);
    --  cause error
    INSERT INTO t1(id) VALUES(1);
END TRY
BEGIN CATCH
    PRINT('Raise the caught error again');
    THROW;
END CATCH

EXEC sys.sp_addmessage 
    @msgnum = 50010, 
    @severity = 16, 
    @msgtext =
    N'The order number %s cannot be deleted because it does not exist.', 
    @lang = 'us_english';   
GO

DECLARE @MessageText NVARCHAR(2048);
SET @MessageText =  FORMATMESSAGE(50010, N'1001');   

THROW 50010, @MessageText, 1; 

-- daynamic sql

EXEC sp_executesql N'SELECT * FROM production.products';

DECLARE 
    @table NVARCHAR(128),
    @sql NVARCHAR(MAX);

SET @table = N'production.products';

SET @sql = N'SELECT * FROM ' + @table;

EXEC sp_executesql @sql;



