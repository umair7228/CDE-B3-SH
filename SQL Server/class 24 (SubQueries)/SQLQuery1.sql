USE BikeStores;

SELECT order_id, order_date, customer_id
FROM sales.orders
WHERE customer_id IN (
	SELECT customer_id
	FROM sales.customers
	WHERE city = 'New York'
);


SELECT *
FROM production.brands;

SELECT product_id
FROM production.products
WHERE list_price > (
	SELECT AVG(list_price)
	FROM production.products
	WHERE brand_id IN (
		SELECT brand_id
		FROM production.brands
		WHERE brand_name = 'Strider'
			OR brand_name = 'Trek')
	)

SELECT order_id, order_date
FROM sales.orders

select * from sales.order_items;

SELECT
	order_id,
	order_date,
	(SELECT MAX(list_price) 
	FROM sales.order_items i
	WHERE i.order_id = o.order_id
	) AS max_list_price
FROM sales.orders o

SELECT list_price
FROM production.products
WHERE list_price >= ANY (
	SELECT AVG(list_price)
	FROM production.products
	GROUP BY brand_id)

SELECT list_price
FROM production.products
WHERE list_price >= ALL (
	SELECT AVG(list_price)
	FROM production.products
	GROUP BY brand_id)

SELECT
	AVG(order_count)
FROM
	(SELECT staff_id, count(order_id) as order_count
	FROM sales.orders
	GROUP BY staff_id) t

SELECT list_price, product_name
FROM production.products p1
WHERE list_price IN (
	SELECT MAX(list_price)
	FROM production.products p2
	WHERE p2.category_id = p1.category_id
	GROUP BY category_id)

SELECT customer_id, first_name
FROM sales.customers
WHERE
	EXISTS (SELECT NULL)

SELECT customer_id, first_name
FROM sales.customers c
WHERE
	EXISTS
		(SELECT COUNT(*)
		FROM sales.orders o
		WHERE o.customer_id = c.customer_id
		GROUP BY customer_id
		HAVING COUNT(*) > 2)

SELECT c.category_name, r.product_name, r.list_price
FROM production.categories c
OUTER APPLY
	(SELECT TOP 2 *
	FROM production.products p
	WHERE p.category_id = c.category_id
	ORDER BY list_price DESC) r