--Cerinta 11
/*
    Trigger care nu permite inchirierea unei masini de mai mult de un numar dat de ori, pana nu i se efectueaza o inspectie tehnica.
Pentru exemplu aleg acest prag ca fiind 2 avand un numar relativ mic de inregistrari.
*/
set serveroutput on;
set verify off;


create or replace trigger cerinta11_adi
for insert or delete on inchiriere
compound trigger
    type rec is record(
    v_id_masina inchiriere.id_masina%type,
    v_marca masina.marca%type,
    v_tip masina.tip%type,
    nr_inchirieri number);
    type tablou_indexat is table of rec index by binary_integer;
    t tablou_indexat;
    
    before statement is 
    begin
    select i.id_masina, m.marca, m.tip, count(i.id_masina) nr_inchirieri
    bulk collect into t 
    from inchiriere i, masina m
    where i.id_masina(+) = m.id_masina
    group by i.id_masina, m.marca, m.tip
    order by id_masina;
    end before statement;
    
    after each row 
    is
    begin
        case 
            when inserting then
                for i in t.first..t.last loop
                    if t(i).v_id_masina = :new.id_masina then
                        if t(i).nr_inchirieri >= 2 then
                            raise_application_error(-20001, 'Masina cu codul '||t(i).v_id_masina||
                            ' nu mai poate fi inchiriata inaintea efectuarii unei inspectii tehnice.');
                        else
                            t(i).nr_inchirieri := t(i).nr_inchirieri + 1;
                        end if;
                    end if;
                end loop;
            when deleting then
                for i in t.first..t.last loop
                    if t(i).v_id_masina = :old.id_masina then
                        t(i).nr_inchirieri := t(i).nr_inchirieri - 1;
                    end if;
                end loop;
        end case;
    end after each row;
    
    after statement is
    begin
    for i in t.first..t.last loop
        dbms_output.put_line(t(i).v_id_masina||' '||t(i).v_marca||' '||t(i).v_tip||' '||t(i).nr_inchirieri);
    end loop;
    t.delete;
    end after statement;
end cerinta11_adi;
/

drop trigger cerinta11_adi;

-- Test1 masina cu codul 9 nu mai poate fi inchiriata deoarece deja a atins pragul de 2 inchirieri
insert into inchiriere
values(14, 666, 7, 9, TO_DATE('03-02-2021','dd-mm-yyyy'),TO_DATE('17-02-2021','dd-mm-yyyy'),850,null);
rollback;
-- Test2 masina cu codul 10 poate fi inchiriata in continuare
insert into inchiriere
values(14, 666, 7, 10, TO_DATE('03-02-2021','dd-mm-yyyy'),TO_DATE('17-02-2021','dd-mm-yyyy'),850,null);
rollback;
-- Test3 dupa efectuarea inspectiei tehinice a masinii cu identificatorul 1, stergem din tabela INCHIRIERE toate inregistrarile legate de aceasta
delete from inchiriere
where id_masina = 1;
rollback;


set serveroutput off;
set verify on;