
  CREATE OR REPLACE  VIEW VW_NCI_DE_PV AS
  SELECT pv.val_id, PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR, VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		decode(e.cncpt_concat_with_int, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat_with_int) cncpt_concat_with_int,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR,
	  'CDE' PV_TYP, de.VAL_DOM_ITEM_ID, de.val_dom_Ver_nr,
    vm.Admin_stus_nm_dn VM_ADMIN_STUS
       FROM  DE, PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR and
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR ;
	 
alter table NCI_STG_CDE_CREAT add NEW_VER_NR number(4,2);
alter table NCI_STG_CDE_CREAT add ADMIN_NOTES varchar2(4000);
