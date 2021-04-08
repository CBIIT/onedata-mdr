CREATE OR REPLACE FUNCTION ALS_DraftFieldName (P_ID NUMBER,P_VER in number) RETURN VARCHAR2
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

