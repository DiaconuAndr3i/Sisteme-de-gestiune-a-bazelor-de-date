--Cerinta 7
/*
    Pentru fiecare client(id, nume, prenume) afisati numarul de masini inchiriate sub forma
        Clientul x nu a inchiriat nicio masina.
        Clientul x a inchiriat o masina.
        Clientul x a inchiriat un numar de y masini.
*/
set serveroutput on;
set verify off;

create or replace procedure cerinta7_adi
    is
    cursor c is
    select c.id_client, nume, prenume, count(id_masina)
    from client c, inchiriere i
    where c.id_client = i.id_client(+)
    group by c.id_client, nume, prenume; 
    
    type rec is record(
        id_client client.id_client%type,
        nume client.nume%type,
        prenume client.prenume%type,
        nr number);
    
    date_client rec;
    
    begin
        open c;
        loop
            fetch c into date_client;
            exit when c%notfound;
                if date_client.nr = 0 then
                    dbms_output.put_line('Clientul cu id-ul '||date_client.id_client||' si numele '||
                    date_client.nume||' '||date_client.prenume||' nu a inchiriat nicio masina.');
                
                elsif date_client.nr = 1 then
                    dbms_output.put_line('Clientul cu id-ul '||date_client.id_client||' si numele '||
                    date_client.nume||' '||date_client.prenume||' a inchiriat o masina.');
                
                else
                    dbms_output.put_line('Clientul cu id-ul '||date_client.id_client||' si numele '||
                    date_client.nume||' '||date_client.prenume||' a inchiriat un numar de '||date_client.nr||' masini.');
                end if;
                
        end loop;  
    end;
    /


drop procedure cerinta7_adi;

begin
    cerinta7_adi;
end;
/



set serveroutput off;
set verify on;