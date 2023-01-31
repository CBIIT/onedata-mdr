CREATE OR REPLACE PROCEDURE CLEAR_INDEX(INDEX_NAME IN VARCHAR2) AS
BEGIN
    EXECUTE IMMEDIATE 'drop index ' || INDEX_NAME;
EXCEPTION
    WHEN OTHERS THEN
        NULL;
END CLEAR_INDEX;
/
create or replace Procedure SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG AS
--DECLARE
v_eff_date DATE := sysdate;
BEGIN
  BEGIN -- Load EVS concept data
	--Concept preferred name is the first synonym token, here is the code to populate it.
	update SAG_LOAD_CONCEPTS_EVS
	set EVS_PREF_NAME = substr(REGEXP_SUBSTR(SYNONYMS, '[^|]+'), 1, 255)
	;
	commit;

	--disable compaund triggers
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_DEF_POST DISABLE';

INSERT INTO /*+ APPEND */ admin_item (--NCI_IDSEQ,
     ADMIN_ITEM_TYP_ID,
     ADMIN_STUS_ID, --75 
     ADMIN_STUS_NM_DN, -- compound trigger RELEASED
     EFF_DT,
     -- CHNG_DESC_TXT, N/A
     CNTXT_ITEM_ID, -- trigger 20000000024 
     CNTXT_VER_NR, --1
     CNTXT_NM_DN, --NCIP
     -- UNTL_DT,
     -- CURRNT_VER_IND, default
     ITEM_LONG_NM,
     ORIGIN_ID, -- default by trigger from obj_key 1466
     ORIGIN_ID_DN, -- NCI Thesaurus
     ITEM_DESC, 
     --ITEM_ID,
     ITEM_NM,
     VER_NR,
     CREAT_USR_ID,
     CREAT_DT,
     LST_UPD_DT,
     LST_UPD_USR_ID,
     DEF_SRC)
select --'D12B8399-3EE0-0244-E053-5801D00A0E12', --for test
49, 75, 'RELEASED', v_eff_date, 
20000000024, 1, 'NCIP',
code, -- ITEM_LONG_NM
1466,
'NCI Thesaurus',
substr(NVL(definition, 'No value exists.'), 1, 4000), 
EVS_PREF_NAME, 1, 
'ONEDATA', v_eff_date, v_eff_date, 
'ONEDATA', 'NCI'
from SAG_LOAD_CONCEPTS_EVS where
 code not in (select item_long_nm from ADMIN_ITEM where admin_item_typ_id = 49 and cntxt_item_id = 20000000024)-- and context restriction NCIP
 and (CONCEPT_STATUS is NULL and CON_IDSEQ is null);-- use an empty status concepts
-- commit;
dbms_output.put_line('loaded concepts to admin_item !!!');

--Add concept table records based on AI table
insert into /*+ APPEND */ cncpt (item_id,
     ver_nr,
     evs_src_id,
     CREAT_USR_ID,
     CREAT_DT,
     LST_UPD_DT,
     LST_UPD_USR_ID)
SELECT item_id,
     ver_nr,
     218,-- NCI_CONCEPT_CODE
     CREAT_USR_ID,
     CREAT_DT,
     LST_UPD_DT,
     LST_UPD_USR_ID from admin_item where (item_id, ver_nr) in
(select item_id, ver_nr from admin_item where admin_item_typ_id = 49 minus select item_id, ver_nr from cncpt);
commit; --commit only when both cncpt and admin_item updated
dbms_output.put_line('loaded concepts to cncpt !!!'); 
-- Add IDSEQ generated for concepts in AI, and ITEM_ID, VER_NR reference to EVS flat table

MERGE INTO SAG_LOAD_CONCEPTS_EVS t1
USING
(
SELECT * FROM ADMIN_ITEM where ADMIN_ITEM_TYP_ID = 49 
and cntxt_item_id = 20000000024 and CNTXT_VER_NR = 1-- and context restriction NCIP
--and CREAT_USR_ID = 'ONEDATA' 
)t2
ON(t1.code = t2.item_long_nm)
WHEN MATCHED THEN UPDATE SET
t1.con_idseq = t2.nci_idseq,
t1.item_id = t2.item_id,
t1.ver_nr = t2.ver_nr
where CONCEPT_STATUS is NULL; --we do not use in further steps EVS concepts which status is not null
commit;

dbms_output.put_line('updated SAG_LOAD_CONCEPTS_EVS with ID info!!!');

-- add concept alt names type vsynonym load by ONEDATA, which have a record in the EVS table, only if these synonyms are not in DB
EXECUTE IMMEDIATE 'CREATE INDEX IDX_SAG_LOAD_CNCPT_ID_VER ON SAG_LOAD_CONCEPTS_EVS (ITEM_ID, VER_NR)';
-- create Alternate names from flat table concepts synonyms
for record in (select ld.synonyms synonyms,
     ai.ITEM_ID ITEM_ID, 
     ai.VER_NR VER_NR,
     ai.CREAT_USR_ID CREAT_USR_ID,
     ai.CREAT_DT CREAT_DT,
     ai.LST_UPD_USR_ID LST_UPD_USR_ID,
     ai.LST_UPD_DT LST_UPD_DT
from SAG_LOAD_CONCEPTS_EVS ld, admin_item ai 
     where ai.admin_item_typ_id = 49
     and ld.item_id = ai.item_id
     and ld.ver_nr = ai.ver_nr
     and CONCEPT_STATUS is NULL 
     --and CON_IDSEQ is not null --not needed since item ID is used
     and instr (SYNONYMS, '|') > 0) -- just one synonym is pref name
LOOP
     SAG_LOAD_CONCEPT_SYNONYMS(
     substr(record.synonyms, instr(record.synonyms, '|')+1),
     record.ITEM_ID, record.VER_NR, 
     'ONEDATA', v_eff_date, 
     'ONEDATA', v_eff_date);
END LOOP;
dbms_output.put_line('loaded concepts synonyms to ALT_NMS !!!');

	SAG_LOAD_CONCEPT_UPDATES(v_eff_date); -- update names and definitions
dbms_output.put_line('concept load updates done !!!');
	DBMS_MVIEW.REFRESH('VW_CNCPT');

	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on designation updates
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_DEF_POST ENABLE';
	--drop an auxilary index if there
     CLEAR_INDEX('IDX_SAG_LOAD_CNCPT_ID_VER');

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        ROLLBACK;
        -- always restore OD Triggers
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on designation updates
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_DEF_POST ENABLE';
        --drop an auxilary index if there
        CLEAR_INDEX('IDX_SAG_LOAD_CNCPT_ID_VER');
        RAISE_APPLICATION_ERROR (-20002, 'SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
  END;-- of EVS concepts data load
  
  -- subset terminologies and concept parents related load
  BEGIN
    nci_import.spLoadConceptRel;
  EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('nci_import.spLoadConceptRel error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
  END;
END;
/
create or replace Procedure SAG_LOAD_CONCEPT_PRIOR_DEF (P_CREAT_DT IN DATE DEFAULT sysdate) AS
v_date DATE := P_CREAT_DT; --parameter
V_IDSEQ CHAR(36 BYTE);
v_cnt NUMBER(3);
BEGIN
-- assuming that sag_load_concepts_evs is preprocessed
  FOR desig IN (SELECT item_id, ver_nr FROM sag_load_concepts_evs where CHANGED_DEF = 1)
  LOOP --shall check not include if def is there
   select count(*) into v_cnt from ALT_DEF
   where NCI_DEF_TYP_ID = 1357
   and CNTXT_ITEM_ID = 20000000024 and CNTXT_VER_NR = 1
   and ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR
   and DEF_DESC =
   (select item_desc from admin_item where ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR);
      --insert if not exist
   IF (v_cnt  = 0) THEN
    INSERT INTO /*+ APPEND */ ALT_DEF (DEF_DESC,
    NCI_DEF_TYP_ID ,
    CNTXT_ITEM_ID , --trigger 20000000024 NCIP
    CNTXT_VER_NR ,
    ITEM_ID , --AI reference
    VER_NR , --AI reference
    CREAT_USR_ID , CREAT_DT , LST_UPD_USR_ID , LST_UPD_DT )
    SELECT
        item_desc,
        1357, -- Prior Preferred Definition
        20000000024, --NCIP ID
        1,
        item_id, --concept to update name
        ver_nr,
        'ONEDATA',
        v_date, --parameter
        'ONEDATA',
        v_date
    FROM
        admin_item
    WHERE
        admin_item_typ_id = 49
        AND item_id = desig.item_id
        AND ver_nr = desig.ver_nr
        AND admin_stus_id = 75
    ;
   END IF;
  END LOOP;
  commit;
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_PRIOR_DEF error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        rollback;
    RAISE_APPLICATION_ERROR (SQLCODE, 'SAG_LOAD_CONCEPT_PRIOR_DEF error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
END;
/
create or replace Procedure SAG_LOAD_CONCEPT_PRIOR_NAME (P_CREAT_DT IN DATE DEFAULT sysdate) AS
v_date DATE := P_CREAT_DT; --parameter
V_IDSEQ CHAR(36 BYTE);
BEGIN
-- assuming that sag_load_concepts_evs is preprocessed and item_id, item_nr is a unique combination
  FOR desig IN (SELECT item_id, ver_nr FROM sag_load_concepts_evs where CHANGED_NAME = 1)
  LOOP
   BEGIN
         --check that prior name like this does not exist
   select NCI_IDSEQ into V_IDSEQ from ALT_NMS
   where NM_TYP_ID = 1049
   and CNTXT_ITEM_ID = 20000000024 and CNTXT_VER_NR = 1
   and ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR
   and NM_DESC =
   (select item_nm from admin_item where ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR);
   EXCEPTION
   --insert if not exist
      WHEN no_data_found THEN
    INSERT INTO /*+ APPEND */ ALT_NMS (NM_DESC,
    nm_typ_id ,
    CNTXT_ITEM_ID , --trigger 20000000024 NCIP
    CNTXT_VER_NR , CNTXT_NM_DN ,
    LANG_ID ,
    ITEM_ID , --AI reference
    VER_NR , --AI reference
    CREAT_USR_ID , CREAT_DT , LST_UPD_USR_ID , LST_UPD_DT )
    SELECT
        item_nm,
        1049,  --Prior Preferred Name
        20000000024, --NCIP ID
        1,
        'NCIP', --Context
        1000, --DSRMWS-2436 ENGLISH
        item_id, --concept to update name
        ver_nr,
        'ONEDATA',
        v_date, --parameter
        'ONEDATA',
        v_date
    FROM
        admin_item
    WHERE
        admin_item_typ_id = 49
        AND item_id = desig.item_id
        AND ver_nr = desig.ver_nr
        AND admin_stus_id = 75
    ;
   WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_PRIOR_NAME loop error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        rollback;
        RAISE_APPLICATION_ERROR (SQLCODE, 'SAG_LOAD_CONCEPT_PRIOR_NAME Loop error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
   END;
  END LOOP;
  commit;
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_PRIOR_NAME error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        rollback;
    RAISE_APPLICATION_ERROR (SQLCODE, 'SAG_LOAD_CONCEPT_PRIOR_NAME error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
END;
/
create or replace Procedure SAG_LOAD_CONCEPT_PRIOR_DEF (P_CREAT_DT IN DATE DEFAULT sysdate) AS
v_date DATE := P_CREAT_DT; --parameter
V_IDSEQ CHAR(36 BYTE);
v_cnt NUMBER(3);
BEGIN
-- assuming that sag_load_concepts_evs is preprocessed
  FOR desig IN (SELECT item_id, ver_nr FROM sag_load_concepts_evs where CHANGED_DEF = 1)
  LOOP --shall check not include if def is there
   select count(*) into v_cnt from ALT_DEF
   where NCI_DEF_TYP_ID = 1357
   and CNTXT_ITEM_ID = 20000000024 and CNTXT_VER_NR = 1
   and ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR
   and DEF_DESC =
   (select item_desc from admin_item where ITEM_ID = desig.ITEM_ID and VER_NR = desig.VER_NR);
      --insert if not exist
   IF (v_cnt  = 0) THEN
    INSERT INTO /*+ APPEND */ ALT_DEF (DEF_DESC,
    NCI_DEF_TYP_ID ,
    CNTXT_ITEM_ID , --trigger 20000000024 NCIP
    CNTXT_VER_NR ,
    LANG_ID ,
    ITEM_ID , --AI reference
    VER_NR , --AI reference
    CREAT_USR_ID , CREAT_DT , LST_UPD_USR_ID , LST_UPD_DT )
    SELECT
        item_desc,
        1357, -- Prior Preferred Definition
        20000000024, --NCIP ID
        1,
        1000, --DSRMWS-2436 ENGLISH
        item_id, --concept to update name
        ver_nr,
        'ONEDATA',
        v_date, --parameter
        'ONEDATA',
        v_date
    FROM
        admin_item
    WHERE
        admin_item_typ_id = 49
        AND item_id = desig.item_id
        AND ver_nr = desig.ver_nr
        AND admin_stus_id = 75
    ;
   END IF;
  END LOOP;
  commit;
  EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_PRIOR_DEF error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        rollback;
    RAISE_APPLICATION_ERROR (SQLCODE, 'SAG_LOAD_CONCEPT_PRIOR_DEF error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
END;
/