
  CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_NCI_CSI_AI ("ITEM_ID", "VER_NR", "CSI_ITEM_ID", "CSI_VER_NR", "CSI_ITEM_NM", "CS_ITEM_ID", "CS_VER_NR", "REL_TYP_ID", "CSI_ITEM_LONG_NM", "CSI_ITEM_DESC", "P_CS_ITEM_ID", "P_CS_VER_NR", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "CSI_SEARCH_STR", "CS_ITEM_NM", "CS_ITEM_LONG_NM", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "FUL_PATH", "ITEM_NM", "ITEM_LONG_NM", "REGSTR_STUS_NM_DN", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "ADMIN_ITEM_TYP_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr,
  csi.item_nm csi_ITEM_NM, csi.cs_item_id CS_ITEM_ID, csi.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csi.p_item_Id p_CS_ITEM_ID, csi.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM,
 cs.cntxt_item_id , cs.cntxt_ver_nr, csi.ful_path,
 ai.item_nm, ai.item_long_nm, ai.regstr_stus_nm_dn, ai.admin_stus_nm_dn, ai.cntxt_nm_dn, ai.admin_item_typ_id
from   VW_CLSFCTN_SCHM_ITEM csi, nci_admin_item_rel aim, vw_CLSFCTN_SCHM cs, admin_item ai
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr
and aim.rel_typ_id = 65
and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and aim.c_item_id = ai.item_id and aim.c_item_ver_nr = ai.ver_nr;


  GRANT SELECT ON VW_NCI_CSI_AI TO "ONEDATA_RO";