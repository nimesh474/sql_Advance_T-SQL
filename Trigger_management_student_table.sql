use management;


create table audit_student_record(
id int primary key identity(1,1),
first_name varchar(50),
last_name varchar(50),
address varchar(50) not null,
contact varchar(15) not null,
dob date not null,
updated_at date default getdate(),
operation char(3) not null,
constraint check_con check(operation='ins' or operation='del')
);

 -- trigger for student table in management
 create trigger trg_student_record
 on student
 after insert, delete
 as
 begin
	set nocount on

	insert into audit_student_record(first_name, last_name, address, contact, dob, updated_at, operation)
	select i.first_name, i.last_name, i.address, i.contact, i.dob, getdate(), 'ins'
		from inserted i

	union all

	select d.first_name, d.last_name, d.address, d.contact, d.DOB, getdate(), 'del'
		from deleted d

 end

 select * from audit_student_record;
select * from student;
insert into student(first_name, last_name, address, contact, DOB)
values('Samsung', 'Korea', 'Korea Capital', '9506932139', '1975-04-23'),
('Noise', 'Caliber', 'India', '5069485934', '02-27-1990');

delete from student
	where id=9;
