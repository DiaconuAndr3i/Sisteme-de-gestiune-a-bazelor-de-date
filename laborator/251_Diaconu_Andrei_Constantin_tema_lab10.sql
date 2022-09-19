-- PB1-complet PLSQL5
set serveroutput on;

create sequence  "UTILIZATOR"."SEC_ADI"  
minvalue 1 maxvalue 999999999999999999999999999 
increment by 1 start with 227 
cache 20 noorder  nocycle  nokeep  noscale  global;

drop sequence sec_adi;

create or replace package pb5_pachet_adi as
    cursor pct_f(cod_job emp_adi.job_id%type) return employees%rowtype;
    
    cursor pct_g return jobs%rowtype;
    
    function pct_a_cod_dep(nume_dep dept_adi.department_name%type)
    return number;
    
    function pct_a_cod_job(nume_job jobs.job_title%type)
    return jobs.job_id%type;
    
    function pct_a_cod_mng(nume emp_adi.last_name%type,
    prenume emp_adi.first_name%type) return number;
    
    function pct_a_salariu(nume_dep dept_adi.department_name%type, 
    nume_job jobs.job_title%type) return number;
    
    procedure pct_a(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type,
        telefon emp_adi.phone_number%type,
        email emp_adi.email%type,
        nume_dep dept_adi.department_name%type,
        nume_job jobs.job_title%type,
        nume_mng emp_adi.last_name%type,
        prenume_mng emp_adi.first_name%type);
        
    procedure pct_b(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type,
        nume_dep dept_adi.department_name%type,
        nume_mng emp_adi.last_name%type,
        prenume_mng emp_adi.first_name%type);
    
    function pct_c(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type) return number;
        
    procedure pct_d(cod_angajat emp_adi.employee_id%type);
    
    procedure pct_e(nume emp_adi.last_name%type, 
        salariu emp_adi.salary%type);
        
    procedure pct_h;
    
end pb5_pachet_adi;
/

create or replace package body pb5_pachet_adi as
    cursor pct_f(cod_job emp_adi.job_id%type) return employees%rowtype
        is
        select *
        from emp_adi
        where job_id = cod_job;
        
    cursor pct_g return jobs%rowtype
    is
    select * 
    from jobs;

    function pct_a_cod_dep(nume_dep dept_adi.department_name%type)
    return number is
    cod_dep_local dept_adi.department_id%type;
    ct number;
    exp exception;
    begin
        select count(*)
        into ct
        from dept_adi 
        where lower(trim(department_name)) = lower(trim(nume_dep));
        
        if ct = 0 then 
            raise exp;
        end if;
        
        select department_id
        into cod_dep_local
        from dept_adi
        where lower(trim(department_name)) = lower(trim(nume_dep));
        return cod_dep_local;
        
        exception
            when exp then return -1;
    end;
    
    function pct_a_cod_job(nume_job jobs.job_title%type)
    return jobs.job_id%type is
    cod_job_local jobs.job_id%type;
    ct number;
    exp exception;
    er varchar2(10) := '-1';
    begin
        select count(*)
        into ct
        from jobs 
        where lower(trim(job_title)) = lower(trim(nume_job));
        
        if ct = 0 then 
            raise exp;
        end if;
    
        select job_id
        into cod_job_local
        from jobs
        where lower(trim(job_title)) = lower(trim(nume_job));
        return cod_job_local;
        
        exception
            when exp then return er;
    end;
    
    function pct_a_cod_mng(nume emp_adi.last_name%type,
    prenume emp_adi.first_name%type) return number is
    cod_mng_local emp_adi.manager_id%type;
    ct number;
    exp exception;
    begin
        select count(*)
        into ct
        from emp_adi
        where
            lower(trim(last_name)) = lower(trim(nume))
            and
            lower(trim(first_name)) = lower(trim(prenume));
        
        if ct = 0 then 
            raise exp;
        end if;
    
        select employee_id
        into cod_mng_local
        from emp_adi
        where 
            lower(trim(last_name)) = lower(trim(nume))
            and
            lower(trim(first_name)) = lower(trim(prenume));
        return cod_mng_local;
        
        exception
            when exp then return -1;
    end;
    
    function pct_a_salariu(nume_dep dept_adi.department_name%type, 
    nume_job jobs.job_title%type) return number is
    salariu emp_adi.salary%type;
    ct number;
    exp exception;
    begin
        select count(*)
        into ct
        from emp_adi
        where department_id = pct_a_cod_dep(nume_dep) and job_id = pct_a_cod_job(nume_job);
        
        if ct = 0 then
            raise exp;
        end if;
    
        select min(salary)
        into salariu
        from emp_adi
        where department_id = pct_a_cod_dep(nume_dep) and job_id = pct_a_cod_job(nume_job);
        return salariu;
        
        exception
            when exp then return -1;
    end;
    
    procedure pct_a(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type,
        telefon emp_adi.phone_number%type,
        email emp_adi.email%type,
        nume_dep dept_adi.department_name%type,
        nume_job jobs.job_title%type,
        nume_mng emp_adi.last_name%type,
        prenume_mng emp_adi.first_name%type) is
        cod_dep dept_adi.department_name%type;
        exp_cod_dep exception;
        cod_job jobs.job_id%type;
        exp_cod_job exception;
        cod_mng emp_adi.manager_id%type;
        exp_cod_mng exception;
        salariu emp_adi.salary%type;
        exp_salariu exception;
        begin
            cod_dep := pct_a_cod_dep(nume_dep);
            if cod_dep = -1 then
                raise exp_cod_dep;
            end if;
            
            cod_job := pct_a_cod_job(nume_job);
            if cod_job = '-1' then
                raise exp_cod_job;
            end if;
            
            cod_mng := pct_a_cod_mng(nume_mng, prenume_mng);
            if cod_mng = -1 then
                raise exp_cod_mng;
            end if;
                
            salariu := pct_a_salariu(nume_dep, nume_job);
            if salariu = -1 then 
                raise exp_salariu;
            end if;
            
            insert into emp_adi
            values(SEC_ADI.nextval, prenume, nume, email, telefon, sysdate, cod_job, salariu, null, cod_mng, cod_dep);
            dbms_output.put_line('Inregistrare efectuata cu succes!');
                
            exception
                when exp_cod_dep then 
                    dbms_output.put_line('Departamentul cu numele '||nume_dep||' nu exista!');
                when exp_cod_job then 
                    dbms_output.put_line('Job-ul cu numele '||nume_job||' nu exista!');
                when exp_cod_mng then 
                    dbms_output.put_line('Managerul cu numele '||nume_mng||' si prenumele '||prenume_mng||' nu exista!');
                when exp_salariu then
                    dbms_output.put_line('Job-ul cu numele '||nume_job||' nu se afla in departamentul '||nume_dep);
        end;
        
        procedure pct_b(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type,
        nume_dep dept_adi.department_name%type,
        nume_mng emp_adi.last_name%type,
        prenume_mng emp_adi.first_name%type) is
        cod_dep dept_adi.department_name%type;
        exp_cod_dep exception;
        cod_job jobs.job_id%type;
        exp_cod_job exception;
        cod_mng emp_adi.manager_id%type;
        exp_cod_mng exception;
        nume_job jobs.job_title%type;
        salariu emp_adi.salary%type;
        sal_curent salariu%type;
        comision emp_adi.commission_pct%type;
        hist_id emp_adi.employee_id%type;
        hist_start_date emp_adi.hire_date%type;
        hist_job_id emp_adi.job_id%type;
        hist_department_id emp_adi.department_id%type;
        ct number;
        fara_angajat exception;
        begin
            select count(*)
            into ct
            from employees
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            
            if ct = 0 then
                raise fara_angajat;
            end if;
        
            cod_dep := pct_a_cod_dep(nume_dep);
            if cod_dep = -1 then
                raise exp_cod_dep;
            end if;
            
            select job_title
            into nume_job
            from jobs j, employees e
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume))
            and e.job_id = j.job_id;
            
            cod_job := pct_a_cod_job(nume_job);
            if cod_job = '-1' then
                raise exp_cod_job;
            end if;
            
            cod_mng := pct_a_cod_mng(nume_mng, prenume_mng);
            if cod_mng = -1 then
                raise exp_cod_mng;
            end if;
            
            select min(salary)
            into salariu 
            from emp_adi 
            where job_id = cod_job and department_id = cod_dep;
            
            select salary
            into sal_curent
            from emp_adi
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            
            if sal_curent > nvl(salariu,0) then
                salariu := sal_curent;
            end if;
            
            select min(commission_pct)
            into comision
            from emp_adi
            where job_id = cod_job and department_id = cod_dep;
            
            select employee_id, hire_date, job_id, department_id
            into hist_id, hist_start_date, hist_job_id, hist_department_id
            from emp_adi
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            
            insert into job_history
            values(hist_id, hist_start_date, sysdate, hist_job_id, hist_department_id);
            dbms_output.put_line('Inregistarare efectuata cu succes');
            
            update emp_adi
            set department_id = cod_dep, job_id = cod_job, 
            manager_id = cod_mng, salary = salariu, 
            commission_pct = comision, hire_date = sysdate
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            dbms_output.put_line('Update efectuat cu succes');

            
            exception
                when exp_cod_dep then 
                    dbms_output.put_line('Departamentul cu numele '||nume_dep||' nu exista!');
                when exp_cod_job then 
                    dbms_output.put_line('Job-ul cu numele '||nume_job||' nu exista!');
                when exp_cod_mng then 
                    dbms_output.put_line('Managerul cu numele '||nume_mng||' si prenumele '||prenume_mng||' nu exista!');
                when fara_angajat then 
                    dbms_output.put_line('Nu exista angajat cu numele '||nume||' si prenumele '||prenume);
        end;
        
        function pct_c(prenume emp_adi.first_name%type, 
        nume emp_adi.last_name%type) return number
        is
        contor number;
        id emp_adi.employee_id%type;
        nr number;
        exp exception;
        begin
            select count(*)
            into nr
            from emp_adi
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            
            if nr = 0 then
                raise exp;
            end if;
            
            select employee_id
            into id
            from emp_adi
            where lower(trim(first_name)) = lower(trim(prenume)) and lower(trim(last_name)) = lower(trim(nume));
            
            select count(*)
            into contor
            from employees
            where manager_id is not null
            start with employee_id = id
            connect by prior employee_id = manager_id;
            
            return contor;
            
            exception
                when exp then 
                dbms_output.put_line('Nu exista un angajat cu numele si prenumele dat!');
                return -1;
        end;
        
        procedure pct_d(cod_angajat emp_adi.employee_id%type) is
        type tablou_indexat is table of emp_adi.employee_id%type index by binary_integer;
        t tablou_indexat;
        t1 tablou_indexat;
        cod_mng_mng emp_adi.manager_id%type;
        dep_id emp_adi.department_id%type;
        dep_mng emp_adi.department_id%type;
        level_angajat number;
        ct1 number;
        exp1 exception;
        exp2 exception;
        exp3 exception;
        manager_angajat emp_adi.manager_id%type;
        begin
        
-- Angajatul va fi promovat pe o treapta imediat superioara in departament, doar daca exista aceasta
-- (deci este obligatoriu ca managerul sau curent sa fie in acelasi departament cu el)
-- Daca este manager general(King Steven in cazul acesta) nu mai putem sa-l promovam
-- Daca exista posibilitatea de promovare, verificam daca are subalterni pentru a putea restructura arborele
-- Daca nu are atunci promovam si ne oprim
-- Daca are, cautam un coleg al angajatului curent care sa devina manager pentru subalternii acestuia
-- Daca exista acest coleg, atunci toti subalternii angajatului vor fi condusi in continuare de acest coleg
-- Daca nu exista acest coleg, promovam un angajat din acesti subalterni (l-am ales pe primul din lista pentru a nu mai adauga un
-- criteriu suplimentar de alegere)
-- pe postul ramas liber odata cu 
-- promovarea angajatului dat iar ceilalti subalterni daca mai sunt vor devei subalterni ai noului lor manager
        
        
        
        
        
        -- departamaentul in care lucreaza angajatul dat
            select department_id
            into dep_id
            from emp_adi
            where employee_id = cod_angajat;
            
            if dep_id is null then
                raise exp1;
            end if;
            
            select manager_id
            into manager_angajat
            from emp_adi where
            employee_id = cod_angajat;
            
            if manager_angajat is null then
                raise exp2;
            end if;
            
        --verificam daca managerul sau este din acelasi departament
            select department_id 
            into dep_mng
            from emp_adi
            where employee_id =
            (select manager_id from emp_adi where
            employee_id = cod_angajat);
            
            if dep_mng != dep_id then
                raise exp2;
            end if;
        
        -- managerul managerului angajatului dat
            select count(*)
            into ct1
            from emp_adi e1, emp_adi e2
            where
            e1.manager_id = e2.employee_id
            and e1.employee_id = cod_angajat;
            
            if ct1 = 0 then
                raise exp3;
            end if;
            
            select e2.manager_id
            into cod_mng_mng
            from emp_adi e1, emp_adi e2
            where
            e1.manager_id = e2.employee_id
            and e1.employee_id = cod_angajat;
            
            -- stocam toti subalternii directi ai angajatului dat care sunt direct influentati de schimbarea
            -- pozitiei in departament a acestuia
            select employee_id
            bulk collect into t
            from employees
            where level = 2
            start with employee_id = cod_angajat
            connect by prior employee_id = manager_id;
            
            -- nivelul pe care se afla angajatul dat in departamentul sau raportat la arborele genaral al companiei
            select level
            into level_angajat
            from emp_adi
            where department_id = dep_id and employee_id = cod_angajat
            start with employee_id = (select employee_id from emp_adi where manager_id is null)
            connect by prior employee_id = manager_id; 
            
            -- salvam toti angajati care ocupa acelasi nivel cu angajatul dat (daca exista)
            select employee_id
            bulk collect into t1
            from emp_adi
            where department_id = dep_id and employee_id != cod_angajat and level = level_angajat
            start with employee_id = (select employee_id from emp_adi where manager_id is null)
            connect by prior employee_id = manager_id;
            
            -- daca angajatul are cel putin un subaltern
            if t.count != 0 then
                -- daca nu exista angajati care se afla pe acelasi nivel cu angajatul dat
                if t1.count = 0 then
                    -- Primul angajat subaltern al angajatului dat este avnasat iar toti ceilalti de la 2 pana la numarul lor
                    -- ii devin subalterni primului
                    update emp_adi
                    set manager_id = (select manager_id from emp_adi where employee_id = cod_angajat)
                    where employee_id = t(1);
                    
                    for i in t.first+1..t.last loop
                        update emp_adi 
                        set manager_id = t(1)
                        where employee_id = t(i);
                    end loop;

                else 
                dbms_output.new_line;
                -- daca exista cel putin un angajat pe acelasi nivel cu angajatul dat atunci subalternii angajatului dat
                -- devin subalterni ai colegului sau
                    for i in t.first..t.last loop
                        update emp_adi 
                        set manager_id = t1(1)
                        where employee_id = t(i);
                    end loop;
                end if;
            end if;
            -- Promovam angajatul in departament
            update emp_adi
            set manager_id = cod_mng_mng
            where employee_id = cod_angajat;
            
            exception
                when exp1 then
                    dbms_output.put_line('Angajatul nu lucreaza intr-un departament!');
                when exp2 then 
                    dbms_output.put_line('Angajatul nu mai poate fi promovat in departament!');
                when exp3 then 
                    dbms_output.put_line('Angajatul este manager general!');          
        end;
        
        procedure pct_e(nume emp_adi.last_name%type, 
        salariu emp_adi.salary%type) is
        ct_nr_ang number;
        exp1 exception;
        type tablou_indexat is table of emp_adi.employee_id%type index by binary_integer;
        t tablou_indexat;
        ok boolean := false;
        v_ang emp_adi%rowtype;
        
        
        function respecta(cod_ang emp_adi.employee_id%type) return number
        is 
        job_cod emp_adi.job_id%type;
        sal_min_dep emp_adi.salary%type;
        sal_max_dep emp_adi.salary%type;
        begin
            select job_id
            into job_cod
            from emp_adi
            where employee_id = cod_ang;
            
            select min(salary), max(salary)
            into sal_min_dep, sal_max_dep
            from emp_adi
            where job_id = job_cod;
            
            if salariu between sal_min_dep and sal_max_dep then
                return 1;
            end if;
            
            return 0;
        end respecta;
        
        begin
        
            select count(*)
            into ct_nr_ang
            from emp_adi
            where lower(trim(last_name)) = lower(trim(nume));
            
            if ct_nr_ang = 0 then
                raise exp1;
            elsif ct_nr_ang > 1 then
                select employee_id
                bulk collect into t
                from emp_adi
                where lower(trim(last_name)) = lower(trim(nume));
                ok := true;
            end if;
                if ok = true then
                    dbms_output.put_line('Sunt mai multi angajati cu numele '||nume||' lista acestora este:');
                    for i in t.first..t.last loop             
                        
                        /*if respecta(t(i)) = 1 then
                            update emp_adi
                            set salary = salariu
                            where employee_id = t(i);    
                        end if;*/
                        
                        select *
                        into v_ang
                        from emp_adi
                        where employee_id = t(i);
                        
                        dbms_output.put_line(v_ang.employee_id||' '||v_ang.first_name||' '||v_ang.last_name||' '||v_ang.email||' '||
                        v_ang.phone_number||' '||v_ang.hire_date||' '||v_ang.job_id||' '||v_ang.salary||' '||v_ang.commission_pct||' '||
                        v_ang.manager_id||' '||v_ang.department_id);
                    end loop;
                    else
                        select *
                        into v_ang
                        from emp_adi
                        where lower(trim(last_name)) = lower(trim(nume));
                        if respecta(v_ang.employee_id) = 1 then
                            update emp_adi
                            set salary = salariu
                            where employee_id = v_ang.employee_id;    
                        end if;
                        
                        dbms_output.put_line(v_ang.employee_id||' '||v_ang.first_name||' '||v_ang.last_name||' '||v_ang.email||' '||
                        v_ang.phone_number||' '||v_ang.hire_date||' '||v_ang.job_id||' '||v_ang.salary||' '||v_ang.commission_pct||' '||
                        v_ang.manager_id||' '||v_ang.department_id);
                end if;
            
            exception 
                when exp1 then
                    dbms_output.put_line('Nu exista angajatul cu acest nume!');
        end;
        
        procedure pct_h is
        pattern_job jobs%rowtype;
        pattern_emp_adi employees%rowtype;
        trecut number;
        begin
            open pct_g;
            loop
                fetch pct_g into pattern_job;
                exit when pct_g%notfound;
                dbms_output.put_line('Nume job: '||pattern_job.job_title);
                 dbms_output.put_line('------------------------');
                 open pct_f(pattern_job.job_id);
                 loop
                    fetch pct_f into pattern_emp_adi;
                    exit when pct_f%notfound;
                    dbms_output.put_line(pattern_emp_adi.employee_id||' '||pattern_emp_adi.first_name||' '||pattern_emp_adi.last_name||' '||
                        pattern_emp_adi.email||' '||pattern_emp_adi.phone_number||' '||pattern_emp_adi.hire_date||' '||
                        pattern_emp_adi.job_id||' '||pattern_emp_adi.salary||' '||pattern_emp_adi.commission_pct||' '||
                        pattern_emp_adi.manager_id||' '||pattern_emp_adi.department_id); 
                        
                    select count(*)
                    into trecut
                    from job_history
                    where job_id = pattern_job.job_id and employee_id = pattern_emp_adi.employee_id;
                    
                    if trecut = 0 then
                        dbms_output.put_line('Nu a mai avut job-ul.');
                    else 
                        dbms_output.put_line('A avut job-ul in trecut');
                    end if;
                    
                 end loop;
                 close pct_f;
            end loop;
            close pct_g;
        end;
end pb5_pachet_adi;
/


begin
    pb5_pachet_adi.pct_a('PRENUME', 'NUME', 'TELEFON', 'EMAIL', 'Shipping', 'Shipping Clerk', 'Bell', 'Sarah');
    pb5_pachet_adi.pct_b('Julia', 'Dellinger', 'Executive', 'Bissot', 'Laura');
    dbms_output.put_line(pb5_pachet_adi.pct_c('Steven', 'King'));
    pb5_pachet_adi.pct_d(102);
    pb5_pachet_adi.pct_e('Austin', 5000);
    pb5_pachet_adi.pct_h;
end;
/






select * from job_history;
select * from emp_adi;
select * from job_history;
select * from dept_adi;
rollback;


select * from employees where last_name = 'Austin';
select min(salary), max(salary)
from emp_adi
where job_id = 'SA_REP';


select * from jobs;

