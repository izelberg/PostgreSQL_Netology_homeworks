1. Рассчитайте совокупный доход всех магазинов на каждую дату.
2. Выведите наиболее и наименее востребованные жанры (те, которые арендовали наибольшее/наименьшее количество раз),
число их общих продаж и сумму дохода/
3. Какова средняя арендная ставка для каждого жанра?
(упорядочить по убыванию, среднее значение округлить до сотых)
===== Дополнительные задания =====
4. Cоставить список из 5 самых дорогих клиентов (арендовавших фильмы с 10 по 13 апреля).
формат списка:
'Имя_клиента Фамилия_клиента email address is: e-mail_клиента'
5. Сколько арендованных фильмов было возвращено в срок, до срока возврата и после, выведите максимальную разницу со сроком?

1. Рассчитайте совокупный доход всех магазинов на каждую дату. Если считать, что совокупный доход на каждую дату - это сумма продаж на каждую дату.

alter table payment 
ALTER COLUMN payment_date SET DATA TYPE data --Сначала поменяла тип данных дата платежа с timestamp на date. 
--Потом уже решила, что это плохо. Надо было создать еще одну колонку payment_date2, равное payment_date с типом данных date. А так я попортила первоначальные данные.

--Мой вариант
select p.payment_date, sum (p.amount) as total_sum
from payment p 
group by p.payment_date 
order by p.payment_date desc

--Вариант из самопроверки 1 
select date(p.payment_date), sum(amount)
from payment p
group by date(p.payment_date)
order by date(p.payment_date)

--Вариант из самопроверки 2
with pds as (
  select cast(payment_date as date) as payment_date, sum(amount) as amount
  from payment
  group by cast(payment_date as date)
)
select payment_date, amount, sum(amount) over (order by payment_date)
from pds
order by payment_date;


2. Выведите наиболее и наименее востребованные жанры (те, которые арендовали наибольшее/наименьшее количество раз),
число их общих продаж и сумму дохода/

--Мой вариант 1
with cte_1 as (
	select c2."name", c2.category_id , count(r.rental_id) as count_rental_id, sum(p2.amount) as total_sum
	from rental r
	join inventory i using (inventory_id)
	join film f using (film_id)
	join film_category fc using (film_id)
	join category c2 using (category_id)
	join payment p2 on r.rental_id = p2.rental_id 
	group by c2."name" , c2.category_id
)
select cte_1.name, cte_1.count_rental_id, cte_1.total_sum
from cte_1
join 
(select max(count_rental_id), min(count_rental_id) 
from cte_1) as q
on cte_1.count_rental_id = q.max or cte_1.count_rental_id = q.min

--Мой вариант 2
select name, cnt, total
from 
(
select name, cnt, total,
	max(cnt) over () as max_cnt,
	min(cnt) over () as min_cnt
from 
(
select distinct c2."name", c2.category_id, 
	count (r.rental_id) over (partition by c2.category_id) cnt,
	sum (p2.amount) over (partition by c2.category_id) total
from rental r
	join inventory i using (inventory_id)
	join film f using (film_id)
	join film_category fc using (film_id)
	join category c2 using (category_id)
	join payment p2 on r.rental_id = p2.rental_id 
) a
) b
where cnt = max_cnt or cnt = min_cnt	

--Вариант из самопроверки 1
with trds as(
select c.name as category_name,
	count(*) as cnt,
	sum (p.amount) as sums
   from category c
   join film_category fc
   using (category_id)
   join film f
   using (film_id)
   join inventory i
   using (film_id)
   join rental r
   using (inventory_id)
   join customer cu
   using (customer_id)
   join payment p
   using (rental_id)
   group by category_name
)
select category_name, cnt, sums
from trds 
where cnt = (
select max(cnt)
from trds
) 
or cnt = (
select min(cnt)
from trds
)

--Вариант из самопроверки 2
 (
select 'наибольшее кол-во продаж - ' || c.name || ' в размере ' || count(p.rental_id) || ' на сумму ' || sum(p.amount)
from payment p
inner join rental r on r.rental_id = p.rental_id
inner join inventory i on i.inventory_id = r.inventory_id
inner  join film f on f.film_id = i.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by c.name
order by count(p.rental_id) desc
limit 1
)
union all
(
select 'наименьшее кол-во продаж - ' || c.name || ' в размере ' || count(p.rental_id) || ' на сумму ' || sum(p.amount)
from payment p
inner join rental r on r.rental_id = p.rental_id
inner join inventory i on i.inventory_id = r.inventory_id
inner join film f on f.film_id = i.film_id
inner join film_category fc on fc.film_id = f.film_id
inner join category c on c.category_id = fc.category_id
group by c.name
order by count(p.rental_id) asc
limit 1
)


3. Какова средняя арендная ставка для каждого жанра?
(упорядочить по убыванию, среднее значение округлить до сотых)
--Непонятно сформулировано, что такое средняя арендная ставка для жанра. Они посчитали, что это рентал_рейт / продолжительность аренды, т.е. ставка в день.
--Я посчитала, что это среднее количество денег, заплаченных за аренду (из платежей)

--Мой вариант
select "name", avg_rental_rate
from 
(
select c2."name", c2.category_id , avg(p2.amount)::numeric(6,3) as avg_rental_rate 
	from rental r
	join inventory i using (inventory_id)
	join film f using (film_id)
	join film_category fc using (film_id)
	join category c2 using (category_id)
	join payment p2 on r.rental_id = p2.rental_id 
	group by c2."name" , c2.category_id
) a
order by avg_rental_rate desc

--Вариант из самопроверки
select c.name as category_name, round(avg(f.rental_rate/f.rental_duration), 2) as avr
from category c
join film_category fc
using (category_id)
join film f
using (film_id)
group by c.name
order by avr desc


4. Cоставить список из 5 самых дорогих клиентов (арендовавших фильмы с 10 по 13 апреля).
формат списка:
'Имя_клиента Фамилия_клиента email address is: e-mail_клиента'

--Мой вариант
select concat (a.first_name, ' ', a.last_name, ' email address is: ', a.email ) as top_5_valuable_clients
from 
(
select c.customer_id, c.first_name, c.last_name, c.email , sum (amount) as total_sum
from  payment p 
join customer c using (customer_id)
where p.payment_date >= '2007-04-10' and p.payment_date <= '2007-04-13'
group by c.customer_id 
order by total_sum desc
) a
limit 5

--Вариант из самопроверки 1
select first_name||' '||last_name||'''s email address is: '||email as name_and_email
from customer
where customer_id in (
	select customer_id from (
		select distinct customer_id, sum(amount)
		from payment
		where extract(month from payment_date) = 4
		and extract(day from payment_date) between 10 and 13
		group by customer_id
		order by sum(amount) desc
		limit 5
		) as top_five
	);

--Вариант из самопроверки 2
select
	first_name,
	last_name,
	concat('email address is ', email) as email
from
	payment as r
	inner join customer 
	using (customer_id)
where
	payment_date::date between '2007-04-10' and '2007-04-13'
group by first_name, last_name, email
order by sum(amount) desc
limit 5;

--Вариант из самопроверки 3
select ci.first_name, ci.last_name, concat('email address is:' ,ci.email) from customer as ci
inner join (
select pay.customer_id, sum(pay.amount) from payment as pay
where pay.payment_date between '2007-04-10' and '2007-04-13'
group by pay.customer_id
order by sum(pay.amount) desc limit 5) as top 
on top.customer_id =ci.customer_id;

5. Сколько арендованных фильмов было возвращено в срок, до срока возврата и после, выведите максимальную разницу со сроком?

--Мой вариант. Не поняла условие, что надо сравнивать (return_date - rental_date) с rental_duration. Не стала переделывать
with cte_1 as (
select count(r.return_date - r.rental_date) as return_before_time
from rental r
where (r.return_date - r.rental_date) > '23:59:59'
),
cte_2 as (select count(r.return_date - rental_date) as return_on_time
from rental r
where (r.return_date - r.rental_date) <= '23:59:59' and (r.return_date - r.rental_date) >= '00:00:00'
),
cte_3 as (select count(r.return_date - rental_date) as return_with_delay
from rental r
where (r.return_date - r.rental_date) < '00:00:00'
),
cte_4 as (select max(r.return_date - r.rental_date) as max_time_laps
from rental r
)
select return_before_time, return_on_time, return_with_delay, max_time_laps 
from cte_1, cte_2, cte_3, cte_4

--Вариант из самопроверки 1. Результаты отличаются, потому что неправильно поняла условие
with rdt as (
   select inventory_id, DATE_PART('day', return_date - rental_date) as ddate
   from rental
),
sttbl as (
   select abs(rental_duration - ddate) as absdif,
	case 
	   when rental_duration > ddate then 'раньше'
	   when rental_duration = ddate then 'в срок'
	   else 'позже'
	end as status
   from film f
   join inventory i
   using (film_id)
   join rdt
   using (inventory_id)
)
select status, count(*) as cnt, round(max(absdif)) as maxdif
from sttbl
group by status
order by cnt, maxdif desc

--Вариант из самопроверки 2
with rental_scheme as (
select
	rental_id,
	rental_duration as dur,
	extract(day from return_date - rental_date) as back
from
	rental as r
	left join inventory as i using (inventory_id)
	left join film as f using (film_id)
)
select
	count(case when back = dur then rental_id else null end) as return_in_line,
	count(case when back < dur then rental_id else null end) as return_before_line,
	count(case when back > dur then rental_id else null end) as return_after_line,
	max(back - dur) as max_late_return
from
	rental_scheme

