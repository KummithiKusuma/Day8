use pubs
select * from authors

--projection
select au_fname, phone from authors
select au_fname 'Author Name' ,phone 'Contact Number' from authors
select au_fname as 'Author Name' ,phone as 'Contact Number' from authors
select au_fname Author_Name ,phone Contact_Number from authors

--selection
select * from authors where contract = 0
select * from titles where royalty  >10
select * from titles where royalty  >10 or price>15
select * from titles where royalty  >10 and price>15
select title 'Book Name', price 'Cost', royalty 'Royalty Paid',
advance 'Advance received'
from titles 

--selection
select * from authors where contract = 0
select * from titles where royalty  >10
select * from titles where royalty  >10 or price>15
select * from titles where royalty  >10 and price>15
select title 'Book Name', price 'Cost', royalty 'Royalty Paid',
advance 'Advance received'
from titles 
where royalty  >10 and price>15

select title from titles where price >= 10 and price <=25
select title from titles where price between 10 and 25
select * from titles where title like 'The%'

--I want the books that have price of 10 or 20 or 30
select * from titles where price =10 or price = 20 or price = 30

select * from titles where price in (10, 20, 30)
select AVG(price) 'Averge price' from titles

select AVG(price) 'Averge price'from titles where  type='business'

select AVG(price) 'Averge price', Sum(price) 'Sum of price' from titles


--sub total and grouping
select type 'Type name', AVG(price) 'Averge price'from titles group by type

select state, count(au_id) from authors group by state

select title_id, count(ord_num) 'number of times sold'
from sales group by title_id


select title_id, count(ord_num) 'number of times sold'
from sales
group by title_id 
having count(ord_num) >1


select type 'Type name', AVG(price) 'Averge price'
from titles 
where price >10
group by type
having AVG(price)>18

---sorting
select * from authors order by state,city,au_fname

select type 'Type name', AVG(price) 'Averge price'
from titles 
where price >10
group by type
having AVG(price)>18
order by Type desc

--subqueries

select * from titles
select * from sales
select title_id from titles where title = 'Straight Talk About Computers'
select * from sales where title_id = 'BU7832'

select * from sales where title_id =
(select title_id from titles where title = 'Straight Talk About Computers')

select * from authors

Select * from titles where title_id in(
select title_id from titleauthor where au_id = 
(select au_id from authors where au_lname = 'White'))