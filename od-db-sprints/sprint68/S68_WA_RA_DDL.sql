
  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT_SHRT AS
  select   map.MDL_MAP_ITEM_ID ,
    map.mdl_map_ver_nr ,
    map.MEC_MAP_NM,
    map.sort_ord,
    tme.ITEM_PHY_OBJ_NM ||  '.'  || tmec."MEC_PHY_NM"  TGT_MEC_PHY_NM,
    tme.ITEM_PHY_OBJ_NM  TGT_ME_PHY_NM,
  --   tmec.MEC_PHY_NM  TGT_MEC_PHY_NM,
    sme.ITEM_PHY_OBJ_NM  SRC_ME_PHY_NM,
    -- smec.MEC_PHY_NM  SRC_MEC_PHY_NM,
    sme.ITEM_PHY_OBJ_NM ||  '.'  || smec."MEC_PHY_NM"  SRC_MEC_PHY_NM,
    --    tmecd."MEC_PHY_NM",
  --       tmecd.MEC_LONG_NM,
  decode(tvd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') TGT_VAL_DOM_TYP,
  decode(svd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') SRC_VAL_DOM_TYP,
  tmec.cde_item_id tgt_cde_item_id,
  tmec.cde_ver_nr tgt_cde_ver_nr,
   smec.cde_item_id src_cde_item_id,
  smec.cde_ver_nr src_cde_ver_nr,
  MEC_MAP_NOTES,
  TRNS_DESC_TXT,
      TRANS_RUL_NOT,
  map.PCODE_SYSGEN,
	  VALID_PLTFORM,
  PROV_ORG_ID,
  PROV_CNTCT_ID,
  PROV_RSN_TXT,
  PROV_TYP_RVW_TXT,
  PROV_RVW_DT,
  PROV_APRV_DT,
  cmnts_desc_txt,
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
     sysdate LST_DEL_DT
from
    nci_MEC_MAP map,
  NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, VALUE_DOM tvd,VALUE_DOM svd,
      NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec
where   tmec.MDL_ELMNT_ITEM_ID = tme.item_id (+) 
and tmec.MDL_ELMNT_VER_NR =tme.ver_nr (+)   
and map.TGT_MEC_ID = tmec.mec_id (+)
    and  smec.MDL_ELMNT_ITEM_ID = sme.item_id  (+)
and smec.MDL_ELMNT_VER_NR= sme.ver_nr  (+)
and map.SRC_MEC_ID = smec.mec_id (+)
  --and map.map_deg in (86,87,120)
  and tmec.VAL_DOM_ITEM_ID = tvd.ITEM_ID (+)
and tmec.VAL_DOM_VER_NR = tvd.VER_NR (+)
 and smec.VAL_DOM_ITEM_ID = svd.ITEM_ID (+)
and smec.VAL_DOM_VER_NR = svd.VER_NR (+);

-- To check if needs to be executed.

delete from nci_mec_map where src_mec_id in (select mec_id from nci_mdl_elmnt_Char where upper(mec_long_nm) like '%DELETED%')
and map_deg in (129,130,131);

delete from nci_mec_map where tgt_mec_id in (select mec_id from nci_mdl_elmnt_Char where upper(mec_long_nm) like '%DELETED%')
and map_deg in (129,130,131);

commit;


  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_VER_CREATED AS
  SELECT "ITEM_ID","VER_NR","ITEM_DESC","CNTXT_ITEM_ID","CNTXT_VER_NR","ITEM_LONG_NM","ITEM_NM","ADMIN_NOTES","CHNG_DESC_TXT","CREATION_DT","EFF_DT","ORIGIN","UNRSLVD_ISSUE","UNTL_DT","CLSFCTN_SCHM_VER_NR","ADMIN_ITEM_TYP_ID",
  "CURRNT_VER_IND","ADMIN_STUS_ID","REGSTR_STUS_ID","REGISTRR_CNTCT_ID","SUBMT_CNTCT_ID","STEWRD_CNTCT_ID","SUBMT_ORG_ID","STEWRD_ORG_ID",
  "CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","REGSTR_AUTH_ID",
  "ADMIN_STUS_NM_DN","CNTXT_NM_DN","REGSTR_STUS_NM_DN","ORIGIN_ID","ORIGIN_ID_DN","DEF_SRC",
  "CREAT_USR_ID_X","LST_UPD_USR_ID_X","ITEM_NM_CURATED","ITEM_NM_ID_VER","RVWR_CMNTS","LST_UPD_DT_X",
	  CNTXT_NM_DN, decode(admin_item_typ_id, 4, 'Data Element', 2, 'Data Element Concept',3, 'Value Domain', 54 , 'Form', 57, 'Model', 58, 'Model Map') ADMIN_ITEM_TYP_NM
       FROM ADMIN_ITEM
       where (item_id) in (Select item_id from admin_item where admin_item_typ_id in (2,3,4,54,57,58)
       group by item_id having count(*) > 1)
       and admin_item_typ_id in (2,3,4,54,57,58)
       and ver_nr <> 1;


alter table alt_nms add (ORI_VER_CREAT_USR_ID varchar2(50), ORI_VER_CREAT_DT date);
alter table alt_def add (ORI_VER_CREAT_USR_ID varchar2(50), ORI_VER_CREAT_DT date);
alter table ref add (ORI_VER_CREAT_USR_ID varchar2(50), ORI_VER_CREAT_DT date);
alter table NCI_ADMIN_ITEM_REL add (ORI_VER_CREAT_USR_ID varchar2(50), ORI_VER_CREAT_DT date);
alter table REF_DOC add (ORI_VER_CREAT_USR_ID varchar2(50), ORI_VER_CREAT_DT date);

alter table alt_nms disable all triggers;
update alt_nms set ori_ver_creat_usr_id = creat_usr_id, ori_ver_creat_dt = creat_dt;
commit;
alter table alt_nms enable all triggers;

alter table alt_def disable all triggers;
update alt_def set ori_ver_creat_usr_id = creat_usr_id, ori_ver_creat_dt = creat_dt;
commit;
alter table alt_def enable all triggers;

alter table ref disable all triggers;
update ref set ori_ver_creat_usr_id = creat_usr_id, ori_ver_creat_dt = creat_dt;
commit;
alter table ref enable all triggers;


alter table ref_DOC disable all triggers;
update ref_DOC set ori_ver_creat_usr_id = creat_usr_id, ori_ver_creat_dt = creat_dt;
commit;
alter table ref_DOC enable all triggers;

alter table nci_admin_item_rel disable all triggers;
update nci_admin_item_rel set ori_ver_creat_usr_id = creat_usr_id, ori_ver_creat_dt = creat_dt;
commit;
alter table nci_admin_item_rel enable all triggers;


  CREATE OR REPLACE VIEW VW_VAL_MAP_IMP_TEMPLATE AS
  select  ' ' "DO_NOT_USE",
       ' ' "BATCH_USER",
       ' ' "BATCH_NAME",
       rownum "SEQ_ID",
       vmap.mdl_map_item_id "MODEL_MAP_ID",
       vmap.mdl_map_ver_nr "MODEL_MAP_VERSION",
	vmap.MECM_ID_DESC,
        vmap.mecvm_id "MECVM_ID", 
   	sme.ITEM_PHY_OBJ_NM "SRC_ELMNT_PHY_NAME", 
	sme.ITEM_LONG_NM "SRC_ELMNT_NAME", 
  smec."MEC_PHY_NM" "SRC_PHY_NAME", 
	smec.MEC_LONG_NM "SRC_MEC_NAME", 
	  tme.ITEM_PHY_OBJ_NM "TGT_ELMNT_PHY_NAME", 
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
   	  deg.obj_key_Desc "MAPPING_DEGREE",
	org.org_nm "PROV_ORG",
cnt.PRSN_FULL_NM_DERV	"PROV_CONTACT",
	vmap.prov_rsn_txt "PROV_REVIEW_REASON",
	vmap.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	vmap.PROV_RVW_DT "PROV_REVIEW_DATE",
	vmap.prov_APRV_DT "PROV_APPROVAL_DATE",
	vmap.prov_Notes "PROV_APPROVAL_NOTES",
decode(svd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "SOURCE_DOMAIN_TYPE",
decode(tvd.val_dom_typ_id,17, 'Enumerated',18, 'Non-enumerated',16, 'Enumerated by Reference')  "TARGET_DOMAIN_TYPE",
    vmap.SRC_PV,
    vmap.TGT_PV,
    vmap.SRC_LBL,
    vmap.TGT_LBL, 
    vmap.SRC_VM_CNCPT_CD,
    vmap.SRC_VM_CNCPT_NM,
  vmap.TGT_VM_CNCPT_CD,
    vmap.TGT_VM_CNCPT_NM,
	   vmap."CREAT_DT",
	  vmap."CREAT_USR_ID",
	  vmap."LST_UPD_USR_ID",
	  vmap."FLD_DELETE",
	  vmap."LST_DEL_DT",
	  vmap."S2P_TRN_DT",
	  vmap."LST_UPD_DT",
      smec.MEC_ID SRC_MEC_ID,
      smec.CDE_ITEM_ID  "SOURCE_CDE_ITEM_ID",
      smec.CDE_VER_NR  "SOURCE_CDE_VER",
      tmec.CDE_ITEM_ID  "TARGET_CDE_ITEM_ID",
      tmec.CDE_VER_NR  "TARGET_CDE_VER",
       svd.ITEM_ID  "SOURCE_VD_ITEM_ID",
      svd.VER_NR  "SOURCE_VD_VER",
      tvd.ITEM_ID  "TARGET_VD_ITEM_ID",
      tvd.VER_NR  "TARGET_VD_VER",
tmec.MEC_ID TGT_MEC_ID,
svdrt.TERM_USE_NAME "SOURCE_REF_TERM_SOURCE",
tvdrt.TERM_USE_NAME "TARGET_REF_TERM_SOURCE",
    ' ' "CMNTS_DESC_TXT",
	  sort_ord "SORT_ORDER"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec,	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt,
	  NCI_PRSN cnt
	where  sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and
	  nvl(vmap.fld_delete,0) = 0 and
	 tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR  
	  and vmap.map_deg = deg.obj_key_id (+)
	  and vmap.prov_org_id = org.entty_id (+)
	        and smec.val_dom_item_id = svd.item_id 
	  and smec.val_dom_ver_nr = svd.ver_nr
	  and tmec.val_dom_item_id = tvd.item_id
 	  and tmec.val_dom_ver_nr = tvd.ver_nr 
          and svd.item_id = svdrt.item_id (+)
	  and vmap.PROV_CNTCT_ID = cnt.entty_id (+)
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and vmap.src_mec_id = smec.mec_id
          and vmap.tgt_mec_id = tmec.mec_id
	  and nvl(vmap.fld_delete,0) = 0;

--jira 4182
alter table nci_stg_pv_vm_import add IMP_TYP_NM varchar2(50);
update nci_stg_pv_vm_import set IMP_TYP_NM = 'IMPORT';
commit;

--jira 4206

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_MAP_RSLT ("MDL_MAP_ITEM_ID", "MDL_MAP_VER_NR", "MEC_MAP_NM", "MEC_PHY_NM", "MEC_LONG_NM", "VAL_DOM_TYP", "PCODE_SYSGEN", "MEC_MAP_NOTES", "TRNS_DESC_TXT", "PROV_ORG_ID", "PROV_CNTCT_ID", "PROV_RSN_TXT", "PROV_TYP_RVW_TXT", "PROV_RVW_DT", "PROV_APRV_DT", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_DT", "LST_UPD_USR_ID", "CREAT_DT_X", "CREAT_USR_ID_X", "LST_UPD_DT_X", "LST_UPD_USR_ID_X", "FLD_DELETE", "S2P_TRN_DT", "LST_DEL_DT", "TRNS_RUL_NOT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
	  PROV_ORG_ID,
	  PROV_CNTCT_ID,
	  PROV_RSN_TXT,
	  	PROV_TYP_RVW_TXT,
	  PROV_RVW_DT,
	  PROV_APRV_DT,
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
      decode(map.TRANS_RUL_NOT, 122, 'Text', 124, 'SQL', 123, 'Pseudocode') TRNS_RUL_NOT
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd, VALUE_DOM vd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120)
and tmecd.VAL_DOM_ITEM_ID = vd.ITEM_ID (+)
	  and tmecd.VAL_DOM_VER_NR = vd.VER_NR (+)
      and (pcode_sysgen is not null or mec_map_notes is not null);

--jira 4112

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_ADMIN_ITEM ("ITEM_ID", "VER_NR", "ITEM_NM", "ITEM_LONG_NM", "ITEM_DESC", "CLSFCTN_SCHM_ID", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ADMIN_NOTES", "CHNG_DESC_TXT", "CREATION_DT", "EFF_DT", "ORIGIN", "UNRSLVD_ISSUE", "UNTL_DT", "DATA_ID_STR", "CLSFCTN_SCHM_VER_NR", "ADMIN_ITEM_TYP_ID", "CURRNT_VER_IND", "REGSTR_STUS_ID", "ADMIN_STUS_ID", "STEWRD_CNTCT_ID", "SUBMT_CNTCT_ID", "REGISTRR_CNTCT_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "LEGCY_CD", "CASE_FILE_ID", "STEWRD_ORG_ID", "SUBMT_ORG_ID", "REGSTR_AUTH_ID", "BTCH_NR", "ADMIN_STUS_NM_DN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT ADMIN_ITEM.ITEM_ID, 
  ADMIN_ITEM.VER_NR, 
  ADMIN_ITEM.ITEM_NM, 
  ADMIN_ITEM.ITEM_LONG_NM, 
  ADMIN_ITEM.ITEM_DESC, 
  ADMIN_ITEM.CLSFCTN_SCHM_ID, 
  ADMIN_ITEM.CNTXT_ITEM_ID, 
  ADMIN_ITEM.CNTXT_VER_NR, 
  ADMIN_ITEM.ADMIN_NOTES, 
  ADMIN_ITEM.CHNG_DESC_TXT, 
  ADMIN_ITEM.CREATION_DT, 
  ADMIN_ITEM.EFF_DT, 
  ADMIN_ITEM.ORIGIN, 
  ADMIN_ITEM.UNRSLVD_ISSUE, 
  ADMIN_ITEM.UNTL_DT, 
  ADMIN_ITEM.DATA_ID_STR, 
  ADMIN_ITEM.CLSFCTN_SCHM_VER_NR, 
  ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
  ADMIN_ITEM.CURRNT_VER_IND, 
  ADMIN_ITEM.REGSTR_STUS_ID, 
  ADMIN_ITEM.ADMIN_STUS_ID, 
  ADMIN_ITEM.STEWRD_CNTCT_ID, 
  ADMIN_ITEM.SUBMT_CNTCT_ID, 
  ADMIN_ITEM.REGISTRR_CNTCT_ID, 
  ADMIN_ITEM.CREAT_DT, 
  ADMIN_ITEM.CREAT_USR_ID, 
  ADMIN_ITEM.LST_UPD_USR_ID, 
  ADMIN_ITEM.FLD_DELETE, 
  ADMIN_ITEM.LST_DEL_DT, 
  ADMIN_ITEM.S2P_TRN_DT, 
  ADMIN_ITEM.LST_UPD_DT,
  ADMIN_ITEM.LEGCY_CD, 
  ADMIN_ITEM.CASE_FILE_ID, 
  ADMIN_ITEM.STEWRD_ORG_ID, 
  ADMIN_ITEM.SUBMT_ORG_ID, 
  ADMIN_ITEM.REGSTR_AUTH_ID, 
  ADMIN_ITEM.BTCH_NR,
  ADMIN_ITEM.ADMIN_STUS_NM_DN
       FROM ADMIN_ITEM;


  GRANT SELECT ON VW_ADMIN_ITEM TO "ONEDATA_RO";
  GRANT READ ON VW_ADMIN_ITEM TO "ONEDATA_RO";

--jira 4206

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_MDL_MAP_IMP_TEMPLATE ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MODEL_MAP_ID", "MODEL_MAP_VERSION", "MECM_ID", "SRC_CHAR_ORD", "SRC_ELMNT_PHY_NAME", "SRC_ELMNT_NAME", "SRC_PHY_NAME", "SRC_MEC_NAME", "TGT_ELMNT_PHY_NAME", "TGT_ELMNT_NAME", "TGT_PHY_NAME", "TGT_MEC_NAME", "TGT_CHAR_ORD", "MAPPING_GROUP_NAME", "TARGET_FUNCTION_ID", "TRANS_RULE_NOTATION", "DERIVATION_GROUP_ORDER", "SET_TARGET_DEFAULT", "TARGET_FUNCTION_PARAM", "OPERATOR", "OPERAND_TYPE", "FLOW_CONTROL", "PARENTHESIS", "RIGHT_OPERAND", "LEFT_OPERAND", "VALIDATION_PLATFORM", "TRANSFORMATION_NOTES", "TRANSFORMATION_RULE", "PROV_ORG", "PROV_CONTACT", "PROV_REVIEW_REASON", "PROV_TYPE_OF_REVIEW", "PROV_REVIEW_DATE", "PROV_APPROVAL_DATE", "PCODE_SYSGEN", "MAP_DEG", "VALUE_MAP_GENERATED_IND", "SOURCE_DOMAIN_TYPE", "TARGET_DOMAIN_TYPE", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "SRC_MEC_ID", "SOURCE_CDE_ITEM_ID", "SOURCE_CDE_VER", "TARGET_CDE_ITEM_ID", "TARGET_CDE_VER", "SOURCE_VD_ITEM_ID", "SOURCE_VD_VER_NR", "TARGET_VD_ITEM_ID", "TARGET_VD_VER_NR", "SRC_MDL_ITEM_ID", "SRC_MDL_VER_NR", "TGT_MDL_ITEM_ID", "TGT_MDL_VER_NR", "TGT_MEC_ID", "TGT_PK_IND", "SRC_PK_IND", "SOURCE_REF_TERM_SOURCE", "TARGET_REF_TERM_SOURCE", "TGT_ELMNT_PHY_NAME_DERV", "CMNTS_DESC_TXT", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "CREAT_DT_X", "LST_UPD_DT_X", "SORT_ORD", "TRNS_RUL_NOT_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
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
    map.tgt_func_id "TARGET_FUNCTION_ID",
          ' ' "TRANS_RULE_NOTATION",
map.mec_sub_grp_nbr	"DERIVATION_GROUP_ORDER",
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
cnt.PRSN_FULL_NM_DERV	"PROV_CONTACT",
	map.prov_rsn_txt "PROV_REVIEW_REASON",
	map.prov_typ_rvw_txt "PROV_TYPE_OF_REVIEW",
	map.PROV_RVW_DT "PROV_REVIEW_DATE",
	map.prov_APRV_DT "PROV_APPROVAL_DATE",
	  map.pcode_sysgen,
	  map.map_deg,
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
      map.TRANS_RUL_NOT TRNS_RUL_NOT_ID 
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
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
	  NCI_PRSN cnt
	where  sme.item_id (+)= smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr (+)= smec.MDL_ELMNT_VER_NR and
	 tme.item_id (+)= tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr (+)= tmec.MDL_ELMNT_VER_NR  and
	 tmed.item_id (+)= tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr (+)= tmecd.MDL_ELMNT_VER_NR  and
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
          and tvd.ver_nr = tvdrt.ver_nr (+);


