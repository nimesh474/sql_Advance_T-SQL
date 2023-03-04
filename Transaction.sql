create database BankAccount;
use BankAccount;

create table account_sheet(
id int primary key identity(1,1),
accountNumber bigint unique not null,
accountName varchar(50) not null,
citizenNumber varchar(50) not null,
DOB date default getdate(),
amount decimal(10,2)
);

insert into account_sheet(accountNumber, accountName, citizenNumber, DOB, amount)
values(058923400012985, 'Ram', '1234-9-73', '2-28-2023', 5000),
(058923400048755, 'Shyam', '23-67','2020-07-22', 7000);



-- Transaction Procedure

alter procedure AccountDetails(@sourceAccountID bigint, 
								@destinationAccountID bigint,
								@transAmount decimal(10,2))
as
begin
	begin try
		begin transaction
			declare @amountZero int

			set @amountZero = (select amount from account_sheet
								where accountNumber = @sourceAccountID)
			if (@amountZero < @transAmount)
				print 'Invalid Transaction Attempt'
			else
			begin
				update account_sheet
					set amount = amount-@transAmount
					where accountNumber = @sourceAccountID
				update account_sheet
					set amount = amount+@transAmount
					where accountNumber = @destinationAccountID
			end

			print @@trancount
			if @@trancount > 0
				commit
	end try
	begin catch
		if @@TRANCOUNT >0
			rollback
		select error_line(), error_message(), error_number()
	end catch
end;

execute AccountDetails @sourceAccountID=58923400012985,
					   @destinationAccountID=58923400048755,
					   @transAmount=1000;
select * from account_sheet;

update account_sheet
	set amount=10000
	where accountNumber=58923400012985;