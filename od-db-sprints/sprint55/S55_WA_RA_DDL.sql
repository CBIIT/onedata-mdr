
alter table nci_stg_mdl_elmnt_char add (CTL_VAL_MSG varchar2(1000));
alter table nci_stg_mdl_elmnt add (CTL_VAL_MSG varchar2(1000));
alter table NCI_MEC_VAL_MAP add ( MAP_DEG integer);

alter table NCI_MDL add ( ASSOC_TBL_NM_TYP_ID integer, ASSOC_CS_ITEM_ID number, ASSOC_CS_VER_NR number(4,2));
alter table NCI_MDL_ELMNT_CHAR add ( CHNG_DESC_TXT varchar2(4000));



delete from nci_cncpt_rel where (c_item_id, c_item_ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

delete from cncpt where (item_id, ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

delete from admin_item where (item_id, ver_nr) in 
(select item_id, ver_nr from vw_cncpt where evs_src_Id in (select obj_key_id from obj_key where obj_typ_id = 23 and obj_key_desc = 'MEDDRA_CODE')
and item_desc like '%25.1'
and (item_id, ver_nr) not in (Select cncpt_item_id, cncpt_ver_nr from cncpt_admin_item));

commit;


  CREATE OR REPLACE  VIEW "VW_MDL_MAP_IMP_TEMPLATE" ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "MAPPING_GROUP_DESC", "SOURCE_FUNCTION", "TARGET_FUNCTION", "MAPPING_CARDINALITY", "MAPPING_DEGREE", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_NBR", "DERIVATION_GROUP_ORDER", "SOURCE_COMPARISON_VALUE", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
	  crd.obj_key_desc "MAPPING_CARDINALITY",
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
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  obj_key crd,
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
	   smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
	  and map.map_deg = deg.obj_key_id (+)
	  and map.src_func_id= src_func.obj_key_id (+)
	  and map.tgt_func_id= tgt_func.obj_key_id (+)
	  and map.prov_org_id = org.entty_id (+)
	  and map.crdnlity_id = crd.obj_key_id (+)
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

insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (129,'No CDE',45,'No CDE','No CDE','No CDE' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (130,'Not Mapped',45,'Not Mapped','Not Mapped','Not Mapped' );
commit;
