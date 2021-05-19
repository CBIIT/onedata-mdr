alter table 	NCI_STG_CDE_CREAT add (
VD_CNTXT_ITEM_ID  number, 
VD_CNTXT_VER_NR number(4,2));

alter table NCI_STG_AI_CNCPT_CREAT add (CTL_VAL_STUS varchar2(100));
                                                              
 drop view vw_perm_values;
                                                              
alter table NCI_DLOAD_HDR add (EMAIL_ADDR  varchar2(255));
                                              
  CREATE OR REPLACE  VIEW VW_CNCPT AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, 
nvl(decode(ADMIN_ITEM.DEF_SRC, 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC,
		      decode(OBJ_KEY.OBJ_KEY_DESC, 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC
       FROM ADMIN_ITEM, CNCPT, OBJ_KEY
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED';
			
  CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_AI
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           '.' || ADMIN_ITEM.ITEM_ID || '.'    ITEM_ID_STR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           SUBSTR (
                  ADMIN_ITEM.ITEM_LONG_NM
               || '||'
               || ADMIN_ITEM.ITEM_NM
               || '||'
               || ADMIN_ITEM.ITEM_DESC
               || '||'
               || REF_DESC,
               1,
               32766)                          SEARCH_STR
      FROM ADMIN_ITEM  ADMIN_ITEM,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||'ON OVERFLOW TRUNCATE '...' WITH COUNT)
                         WITHIN GROUP (ORDER BY OBJ_KEY_DESC DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) REF                                   --
     WHERE     ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+);



