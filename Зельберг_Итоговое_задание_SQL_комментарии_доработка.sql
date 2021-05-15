SELECT * FROM avia.INFORMATION_SCHEMA.tables -- ��� �������� ��
where table_schema = 'bookings'

--1	� ����� ������� ������ ������ ���������? ����� ��������� ��������.
select a2.city, a2.airport_code, a2.airport_name 
from
	(select a.city 
	from airports a
	group by a.city 
	having count (a.city) > 1) as q
join airports a2 using (city)
--������ 10 �� 10
--� ���������� ������ ���� ����� �� ������, �� ���� ���������� ������ �������.
--��������� � ���� �������, � ������ ������ ��������.

--2	� ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?	- ���������
select a2.airport_code, a2.airport_name, a2.city, q.model
from
	(select a.aircraft_code, a.model , a."range" 
	from aircrafts a
	order by a."range" desc 
	limit 1) as q
join flights f on f.aircraft_code = q.aircraft_code
join airports a2 on f.arrival_airport = a2.airport_code or f.departure_airport = a2.airport_code 
group by a2.airport_code, a2.airport_name, a2.city, q.model
--������ 15 �� 15
--������������� ������������� ����������� ����� �������� � ���������.
--����� �� �� ����������� ��� ����, ��� �� �������� ������ ���������� ��������, � �� �������� �����-�� ���������, �������������� ������ ��� ����� ������������ �������� distinct.
--���� ��� ���:
select distinct a2.airport_code, a2.airport_name, a2.city, q.model
from
	(select a.aircraft_code, a.model , a."range" 
	from aircrafts a
	order by a."range" desc 
	limit 1) as q
join flights f on f.aircraft_code = q.aircraft_code
join airports a2 on f.arrival_airport = a2.airport_code or f.departure_airport = a2.airport_code

--3	������� 10 ������ � ������������ �������� �������� ������	- �������� LIMIT
select f.flight_no, f.departure_airport , f.arrival_airport , f.status , (f.actual_departure - f.scheduled_departure) as actual_departure_time_delay
from flights f 
where f.actual_departure is not null 
order by (f.actual_departure - f.scheduled_departure) desc 
limit 10
--������ 15 �� 15

--4	���� �� �����, �� ������� �� ���� �������� ���������� ������?	- ������ ��� JOIN
select b.book_ref , b.total_amount , t.ticket_no , tf.flight_id, bp.boarding_no --� ����� ����� ��������� ������, ��������� ������� �� ����. 
--������� ������ ���������� ���������� ���� �� �����, ������� ����� �� ���� ������ ������ � ������ �� ��������� ������, �� �� ������� ����� �� ������� (�������� �������).
--����� ������� ����� �����, �.�. � ����� ����� ����� ���� ��������� ������� �� ���� ���� (����� ������ ����) + ��������� ������ �� ���� ����� (���� ������� � �����������),
--� ����� ���������� ��������� ������ �� ��������� ������� �� ���� ������������.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 
group by b.book_ref , b.total_amount , t.ticket_no , tf.flight_id, bp.boarding_no 
order by b.book_ref

select count(b.book_ref) --� ����� ����� ��������� ������
--�������, ������� ����� �������, ����� �� ������ �� ���� �������� ���������� ������, �.�. ����� �� ���������. ����� ����� ������� - 465880
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no is null 

select b.book_ref , bp.boarding_no --��������� �� �������� ���������� ������, �������� �� ���������������. �� ��������� �� ����� � ����� � �����.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull
group by b.book_ref, bp.boarding_no 
order by b.book_ref

select b.book_ref , bp.boarding_no, count (*) --�������, ������� ������ ������ ����� �������������� �������� ��������-����.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no isnull 
group by b.book_ref, bp.boarding_no 
order by b.book_ref

select count (distinct b.book_ref) --������� ������ ���������� ������, �������� �� ���������������. �� ��������� �� ����� � ����� � �����. ����� - 137570.
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id, ticket_no)
where bp.boarding_no is null 
--������ 5 �� 15
--����� 10 ������.
--������ ��� ����� � ���������� ������, �������� � ��������� ������� ���������� ������.
--������������ ������� ticket_flights � ������ ������� �� �����.
--����������� ����� �� ����� ��������, ��� ��� ���������� ���������� �������� (�� ����� ��������, ������� �� �������� ������������).
--� ��������� �������� ����������� ������, �� ticket_flights ������.

select count (distinct b.book_ref) --������� ������ ���������� ������, �������� �� ���������������. �� ��������� �� ����� � ����� � �����. ����� - 137570.
from bookings b 
join tickets t using (book_ref)
-- join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (ticket_no)
where bp.boarding_no is null 

select b.*, t.*, tf.*, bp.*
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (ticket_no, flight_id)
-- where bp.boarding_no is null
where b.book_ref = '0004B0'
order by b.book_ref

select * 
from
(
select -- b.*, tf.*, bp.*,
	b.book_ref, t.ticket_no,  
	sum(case when bp.boarding_no is null then 0 else 1 end) over (partition by b.book_ref) as b_cnt,
	count(t.ticket_no) over (partition by b.book_ref) t_cnt 
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (ticket_no, flight_id)
) as a 
where t_cnt > b_cnt and b_cnt > 0
-- where bp.boarding_no is null
order by book_ref


select * 
from bookings b 
join tickets t using (book_ref)
left outer join ticket_flights tf using (ticket_no)
where tf.ticket_no is null

select distinct b.book_ref
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id, ticket_no)
where bp.boarding_no is null 
except 
select distinct b.book_ref
from bookings b 
join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp using (flight_id)
where bp.boarding_no is null 

CE0FDC
B8BB72
7367D7
257C8F
715E32
6EAF34
392B2A

select * 
from bookings b join tickets t using (book_ref)
join ticket_flights tf using (ticket_no)
left outer join boarding_passes bp -	- using (flight_id)	
	on bp.flight_id = tf.flight_id and bp.ticket_no = tf.ticket_no 
where b.book_ref = 'CE0FDC'
order by boarding_no


select aircraft_code, count(seat_no) from seats s group by aircraft_code 











--5	������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.
--�������� ������� � ������������� ������ - ��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� - ������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.	
--- ������� ������� - ����������

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
--������ 25 �� 25


--6	������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������.	- ��������� - �������� ROUND
--�������, ��� ������� = ���� = flight_id
with cte_1 as 
(select count(f.flight_id) as flights_total_amount
from flights f
where f.actual_arrival is not null
), --��������� ������� ����� ���������� ���� ������, ������� ����������, �.�. �������� �� ��������� ����������
cte_2 as
(select f2.aircraft_code, row_number() over (partition by f2.aircraft_code), 
count(f2.flight_id) over (partition by f2.aircraft_code) as flights_amount_by_aircraft_code
from flights f2
where f2.actual_arrival is not null
) --��������� ������� � ������� ������� ���������� ���� ������ �� ���� ��������, ������� ����������, �.�. �������� �� ��������� ����������. 
--��������� ����� � ������� ������� ������� ��� ����, ����� � ��������� ������ �������� ������ �� ����� ������ ��� ������� ���� ��������
select cte_2.aircraft_code, cte_2.flights_amount_by_aircraft_code, round((cte_2.flights_amount_by_aircraft_code)/cast (cte_1.flights_total_amount as decimal)*100, 2) as flights_pct_by_aircraft_code
from cte_1, cte_2 --����� ���� ��������, ���������� ������������ ������ � ������ �������� ������������ ������� �� ���� �������� �� ������ ����� �������
where cte_2.row_number = 1
--������ 15 �� 25
--����� 10 ������.
--�������� ����� ������, ������ �� �������� ��������, ������� � ��������?
--����� ������ ��������. ��� ���� ����������� ������� ������� � cte_2? ��� ����� ������� ��������� count � �����������, ������ ��������, ��� ������� �������� ������ :)


--7	���� �� ������, � ������� �����  ��������� ������ - ������� �������, ��� ������-������� � ������ ��������?	- CTE

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
--������ 20 �� 25
--����� 5 ������.
--��� ������ �� ������, � ������ ������ �� �������.



--8	����� ������ �������� ��� ������ ������?	- ��������� ������������ � ����������� FROM
--- �������������� ��������� �������������
--- �������� EXCEPT

create or replace view full_pathes as
	select a.airport_code as airport_1, a2.airport_code as airport_2
	from airports a 
	cross join airports a2 
	where a.airport_code < a2.airport_code -- ��� ���������� ��������� ��� ��������� ���� ��� - ��� , ��� - ��� � ������� ���������� �� �������.

select count(*) from full_pathes

select * from full_pathes

select f.departure_airport , f.arrival_airport, full_pathes.airport_1, full_pathes.airport_2 --����������� ������: ��� ��������� ������� ����������� � ������ ���������
from flights f 
right join full_pathes on f.arrival_airport = full_pathes.airport_1 and f.departure_airport = full_pathes.airport_2

select full_pathes.airport_1, full_pathes.airport_2 --�������� ��� ���� ����������, ����� �������� ��� ������ ������
from full_pathes
except
select f.departure_airport , f.arrival_airport
from flights f
--������ 15 �� 35
--����� 20 ������.
--����������� ������, �� ������ ��� ������, � �� ���������.
--�������������� ������� ������ � ���������� ������ ������ � ����������� � except, ��� �� �������� ������.


--9	��������� ���������� ����� �����������, ���������� ������� �������, �������� � ���������� ������������ ���������� ���������  � ���������, ������������� ��� ����� *	
-- �������� RADIANS ��� ������������� sind/cosd
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
--������ 35 �� 35









