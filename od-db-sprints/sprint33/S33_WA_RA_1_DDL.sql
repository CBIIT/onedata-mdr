CREATE OR REPLACE FORCE VIEW VW_NCI_MODULE_DE
(FRM_ITEM_LONG_NM, FRM_ITEM_NM, FRM_ITEM_ID, FRM_VER_NR, FRM_CNTXT_NM_DN, 
 FRM_CNTXT_ITEM_ID, FRM_CNTXT_VER_NR, MOD_ITEM_ID, MOD_VER_NR, DE_ITEM_ID, 
 DE_VER_NR, QUEST_DISP_ORD, MOD_DISP_ORD, MOD_ITEM_NM, INSTR, 
 MOD_ITEM_LONG_NM, MOD_ITEM_DESC, ADMIN_ITEM_TYP_NM, NCI_PUB_ID, NCI_VER_NR, 
 CNTXT_NM_DN, DE_ITEM_NM,DE_ITEM_DESC, DE_CNTXT_ITEM_ID, DE_CNTXT_VER_NR, DE_ADMIN_STUS_NM_DN, 
 DE_REGSTR_STUS_NM_DN, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, 
 LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, QUEST_LONG_TXT, QUEST_TXT)
BEQUEATH DEFINER
AS 
select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr,  frm.cntxt_nm_dn FRM_CNTXT_NM_DN,
  frm.CNTXT_ITEM_ID FRM_CNTXT_ITEM_ID, frm.CNTXT_VER_NR FRM_CNTXT_VER_NR,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord,
aim.item_nm MOD_ITEM_NM, air.instr,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr,
de.CNTXT_NM_DN, de.item_nm DE_ITEM_NM, de.ITEM_DESC DE_ITEM_DESC, de.cntxt_item_id DE_CNTXT_ITEM_ID, de.cntxt_VER_NR DE_CNTXT_VER_NR, de.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, de.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id
and air.c_item_ver_nr = de.ver_nr;


GRANT SELECT ON VW_NCI_MODULE_DE TO ONEDATA_RO;
