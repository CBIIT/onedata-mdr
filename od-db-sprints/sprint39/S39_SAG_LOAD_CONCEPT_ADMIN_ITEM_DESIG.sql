create or replace Procedure SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG AS
--DECLARE
v_eff_date DATE := sysdate;
BEGIN
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
commit;
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
commit;
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

	DBMS_MVIEW.REFRESH('VW_CNCPT');

	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on designation updates
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_DEF_POST ENABLE';
	EXECUTE IMMEDIATE 'DROP INDEX IDX_SAG_LOAD_CNCPT_ID_VER';
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        ROLLBACK;
        -- always restore OD Triggers
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on designation updates
        EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_DEF_POST ENABLE';
        RAISE_APPLICATION_ERROR (SQLCODE, 'SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
        
        nci_import.spLoadConceptRel;
END;
