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

	
