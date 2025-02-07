create database GsmLab3;

use GsmLab3;

insert into version_ values
(0, 1);
create table Brand
(
Name_Brand varchar(30) UNIQUE,
Profit float,
PRIMARY KEY(Name_Brand),
);
create table Logs
(
Lid int,
TriggerDate date,
TriggerType varchar(20),
NameAffectedTable varchar(20),
NOAMDRows int
);
create table Employees
(
Employee_ID int NOT NULL,
Salary int NOT NULL,
Namee varchar(20),
Surname varchar(20),
PRIMARY KEY (Employee_ID),
);
create table Phones
(
Price int NOT NULL,
CPU varchar(20) UNIQUE,
RAM varchar(20),
Name_Brand varchar(30) References Brand(Name_Brand)
);
create table Shifts
(
Time_open int NOT NULL,
Time_close int NOT NULL,
Time_date date Not NULL,
Employee_ID int REFERENCES Employees(Employee_ID),
)
create table Profit
(
Time_date date NOT NULL,
Nr_Phones_Sold int,
Salary int,
);
create table Computers
(
ID int,
Model varchar(20),
Price int,
Date_model Date,
Name_Brand varchar(30) References Brand(Name_Brand),
primary key(ID)
);
drop table Computers
create table Tablets
(
Name_Brand varchar(30) references Brand(Name_Brand),
Model varchar(20),
Price int
);


create function checkSalary(@n int)
returns int as
begin
	declare @num int
	if @n<1500 or @n>5000
		set @num=0;
	else 
		set @num=1;
	return @num
end
go

create function checkName(@v varchar(20))
returns bit as
begin 
	declare @b bit
	if @v LIKE '[A-Z]%'
		set @b=1
	else
		set @b=0
	return @b
end
go

--Creating function check brand 
create function checkBrand(@b varchar(30))
returns bit as
begin
	declare @brand bit
	if @b LIKE 'A%[A-Z]'
		set @brand=1
	else 
		set @brand=0
	return @brand
end
go

--CReate function check date
create function checkShift(@b varchar(30))
returns bit as
begin
	declare @shift bit
	if @b LIKE 'J%[A-Z]'
		set @shift=1
	else 
		set @shift=0
	return @shift
end
go
--Creating function check profit
create function checkProfit(@p FLOAT)
returns bit as
begin
	declare @profit bit
	if @p>10000.0 and @p<100000.0
		set @profit=1
	else
		set @profit=0
	return @profit
end
go

--Creating the procedure add employees
create procedure addEmployees_brand @id int, @salary int, @name varchar(20), @surname varchar(20), @brand varchar(30), @profit float
as
	begin
		if dbo.checkSalary(@salary)=1 and dbo.checkName(@name)=1
		begin
			INSERT INTO Employees(Employee_ID, Salary, Namee, Surname) Values (@id, @salary, @name, @surname)
			print 'Values added'
		end
		else
		begin
			print 'Wrong parameters'
		end
		if dbo.checkBrand(@brand)=1 and dbo.checkProfit(@profit)=1
		begin
			INSERT INTO Brand(Name_Brand, Profit) Values (@brand, @profit)
			print 'Values added'
		end
		else
		begin
			print 'Wrong parameters'
		end
	end
go

drop procedure addEmployees_brand

exec addEmployees_brand 45, 2000, 'Gigel', 'Frone', 'Arebo', 11000

Select * from Employees
Select * from Brand

delete from Employees
delete from Brand where Name_Brand='Arebo'
--creating the procedure add brand
create procedure addBrand @brand varchar(30), @profit float
as
	begin
		if dbo.checkBrand(@brand)=1 and dbo.checkProfit(@profit)=1
		begin
			INSERT INTO Brand(Name_Brand, Profit) Values (@brand, @profit)
			print 'Values added'
		end
		else
		begin
			print 'Wrong parameters'
		end
	end
go

--Creating the view
create view view_All
as
	Select b.Name_Brand, p.CPU, c.Model, t.Price
	from Computers c inner join Phones p on c.Name_Brand=p.Name_Brand
	inner join Tablets t on p.Name_Brand=t.Name_Brand
	inner join Brand b on b.Name_Brand=t.Name_Brand
go

Select * from view_All

--Creating a computer 2 so i can make a trigger that adds to it
create table Computers2(Model varchar(20), Price int, Date_model Date, Name_Brand varchar(30));

--Creating the trigger for computers
create trigger add_computer on Computers for
insert as
begin
insert into Computers2(Model, Price, Date_model, Name_Brand)
select Model, Price, Date_model, Name_Brand
from inserted
insert into Logs(TriggerDate, TriggerType, NameAffectedTable, NOAMDRows)
values (GETDATE(), 'INSERT', 'Computer', @@ROWCOUNT)
end
go

Select * from logs
truncate table logs
delete from computers
alter table computers drop column id 
--Just inserting some values for testing
insert into Computers(Model, Price, Date_model, Name_Brand) values ('Computer', 15000,'11/10/1999', 'Name Brand');
insert into Brand values('Name Brand', 150000);

--Deleting any already existing index
if exists (select name from sys.indexes where name=N'N_idx_Computers_Price')
	drop index N_idx_Computers_Price on Computers;
go

--Creating a noncluster index
create nonclustered index N_idx_Computers_Price on Computers(Price);


--Deleting any already existing index
if exists(select name from sys.indexes where name=N'N_idx_Computers_Name_Brand')
	drop index N_idx_Computers_Name_Brand on Computers;
go

--Creating a noncluster index
create nonclustered index N_idx_Computers_Name_Brand on Computers(Name_Brand);


--Inserting some stuff to test
insert into Brand (Name_Brand, Profit) values
('Intel', 200000),
('Invidia',150000),
('Sony',80000),
('PC Garage',20000);


insert into Computers (ID, Model, Price, Date_model, Name_Brand) values
(1, 'IDK', 3450, '2021/11/08', 'PC Garage'),
(2, 'V2', 1500., '2021/11/02', 'Intel'),
(3, 'V2', 2000, '2021/10/01', 'Intel'),
(4, 'V2 Pro', 2200, '2022/03/15', 'Invidia'),
(5, 'V1', 800, '2018/06/10', 'Sony'),
(6, 'V2', 900, '2019/06/10', 'Sony'),
(7, 'V3', 1000, '2020/06/10', 'Sony'),
(8, 'V1', 3000, '2023/10/07', 'PC Garage'),
(9, 'V2', 3500, '2024/10/07', 'PC Garage');

--Seeing the diff from sort by where and select from the cluster to noncluster indexes
Select Price from Computers
where Price>1500

Select * from Computers
order by ID

Select * from Computers
where Price>1500
order by Name_Brand

Select Name_Brand from Computers c inner join Brand b on c.Name_Brand=b.Name_Brand