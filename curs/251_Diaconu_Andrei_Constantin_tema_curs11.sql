-- PB1 CURS
-- Voi genera un tabel care va retine informatiile necesare pentru implementarea unui astfel de trigger
create table client_preturi_preferentiale_adi(
    id_client number(6),
    perioada_start date,
    perioada_end date,
    beneficiere number(1),
    nr_perioade number(1),
    constraint pk_id_client primary key (id_client));

-- Inserez doua inregistrari de test in tabel    
insert into client_preturi_preferentiale_adi
    values(1,sysdate - 246, concat(concat(concat(concat(to_char(sysdate - 246, 'DD'),'-'),to_char(sysdate - 246, 'MON')),'-'),to_char(sysdate - 246,'yy')+1), 0, 3);

insert into client_preturi_preferentiale_adi
    values(2,sysdate - 128, concat(concat(concat(concat(to_char(sysdate - 128, 'DD'),'-'),to_char(sysdate - 128, 'MON')),'-'),to_char(sysdate - 128,'yy')+1), 0, 2);

    
drop table client_preturi_preferentiale_adi; 
select * from client_preturi_preferentiale_adi;

create or replace trigger trg_adi
    before update or insert on client_preturi_preferentiale_adi
    for each row
declare
    exceptie_update exception;
    exceptie_insert exception;
    actualizare_nevalida1 exception;
    actualizare_nevalida2 exception;
begin
    if updating('beneficiere') then
        if (:old.beneficiere = 0 and :new.beneficiere = 0) or
           (:old.beneficiere = 1 and :new.beneficiere = 1) then
            raise actualizare_nevalida1;
        end if;
        if :new.beneficiere != 0 and :new.beneficiere != 1 then
            raise actualizare_nevalida2;
        end if;
        if :old.nr_perioade >= 3 then
            raise exceptie_update;
        end if;
        
    elsif inserting then
        if :new.nr_perioade > 3 then
            raise exceptie_insert;
        end if;
    end if;
    exception
        when exceptie_update then
            raise_application_error (-20002, 'Clientul si-a epuizat perioadele de 
            alocare a preturilor preferentiale!');
        when exceptie_insert then
            raise_application_error (-20002, 'Clientul pe care doriti sa-l inserati nu poate beneficia 
            de mai mult de 3 perioade cu preturi preferentiale!');
        when actualizare_nevalida1 then
            raise_application_error (-20001, 'Actualizare nevalida1!');
        when actualizare_nevalida2 then
            raise_application_error (-20001, 'Actualizare nevalida2!');
end;
/

drop trigger trg_adi;

update client_preturi_preferentiale_adi
set beneficiere = 1
where id_client = 1;
rollback;

insert into client_preturi_preferentiale_adi
values(3,sysdate,concat(concat(concat(concat(to_char(sysdate, 'DD'),'-'),to_char(sysdate, 'MON')),'-'),to_char(sysdate,'yy')+1),0,4);


-- PB2 CURS
-- Pentru tabelul departments, stabilim sa nu putem avea campul location_id null
select * from departments;

desc departments;

create or replace trigger trg2_adi 
    before update or insert on departments
    for each row
    declare 
    exp exception;
    begin
        if updating('location_id') then
            if :new.location_id is null then
                raise exp;
            end if;
        end if;
        
        if inserting then
            if :new.location_id is null then
                raise exp;
            end if;
        end if;
    
        exception
            when exp then 
                raise_application_error (-20002, 'Nu puteti avea in campul location_id un id null!');
    end;
    /
    
drop trigger trg2_adi;

update departments
set location_id = null;

insert into departments
values(1,'Nume',null,null);

insert into departments
values(1,'Nume',null,1700);

rollback;