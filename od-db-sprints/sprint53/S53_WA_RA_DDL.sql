
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
        map.MECM_ID "Rule ID",
        map.mec_map_nm "Characteristic Group Name",
        map.MEC_GRP_RUL_NBR "Derivation Group Nbr",
       crd.obj_key_desc "Mapping Cardinality",
   decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "Values Mapped?",
        sme.ITEM_PHY_OBJ_NM "Source Element Physical Name", 
        smec."MEC_PHY_NM" "Source Characteristic Physical Name", 
	smec.char_ord "Source Char Order",        
smec."CDE_ITEM_ID" "Source CDE Public ID",
        smec."CDE_VER_NR" "Source CDE Version",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "Source VD Type",
          src_func.obj_key_Desc "Source Function",
	--map.SRC_FUNC_PARAM "Source Function Parameter",
	   map.SRC_VAL "Source Value",
        tme.ITEM_PHY_OBJ_NM "Target Element Physical Name", 
       tmec.char_ord "Target Char Order",        
        tmec."MEC_PHY_NM" "Target Characteristic Physical Name", 
        tmec."CDE_ITEM_ID" "Target CDE Public ID",
        tmec."CDE_VER_NR" "Target CDE Version" ,
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "Target VD Type",
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
        map.prov_aprv_dt "Provenance Approval Date"
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
	p.PRSN_FULL_NM_DERV  "Provenance Contact"
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
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated')  "TARGET_DOMAIN_TYPE",
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

