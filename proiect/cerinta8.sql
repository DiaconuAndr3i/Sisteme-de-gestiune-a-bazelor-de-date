--Cerinta 8
/*
    Pentru un client ale carui nume si prenume sunt furnizate de utilizator, afisati preferinta 
lui in materie de cutie de viteze.
*/
set serveroutput on;
set verify off;

select count(cutie_de_viteze)
from(
select cutie_de_viteze, count(cutie_de_viteze) nr
from client c, inchiriere i, masina m
where c.id_client = 999 and
c.id_client = i.id_client and
i.id_masina = m.id_masina
group by cutie_de_viteze
order by nr desc)
where rownum <=1;

create or replace function cerinta8_adi(v_nume client.nume%type, v_prenume client.prenume%type)
    return varchar2 is
    v_id_client client.id_client%type;
    
    exp_fara_clienti exception;
    exp_mai_multi_clienti exception;
    exp_client_fara_inchirieri exception;
    ct number(10);
    val_return varchar2(30);
    
    begin
        select count(*)
        into ct
        from client
        where lower(trim(nume)) = lower(trim(v_nume)) and
        lower(trim(prenume)) = lower(trim(v_prenume));
        
        if ct = 0 then
            raise exp_fara_clienti;
        elsif ct > 1 then
            raise exp_mai_multi_clienti;
        end if;
    
        select id_client
        into v_id_client
        from client
        where lower(trim(nume)) = lower(trim(v_nume)) and
        lower(trim(prenume)) = lower(trim(v_prenume));
        
        select count(id_masina)
        into ct
        from inchiriere i, client c
        where c.id_client = i.id_client and
        c.id_client = v_id_client;
        
        if ct = 0 then
            raise exp_client_fara_inchirieri;
        end if;
        
        select cutie_de_viteze
        into val_return
        from(
        select cutie_de_viteze, count(cutie_de_viteze) nr
        from client c, inchiriere i, masina m
        where c.id_client = v_id_client and
        c.id_client = i.id_client and
        i.id_masina = m.id_masina
        group by cutie_de_viteze
        order by nr desc)
        where rownum <=1;
       
        return val_return;
            
        exception
            when exp_fara_clienti then
                dbms_output.put_line('Nu exista clienti cu numele '||v_nume||' si prenumele '||v_prenume||'.');
                return null;
            when exp_mai_multi_clienti then
                dbms_output.put_line('Exista mai multi clienti cu numele '||v_nume||' si prenumele '||v_prenume||'.');
                return null;
            when exp_client_fara_inchirieri then
                dbms_output.put_line('Clientul nu a inchiriat vreo masina in ultima vreme.');
                return null;
            when others then
                dbms_output.put_line('Alta eroare.');
                return null;
    end;
    /

drop function cerinta8_adi;

begin
    --Test1 - mai multi clienti cu acelasi nume
    --dbms_output.put_line(cerinta8_adi('Dinculescu', 'Andreea'));
     --Test2 - niciun client cu numele si prenumele dat
    --dbms_output.put_line(cerinta8_adi('Odogar', 'Mihaela'));
     --Test3 - clientul nu a inchiriat nicio masina in ultima perioada si astfel nu se poate afisa preferinta
    --dbms_output.put_line(cerinta8_adi('Antal', 'George'));
     --Test4 - exemplu pentru Avramescu Eduard
    dbms_output.put_line(cerinta8_adi('Avramescu', 'Eduard'));
end;
/


set serveroutput off;
set verify on;