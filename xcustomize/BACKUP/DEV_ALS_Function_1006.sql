DROP FUNCTION ONEDATA_WA.ALS_DRAFTFIELDNAME;

CREATE OR REPLACE FUNCTION ONEDATA_WA.ALS_DraftFieldName (P_ID NUMBER,P_VER in number) RETURN VARCHAR2
IS
V_DN VARCHAR2(355);
V_LN VARCHAR2(255);
V_type number;
V_VER varchar(10);
BEGIN
select ADMIN_ITEM_TYP_ID,ITEM_NM into V_type,V_LN from ONEDATA_WA.ADMIN_ITEM where ITEM_ID=P_ID
and VER_NR=P_VER;

V_VER:=to_char(P_ver);

IF instr(V_ver,'.')=0 then
V_ver:=V_ver||'.0';
end if;

IF V_type=4 then 
V_DN :=V_LN||' PID'||P_ID||'_V'||substr (V_VER,1,INSTR(V_VER,'.')-1)||'_'||substr (V_VER,INSTR(V_VER,'.')+1);

ELSIF V_TYPE=54 then
V_DN :='PID'||P_ID||'_V'||substr (V_VER,1,INSTR(V_VER,'.')-1)||'_'||substr (V_VER,INSTR(V_VER,'.')+1);
ELSE

V_DN:='Wrong input';
end if ;

RETURN V_DN;
END;
/


DROP FUNCTION ONEDATA_WA.ALS_LONG_NAME;

CREATE OR REPLACE FUNCTION ONEDATA_WA.ALS_LONG_NAME  (P_LONG_NAME VARCHAR2) RETURN VARCHAR2
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
