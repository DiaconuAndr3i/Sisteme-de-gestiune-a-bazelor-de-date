--Cerinta 9
/*
    Pentru un sediu a carui denumire este dat ca parametru, afisati informatii despre activitatea acestuia
(numarul de avarii avute precum si numarul de masini inchiriate) si adresa unde se situeaza.
*/
set serveroutput on;
set verify off;



create or replace procedure cerinta9_adi(nume_sediu sediu_inchiriere.denumire%type)
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
        
        exception
            when exp_nu_exista_sediu then
                dbms_output.put_line('Nu exista sediul cu numele '||nume_sediu||'.');
            when no_data_found then
                dbms_output.put_line('Sediul cu codul dat nu a avut activitate.');
            when too_many_rows then
                dbms_output.put_line('Exista mai multe sedii cu numele dat.');
            when others then
                dbms_output.put_line('Alta eroare.');
    end;
    /


drop procedure cerinta9_adi;

begin
    --Test 1 sediul nu a avut activitate (no_data_found) 
    --cerinta9_adi('E');
    --Test2 exista mai multe sediuri cu numele dat (too_many_rows)
    --cerinta9_adi('A');
    --Test3 nu exista sediu cu numele dat
    --cerinta9_adi('Z');
    --Test4 functionare normala
    cerinta9_adi('C');
end;
/

set serveroutput off;
set verify on;