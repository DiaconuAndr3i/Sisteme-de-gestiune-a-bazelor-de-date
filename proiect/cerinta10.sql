--Cerinta 10
/*
    Trigger ce va permite actiunile de insert, update pe tabelul "CLIENT" doar pentru executarea in timpul
unei ore impare( ex: 3:34:21 permite actiunile necesare; 2:23:56 permisiune respinsa)
*/
set serveroutput on;
set verify off;


create or replace trigger cerinta10_adi
before insert or update on client
declare
    exp_nepotrivire_ora_insert exception;
    exp_nepotrivire_ora_update exception;
    ora_completa varchar2(20);
    ora number(10);
    
    function modulo(x number, y number)
    return number
    is
    result number;
    begin
        result := x - y * floor(x/y);
        return result;
    end;
   
    
begin

    select to_char(sysdate, 'HH24:MI:SS'), to_number(to_char(sysdate, 'HH24'))
    into ora_completa, ora
    from dual;
    
    if modulo(ora, 2) = 0 then
        if inserting then
            raise exp_nepotrivire_ora_insert;
        else
            raise exp_nepotrivire_ora_update; 
        end if;
    end if;
    
    dbms_output.put_line('Este ora '||ora_completa||', modificari permise!');
        
    exception
        when exp_nepotrivire_ora_insert then 
            raise_application_error(-20900,'Permisiune de insert respinsa!');
        when exp_nepotrivire_ora_update then
            raise_application_error(-20900,'Permisiune de update respinsa!');
        when others then
            raise_application_error(-20000,'Alta eroare');

end;
/

drop trigger cerinta10_adi;

--Test insert
insert into client
values(996,6,'Stoica','Marius','0725252525',7667278885990);
rollback;

--Test update
update client
set telefon = '0711111111'
where id_client = 222;
rollback;



set serveroutput off;
set verify on;