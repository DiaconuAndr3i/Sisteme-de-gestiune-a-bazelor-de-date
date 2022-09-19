--PB5 PLSQL4
create or replace procedure pb5_adi(yes_no_job_history boolean)
    is
cursor id_nume_dep is
    select department_id, department_name from 
    departments;
    
cursor zi_nr_dep(cod_dep number) is
    select zi, nr from
    (select to_char(hire_date,'d') zi, count(*) nr
    from employees
    where department_id = cod_dep
    group by to_char(hire_date,'d')
    order by count(*) desc)
    where rownum <= 1;
    
cursor lista_nume_vechime_venit(zi number, cod_dep number) is
    select employee_id, last_name, first_name, round(sysdate-hire_date) vechime, salary + salary * nvl(commission_pct,0)  venit
    from employees
    where to_char(hire_date,'d') = zi and department_id = cod_dep;
    
    
cursor history_id_vechime(zi number, cod_dep number) is
    select employee_id, sum(round(end_date-start_date)) vechime
    from job_history
    where to_char(start_date,'d') = zi and department_id = cod_dep
    group by employee_id;
        
ok boolean:=false;

maxim_nr number(10);
maxim_zi number(1);
ct boolean := false;
suma number(10);
        
function history_zi_nr_dep(cod_dep number, val boolean)
        return number
        is
        result_zi number;
        result_nr number;
        verificare number;
        begin
        
        select count(*) 
        into verificare
        from(
            select department_id from job_history
            intersect
            select department_id from job_history where department_id = cod_dep);
        if verificare = 0 then
            return -1;
        end if;
        
        select zi, nr into
        result_zi, result_nr
        from
        (select to_char(start_date,'d') zi, count(*) nr
        from job_history
        where department_id = cod_dep
        group by to_char(start_date,'d')
        order by count(*) desc)
        where rownum <= 1;
        
        if val = true then
            return result_zi;
        else 
            return result_nr; 
        end if;
        
        end history_zi_nr_dep;        

begin    
    for item in id_nume_dep loop
        dbms_output.put_line('Departamentul '||item.department_name);
        dbms_output.put_line('----------------------------');
        for i in zi_nr_dep(item.department_id) loop 
            if yes_no_job_history = true then
                if i.nr >= history_zi_nr_dep(item.department_id, false) then
                    maxim_nr := i.nr;
                    maxim_zi := i.zi;
                else
                    maxim_nr := history_zi_nr_dep(item.department_id, false);
                    maxim_zi := history_zi_nr_dep(item.department_id, true);
                end if;
            else 
                maxim_nr := i.nr;
                maxim_zi := i.zi;
            end if;
            ok := true;
            dbms_output.put_line('Ziua din saptamana cu cele mai multe angajari este: '||maxim_zi);
            dbms_output.put_line('___________________________________________________');
            if yes_no_job_history = true then
                for j in lista_nume_vechime_venit(maxim_zi, item.department_id) loop
                    for k in history_id_vechime(maxim_zi, item.department_id) loop
                        if j.employee_id = k.employee_id then
                            ct := true;
                            suma := j.vechime + k.vechime;
                            dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||suma||' de zile si un venit lunar actual de '||j.venit||' *');
                        end if;
                    end loop;
                    if ct = false then
                        dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||j.vechime||' de zile si un venit lunar de '||j.venit);
                    end if;
                    ct := false;
                end loop;
            else
                for j in lista_nume_vechime_venit(maxim_zi, item.department_id) loop
                    dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||j.vechime||' de zile si un venit lunar de '||j.venit);
                end loop;
            end if;
        end loop;
        if ok = false then
            dbms_output.put_line('Niciun angajat in departament!');
        end if;
        ok := false;
        dbms_output.new_line;
        dbms_output.new_line;
        
    end loop;

end pb5_adi;
/
     

begin
    -- pb5_adi(false) netinand cont de istoric
    -- pb5_adi(true) tinand cont de istoric
    -- marchez cu * modificarile aparute pentru "true"
    pb5_adi(true);
end;
/


















--PB6 PLSQL4
create or replace procedure pb5_adi(yes_no_job_history boolean)
    is
    
-- cursor pentru id si nume departamente
cursor id_nume_dep is
    select department_id, department_name from 
    departments;

-- cursor pentru ziua si numarul in care s-au angajat cei mai multi  (B)
cursor zi_nr_dep(cod_dep number) is
    select zi, nr from
    (select to_char(hire_date,'d') zi, count(*) nr
    from employees
    where department_id = cod_dep
    group by to_char(hire_date,'d')
    order by count(*) desc)
    where rownum <= 1;
 
-- cursor id, nume, prenume, vechime, venit din tabela employees  (A) 
cursor lista_nume_vechime_venit(zi number, cod_dep number) is
    select employee_id, last_name, first_name, round(sysdate-hire_date) vechime, salary + salary * nvl(commission_pct,0)  venit
    from employees
    where to_char(hire_date,'d') = zi and department_id = cod_dep;
    
-- asemanator ca la (A) dar pe tabela job_history
cursor history_id_vechime(zi number, cod_dep number) is
    select employee_id, sum(round(end_date-start_date)) vechime
    from job_history
    where to_char(start_date,'d') = zi and department_id = cod_dep
    group by employee_id;
        
ok boolean:=false;
maxim_nr number(10);
maxim_zi number(1);
ct boolean := false;
suma number(10);
iterator integer := 0;

-- definesc o inregistrare unde voi salva informatiile specifice angajatilor
type inregistrare is record(
        nume employees.last_name%type,
        prenume employees.first_name%type,
        vechime number(10),
        venit_lunar number(10,2),
        yes_no_history boolean
        );

-- tablou indexat de inregistrari definite mai sus
type tablou_indexat is table of inregistrare index by binary_integer;
t tablou_indexat;

-- functie ce returneaza ziua in care au inceput lucrul cei mai multi dintre angajati pentru istoricul joburilor lor (C)   
function history_zi_nr_dep(cod_dep number, val boolean)
        return number
        is
        result_zi number;
        result_nr number;
        verificare number;
        begin
        
        select count(*) 
        into verificare
        from(
            select department_id from job_history
            intersect
            select department_id from job_history where department_id = cod_dep);
        if verificare = 0 then
            return -1;
        end if;
        
        select zi, nr into
        result_zi, result_nr
        from
        (select to_char(start_date,'d') zi, count(*) nr
        from job_history
        where department_id = cod_dep
        group by to_char(start_date,'d')
        order by count(*) desc)
        where rownum <= 1;
        
        if val = true then
            return result_zi;
        else 
            return result_nr; 
        end if;
        
        end history_zi_nr_dep;
    
-- procedura ce va sorta clasic tabloul indexat 
procedure top(t in out tablou_indexat)
is 
    v_top integer := 1;
    v_old number(10);
    v_new number(10);
    type inregistrare is record(
        nume employees.last_name%type,
        prenume employees.first_name%type,
        vechime number(10),
        venit_lunar number(10,2),
        yes_no_history boolean
        );
    rec inregistrare;
begin
    for i in 1..t.count-1 loop
        for j in i+1..t.count loop
            if t(i).vechime > t(j).vechime then
                rec.nume := t(i).nume;
                rec.prenume := t(i).prenume;
                rec.vechime := t(i).vechime;
                rec.venit_lunar := t(i).venit_lunar;
                rec.yes_no_history := t(i).yes_no_history;
                t(i).nume := t(j).nume;
                t(i).prenume := t(j).prenume;
                t(i).vechime := t(j).vechime;
                t(i).venit_lunar := t(j).venit_lunar;
                t(i).yes_no_history := t(j).yes_no_history;
                t(j).nume := rec.nume;
                t(j).prenume := rec.prenume;
                t(j).vechime := rec.vechime;
                t(j).venit_lunar := rec.venit_lunar;
                t(j).yes_no_history := rec.yes_no_history;
            end if;
        end loop;
    end loop;
    
    v_old := t(1).vechime;
    dbms_output.put_line('Locul '||v_top||':');
    for i in 1..t.count loop
    v_new := t(i).vechime;
    if v_old != v_new then
        v_top := v_top + 1;
        v_old := v_new;
        dbms_output.put_line('Locul '||v_top||':');
    end if;
    if t(i).yes_no_history = true then
        dbms_output.put_line(t(i).nume||' '||t(i).prenume||' are o vechime de aproximativ '||t(i).vechime||
        ' de zile si un venit lunar de '||t(i).venit_lunar||' *');
    else
        dbms_output.put_line(t(i).nume||' '||t(i).prenume||' are o vechime de aproximativ '||t(i).vechime||
    ' de zile si un venit lunar de '||t(i).venit_lunar);
    end if;
    end loop;

end top;

begin    
    for item in id_nume_dep loop
        dbms_output.put_line('Departamentul '||item.department_name);
        dbms_output.put_line('----------------------------');
        for i in zi_nr_dep(item.department_id) loop
            -- identific maximul dintre interogarile furnizate de (B) si (C) astfel am maximul general
            if yes_no_job_history = true then
                if i.nr >= history_zi_nr_dep(item.department_id, false) then
                    maxim_nr := i.nr;
                    maxim_zi := i.zi;
                else
                    maxim_nr := history_zi_nr_dep(item.department_id, false);
                    maxim_zi := history_zi_nr_dep(item.department_id, true);
                end if;
            else 
                maxim_nr := i.nr;
                maxim_zi := i.zi;
            end if;
            ok := true;
            dbms_output.put_line('Ziua din saptamana cu cele mai multe angajari este: '||maxim_zi);
            dbms_output.put_line('___________________________________________________');
            -- in functie daca vreau sa tin cont de istoric sau nu 
            if yes_no_job_history = true then
                for j in lista_nume_vechime_venit(maxim_zi, item.department_id) loop
                    for k in history_id_vechime(maxim_zi, item.department_id) loop
                        if j.employee_id = k.employee_id then
                            ct := true;
                            suma := j.vechime + k.vechime;
                            iterator := iterator + 1;
                            t(iterator).nume := j.last_name;
                            t(iterator).prenume := j.first_name;
                            t(iterator).vechime := suma;
                            t(iterator).venit_lunar := j.venit;
                            t(iterator).yes_no_history := true;
                            --dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||suma||' de zile si un venit lunar actual de '||j.venit||' *');
                        end if;
                    end loop;
                    if ct = false then
                        iterator := iterator + 1;
                        t(iterator).nume := j.last_name;
                        t(iterator).prenume := j.first_name;
                        t(iterator).vechime := j.vechime;
                        t(iterator).venit_lunar := j.venit;
                        t(iterator).yes_no_history := false;
                        --dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||j.vechime||' de zile si un venit lunar de '||j.venit);
                    end if;
                    ct := false;
                end loop;
                top(t);
                -- eliberez tabloul indexat pentru a nu aparea eventuale coliziuni nedorite
                t.delete(t.first,t.last);
                -- resetez si iteratorul
                iterator := 0;
            else
                for j in lista_nume_vechime_venit(maxim_zi, item.department_id) loop
                    iterator := iterator + 1;
                    t(iterator).nume := j.last_name;
                    t(iterator).prenume := j.first_name;
                    t(iterator).vechime := j.vechime;
                    t(iterator).venit_lunar := j.venit;
                    t(iterator).yes_no_history := false;
                    --dbms_output.put_line(j.last_name||' '||j.first_name||' are o vechime de aproximativ '||j.vechime||' de zile si un venit lunar de '||j.venit);
                end loop;
                top(t);
                t.delete(t.first,t.last);
                iterator := 0;
            end if;
        end loop;
        if ok = false then
            dbms_output.put_line('Niciun angajat in departament!');
        end if;
        ok := false;
        dbms_output.new_line;
        dbms_output.new_line;
        
    end loop;

end pb5_adi;
/
     

begin
    -- pb5_adi(false) netinand cont de istoric
    -- pb5_adi(true) tinand cont de istoric
    -- marchez cu * modificarile aparute pentru "true"
    pb5_adi(true);
end;
/
