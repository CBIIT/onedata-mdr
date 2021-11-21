CREATE OR REPLACE Procedure SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG AS
--DECLARE
v_concepts_loaded SAG_LOAD_CONCEPTS_EVS%ROWTYPE;
v_eff_date DATE := sysdate;

BEGIN
	--disable compaund triggers
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS DISABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST DISABLE';
	
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
                    -- ORIGIN, default trigger
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
code, substr(NVL(definition, 'No value exists.'), 1, 4000), NVL (display_name, code), 1,
'ONEDATA', v_eff_date, v_eff_date, 
'ONEDATA', 'NCI'
from SAG_LOAD_CONCEPTS_EVS where
 code not in (select item_long_nm from ADMIN_ITEM where admin_item_typ_id = 49)
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

-- Add IDSEQ generated for concepts in AI to flat table
MERGE INTO SAG_LOAD_CONCEPTS_EVS t1
USING
(
-- For more complicated queries you can use WITH clause here
SELECT * FROM ADMIN_ITEM where ADMIN_ITEM_TYP_ID = 49 and CREAT_USR_ID = 'ONEDATA' -- and context restriction
)t2
ON(t1.code = t2.item_long_nm)
WHEN MATCHED THEN UPDATE SET
t1.con_idseq = t2.nci_idseq;
commit;
dbms_output.put_line('updated con_idseq !!!'); 

-- create Alternate names from flat table concepts synonyms
INSERT INTO /*+ APPEND */ ALT_NMS (NM_DESC,
                    NM_TYP_ID,
                    -- NCI_IDSEQ, --newly generated value for designation object
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
                    LST_UPD_DT,
                    LST_UPD_USR_ID
                    )
select substr(ld.synonyms,1, 2000),
1064,--'Synonym',
-- 'A12B8399-3EE0-0244-E053-5801D00A0E12', -- for test
20000000024, 1, 'NCIP',
ai.ITEM_ID, ai.VER_NR,
ai.CREAT_USR_ID,
ai.CREAT_DT,
ai.LST_UPD_DT,
ai.LST_UPD_USR_ID
from SAG_LOAD_CONCEPTS_EVS ld, admin_item ai 
where ai.admin_item_typ_id = 49
and ld.code = ai.item_long_nm
and CONCEPT_STATUS is NULL and CON_IDSEQ is not null;
commit;
dbms_output.put_line('loaded concepts synonyms to ALT_NMS !!!');

	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on degignation updates
END;
/