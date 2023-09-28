--alter table NCI_MEC_MAP add ( MEC_SUB_GRP_NBR integer);
alter table NCI_STG_MDL add (CNTXT_ITEM_ID number, CNTXT_VER_NR number(4,2));

alter table NCI_STG_MDL_ELMNT add ( IMP_GRP_NM  varchar2(1000), ME_GRP_ID integer);

alter table NCI_MDL_ELMNT add (  ME_GRP_ID integer);

alter table NCI_STG_MDL_ELMNT_CHAR add (  CMNTS_DESC_TXT varchar2(4000));



	
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (49,'Mapping Groups');
	     commit;

--- Views for API
/*

create or replace view vw_mdl_flat as
select ai.item_id mdl_item_id, ai.ver_nr mdl_ver_nr, ai.item_long_nm mdl_long_nm, ai.item_desc mdl_item_desc,
ai.cntxt_item_id mdl_cntxt_item_id, ai.cntxt_ver_nr  mdl_cntxt_ver_nr,
ai.cntxt_nm_dn mdl_cntxt_nm_dn, ai.admin_stus_id mdl_admin_stus_id, ai.regstr_stus_id mdl_regstr_stus_id,
ai.admin_stus_nm_dn mdl_admin_stus_nm_dn, ai.regstr_stus_nm_dn mdl_regstr_stus_nm_dn,
mdl.prmry_mdl_lang_id, mdl.mdl_typ_id, ai.currnt_ver_ind mdl_currnt_ver_ind, 
me.item_long_nm mdl_elmnt_long_nm, me.item_phy_obj_nm mdl_elmnt_phy_nm ,me.me_typ_id mdl_elmnt_typ_id, me.item_desc mdl_elmnt_item_desc,
me.me_grp_id mdl_elmnt_grp_id, me.item_id mdl_elmnt_item_id, me.ver_nr mdl_elmnt_ver_nr, 
mec.creat_dt, mec.creat_usr_id, mec.lst_upd_dt, mec.lst_upd_usr_id, mec.s2p_trn_dt, mec.fld_delete, mec.lst_del_dt,
mec.src_dttype, mec.src_max_char, mec.src_min_char, mec.src_uom, mec.src_deflt_val, mec.de_conc_item_id, mec.de_conc_ver_nr, mec.val_dom_item_id,
mec.val_dom_ver_nr, mec.mec_long_nm, mec.mec_phy_nm, mec.mec_desc, mec.cde_item_id, mec.cde_ver_nr
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr;


  CREATE OR REPLACE  VIEW VW_MDL_MAP_FLAT AS
  select  s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm src_mdl_item_nm, s.item_desc src_mdl_item_desc,
  s.cntxt_nm_dn src_cntxt_nm_dn, sme.item_id SRC_ME_ITEM_ID, 
  sme.ver_nr SRC_me_VER_NR,
	sme.ITEM_LONG_NM SRC_me_item_nm, sme.ITEM_PHY_OBJ_NM SRC_me_phy_nm, smec."MEC_ID" SRC_MEC_ID, 
	  smec."MEC_TYP_ID" SRC_MEC_TYP_ID,map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  smec."DE_CONC_ITEM_ID" SRC_DE_CONC_ITEM_ID,smec."DE_CONC_VER_NR" SRC_DE_CONC_VER_NR,smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" SRC_MEC_LONG_NM ,smec."MEC_PHY_NM" SRC_MEC_PHY_NM, smec."CDE_ITEM_ID" SRC_CDE_ITEM_ID,smec."CDE_VER_NR" SRC_CDE_VER_NR,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm,  t.item_desc tgt_mdl_item_desc,
  t.cntxt_nm_dn tgt_cntxt_nm_dn,
	tme.ITEM_LONG_NM tgt_me_item_nm, tme.ITEM_PHY_OBJ_NM tgt_me_phy_nm, tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  tmec."DE_CONC_ITEM_ID" tgt_DE_CONC_ITEM_ID,tmec."DE_CONC_VER_NR" tgt_DE_CONC_VER_NR,tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" tgt_MEC_LONG_NM ,tmec."MEC_PHY_NM" tgt_MEC_PHY_NM, tmec."CDE_ITEM_ID" tgt_CDE_ITEM_ID,tmec."CDE_VER_NR" tgt_CDE_VER_NR ,
      map.map_deg mec_map_deg, map.mec_map_nm, map.mec_map_desc, map.direct_typ mec_direct_typ, map.mec_grp_rul_nbr, map.mec_sub_grp_nbr, map.mec_map_notes, map.valid_pltform,
      map.crdnlity_id mec_map_crdnlity_id,map.prov_org_id mec_map_prov_org_id, map.prov_cntct_id mec_map_prov_cntct_id, map.prov_rsn_txt mec_map_prov_rsn_txt,
      map.prov_typ_rvw_txt mec_map_prov_typ_rvw_txt
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID;




  CREATE OR REPLACE  VIEW VW_MDL_VAL_MAP_FLAT AS
  select  s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm src_mdl_item_nm, s.item_desc src_mdl_item_desc,
  s.cntxt_nm_dn src_cntxt_nm_dn, sme.item_id SRC_ME_ITEM_ID, 
  sme.ver_nr SRC_me_VER_NR,
	sme.ITEM_LONG_NM SRC_me_item_nm, sme.ITEM_PHY_OBJ_NM SRC_me_phy_nm, smec."MEC_ID" SRC_MEC_ID, 
	  smec."MEC_TYP_ID" SRC_MEC_TYP_ID,map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  smec."DE_CONC_ITEM_ID" SRC_DE_CONC_ITEM_ID,smec."DE_CONC_VER_NR" SRC_DE_CONC_VER_NR,smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" SRC_MEC_LONG_NM ,smec."MEC_PHY_NM" SRC_MEC_PHY_NM, smec."CDE_ITEM_ID" SRC_CDE_ITEM_ID,smec."CDE_VER_NR" SRC_CDE_VER_NR,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm,  t.item_desc tgt_mdl_item_desc,
  t.cntxt_nm_dn tgt_cntxt_nm_dn,
	tme.ITEM_LONG_NM tgt_me_item_nm, tme.ITEM_PHY_OBJ_NM tgt_me_phy_nm, tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  tmec."DE_CONC_ITEM_ID" tgt_DE_CONC_ITEM_ID,tmec."DE_CONC_VER_NR" tgt_DE_CONC_VER_NR,tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" tgt_MEC_LONG_NM ,tmec."MEC_PHY_NM" tgt_MEC_PHY_NM, tmec."CDE_ITEM_ID" tgt_CDE_ITEM_ID,tmec."CDE_VER_NR" tgt_CDE_VER_NR ,
     map.prov_org_id mecv_prov_org_id, map.prov_cntct_id mecv_prov_cntct_id, map.prov_rsn_txt mecv_prov_rsn_txt,
      map.prov_typ_rvw_txt mec_map_prov_typ_rvw_txt, map.src_pv, map.tgt_pv, map.vm_cncpt_cd, map.vm_cncpt_nm
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_VAL_MAP map
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID;

*/

create or replace view vw_mdl_flat as
select ai.item_id "Model Public ID", 
	ai.ver_nr  "Model Version", 
	ai.item_long_nm  "Model Name", 
	ai.item_desc  "Model Definition",
--	ai.cntxt_item_id mdl_cntxt_item_id, 
--  	ai.cntxt_ver_nr  mdl_cntxt_ver_nr,
        ai.cntxt_nm_dn  "Model Context", 
--	ai.admin_stus_id mdl_admin_stus_id, 
--	ai.regstr_stus_id mdl_regstr_stus_id,
	ai.admin_stus_nm_dn  "Model Workflow Status", 
	ai.regstr_stus_nm_dn  "Model Registration Status",
--	mdl.prmry_mdl_lang_id, 
	mdl_lang.obj_key_desc "Primary Modelling Language" ,
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
	me.item_id "Element ID", 
	me.ver_nr "Element Version", 
--	mec.creat_dt, 
--	mec.creat_usr_id, 
--	mec.lst_upd_dt, 
--	mec.lst_upd_usr_id, 
--	mec.s2p_trn_dt, 
--	mec.fld_delete, 
--	mec.lst_del_dt,
	mec.src_dttype "Characteristics Source Data Type", 
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



  CREATE OR REPLACE  VIEW VW_MDL_MAP_FLAT AS
  select  s.item_id "Source Model Public ID",
	s.ver_nr "Source Model Version", 
	  s.item_nm "Source Model Name", 
	  s.item_desc "Source Model Definition",
  s.cntxt_nm_dn "Source Model Context", 
	  sme.item_id "Source Element ID", 
  sme.ver_nr "Source Element Version",
	sme.ITEM_LONG_NM "Source Element Name", 
	  sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
	--  smec."MEC_ID" SRC_MEC_ID, 
	 -- smec."MEC_TYP_ID" SRC_MEC_TYP_ID,
	  --map."CREAT_DT",
	  --map."CREAT_USR_ID",
	  --map."LST_UPD_USR_ID",
	  --map."FLD_DELETE",
	  --map."LST_DEL_DT",
	  --map."S2P_TRN_DT",
	  --map."LST_UPD_DT",
	   smec."DE_CONC_ITEM_ID" "Source DEC Public ID",
	  smec."DE_CONC_VER_NR" "Source DEC Version",
	  --smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" "Source Characteristic Name" ,
	  smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	  smec."CDE_ITEM_ID" "Source CDE Public ID",
	  smec."CDE_VER_NR" "Source CDE Version",
	   t.item_id "Target Model Public ID", 
	  t.ver_nr "Target Model Version", 
	  t.item_nm "Target Model Name",  
	  t.item_desc "Target Model Definition",
  	 t.cntxt_nm_dn "Target Model Context",
	  tme.ITEM_LONG_NM "Target Element Name", 
	  tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
	  --tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	--tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  
	  tmec."DE_CONC_ITEM_ID" "Target DEC Public Id",
	  tmec."DE_CONC_VER_NR" "Target DEC Version",
	  --tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  --tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" "Target Characteristic Name" ,
	  tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
	  tmec."CDE_ITEM_ID" "Target CDE ID",
	  tmec."CDE_VER_NR" "Target CDE Version" ,
           -- map.map_deg mec_map_deg, 
	  map.mec_map_nm "Mapping Name", 
	  map.mec_map_desc "Mapping Definition", 
	  --map.direct_typ , 
	  map.mec_grp_rul_nbr "Mapping Group #", 
	  map.mec_sub_grp_nbr "Group Precedence/Sub Group", 
	  map.mec_map_notes "Notes",
	  --map.valid_pltform,
      --map.crdnlity_id mec_map_crdnlity_id,
	  --map.prov_org_id mec_map_prov_org_id, 
	  --map.prov_cntct_id mec_map_prov_cntct_id, 
	  map.prov_rsn_txt "Provenance Reason Text",
      map.prov_typ_rvw_txt "Provenance Type of Review"
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key direct,
	  obj_key deg,
	  obj_key plat,
	  nci_org org
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.direct_typ = direct.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crc.obj_key_id (+);




  CREATE OR REPLACE  VIEW VW_MDL_VAL_MAP_FLAT AS
  select  s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm src_mdl_item_nm, s.item_desc src_mdl_item_desc,
  s.cntxt_nm_dn src_cntxt_nm_dn, sme.item_id SRC_ME_ITEM_ID, 
  sme.ver_nr SRC_me_VER_NR,
	sme.ITEM_LONG_NM SRC_me_item_nm, sme.ITEM_PHY_OBJ_NM SRC_me_phy_nm, smec."MEC_ID" SRC_MEC_ID, 
	  smec."MEC_TYP_ID" SRC_MEC_TYP_ID,map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  smec."DE_CONC_ITEM_ID" SRC_DE_CONC_ITEM_ID,smec."DE_CONC_VER_NR" SRC_DE_CONC_VER_NR,smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" SRC_MEC_LONG_NM ,smec."MEC_PHY_NM" SRC_MEC_PHY_NM, smec."CDE_ITEM_ID" SRC_CDE_ITEM_ID,smec."CDE_VER_NR" SRC_CDE_VER_NR,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm,  t.item_desc tgt_mdl_item_desc,
  t.cntxt_nm_dn tgt_cntxt_nm_dn,
	tme.ITEM_LONG_NM tgt_me_item_nm, tme.ITEM_PHY_OBJ_NM tgt_me_phy_nm, tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  tmec."DE_CONC_ITEM_ID" tgt_DE_CONC_ITEM_ID,tmec."DE_CONC_VER_NR" tgt_DE_CONC_VER_NR,tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" tgt_MEC_LONG_NM ,tmec."MEC_PHY_NM" tgt_MEC_PHY_NM, tmec."CDE_ITEM_ID" tgt_CDE_ITEM_ID,tmec."CDE_VER_NR" tgt_CDE_VER_NR ,
     map.prov_org_id mecv_prov_org_id, map.prov_cntct_id mecv_prov_cntct_id, map.prov_rsn_txt mecv_prov_rsn_txt,
      map.prov_typ_rvw_txt mec_map_prov_typ_rvw_txt, map.src_pv, map.tgt_pv, map.vm_cncpt_cd, map.vm_cncpt_nm
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_VAL_MAP map
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID;
