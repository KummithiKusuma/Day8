use pubs

SELECT title
FROM titles
WHERE authors = 'CA';

SELECT * from sales 
FROM titles
GROUP BY store_id;

SELECT t.title_id, t.title, COUNT(o.orders_id) AS NumberOfOrders
FROM Titles t
LEFT JOIN Order o ON t.title_id = o.titles_id
GROUP BY t.title_id, t.title_name

SELECT t.title_id, t.title_name, COUNT(o.order_id) AS NumberOfOrders
FROM titles t
LEFT JOIN Orders o ON t.title_id = o.title_id
GROUP BY t.title_id, t.title_name
											
SELECT p.publisher_name, b.book_name
FROM Publishers p
JOIN Books b ON p.publisher_id = b.publisher_id;

SELECT CONCAT(first_name, ' ', last_name) AS AuthorFullName
FROM Authors;

SELECT title, price, price + (price * 12.36 / 100) AS PriceWithTax
FROM titles;

SELECT A.title_id, T.title
FROM titles A
JOIN Titles T ON A.title_id = T.title_id;

SELECT  A title_name, T.authors_name, P.publisher_name
FROM titles A
JOIN Titles T ON A.authors_id = T.author_id
JOIN Publishers P ON T.publisher_id = P.publisher_id;

SELECT P.published_id, AVG(B.price) AS AveragePrice
FROM titles P
JOIN titles B ON P.pub_id = B.pub_id
GROUP BY P.published_id;