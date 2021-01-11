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
                     LISTAGG (ref_desc, '||')
                         WITHIN GROUP (ORDER BY OBJ_KEY_DESC DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) REF                                  --,
     WHERE     ADMIN_ITEM.ITEM_ID = REF.ITEM_ID
           AND ADMIN_ITEM.VER_NR = REF.VER_NR;


/* Formatted on 1/7/2021 2:24:55 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    CNTXT_NM_DN,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    CREAT_USR_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID,
    LST_UPD_USR_ID_X,
    REGSTR_STUS_DISP_ORD,
    ADMIN_STUS_DISP_ORD,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    NCI_IDSEQ,
    NCI_PRG_AREA_ID,
    ADMIN_ITEM_TYP_ID,
    CNTXT_AGG,
    PREF_QUEST_TXT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           '.' || ADMIN_ITEM.ITEM_ID || '.'    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR                    REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR                    ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
           ext.USED_BY                         CNTXT_AGG,
           REF.ref_desc                        PREF_QUEST_TXT,
           SUBSTR (
                  ADMIN_ITEM.ITEM_LONG_NM
               || '||'
               || ADMIN_ITEM.ITEM_NM
               || '||'
               || NVL (ref_desc.ref_desc, ''),
               1,
               32766)                          SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
           NCI_ADMIN_ITEM_EXT  ext,
           (SELECT item_id, ver_nr, ref_desc
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||') WITHIN GROUP (ORDER BY OBJ_KEY_DESC desc)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           --and ADMIN_ITEM.ITEM_Id = de.item_id
           --and ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;


GRANT SELECT ON ONEDATA_WA.VW_NCI_DE TO ONEDATA_RO;
