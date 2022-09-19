--EX1 CURS
create or replace package pachet_adi as

--                    OBIECT_1_nov_2021_curs
--                    |                    |
--                  RECORD               RECORD
--                  |    |               |     |
--      TABLOU_INDEXAT   REGIUNE PERIOA_CALAT  CURSOR_CU_PARAMETRU(MNG_ID)
--              |
--           RECORD
--           |    |
--      RECORD    ORAS
--      |   |
--PERIOADA  COST

-- OBIECT_1_nov_2021_curs descrie o calatorie de afaceri specifica unui anumit angajat

    cursor c(mng_id employees.employee_id%type)return employees%rowtype;
        
    type perioada_calatori is record(
        perioada_calat number,
        end_calatorie date);
        
    type perioada_petrecuta_cost is record(
        perioada_petrecuta number(10),
        cost_generat number(10));
        
    type perioada_petrecuta_cost_oras is record(
        val perioada_petrecuta_cost,
        oras locations.city%type);
        
    TYPE tip_tablou_index_orase_cost_perioada IS TABLE OF
        perioada_petrecuta_cost_oras INDEX BY PLS_INTEGER;
        
    type tip_tablou_index_orase_cost_perioada_regiune is record(
        val tip_tablou_index_orase_cost_perioada,
        regiune regions.region_name%type);
    
    
    
--                  OBIECT_15_nov_2021
--                  |                |
--      CURSOR_DINAMIC_1        CURSOR_DINAMIC_2
    
    type CURSOR_DINAMIC_1 is ref cursor return employees%rowtype;
    
    type CURSOR_DINAMIC_2 is ref cursor return departments%rowtype;
    
    end pachet_adi;
/    

/*create or replace type OBIECT_1_nov_2021_curs is object 
    (pachet_adi.v_tip_tablou_index_orase_cost_perioada_regiune tip_tablou_index_orase_cost_perioada_regiune,
    pachet_adi.v_perioada_calatori perioada_calatori);
    /*/



--EX2 CURS
create table log_adi(
    id number(10),
    old_value_id varchar2(15),
    new_value_id varchar2(15),
    tip_op varchar2(15),
    moment_efectuare date default sysdate,
    who varchar2(10));

drop table log_adi;


create sequence  "UTILIZATOR"."SEC_ADI_LOG"  
minvalue 1 maxvalue 999999999999999999999999999 
increment by 1 start with 1 
cache 20 noorder  nocycle  nokeep  noscale  global;

drop sequence sec_adi_log;

create sequence  "UTILIZATOR"."SEC_ADI"  
minvalue 1 maxvalue 999999999999999999999999999 
increment by 1 start with 227 
cache 20 noorder  nocycle  nokeep  noscale  global;

drop sequence sec_adi;

create or replace trigger t
  after
    insert or
    update or
    delete
  on emp_adi
  for each row
begin
  case
    when INSERTING then
      insert into log_adi(id, old_value_id, new_value_id, tip_op, moment_efectuare) 
      values(SEC_ADI_LOG.nextval, 'null', :new.employee_id, 'insert', sysdate);
      update log_adi set who = (select user from dual) where id =(select max(id) from log_adi);
    when UPDATING then
      insert into log_adi(id, old_value_id, new_value_id, tip_op, moment_efectuare) 
      values(SEC_ADI_LOG.nextval, :old.employee_id, :new.employee_id, 'update', sysdate);
      update log_adi set who = (select user from dual) where id =(select max(id) from log_adi);
    when DELETING then
      insert into log_adi(id, old_value_id, new_value_id, tip_op, moment_efectuare) 
      values(SEC_ADI_LOG.nextval, :old.employee_id, 'null', 'delete', sysdate);
      update log_adi set who = (select user from dual) where id =(select max(id) from log_adi);
  end case;
end;
/

drop trigger t;

insert into emp_adi values(SEC_ADI.nextval, 'P', 'N', 'PN', '07xxxxxxx', sysdate, 'j', 1010, null, null, null);
update emp_adi set salary = 1011 where employee_id = 227;
delete from emp_adi where employee_id=227;

select * from emp_adi where first_name='P';
select * from emp_adi order by employee_id ;



select * from log_adi;
rollback; 

describe emp_adi;

select * from emp_adi;