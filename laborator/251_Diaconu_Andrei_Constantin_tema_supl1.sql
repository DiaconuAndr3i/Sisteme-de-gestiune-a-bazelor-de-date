--1)

set serveroutput on;
set verify off;


/*
    Afisati membrii care au inchiriat filme, titlul acestora si copia pentru fiecare film, din cea mai ceruta categorie.
*/

declare
    procedure afisati_membrii_adi
    is
    
        cursor membrii(cat title.category%type) is
        select distinct m.member_id, last_name, first_name, t.title, r.copy_id
        from member m, rental r, title t
        where m.member_id = r.member_id and
        r.title_id = t.title_id and
        t.category = cat;
        
        cursor categorie is
        select category from
        (select category, count(r.title_id) nr_inchirieri
        from rental r, title t
        where r.title_id = t.title_id
        group by category
        order by nr_inchirieri desc)
        where nr_inchirieri = 
        (select max(nr_inchirieri)
        from(
        select category, count(r.title_id) nr_inchirieri
        from rental r, title t
        where r.title_id = t.title_id
        group by category
        order by nr_inchirieri desc));
        
        type rec is record(
            v_member_id member.member_id%type,
            v_last_name member.last_name%type,
            v_first_name member.first_name%type,
            v_title title.title%type,
            v_copy_id rental.copy_id%type
            );
        date_membru rec;

    v_categorie title.category%type;
    ct number := 0;
    exp exception;
    begin
        
        open categorie;
        loop 
            fetch categorie into v_categorie;
            if categorie%notfound and ct = 0 then
                raise exp;
            end if;
            exit when categorie%notfound;
            dbms_output.put_line('Pentru categoria '||v_categorie||', membrii care au imprumutat sunt:');
            open membrii(v_categorie);
            loop
                fetch membrii into date_membru;
                exit when membrii%notfound;
                dbms_output.put_line('Id: '||date_membru.v_member_id||', Nume: '||date_membru.v_first_name||', Prenume: '||date_membru.v_last_name||
                ', Titlu film: '||date_membru.v_title||', Copie film: '||date_membru.v_copy_id);
            end loop;
            close membrii;
            
            ct := ct + 1;
        end loop;
        close categorie;
        exception
            when exp then
                dbms_output.put_line('Nu a fost efectuata nicio inchiriere!');
    end;
begin
    afisati_membrii_adi;
end;
/

-- Test pentru situatia cand tabela rental nu contine inregistrari
delete from rental;
rollback;


set serveroutput off;
set verify on;










--2)

set serveroutput on;
set verify off;


/*
    Pentru acest tip de date, voi utiliza un obiect ale carui campuri vor fi de tip number si respectiv varchar2.
    Prin aceste campuri voi retine, pentru fiecare film, de cate ori a fost inchiriat si repectiv,
    procentul de inchiriere.
*/


-- Definim tipul de date descris mai sus
create or replace type obj is object(
    nr_inchirieri number(10),
    procent_inchirieri varchar2(10));
/

    
alter table title
add (date_inchirieri obj);


alter table title
drop column date_inchirieri;

desc title;

create or replace procedure pb1_adi
is
ct_item number;
ct number;
begin

    select count(*)
    into ct 
    from rental;
    
    for item in (select * from title) loop
        select count(*)
        into ct_item
        from rental
        where title_id = item.title_id;
        
        update title
        set date_inchirieri = obj(ct_item, concat(to_char(round(ct_item / decode(ct,0,-1,ct) * 100, 2)),'%')) -- decode pt a evita o eventuala impartire la 0
        where title_id = item.title_id;
        
    end loop;
    
    
    
end;
/

drop procedure pb1_adi;

begin
    pb1_adi;
end;
/

rollback;

select t.title_id, t.title, t.description, t.rating, t.category, t.release_date,
t.date_inchirieri.nr_inchirieri,
t.date_inchirieri.procent_inchirieri
from title t;


set serveroutput off;
set verify on;












--3)

set serveroutput on;
set verify off;

/*
    Trigger ce nu va permite actualizarea categoriei filmelor incadrate in cele mai inchiriate categorii.
*/

-- Exemplu "mutating table" -> incercam sa aducem modificari tabelului TITLE, in cazul de mai jos o simpla interogare
-- urmata de o aruncare a unei exceptii, in timp ce se afla deja in proces de actualizare
create or replace trigger trg_adi
before update of category on title
for each row
declare
type cat_tab is table of title.category%type index by pls_integer;
t cat_tab;
begin
--Selectam cele mai inchiriate categorii(in acest caz va fi una singura SCIFI)
    select category
    bulk collect into t
    from
    (select category, count(r.title_id) nr_inchirieri
    from rental r, title t
    where r.title_id = t.title_id
    group by category
    order by nr_inchirieri desc)
    where nr_inchirieri = 
    (select max(nr_inchirieri)
    from(
    select category, count(r.title_id) nr_inchirieri
    from rental r, title t
    where r.title_id = t.title_id
    group by category
    order by nr_inchirieri desc));
    
    --Nu permitem actualizarea cu o alta categorie daca se afla deja in cea mai inchiriata categorie
    for i in t.first..t.last loop
        if t(i) = :old.category then
            raise_application_error(-20001, 'Nu puteti modifica cea mai imprumutata categorie cu alta!');
        end if;
    end loop;
    
    t.delete;
end;
/

drop trigger trg_adi;

-- Trigger-ul va arunca eroarea ORA-04091 incercand sa facem orice tip de update asupra 
-- unei categorii pe tabelul TITLE
update title
set category = 'DRAMA'
where category = 'SCIFI';

update title
set category = 'SCIFI'
where category = 'DRAMA';

rollback;





-- Remediere printr-un compound trigger

create or replace trigger trg_adi
for update of category on title
compound trigger
    -- In sectiunea declarativa, definim tabloul indexat
    type cat_tab is table of title.category%type index by pls_integer;
    t cat_tab;
    
    before statement is
    begin
    
    -- In aceasta sectiune selectam cele mai inchiriate categorii, in acest fel eliminand eroarea "mutating table"
        select category
    bulk collect into t
    from
    (select category, count(r.title_id) nr_inchirieri
    from rental r, title t
    where r.title_id = t.title_id
    group by category
    order by nr_inchirieri desc)
    where nr_inchirieri = 
    (select max(nr_inchirieri)
    from(
    select category, count(r.title_id) nr_inchirieri
    from rental r, title t
    where r.title_id = t.title_id
    group by category
    order by nr_inchirieri desc));
    
    end before statement;
        
    before each row is
    -- Daca update-ul pe care il initiem refera o modificare a unei categorii incadrate ca cea mai inchiriata,
    -- aruncam o eroare
    begin
        case
            when updating then
                for i in t.first..t.last loop
                    if t(i) = :old.category then
                        raise_application_error(-20001, 'Nu puteti modifica cea mai imprumutata categorie cu alta!');
                    end if;
                end loop;
        end case;
    end before each row;
    
    after statement is
    begin
        -- Eliberam memoria
        t.delete;
    end after statement;
    
end trg_adi;
/


drop trigger trg_adi;

update title
set category = 'DRAMA'
where category = 'SCIFI';

update title
set category = 'SCIFI'
where category = 'DRAMA';

rollback;



set serveroutput off;
set verify on;










--4)

set serveroutput on;
set verify off;

/*
    Trigger ce nu permite inchirierea unui film cu un id care nu exista in tabela TITLE
    (Constrangerea se aplica pe tabela RENTAL)
*/
-- Cate filme a imprumutat fiecare membru
select m.member_id, count(r.member_id)
from member m, rental r
where m.member_id = r.member_id(+)
group by m.member_id;

select * from member;
select * from rental;


create or replace trigger trg_pb4_adi
before insert on rental
for each row
declare
ct number;
begin
    select count(*)
    into ct
    from title
    where title_id = :new.title_id;
    
    if ct = 0 then
        raise_application_error(-20001, 'Inregistrare nevalida. Filmul cu id-ul '||:new.title_id||' nu exista.');
    end if;
    
end trg_pb4_adi;
/

drop trigger trg_pb4_adi;

-- Exemplu cand nu permite insertia
insert into rental
values(sysdate, 1, 101, 100, null, sysdate);
rollback;

-- Exemplu cand permite insertia
insert into rental
values(sysdate, 1, 101, 98, null, sysdate);
rollback;

set serveroutput off;
set verify on;