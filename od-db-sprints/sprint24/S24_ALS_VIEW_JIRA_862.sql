CREATE OR REPLACE FORCE VIEW VW_ALS_CDE_VD_PV_RAW_DATA_DD
(
    COLLECT_ID,
    COLLECT_TYPE,
    COLLECT_NAME,
    DE_PUB_ID,
    DE_VERSION,
    DE_LONG_NAME,
    DE_SHORT_NAME,
    PREFERRED_QUESTION,
    VD_ID,
    VD_VERSION,
    VD_LONG_NAME,
    VD_SHORT_NAME,
    VAL_DOM_TYP_ID,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VAL_DOM_MAX_CHAR,
    VD_MAXIMUM_LENGTH,
    VD_MIN_LENGTH,
    VD_DISPLAY_FORMAT,
    NUMBER_PV_IN_CDE,
    PV_VALUE,
    VM_LONG_NAME,
    VM_ID,
    VM_VERSION
)
BEQUEATH DEFINER
AS
    SELECT h.HDR_ID             COLLECT_ID,
           93                   COLLECT_TYPE,
           H.DLOAD_HDR_NM       COLLECT_NAME,
           CDE.ITEM_ID          DE_PUB_ID,
           CDE.VER_NR           DE_VERSION,
           CDE.ITEM_NM          DE_Long_Name,
           CDE.ITEM_LONG_NM     DE_Short_Name,
           NULL                 Preferred_Question,
           NULL                 VD_ID,
           NULL                 VD_VERSION,
           NULL                 VD_Short_Name,
           'CDE_OID'            VD_Long_Name,
           NULL                 VAL_DOM_TYP_ID,
           NULL                 VD_DATA_TYPE_NCI,
           NULL                 VD_DATA_TYPE_MAP,
           NULL                 VAL_DOM_MAX_CHAR,
           NULL                 VD_Maximum_Length,
           NULL                 VD_Minimum_Length,
           NULL                 VD_Display_Format,
           NULL                 NMR_PV,
           NULL                 PV_Value,
           NULL                 VM_Long_Name,
           NULL                 VM_ID,
           NULL                 VM_Version
      FROM ADMIN_ITEM CDE, NCI_DLOAD_DTL ALS, NCI_DLOAD_HDR H
     WHERE     CDE.ITEM_ID = ALS.ITEM_ID
           AND CDE.VER_NR = ALS.VER_NR
           AND h.HDR_ID = ALS.HDR_ID
    UNION
    SELECT h.HDR_ID                                        COLLECT_ID,
           93                                              COLLECT_TYPE,
           H.DLOAD_HDR_NM                                  COLLECT_NAME,
           DE.ITEM_ID                                      DE_PUB_ID,
           DE.VER_NR                                       DE_VERSION,
           CDE.ITEM_NM                                     DE_Long_Name,
           CDE.ITEM_LONG_NM                                DE_Short_Name,
           DE.PREF_QUEST_TXT                               Preferred_Question,
           VALUE_DOM.ITEM_ID                               VD_ID,
           VALUE_DOM.VER_NR                                VD_VERSION,
           VD.ITEM_LONG_NM                                 VD_Short_Name,
           VD.ITEM_NM                                      VD_Long_Name,
           DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')     VAL_DOM_TYP_ID,
           dt.NCI_CD                                       VD_DATA_TYPE_NCI,
           dt.NCI_DTTYPE_MAP                               VD_DATA_TYPE_MAP,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM                  VD_Maximum_Length,
           VALUE_DOM.VAL_DOM_MIN_CHAR                      VD_Minimum_Length,
           FMT.FMT_NM                                      VD_Display_Format,
           NMR_PV,
           PVM.PERM_VAL_NM                                 PV_Value,
           PVM.ITEM_NM                                     VM_Long_Name,
           PVM.VAL_DOM_ITEM_ID                             VM_ID,
           PVM.VAL_DOM_VER_NR                              VM_Version
      FROM de             DE,
           ADMIN_ITEM     CDE,
           VALUE_DOM,
           ADMIN_ITEM     VD,
           (SELECT PERM_VAL.PERM_VAL_NM,
                   PERM_VAL.VAL_DOM_ITEM_ID,
                   PERM_VAL.VAL_DOM_VER_NR,
                   VM.ITEM_NM,
                   VM.ITEM_ID     VM_ID,
                   VM.VER_NR
              FROM PERM_VAL, ADMIN_ITEM VM
             WHERE     ADMIN_ITEM_TYP_ID = 53
                   AND VM.ITEM_ID = PERM_VAL.NCI_VAL_MEAN_ITEM_ID
                   AND VM.VER_NR = PERM_VAL.NCI_VAL_MEAN_VER_NR) PVM,
           (  SELECT COUNT (*) NMR_PV, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR
                FROM PERM_VAL
            GROUP BY PERM_VAL.VAL_DOM_ITEM_ID, PERM_VAL.VAL_DOM_VER_NR) CPVM,
           FMT,
           DATA_TYP       DT,
           NCI_DLOAD_DTL  ALS,
           NCI_DLOAD_HDR  H
     WHERE     CDE.ITEM_ID = ALS.ITEM_ID
           AND CDE.VER_NR = ALS.VER_NR
           AND h.HDR_ID = ALS.HDR_ID
           AND VD.ADMIN_ITEM_TYP_ID = 3
           AND CDE.ADMIN_ITEM_TYP_ID = 4
           -- AND VM.ADMIN_ITEM_TYP_ID = 53                   --(Value Meaning)
           AND CDE.ITEM_ID = DE.ITEM_ID
           AND CDE.VER_NR = DE.VER_NR
           AND de.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND de.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
           AND VD.VER_NR = VALUE_DOM.VER_NR
           AND CPVM.VAL_DOM_VER_NR = VD.VER_NR
           AND CPVM.VAL_DOM_ITEM_ID = VD.ITEM_ID
           AND VD.ITEM_ID = PVM.VAL_DOM_ITEM_ID(+)
           AND VD.VER_NR = PVM.VAL_DOM_VER_NR(+)
           AND VALUE_DOM.dttype_id = DT.dttype_id
           AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
    ORDER BY COLLECT_ID, DE_PUB_ID, DE_VERSION;
/
CREATE OR REPLACE FORCE VIEW VW_ALS_FIELD_FORM_DD
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
             ALS.HDR_ID         COLLECT_ID,
             92                 COLLECT_TYPE,
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
             NCI_DLOAD_DTL        ALS,
             NCI_DLOAD_HDR        H
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
/