alter table NCI_MEC_VAL_MAP add (CMNTS_DESC_TXT varchar2(4000));

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
	  map.lst_upd_dt lst_upd_dt_x
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

 CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT AS
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
      sysdate LST_DEL_DT
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

alter table NCI_STG_MEC_MAP add (CMNTS_DESC_TXT varchar2(4000));


  CREATE OR REPLACE VIEW VW_MDL_MAP_RSLT_SHRT as
  select   map.MDL_MAP_ITEM_ID ,
    map.mdl_map_ver_nr ,
    map.MEC_MAP_NM,
    tme.ITEM_PHY_OBJ_NM ||  '.'  || tmec."MEC_PHY_NM"  MEC_PHY_NM,
    tme.ITEM_PHY_OBJ_NM  TGT_ME_PHY_NM,
     tmec.MEC_PHY_NM  TGT_MEC_PHY_NM,
    sme.ITEM_PHY_OBJ_NM  SRC_ME_PHY_NM,
     smec.MEC_PHY_NM  SRC_MEC_PHY_NM,
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
and smec.VAL_DOM_VER_NR = svd.VER_NR (+)
 and TRNS_DESC_TXT is not null;


  CREATE OR REPLACE VIEW VW_NCI_MEC_VAL_MAP AS
  select 
MECVM_ID,
vm.SRC_MEC_ID,
vm.TGT_MEC_ID,
vm.MDL_MAP_ITEM_ID,
vm.MDL_MAP_VER_NR,
SRC_PV,
TGT_PV,
VM_CNCPT_CD,
VM_CNCPT_NM,
vm.CREAT_DT,
vm.CREAT_USR_ID,
vm.LST_UPD_USR_ID,
vm.FLD_DELETE,
vm.LST_DEL_DT,
vm.LST_UPD_DT,
vm.S2P_TRN_DT,
vm.PROV_ORG_ID,
vm.PROV_CNTCT_ID,
vm.PROV_RSN_TXT,
vm.PROV_TYP_RVW_TXT,
vm.PROV_RVW_DT,
vm.PROV_APRV_DT,
SRC_LBL,
TGT_LBL,
PROV_NOTES,
vm.MAP_DEG,
SRC_VM_CNCPT_CD,
SRC_VM_CNCPT_NM,
TGT_VM_CNCPT_CD,
TGT_VM_CNCPT_NM,
vm.SRC_VD_ITEM_ID,
vm.SRC_VD_VER_NR,
decode(svd.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated', 16, 'Enumerated by Reference') SRC_VD_TYP,
vm.TGT_VD_ITEM_ID,
vm.TGT_VD_VER_NR,
decode(tvd.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated', 16, 'Enumerated by Reference') TGT_VD_TYP,
vm.SRC_CDE_ITEM_ID,
vm.SRC_CDE_VER_NR,
vm.TGT_CDE_ITEM_ID,
vm.TGT_CDE_VER_NR,
mm.mecm_id,
vm.cmnts_desc_txt
--,	vm.SRC_VD_TYP, vm.TGT_VD_TYP
from nci_mec_map mm, nci_mec_val_map vm, value_dom svd, value_dom tvd
where mm.src_mec_id = vm.src_mec_id and mm.tgt_mec_id = vm.tgt_mec_id
	and mm.mdl_map_item_id = vm.mdl_map_item_id and mm.mdl_map_ver_nr = vm.mdl_map_ver_nr
	and vm.src_vd_item_id = svd.item_id and vm.src_vd_ver_nr = svd.ver_nr
	and vm.tgt_vd_item_id = tvd.item_id and vm.tgt_vd_ver_nr = tvd.ver_nr;

