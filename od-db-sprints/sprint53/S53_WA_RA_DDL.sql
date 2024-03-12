alter table value_dom add (TERM_USE_TYP  integer);


insert into obj_typ (obj_typ_id, obj_typ_desc) values
(55, 'Terminology Reference VD Type');
commit;

  CREATE OR REPLACE FORCE VIEW VW_MDL_MAP_FLAT AS
  select  map.MDL_MAP_ITEM_ID "Model Map ID",
         map.mdl_map_ver_nr "Model Map Version",
         m.ADMIN_STUS_NM_DN "Model Map Status",
        m.CURRNT_VER_IND "Model Map Latest Version Indicator",
        s.item_id "Source Model Public ID",
        s.ver_nr "Source Model Version", 
        s.item_nm "Source Model Name", 
         s.ADMIN_STUS_NM_DN "Source Model Status",
        t.item_id "Target Model Public ID", 
        t.ver_nr "Target Model Version", 
        t.item_nm "Target Model Name",  
         t.ADMIN_STUS_NM_DN "Target Model Status",
     --   map.MECM_ID "Rule ID",
        map.mec_map_nm "Characteristic Group Name",
        map.MEC_GRP_RUL_NBR "Derivation Group Nbr",
       crd.obj_key_desc "Mapping Cardinality",
   decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "Values Mapped Indicator",
        sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
        smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	smec.char_ord "Source Char Order",        
smec."CDE_ITEM_ID" "Source CDE Public ID",
        smec."CDE_VER_NR" "Source CDE Version",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "Source VD Type",
          src_func.obj_key_Desc "Source Function",
	--map.SRC_FUNC_PARAM "Source Function Parameter",
	   map.SRC_VAL "Source Value",
        tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
       tmec.char_ord "Target Char Order",        
        tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
        tmec."CDE_ITEM_ID" "Target CDE Public ID",
        tmec."CDE_VER_NR" "Target CDE Version" ,
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "Target VD Type",
       tgt_func.obj_key_Desc "Target Function",
	map.TGT_FUNC_PARAM "Target Function Parameter",
        map.TGT_VAL "Target Value",
        map.mec_sub_grp_nbr "Group Order",
        map.mec_map_notes "Transformation Notes",
        map.MEC_MAP_NOTES "Transformation Rule",
        map.TRANS_RUL_NOT "Transformation Rule Notation",
        deg.obj_key_Desc "Mapping Type",
        map.valid_pltform	   "Validation Platform",
        org.org_nm "Provenance Organization",
        c.PRSN_FULL_NM_DERV  "Provenance Contact",
        --map.prov_cntct_id mec_map_prov_cntct_id, 
        map.prov_rsn_txt "Provenance Reason",
        map.prov_typ_rvw_txt "Provenance Type of Review",
        map.prov_rvw_dt "Provenance Review Date",   
        map.prov_aprv_dt "Provenance Approval Date",
	    m.creat_dt "Model Map Create Date",
	  m.creat_usr_id "Model Map Create User",	  
	  m.lst_upd_dt "Model Map Last Update Date",
	  m.lst_upd_usr_id "Model Map Last Update User",	  
	  map.creat_dt "Characteristic Map Create Date",
	  map.creat_usr_id "Characteristic Map Create User",	  
	  map.lst_upd_dt "Characteristic Map Last Update Date",
	  map.lst_upd_usr_id "Characteristic Map Last Update User"  
        --map.prov_notes "Provenance Notes"
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
admin_item m,
	  obj_key crd,
	  obj_key deg,
	  nci_org org,
 obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
         value_dom svd,
value_dom tvd,
    nci_prsn c
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID and
map.mdl_map_item_id = m.item_id and map.mdl_map_ver_nr = m.ver_nr 
	  and map.map_deg = deg.obj_key_id (+)
 and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+)
 and map.op_id = op.obj_key_id (+)
and map.prov_cntct_id  = c.entty_ID (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);


  CREATE OR REPLACE FORCE VIEW VW_MDL_MAP_LIST AS
  select  m.ITEM_ID "Model Map ID",
         m.ver_nr "Model Map Version",
	m.ITEM_NM "Model Map Name",
         m.ADMIN_STUS_NM_DN "Model Map Status",
	m.cntxt_nm_dn "Model Map Context",
           decode(m.CURRNT_VER_IND,1,'Yes',0,'No') "Model Map Latest Version Indicator",
     s.item_id "Source Model Public ID",
        s.ver_nr "Source Model Version", 
        s.item_nm "Source Model Name",
         s.ADMIN_STUS_NM_DN "Source Model Status",
	s.cntxt_nm_dn "Source Model Context",
        t.item_id "Target Model Public ID", 
        t.ver_nr "Target Model Version", 
        t.item_nm "Target Model Name",  
         t.ADMIN_STUS_NM_DN "Target Model Status",
	t.cntxt_nm_dn "Target Model Context",
        org.org_nm "Provenance Organization",
	p.PRSN_FULL_NM_DERV  "Provenance Contact",
	   m.creat_dt "Model Map Create Date",
	  m.creat_usr_id "Model Map Create User",	  
	  m.lst_upd_dt "Model Map Last Update Date",
	  m.lst_upd_usr_id "Model Map Last Update User"
     from admin_item s,  admin_item t, nci_mdl_map mm,
admin_item m, nci_org org, nci_prsn p
	where m.item_id = mm.item_id and m.ver_nr = mm.ver_nr and mm.SRC_MDL_ITEM_ID= s.item_id and mm.TGT_MDL_ITEM_ID= t.item_id 
and mm.SRC_MDL_VER_NR = s.ver_nr and mm.TGT_MDL_VER_NR = t.ver_nr 
 and mm.PROV_ORG_ID = org.entty_id (+)
and mm.prov_cntct_id  = p.entty_ID (+);




  CREATE OR REPLACE  VIEW VW_MDL_MAP_IMP_TEMPLATE AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       map.mdl_map_item_id "MODEL_MAP_ID",
       map.mdl_map_ver_nr "MODEL_MAP_VERSION",
        map.mecm_id "MECM_ID", 
        smec.char_ord SRC_CHAR_ORD,
	sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	sme.ITEM_LONG_NM "SRC_ELMNT_NAME", 
  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	smec.MEC_LONG_NM "SRC_MEC_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	 sme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
          map.MEC_MAP_DESC "MAPPING_GROUP_DESC",
	  src_func.obj_key_Desc "SOURCE_FUNCTION",
	  tgt_func.obj_key_Desc "TARGET_FUNCTION",
	  crd.obj_key_desc "MAPPING_CARDINALITY",
	  deg.obj_key_Desc "MAPPING_DEGREE",
          ' ' "TRANS_RULE_NOTATION",
map.mec_grp_rul_nbr "DERIVATION_GROUP_NBR",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
	map.SRC_VAL "SOURCE_COMPARISON_VALUE",
	map.TGT_VAL "SET_TARGET_DEFAULT"	,
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"	,
	op.obj_key_desc "OPERATOR",
  map.valid_pltform	   "VALIDATION_PLATFORM",
	map.mec_map_notes "TRANSFORMATION_NOTES",
	map.TRNS_DESC_TXT "TRANSFORMATION_RULE",
	org.org_nm "PROV_ORG",
' '	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
	   map."CREAT_DT",
	  map."CREAT_USR_ID",
	  map."LST_UPD_USR_ID",
	  map."FLD_DELETE",
	  map."LST_DEL_DT",
	  map."S2P_TRN_DT",
	  map."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+)
	  and map.op_id = op.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+);

alter table nci_stg_MEC_MAP add (SRC_ME_ITEM_NM varchar2(255), SRC_MEC_ITEM_NM varchar2(255), TGT_ME_ITEM_NM varchar2(255), TGT_MEC_ITEM_NM varchar2(255));

alter table VALUE_DOM add (TERM_CNCPT_ITEM_ID number, TERM_CNCPT_VER_NR number(4,2));
insert into obj_key (obj_typ_Id, obj_key_id, obj_key_desc) values (7, 16,'Enumerated by Reference');
commit;


  CREATE OR REPLACE  VIEW VW_CNCPT_XMAP AS
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,'')) ICD_O_CODE,
  max(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,'')) ICD_O_DESC,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_Cd,'')) SNOMED_CODE,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_DESC,'')) SNOMED_DESC,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,'')) MEDDRA_CODE,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,'')) MEDDRA_DESC,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,'')) LOINC_CODE,
  max(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,'')) LOINC_DESC,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,'')) HUGO_CODE,
  max(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,'')) HUGO_CODE_DESC,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,'')) ICD_10_CM_CODE,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,'')) ICD_10_CM_DESC,
	    max(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_Cd,'')) OMOP_CODE,
  max(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_DESC,'')) OMOP_DESC,
 max(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_Cd,'')) META_CUI_CODE,
  max(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_DESC,'')) META_CUI_DESC,
	  max(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_Cd,'')) MED_RT_CODE,
  max(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_DESC,'')) MED_RT_DESC,
	  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_Cd,'')) ICD_10_PCS_CODE,
  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_DESC,'')) ICD_10_PCS_DESC,
	  max(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_Cd,'')) NCBI_CODE,
  max(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_DESC,'')) NCBI_DESC,
	  max(decode(o.obj_key_desc, 'HPO_CODE', XMAP_Cd,'')) HPO_CODE,
  max(decode(o.obj_key_desc, 'HPO_CODE', XMAP_DESC,'')) HPO_DESC,
	  max(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_Cd,'')) HCPCS_CODE,
  max(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_DESC,'')) HCPCS_DESC,
   max(decode(o.obj_key_desc, 'ICD-O_CODE', TERM_TYP,'')) ICD_O_TERM_TYP,
  max(decode(o.obj_key_desc, 'SNOMED-CT_CODE', TERM_TYP,'')) SNOMED_TERM_TYP,
  max(decode(o.obj_key_desc, 'MEDDRA_CODE', TERM_TYP,'')) MEDDRA_TERM_TYP,
  max(decode(o.obj_key_desc, 'LOINC_CODE', TERM_TYP,'')) LOINC_TERM_TYP,
  max(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,'')) HUGO_TERM_TYP,
  max(decode(o.obj_key_desc, 'ICD-10-CM_CODE', TERM_TYP,'')) ICD_10_CM_TERM_TYP,
 max(decode(o.obj_key_desc, 'NCI_META_CUI', TERM_TYP,'')) META_CUI_TERM_TYP,
	  max(decode(o.obj_key_desc, 'MED_RT_CODE', TERM_TYP,'')) MED_RT_TERM_TYP,
	  max(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', TERM_TYP,'')) ICD_10_PCS_TERM_TYP,
	  max(decode(o.obj_key_desc, 'NCBI_CODE', TERM_TYP,'')) NCBI_TERM_TYP,
	  max(decode(o.obj_key_desc, 'HPO_CODE', TERM_TYP,'')) HPO_TERM_TYP,
	  max(decode(o.obj_key_desc, 'HCPCS_CODE', TERM_TYP,'')) HCPCS_TERM_TYP,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind = 1
       group by xmap.item_id, xmap.ver_nr;


  CREATE OR REPLACE  VIEW VW_MDL_FLAT AS
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
	cde.cntxt_nm_dn "CDE Context",
	      ai.creat_dt "Model Create Date",
	  ai.creat_usr_id "Model Create User",	  
	  ai.lst_upd_dt "Model Last Update Date",
	  ai.lst_upd_usr_id "Model Last Update User",
	       me.creat_dt "Element Create Date",
	  me.creat_usr_id "Element Create User",	  
	  me.lst_upd_dt "Element Last Update Date",
	  me.lst_upd_usr_id "Element Last Update User",
	     mec.creat_dt "Characteristic Create Date",
	  mec.creat_usr_id "Characteristic Create User",	  
	  mec.lst_upd_dt "Characteristic Last Update Date",
	  mec.lst_upd_usr_id "Characteristic Last Update User"
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

--jira 3177: add missing index on admin_item
CREATE UNIQUE INDEX IDX_ADMIN_ITEM_NCI_UNI ON ADMIN_ITEM ("ADMIN_ITEM_TYP_ID", "ITEM_LONG_NM", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "VER_NR") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;


