
  CREATE OR REPLACE  VIEW VW_NCI_FORM_FLAT as
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, frm.item_desc  frm_item_def,
  frmst.hdr_instr, frmst.ftr_instr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr, frm_mod.instr MOD_INSTR,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord, frm_mod.rep_no  mod_rep_no,
aim.item_nm MOD_ITEM_NM, air.instr QUEST_INSTR, air.REQ_IND  QUEST_REQ_IND, air.DEFLT_VAL QUEST_DEFLT_VAL, 
decode(DEFLT_VAL_ID, nvl(vv.nci_pub_id, 1), vv.value) QUEST_DEFLT_VAL_ENUM, 
       air.EDIT_IND QUEST_EDIT_IND,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
air.nci_pub_id QUEST_ITEM_ID,air.nci_ver_nr QUEST_VER_NR,
de.CNTXT_NM_DN CDE_CNTXT_NM, de.item_nm CDE_ITEM_NM, de.cntxt_item_id CDE_CNTXT_ITEM_ID, de.cntxt_VER_NR CDE_CNTXT_VER_NR, de.REGSTR_STUS_NM_DN CDE_REGSTR_STUS_NM,
de.ADMIN_STUS_NM_DN CDE_ADMIN_STUS_NM, nvl(de.CURRNT_VER_IND,0) CDE_CURRNT_VER_IND,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT,
vv.VM_NM, vv.VM_LNM, vv.VM_DEF, vv.VALUE VV_VALUE, vv.EDIT_IND VV_EDIT_IND, vv.SEQ_NBR VV_SEQ_NR, vv.MEAN_TXT VV_MEAN_TXT, vv.DESC_TXT VV_DESC_TXT, nvl(vv.nci_pub_id, 1) VV_ITEM_ID,
nvl(vv.nci_ver_nr, 1) VV_VER_NR, vv.INSTR VV_INSTR, vv.DISP_ORD VV_DISP_ORD,
VV.VAL_MEAN_ITEM_ID, vv.VAL_MEAN_VER_NR, frm.item_nm || '|' || frm.item_id || 'v' || frm.ver_nr || '|' || frm.cntxt_nm_dn || '|' || frm.admin_stus_nm_dn || '|' || frm.regstr_stus_nm_dn  FRM_DESC_COL
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de, nci_quest_valid_value vv, nci_form frmst
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm.item_id = frmst.item_id and frm.ver_nr = frmst.ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id (+)
and air.c_item_ver_nr = de.ver_nr (+)
and air.NCI_PUB_ID = vv.q_pub_id (+)
and air.nci_ver_nr = vv.q_ver_nr (+)
and nvl(air.fld_delete,0) = 0
and nvl(frm_mod.fld_delete,0) = 0
and nvl(vv.fld_delete,0) = 0;


  GRANT SELECT ON VW_NCI_FORM_FLAT TO "ONEDATA_RO";


  CREATE OR REPLACE VIEW VW_MDL_FLAT_VAL_MAP AS
  select ai.item_id MDL_ITEM_ID, 
	ai.ver_nr  MDL_VER_NR, 
	ai.item_nm  MDL_NM, 
        ai.cntxt_nm_dn  MDL_CNTXT_NM, 
	ai.admin_stus_nm_dn  MDL_ADMIN_STUS_NM, 
	ai.regstr_stus_nm_dn  MDL_REGSTR_STUS_NM,
	ai.currnt_ver_ind MDL_CURRNT_VER_IND, 
	me.item_long_nm  ME_LONG_NM, 
	me.item_phy_obj_nm ME_PHY_NM ,
	me.item_desc ME_DESC,
	me.item_id ME_ITEM_ID, 
	me.ver_nr ME_VER_NR, 
	mec.creat_dt, 
	mec.creat_usr_id, 
	mec.lst_upd_dt, 
	mec.lst_upd_usr_id, 
	mec.s2p_trn_dt, 
	mec.fld_delete, 
	mec.lst_del_dt,
--	mec.src_dttype MEC_DTTYP, 
--	mec.CHAR_ORD MEC_CHAR_ORD, 
--	mec.src_max_char MEC_MAX_CHAR, 
--	mec.src_min_char MEC_MIN_CHAR, 
--	mec.src_uom MEC_UOM, 
--	mec.src_deflt_val MEC_DEFLT_VAL, 
--	  mec.cmnts_desc_txt,
--	mec.de_conc_item_id, 
--	mec.de_conc_ver_nr,
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm , 
	mec.mec_phy_nm , 
	mec.mec_desc , 
	mec.cde_item_id , 
	  mec.val_dom_item_id, 
	  mec.val_dom_ver_nr,
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
	  PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
             -- PV.VAL_DOM_ITEM_ID,
		--PV.VAL_DOM_VER_NR , 
        VM.ITEM_NM VM_ITEM_NM, VM.ITEM_LONG_NM VM_ITEM_LONG_NM,
                VM.ITEM_DESC VM_ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, vm.admin_stus_nm_dn VM_ADMIN_STUS_NM_DN
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec, admin_item cde, PERM_VAL PV, ADMIN_ITEM VM	 
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and cde.admin_item_typ_id (+)= 4
	  and PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID (+) and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR (+) and
	  mec.val_dom_item_id = pv.val_dom_item_id (+) and 
	 mec.val_dom_ver_nr= pv.val_dom_Ver_nr (+) ;


