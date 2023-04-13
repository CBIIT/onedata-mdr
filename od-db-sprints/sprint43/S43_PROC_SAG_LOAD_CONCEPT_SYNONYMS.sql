--DSRMWS-2436 Set Synonyms Language to "ENGLISH", ID is 1000
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
    LANG_ID, --ENGLISH
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
     1000,
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
--DSRMWS-2436 Concepts Synonym and Prior Preferred Name English Language
alter table ALT_NMS disable all triggers;
MERGE INTO ALT_NMS t1
USING
(
SELECT item_id, ver_nr FROM ADMIN_ITEM where
ADMIN_ITEM_TYP_ID = 49 --Concept
and cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
)t2
ON (t1.item_id = t2.item_id
and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.LANG_ID = 1000 --ENGLISH
where t1.LANG_ID is null
and t1.NM_TYP_ID in (1064, 1049) --Synonym or Prior Preferred Name
and t1.CNTXT_ITEM_ID = 20000000024
and t1.CNTXT_VER_NR = 1
;
commit;
alter table ALT_NMS enable all triggers;
--DSRMWS-2436 Concepts Prior Preferred Definition English Language
alter table ALT_DEF disable all triggers;
MERGE INTO ALT_DEF t1
USING
(
SELECT item_id, ver_nr FROM ADMIN_ITEM where
ADMIN_ITEM_TYP_ID = 49 --Concept
and cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
)t2
ON (t1.item_id = t2.item_id
and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.LANG_ID = 1000 --ENGLISH
where t1.LANG_ID is null
and t1.NCI_DEF_TYP_ID = 1357 -- Prior Preferred Definition
;
commit;
alter table ALT_DEF enable all triggers;
--on SBR schema DESIGNATIONS table to reflect ENGLISH related changes
--SBR.DESIGNATIONS all triggers have been disabled on cloud schema
MERGE INTO SBR.DESIGNATIONS t1
USING
(
SELECT NCI_IDSEQ FROM ONEDATA_WA.ALT_NMS where
cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
and LANG_ID = 1000
and NM_TYP_ID in (1064, 1049) --Synonym or Prior Preferred Name
)t2
ON (t1.DESIG_IDSEQ = t2.NCI_IDSEQ)
WHEN MATCHED THEN UPDATE SET
t1.LAE_NAME = 'ENGLISH'
where t1.LAE_NAME is null;
commit;
--on SBR schema DEFINITIONS table to reflect ENGLISH related changes
--SBR.DEFINITIONS all triggers have been disabled on cloud schema
MERGE INTO SBR.DEFINITIONS t1
USING
(
SELECT NCI_IDSEQ FROM ONEDATA_WA.ALT_DEF where
cntxt_item_id = 20000000024 -- context NCIP
and cntxt_ver_nr = 1
and LANG_ID = 1000
and NCI_DEF_TYP_ID = 1357
)t2
ON (t1.DEFIN_IDSEQ = t2.NCI_IDSEQ)
WHEN MATCHED THEN UPDATE SET
t1.LAE_NAME = 'ENGLISH'
where t1.LAE_NAME is null
;
commit;
