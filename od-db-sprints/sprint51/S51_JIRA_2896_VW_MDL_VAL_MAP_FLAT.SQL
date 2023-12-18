CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_VAL_MAP_FLAT ("Source Model Public ID", "Source Model Version", "Source Model Name", "Source Element ID", "Source Element Version", "Source Element Physical Name", "Source Characteristic Physical Name", "Source CDE Public ID", "Source CDE Version", "Target Model Public ID", "Target Model Version", "Target Model Name", "Target Element Physical Name", "Target Characteristic Physical Name", "Target CDE ID", "Target CDE Version", "Source PV", "Target PV", "VM Concept Code", "VM Concept Name", "Provenance Organization", "Provenance Contact", "Provenance Reason", "Provenance Type of Review", "Provenance Review Date", "Provenance Approval Date", "Provenance Notes") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select  s.item_id  "Source Model Public ID",
	  s.ver_nr  "Source Model Version", 
	  s.item_nm  "Source Model Name",
	  --s.item_desc  "Source Model Definition", --REMOVED
      --s.cntxt_nm_dn "Source Model Context",  --REMOVED
	  sme.item_id "Source Element ID", 
  sme.ver_nr "Source Element Version",
	--sme.ITEM_LONG_NM "Source Element Name",  --REMOVED
	  sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
	--  smec."MEC_ID" SRC_MEC_ID, 
	 -- smec."MEC_TYP_ID" SRC_MEC_TYP_ID,
	  --map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  -- smec."DE_CONC_ITEM_ID" "Source DEC Public ID", --REMOVED
	  --smec."DE_CONC_VER_NR" "Source DEC Version", --REMOVED
	  --smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  --smec."MEC_LONG_NM" "Source Characteristic Name" , --REMOVED
	  smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	  smec."CDE_ITEM_ID" "Source CDE Public ID",
	  smec."CDE_VER_NR" "Source CDE Version",
	   t.item_id "Target Model Public ID", 
	  t.ver_nr "Target Model Version", 
	  t.item_nm "Target Model Name",  
	  --t.item_desc "Target Model Definition", --REMOVED
  	 --t.cntxt_nm_dn "Target Model Context", --REMOVED
	  --tme.ITEM_LONG_NM "Target Element Name",  --REMOVED
	  tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
	  --tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	--tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  
	  --tmec."DE_CONC_ITEM_ID" "Target DEC Public Id", --REMOVED
	  --tmec."DE_CONC_VER_NR" "Target DEC Version", --REMOVED
	  --tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  --tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  --tmec."MEC_LONG_NM" "Target Characteristic Name" , --REMOVED
	  tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
	  tmec."CDE_ITEM_ID" "Target CDE ID",
	  tmec."CDE_VER_NR" "Target CDE Version" ,
	 map.src_pv "Source PV",
     map.tgt_pv "Target PV",
      map.vm_cncpt_cd "VM Concept Code", 
      map.vm_cncpt_nm "VM Concept Name",
      org.org_nm "Provenance Organization",
      c.cntct_nm    "Provenance Contact",
	  --map.prov_cntct_id mec_map_prov_cntct_id, 
	  map.prov_rsn_txt "Provenance Reason",
      map.prov_typ_rvw_txt "Provenance Type of Review",
      map.prov_rvw_dt "Provenance Review Date",   
      map.prov_aprv_dt "Provenance Approval Date",
      map.prov_notes "Provenance Notes"
FROM admin_item s, 
    NCI_MDL_ELMNT sme,
    NCI_MDL_ELMNT_CHAR smec, 
    admin_item t, 
    NCI_MDL_ELMNT tme,
    NCI_MDL_ELMNT_CHAR tmec, 
    nci_MEC_VAL_MAP map, 
    nci_org org,
    CNTCT c
where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID
	  and map.prov_org_id = org.entty_id (+)
      AND map.PROV_CNTCT_ID = c.cntct_id (+);
