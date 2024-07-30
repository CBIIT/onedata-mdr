alter table NCI_MDL add (MAP_USG_TYP_ID integer);

insert into obj_typ(obj_typ_id, obj_typ_desc) values (61,'Model Usage Type for Mapping');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,135, 'Source Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,136, 'Target Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,137, 'Source or Target');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,138, 'No Mapping');
commit

alter table NCI_MEC_MAP add (PCODE_SYSGEN varchar2(4000));


  CREATE OR REPLACE  VIEW VW_NCI_MDL AS
  select
	ai."ITEM_ID",ai."VER_NR",
    ai."ITEM_DESC",ai."CNTXT_ITEM_ID",ai."CNTXT_VER_NR",ai."ITEM_LONG_NM",ai."ITEM_NM",ai."ADMIN_NOTES",
    ai."CHNG_DESC_TXT",ai."EFF_DT",ai."ORIGIN",ai."UNRSLVD_ISSUE",ai."UNTL_DT",ai."ADMIN_ITEM_TYP_ID",
    ai."CURRNT_VER_IND",ai."ADMIN_STUS_ID",ai."REGSTR_STUS_ID",ai."CREAT_DT",
    ai."CREAT_USR_ID",ai."LST_UPD_USR_ID",ai."FLD_DELETE",ai."LST_DEL_DT",ai."S2P_TRN_DT",ai."LST_UPD_DT",
    ai."ADMIN_STUS_NM_DN",ai."CNTXT_NM_DN",ai."REGSTR_STUS_NM_DN",ai."ORIGIN_ID",ai."CREAT_USR_ID_X",ai."LST_UPD_USR_ID_X",
    ai."ITEM_NM_CURATED", m.prmry_mdl_lang_id ,
    m.map_usg_Typ_id from admin_item ai, nci_mdl m where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 57;

