--Выведите магазины, имеющие больше 300-от покупателей
select s.store_id, a.address, a.district, c2.city, c3.country 
from store s
join customer c on c.store_id = s.store_id 
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id  
group by s.store_id, a.address, a.district, c2.city, c3.country
having count (c.customer_id) > 300
--Специально выведено много атрибутов, т.к. просто адрес магазина ничего не говорит, хотелось вывести город и страну

--Выведите у каждого покупателя город, в котором он живет
select concat (c.last_name, ' ', c.first_name) as full_name, c2.city , c3.country 
from customer c
join address a on c.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id 
order by c3.country, c2.city 
--Добавлена страна, в которой живет, и сортировка стран, городов по алфавиту

--Выведите ФИО сотрудников и города магазинов, имеющих больше 300-от покупателей
select concat (s2.last_name, ' ', s2.first_name) as full_name, a.address, a.district, c2.city, c3.country 
from staff s2
join store s on s2.store_id = s.store_id 
join customer c on c.store_id = s.store_id 
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id  
group by s.store_id, s2.last_name, s2.first_name, a.address, a.district, c2.city, c3.country
having count (c.customer_id) > 300

--Выведите ФИО сотрудников и города магазинов, имеющих больше 300-от покупателей - через подзапрос
select concat (s.last_name, ' ', s.first_name) as full_name, c2.city 
from
	(select c.store_id 
	from customer c 
	group by c.store_id 
	having count (c.customer_id) > 300) as t
join staff s on s.store_id = t.store_id
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 

--Выведите количество актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99
select count (distinct fa.actor_id)--, fa.film_id 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
--order by fa.film_id 

--Выведите ФИО актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99
select distinct concat (a.last_name, ' ', a.first_name) as full_name, q.rental_rate 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
join actor a on a.actor_id = fa.actor_id 
order by concat (a.last_name, ' ', a.first_name)
--Этот запрос сделан для того, чтобы проверить, какие именно актеры выбираются для фильмов с арендной платой 2,99. 
--Почему-то в этой выборе 199 строк. А по счетчику в запросе выше - 200 записей актерами в таких фильмах. Поэтому - следующий запрос

--Выведите ФИО актеров, снимавшихся в фильмах, которые сдаются в аренду за 2,99
select distinct fa.actor_id, concat (a.last_name, ' ', a.first_name) as full_name, q.rental_rate 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
join actor a on a.actor_id = fa.actor_id 
order by concat (a.last_name, ' ', a.first_name)
--Оказалось, что два актера имеют одинаковые ФИО Davis Susan и разные id. Т.е. полагаем, что это разные люди. 
--Т.е. предыдущий запрос неверный, этот запрос верный.
--ВОПРОС: как сделать, чтобы в результаты не выводился actor_id (только ФИО и арендная плата? 
--Если пишу dictinct не сразу в select, а в другом месте запроса, то выдает ошибку, что distinct находится не в том месте
