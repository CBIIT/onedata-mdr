
alter table nci_stg_mdl_elmnt_char add (CTL_VAL_MSG varchar2(1000));
alter table nci_stg_mdl_elmnt add (CTL_VAL_MSG varchar2(1000));
alter table NCI_MEC_VAL_MAP add ( MAP_DEG integer);

alter table NCI_MDL add ( ASSOC_TBL_NM_TYP_ID integer, ASSOC_CS_ITEM_ID number, ASSOC_CS_VER_NR number(4,2));
alter table NCI_MDL_ELMNT_CHAR add ( CHNG_DESC_TXT varchar2(4000));



delete from nci_cncpt_rel where (c_item_id, c_item_ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

delete from cncpt where (item_id, ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

delete from admin_item where (item_id, ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

commit;
