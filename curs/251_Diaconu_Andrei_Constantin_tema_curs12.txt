set serveroutput on;

--ex1)

/*
Structura blocuri
                    bloc
                    |  |
            sub_bloc1  sub_bloc2
                |
        sub-sub-bloc1
*/

declare 
    exp1 exception;
    exp2 exception;
    exp3 exception;
begin
    begin
        begin
            raise exp1;
        exception
            when exp1 then
                dbms_output.put_line('Exceptie prinsa in sub-sub-bloc1 exp1');
                raise exp2;--Arunc exceptie care este prinsa in sub-bloc pentru ca este aruncata in zona de tratare a exceptiilor din sub-sub-bloc
            when exp2 then
                dbms_output.put_line('Exceptie prinsa in sub-sub-bloc1 exp2');
        end;
    -- Nu se executa, exceptia 2 fiind prinsa din sub-sub-bloc si tratata direct
    dbms_output.put_line('Control in sub-bloc1');
    exception
        when exp2 then
            dbms_output.put_line('Exceptie prinsa in sub-bloc1 exp2');
    end;
    dbms_output.put_line('Control in bloc');
    raise exp3; --Arunc exceptie in bloc1 pe care o prind in zona de tratare a exceptiilor blocului
    exception
        when exp3 then
            dbms_output.put_line('Exceptie prinsa in bloc exp3');
    begin
        dbms_output.put_line('Control in sub-bloc2');
        exception
            when exp3 then
            -- Nu poate fi prinsa o exceptie din intr-un bloc consecutiv
                dbms_output.put_line('Exceptie prinsa in sub-bloc2 exp3');
    end;
end;
/



-- ex2)

-- Exceptie predefinita ridicata prin raise
declare
    numar number(5) := &p_numar;
    function modulo(x number, y number)
    return number
    is
    result number;
    begin
        result := x - y * floor(x/y);
        return result;
    end;
begin
    if modulo(numar,2) <> 0 then
        raise invalid_number;
    elsif numar = 0 then
        raise zero_divide;
    end if;
    exception
        when invalid_number then
            dbms_output.put_line('Numarul dat este impar, este necesar un numar par');
        when others then
            dbms_output.put_line('Cod eroare '||sqlcode);
            dbms_output.put_line('Mesaj eroare '||sqlerrm);
end;
/

--Explicatie cu/ fara raise pentru exp predefinite
/*
In cazul exceptiilor predefinite in care se utilizeaza instructiunea raise, aruncarea explicita a erorii
poate produce la randul ei, alte exceptii predefinite
*/

declare 
    nr number:= 10;
begin
    if nr <> 9 then
        raise invalid_number;
    end if;
    
    exception
        when invalid_number then 
            rollback;
end;
/

--Exceptie definita de utilizator
declare
    numar number(5) := &p_numar;
    exp1 exception;
    exp2 exception;
begin
    if numar = 0 then
        raise exp1;
    elsif numar > 0 then
        raise exp2;
    end if;
    exception
        when exp1 then
            dbms_output.put_line('Am prins exceptia 1');
        when exp2 then
            dbms_output.put_line('Am prins exceptia 2');
end;
/


