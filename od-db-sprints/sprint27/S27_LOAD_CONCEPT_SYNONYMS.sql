create or replace Procedure SAG_LOAD_CONCEPT_SYNONYMS 
(p_NM_DESC IN VARCHAR2,
V_ITEM_ID IN NUMBER,
V_VER_NR IN NUMBER,
V_CREAT_USR_ID IN VARCHAR2,
V_CREAT_DT IN DATE, 
V_LST_UPD_USR_ID IN VARCHAR2, 
V_LST_UPD_DT IN  DATE)
AS
--DECLARE
V_NM_DESC VARCHAR2 (8000);
V_IDSEQ CHAR(36 BYTE);
TYPE T_syn_name IS TABLE OF VARCHAR2 (2000);--nested table type for synonyms names

arr_full    T_syn_name := T_syn_name (); -- table type for synonyms
arr_clean   T_syn_name := T_syn_name ();
BEGIN
     V_NM_DESC := p_NM_DESC;
     --DBMS_OUTPUT.PUT_LINE('p_NM_DESC ' || p_NM_DESC);
     --DBMS_OUTPUT.PUT_LINE('V_ITEM_ID ' || V_ITEM_ID);
     --DBMS_OUTPUT.PUT_LINE('V_VER_NR ' || V_VER_NR);
     --DBMS_OUTPUT.PUT_LINE('V_CREAT_USR_ID ' ||V_CREAT_USR_ID);
     --DBMS_OUTPUT.PUT_LINE('V_CREAT_DT ' ||V_CREAT_DT);    
     --DBMS_OUTPUT.PUT_LINE('V_LST_UPD_USR_ID ' ||V_LST_UPD_USR_ID);  
     --DBMS_OUTPUT.PUT_LINE('V_LST_UPD_DT ' ||V_LST_UPD_DT);
-- For performance triggers shall be disabled : TR_ALT_NMS_POST TR_NCI_ALT_NMS_DENORM_INS
-- This is done when called from SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG
--create an nested table of synonyms
FOR record IN (
select 
     regexp_substr (V_NM_DESC, '[^|]+', 1, rn) as splited
     from dual
     cross
     join (select rownum as rn
              from (select length (regexp_replace(V_NM_DESC, '[^|]+')) + 1 as mx from dual
          )
     connect by level <= mx)
)
LOOP
   arr_full.EXTEND;
   arr_full (arr_full.LAST) := substr(record.splited,1, 2000);
END LOOP; --table of synonyms created
-- create Alternate names from flat table concepts synonyms splitted by '|'
-- TODO check that the synonym does not exist before insert
IF arr_full IS NOT empty THEN
   -- same array into array 2
   arr_clean := arr_full;

   -- Identify distinct and return to main arr_full
   arr_full := arr_full MULTISET UNION DISTINCT arr_clean;

FOR idx_arr IN arr_full.FIRST .. arr_full.LAST
   LOOP
   BEGIN
   select NCI_IDSEQ into V_IDSEQ from ALT_NMS
   where NM_TYP_ID = 1064
   and CNTXT_ITEM_ID = 20000000024 and CNTXT_VER_NR = 1
   and ITEM_ID = V_ITEM_ID and VER_NR = V_VER_NR
   and NM_DESC = arr_full(idx_arr);
EXCEPTION 
WHEN no_data_found THEN
INSERT INTO /*+ APPEND */ ALT_NMS (NM_DESC,
     NM_TYP_ID,
     -- NCI_IDSEQ, --newly generated value
     -- LANG_ID,
    CNTXT_ITEM_ID, --trigger 20000000024 NCIP
    CNTXT_VER_NR,
    CNTXT_NM_DN,
     -- UNTL_DT,
     -- PREF_NM_IND
     ITEM_ID, --AI reference
     VER_NR, --AI reference
     CREAT_USR_ID,
     CREAT_DT,
     LST_UPD_USR_ID,
     LST_UPD_DT
     )
VALUES (arr_full(idx_arr),
     1064,--'Synonym',
     20000000024, 1, 'NCIP',
     V_ITEM_ID, V_VER_NR,
     V_CREAT_USR_ID,
     V_CREAT_DT,
     V_LST_UPD_USR_ID,
     V_LST_UPD_DT);
WHEN OTHERS THEN
NULL;
END;
END LOOP; --INSERT
END IF; --arr_full
commit;
END;
/