
use film_rental;
select * from actor;
select * from category;
select * from rental;
select * from film;
select * from payment;
select * from film_category;
#1)

select sum(amount) as `total amount generated` from payment;
#2)
select count(rental_id), monthname(rental_date) from rental group by monthname(rental_date) ;
#3)
select film_id,title,max(length(title)) as maximum_length,rental_rate from film group by title,film_id order by maximum_length desc limit 1 ;

#4)
SELECT AVG(f.rental_rate) AS average_rental_rate
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.rental_date BETWEEN '2005-05-24 22:53:30' AND '2005-06-25 22:53:30';

select distinct date(rental_date),month(rental_date) from rental;
#5)
select c.category_id,c.name,count(r.rental_id) as popular_category from category c
left join film_category fc
on c.category_id = fc.category_id
left join film f
on fc.film_id = f.film_id
left join inventory i
on f.film_id = i.film_id
left join rental r
on i.inventory_id = r.inventory_id group by c.category_id order by popular_category desc limit 1 ;
#6)
select f.film_id,f.title,f.length,group_concat(r.rental_id) as no_rentals from film f 
left join inventory i
on f.film_id = i.film_id
left join rental r
on i.inventory_id = r.inventory_id group by f.film_id having no_rentals is null order by f.length desc limit 1;
#7)
select c.name,fc.category_id,avg(f.rental_rate) as average from category c
left join film_category fc
on c.category_id = fc.category_id
left join film f
on fc.film_id = f.film_id group by fc.category_id,c.name order by average desc ;
#8)
select a.actor_id,a.first_name,a.last_name,sum(p.amount) as `total earned by each actor` from actor a
left join film_actor fa
on a.actor_id = fa.actor_id
left join film f
on fa.film_id = f.film_id
left join inventory i
on f.film_id = i.film_id
left join rental r
on i.inventory_id = r.inventory_id
left join payment p
on r.rental_id = p.rental_id group by a.actor_id order by `total earned by each actor` desc;
#9)
select a.actor_id,concat(a.first_name,' ',a.last_name),f.description,dense_rank() OVER (ORDER BY a.actor_id) AS row_num from actor a
left join film_actor fa
on a.actor_id = fa.actor_id
left join film f
on fa.film_id = f.film_id  having f.description like  "%Wrestler%" ;
#10)
SELECT c.customer_id, f.film_id,c.first_name,c.last_name,group_concat(r.rental_id), COUNT(*) as rental_count from customer c
left join rental r
on c.customer_id = r.customer_id
left join inventory i
on i.inventory_id = r.inventory_id
left join film f
on i.film_id = f.film_id GROUP BY c.customer_id,f.film_id
HAVING COUNT(*) > 1;
#11)
select avg(rental_rate) from film;
select c.name,f.film_id,f.title,f.rental_rate from film f
left join film_category fc
on f.film_id = fc.film_id
left join category c
on fc.category_id = c.category_id having f.rental_rate > 2.98 and c.name rlike ("comedy") ;
#12)
WITH RankedRentals AS (
    SELECT
        ci.city_id,
        f.film_id,
        f.title,
        COUNT(r.rental_id) AS rental_count,
        ROW_NUMBER() OVER (PARTITION BY ci.city_id ORDER BY COUNT(r.rental_id) DESC) AS ranking
    FROM
        customer c
    JOIN
        rental r ON c.customer_id = r.customer_id
    JOIN
    
        inventory i ON r.inventory_id = i.inventory_id
    JOIN
        film f ON i.film_id = f.film_id
    JOIN
        address a ON c.address_id = a.address_id
    JOIN
        city ci ON a.city_id = ci.city_id
    GROUP BY
        ci.city_id, f.film_id, f.title
)
SELECT
    rr.city_id,
    rr.film_id,
    rr.title,
    rr.rental_count
FROM
    RankedRentals rr
WHERE
    rr.ranking = 1;


#13)
select c.customer_id,c.first_name,c.last_name,sum(p.amount) as total_amount from customer c
left join rental r
on c.customer_id = r.customer_id
left join payment p
on r.rental_id = p.rental_id group by c.customer_id,c.first_name,c.last_name having total_amount > 200;
#15)
select * from staff;
select s.staff_id,concat(s.first_name ,' ' ,s.last_name),sum(p.amount),s.store_id,c.city,co.country from payment p
left join staff s
on p.staff_id = s.staff_id
left join store st
on s.store_id = st.store_id
left join address a
on st.address_id = a.address_id
left join city c
on a.city_id = c.city_id
left join country co
on c.country_id = co.country_id group by s.staff_id;

#16)
select dayname(r.rental_date),concat(c.first_name,'',c.last_name),f.title,datediff(r.return_date,r.rental_date) as no_of_rental_days,
p.amount,round((p.amount/(select sum(amount) from payment WHERE customer_id = c.customer_id)) * 100,2) as percentage
from customer c
left join payment p
on c.customer_id = p.customer_id
left join rental r
on p.rental_id = r.rental_id
left join inventory i
on r.inventory_id = i.inventory_id
left join film f
on i.film_id = f.film_id group by c.customer_id,c.first_name,c.last_name,f.title,r.rental_date,r.return_date,p.amount;

#17)
select
    c.customer_id,
    concat(c.first_name, ' ', c.last_name) AS full_name,
    sum(p.amount) AS total_payment,
    sum(f.rental_rate) AS total_rental_cost,
    min(p.payment_date) AS first_payment_date,
    max(p.payment_date) AS last_payment_date
from customer c
left join payment p 
on c.customer_id = p.customer_id
left join rental r 
on p.rental_id = r.rental_id
left join inventory i
on r.inventory_id = i.inventory_id
left join film f
on i.film_id = f.film_id
group by c.customer_id
having total_payment >= 0.5 * total_rental_cost
and datediff(last_payment_date, first_payment_date) <= 1;