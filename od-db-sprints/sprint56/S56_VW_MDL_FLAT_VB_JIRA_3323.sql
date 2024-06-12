CREATE OR REPLACE FORCE EDITIONABLE VIEW "ONEDATA_WA"."VW_MDL_FLAT_VB" ("MDL_ITEM_ID", "MDL_VER_NR", "MDL_NM", "MDL_CNTXT_NM", "MDL_ADMIN_STUS_NM", "MDL_REGSTR_STUS_NM", "MDL_LANG_DESC", "MDL_TYP_DESC", "MDL_CURRNT_VER_IND", "ME_LONG_NM", "ME_PHY_NM", "ME_TYP_DESC", "ME_DESC", "ME_MAP_GRP_DESC", "ME_ITEM_ID", "ME_VER_NR", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_DT", "LST_UPD_USR_ID", "S2P_TRN_DT", "FLD_DELETE", "LST_DEL_DT", "MEC_DTTYP", "MEC_CHAR_ORD", "MEC_MAX_CHAR", "MEC_MIN_CHAR", "MEC_UOM", "MEC_DEFLT_VAL", "DE_CONC_ITEM_ID", "DE_CONC_VER_NR", "DEC_NM", "DEC_CNTXT_NM", "MEC_LONG_NM", "MEC_PHY_NM", "MEC_DESC", "CDE_ITEM_ID", "VAL_DOM_ITEM_ID", "VAL_DOM_VER_NR", "VAL_DOM_TYP", "TERM_NAME", "USE_NAME", "VAL_DOM_MIN_CHAR", "VAL_DOM_MAX_CHAR", "VD_ITEM_NM", "DT_TYP_DESC", "UOM_DESC", "MEC_TYP_DESC", "CDE_VER_NR", "CDE_NM", "CDE_CNTXT_NM", "MEC_ID", "REQ_IND", "PK_IND", "FK_IND", "FK_ELMNT_PHY_NM", "FK_ELMNT_CHAR_PHY_NM", "VAL_DOM_TYP_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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