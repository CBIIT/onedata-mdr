alter table NCI_MDL add (MAP_USG_TYP_ID integer);

insert into obj_typ(obj_typ_id, obj_typ_desc) values (61,'Model Usage Type for Mapping');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,135, 'Source Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,136, 'Target Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,137, 'Source or Target');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,138, 'Do Not Use');
commit

	alter table nci_mdl disable all triggers;
	update nci_mdl set 	MAP_USG_TYP_ID = 137 where 	MAP_USG_TYP_ID is null;
commit;
alter table nci_mdl enable all triggers;

alter table NCI_MEC_MAP add (PCODE_SYSGEN varchar2(4000));

alter table NCI_MEC_MAP add (MEC_MAP_NM_GEN varchar2(4000));

  CREATE OR REPLACE  VIEW VW_NCI_MDL AS
  select
	ai."ITEM_ID",ai."VER_NR",
    ai."ITEM_DESC",ai."CNTXT_ITEM_ID",ai."CNTXT_VER_NR",ai."ITEM_LONG_NM",ai."ITEM_NM",ai."ADMIN_NOTES",
    ai."CHNG_DESC_TXT",ai."EFF_DT",ai."ORIGIN",ai."ADMIN_ITEM_TYP_ID",
    ai."CURRNT_VER_IND",ai."ADMIN_STUS_ID",ai."REGSTR_STUS_ID",ai."CREAT_DT",
    ai."CREAT_USR_ID",ai."LST_UPD_USR_ID",ai."FLD_DELETE",ai."LST_DEL_DT",ai."S2P_TRN_DT",ai."LST_UPD_DT",
    ai."ADMIN_STUS_NM_DN",ai."CNTXT_NM_DN",ai."REGSTR_STUS_NM_DN",ai."ORIGIN_ID",
   m.prmry_mdl_lang_id ,
    m.map_usg_Typ_id from admin_item ai, nci_mdl m where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 57;


  CREATE OR REPLACE  VIEW VW_CNCPT_XMAP AS
  SELECT XMAP.ITEM_ID, XMAP.VER_NR, 
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-O_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_DESC,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_CODE,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_DESC,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_CODE,
 listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_DESC,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_CODE,
 listagg(decode(o.obj_key_desc, 'LOINC_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_DESC,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HGNC_CODE,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD)HGNC_CODE_DESC,
  listagg(decode(o.obj_key_desc, 'GO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) GO_CODE,
  listagg(decode(o.obj_key_desc, 'GO_CODE', XMAP_desc,''),'|') WITHIN GROUP (ORDER by XMAP_CD)GO_CODE_DESC,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_DESC,
	   listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) OMOP_CODE,
  listagg(decode(o.obj_key_desc, 'OMOP_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) OMOP_DESC,
	   listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) UBERON_CODE,
  listagg(decode(o.obj_key_desc, 'UBERON_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) UBERON_DESC,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD)META_CUI_CODE,
  listagg(decode(o.obj_key_desc, 'NCI_META_CUI', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_DESC,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_CODE,
  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_DESC,
	 listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_CODE,
  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_DESC,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_CODE,
  listagg(decode(o.obj_key_desc, 'NCBI_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_DESC,
	 listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_CODE,
  listagg(decode(o.obj_key_desc, 'HPO_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_DESC,
	  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_Cd,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_CODE,
  listagg(decode(o.obj_key_desc, 'HCPCS_CODE', XMAP_DESC,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_DESC,
   listagg(decode(o.obj_key_desc, 'ICD-O_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_O_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'SNOMED-CT_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) SNOMED_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'MEDDRA_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MEDDRA_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'LOINC_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) LOINC_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'HUGO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HGNC_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'GO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) GO_TERM_TYP,
  listagg(decode(o.obj_key_desc, 'ICD-10-CM_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_CM_TERM_TYP,
 listagg(decode(o.obj_key_desc, 'NCI_META_CUI', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) META_CUI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'MED_RT_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) MED_RT_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'ICD-10-PCS_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) ICD_10_PCS_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'NCBI_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) NCBI_TERM_TYP,
	  listagg(decode(o.obj_key_desc, 'HPO_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HPO_TERM_TYP,
	 listagg(decode(o.obj_key_desc, 'HCPCS_CODE', TERM_TYP,''),'|') WITHIN GROUP (ORDER by XMAP_CD) HCPCS_TERM_TYP,
  sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT 
       FROM NCI_ADMIN_ITEM_XMAP xmap, obj_key o
       WHERE o.obj_typ_id = 23 and o.obj_key_id = xmap.evs_src_id and pref_ind != 0 and xmap.item_id <> 0
       group by xmap.item_id, xmap.ver_nr;

alter table nci_mec_Map modify (TRNS_DESC_TXT varchar2(8000));

alter table nci_stg_mec_Map modify (TRNS_DESC_TXT varchar2(8000));


  CREATE OR REPLACE VIEW VW_MDL_MAP_IMP_TEMPLATE AS
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
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
          map.MEC_MAP_DESC "MAPPING_GROUP_DESC",
	  src_func.obj_key_Desc "SOURCE_FUNCTION",
	  tgt_func.obj_key_Desc "TARGET_FUNCTION",
	  deg.obj_key_Desc "MAPPING_DEGREE",
          ' ' "TRANS_RULE_NOTATION",
map.mec_grp_rul_nbr "DERIVATION_GROUP_NBR",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
	map.SRC_VAL "SOURCE_COMPARISON_VALUE",
	map.TGT_VAL "SET_TARGET_DEFAULT"	,
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"	,
	op.obj_key_desc "OPERATOR",
	op_typ.obj_key_desc "OPERAND_TYPE",
	flow_cntrl.obj_key_desc "FLOW_CONTROL",
	paren.obj_key_desc "PARENTHESIS",
	map.right_op "RIGHT_OPERAND",
	map.left_op "LEFT_OPERAND",
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
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND,
svdrt.TERM_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_NAME "TARGET_REF_TERM_SOURCE"
	, tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
	  obj_key deg,
	  obj_key src_func,
	  obj_key tgt_func,
	  obj_key op,
	  obj_key op_typ,
	  obj_key flow_cntrl,
	  obj_key paren,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	 tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and tmecd.mec_id (+)= map.TGT_MEC_ID_DERV
	  and map.map_deg = deg.obj_key_id (+)
	  and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.op_id = op.obj_key_id (+)
	  and map.paren = paren.obj_key_id (+)
	  and map.op_typ = op_typ.obj_key_id (+)
	  and map.flow_cntrl = flow_cntrl.obj_key_id (+)
          and smec.val_dom_item_id = svd.item_id (+)
	  and smec.val_dom_ver_nr = svd.ver_nr (+)
	  and tmec.val_dom_item_id = tvd.item_id (+)
 	  and tmec.val_dom_ver_nr = tvd.ver_nr (+)
          and svd.item_id = svdrt.item_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+);
