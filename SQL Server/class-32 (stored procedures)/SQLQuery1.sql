SELECT * FROM production.products;

-- SP with parameters
CREATE PROCEDURE find_procedure
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
END;

EXEC find_procedure;

--TASK: create a stored procedure which select data of 
--those products whose list price is greater then 10000.

ALTER PROCEDURE find_procedure
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE list_price >= 10000
END;

EXEC find_procedure;

ALTER PROCEDURE find_procedure (@min_list_price AS DECIMAL)
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE list_price >= @min_list_price
END;

EXEC find_procedure 8000;

-- sp with multi-params
ALTER PROCEDURE find_procedure (@min_list_price AS DECIMAL, @max_list_price AS DECIMAL)
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE 
		list_price >= @min_list_price AND
		list_price <= @max_list_price
END;

EXEC find_procedure 1000, 2000;
EXEC find_procedure @min_list_price = 1000, @max_list_price = 2000;

-- sp with text parameter
ALTER PROCEDURE find_procedure 
	(@min_list_price AS DECIMAL, 
	@max_list_price AS DECIMAL, 
	@name AS VARCHAR(MAX))
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE 
		list_price >= @min_list_price AND
		list_price <= @max_list_price AND
		product_name LIKE '%' + @name + '%'
END;

EXEC find_procedure 1000, 2000, 'Trek';

-- sp with optional param
ALTER PROCEDURE find_procedure 
	(@min_list_price AS DECIMAL = 0, 
	@max_list_price AS DECIMAL = 99999,
	@name AS VARCHAR(MAX))
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE 
		list_price >= @min_list_price AND
		list_price <= @max_list_price AND
		product_name LIKE '%' + @name + '%'
END;

EXEC find_procedure @name = 'Trek';

-- sp with null optional param
ALTER PROCEDURE find_procedure 
	(@min_list_price AS DECIMAL = 0, 
	@max_list_price AS DECIMAL = NULL,
	@name AS VARCHAR(MAX))
AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE 
		list_price >= @min_list_price AND
		(@max_list_price IS NULL OR list_price <= @max_list_price) AND
		product_name LIKE '%' + @name + '%'
END;

EXEC find_procedure @name = 'Trek';

-- simple variables
DECLARE @model_year SMALLINT;

SET @model_year = 2018;

PRINT @model_year;

SELECT
	product_name, list_price, model_year
FROM production.products
WHERE model_year = @model_year;

DECLARE @product_count INT;

SET @product_count = (
	SELECT COUNT(*)
	FROM production.products
)

--PRINT @product_count;

SELECT @product_count;

PRINT 'Total Product Count is ' + CAST(@product_count AS VARCHAR(max));

-- selecting a record into variable
DECLARE @product_name VARCHAR(MAX), @list_price DECIMAL(10, 2);

SELECT
	@product_name = product_name,
	@list_price = list_price
FROM production.products
WHERE product_id = 100

SELECT @product_name;

ALTER PROC uspGetProductList(
    @model_year SMALLINT
) AS 
BEGIN
    DECLARE @product_list VARCHAR(MAX);

    SET @product_list = '';

    SELECT
        @product_list = @product_list + product_name 
                        + CHAR(10)
    FROM 
        production.products
    WHERE
        model_year = @model_year
    ORDER BY 
        product_name;

    SELECT @product_list;
END;

EXEC uspGetProductList 2018;

-- creating output param
ALTER PROC FindProductByModel (
	@model_year SMALLINT,
	@product_count INT OUTPUT
) AS
BEGIN
	SELECT
		product_name,
		list_price
	FROM production.products
	WHERE model_year = @model_year

	SELECT @product_count = @@ROWCOUNT;
END;

DECLARE @count INT;

EXEC FindProductByModel @model_year = 2018, @product_count = @count OUTPUT;

SELECT @count AS 'Count';


-- BEGIN END
BEGIN
	SELECT
		product_id, product_name
	FROM production.products
	WHERE list_price > 100000;

	IF @@ROWCOUNT = 0
		PRINT 'NO products with price greater then 100000'
END;

-- declare a variable called name then select top 1 most expensive product from products table, 
--if there is any row means count not equal 0 then print a message

-- nested begin end & IF ELSE
BEGIN
	DECLARE @name VARCHAR(MAX);

	SELECT TOP 1
		@name = product_name
	FROM production.products
	ORDER BY list_price DESC

	IF @@ROWCOUNT <> 0
		BEGIN
			PRINT 'The most expensive product is ' + @name
		END
	ELSE
		BEGIN
			PRINT 'No product found'
		END
END;

--WHILE statement
DECLARE @counter INT = 1;

WHILE @counter <= 5
	BEGIN
		PRINT @counter;
		SET @counter = @counter + 1
	END

-- break
DECLARE @counter INT = 1;

WHILE @counter <= 5
	BEGIN
		SET @counter = @counter + 1
		IF @counter = 4
			BREAK
		PRINT @counter;
	END

-- continue
DECLARE @counter INT = 0;

WHILE @counter < 5
	BEGIN
		SET @counter = @counter + 1
		IF @counter = 3
			CONTINUE
		PRINT @counter;
	END

--cursor

DECLARE product_cursor CURSOR
FOR SELECT
		product_name,
		list_price
	FROM production.products

OPEN product_cursor;

DECLARE @product_name VARCHAR(MAX),
	@list_price DECIMAL;

FETCH NEXT FROM product_cursor INTO
	@product_name, @list_price

WHILE @@FETCH_STATUS = 0
	BEGIN
		PRINT @product_name + CAST(@list_price AS VARCHAR)
		--SELECT @product_name, @list_price
		FETCH NEXT FROM product_cursor INTO
		@product_name, @list_price
	END

CLOSE product_cursor;
DEALLOCATE product_cursor;

