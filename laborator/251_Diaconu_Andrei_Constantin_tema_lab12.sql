set serveroutput on;
set verify off;

--ex4) PLSQL6
select * from emp_adi;
select * from dept_adi;

select d.department_id, d.department_name, count(e.department_id)
from emp_adi e, dept_adi d
where e.department_id(+) = d.department_id
group by d.department_id, d.department_name;


create or replace trigger trg_pb4_adi
for insert or update of department_id on emp_adi
compound trigger
    
    type rec is record(
    cod_dep emp_adi.department_id%type,
    nume_dep dept_adi.department_name%type,
    nr_ang number);
    type tablou_indexat is table of rec index by binary_integer;
    t tablou_indexat;
    
    before statement is
    begin
        select d.department_id, d.department_name, count(e.department_id)
        bulk collect into t
        from emp_adi e, dept_adi d
        where e.department_id(+) = d.department_id
        group by d.department_id, d.department_name;    
    end before statement;
    
    after each row is
    begin
        case
            when inserting then
                for i in t.first..t.last loop
                    if t(i).cod_dep = :new.department_id then
                        if t(i).nr_ang >= 45 then
                            raise_application_error(-20001, 'Nu pot lucra mai mult de 45 de angajati in departamentul '||t(i).nume_dep);
                        else
                            t(i).nr_ang := t(i).nr_ang + 1;
                        end if;
                    end if;
                end loop;
            when updating then
                for i in t.first..t.last loop
                    if t(i).cod_dep = :new.department_id then
                        if t(i).nr_ang >= 45 then
                            raise_application_error(-20001, 'Nu pot lucra mai mult de 45 de angajati in departamentul '||t(i).nume_dep);
                        else
                            t(i).nr_ang := t(i).nr_ang + 1;
                        end if;
                    end if;
                    if t(i).cod_dep = :old.department_id then
                        t(i).nr_ang := t(i).nr_ang - 1;
                    end if;
                end loop;
            when deleting then
                for i in t.first..t.last loop
                    if t(i).cod_dep = :old.department_id then
                        t(i).nr_ang := t(i).nr_ang - 1;
                    end if;
                end loop;
        end case;             
    end after each row;
    
    after statement is
    begin
    for i in t.first..t.last loop
        dbms_output.put_line(t(i).cod_dep||' '||t(i).nume_dep||' '||t(i).nr_ang);
    end loop;
    t.delete;
    end after statement;

end trg_pb4_adi;
/

drop trigger trg_pb4_adi;

--Test
select * from emp_adi order by employee_id;
select * from dept_adi order by manager_id;
select * from emp_adi where department_id = 10;

rollback;

desc emp_adi;

--In departamentul cu codul 10 lucreaza un singur angajat care are codul 200

--Departamentul cu codul 50 are deja 45 de angajati si nu mai permite adaugarea de noi angajati
update emp_adi
set department_id = 50
where department_id = 10;

-- Actualizare efectuata cu succes
update emp_adi
set department_id = 90
where department_id = 10;

-- Inserare efectuata cu succes
insert into emp_adi
values(1000, 'Prenume', 'Nume', 'Email', 'NumarTel', sysdate, 'IdJob', 1000, null, 100, 270);

-- Eroare, dep cu codul 50 nu mai permite adaugarea de noi angajati
insert into emp_adi
values(1001, 'Prenume1', 'Nume1', 'Email1', 'NumarTel1', sysdate, 'IdJob1', 1000, null, 100, 50);

-- Stergere efectuata cu succes
delete from emp_adi
where employee_id = 200;



--ex3 PLSQL7
accept p_cod_existent prompt 'Dati codul departamentului de modificat';
accept p_cod_de_modificat prompt 'Dati noul cod de departament';
declare
    exp exception;
    pragma exception_init(exp,-02292);
begin
    update dept_adi
    set department_id = &p_cod_de_modificat
    where department_id = &p_cod_existent;
    
    exception
        when exp then
            dbms_output.put_line('Nu se pot efectua modificari asupra codului unui departament unde lucreaza angajati.');
        when others then
            dbms_output.put_line('Alta eroare.');
end;
/

rollback;

update dept_adi
set department_id = 1000
where department_id = 10;

update dept_adi
set department_id = 1001
where department_id = 270;





--ex4) PLSQL7

accept st prompt 'Introduceti capatul din stanga al intervalului';
accept dr prompt 'Introduceti capatul din dreapta al intervalului';
declare
    exp exception;
    nr_ang_dep number;
    cod_dep emp_adi.department_id%type := 10;
    nume_dep dept_adi.department_name%type;
begin
    select count(*)
    into nr_ang_dep
    from emp_adi
    where department_id = cod_dep;
    if nr_ang_dep not between &st and &dr then
        raise exp;
    end if;
    
    select department_name
    into nume_dep
    from dept_adi d, emp_adi e
    where d.department_id = e.department_id
    and d.department_id = cod_dep;
    
    dbms_output.put_line('Totul ok. Numele departamentului este '||nume_dep||'.');
    exception
        when exp then 
            dbms_output.put_line('Numarul de angajati din departamentul cu codul '||cod_dep||'(nr_ang='||nr_ang_dep
            ||')'||' nu se afla in intervalul '||'['||&st||', '||&dr||'].');
        when others then
            dbms_output.put_line('Alta eroare.');
end;
/


select count(*)
from emp_adi
where department_id = 10;


set verify on;
set serveroutput off;