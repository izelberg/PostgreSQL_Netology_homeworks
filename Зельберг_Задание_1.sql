--������� ���� ���������� �����������
select first_name , last_name from customer
where active != 0

--���������, ����� ������� activebool, ���� ��� ��� �������� true. �.�. ��� ������� �� �������� �� ������� ���������� �����������.
select first_name , last_name, activebool, active from customer
where activebool = 'true'

--������� ��� ������, ���������� � 2006 ����
select * from film
where release_year = '2006'

--������� 10 ��������� �������� �� ������ ������� (�������� ���������� �� ������ ��������� �� �������, �� � �� ������� �������� ��������� ������, �.�. ����� �������� � ����� � ��� �� ����� � ��������)
select * from payment
where amount > 0
order by payment_date desc, amount desc
limit 10

--������ � �������������� ��������
SELECT * FROM postgres.INFORMATION_SCHEMA.tables
where table_schema = 'public'

select * from information_schema.information_schema_catalog_name

--������� ������ ��������� ������ ����� ������
select * from information_schema.table_constraints 
where constraint_schema  = 'public'
and constraint_type = 'PRIMARY KEY' 

--�������� ����� ����� ������������� � ���������� ������� ������ ����� ������, � ������� ��������� ��� �����������. �� ����� �� �����, ����� ����� �������� ����������.
select * from information_schema.constraint_column_usage

--�������� � ����� �������� ������ ����� ��������� �����
select * from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
where tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY' 

--�������� ������� ������ � ���������� ������� (������ �������)
select ccu.table_name, ccu.column_name, ccu.constraint_name, tc.constraint_type from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
where tc.constraint_catalog = 'postgres' and tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY'

select * from information_schema."columns"
where table_schema = 'public'

--�������� ������� ������ � ���������� ������� � ����� ��� ������ ����� ��� �������
select ccu.table_name, ccu.column_name, ccu.constraint_name, tc.constraint_type, col.data_type
from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
join information_schema."columns" col 
on tc.table_catalog = col.table_catalog and tc.table_schema = col.table_schema and tc.table_name = col.table_name 
and ccu.column_name = col.column_name 
where tc.constraint_catalog = 'postgres' and tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY'

