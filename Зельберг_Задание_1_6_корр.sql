Домашнее задание:
Сделайте запрос к таблице rental. Используя оконую функцию добавьте колонку с порядковым номером аренды для каждого пользователя (сортировать по rental_date)
Для каждого пользователя подсчитайте сколько он брал в аренду фильмов со специальным атрибутом Behind the Scenes
-напишите этот запрос
-создайте материализованное представление с этим запросом
-обновите материализованное представление
-напишите три варианта условия для поиска Behind the Scenes

select *, row_number () over (partition by customer_id order by rental_date desc)
from rental

create materialized view Behind_the_Scenes as
select q.full_name, q.film_special_features, count(q.film_special_features)
from (
	with cte_2 as (
	select *, row_number () over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name) as full_name, f.title as film_title, unnest(f.special_features) as film_special_features
from cte_2
	join inventory i using (inventory_id)
	join film f using (film_id)
	join customer c using (customer_id)) as q
where q.film_special_features::text like 'Behind the Scenes'
group by q.full_name, q.film_special_features
order by q.count desc
with no data

refresh materialized view Behind_the_Scenes

select * 
from Behind_the_Scenes

--1.1. ПЕРВОНАЧАЛЬНЫЙ Первый вариант поиска Behind_the_Scenes. Первый по созданию. cost 3848
explain analyze
select q.full_name, q.film_special_features, count(q.film_special_features)
from (
	with cte_2 as (
	select *, row_number () over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name) as full_name, f.title as film_title, unnest(f.special_features) as film_special_features
from cte_2
	join inventory i using (inventory_id)
	join film f using (film_id)
	join customer c using (customer_id)) as q
where q.film_special_features::text = 'Behind the Scenes'
group by q.full_name, q.film_special_features
order by q.count desc

--1.2. ИСПРАВЛЕННЫЙ Первый вариант поиска Behind_the_Scenes - без оконной функции. Cost 3648. Самый медленный.
explain analyze
select q.full_name, count (q.film_sp_features)
from
(
	select concat(c.last_name, ' ', c.first_name) as full_name, f.title as film_title, unnest(f.special_features) as film_sp_features
	from film f
		join inventory i using (film_id)
		join rental r using (inventory_id)
		join customer c using (customer_id)
) as q
where q.film_sp_features::text = 'Behind the Scenes'
group by q.full_name
order by q.count desc


--2.1. ПЕРВОНАЧАЛЬНЫЙ Второй вариант поиска Behind_the_Scenes.  cost 1156
explain analyze
select q.full_name, count(*)
from (
	with cte_2 as (
	select *, row_number () over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name) as full_name, f.title as film_title
from cte_2
	join inventory i using (inventory_id)
	join film f on f.film_id = i.film_id and array_position(f.special_features, 'Behind the Scenes') is not null 
	join customer c using (customer_id)) as q
group by q.full_name
order by q.count desc


--2.2. ИСПРАВЛЕННЫЙ Второй вариант поиска Behind_the_Scenes - без оконной функции. Меньше затрат, но скорость меньше, чем в третьем исправленном. cost 822
explain analyze
select concat(c.last_name, ' ', c.first_name) as full_name, count(*)
from rental r
	join inventory i using (inventory_id)
	join film f on f.film_id = i.film_id and array_position(f.special_features, 'Behind the Scenes') is not null 
	join customer c using (customer_id) 
group by full_name
order by count desc

--3.1. ПЕРВОНАЧАЛЬНЫЙ Третий вариант поиска Behind_the_Scenes. Надо было придумать третий способ. Самый медленный. cost 6397
explain analyze
select * from (
select q.full_name, q.film_special_features, 
	sum(case when q.film_special_features = 'Behind the Scenes' then 1 else 0 end) as sum
from (
	with cte_2 as (
	select *, row_number () over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name) as full_name, f.title as film_title, unnest(f.special_features) as film_special_features
from cte_2
	join inventory i using (inventory_id)
	join film f using (film_id)
	join customer c using (customer_id)) as q
group by q.full_name, q.film_special_features
) as q2 
where q2.sum > 0
order by q2.sum desc


--3.2. ИСПРАВЛЕННЫЙ Третий вариант поиска Behind_the_Scenes. cost 6119 - потому что добавлен еще один селект: сначала по customer_id, потом по полному ФИО. 
--Скорость самая быстрая из исправленных трех вариантов
explain analyze
select 
	(select concat(c2.last_name, ' ', c2.first_name) 
	from customer c2
	where c2.customer_id = c.customer_id) as full_name, count(*)
from 
	(select f.film_id , f.special_features
	from film f
	except 
	select f2.film_id, array_remove(f2.special_features, 'Behind the Scenes')
	from film f2) as q
	join inventory i using (film_id)
	join rental r using (inventory_id)
	join customer c using (customer_id)
group by c.customer_id 
order by count desc


--Вариант запроса "из учебника". Медленнее моих запросов. 68,8 мс, cost 1089. Почему у него время на выполнение самое большое, а стоимость самая маленькая?
explain analyze
select distinct cu.first_name  || ' ' || cu.last_name as name, 
	count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
	(select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
	from rental r 
	full outer join 	
		(select *, unnest(f.special_features) as sf_string
		from inventory i
		full outer join film f on f.film_id = i.film_id) as inv 
		on r.inventory_id = inv.inventory_id) as ren 
	on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count desc

