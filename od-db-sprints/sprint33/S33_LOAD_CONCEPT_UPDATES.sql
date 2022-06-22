create or replace Procedure SAG_LOAD_CONCEPT_RETIRE (p_END_DATE IN date default sysdate)
AS
v_end_date DATE;
v_updated_by2 varchar2(64) := '. Updated by caDSR II Monthly Concept Load.';
v_updated_by1 varchar2(256) := 'Updated caDSR information to match EVS retirement status, concept was retired on ';
v_updated_by varchar2(512);
BEGIN
     v_end_date := p_END_DATE;
     v_updated_by := v_updated_by1 || to_char(sysdate, 'MON DD, YYYY HH:MI AM') || v_updated_by2;
update admin_item set admin_stus_id = 77, --WFS to 'RETIRED ARCHIVED'
     LST_UPD_USR_ID = 'ONEDATA', 
     UNTL_DT = v_end_date,
     CHNG_DESC_TXT = v_updated_by,
     REGSTR_STUS_ID = 11 -- 'Retired'
     where admin_item_typ_id = 49 and -- Concept
     admin_stus_id <> 77 and 
     CNTXT_ITEM_ID = 20000000024 and --NCIP
     CNTXT_VER_NR = 1 and
     item_long_nm in ( -- EVS provided list - parents of retired concepts
     select code from sag_load_concepts_evs where parents in(
'C176957',
'C167277',
'C157491',
'C83481',
'C83484',
'C83483', 
'C83482',
'C83479',
'C83480',
'C131742',
'C104171',
'C113462',
'C125190',
'C120167', 
'C85834', 
'C95421',
'C143136',
'C83485',
'C99526',
'C185140'
));
commit;
exception
 when OTHERS then
  DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_RETIRE error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 128));
  rollback;
END;
/
create or replace Procedure SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG AS
--DECLARE
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
code, -- ITEM_LONG_NM
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
-- Add IDSEQ generated for concepts in AI to flat table
MERGE INTO SAG_LOAD_CONCEPTS_EVS t1
USING
(
SELECT * FROM ADMIN_ITEM where ADMIN_ITEM_TYP_ID = 49 and cntxt_item_id = 20000000024 -- and context restriction NCIP
--and CREAT_USR_ID = 'ONEDATA' 
)t2
ON(t1.code = t2.item_long_nm)
WHEN MATCHED THEN UPDATE SET
t1.con_idseq = t2.nci_idseq,
t1.item_id = t2.item_id,
t1.ver_nr = t2.ver_nr;
commit;
dbms_output.put_line('updated con_idseq SAG_LOAD_CONCEPTS_EVS !!!');

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

	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_AI_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_NCI_ALT_NMS_DENORM_INS ENABLE';
	EXECUTE IMMEDIATE 'ALTER TRIGGER TR_ALT_NMS_POST ENABLE';-- this trigger updates AI audit info on degignation updates
	EXECUTE IMMEDIATE 'DROP INDEX IDX_SAG_LOAD_CNCPT_ID_VER';

	SAG_LOAD_CONCEPT_RETIRE(v_eff_date); --retire EVS-retired concepts
END;
/
create or replace procedure SAG_LOAD_CONCEPT_PREPARE_UPD
AS
BEGIN

--prepare CHANGED_NAME indicator
MERGE INTO SAG_LOAD_CONCEPTS_EVS t1
USING
(
SELECT * FROM ADMIN_ITEM where ADMIN_ITEM_TYP_ID = 49 
and cntxt_item_id = 20000000024 -- and context restriction NCIP
and cntxt_ver_nr = 1
AND admin_stus_id = 75 --RELEASED Only
)t2
ON(t1.code = t2.item_long_nm)
WHEN MATCHED THEN UPDATE SET
t1.CHANGED_NAME = 1
where t1.evs_pref_name <> t2.item_nm;
--prepare CHANGED_DEF indicator
MERGE INTO SAG_LOAD_CONCEPTS_EVS t1
USING
(
SELECT * FROM ADMIN_ITEM where ADMIN_ITEM_TYP_ID = 49 
and cntxt_item_id = 20000000024 -- and context restriction NCIP
and cntxt_ver_nr = 1
AND admin_stus_id = 75 --RELEASED Only
)t2
ON(t1.code = t2.item_long_nm)
WHEN MATCHED THEN UPDATE SET
t1.CHANGED_DEF = 1
where t1.definition is not null
and substr(NVL(t1.definition, 'No value exists.'), 1, 4000) <> t2.ITEM_DESC;
--
UPDATE SAG_LOAD_CONCEPTS_EVS set CHANGED_BOTH = 1
where CHANGED_DEF = 1 and CHANGED_NAME = 1;
commit;
exception
 when OTHERS then
  DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_PREPARE_UPD error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 128));
  rollback;
END;
/
