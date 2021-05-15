--�������� ������� � 3-�� ������: �������� ������, ��� ������ � ���������� �������, � ������� �� ��������
select f.title, concat(a.last_name, ' ', a.first_name), --����� ������ ������ ����: �������� ������ � �� ������� ������ �������� �������, ������� � ��� ���������
row_number() over (partition by f.film_id)
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id
 
select f.title, concat(a.last_name, ' ', a.first_name),
count(f.film_id) over (partition by a.actor_id) --������ ��������� ���-�� ������� � ���� ������� ������.
from film f
join film_actor fa on fa.film_id = f.film_id
join actor a on a.actor_id = fa.actor_id
order by f.film_id --��� ��� ����������, �������� �� ������, ����� �������� ���� ������� � ����� ������. ��� ��� ��������� �� ������.

select * from film f 

--CTE - ��������� ��������� ��������� Common Table Expression

--��� ������ CTE �������� ������� �� ��������� �����������: ������� � ��� ���������� (staff) � ���������� �������� ��� (retal), ������� �� ������

--explain analyze
with cte_1 as (
	select r.staff_id, count (r.rental_id) as rental_qty
	from rental r 
	group by r.staff_id
)
select concat(s2.last_name, ' ', s2.first_name) as full_name, cte_1.rental_qty
from cte_1
join staff s2 on s2.staff_id = cte_1.staff_id

--�������� view � ��������� ������ (���; email) � title ������, ������� �� ���� � ������ ���������

create view last_order as
with cte_2 as (
	select *, row_number () over (partition by customer_id order by rental_date desc)
	from rental)
select concat(c.last_name, ' ', c.first_name) as full_name, c.email, f.title as film_title
	from cte_2
	join inventory i using (inventory_id)
	join film f using (film_id)
	join customer c using (customer_id)
	where row_number = 1 --���� �� ���������� ��������� ��� �������. �.�. ������� ������ ���� ����������� �� �������� ���� ������ ������ � ������, � ����� ���������� ������ ��
	--������, ��� ����� ���� = 1, �.�. ����� ���������.
	
select * from last_order

�������� �������:
�������� ������ � ������� rental. ��������� ������ ������� �������� ������� � ���������� ������� ������ ��� ������� ������������ (����������� �� rental_date)
��� ������� ������������ ����������� ������� �� ���� � ������ ������� �� ����������� ��������� Behind the Scenes
-�������� ���� ������
-�������� ����������������� ������������� � ���� ��������
-�������� ����������������� �������������
-�������� ��� �������� ������� ��� ������ Behind the Scenes

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

--������ ������� ������ Behind_the_Scenes. ������ �� ��������. 39 ��, cost 3848
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

--������ ������� ������ Behind_the_Scenes. ����� �������. 18,1 ��, cost 1156
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

--������ ������� ������ Behind_the_Scenes. ���� ���� ��������� ������ ������. ����� ���������. 50,8 ��, cost 6397
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

--������� ������� "�� ��������". ��������� ���� ��������. 68,8 ��, cost 1089. ������ � ���� ����� �� ���������� ����� �������, � ��������� ����� ���������?
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



