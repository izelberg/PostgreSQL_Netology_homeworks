--�������� ��������, ������� ������ 300-�� �����������
select s.store_id, a.address, a.district, c2.city, c3.country 
from store s
join customer c on c.store_id = s.store_id 
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id  
group by s.store_id, a.address, a.district, c2.city, c3.country
having count (c.customer_id) > 300
--���������� �������� ����� ���������, �.�. ������ ����� �������� ������ �� �������, �������� ������� ����� � ������

--�������� � ������� ���������� �����, � ������� �� �����
select concat (c.last_name, ' ', c.first_name) as full_name, c2.city , c3.country 
from customer c
join address a on c.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id 
order by c3.country, c2.city 
--��������� ������, � ������� �����, � ���������� �����, ������� �� ��������

--�������� ��� ����������� � ������ ���������, ������� ������ 300-�� �����������
select concat (s2.last_name, ' ', s2.first_name) as full_name, a.address, a.district, c2.city, c3.country 
from staff s2
join store s on s2.store_id = s.store_id 
join customer c on c.store_id = s.store_id 
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 
join country c3 on c3.country_id = c2.country_id  
group by s.store_id, s2.last_name, s2.first_name, a.address, a.district, c2.city, c3.country
having count (c.customer_id) > 300

--�������� ��� ����������� � ������ ���������, ������� ������ 300-�� ����������� - ����� ���������
select concat (s.last_name, ' ', s.first_name) as full_name, c2.city 
from
	(select c.store_id 
	from customer c 
	group by c.store_id 
	having count (c.customer_id) > 300) as t
join staff s on s.store_id = t.store_id
join address a on s.address_id = a.address_id 
join city c2 on c2.city_id = a.city_id 

--�������� ���������� �������, ����������� � �������, ������� ������� � ������ �� 2,99
select count (distinct fa.actor_id)--, fa.film_id 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
--order by fa.film_id 

--�������� ��� �������, ����������� � �������, ������� ������� � ������ �� 2,99
select distinct concat (a.last_name, ' ', a.first_name) as full_name, q.rental_rate 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
join actor a on a.actor_id = fa.actor_id 
order by concat (a.last_name, ' ', a.first_name)
--���� ������ ������ ��� ����, ����� ���������, ����� ������ ������ ���������� ��� ������� � �������� ������ 2,99. 
--������-�� � ���� ������ 199 �����. � �� �������� � ������� ���� - 200 ������� �������� � ����� �������. ������� - ��������� ������

--�������� ��� �������, ����������� � �������, ������� ������� � ������ �� 2,99
select distinct fa.actor_id, concat (a.last_name, ' ', a.first_name) as full_name, q.rental_rate 
from
	(select f.film_id , f.rental_rate 
	from film f 
	where f.rental_rate = 2.99) as q
join film_actor fa on fa.film_id = q.film_id
join actor a on a.actor_id = fa.actor_id 
order by concat (a.last_name, ' ', a.first_name)
--���������, ��� ��� ������ ����� ���������� ��� Davis Susan � ������ id. �.�. ��������, ��� ��� ������ ����. 
--�.�. ���������� ������ ��������, ���� ������ ������.
--������: ��� �������, ����� � ���������� �� ��������� actor_id (������ ��� � �������� �����? 
--���� ���� dictinct �� ����� � select, � � ������ ����� �������, �� ������ ������, ��� distinct ��������� �� � ��� �����
