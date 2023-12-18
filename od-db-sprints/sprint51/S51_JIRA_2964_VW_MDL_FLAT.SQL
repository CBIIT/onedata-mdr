CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_FLAT ("Model Public ID", "Model Version", "Model Name", "Model Definition", "Model Context", "Model Workflow Status", "Model Registration Status", "Modelling Language", "Model Type", "Model Latest Version", "Element Long Name", "Element Physical Name", "Element Type", "Element Definition", "Element Mapping Group", "Element Public ID", "Element Version", "Characteristics Data Type", "Characteristics Max Length", "Characteristics Min Length", "Characteristics UOM", "Characteristics Default", "DEC Public ID", "DEC Version", "DEC Long Name", "DEC Context", "Characteristics Name", "Characteristics Physical Name", "Characteristics Description", "CDE Public ID", "CDE Version", "CDE Item Long Name", "CDE Context") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select ai.item_id "Model Public ID", 
	ai.ver_nr  "Model Version", 
	ai.item_nm  "Model Name", 
	ai.item_desc  "Model Definition",
--	ai.cntxt_item_id mdl_cntxt_item_id, 
--  	ai.cntxt_ver_nr  mdl_cntxt_ver_nr,
        ai.cntxt_nm_dn  "Model Context", 
--	ai.admin_stus_id mdl_admin_stus_id, 
--	ai.regstr_stus_id mdl_regstr_stus_id,
	ai.admin_stus_nm_dn  "Model Workflow Status", 
	ai.regstr_stus_nm_dn  "Model Registration Status",
--	mdl.prmry_mdl_lang_id, 
	mdl_lang.obj_key_desc "Modelling Language" ,
--	mdl.mdl_typ_id, 
	mdl_typ.obj_key_desc "Model Type",
	decode(ai.currnt_ver_ind,1,'Yes','No')  "Model Latest Version", 
	me.item_long_nm "Element Long Name", 
	me.item_phy_obj_nm "Element Physical Name" ,
--	me.me_typ_id , 
	me_typ.obj_key_desc "Element Type",
	me.item_desc "Element Definition",
--	me.me_grp_id mdl_elmnt_grp_id, 
	me_grp.obj_key_desc "Element Mapping Group",
	me.item_id "Element Public ID", 
	me.ver_nr "Element Version", 
--	mec.creat_dt, 
--	mec.creat_usr_id, 
--	mec.lst_upd_dt, 
--	mec.lst_upd_usr_id, 
--	mec.s2p_trn_dt, 
--	mec.fld_delete, 
--	mec.lst_del_dt,
	mec.src_dttype "Characteristics Data Type", 
	mec.src_max_char "Characteristics Max Length", 
	mec.src_min_char"Characteristics Min Length", 
	mec.src_uom "Characteristics UOM", 
	mec.src_deflt_val "Characteristics Default", 
	mec.de_conc_item_id "DEC Public ID", 
	mec.de_conc_ver_nr "DEC Version",
	dec.item_nm "DEC Long Name",
	dec.cntxt_nm_dn "DEC Context",
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm "Characteristics Name", 
	mec.mec_phy_nm "Characteristics Physical Name", 
	mec.mec_desc "Characteristics Description", 
	mec.cde_item_id "CDE Public ID", 
	mec.cde_ver_nr "CDE Version",
	cde.Item_nm "CDE Item Long Name",
	cde.cntxt_nm_dn "CDE Context"
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec,admin_item dec, admin_item cde, obj_key me_grp, obj_key mdl_typ, obj_key mdl_lang, obj_key me_typ
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and cde.admin_item_typ_id (+)= 4
	and mec.de_conc_item_id = dec.item_id (+)
	and mec.de_conc_ver_nr = dec.ver_nr (+)
	and dec.admin_item_typ_id (+)= 2
	and mdl.mdl_typ_id =mdl_typ.obj_key_id (+)
	and mdl.prmry_mdl_lang_id =mdl_lang.obj_key_id (+)
	and me.me_typ_id = me_typ.obj_key_id (+)
	and me.me_grp_id = me_grp.obj_key_id (+);

