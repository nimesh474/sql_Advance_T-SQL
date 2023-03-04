-- create database
create database management;
use management;

/* create a table named student having columns as first_name, last_name, address, 
contact, DOB */
create table student(
id int primary key identity(1,1),
first_name varchar(50) not null,
last_name varchar(50) not null,
address varchar(100),
contact varchar(50),
DOB date not null
);

insert into student(first_name, last_name, address, contact, DOB)
values('Nimesh', 'Bhattarai', 'Suncity', '9405968819','2056-01-10'),
('Saroj', 'Khatri', 'Chabahil', '9583048194','2056-02-11'),
('Pushpa', 'Dahal', 'Bhaktapur', '9485069912','2054-10-12'),
('Ramesh', 'Shapkota', 'Parsa', '958601295','2055-09-30'),
('Rupa', 'Prashad', 'Nawalpur', '9506839582','2056-03-10'),
('Bidhya', 'Bhandari', 'Okhaldhunga', '9506978375','2056-07-07'),
('Pradeep', 'Khadka', 'Chitawan', '9506948596','2055-12-01');


/* create a table named tutionfee to store the details of fee paid by student.
The table should contain the columns studentID(FK referencing the PK of student table),
amount, description and dateofpayment. you should be able to store those amounts that 
are greater than zero(use check). The default value to dateofpayment should be today's date.
*/
create table tutionFee(
bill int primary key identity(1,1),
studentID int ,
amount decimal(10,2) constraint amount_check check(amount>0),
description varchar(50) not null,
dateofpayment date default getDate(),
constraint id_FK foreign key(studentID) references student(id)
);

-- insert at least 5 records to show the fee paid by students.
insert into tutionFee(studentID, amount, description, dateofpayment)
values(1, 10000, 'paid', '2022-01-12'),
(2, 5000, 'paid', '2022-01-10'),
(5, 7000, 'paid', '2022-01-13'),
(3, 9000, 'paid', '2022-04-01'),
(7, 3000, 'paid', '2022-03-11');

/* create a table named project to store the details of project. The table should contain studentID(FK referencing the PK of student table), project, department, supervisior, startdate, enddate.*/
create table project(
project_id int primary key identity(1,1),
studentID int,
project varchar(50) not null,
department varchar(50), 
supervisior varchar(50),
startdate date not null,
enddate date default getDate(),
constraint project_FK foreign key(studentID) references student(id)
);

-- insert at least 5 records to show projects of each students.
insert into project(studentID, project, department, supervisior, startdate, enddate)
values(1, 'AI Application', 'Faulty Member', 'Internal', '2020-06-10', '2022-04-10'),
(2, 'Excel Pivot Data Structure', 'Lecturer', 'External','2020-05-11', '2022-03-13'),
(5, 'DL Application', 'DL Lecturer', 'Internal', '2020-07-22', '2022-05-01'),
(6, 'Arduino Application', 'Faculty Member','Internal', '2020-09-30', '2022-09-01'),
(5, 'Political Concern', 'Faculty Member', 'External', '2020-10-13', '2022-07-29');

insert into project(studentID, project, department, supervisior, startdate, enddate)
values(3, 'AI Application', 'Faulty Member', 'Internal', '2020-06-10', '2022-04-10');

use management;
-- 1. Show the list of the students that have paid the fee.

alter view fee_paid_student
as
	select concat(s.first_name, ' ' ,s.last_name)Name, t.description from tutionFee t
	inner join student s
	on s.id = t.studentID;
	

select * from fee_paid_student;

-- 2. Show the list of the students that are involved in a project.
alter proc project_student
as
begin
	select concat(s.first_name, ' ', s.last_name)Name, p.project from student s
	inner join project p
	on s.id = p.studentID
	order by project
end;
execute project_student;
drop procedure project_student;

-- 3. Show the list of the students and total amount they have paid. The student with highest 
--	paying fee should show on the top and lowest on the bottom.
select concat(s.first_name, ' ', s.last_name)Name, t.amount from student s
inner join tutionFee t 
on s.id = t.studentID
order by t.amount desc;

-- 4. show the list of students and total amount they have paid only if the total fee is greater
--	than 4000.
alter proc feePaid(@amount int)
as
begin
	select s.id, concat(s.first_name, ' ', s.last_name)Name, sum(t.amount)totalFee from student s
inner join tutionFee t 
on s.id = t.studentID
group by s.id, s.first_name, s.last_name
having sum(t.amount) > @amount
order by totalFee desc
end;

execute feePaid @amount=4000

-- 5. Show the list of students and number of projects they are involved in.
create procedure namelike(@name varchar(50))
as
 begin
	select concat(s.first_name, ' ', s.last_name)Name, count(p.studentID)StudentProjectCount
	from student s
	inner join project p
	on s.id=p.studentID
	where first_name like @name+'%'
	group by s.id, s.first_name, s.last_name
	order by StudentProjectCount desc
 end;

 execute namelike @name='s'

 alter procedure multiproc(@amount int, @fname varchar(50), @lname varchar(50))
 as
 begin
	select concat(first_name,' ',last_name)Name, sum(amount)totlaAmount
 from student s
 inner join tutionFee t
 on s.id=t.studentID
 where first_name like '%'+@fname+'%' and last_name like '%'+@lname+'%'
 group by first_name, last_name
 having sum(amount)>@amount
 order by totlaAmount
 end;
 
 execute multiproc @amount=1000, @fname='r', @lname='a'


-- 6. Show the number of students involved in each project.
select count(studentID)StudentInProject from project

-- 7. Show the number of students involved in each project only if 
	--multiple student(number of studnts > 1) are involved.
select project, count(studentID)StudentInProject from project
group by project
having count(studentID) >= 1
order by StudentInProject desc;

-- 8. Show the list of students that have paid fee and are involved in a project.
select distinct concat(s.first_name, ' ', s.last_name)Name, t.description, p.project 
	from student s
	inner join tutionFee t
	on s.id=t.studentID
	inner join project p
	on s.id = p.studentID
	order by name;

-- 9. Show the list of students and total amount they have paid. 
--	Show 0 if they have not paid
select concat(s.first_name, ' ', s.last_name)Name, isnull(sum(t.amount),0)TotalAmount
	from student s
	left join tutionFee t
	on s.id=t.studentID
	group by s.id, s.first_name, s.last_name
	order by TotalAmount desc;

-- 10. Show the list of students that have not paid fee.
select concat(s.first_name, ' ', s.last_name)Name, isnull(t.amount, 0)Fee from student s
left join tutionFee t
on s.id = t.studentID
where t.amount is null
order by s.first_name;


-- 11. Show the list of students that are involved in a project. If not invloved show 
--	'Not Involved' in project name.
select concat(s.first_name, ' ', s.last_name)Name, isnull(p.project, 'Not Involved')ProjectName
	from student s
	left join project p
	on s.id = p.studentID


-- 12. Show the list of students that are not involved in project.
select concat(s.first_name, ' ', s.last_name)Name, isnull(p.project, 'Not Involved')Project 
from student s
left join project p
on s.id=p.studentID
where p.project is null;


-- 13. Show the list of students that have paid fee but are not involved in any project.
select concat(s.first_name, ' ', s.last_name)Name, t.amount,
	isnull(p.project, 'Not Involved')Projectname
	from student s
	inner join tutionFee t
	on s.id=t.studentID
	left join project p
	on t.studentID=p.studentID
	where p.project is null;


-- 14. Show the list of students that are involved in a project but not paid any fee.
select concat(s.first_name, ' ', s.last_name)Name, p.project, isnull(t.amount,0)Fee 
	from student s
	inner join project p
	on s.id=p.studentID
	left join tutionFee t
	on s.id=t.studentID
	where t.amount is null
	order by s.first_name;


-- 15. Show the list of students and amount they have paid. The student with highest paying
--	fee should show on the top and lowest on bottom.
select concat(s.first_name, ' ', s.last_name)Name, t.amount from student s
inner join tutionFee t
on s.id=t.studentID
order by t.amount desc;


-- 16. Show the list of students and amount they have paid only if the total fee is greater
--	than 4000.
select concat(s.first_name, ' ', s.last_name)Name, sum(t.amount)totalFee
	from student s
	inner join tutionFee t
	on s.id=t.studentID
	group by s.id, s.first_name,s.last_name
	having sum(t.amount) > 4000
	order by totalFee desc;


-- 17. Show number of students involved in the project.
select project, count(studentID)StudentNumber from project
group by project
order by StudentNumber desc;


-- 18. Show the number of students involved in the each project
--	only if the multiple students(number of studnts > 1) are involved.
select project , count(studentID)StudentNumber from project
group by project
having count(studentID) > 1
order by studentNumber desc; 


-- 19. Show the list of students that have paid fee and are involved in a project.
select concat(s.first_name, ' ', s.last_Name)Name, p.project, t.amount, t.description
	from student s
	inner join tutionFee t
	on s.id=t.studentID
	inner join project p
	on s.id=p.studentID;

/* NOTE.......... amount, student and project is involved......
	Even student paid 1 time but showing multiple times due to not having foreign 
	constraint with project tables ..........*/
begin
declare @total int
set @total=1000
if @total>1000
begin
	print 'greate total amount'
end
else
	begin
	print 'loss'
	end
end;

begin
declare @counter int
set @counter=1
while @counter<=5
begin

if @counter=4
begin
	continue
end
	print @counter
	set @counter+=1
end
end
select * from tutionFee;
select * from student;
select * from project;

alter procedure usp_divide(@num1 decimal(10,2), @num2 decimal(10,2))
as
begin
	declare @result decimal(10,2)
	begin try
		set @result = @num1/@num2
		print @result
	end try
	begin catch
		select error_line(),
			error_message(),
			error_number(),
			error_severity(),
			error_procedure()
	end catch
end;

execute usp_divide @num1=10, @num2=5;

