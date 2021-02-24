

create unique index idx_Admin_item_nci_uni on admin_item (ADMIN_ITEM_TYP_ID, ITEM_LONG_NM, CNTXT_ITEM_ID, CNTXT_VER_NR, VER_NR);

create unique index idxQuestRepUni on nci_quest_vv_rep (QUEST_PUB_ID, QUEST_VER_NR, REP_SEQ);



create unique index idxNCiAIRelUni on nci_admin_item_rel 
( P_ITEM_ID, P_ITEM_VER_NR,decode(REL_TYP_ID, 61, 1,C_ITEM_ID), C_ITEM_VER_NR,  REL_TYP_ID, DISP_ORD);

create index idxQuestVV2 on nci_quest_valid_value (Q_PUB_ID, Q_VER_NR, VALUE);


  CREATE OR REPLACE  VIEW VW_DE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN,
ADMIN_ITEM.REGSTR_STUS_ID, ADMIN_ITEM.ADMIN_STUS_ID,
 DE.DE_CONC_VER_NR, DE.DE_CONC_ITEM_ID, DE.VAL_DOM_VER_NR, DE.VAL_DOM_ITEM_ID, DE.REP_CLS_VER_NR, DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, DE.LST_UPD_USR_ID, DE.FLD_DELETE, DE.LST_DEL_DT, DE.S2P_TRN_DT, DE.LST_UPD_DT, DE.CREAT_DT,
DE.PREF_QUEST_TXT, VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.DTTYPE_ID, VAL_DOM_MAX_CHAR, VAL_DOM_TYP_ID, VALUE_DOM.UOM_ID,
VAL_DOM_MIN_CHAR, VAL_DOM_FMT_ID, CHAR_SET_ID, VAL_DOM_HIGH_VAL_NUM, VAL_DOM_LOW_VAL_NUM, FMT_NM, DTTYPE_NM, UOM_NM,
decode(VALUE_DOM.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated')
   FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+);


create unique index idxDEC on DE_CONC 
( OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID, PROP_VER_NR);

alter table NCI_CLSFCTN_SCHM_ITEM add (P_ITEM_ID  number, P_ITEM_VER_NR number(4,2), CS_ITEM_ID NUMber, CS_ITEM_VER_NR number(4,2), CS_CSI_IDSEQ char(36));




DROP MATERIALIZED VIEW VW_CLSFCTN_SCHM_ITEM;

CREATE MATERIALIZED VIEW VW_CLSFCTN_SCHM_ITEM
  BUILD IMMEDIATE
  REFRESH FORCE
  ON COMMIT AS
 SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR, CSI.CS_ITEM_ID, CSI.CS_ITEM_VER_NR
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR;





  CREATE OR REPLACE  VIEW VW_NCI_CSI_NODE AS
  SELECT NODE.NCI_PUB_ID, NODE.NCI_VER_NR, CSI.ITEM_ID, CSI.VER_NR, CSI.ITEM_NM, CSI.ITEM_LONG_NM, CSI.ITEM_DESC, 
CSI.CNTXT_NM_DN, CSI.CURRNT_VER_IND, CSI.REGSTR_STUS_NM_DN, CSI.ADMIN_STUS_NM_DN, CSI.CREAT_DT, 
CSI.CREAT_USR_ID, CSI.LST_UPD_USR_ID, CSI.FLD_DELETE, CSI.LST_DEL_DT, CSI.S2P_TRN_DT, 
CSI.LST_UPD_DT, cs.CNTXT_ITEM_ID, CS.CNTXT_VER_NR,
cs.item_id cs_item_id, cs.ver_nr cs_ver_nr , cs.item_long_nm cs_long_nm, cs.item_nm cs_item_nm, cs.item_desc cs_item_desc,
pcsi.item_id pcsi_item_id, pcsi.ver_nr pcsi_ver_nr, pcsi.item_long_nm pcsi_long_nm, pcsi.item_nm pcsi_item_nm, cs.admin_stus_nm_dn cs_admin_stus_nm_dn,CS.CLSFCTN_SCHM_TYP_ID
FROM VW_CLSFCTN_SCHM_ITEM CSI,  VW_CLSFCTN_SCHM CS, VW_CLSFCTN_SCHM_ITEM PCSI
       WHERE  CSI.cs_item_id = cs.item_id and CSI.cs_ITEM_Ver_nr = cs.ver_nr
       and CSI.p_item_id = pcsi.item_id (+)
       and CSI.p_item_ver_nr = pcsi.ver_nr (+);


  CREATE OR REPLACE VIEW VW_NCI_CSI_DE AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr, 
  csi.item_nm csi_ITEM_NM, csi.cs_item_id CS_ITEM_ID, csi.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csi.p_item_Id p_CS_ITEM_ID, csi.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from vw_CLSFCTN_SCHM_ITEM csi, nci_admin_item_rel aim, vw_CLSFCTN_SCHM cs 
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr 
and aim.rel_typ_id = 65 
and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr;



  CREATE OR REPLACE VIEW VW_NCI_CSI_DE AS
  select  aim.NCI_PUB_ID, AIM.NCI_VER_NR,  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, ai.item_id csi_item_id, ai.ver_nr csi_ver_nr, 
  ai.item_nm csi_ITEM_NM, air.cntxt_cs_item_id CS_ITEM_ID, air.CNTXT_CS_VER_NR CS_VER_NR, aim.rel_typ_id,
 ai.item_long_nm  csi_item_long_nm, ai.item_desc csi_item_desc, air.p_item_Id p_CS_ITEM_ID, air.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 ai.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM
from admin_item ai, VW_nci_CLSFCTN_SCHM_ITEM air, nci_admin_item_rel aim, admin_item cs 
where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr 
and air.rel_typ_id = 64
and aim.nci_pub_id = air.nci_pub_id and aim.nci_ver_nr = air.nci_ver_nr
and air.cntxt_cs_item_id = cs.item_id and air.cntxt_cs_ver_nr = cs.ver_nr and cs.admin_item_typ_id = 9;




create or replace view vw_csi_tree as 
select 'CONTEXT' LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 8
 union 
select 'CLASSIFICATION SCHEME' LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 9
 union
 select 'CSI' LVL, CS_ITEM_ID P_ITEM_ID, CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null
 union
 select 'CSI' LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null


create or replace view vw_csi_tree_node as 
select decode(admin_item_typ_id, 8, 'CONTEXT',9, 'CS', 51, 'CSI')  LVL,  ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID, 
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, 
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID in ( 8,9, 51)
 

create or replace view vw_csi_tree_node_rel as 
select 'CLASSIFICATION SCHEME' LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, 
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT
 from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 9
 union
 select 'CSI' LVL, CS_ITEM_ID P_ITEM_ID, CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, 
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT
 from NCI_CLSFCTN_SCHM_ITEM ai
 where  ai.p_item_id is null
 union
 select 'CSI' LVL, P_ITEM_ID P_ITEM_ID, P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, 
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT
  from  NCI_CLSFCTN_SCHM_ITEM ai
 where  ai.p_item_id is not null;


