--Cerinta 13
/*
    Trigger Cerinta10: Trigger ce va permite actiunile de insert, update pe tabelul "CLIENT" doar pentru executarea in timpul
unei ore impare( ex: 3:34:21 permite actiunile necesare; 2:23:56 permisiune respinsa)

    Trigger Cerinta 11: Trigger care nu permite inchirierea unei masini de mai mult de un numar dat de ori, pana nu i se efectueaza o inspectie tehnica.
Pentru exemplu aleg acest prag ca fiind 2 avand un numar relativ mic de inregistrari.

    Trigger Cerinta 12: Trigger ce va adauga in tabelul "ACTIUNE_GENERATA" informatii despre comenziile(alter, create, drop)
date de utilizator.
*/
set serveroutput on;
set verify off;

@C:\Users\Andrei\Desktop\proiect_sgbd\SCHEMA_GEN.sql;
@C:\Users\Andrei\Desktop\proiect_sgbd\cerinta10_adi.sql;
@C:\Users\Andrei\Desktop\proiect_sgbd\cerinta11_adi.sql;
@C:\Users\Andrei\Desktop\proiect_sgbd\cerinta12_adi.sql;

delete from actiune_generata;

create or replace package cerinta13_adi as
    
    trigger_declansare number := 1;

    procedure cerinta6_adi(cod_sediu in number);
    procedure cerinta7_adi;
    function cerinta8_adi(v_nume client.nume%type, v_prenume client.prenume%type)
    return varchar2;
    procedure cerinta9_adi(nume_sediu sediu_inchiriere.denumire%type);
    procedure enable_triggers;
    procedure disable_triggers;

end cerinta13_adi;
/


create or replace package body cerinta13_adi as
    
    procedure cerinta6_adi(cod_sediu in number)
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

        
        if trigger_declansare = 0 then
            enable_triggers;
        end if;
    
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
        
        if trigger_declansare = 0 then
            disable_triggers;
        end if;
        

    end;
    
    
    
    
    procedure cerinta7_adi
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

        if trigger_declansare = 0 then
            enable_triggers;
        end if;
        
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
        if trigger_declansare = 0 then
            disable_triggers;
        end if;
    end;
    
    
    
    
    function cerinta8_adi(v_nume client.nume%type, v_prenume client.prenume%type)
    return varchar2 is
    v_id_client client.id_client%type;
    
    exp_fara_clienti exception;
    exp_mai_multi_clienti exception;
    exp_client_fara_inchirieri exception;
    ct number(10);
    val_return varchar2(30);

    begin

        if trigger_declansare = 0 then
            enable_triggers;
        end if;
    
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
        
        if trigger_declansare = 0 then
            disable_triggers;
        end if;
        
        return val_return;
        
        exception
            when exp_fara_clienti then
                dbms_output.put_line('Nu exista clienti cu numele '||v_nume||' si prenumele '||v_prenume||'.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
                return null;
            when exp_mai_multi_clienti then
                dbms_output.put_line('Exista mai multi clienti cu numele '||v_nume||' si prenumele '||v_prenume||'.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
                return null;
            when exp_client_fara_inchirieri then
                dbms_output.put_line('Clientul nu a inchiriat vreo masina in ultima vreme.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
                return null;
            when others then
                dbms_output.put_line('Alta eroare.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
                return null;
                
    end;
    
    procedure cerinta9_adi(nume_sediu sediu_inchiriere.denumire%type)
    is
    type rec is record(
        id_sediu sediu_inchiriere.id_sediu%type,
        oras adresa.oras%type,
        strada adresa.strada%type,
        nr_avarii number,
        masini_inchiriate number);
    
    activitate_sediu rec;    
    
    exp_nu_exista_sediu exception;
    
    ct number;

    begin

        if trigger_declansare = 0 then
            enable_triggers;
        end if;
        
        select count(*)
        into ct
        from sediu_inchiriere
        where lower(trim(denumire)) = lower(trim(nume_sediu));
        
        if ct = 0 then
            raise exp_nu_exista_sediu;
        end if;
        
        
        select si.id_sediu, adr.oras, adr.strada, tabel.nr_avarii, count(i.id_masina) masini_inchiriate
        into activitate_sediu
        from sediu_inchiriere si, adresa adr,
        
        (select count(sr.id_avarie) nr_avarii
        from stare_returnare sr, avarie a, sediu_inchiriere si
        where sr.id_avarie = a.id_avarie and
        lower(trim(tip_avarie)) != lower(trim('Fara avarii')) and
        sr.id_sediu = si.id_sediu and lower(trim(si.denumire)) = lower(trim(nume_sediu)) ) tabel,
        
        inchiriere i
        where si.id_adresa = adr.id_adresa and
        si.id_sediu = i.id_sediu and
        lower(trim(si.denumire)) = lower(trim(nume_sediu))
        group by si.id_sediu, adr.oras, adr.strada, tabel.nr_avarii;
        
        dbms_output.put_line('Sediul cu id-ul '||activitate_sediu.id_sediu||' din orasul '||activitate_sediu.oras||
        ' situat pe strada '||activitate_sediu.strada||' a inregistrat un numar de avarii = '||activitate_sediu.nr_avarii||
        ' la un numar de masini = '||activitate_sediu.masini_inchiriate||'.');
        
        if trigger_declansare = 0 then
            disable_triggers;
        end if;
        
        exception
            when exp_nu_exista_sediu then
                dbms_output.put_line('Nu exista sediul cu numele '||nume_sediu||'.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
            when no_data_found then
                dbms_output.put_line('Sediul cu codul dat nu a avut activitate.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
            when too_many_rows then
                dbms_output.put_line('Exista mai multe sedii cu numele dat.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;
            when others then
                dbms_output.put_line('Alta eroare.');
                if trigger_declansare = 0 then
                    disable_triggers;
                end if;        
    end;
    
    procedure enable_triggers
    is
    begin
        execute immediate 'alter trigger cerinta10_adi enable';
        execute immediate 'alter trigger cerinta11_adi enable';
        execute immediate 'alter trigger cerinta12_adi enable';
    end;
    
    procedure disable_triggers
    is
    begin
        execute immediate 'alter trigger cerinta10_adi disable';
        execute immediate 'alter trigger cerinta11_adi disable';
        execute immediate 'alter trigger cerinta12_adi disable';
    end;
    
end cerinta13_adi;
/


drop package cerinta13_adi;

<<cerinta6>>
begin
    cerinta13_adi.trigger_declansare := 1;
    dbms_output.put_line('*******');
    dbms_output.put_line('Test1');
    dbms_output.put_line('*******');
    cerinta13_adi.cerinta6_adi(3);
    dbms_output.put_line('*******');
    dbms_output.put_line('Test2');
    dbms_output.put_line('*******');
    cerinta13_adi.cerinta6_adi(7);
    dbms_output.put_line('*******');
    dbms_output.put_line('Test3');
    dbms_output.put_line('*******');
    cerinta13_adi.cerinta6_adi(10);
end;
/


<<cerinta7>>
begin
    cerinta13_adi.trigger_declansare := 1;
    cerinta13_adi.cerinta7_adi;
end;
/

<<cerinta8>>
begin
    cerinta13_adi.trigger_declansare := 1;
    --Test1 - mai multi clienti cu acelasi nume
    --dbms_output.put_line(cerinta13_adi.cerinta8_adi('Dinculescu', 'Andreea'));
     --Test2 - niciun client cu numele si prenumele dat
    --dbms_output.put_line(cerinta13_adi.cerinta8_adi('Odogar', 'Mihaela'));
     --Test3 - clientul nu a inchiriat nicio masina in ultima perioada si astfel nu se poate afisa preferinta
    --dbms_output.put_line(cerinta13_adi.cerinta8_adi('Antal', 'George'));
     --Test4 - exemplu pentru Avramescu Eduard
    dbms_output.put_line(cerinta13_adi.cerinta8_adi('Avramescu', 'Eduard'));
end;
/

<<cerinta9>>
begin
    cerinta13_adi.trigger_declansare := 1;
    --Test 1 sediul nu a avut activitate (no_data_found) 
    --cerinta13_adi.cerinta9_adi('E');
    --Test2 exista mai multe sediuri cu numele dat (too_many_rows)
    --cerinta13_adi.cerinta9_adi('A');
    --Test3 nu exista sediu cu numele dat
    --cerinta13_adi.cerinta9_adi('Z');
    --Test4 functionare normala
    cerinta13_adi.cerinta9_adi('C');
end;
/



select * from actiune_generata;

set serveroutput off;
set verify on;