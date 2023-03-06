create database products;
use products;

-- brand table
create table brand(
brand_id int primary key identity(1,1),
brand_name varchar(50) not null
);

-- enter some data in table
insert into brand(brand_name)
values('Electra'),
('Haro'),
('Heller'),
('Pure Cycle'),
('Ritchery'),
('Strider');


-- create brand approval table
create table brand_approval(
brand_id int primary key identity(1,1),
brand_name varchar(50) not null
);

-- create view 
alter view vw_brands
as
select brand_name, 'approval' as approval_status
	from brand
union 
select brand_name, 'approval pending' as approval_status-
	from brand_approval

-- trigger for brand approval
create trigger trg_vw_brand
on vw_brands
instead of insert
as
begin
	set nocount on;
	insert into brand_approval(brand_name)
	select i.brand_name
		from inserted i
		where i.brand_name not in(select brand_name from brand)
end;

insert into vw_brands(brand_name)
values('KTM')

select * from vw_brands;
select * from brand;
select * from brand_approval;