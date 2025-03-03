
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
	 tme.ITEM_LONG_NM "TGT_ELMNT_NAME", 
	  tmec."MEC_PHY_NM" "TGT_PHY_NAME", 
   	tmec.MEC_LONG_NM "TGT_MEC_NAME", 
       tmec.char_ord TGT_CHAR_ORD,
          map.MEC_MAP_NM "MAPPING_GROUP_NAME",
      tgt_func.obj_key_Desc "TARGET_FUNCTION",
    tgt_func.obj_key_id "TARGET_FUNCTION_ID",
	  deg.obj_key_Desc "MAPPING_DEGREE",
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
' '	"PROV_CONTACT",
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
	  map.lst_upd_dt lst_upd_dt_x
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd,
	  obj_key deg,
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


  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT as
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          tmed.ITEM_PHY_OBJ_NM,
            tmecd."MEC_PHY_NM",
	          tmecd.MEC_LONG_NM,
	          tmed.	ITEM_LONG_NM,
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
      sysdate LST_DEL_DT
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120)
      and (pcode_sysgen is not null or mec_map_notes is not null);


  CREATE OR REPLACE  VIEW VW_CNCPT_ADMIN_ITEM AS
  select "CNCPT_ITEM_ID","CNCPT_VER_NR","ITEM_ID","VER_NR","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT",
	  "LST_UPD_DT","NCI_ORD","NCI_PRMRY_IND","CNCPT_AI_ID","NCI_CNCPT_VAL" from cncpt_admin_item
union
SELECT  x.TERM_CNCPT_ITEM_ID,x.TERM_CNCPT_VER_NR ,
		x.ITEM_ID ITEM_ID, x.VER_NR VER_NR,
		sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID,
		0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT,
		sysdate LST_UPD_DT, null NCI_ORD, null NCI_PRMRY_IND , x.term_cncpt_item_Id + 1000*x.item_id + x.ver_nr, null NCI_CNCPT_VAL
       FROM vw_val_dom_ref_term x;


  CREATE OR REPLACE  VIEW VW_NCI_MEC_NO_CDE AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, 
    mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",
mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",
mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",
mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",
    mec."MEC_LONG_NM",
    mec."MEC_PHY_NM",
   me.ITEM_PHY_OBJ_NM || '.' || mec.MEC_PHY_NM me_mec_phy_nm, 
  me.ITEM_LONG_NM || '.' || mec.MEC_LONG_NM me_mec_long_nm, 
    mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR"
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57;


  CREATE OR REPLACE  VIEW VW_NCI_MEC AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",
mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",
vd."VAL_DOM_TYP_ID",mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",
mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",mec."MEC_LONG_NM",mec."MEC_PHY_NM",mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR",
decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated',18,'Non-enumerated','') VAL_DOM_TYP_DESC,
vd.TERM_CNCPT_ITEM_ID,
vd.TERM_CNCPT_VER_NR,
  me.ITEM_PHY_OBJ_NM || '.' || mec.MEC_PHY_NM me_mec_phy_nm, 
  me.ITEM_LONG_NM || '.' || mec.MEC_LONG_NM me_mec_long_nm, 
 nvl(term.term_use_name, cncpt.ITEM_NM)  TERM_CNCPT_DESC
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec, value_dom vd, vw_cncpt cncpt, vw_val_dom_ref_term term
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57
	  and mec.val_dom_item_id = vd.item_id(+) and mec.val_dom_ver_nr = vd.ver_nr(+)
and vd.TERM_CNCPT_ITEM_ID = cncpt.item_id (+)
and vd.term_cncpt_ver_nr = cncpt.ver_nr (+)
and vd.ITEM_ID = term.item_id (+)
and vd.ver_nr = term.ver_nr (+);

alter table admin_item add (MDL_MAP_SNAME varchar2(255));

--jira 3753
alter table nci_mec_val_map add src_vd_typ number;
alter table nci_mec_val_map add tgt_vd_typ number;

  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_VALUE_DOM ("ITEM_ID", "VER_NR", "ITEM_NM", "ITEM_LONG_NM", "ITEM_DESC", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ADMIN_STUS_NM_DN", "CURRNT_VER_IND", "DTTYPE_ID", "VAL_DOM_MAX_CHAR", "CONC_DOM_VER_NR", "CONC_DOM_ITEM_ID", "NON_ENUM_VAL_DOM_DESC", "UOM_ID", "VAL_DOM_TYP_ID", "VAL_DOM_MIN_CHAR", "VAL_DOM_FMT_ID", "CHAR_SET_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REP_TERM_ITEM_NM", "SUBSET_DESC", "PRNT_SUBSET_ITEM_ID", "PRNT_SUBSET_VER_NR", "NCI_STD_DTTYPE_ID", "TERM_NAME", "USE_NAME", "TERM_USE_NAME", "VAL_DOM_TYP_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.subset_desc, value_dom.PRNT_SUBSET_ITEM_ID, value_dom.PRNT_SUBSET_VER_NR,
	  value_dom.NCI_STD_DTTYPE_ID, term.term_name, term.use_name, term.term_use_name, DECODE(value_dom.val_dom_typ_id, 17, 'Enumerated', 18, 'Non-enumerated', 16, 'Enumerated by Reference')
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC, vw_val_dom_ref_term term
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+)
and
VALUE_DOM.ITEM_ID = TERM.ITEM_ID (+) and 
VALUE_DOM.VER_NR = TERM.VER_NR (+);

--jira 3703
update nci_dload_cstm_col_key set col_def = 'CDE Short Name' where col_id = 1;
update nci_dload_cstm_col_key set col_def = 'CDE Long Name' where col_id = 2;
update nci_dload_cstm_col_key set col_def = 'CDE Alternate Name' where col_id = 91;
commit;

alter table nci_dload_cstm_data_coll add cntxt_id number;
alter table nci_dload_cstm_data_coll add cntxt_ver_nr number (4,2);
alter table nci_dload_cstm_data_coll add LANG_ID number default 1000;

--jira 3805
alter table nci_stg_pv_vm_import add REF_BTCH_STR varchar2(128);



  CREATE OR REPLACE VIEW VW_MDL_MAP_RSLT AS
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          tmed.ITEM_PHY_OBJ_NM,
            tmecd."MEC_PHY_NM",
	          tmecd.MEC_LONG_NM,
	          tmed.	ITEM_LONG_NM,
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
      sysdate LST_DEL_DT
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120)
      and (pcode_sysgen is not null or mec_map_notes is not null);

