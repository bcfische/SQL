use sakila;

-- Display the first and last names of all actors from the table actor
select
	first_name
    ,last_name
from actor; /*1a*/

-- Display the first and last name of each actor in a single column in upper case letters
-- Name the column Actor Name
select CONCAT(first_name,' ',last_name) as 'Actor Name'
from actor; /*1b*/

-- You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe"
-- What is one query would you use to obtain this information?
select
	actor_id
    ,first_name
    ,last_name
from actor
where first_name='Joe'; /*2a*/

-- Find all actors whose last name contain the letters GEN
select
	first_name
    ,last_name
from actor
where last_name like '%GEN%'; /*2b*/

-- Find all actors whose last names contain the letters LI
-- This time, order the rows by last name and first name, in that order
select
	last_name
    ,first_name
from actor
where last_name like '%LI%'; /*2c*/

-- Using IN, display the country_id and country columns of the following countries
-- Afghanistan, Bangladesh, and China
select
	country_id
    ,country
from country
where country IN('Afghanistan','Bangladesh','China'); /*2d*/

-- You want to keep a description of each actor
-- You don't think you will be performing queries on a description
-- So create a column in the table actor named description and use the data type BLOB
alter table actor add column description blob; /*3a*/

-- Very quickly you realize that entering descriptions for each actor is too much effort
-- Delete the description column
alter table actor drop description; /*3b*/

-- List the last names of actors, as well as how many actors have that last name
select
	last_name as 'LastName'
	,count(last_name) as 'Count'
from actor
group by last_name; /*4a*/

-- List last names of actors and the number of actors who have that last name,
-- but only for names that are shared by at least two actors
select
	last_name as 'LastName'
    ,count(last_name) as 'Count'
from actor
group by last_name
having count(last_name)>1; /*4b*/

-- The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS
-- Write a query to fix the record
set SQL_SAFE_UPDATES = 0;
select * from actor where last_name='WILLIAMS';
update actor set first_name='HARPO' where first_name='GROUCHO' and last_name='WILLIAMS'; /*4c*/

-- Perhaps we were too hasty in changing GROUCHO to HARPO
-- It turns out that GROUCHO was the correct name after all!
-- In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO
update actor set first_name='GROUCHO' where first_name = 'HARPO'; /*4d*/

-- You cannot locate the schema of the address table
-- Which query would you use to re-create it?
show create table address; /*5a*/

-- Use JOIN to display the first and last names, as well as the address, of each staff member
-- Use the tables staff and address
select
	s.first_name
    ,s.last_name
    ,a.address
from
	staff s
    ,address a
where s.address_id = a.address_id; /*6a-where*/
select
	s.first_name
    ,s.last_name
    ,a.address
from staff s
join address a on s.address_id = a.address_id; /*6a-join*/

-- Use JOIN to display the total amount rung up by each staff member in August of 2005
-- Use tables staff and payment
select
	s.first_name
	,s.last_name
    ,SUM(p.amount) as 'total'
from staff s, payment p
where s.staff_id = p.staff_id and p.payment_date like '%-08-%'
group by s.staff_id; /*6b-where*/
select
	s.first_name
    ,s.last_name
    ,SUM(p.amount) as 'total'
from staff s
join payment p on s.staff_id = p.staff_id
where p.payment_date like '%-08-%'
group by s.staff_id; /*6b-join*/

-- List each film and the number of actors who are listed for that film
-- Use inner join with tables film_actor and film
select
	f.title
    ,COUNT(fa.film_id) as 'actors'
from film_actor fa
inner join film f on fa.film_id = f.film_id
group by fa.film_id; /*6c*/

-- How many copies of the film Hunchback Impossible exist in the inventory system?
set @id = (select film_id from film where title='Hunchback Impossible');
select COUNT(film_id) as 'Copies of Hunchback Impossible'
from inventory
where film_id = @id; /*6d*/

-- Using the tables payment and customer and the JOIN command, list the total paid by each customer
-- List the customers alphabetically by last name
select
	c.first_name
    ,c.last_name
    ,SUM(p.amount) as 'total_amount_paid'
from customer c
join payment p on c.customer_id = p.customer_id
group by p.customer_id
order by c.last_name; /*6e*/

-- The music of Queen and Kris Kristofferson have seen an unlikely resurgence
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English    
select title from film where title like 'K%' or title like 'Q%'; /*7a*/

-- Use subqueries to display all actors who appear in the film Alone Trip
select
	first_name
    ,last_name
from actor
where actor_id in
	(select actor_id from film_actor where film_id=
		(select film_id from film where title='Alone Trip'
		)
	); /*7b*/

-- You want to run an email marketing campaign in Canada
-- Gather all the names and email addresses of customers in Canada
select
	first_name
    ,last_name
    ,email
from customer
where address_id in
	(select address_id from address where city_id in
		(select city_id from city where country_id=
			(select country_id from country where country='Canada'
			)
		)
	); /*7c*/

-- Sales have been lagging among young families, and you wish to target all family movies for a promotion
-- Identify all movies categorized as family films
select title
from film
where film_id in
	(select film_id from film_category where category_id=
		(select category_id from category where name='Family'
        )
	); /*7d*/

-- Display the most frequently rented movies in descending order
select
	film_id
    ,COUNT(film_id)
from inventory i
join rental r
where i.inventory_id=r.inventory_id
group by film_id
order by COUNT(film_id) desc; /*7e*/

-- Write a query to display how much business, in dollars, each store brought in
select
	staff_id as 'store'
    ,SUM(amount) as 'revenue'
from payment
group by staff_id; /*7f*/

-- Write a query to display for each store its store ID, city, and country
select
	s.store_id
    ,ci.city
    ,co.country
from store s
left join address a on s.address_id=a.address_id
left join city ci on a.city_id=ci.city_id
left join country co on ci.country_id=co.country_id; /*7g*/

-- List the top five genres in gross revenue in descending order
select
	name as 'genre'
    ,SUM(amount) as 'gross_revenue'
from
	(select c.name,p.amount
		from payment p
		join rental r on p.rental_id=r.rental_id
		join inventory i on r.inventory_id=i.inventory_id
		join film_category fc on i.film_id=fc.film_id
		join category c on fc.category_id=c.category_id
	) as BigTable
group by name
order by SUM(amount) desc
limit 5; /*7h*/

-- Use the solution from the problem above to create a view
create view top_five_genres as
	select
		name as 'genre'
        ,SUM(amount) as 'gross_revenue'
	from
		(select c.name,p.amount
			from payment p
			join rental r on p.rental_id=r.rental_id
			join inventory i on r.inventory_id=i.inventory_id
			join film_category fc on i.film_id=fc.film_id
			join category c on fc.category_id=c.category_id
		) as BigTable
	group by name
	order by SUM(amount) desc
	limit 5; /*8a*/

-- How would you display the view that you created in 8a?
show create view top_five_genres; /*8b*/

-- You find that you no longer need the view top_five_genres
-- Write a query to delete it
drop view top_five_genres; /*8c*/