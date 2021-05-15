--¬ывести всех неактивных покупателей
select first_name , last_name from customer
where active != 0

--Ќепон€тно, зачем колонка activebool, если она вс€ содержит true. “.е. эта колонка не отвечает за условие активности пользовтел€.
select first_name , last_name, activebool, active from customer
where activebool = 'true'

--¬ывести все фильмы, выпущенные в 2006 году
select * from film
where release_year = '2006'

--¬ывести 10 последних платежей за прокат фильмов (добавила сортировку не только последних по платежу, но и по пор€дку убывани€ стоимости оплаты, т.к. много платежей с одной и той же датой и временем)
select * from payment
where amount > 0
order by payment_date desc, amount desc
limit 10

--–абота с информационной таблицей
SELECT * FROM postgres.INFORMATION_SCHEMA.tables
where table_schema = 'public'

select * from information_schema.information_schema_catalog_name

--“аблица только первичных ключей схемы паблик
select * from information_schema.table_constraints 
where constraint_schema  = 'public'
and constraint_type = 'PRIMARY KEY' 

--ѕоказать св€зь между ограничени€ми и названи€ми колонок таблиц схемы паблик, в которых наход€тс€ эти ограничени€. Ќо здесь не видно, какие ключи €вл€ютс€ первичными.
select * from information_schema.constraint_column_usage

--ѕоказать в каких колонках таблиц какие первичные ключи
select * from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
where tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY' 

--ѕоказать колонки таблиц с первичными ключами (меньше колонок)
select ccu.table_name, ccu.column_name, ccu.constraint_name, tc.constraint_type from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
where tc.constraint_catalog = 'postgres' and tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY'

select * from information_schema."columns"
where table_schema = 'public'

--ѕоказать колонки таблиц с первичными ключами и какой тип данных имеют эти колонки
select ccu.table_name, ccu.column_name, ccu.constraint_name, tc.constraint_type, col.data_type
from information_schema.table_constraints tc
join information_schema.constraint_column_usage ccu
on tc.constraint_catalog = ccu.constraint_catalog and tc.constraint_schema = ccu.constraint_schema and tc.constraint_name = ccu.constraint_name 
join information_schema."columns" col 
on tc.table_catalog = col.table_catalog and tc.table_schema = col.table_schema and tc.table_name = col.table_name 
and ccu.column_name = col.column_name 
where tc.constraint_catalog = 'postgres' and tc.constraint_schema  = 'public'
and tc.constraint_type = 'PRIMARY KEY'

