CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_CDE_VD_PV_RAW_DATA_DD
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
           93       COLLECT_TYPE,
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
           93                                  COLLECT_TYPE,
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
