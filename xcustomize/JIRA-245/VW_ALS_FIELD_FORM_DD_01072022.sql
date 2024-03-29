
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD
(
    COLLECT_ID,
    COLLECT_TYPE,
    COLLECT_NAME,
    PROTOCOL,
    FORM_ID,
    FORM_VERSION,
    FORM_LONG_NAME,
    CDE_SHORT_NAME,
    CDE_LONG_NAME,
    DE_PUB_ID,
    DE_VERSION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    MODULE_DISPLAY_ORDER,
    GR_QVV_VALUE,
    VV_NUMBERS_IN_QUEST,
    VAL_DOM_TYP_ID,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VD_DISPLAY_FORMAT,
    VAL_DOM_MAX_CHAR,
    VD_MIN_LENGTH,
    QUEST_ID,
    QUEST_VERSION,
    QUEST_LONG_NAME,
    QUEST_SHORT_NAME,
    ISMANDATORY,
    QUEST_DISP_ORD,
    QUEST_INSTR,
    VV_ID,
    VV_VRERSION,
    VALID_VALUE,
    VV_VM_DEFOLD,
    VV_VM_DEF,
    VV_DESC_TXT,
    VV_DISP_ORD,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR
)
BEQUEATH DEFINER
AS
      SELECT /*+ PARALLEL(4) */
             ALS.HDR_ID           COLLECT_ID,
             92     COLLECT_TYPE,
             H.DLOAD_HDR_NM     COLLECT_NAME,
             PROTOCOL,
             FORM_ID,
             FORM_VERSION,
             Form_Long_Name,
             CDE_SHORT_NAME,
             CDE_LONG_NAME,
             DE_PUB_ID,
             DE_VERSION,
             VD_LONG_NAME,
             VD_ID,
             VD_Version,
             MODULE_DISPLAY_ORDER,
             GR_QVV_VALUE,
             QVV.max_vv         VV_NUMBERS_IN_QUEST,
             VAL_DOM_TYP_ID,
             VD_DATA_TYPE_NCI,
             VD_DATA_TYPE_MAP,
             VD_DISPLAY_FORMAT,
             VAL_DOM_MAX_CHAR,
             VD_MIN_LENGTH,
             QUEST_ID,
             QUEST_VERSION,
             QUEST_LONG_NAME,
             QUEST_SHORT_NAME,
             isMandatory,
             QUEST_DISP_ORD,
             QUEST_INSTR,
             VV.NCI_PUB_ID      VV_ID,
             VV.NCI_VER_NR      VV_VRERSION,
             VV.VALUE           VALID_VALUE,
             VV.VM_DEF          VV_VM_DEFOLD,
             VV.MEAN_TXT        VV_VM_DEF,
             VV.DESC_TXT        VV_DESC_TXT,
             VV.DISP_ORD        VV_DISP_ORD,
             VAL_MEAN_ITEM_ID,
             VAL_MEAN_VER_NR
        FROM VW_ALS_FIELD_RAW_DATA VW,
             (  SELECT /*+ PARALLEL(5) */
                       Q_PUB_ID,
                       Q_VER_NR,
                       LISTAGG (DISP_ORD || '.' || VALUE,
                                '||'
                                ON OVERFLOW TRUNCATE)
                       WITHIN GROUP (ORDER BY DISP_ORD)    GR_QVV_VALUE,
                       COUNT (DISP_ORD)                    max_VV
                  FROM NCI_QUEST_VALID_VALUE
                 WHERE NVL (FLD_DELETE, 0) = 0
              GROUP BY Q_PUB_ID, Q_VER_NR) QVV,
             (SELECT *
                FROM NCI_QUEST_VALID_VALUE
               WHERE NVL (FLD_DELETE, 0) = 0) VV,
             NCI_DLOAD_DTL        ALS
           , NCI_DLOAD_HDR        H
       WHERE     ALS.ITEM_ID = FORM_ID
             AND ALS.VER_NR = Form_Version
             AND h.HDR_ID = ALS.HDR_ID
           --  AND h.DLOAD_TYP_ID = 92
             AND QUEST_ID = QVV.Q_PUB_ID(+)
             AND QUEST_VERSION = QVV.Q_VER_NR(+)
             AND QUEST_VERSION = VV.Q_VER_NR(+)
             AND QUEST_ID = VV.Q_PUB_ID(+)
             --and ALS.HDR_ID=2458
    ORDER BY ALS.HDR_ID,
             Form_ID,
             MODULE_DISPLAY_ORDER NULLS FIRST,
             VD_ID,
             GR_QVV_VALUE NULLS FIRST,
             QUEST_DISP_ORD DESC,
             VV.DISP_ORD;
