create schema population

create table languages (
lang_id serial primary key,
lang_name varchar (50) unique not null
)

create table nations (
nation_id serial primary key,
nation_name varchar (50) unique not null
)

create table countries (
country_id serial primary key,
country_name varchar (50) unique not null
)

insert into population.languages (lang_name)
values ('РќРµРјРµС†РєРёР№'), ('РђРЅРіР»РёР№СЃРєРёР№'), ('Р СѓСЃСЃРєРёР№'), ('Р¤СЂР°РЅС†СѓР·СЃРєРёР№'),('Р�СЃРїР°РЅСЃРєРёР№')

insert into population.nations (nation_name)
values ('РќРµРјС†С‹'), ('Р‘Р°РІР°СЂС†С‹'), ('РђРІСЃС‚СЂРёР№С†С‹'), ('Р СѓСЃСЃРєРёРµ'), ('Р‘РµР»РѕСЂСѓСЃС‹'),('Р¤СЂР°РЅС†СѓР·С‹'),('Р¤СЂР°РЅРєРѕ-С€РІРµР№С†Р°СЂС†С‹'),('Р�СЃРїР°РЅС†С‹'),('РљР°С‚Р°Р»РѕРЅС†С‹'),('РљСѓР±РёРЅС†С‹')

insert into population.countries (country_name)
values ('Р“РµСЂРјР°РЅРёСЏ'), ('РђРІСЃС‚СЂРёСЏ'), ('Р РѕСЃСЃРёСЏ'), ('Р‘РµР»Р°СЂСѓСЃСЊ'),('Р¤СЂР°РЅС†РёСЏ'),('РЁРІРµР№С†Р°СЂРёСЏ'),('Р�СЃРїР°РЅРёСЏ'),('РљСѓР±Р°')

select * from countries

create table languages_nations (
lang_id integer,
nation_id integer,
foreign key (lang_id) references languages (lang_id),
foreign key (nation_id) references nations (nation_id)
)

create table nations_countries (
nation_id integer,
country_id integer,
foreign key (nation_id) references nations (nation_id),
foreign key (country_id) references countries (country_id)
)

alter table nations_countries drop constraint nations_countries_nation_id_fkey

alter table nations_countries add foreign key (nation_id) references nations (nation_id)

alter table nations_countries add primary key (nation_id, country_id)

alter table languages_nations add primary key (lang_id, nation_id)

alter table languages add last_update timestamp default now() --Р”РѕР±Р°РІР»РµРЅРѕ РїРѕР»Рµ РґР°С‚С‹ РІРЅРµСЃРµРЅРёСЏ РёР·РјРµРЅРµРЅРёР№

alter table languages add sample_text text --Р”РѕР±Р°РІР»РµРЅРѕ РїРѕР»Рµ - РїСЂРёРјРµСЂ С‚РµРєСЃС‚Р° РЅР° СЏР·С‹РєРµ

alter table countries add neighbor_with_russia boolean --Р”РѕР±Р°РІР»РµРЅРѕ РїРѕР»Рµ - РїСЂРёР·РЅР°Рє РЅР°Р»РёС‡РёСЏ РіСЂР°РЅРёС†С‹ СЃ Р РѕСЃСЃРёРµР№

insert into languages_nations (lang_id, nation_id)
values 
(1,1),
(1,2),
(1,3),
(3,4),
(3,5),
(4,6),
(4,7),
(5,8),
(5,9),
(5,10)

insert into nations_countries (nation_id, country_id)
values 
(1,1),
(2,1),
(3,2),
(4,3),
(5,4),
(6,5),
(7,6),
(8,7),
(9,7),
(10,8),
(1,6),
(4,4),
(5,3),
(6,6)

update countries 
set neighbor_with_russia = true
where country_id in (4)

update countries 
set neighbor_with_russia = false 
where country_id not in (4) and country_id != 3

update languages 
set sample_text = 'Guten Morgen'
where lang_id = 1

update languages 
set sample_text = 'Good Morning'
where lang_id = 2

update languages 
set sample_text = 'Р”РѕР±СЂРѕРµ СѓС‚СЂРѕ'
where lang_id = 3

update languages 
set sample_text = 'Bonjour'
where lang_id = 4

update languages 
set sample_text = 'Buenos dГ­as'
where lang_id = 5

select * from countries c 





