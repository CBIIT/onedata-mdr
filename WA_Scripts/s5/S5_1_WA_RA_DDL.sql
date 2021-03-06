
  CREATE OR REPLACE  VIEW VW_DE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 DE.DE_CONC_VER_NR, DE.DE_CONC_ITEM_ID, DE.VAL_DOM_VER_NR, DE.VAL_DOM_ITEM_ID, DE.REP_CLS_VER_NR, DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, DE.LST_UPD_USR_ID, DE.FLD_DELETE, DE.LST_DEL_DT, DE.S2P_TRN_DT, DE.LST_UPD_DT, DE.CREAT_DT,
DE.PREF_QUEST_TXT
   FROM ADMIN_ITEM, DE
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR;


  CREATE OR REPLACE  VIEW VW_NCI_AI_CURRNT AS
  select DATA_ID_STR,ITEM_ID,VER_NR,CLSFCTN_SCHM_ID,
ITEM_DESC,CNTXT_ITEM_ID,CNTXT_VER_NR,ITEM_LONG_NM,
ITEM_NM,ADMIN_NOTES,CHNG_DESC_TXT,CREATION_DT,EFF_DT,ORIGIN,
UNRSLVD_ISSUE,UNTL_DT,CLSFCTN_SCHM_VER_NR,ADMIN_ITEM_TYP_ID,CURRNT_VER_IND,
ADMIN_STUS_ID,REGSTR_STUS_ID,REGISTRR_CNTCT_ID,SUBMT_CNTCT_ID,STEWRD_CNTCT_ID,
SUBMT_ORG_ID,STEWRD_ORG_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_USR_ID,FLD_DELETE,
LST_DEL_DT,S2P_TRN_DT,LST_UPD_DT,LEGCY_CD,CASE_FILE_ID,REGSTR_AUTH_ID,BTCH_NR,
ALT_KEY,ABAC_ATTR,NCI_IDSEQ,ADMIN_STUS_NM_DN,CNTXT_NM_DN,REGSTR_STUS_NM_DN,
ORIGIN_ID,ORIGIN_ID_DN,DEF_SRC from admin_item where ADMIN_ITEM.CURRNT_VER_IND = '1';
