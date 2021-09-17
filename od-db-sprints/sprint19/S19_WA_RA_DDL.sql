alter table NCI_STG_AI_CNCPT_CREAT
 ADD ( CNCPT_INT_1_1 integer, CNCPT_INT_1_2 integer, CNCPT_INT_1_3 integer, CNCPT_INT_1_4 integer, CNCPT_INT_1_5 integer, 
 CNCPT_INT_1_6 integer, CNCPT_INT_1_7 integer, CNCPT_INT_1_8 integer, CNCPT_INT_1_9 integer, CNCPT_INT_1_10 integer, 
 CNCPT_INT_2_1 integer, CNCPT_INT_2_2 integer, CNCPT_INT_2_3 integer, CNCPT_INT_2_4 integer, CNCPT_INT_2_5 integer, 
 CNCPT_INT_2_6 integer, CNCPT_INT_2_7 integer, CNCPT_INT_2_8 integer, CNCPT_INT_2_9 integer, CNCPT_INT_2_10 integer);
 
 alter table 
 NCI_STG_PV_VM_BULK
 ADD ( CNCPT_INT_1_1 integer, CNCPT_INT_1_2 integer, CNCPT_INT_1_3 integer, CNCPT_INT_1_4 integer, CNCPT_INT_1_5 integer, 
 CNCPT_INT_1_6 integer, CNCPT_INT_1_7 integer, CNCPT_INT_1_8 integer, CNCPT_INT_1_9 integer, CNCPT_INT_1_10 integer, 
 STR_DESC_1  varchar2(4000),STR_DESC_2  varchar2(4000),STR_DESC_3  varchar2(4000),STR_DESC_4  varchar2(4000),STR_DESC_5  varchar2(4000),
     STR_DESC_6  varchar2(4000),STR_DESC_7  varchar2(4000),STR_DESC_8  varchar2(4000),STR_DESC_9  varchar2(4000),STR_DESC_10  varchar2(4000));
 
  alter table 
 NCI_STG_PV_VM_BULK
 ADD ( blank_1 char(1), blank_2 char(1), blank_3 char(1), blank_4 char(1), blank_5 char(1),
     blank_6 char(1), blank_7 char(1), blank_8 char(1), blank_9 char(1), blank_10 char(1) );
 
alter table nci_admin_item_ext add (CNCPT_CONCAT_WITH_INT varchar2(4000));

alter table nci_admin_item_rel_alt_key add (PREF_NM_MIGRATED varchar2(30));

alter table NCI_CLSFCTN_SCHM_ITEM add (DISP_ORD integer default 0);



-- Current
CREATE OR REPLACE  VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr, 
  csi.item_nm csi_ITEM_NM, csist.cs_item_id CS_ITEM_ID, csist.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csist.p_item_Id p_CS_ITEM_ID, csist.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from  admin_item csi, NCI_CLSFCTN_SCHM_ITEM csist, nci_admin_item_rel aim, vw_CLSFCTN_SCHM cs 
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr 
and aim.rel_typ_id = 65 
and csi.item_id = csist.item_id and csi.ver_nr = csist.ver_nr
and csist.cs_item_id = cs.item_id and csist.cs_item_ver_nr = cs.ver_nr;

/*
-- Trial
CREATE OR REPLACE  VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr, 
  csi.item_nm csi_ITEM_NM, csist.cs_item_id CS_ITEM_ID, csist.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csist.p_item_Id p_CS_ITEM_ID, csist.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from  admin_item csi, NCI_CLSFCTN_SCHM_ITEM csist, nci_admin_item_rel aim, admin_item cs 
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr 
and aim.rel_typ_id = 65 
and csi.item_id = csist.item_id and csi.ver_nr = csist.ver_nr
and cs.admin_item_typ_id = 9
and csist.cs_item_id = cs.item_id and csist.cs_item_ver_nr = cs.ver_nr;
*/


