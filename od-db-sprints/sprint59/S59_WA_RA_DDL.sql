alter table cncpt add (PRMRY_OBJ_CLS_IND number(1));

drop materialized view vw_cncpt;

  CREATE MATERIALIZED VIEW VW_CNCPT 
  AS SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, '.' ||ADMIN_ITEM.ITEM_NM ||'.' ITEM_NM_PERIOD,  '.' ||ADMIN_ITEM.ITEM_LONG_NM || '.' ITEM_LONG_NM_PERIOD, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CNTXT_ITEM_ID,
ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.CNTXT_NM_DN,
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC, e.CNCPT_CONCAT_WITH_INT,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC,
		      trim(OBJ_KEY.OBJ_KEY_DESC) EVS_SRC_ORI,
			cncpt.evs_Src_id,nvl(cncpt.ref_term_ind,0) REF_TERM_IND,
		      nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') || '|' ||
		      nvl(decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC), 'No EVS Source') DEF_EVS_SRC,
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN,substr(a.SYN_MTCH_TERM,1,4000) SYN_MTCH_TERM, MTCH_TERM, MTCH_TERM_ADV,
    nvl(PRMRY_OBJ_CLS_IND,0) PRMRY_OBJ_CLS_IND,  decode(PRMRY_OBJ_CLS_IND,1,'Yes','') PRMRY_OBJ_CLS_IND_NM
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,   LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+);


alter table admin_item add (LST_UPD_DT_X date default sysdate);
  

  CREATE OR REPLACE  VIEW VW_MDL_MAP_IMP_TEMPLATE ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "MAPPING_GROUP_DESC", "SOURCE_FUNCTION", "TARGET_FUNCTION", "MAPPING_DEGREE", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_NBR", "DERIVATION_GROUP_ORDER", "SOURCE_COMPARISON_VALUE", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE", "TGT_ELMNT_PHY_NAME_DERV") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE"
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


  CREATE OR REPLACE  VIEW VW_NCI_DE_CNCPT AS
  SELECT  '5. Object Class' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
		a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL, 5 ADMIN_ITEM_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID and
	a.VER_NR = DE_CONC.OBJ_CLS_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '4. Property' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND,  NCI_CNCPT_VAL, 6 ADMIN_ITEM_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC where
	a.ITEM_ID = DE_CONC.PROP_ITEM_ID and
	a.VER_NR = DE_CONC.PROP_VER_NR and
	DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID and
	DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	union
         SELECT '3. Representation Term' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL, 7 ADMIN_ITEM_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD where
	a.ITEM_ID = VD.REP_CLS_ITEM_ID and
	a.VER_NR = VD.REP_CLS_VER_NR and
	DE.VAL_DOM_ITEM_ID = VD.ITEM_ID and
	DE.VAL_DOM_VER_NR = VD.VER_NR
	union
         SELECT '1. Value Meaning' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, a.NCI_CNCPT_VAL, 53 ADMIN_ITEM_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV where
	a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID and
	a.VER_NR = PV.NCI_VAL_MEAN_VER_NR and
	DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID and
	DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR and nvl(pv.fld_delete,0) = 0
	union
         SELECT '2. Value Domain' ALT_NMS_LVL, DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR,
		a.ITEM_ID, a.VER_NR,
		a.CNCPT_ITEM_ID, a.CNCPT_VER_NR,
        	a.CREAT_DT, a.CREAT_USR_ID, a.LST_UPD_USR_ID,
		a.FLD_DELETE, a.LST_DEL_DT, a.S2P_TRN_DT,
		a.LST_UPD_DT, a.NCI_ORD, a.NCI_PRMRY_IND, NCI_CNCPT_VAL, 3 ADMIN_ITEM_TYP_ID
       FROM CNCPT_ADMIN_ITEM a, DE where
	DE.VAL_DOM_ITEM_ID = a.ITEM_ID and
	DE.VAL_DOM_VER_NR = a.VER_NR;

