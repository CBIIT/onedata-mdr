CREATE OR REPLACE FORCE VIEW VW_NCI_AI
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
                     LISTAGG (ref_desc, '||')
                         WITHIN GROUP (ORDER BY OBJ_KEY_DESC DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) REF
     WHERE     ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+);

GRANT SELECT ON VW_NCI_AI TO ONEDATA_RO;
