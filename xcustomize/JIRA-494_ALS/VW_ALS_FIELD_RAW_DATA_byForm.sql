DROP VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA;

/* Formatted on 4/27/2021 10:21:30 AM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA
(
    FORM_LONG_NAME,
    FORM_ID,
    FORM_VERSION,
    MODULE,
    QUESTION_VERSION,
    QUESTION_ID,
    Q_DISP_ORD,
    QUESTION_LONG_NAME,
    Q_INSTRUCTION,
    DE_PUB_ID,
    DE_VERSION,
    CDE_SORT_NAME,
    CDE_LONG_NAME,
    VD_SORT_NAME,
    VD_LONG_NAME,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_TYP_ID,
    VD_MAX_LENGTH,
    VD_DISPLAY_FORMAT,
    VD_ID,
    VD_VERSION,
    UOM_ID
)
BEQUEATH DEFINER
AS
    SELECT DISTINCT FR.ITEM_NM     Form_Long_Name,         --rownum Ordinal,--
                    FR.ITEM_ID     FORM_ID,
                    FR.VER_NR      Form_Version,
                    NULL           Module,
                    NULL           QUESTION_Version,
                    NULL           QUESTION_ID,
                    NULL           Q_DISP_ORD,
                    'FORM_OID'     QUESTION_Long_Name,
                    NULL           Q_Instruction,
                    NULL           DE_PUB_ID,
                    NULL           DE_VERSION,
                    'FORM_OID'     CDE_Sort_Name,
                    NULL           CDE_Long_Name,
                    NULL           VD_Sort_Name,
                    NULL           VD_Long_Name,
                    NULL           VAL_DOM_MAX_CHAR,
                    NULL           VAL_DOM_TYP_ID,
                    NULL           VD_Max_Length,
                    NULL           VD_Display_Format,
                    NULL     VD_ID,
                    NULL      VD_Version,
                    NULL           UOM_ID
      FROM ADMIN_ITEM FR
     WHERE FR.ADMIN_ITEM_TYP_ID = 54
    UNION
    SELECT DISTINCT
           FR.ITEM_NM                                      Form_Long_Name, --rownum Ordinal,--
           FR.ITEM_ID                                      FORM_ID,
           FR.VER_NR                                       Form_Version,
           module.DISP_ORD                                 Module,
           QUESTION.NCI_VER_NR                             QUESTION_Version,
           QUESTION.NCI_PUB_ID                             QUESTION_ID,
           QUESTION.DISP_ORD                               Q_DISP_ORD,
           QUESTION.ITEM_LONG_NM                           QUESTION_Long_Name,
           INST.INSTR_LNG                                  Q_Instruction,
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
           (SELECT REF.REF_DESC, REF.ITEM_ID, REF.VER_NR
              FROM REF, OBJ_KEY
             WHERE     REF.REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                   AND OBJ_KEY.OBJ_KEY_DESC = 'Preferred Question Text') REF,
           (SELECT NCI_INSTR.INSTR_ID,
                   NCI_INSTR.INSTR_LNG,
                   INSTR.NCI_PUB_ID,
                   INSTR.NCI_VER_NR
              FROM NCI_INSTR,
                   (  SELECT MIN (INSTR_ID) INSTR_ID, NCI_VER_NR, NCI_PUB_ID
                        FROM NCI_INSTR
                       WHERE NCI_LVL = 'QUESTION'
                    GROUP BY NCI_VER_NR, NCI_PUB_ID) INSTR
             WHERE     NCI_INSTR.NCI_LVL = 'QUESTION'
                   AND NCI_INSTR.INSTR_ID = INSTR.INSTR_ID) INST
     WHERE     DE.ADMIN_ITEM_TYP_ID = 4                                -- (DE)
           AND VD.ADMIN_ITEM_TYP_ID = 3                                 --(VD)
           AND FR.ADMIN_ITEM_TYP_ID = 54
           AND FORM.ITEM_ID = module.P_ITEM_ID
           AND FORM.VER_NR = module.P_ITEM_VER_NR
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
           AND de2.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND de2.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
           AND VD.VER_NR = VALUE_DOM.VER_NR
           AND FORM.ITEM_ID = FR.ITEM_ID
           AND FORM.VER_NR = FR.VER_NR
           AND QUESTION.NCI_VER_NR = INST.NCI_VER_NR(+)
           AND QUESTION.NCI_PUB_ID = INST.NCI_PUB_ID(+)
    ORDER BY 2, 3, 4;
