update nci_mec_map set TGT_FUNC_PARAM = TGT_VAL where  tgt_val is not null and tgt_func_param is null;
commit;

alter table nci_mec_val_map add (MECM_ID_DESC varchar2(4000));

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


