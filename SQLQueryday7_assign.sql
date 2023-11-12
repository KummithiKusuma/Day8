use pubs
SELECT title
FROM titles
WHERE title LIKE '%e%' AND title LIKE '%a%';
sp_help titles
CREATE TRIGGER PreventPriceUpdateBelowSeven
BEFORE UPDATE ON titles
FOR EACH ROW
BEGIN
    IF NEW.price < 7 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Price cannot be updated below 7';
    END IF;
END;


SELECT
    constraint_name,
    titles_type,
    table_name,
    column_name
FROM
    information_schema.key_column_usage
WHERE
    table_name = 'titles';

CREATE PROCEDURE CountBooksPricedLessThan(IN price_threshold DECIMAL(10, 2))
BEGIN
    DECLARE book_count INT;
    SELECT COUNT(*) INTO book_count FROM Books WHERE price < price_threshold;
    SELECT CONCAT('Number of books priced less than $', price_threshold, ': ', book_count) AS result;
END;

SELECT s.*
FROM titles s
WHERE s.qty > (
    SELECT MAX(qty)
    FROM sales
    WHERE title = s.title AND store_name = s.store_name
);

CREATE PROCEDURE get_total_sales_by_author (
    @author_name VARCHAR(60)
)
AS
BEGIN
    DECLARE @total_sales DECIMAL(10,2);
	SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
    INNER JOIN titles t ON s.title_id = t.title_id
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN authors a ON ta.au_id = a.au_id
    WHERE a.au_fname + ' ' + a.au_lname = @author_name)
    IF @total_sales IS NULL OR @total_sales = 0
    BEGIN
        PRINT 'Sale yet to gear up';
    END
    ELSE
    BEGIN
        PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
    END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';

SELECT s.*
FROM sales s
INNER JOIN (
    SELECT title, store, MAX(qty) AS max_quantity
    FROM titles
    GROUP BY title, store
) t
ON s.titles = t.title AND s.store = t.store
WHERE s.qty > t.max_quantity;











-- Retrieve information for all sales
SELECT
    st.stor_name AS 'Store Name',
    t.title AS 'Title Name',
    s.qty AS 'Quantity',
    s.qty * t.price AS 'Sale Amount',
    p.pub_name AS 'Publisher Name',
    CONCAT(au.au_fname, ' ', au.au_lname) AS 'Author Name',
    'Sold' AS 'Status'
FROM sales s
JOIN stores st ON s.stor_id = st.stor_id
JOIN titles t ON s.title_id = t.title_id
JOIN publishers p ON t.pub_id = p.pub_id
LEFT JOIN titleauthor ta ON t.title_id = ta.title_id
LEFT JOIN authors au ON ta.au_id = au.au_id

UNION ALL

-- Books that have not been sold
SELECT
    t.title AS 'Title Name',
    p.pub_name AS 'Publisher Name',
    NULL AS 'Quantity',
    NULL AS 'Sale Amount',
    NULL AS 'Store Name',
    CONCAT(au.au_fname, ' ', au.au_lname) AS 'Author Name',
    'Not Sold' AS 'Status'
FROM titles t
JOIN publishers p ON t.pub_id = p.pub_id
LEFT JOIN titleauthor ta ON t.title_id = ta.title_id
LEFT JOIN authors au ON ta.au_id = au.au_id

UNION ALL

-- Authors who have not written any books
SELECT
    NULL AS 'Store Name',
    NULL AS 'Title Name',
    NULL AS 'Quantity',
    NULL AS 'Sale Amount',
    NULL AS 'Publisher Name',
    CONCAT(au.au_fname, ' ', au.au_lname) AS 'Author Name',
    'Not Written' AS 'Status'
FROM authors au
LEFT JOIN titleauthor ta ON au.au_id = ta.au_id;








CREATE PROCEDURE get_total_sales_by_author (
    @author_name VARCHAR(60)
)
AS
BEGIN
    DECLARE @total_sales DECIMAL(10,2);
	SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
    INNER JOIN titles t ON s.title_id = t.title_id
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN authors a ON ta.au_id = a.au_id
    WHERE a.au_fname + ' ' + a.au_lname = @author_name)
    IF @total_sales IS NULL OR @total_sales = 0
    BEGIN
        PRINT 'Sale yet to gear up';
    END
    ELSE
    BEGIN
        PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
    END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';

SELECT
    s.stor_id AS 'Store ID',
    s.title_id AS 'Title ID',
    t.title AS 'Title',
    s.qty AS 'Sale Quantity',
    s.ord_date AS 'Sale Date'
FROM sales s
left JOIN (
    SELECT
        s.stor_id,
        s.title_id,
        MAX(s.qty) AS max_qty
    FROM sales s
    GROUP BY s.stor_id, s.title_id
) max_sale_qty ON s.stor_id = max_sale_qty.stor_id
    AND s.title_id = max_sale_qty.title_id
    AND s.qty > max_sale_qty.max_qty
JOIN titles t ON s.title_id = t.title_id;

select
    st.stor_name  'Store Name',
    t.title  'Title Name',
    s.qty  'Quantity',
    s.qty * t.price  'Sale Amount',
    p.pub_name  'Publisher Name',
    CONCAT(au.au_fname, ' ', au.au_lname)  'Author Name',
    'Sold'  'Status'
from sales s
join stores st on s.stor_id = st.stor_id
join titles t on s.title_id = t.title_id
join publishers p on t.pub_id = p.pub_id
left join titleauthor ta on t.title_id = ta.title_id
left join authors au on ta.au_id = au.au_id

union all

select
    t.title  'Title Name',
    p.pub_name  'Publisher Name',
    null  'Quantity',
    null  'Sale Amount',
    null  'Store Name',
    CONCAT(au.au_fname, ' ', au.au_lname)  'Author Name',
    'Not Sold'  'Status'
from titles t
join publishers p on t.pub_id = p.pub_id
left join titleauthor ta on t.title_id = ta.title_id
left join authors au on ta.au_id = au.au_id

union all

select
    null  'Store Name',
    null  'Title Name',
    null  'Quantity',
    null  'Sale Amount',
    null  'Publisher Name',
    CONCAT(au.au_fname, ' ', au.au_lname)  'Author Name',
    'Not Written'  'Status'
from authors au
left join titleauthor ta on au.au_id = ta.au_id;






select
    concat(au.au_fname, ' ', au.au_lname)  'Author Name',
    AVG(t.price) 'Average Price'
from authors au
join titleauthor ta on au.au_id = ta.au_id
join titles t on ta.title_id = t.title_id
group by au.au_id, au.au_fname, au.au_lname;


sp_columns 'titles'  -- Get the schema of the titles table
sp_helpconstraint 'titles'  -- Locate the constraints for the titles table


create procedure proc_CountBooksPricedLessThan 
	@Price decimal(10, 2)
as
begin
    declare @BookCount int
    select @BookCount = count(*)
    from titles
    where price < @Price

    -- Print the count
    PRINT 'Count of books priced less than ' + CAST(@Price AS VARCHAR) + ': ' + CAST(@BookCount AS VARCHAR)
END
EXEC proc_CountBooksPricedLessThan 20.00



create trigger check_price_before_update
on titles 
instead of insert
as
begin
    declare
	@title_id varchar(6),
	@title varchar(60),
	@type char(12),
	@pub_id char(4),
	@price money,
	@advance money,
	@royalty int,
	@ytd_sales int,
	@notes varchar(200),
	@pubdate datetime,
	@new_price decimal(10,2);
    set @new_price = (select  price from inserted);

    if @new_price < 7
    begin
        print 'The price cannot be updated to below 7';
    end
	else
	begin
		insert into titles values(@title_id,@title,@type,@pub_id,@price,@advance,@royalty ,@ytd_sales ,@notes,@pubdate)
	end
end


insert into titles values('AU1099','Learn From Failures',
		'psychology','0599',6.00,15000.00,25,333,
		'Here you can face fear of Failures','2023-10-30 00:00:00:000')





create trigger check_price_before_update
on titles 
instead of insert
as
begin
    declare
	@title_id varchar(6),
	@title varchar(60),
	@type char(12),
	@pub_id char(4),
	@price money,
	@advance money,
	@royalty int,
	@ytd_sales int,
	@notes varchar(200),
	@pubdate datetime,
	@new_price decimal(10,2);
    set @new_price = (select  price from inserted);

    if @new_price < 7
    begin
        print 'The price cannot be updated to below 7';
    end
	else
	begin
		insert into titles values(@title_id,@title,@type,@pub_id,@price,@advance,@royalty ,@ytd_sales ,@notes,@pubdate)
	end
end


insert into titles values('AU1099','Learn From Failures',
		'psychology','0599',6.00,15000.00,25,333,
		'Here you can face fear of Failures','2023-10-30 00:00:00:000')



		CREATE TRIGGER check_price_before_update
ON titles 
instead of insert
AS
BEGIN
    DECLARE
	@title_id varchar(6),
	@title varchar(60),
	@type char(12),
	@pub_id char(4),
	@price money,
	@advance money,
	@royalty int,
	@ytd_sales int,
	@notes varchar(200),
	@pubdate datetime,
	@new_price DECIMAL(10,2);
    SET @new_price = (SELECT  price FROM inserted);

    IF @new_price < 7
    BEGIN
        PRINT 'The price cannot be updated to below 7';
    END;
	ELSE
	BEGIN
		insert into titles values(@title_id,@title,@type,@pub_id,@price,@advance,@royalty ,@ytd_sales ,@notes,@pubdate)
	END;
END;


insert into titles values('AU1099','Learn From Failures',
		'psychology','0599',6.00,15000.00,25,333,
		'Here you can face fear of Failures','2023-10-30 00:00:00:000')















CREATE TRIGGER check_price_before_update
ON titles 
instead of insert
AS
BEGIN
    DECLARE
	@title_id varchar(6),
	@title varchar(60),
	@type char(12),
	@pub_id char(4),
	@price money,
	@advance money,
	@royalty int,
	@ytd_sales int,
	@notes varchar(200),
	@pubdate datetime,
	@new_price DECIMAL(10,2);
    SET @new_price = (SELECT  price FROM inserted);

    IF @new_price < 7
    BEGIN
        PRINT 'The price cannot be updated to below 7';
    END;
	ELSE
	BEGIN
		insert into titles values(@title_id,@title,@type,@pub_id,@price,@advance,@royalty ,@ytd_sales ,@notes,@pubdate)
	END;
END;


insert into titles values('AU1099','Learn From Failures',
		'psychology','0599',6.00,15000.00,25,333,
		'Here you can face fear of Failures','2023-10-30 00:00:00:000')




select title
from titles
where title like '%e%' and title like '%a%';






		CREATE PROCEDURE get_total_sales_by_author (
    @author_name VARCHAR(60)
)
AS
BEGIN
    DECLARE @total_sales DECIMAL(10,2);
	SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
    INNER JOIN titles t ON s.title_id = t.title_id
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN authors a ON ta.au_id = a.au_id
    WHERE a.au_fname + ' ' + a.au_lname = @author_name)
    IF @total_sales IS NULL OR @total_sales = 0
    BEGIN
        PRINT 'Sale yet to gear up';
    END
    ELSE
    BEGIN
        PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
    END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';













alter PROCEDURE get_total_sales_by_author (
    @author_name VARCHAR(60)
)
AS
BEGIN
    DECLARE @total_sales DECIMAL(10,2);
	SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
    INNER JOIN titles t ON s.title_id = t.title_id
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN authors a ON ta.au_id = a.au_id
    WHERE a.au_fname + ' ' + a.au_lname = @author_name)
    IF @total_sales IS NULL OR @total_sales = 0
    BEGIN
        PRINT 'Sale yet to gear up';
    END
    ELSE
    BEGIN
        PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
    END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';




alter PROCEDURE get_total_sales_by_author (@author_name VARCHAR(60))
AS
BEGIN
    DECLARE @total_sales DECIMAL(10,2);
	SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
    INNER JOIN titles t ON s.title_id = t.title_id
    INNER JOIN titleauthor ta ON t.title_id = ta.title_id
    INNER JOIN authors a ON ta.au_id = a.au_id
    WHERE a.au_fname + ' ' + a.au_lname = @author_name)
    IF @total_sales IS NULL OR @total_sales = 0
    BEGIN
        PRINT 'Sale yet to gear up';
    END
    ELSE
    BEGIN
        PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
    END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';






















alter PROCEDURE get_total_sales_by_author (@author_name VARCHAR(60))
AS
BEGIN
DECLARE @total_sales DECIMAL(10,2);
SET @total_sales = (SELECT sum(s.qty )* sum(t.price)  FROM sales s
INNER JOIN titles t ON s.title_id = t.title_id
INNER JOIN titleauthor ta ON t.title_id = ta.title_id
INNER JOIN authors a ON ta.au_id = a.au_id
WHERE a.au_fname + ' ' + a.au_lname = @author_name)
IF @total_sales IS NULL OR @total_sales = 0
BEGIN
PRINT 'Sale yet to gear up';
END
ELSE
BEGIN
PRINT 'The total sales amount for ' + @author_name + ' is ' + CAST(@total_sales AS VARCHAR);
END;
END;

EXEC get_total_sales_by_author @author_name = 'Ann Ringer';

select * from authors
