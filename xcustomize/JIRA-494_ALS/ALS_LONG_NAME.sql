CREATE OR REPLACE FUNCTION ALS_LONG_NAME  (P_LONG_NAME VARCHAR2) RETURN VARCHAR2
IS
V_LN VARCHAR2(255);
BEGIN
--Repace characters with UPPERCASE characters 
--Replace spaces and other characters:
--  ~ Only underscore characters are permitted
--  ~ Replace space characters with “_”
--  ~ Replace “.” with “_”
--  ~ Replace “/” with “_”
--  ~ Replace “(” with “_”
--  ~ Replace “)” with “_”
--  ~ Replace “-” with “_”
--  ~ Replace “’” with “”
V_LN:= UPPER(TRIM(P_LONG_NAME));
IF instr(V_LN,' ')>0 then
V_LN:= replace(V_LN,' ','_');
end if;

IF instr(V_LN,'''')>0 then
V_LN:= replace(V_LN,'''','');
end if;

IF instr(V_LN,'-')>0 then
V_LN:= replace(V_LN,'-','_');
end if;

IF instr(V_LN,'/')>0 then
V_LN:= replace(V_LN,'/','_');
end if;

IF instr(V_LN,')')>0 then
V_LN:= replace(V_LN,')','_');
end if;

IF instr(V_LN,'(')>0 then
V_LN:= replace(V_LN,'(','_');
end if;

IF instr(V_LN,'.')>0 then
V_LN:= replace(V_LN,'.','_');
end if;

-- IF  INSTR(V_LN,'&'||'#8223;')>0
--THEN
--V_LN:=replace(V_LN,'&'||'#8223;','_');
--END if;
RETURN V_LN;
END;
/