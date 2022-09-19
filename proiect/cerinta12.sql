--Cerinta 12
/*
    Trigger ce va adauga in tabelul "ACTIUNE_GENERATA" informatii despre comenziile(alter, create, drop)
date de utilizator.
*/
set serveroutput on;
set verify off;

create table actiune_generata
	(bd_nume varchar2(50),
	 user_curent varchar2(30),
	 data_efectuare timestamp(3),
	 eveniment varchar2(2000),
     obiect_manipulat varchar2(30));
     
drop table actiune_generata;


create or replace trigger cerinta12_adi
	after create or drop or alter on schema
begin
	insert into actiune_generata
	values(sys.database_name, sys.login_user, systimestamp(3), sys.sysevent, sys.dictionary_obj_name);
    dbms_output.put_line('Inregistrare adaugata cu succes in tabelul ACTIUNE_GENERATA.');
end;
/

drop trigger cerinta12_adi;

create table test(
    id number(2) primary key,
    tip_test varchar2(50));


alter table test drop(tip_test);
alter table test add(nume varchar2(100));

drop table test;

select * from actiune_generata;



set serveroutput off;
set verify on;