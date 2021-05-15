SELECT * FROM avia.INFORMATION_SCHEMA.tables -- Для описания БД
where table_schema = 'bookings'

--1	В каких городах больше одного аэропорта? Через подзапрос работает.
select a2.city, a2.airport_code, a2.airport_name 
from
	(select a.city 
	from airports a
	group by a.city 
	having count (a.city) > 1) as q
join airports a2 using (city)

--2	В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?	- Подзапрос
select a2.airport_code, a2.airport_name, a2.city, q.model
from
	(select a.aircraft_code, a.model , a."range" 
	from aircrafts a
	order by a."range" desc 
	limit 1) as q
join flights f on f.aircraft_code = q.aircraft_code
join airports a2 on f.arrival_airport = a2.airport_code or f.departure_airport = a2.airport_code 
group by a2.airport_code, a2.airport_name, a2.city, q.model

--3	Вывести 10 рейсов с максимальным временем задержки вылета	- Оператор LIMIT
select f.flight_no, f.departure_airport , f.arrival_airport , f.status , (f.actual_departure - f.scheduled_departure) as actual_departure_time_delay
from flights f 
where f.actual_departure is not null 
order by (f.actual_departure - f.scheduled_departure) desc 
limit 10

--4	Были ли брони, по которым не были получены посадочные талоны?	- Верный тип JOIN
select b.book_ref , b.total_amount , t.ticket_no , tf.flight_id, bp.boarding_no --В одной брони несколько рейсов, несколько билетов на рейс. 
--Считает полное количество посадочных мест на рейсы, которые могли бы быть заняты людьми в полете по купленным броням, но по которым никто не полетел (остались пустыми).
--Таких записей очень много, т.к. в одной броне может быть несколько билетов на один рейс (летят разные люди) + несколько рейсов на один билет (один человек с пересадками),
--в итоге получается множество рейсов по множеству билетов на одно бронирование.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 
group by b.book_ref , b.total_amount , t.ticket_no , tf.flight_id, bp.boarding_no 
order by b.book_ref

select count(b.book_ref) --В одной брони несколько рейсов
--Считает, сколько таких случаев, когда по броням не были получены посадочные талоны, т.е. вылет не состоялся. Очень много записей - 465880
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 

select b.book_ref , bp.boarding_no --Укрупняем до подсчета количества броней, которыми не воспользовались. Не разделяем на рейсы и людей в брони.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 
group by b.book_ref, bp.boarding_no 
order by b.book_ref

select b.book_ref , bp.boarding_no, count (*) --Считаем, сколько внутри каждой брони несостоявшихся полетных человеко-мест.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 
group by b.book_ref, bp.boarding_no 
order by b.book_ref

select count (distinct b.book_ref) --Считаем только количество броней, которыми не воспользовались. Не разделяем на рейсы и людей в брони. Итого - 137570.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 

--5	Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.
--Добавьте столбец с накопительным итогом - суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма - сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.	
--- Оконная функция - Подзапросы

with cte_1 as 
(
select s.aircraft_code , count(s.seat_no) as seats_qty
from seats s 
group by s.aircraft_code 
)
select *, 
sum(q.filled_seats_qty) over (partition by q.departure_airport, q.actual_departure::date order by q.actual_departure) as departured_passengers_on_airportdate
from
(select f.flight_id , f.departure_airport , f.actual_departure , 
cte_1.aircraft_code , 
count(bp.seat_no) as filled_seats_qty, cte_1.seats_qty, (cte_1.seats_qty-count(bp.seat_no)) as free_seats_qty, 
round((cte_1.seats_qty-count(bp.seat_no))/(cast (cte_1.seats_qty as decimal))*100, 2) as free_seats_pct
from cte_1
join flights f on cte_1.aircraft_code = f.aircraft_code 
join boarding_passes bp on f.flight_id = bp.flight_id 
group by f.flight_id , cte_1.aircraft_code, cte_1.seats_qty) q


--6	Найдите процентное соотношение перелетов по типам самолетов от общего количества.	- Подзапрос - Оператор ROUND
--Принято, что перелет = рейс = flight_id
with cte_1 as 
(select count(f.flight_id) as flights_total_amount
from flights f
where f.actual_arrival is not null
), --Подзапрос считает общее количество всех рейсов, которые свершились, т.е. долетели до аэропорта назначения
cte_2 as
(select f2.aircraft_code, row_number() over (partition by f2.aircraft_code), 
count(f2.flight_id) over (partition by f2.aircraft_code) as flights_amount_by_aircraft_code
from flights f2
where f2.actual_arrival is not null
) --Подзапрос считает в оконной функции количество всех рейсов по типу самолета, которые свершились, т.е. долетели до аэропорта назначения. 
--Нумерация рядов в оконной функции введена для того, чтобы в финальном выборе показать только по одной строке для каждого типа самолета
select cte_2.aircraft_code, cte_2.flights_amount_by_aircraft_code, round((cte_2.flights_amount_by_aircraft_code)/cast (cte_1.flights_total_amount as decimal)*100, 2) as flights_pct_by_aircraft_code
from cte_1, cte_2 --Выбор типа самолета, количества свершившихся рейсов и расчет процента свершившихся вылетов по типу самолета от общего числа вылетов
where cte_2.row_number = 1

--7	Были ли города, в которые можно  добраться бизнес - классом дешевле, чем эконом-классом в рамках перелета?	- CTE

with cte_1 as 
(
select f.arrival_airport , f.departure_airport , tf.fare_conditions , min(tf.amount) as min_price, max(tf.amount) as max_price
from flights f 
join ticket_flights tf using (flight_id)
group by f.arrival_airport , f.departure_airport , tf.fare_conditions
--order by f.arrival_airport , f.departure_airport
)
select a.arrival_airport , a.departure_airport, a.fare_conditions, b.fare_conditions, a.min_price, b.max_price
from cte_1 a
join cte_1 b on a.arrival_airport = b.arrival_airport and a.departure_airport = b.departure_airport
where a.fare_conditions = 'Business' and b.fare_conditions = 'Economy'
and a.min_price < b.max_price


--8	Между какими городами нет прямых рейсов?	- Декартово произведение в предложении FROM
--- Самостоятельно созданные представления
--- Оператор EXCEPT

create or replace view full_pathes as
	select a.airport_code as airport_1, a2.airport_code as airport_2
	from airports a 
	cross join airports a2 
	where a.airport_code < a2.airport_code -- Для исключения задвоения пар аэропоров типа ААА - ВВВ , ВВВ - ААА в выборке обращалась за помощью.

select count(*) from full_pathes

select * from full_pathes

select f.departure_airport , f.arrival_airport, full_pathes.airport_1, full_pathes.airport_2 --Проверочный запрос: что сработало нулевое объединение с полным перебором
from flights f 
right join full_pathes on f.arrival_airport = full_pathes.airport_1 and f.departure_airport = full_pathes.airport_2

select full_pathes.airport_1, full_pathes.airport_2 --Показаны все пары аэропортов, между которыми нет прямых рейсов
from full_pathes
except
select f.departure_airport , f.arrival_airport
from flights f


--9	Вычислите расстояние между аэропортами, связанными прямыми рейсами, сравните с допустимой максимальной дальностью перелетов  в самолетах, обслуживающих эти рейсы *	
-- Оператор RADIANS или использование sind/cosd
with cte as 
(
select distinct f.departure_airport , f.arrival_airport
from flights f 
where f.departure_airport < f.arrival_airport
)
select *,
acos (sind(lat_a)*sind(lat_d) + cosd(lat_a)*cosd(lat_d)*cosd(long_a - long_d)) * 6371.0 as distance
from (
select cte.departure_airport, a.latitude as lat_d , a.longitude as long_d, cte.arrival_airport, a2.latitude as lat_a , a2.longitude as long_a
from cte
join airports a on cte.departure_airport = a.airport_code
join airports a2 on cte.arrival_airport = a2.airport_code) q










