DROP VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA;

/* Formatted on 7/30/2021 11:21:14 AM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA
(
    PROTOCOL,
    FORM_LONG_NAME,
    FORM_ID,
    FORM_VERSION,
    MODULE_DISPLAY_ORDER,
    QUEST_VERSION,
    QUEST_ID,
    QUEST_DISP_ORD,
    QUEST_LONG_NAME,
    QUEST_SHORT_NAME,
    QUEST_INSTR,
    DE_PUB_ID,
    DE_VERSION,
    CDE_SHORT_NAME,
    CDE_LONG_NAME,
    VD_SHORT_NAME,
    VD_LONG_NAME,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_TYP_ID,
    VD_MAX_LENGTH,
    VD_DISPLAY_FORMAT,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VD_ID,
    VD_VERSION,
    UOM_ID
)
BEQUEATH DEFINER
AS
    SELECT DISTINCT REL.PROTO_ID,
                    FR.ITEM_NM     Form_Long_Name,         --rownum Ordinal,--
                    FR.ITEM_ID     FORM_ID,
                    FR.VER_NR      Form_Version,
                    NULL           Module,
                    NULL           QUESTION_Version,
                    NULL           QUESTION_ID,
                    NULL           QUEST_DISP_ORD,
                    'FORM_OID'     QUEST_Long_Name,
                    NULL           QUEST_SORT_Name,
                    NULL           QUEST_Inst,
                    NULL           DE_PUB_ID,
                    NULL           DE_VERSION,
                    'FORM_OID'     CDE_Sort_Name,
                    NULL           CDE_Long_Name,
                    NULL           VD_Short_Name,
                    NULL           VD_Long_Name,
                    NULL           VAL_DOM_MAX_CHAR,
                    NULL           VAL_DOM_TYP_ID,
                    NULL           VD_Max_Length,
                    NULL           VD_Display_Format,
                    NULL           VD_DATA_TYPE,
                    NULL           VD_DATA_TYPE_MAP,
                    NULL           VD_ID,
                    NULL           VD_Version,
                    NULL           UOM_ID
      FROM ADMIN_ITEM  FR,
           --           (  SELECT C_ITEM_ID,
           --                     C_ITEM_VER_NR,
           --                     LISTAGG (P_ITEM_ID || 'v' || P_ITEM_VER_NR,
           --                              ':'
           --                              ON OVERFLOW TRUNCATE)
           --                     WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
           --                FROM NCI_ADMIN_ITEM_REL
           --            GROUP BY C_ITEM_ID, C_ITEM_VER_NR)
            (  SELECT C_ITEM_ID,
                      C_ITEM_VER_NR,
                      LISTAGG (p.ITEM_LONG_NM, ':' ON OVERFLOW TRUNCATE)
                          WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
                 FROM NCI_ADMIN_ITEM_REL r, ADMIN_ITEM p
                WHERE     P.ADMIN_ITEM_TYP_ID = 50
                      AND p.ITEM_ID = r.P_ITEM_ID
                      AND p.VER_NR = r.P_ITEM_VER_NR
             GROUP BY C_ITEM_ID, C_ITEM_VER_NR) REL
     WHERE     FR.ADMIN_ITEM_TYP_ID = 54
           AND FR.ITEM_ID = REL.C_ITEM_ID(+)
           AND FR.VER_NR = REL.C_ITEM_VER_NR(+)
    UNION
    SELECT DISTINCT
           REL.PROTO_ID,
           FR.ITEM_NM                                      Form_Long_Name, --rownum Ordinal,--
           FR.ITEM_ID                                      FORM_ID,
           FR.VER_NR                                       Form_Version,
           module.DISP_ORD                                 Module,
           QUESTION.NCI_VER_NR                             QUEST_Version,
           QUESTION.NCI_PUB_ID                             QUEST_ID,
           QUESTION.DISP_ORD                               QUEST_DISP_ORD,
           QUESTION.ITEM_LONG_NM                           QUEST_Long_Name,
           QUESTION.ITEM_NM                                QUEST_SHORT_Name,
           QUESTION.INSTR                                  QUEST_INST,
           DE.ITEM_ID                                      DE_PUB_ID,
           DE.VER_NR                                       DE_VERSION,
           DE.ITEM_LONG_NM                                 CDE_Sort_Name,
           DE.ITEM_NM                                      CDE_Long_Name,
           VD.ITEM_LONG_NM                                 VD_Sort_Name,
           VD.ITEM_NM                                      VD_Long_Name,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')     VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM                  VD_Max_Length,
           FMT.FMT_NM                                      VD_Display_Format,
           dt.NCI_CD                                       VD_DATA_TYPE_NCI,
           dt.NCI_DTTYPE_MAP                               VD_DATA_TYPE_MAP,
           VD.ITEM_id                                      VD_ID,
           VD.VER_NR                                       VD_Version,
           VALUE_DOM.UOM_ID
      FROM ADMIN_ITEM                  de,
           de                          de2,
           NCI_FORM                    FORM,
           ADMIN_ITEM                  FR,
           NCI_ADMIN_ITEM_REL          MODULE,
           NCI_ADMIN_ITEM_REL_ALT_KEY  QUESTION,
           ADMIN_ITEM                  VD,
           VALUE_DOM,
           FMT,
           DATA_TYP                    DT,
           --           (  SELECT C_ITEM_ID,
           --                     C_ITEM_VER_NR,
           --                     LISTAGG (P_ITEM_ID || 'v' || P_ITEM_VER_NR,
           --                              ':'
           --                              ON OVERFLOW TRUNCATE)
           --                     WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
           --                FROM NCI_ADMIN_ITEM_REL
           --            GROUP BY C_ITEM_ID, C_ITEM_VER_NR) REL,
            (  SELECT C_ITEM_ID,
                      C_ITEM_VER_NR,
                      LISTAGG (p.ITEM_LONG_NM, ':' ON OVERFLOW TRUNCATE)
                          WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
                 FROM NCI_ADMIN_ITEM_REL r, ADMIN_ITEM p
                WHERE     P.ADMIN_ITEM_TYP_ID = 50
                      AND p.ITEM_ID = r.P_ITEM_ID
                      AND p.VER_NR = r.P_ITEM_VER_NR
             GROUP BY C_ITEM_ID, C_ITEM_VER_NR) REL,
           (SELECT REF.REF_DESC, REF.ITEM_ID, REF.VER_NR
              FROM REF, OBJ_KEY
             WHERE     REF.REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                   AND OBJ_KEY.OBJ_KEY_DESC = 'Preferred Question Text') REF
     WHERE     DE.ADMIN_ITEM_TYP_ID = 4                                -- (DE)
           AND VD.ADMIN_ITEM_TYP_ID = 3                                 --(VD)
           AND FR.ADMIN_ITEM_TYP_ID = 54
           AND FORM.ITEM_ID = module.P_ITEM_ID
           AND FORM.VER_NR = module.P_ITEM_VER_NR
           AND FR.ITEM_ID = REL.C_ITEM_ID(+)
           AND FR.VER_NR = REL.C_ITEM_VER_NR(+)
           AND module.REL_TYP_ID = 61
           AND QUESTION.REL_TYP_ID = 63
           AND QUESTION.P_ITEM_ID = module.C_ITEM_ID
           AND QUESTION.P_ITEM_VER_NR = module.C_ITEM_VER_NR
           AND QUESTION.C_ITEM_ID = de.ITEM_ID
           AND de.ITEM_ID = de2.ITEM_ID
           AND de.ver_nr = de2.VER_NR
           AND QUESTION.C_ITEM_VER_NR = de.VER_NR
           AND DE.ITEM_ID = REF.ITEM_ID(+)
           AND DE.VER_NR = REF.VER_NR(+)                                  /**/
           AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
           AND VALUE_DOM.dttype_id = DT.dttype_id
           AND de2.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND de2.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
           AND VD.VER_NR = VALUE_DOM.VER_NR
           AND FORM.ITEM_ID = FR.ITEM_ID
           AND FORM.VER_NR = FR.VER_NR
    -- AND PROTO_ID IS NOT NULL
  AND FORM.ITEM_ID = 3284264
    ORDER BY 3, 5, 7;
