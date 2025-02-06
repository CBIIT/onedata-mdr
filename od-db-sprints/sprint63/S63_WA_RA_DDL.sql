update nci_mec_map set TGT_FUNC_PARAM = TGT_VAL where  tgt_val is not null and tgt_func_param is null;
commit;

alter table nci_mec_val_map add (MECM_ID_DESC varchar2(4000));

alter table NCI_STG_MEC_VAL_MAP add MECM_ID_DESC varchar2(4000);

create or replace view vw_nci_mec_val_map as
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
vm.TGT_VD_ITEM_ID,
vm.TGT_VD_VER_NR,
vm.SRC_CDE_ITEM_ID,
vm.SRC_CDE_VER_NR,
vm.TGT_CDE_ITEM_ID,
vm.TGT_CDE_VER_NR,
mm.mecm_id
from nci_mec_map mm, nci_mec_val_map vm
where mm.src_mec_id = vm.src_mec_id and mm.tgt_mec_id = vm.tgt_mec_id


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
' '	"PROV_CONTACT",
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
    vmap.VM_CNCPT_CD,
    vmap.VM_CNCPT_NM,
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
    ' ' "CMNTS_DESC_TXT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec,	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
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
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and vmap.src_mec_id = smec.mec_id
          and vmap.tgt_mec_id = tmec.mec_id;

-- Tracker: DSRMWS-3853 
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "ONEDATA_WA"."VW_MDL_IMP_TEMPLATE" ("DO_NOT_USE", "BATCH_USER", "BATCH_NAME", "SEQ_ID", "MDL_NM", "MDL_ID", "MDL_VER_NR", "ME_LONG_NM", "ME_PHY_NM", "ME_DESC", "ME_TYP_DESC", "MEC_LONG_NM", "MEC_PHY_NM", "MEC_CHAR_ORD", "MEC_DESC", "MEC_TYP_DESC", "MEC_MIN_CHAR", "MEC_MAX_CHAR", "MEC_DT_TYP_DESC", "UOM_DESC", "MEC_MNDTRY", "MEC_PK_IND", "MEC_DEFLT_VAL", "CDE_ID", "CDE_VERSION", "MEC_FK_IND", "FK_ELMNT_PHY_NM", "FK_ELMNT_CHAR_PHY_NM", "COMMENTS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT ' '                DO_NOT_USE,
       ' '                  BATCH_USER,
       ' '                  BATCH_NAME,
       ROWNUM               SEQ_ID,
       ai.item_nm           MDL_NM, 
       ai.item_id           MDL_ID, 
       ai.ver_nr            MDL_VER_NR, 
       me.item_long_nm      ME_LONG_NM, 
       me.item_phy_obj_nm   ME_PHY_NM, 
       me.item_desc         ME_DESC, 
       me_typ.obj_key_desc ME_TYP_DESC,   
       mec.mec_long_nm      MEC_LONG_NM, 
       mec.MEC_PHY_NM       MEC_PHY_NM, 
       mec.CHAR_ORD         MEC_CHAR_ORD, 
       mec.                 MEC_DESC, 
       mec_typ.obj_key_Desc MEC_TYP_DESC,  
       mec.src_min_char     MEC_MIN_CHAR, 
       mec.src_max_char     MEC_MAX_CHAR, 
       dt.dttype_nm         MEC_DT_TYP_DESC, 
       uom.uom_nm           UOM_DESC,  
       mec_req.obj_key_Desc          MEC_MNDTRY,  
       mec.pk_ind           MEC_PK_IND,    
       mec.src_deflt_val    MEC_DEFLT_VAL, 
       mec.cde_item_id      CDE_ID, 
       mec.cde_ver_nr       CDE_vERSION, 
       mec.FK_IND           MEC_FK_IND, 
       mec.                 FK_ELMNT_PHY_NM, 
       mec.                 FK_ELMNT_CHAR_PHY_NM, 
       ' '                  COMMENTS            
FROM admin_item            ai,
     nci_mdl               mdl,
     nci_mdl_elmnt         me,
     nci_mdl_elmnt_char    mec,
     obj_key               mec_typ,
     obj_key               me_typ,
     obj_key               mec_req,
     data_typ              dt,
     uom                   uom,
     value_dom             vdst 
WHERE ai.item_id                  = mdl.item_id
  AND ai.ver_nr                   = mdl.ver_nr
  AND ai.admin_item_typ_id        = 57
  AND mdl.item_id                 = me.mdl_item_id
  AND mdl.ver_nr                  = me.mdl_item_ver_nr
  AND me.item_id                  = mec.mdl_elmnt_item_id
  AND me.ver_nr                   = mec.mdl_elmnt_ver_nr
  AND mec.val_dom_item_id         = vdst.item_id (+)
  AND mec.val_dom_ver_nr          = vdst.ver_nr (+)
  AND mec.mdl_elmnt_char_typ_id   = mec_typ.obj_key_id (+)
  AND mec.req_ind  = mec_req.obj_key_id (+)
  AND me.ME_TYP_ID  = me_typ.obj_key_id (+)
  AND vdst.nci_std_dttype_id      = dt.dttype_id (+)
  AND vdst.uom_id                 = uom.uom_id (+);


  CREATE OR REPLACE  VIEW VW_VAL_MAP_IMP_TEMPLATE  AS 
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
' '	"PROV_CONTACT",
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
    ' ' "CMNTS_DESC_TXT"
	from  NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec,	NCI_MEC_VAL_MAP vmap,
	  obj_key deg,
	  nci_org org,
  	  value_dom svd,
	  value_dom tvd,
vw_val_dom_ref_term svdrt,
vw_val_dom_ref_term tvdrt
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
          and svd.ver_nr = svdrt.ver_nr (+)
          and tvd.item_id = tvdrt.item_id (+)
          and tvd.ver_nr = tvdrt.ver_nr (+)
          and vmap.src_mec_id = smec.mec_id
          and vmap.tgt_mec_id = tmec.mec_id;

alter table nci_stg_mec_val_map add  (SRC_VM_CNCPT_CD varchar2(4000), 	TGT_VM_CNCPT_CD varchar2(4000),SRC_VM_CNCPT_NM varchar2(4000), SRC_VM_CNCPT_NM   varchar2(4000));
alter table nci_stg_mec_val_map drop VM_CNCPT_CD;
alter table nci_stg_mec_val_map drop VM_CNCPT_NM;

