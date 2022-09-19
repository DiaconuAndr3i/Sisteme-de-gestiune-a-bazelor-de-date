set serveroutput on;

-- PB1

create or replace trigger trg_pb1_adi
before delete on dept_adi
declare
    exp exception;
begin
    if user != upper('grupa251') then
        raise exp;
    end if;
    exception
        when exp then 
            raise_application_error(-20900,'Permisiune de delete respinsa!');
end;
/

drop trigger trg_pb1_adi;

delete from dept_adi
where department_id = 10;
rollback;

select * from dept_adi;





-- PB2
create or replace trigger trg_pb2_adi
before update of commission_pct on emp_adi
for each row
declare
    exp exception;
begin
    if nvl(:new.commission_pct,0) > 0.5 then
        raise exp;
    end if;
    
    exception
        when exp then
            raise_application_error(-20002,'Nu poate fi actualizat cu acest comision!');
end;
/

select * from emp_adi;

update emp_adi
set commission_pct = 0.51
where employee_id = 100;

rollback;


drop trigger trg_pb2_adi;


-- PB3
--a)
create table info_dept_adi as
select * from departments;

create table info_emp_adi as
select * from employees;

alter table info_dept_adi
add (numar number);

select * from info_dept_adi;

begin
    for item in (select department_id from departments) loop
        update info_dept_adi
        set numar = (select count(*) from employees where department_id = item.department_id)
        where department_id = item.department_id;
    end loop;
end;
/

select sum(numar) from info_dept_adi;


--b)
create or replace trigger trg_pb3_adi
after insert or update or delete of department_id on info_emp_adi
for each row
begin
    if updating then
        update info_dept_adi
        set numar = numar - 1
        where department_id = :old.department_id;
        update info_dept_adi
        set numar = numar + 1
        where department_id = :new.department_id;
    elsif deleting then
        update info_dept_adi
        set numar = numar - 1
        where department_id = :old.department_id;
    else
        update info_dept_adi
        set numar = numar + 1
        where department_id = :new.department_id;
    end if;
    dbms_output.put_line('Actualizare efectuata cu succes');
end;
/

drop trigger trg_pb3_adi;

-- Test
select * from info_emp_adi where department_id = 90;
select * from info_emp_adi;
desc info_emp_adi;
select * from info_dept_adi;
rollback;

update info_emp_adi
set department_id = 60
where department_id = 90;

insert into info_emp_adi
values(1000, 'Prenume', 'Nume', 'Email', 'NumarTel', sysdate, 'IdJob', 1000, null, 100, 270);

delete from info_emp_adi
where department_id = 90;




--PB4
select * from emp_adi;
select * from dept_adi;

create or replace trigger trg_pb4_adi
after update or insert or delete of department_id on emp_adi
for each row
declare
nr number;
begin
    if updating then
    -- mutating table
        /*select count(*)
        into nr
        from emp_adi
        where department_id = :old.department_id;
        dbms_output.put_line(nr);*/
    end if;
end;
/

drop trigger trg_pb4_adi;

select * from emp_adi order by employee_id;
select * from dept_adi order by manager_id;
select * from emp_adi where department_id = 50;

rollback;

update emp_adi
set department_id = 50
where department_id = 10;



-- PB5

-- a)
create table emp_test_adi as
select employee_id, last_name, first_name, department_id 
from employees;

alter table emp_test_adi
add constraint emp_test_adi_pk primary key (employee_id);

select * from emp_test_adi;
drop table emp_test_adi;

create table dept_test_adi as
select department_id, department_name from departments;

alter table dept_test_adi
add constraint dept_test_adi_pk primary key (department_id);

select * from dept_test_adi;
drop table dept_test_adi;

-- b)
-- Fara cheie externa intre tabele
create or replace trigger trg_pb5_adi
after delete or update on dept_test_adi
for each row
begin
    if deleting then
        delete from emp_test_adi
        where department_id = :old.department_id;
    else
        update emp_test_adi
        set department_id = :new.department_id
        where department_id = :old.department_id;
    end if;
    dbms_output.put_line('Tabelul emp_test_adi a fost actualizat cu succes!');
end;
/
drop trigger trg_pb5_adi;

-- Test
select * from dept_test_adi;
select * from emp_test_adi where department_id = 90;
select * from emp_test_adi;

delete from dept_test_adi
where department_name = 'Executive';
delete from dept_test_adi
where department_id = 90;

update dept_test_adi
set department_id = 300
where department_id = 90;

rollback;







-- Cu cheie externa intre cele 2 tabele

alter table emp_test_adi
add constraint emp_test_adi_fk foreign key (department_id) 
references dept_test_adi(department_id);

-- Triggerul arata identic iar testele functioneaza la fel


-- Cu cheie externa intre cele 2 tabele, cu optiunea ON DELETE CASCADE

-- Eliminam constrangerea precedenta si o actualizam
alter table emp_test_adi
drop constraint emp_test_adi_fk;

alter table emp_test_adi
add constraint emp_test_adi_fk foreign key (department_id) 
references dept_test_adi(department_id) on delete cascade;

-- Triggerul nu mai poate arata astfel pentru ca vom primi eroarea MUTATING TABLE!


-- Pentru constrangerea cu optiunea ON DELETE CASCADE, este suficient sa definim triggerul asfel
-- pentru delete, iar datele vor fi sterse in cascada sub influenta cheii straine
create or replace trigger trg_pb5_adi
after delete or update on dept_test_adi
for each row
begin
    dbms_output.put_line('Tabelul emp_test_adi a fost actualizat cu succes!'); 
end;
/
drop trigger trg_pb5_adi;
-- La update vor aparea probleme din pricina cheii straine  



-- Cu cheie externa intre cele 2 tabele, cu optiunea on delete set null


alter table emp_test_adi
drop constraint emp_test_adi_fk;

alter table emp_test_adi
add constraint emp_test_adi_fk foreign key (department_id) 
references dept_test_adi(department_id) on delete set null;

-- Vor aparea probleme atat pentru update cat si pentru delete din pricina cheii straine
-- cu optiunea ON DELETE CASCADE SET NULL, care va seta la null departmant_id-ul
-- acelor angajati afectati in urma modificarilor in dept_test_adi, astfel
-- putand aparea confuzii intre date daca inainte de modificari au existat
-- angajati care sa aiba department_id = null, la noi angajatul cu employee_id = 178,
-- va fi stres fara a fi nevoie din aceasta pricina.




-- PB6

create table info_audit_adi(
    user_id varchar2(30),
    nume_bd varchar2(30),
    erori varchar2(3000),
    data date);

drop table info_audit_adi;
    
    
create or replace trigger trg_pb6_adi
before create or drop or alter on schema
begin
    insert into info_audit_adi
    values (sys.login_user, sys.database_name, dbms_utility.Format_error_stack(), sysdate);
end;
/

drop trigger trg_pb6_adi;

create table adi(
    id number);
alter table adi
add constraint pk primary key (id);
alter table adi
drop constraint pk;
drop table adi;

select * from info_audit_adi;


-- Incercare de generare a unei erori 
create or replace package test_oracle is
    global_error varchar(3000);
    procedure main;
end test_oracle;
/

create or replace package body test_oracle is
    procedure main
    is
    dummy number;
    begin
        dummy := 1/0;
        
        exception
            when others then
                global_error := dbms_utility.Format_error_stack;
    end;
end test_oracle;
/

-- Eroarea nu este prinsa in trigger pentru ca nu execut una dintre create, drop, alter 
begin
    test_oracle.main();
    dbms_output.put_line(test_oracle.global_error);
end;
/



