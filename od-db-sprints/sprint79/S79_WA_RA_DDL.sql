alter table nci_ds_rslt add ITEM_ID_2 number;
alter table nci_ds_rslt add VER_NR_2 number(4,2);
alter table nci_ds_rslt add RANK number;

alter table nci_ds_rslt disable all triggers;
update nci_ds_rslt set ITEM_ID_2 = ITEM_ID, VER_NR_2 = VER_NR;
commit;
alter table nci_ds_rslt modify cde_pref_ind number default null;
update nci_ds_rslt set cde_pref_ind = null where cde_pref_ind = 0;
commit;
alter table nci_ds_rslt enable all triggers;

Insert into NCI_PROC_EXEC (LOG_ID,JOB_STEP_DESC,JOB_STEP_SP) 
values (19,'Test LLM Connectivity','nci_api.testLLM (''Gender'')');
commit;

alter table NCI_MDL_ELMNT_CHAR add (NUM_CDE_MTCH integer, SYS_MSG varchar2(2000));


Insert into NCI_LLM_CNFG (LLM_MDL_VER,USE_CASE,PARAM_VAL) values ('CADSRAPI','CDEAIMATCH','/rad/cdeai.api.producer.v2:cdeai_rad/performCDEAIMatch');
commit;

Insert into NCI_LLM_CNFG (LLM_MDL_VER,USE_CASE,PARAM_VAL) values ('CADSRAPI','EMAIL',
'/rad/onedata.flowservices.email:email_rad/email');
commit;


Insert into NCI_LLM_CNFG (LLM_MDL_VER,USE_CASE,PARAM_VAL) values ('CADSRAPI','LLM',
'/rad/aws.bedrock:bedrock_rad/converse');
commit;


Insert into ONEDATA_WA.NCI_MDR_CNTRL (ID,PARAM_NM,PARAM_VAL) values (13,'ISAPIUSER','onedataapi');
Insert into ONEDATA_WA.NCI_MDR_CNTRL (ID,PARAM_NM,PARAM_VAL) values (14,'ISAPIUSERPWD','onedataapi-dev');
commit;

alter table admin_item add ITEM_DESC_LLM varchar2(4000);

create or replace view vw_usr_email as select usr_id usr_nm, email_id from onedata_md.od_md_objsecu;



  CREATE OR REPLACE VIEW VW_MDL_FLAT_VB As
  select ai.item_id MDL_ITEM_ID, 
	ai.ver_nr  MDL_VER_NR, 
	ai.item_nm  MDL_NM, 
        ai.cntxt_nm_dn  MDL_CNTXT_NM, 
	ai.admin_stus_nm_dn  MDL_ADMIN_STUS_NM, 
	ai.regstr_stus_nm_dn  MDL_REGSTR_STUS_NM,
	mdl_lang.obj_key_desc MDL_LANG_DESC ,
	mdl_typ.obj_key_desc MDL_TYP_DESC,
	ai.currnt_ver_ind MDL_CURRNT_VER_IND, 
	me.item_long_nm  ME_LONG_NM, 
	me.item_phy_obj_nm ME_PHY_NM ,
	me_typ.obj_key_desc ME_TYP_DESC,
	me.item_desc ME_DESC,
	me_grp.obj_key_desc ME_MAP_GRP_DESC,
	me.item_id ME_ITEM_ID, 
	me.ver_nr ME_VER_NR, 
	mec.creat_dt, 
	mec.creat_usr_id, 
	mec.lst_upd_dt, 
	mec.lst_upd_usr_id, 
	mec.s2p_trn_dt, 
	mec.fld_delete, 
	mec.lst_del_dt,
	mec.src_dttype MEC_DTTYP, 
	mec.CHAR_ORD MEC_CHAR_ORD, 
	mec.src_max_char MEC_MAX_CHAR, 
	mec.src_min_char MEC_MIN_CHAR, 
	mec.src_uom MEC_UOM, 
	mec.src_deflt_val MEC_DEFLT_VAL, 
	  mec.cmnts_desc_txt,
	mec.de_conc_item_id, 
	mec.de_conc_ver_nr,
	dec.item_nm DEC_NM,
	dec.cntxt_nm_dn DEC_CNTXT_NM,
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm , 
	mec.mec_phy_nm , 
	mec.mec_desc , 
	mec.cde_item_id , 
	  mec.val_dom_item_id, 
	  mec.val_dom_ver_nr,
      mec.num_cde_mtch,
      mec.sys_msg,
decode(vdst.VAL_DOM_TYP_ID,16, 'Enumerated by Reference', 17, 'Enumerated',18, 'Non-enumerated') VAL_DOM_TYP,
	  vdrt.TERM_NAME,
	  vdrt.USE_NAME,
	  vdst.VAL_DOM_MIN_CHAR, 
	  vdst.VAL_DOM_MAX_CHAR, 
	  vd.item_nm vd_item_nm,
	  dt.dttype_nm DT_TYP_DESC,
	  uom.uom_nm uom_DESC,
      mec_typ.obj_key_Desc MEC_TYP_DESC,
	mec.cde_ver_nr ,
	cde.Item_nm CDE_NM,
	cde.cntxt_nm_dn CDE_CNTXT_NM,
	  mec.mec_id,
	  mec.req_ind,
	  mec.pk_ind,
	  mec.fk_ind,
	  mec.mdl_pk_ind,
	  mec.FK_ELMNT_PHY_NM,
	  mec.FK_ELMNT_CHAR_PHY_NM,
      vdst.VAL_DOM_TYP_ID
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec,admin_item dec, admin_item cde, obj_key me_grp, obj_key mdl_typ, obj_key mdl_lang, obj_key me_typ, 
obj_key mec_typ, data_typ dt, uom uom,
	  admin_item vd, value_dom vdst, VW_VAL_DOM_REF_TERM vdrt
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and mec.val_dom_item_id = vd.item_id (+)
	and mec.val_dom_ver_nr = vd.ver_nr (+)	  
	and mec.val_dom_item_id = vdst.item_id (+)
	and mec.val_dom_ver_nr = vdst.ver_nr (+)	  
	and mec.val_dom_item_id = vdrt.item_id (+)
	and mec.val_dom_ver_nr = vdrt.ver_nr (+)	  
	and cde.admin_item_typ_id (+)= 4
	and mec.de_conc_item_id = dec.item_id (+)
	and mec.de_conc_ver_nr = dec.ver_nr (+)
	and dec.admin_item_typ_id (+)= 2
	and mdl.mdl_typ_id =mdl_typ.obj_key_id (+)
	and mdl.prmry_mdl_lang_id =mdl_lang.obj_key_id (+)
	and me.me_typ_id = me_typ.obj_key_id (+)
	and mec.MDL_ELMNT_CHAR_TYP_ID = mec_typ.obj_key_id (+)
	and me.me_grp_id = me_grp.obj_key_id (+)
	and vdst.NCI_STD_DTTYPE_ID = dt.dttype_id (+)
	  and vdst.uom_id = uom.uom_id (+);


