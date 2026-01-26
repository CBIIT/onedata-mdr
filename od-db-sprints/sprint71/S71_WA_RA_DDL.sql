
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

create or replace view vw_admin_item_with_retired_concept as
select ai.item_id item_id, ai.ver_nr ver_nr, o.obj_key_desc Admin_item_type,  ai.item_nm Admin_item_nm, ai.cntxt_nm_dn Admin_item_context, ai.admin_stus_nm_dn Admin_item_status,
c.item_id cncpt_item_id, c.ver_nr cncpt_ver_nr, c.item_nm cncpt_name, c.item_long_nm cncpt_code, c.lst_upd_dt date_cncpt_retired, c.chng_desc_txt cncpt_comments
from admin_item ai, cncpt_admin_item r, obj_key o,
(select item_id, ver_nr, item_nm, item_long_nm,lst_upd_dt, CHNG_DESC_TXT from admin_item where admin_item_typ_id = 49 and admin_stus_nm_dn like 'RETIRED%'
and lst_upd_dt >= sysdate - 60) c
where  c.item_id = r.cncpt_item_id and c.ver_nr = r.cncpt_ver_nr and ai.admin_item_typ_id = o.obj_key_id
and r.item_id = ai.item_id and r.ver_nr = ai.ver_nr


  CREATE OR REPLACE VIEW VW_DE_DEPENDENCY AS
  SELECT distinct frm_mod.p_item_Id item_id , frm_mod.p_item_ver_nr ver_nr, air.c_item_id cde_item_id, air.c_item_ver_nr cde_ver_nr,
sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT,  sysdate LST_UPD_DT
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR,
NCI_ADMIN_ITEM_REL FRM_MOD 
WHERE  AIR.REL_TYP_ID = 63
AND FRM_MOD.C_ITEM_ID = AIR.P_ITEM_ID AND FRM_MOD.C_ITEM_VER_NR = AIR.P_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
union
select distinct mdl.item_id item_id, mdl.ver_nr, mec.cde_item_id, mec.cde_ver_nr de_ver_nr,
sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT,  sysdate LST_UPD_DT
from nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec
where mdl.item_id = me.mdl_item_id and mdl.ver_nr = me.mdl_item_ver_nr and
me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr

