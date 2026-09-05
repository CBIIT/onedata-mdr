
  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT   AS 
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          tmed.ITEM_PHY_OBJ_NM ||  '.'  || tmecd."MEC_PHY_NM"  MEC_PHY_NM,
        --    tmecd."MEC_PHY_NM",
	   --       tmecd.MEC_LONG_NM,
	          tmed.	ITEM_LONG_NM || '.' ||        tmecd.MEC_LONG_NM MEC_LONG_NM,
	  decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') VAL_DOM_TYP,
            map.PCODE_SYSGEN,
	  MEC_MAP_NOTES,
	  TRNS_DESC_TXT,
	  map.PROV_ORG_ID,
	  map.PROV_CNTCT_ID,
	  map.PROV_RSN_TXT,
	  	map.PROV_TYP_RVW_TXT,
	  map.PROV_RVW_DT,
	  map.PROV_APRV_DT,
        sysdate creat_dt,
	  'ONEDATA' creat_usr_id,	  
	   sysdate lst_upd_dt,
	  'ONEDATA' lst_upd_usr_id,
        map.creat_dt creat_dt_x,
	 map.creat_usr_id creat_usr_id_x,	  
	  map.lst_upd_dt lst_upd_dt_x,
	  map.lst_upd_usr_id lst_upd_usr_id_x,
      0 FLD_DELETE,
      sysdate S2P_TRN_DT,
      sysdate LST_DEL_DT,
      decode(map.TRANS_RUL_NOT, 122, 'Text', 124, 'SQL', 123, 'Pseudocode') TRNS_RUL_NOT,
SORT_ORD
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd, VALUE_DOM vd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120,129,130)
and tmecd.VAL_DOM_ITEM_ID = vd.ITEM_ID (+)
	  and tmecd.VAL_DOM_VER_NR = vd.VER_NR (+)
      and (pcode_sysgen is not null or mec_map_notes is not null);


  CREATE OR REPLACE VIEW "VW_MDL_MAP_IMP_TEMPLATE" ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "TARGET_FUNCTION_ID", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_ORDER", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "PCODE_SYSGEN", "MAP_DEG", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "SOURCE_VD_ITEM_ID", "SOURCE_VD_VER_NR", "TARGET_VD_ITEM_ID", "TARGET_VD_VER_NR", "SRC_MDL_ITEM_ID", "SRC_MDL_VER_NR", "TGT_MDL_ITEM_ID", "TGT_MDL_VER_NR", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE", "TGT_ELMNT_PHY_NAME_DERV", "CMNTS_DESC_TXT", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "CREAT_DT_X", "LST_UPD_DT_X", "SORT_ORD", "TRNS_RUL_NOT_ID", "SOURCE_DEC_ITEM_ID", "SOURCE_DEC_VER", "TARGET_DEC_ITEM_ID", "TARGET_DEC_VER") DEFAULT COLLATION "USING_NLS_COMP"  AS
  select  ' ' "DO_NOT_USE",
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
    map.tgt_func_id "TARGET_FUNCTION_ID",
          ' ' "TRANS_RULE_NOTATION",
map.mec_sub_grp_nbr     "DERIVATION_GROUP_ORDER",
      map.TGT_VAL "SET_TARGET_DEFAULT"    ,
map.TGT_FUNC_PARAM "TARGET_FUNCTION_PARAM"      ,
      op.obj_key_desc "OPERATOR",
      op_typ.obj_key_desc "OPERAND_TYPE",
      flow_cntrl.obj_key_desc "FLOW_CONTROL",
      paren.obj_key_desc "PARENTHESIS",
      map.right_op "RIGHT_OPERAND",
      map.left_op "LEFT_OPERAND",
  map.valid_pltform        "VALIDATION_PLATFORM",
      map.mec_map_notes "TRANSFORMATION_NOTES",
      map.TRNS_DESC_TXT "TRANSFORMATION_RULE",
      org.org_nm "PROV_ORG",
cnt.PRSN_FULL_NM_DERV   "PROV_CONTACT",
      map.prov_rsn_txt "PROV_REVIEW_REASON",
      map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
      map.PROV_RVW_DT "PROV_REVIEW_DATE",
      map.prov_APRV_DT "PROV_APPROVAL_DATE",
        replace(map.pcode_sysgen,chr(13),' ') pcode_sysgen,
        map.map_deg,
decode(nvl(map.VAL_MAP_CREATE_IND,0),1, 'Yes','No') "VALUE_MAP_GENERATED_IND",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
         map."CREAT_DT",
        map."CREAT_USR_ID",
        map."LST_UPD_USR_ID",
        map."FLD_DELETE",
        map."LST_DEL_DT",
        map."S2P_TRN_DT",
        map."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
        smec.val_dom_item_id "SOURCE_VD_ITEM_ID",
        smec.val_dom_ver_nr "SOURCE_VD_VER_NR",
          tmec.val_dom_item_id "TARGET_VD_ITEM_ID",
        tmec.val_dom_ver_nr "TARGET_VD_VER_NR",
        sme.MDL_ITEM_ID SRC_MDL_ITEM_ID,
        sme.MDL_item_ver_nr src_mdl_ver_nr,
        tme.MDL_ITEM_ID TGT_MDL_ITEM_ID,
        tme.MDL_item_ver_nr TGT_mdl_ver_nr,
tmec.MEC_ID TGT_MEC_ID,
tmec.pk_ind TGT_PK_IND,
smec.pk_ind SRC_PK_IND,
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE"
      , tmed.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME_DERV",
    ' ' "CMNTS_DESC_TXT",
        map.creat_usr_id creat_usr_id_x,
        map.lst_upd_usr_id lst_upd_usr_id_x,
        map.creat_dt creat_dt_x,
        map.lst_upd_dt lst_upd_dt_x,
        map.sort_ord,
      map.TRANS_RUL_NOT TRNS_RUL_NOT_ID,
      sdec.de_conc_item_id "SOURCE_DEC_ITEM_ID",
      sdec.de_conc_ver_nr "SOURCE_DEC_VER",
      tdec.de_conc_item_id "TARGET_DEC_ITEM_ID",
      tdec.de_conc_ver_nr "TARGET_DEC_VER"
      from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
        NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
        obj_key op,
        obj_key op_typ,
        obj_key flow_cntrl,
        obj_key paren,
        nci_org org,
        value_dom svd,
        value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt,
        NCI_PRSN cnt,
      vw_de sdec,
      vw_de tdec
      where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
      and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
       tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
      and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
       tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
      and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
         smec.MEC_ID (+)= map.SRC_MEC_ID and tmec.mec_id (+)= map.TGT_MEC_ID
        and tmecd.mec_id (+)= map.TGT_MEC_ID_DERV
        and map.PROV_CNTCT_ID = cnt.entty_id (+)
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
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and sdec.item_id (+)= smec.cde_item_id
          and sdec.ver_nr (+)= smec.cde_ver_nr
          and tdec.item_id (+)= tmec.cde_item_id
          and tdec.ver_nr (+)= tmec.cde_ver_nr;

CREATE OR REPLACE  VIEW "VW_MDL_MAP_RSLT" ("MDL_MAP_ITEM_ID", "MDL_MAP_VER_NR", "MEC_MAP_NM", "MEC_PHY_NM", "MEC_LONG_NM", "VAL_DOM_TYP", "PCODE_SYSGEN", "MEC_MAP_NOTES", "TRNS_DESC_TXT", "PROV_ORG_ID", "PROV_CNTCT_ID", "PROV_RSN_TXT", "PROV_TYP_RVW_TXT", "PROV_RVW_DT", "PROV_APRV_DT", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_DT", "LST_UPD_USR_ID", "CREAT_DT_X", "CREAT_USR_ID_X", "LST_UPD_DT_X", "LST_UPD_USR_ID_X", "FLD_DELETE", "S2P_TRN_DT", "LST_DEL_DT", "TRNS_RUL_NOT", "SORT_ORD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          case when  instr(upper(map.pcode_sysgen),'ENDIF',1)>0 then '' else tmed.ITEM_PHY_OBJ_NM ||  '.'  || tmecd."MEC_PHY_NM" end MEC_PHY_NM,
      --     tmed.ITEM_PHY_OBJ_NM ||  '.'  || tmecd."MEC_PHY_NM"  MEC_PHY_NM,
        --    tmecd."MEC_PHY_NM",
	   --       tmecd.MEC_LONG_NM,
       case when instr(upper(map.pcode_sysgen),'ENDIF',1)>0 then '' else tmed.	ITEM_LONG_NM || '.' ||        tmecd.MEC_LONG_NM end MEC_LONG_NM,
   --	          tmed.	ITEM_LONG_NM || '.' ||        tmecd.MEC_LONG_NM MEC_LONG_NM,
	  decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') VAL_DOM_TYP,
            map.PCODE_SYSGEN,
	  MEC_MAP_NOTES,
	  TRNS_DESC_TXT,
	  map.PROV_ORG_ID,
	  map.PROV_CNTCT_ID,
	  map.PROV_RSN_TXT,
	  	map.PROV_TYP_RVW_TXT,
	  map.PROV_RVW_DT,
	  map.PROV_APRV_DT,
        sysdate creat_dt,
	  'ONEDATA' creat_usr_id,	  
	   sysdate lst_upd_dt,
	  'ONEDATA' lst_upd_usr_id,
        map.creat_dt creat_dt_x,
	 map.creat_usr_id creat_usr_id_x,	  
	  map.lst_upd_dt lst_upd_dt_x,
	  map.lst_upd_usr_id lst_upd_usr_id_x,
      0 FLD_DELETE,
      sysdate S2P_TRN_DT,
      sysdate LST_DEL_DT,
      decode(map.TRANS_RUL_NOT, 122, 'Text', 124, 'SQL', 123, 'Pseudocode') TRNS_RUL_NOT,
SORT_ORD
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd, VALUE_DOM vd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120,129,130)
and tmecd.VAL_DOM_ITEM_ID = vd.ITEM_ID (+)
	  and tmecd.VAL_DOM_VER_NR = vd.VER_NR (+)
      and (pcode_sysgen is not null or mec_map_notes is not null);
