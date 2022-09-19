--Cerinta 6
/*
    Pentru fiecare client, afisati toate avariile produse de acesta(daca exista) inregistrare la un 
anumit sediu al carui cod este trimis ca parametru. In caz contrar se va afisa un mesaj corespunzator.
*/
set serveroutput on;
set verify off;


create or replace procedure cerinta6_adi(cod_sediu in number)
    is
    type tablou_indexat is table of client%rowtype
            index by binary_integer;
            
    type tablou_indexat2 is table of avarie.tip_avarie%type
            index by binary_integer;
    
    type rec is record(
        nume varchar2(50),
        prenume varchar2(50),
        avarii tablou_indexat2);
        
    type tablou_imbricat is table of rec;
    
         
    tab_index tablou_indexat;
    tab_imbri tablou_imbricat := tablou_imbricat();
    
    contor number := 0;
    ok number;
    begin
        select * 
        bulk collect into tab_index
        from client;
        
        
        for item in tab_index.first..tab_index.last loop
            
            select count(*)
            into ok
            from stare_returnare
            where id_client = tab_index(item).id_client and
                id_sediu = cod_sediu;
            
            if ok <> 0 then
                contor := contor + 1;         
                tab_imbri.extend;          
                
                select tip_avarie
                bulk collect into tab_imbri(contor).avarii
                from avarie a, stare_returnare sr
                where a.id_avarie = sr.id_avarie and
                id_client = tab_index(item).id_client and
                id_sediu = cod_sediu;
             
                tab_imbri(contor).nume := tab_index(item).nume;
                tab_imbri(contor).prenume := tab_index(item).prenume;       
            end if;
            
        end loop;
        

        
        for i in tab_imbri.first..tab_imbri.last loop
            dbms_output.put_line(tab_imbri(i).nume||' '||tab_imbri(i).prenume);
            dbms_output.put_line('_______________________________');
            for item in tab_imbri(i).avarii.first..tab_imbri(i).avarii.last loop
                dbms_output.put_line(tab_imbri(i).avarii(item));
            end loop;
            dbms_output.put_line('-------------------------------');
            dbms_output.new_line;
        end loop;
        
        tab_index.delete;
        tab_imbri.delete;

    end;
    /


drop procedure cerinta6_adi;

begin
    dbms_output.put_line('*******');
    dbms_output.put_line('Test1');
    dbms_output.put_line('*******');
    cerinta6_adi(3);
    dbms_output.put_line('*******');
    dbms_output.put_line('Test2');
    dbms_output.put_line('*******');
    cerinta6_adi(7);
    dbms_output.put_line('*******');
    dbms_output.put_line('Test3');
    dbms_output.put_line('*******');
    cerinta6_adi(10);
end;
/


set serveroutput off;
set verify on;