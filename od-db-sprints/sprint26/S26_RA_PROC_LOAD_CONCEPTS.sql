create or replace PROCEDURE SAG_LOAD_CONCEPTS_SYN_RA AS 
BEGIN
--Add concepts created in WA by concept loading which are not found by PK in RA schema
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
--remove alt names synonyms from RA
delete from onedata_ra.alt_nms where 
NM_TYP_ID = 1064;
--insert alt names synonyms to ONEDATA_RA from ONEDATA_WA
insert into onedata_ra.alt_nms 
select * from onedata_wa.alt_nms where nm_typ_id = 1064;
commit;
END SAG_LOAD_CONCEPTS_SYN_RA;
/