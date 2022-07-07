create or replace PROCEDURE SAG_LOAD_CONCEPTS_SYN_RA AS
BEGIN
insert into onedata_ra.admin_item ra 
select * from onedata_wa.admin_item wa
where wa.admin_item_typ_id = 49
and wa.creat_usr_id = 'ONEDATA' and wa.lst_upd_usr_id = 'ONEDATA'
and (wa.item_id, wa.ver_nr) not in (select item_id, ver_nr from onedata_ra.admin_item);
commit;

--Add concept table CNCPT records based on AI table
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
--insert concepts synonyms and prior names to ONEDATA_RA
delete from onedata_ra.alt_nms where 
NM_TYP_ID  in (1064, 1049);
--insert alt names synonyms to ONEDATA_RA from ONEDATA_WA
insert into onedata_ra.alt_nms 
select * from onedata_wa.alt_nms where nm_typ_id  in (1064, 1049);
commit;
dbms_output.put_line('ONEDATA_RA load concepts alt_nms is completed');

--insert concepts prior definitions to ONEDATA_RA
delete from onedata_ra.ALT_DEF where 
NCI_DEF_TYP_ID = 1357;
--insert alt names synonyms to ONEDATA_RA from ONEDATA_WA
insert into onedata_ra.ALT_DEF 
select * from onedata_wa.alt_defs where NCI_DEF_TYP_ID = 1357;
commit;
dbms_output.put_line('ONEDATA_RA load concepts alt_nms is completed');

commit;
dbms_output.put_line('ONEDATA_RA load concepts alt_def is completed');

--update names where different
MERGE INTO onedata_ra.admin_item t1
USING
(
SELECT * FROM onedata_wa.admin_item where admin_item_typ_id = 49
)t2
ON(t1.item_id = t2.item_id and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.ITEM_NM = t2.ITEM_NM,
t1.CHNG_DESC_TXT = t2.CHNG_DESC_TXT,
t1.LST_UPD_DT = t2.LST_UPD_DT,
t1.LST_UPD_USR_ID = t2.LST_UPD_USR_ID
where 
t1.admin_item_typ_id = 49
and t1.item_nm <> t2.ITEM_NM;
dbms_output.put_line('ONEDATA_RA load concepts names update is completed');

--update definitions where different
MERGE INTO onedata_ra.admin_item t1
USING
(
SELECT * FROM onedata_wa.admin_item where admin_item_typ_id = 49
)t2
ON(t1.item_id = t2.item_id and t1.ver_nr = t2.ver_nr)
WHEN MATCHED THEN UPDATE SET
t1.ITEM_DESC = t2.ITEM_DESC,
t1.CHNG_DESC_TXT = t2.CHNG_DESC_TXT,
t1.LST_UPD_DT = t2.LST_UPD_DT,
t1.LST_UPD_USR_ID = t2.LST_UPD_USR_ID
where 
t1.admin_item_typ_id = 49
and t1.item_desc <> t2.item_desc;
dbms_output.put_line('ONEDATA_RA load concepts definitions update is completed');

--update alt_def where different
DBMS_MVIEW.REFRESH('VW_CNCPT');

END;
/