CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA
(PROTOCOL, FORM_LONG_NAME, FORM_ID, FORM_VERSION,FORM_INSTRUCTION, MODULE_DISPLAY_ORDER, 
 MODULE_LONG_NAME,  MODULE_INSTRUCTION,QUEST_VERSION, QUEST_ID, QUEST_DISP_ORD, QUEST_LONG_NAME, 
 QUEST_SHORT_NAME, ISMANDATORY, QUEST_INSTR, DE_PUB_ID, DE_VERSION, 
 CDE_SHORT_NAME, CDE_LONG_NAME, VD_SHORT_NAME, VD_LONG_NAME, VAL_DOM_MAX_CHAR, 
 VAL_DOM_TYP_ID, VD_MAX_LENGTH, VD_MIN_LENGTH, VD_DISPLAY_FORMAT, VD_DATA_TYPE_NCI, 
 VD_DATA_TYPE_MAP, VD_ID, VD_VERSION, UOM_ID)
BEQUEATH DEFINER
AS 
SELECT /*+ PARALLEL(4) */
           DISTINCT REL.PROTO_ID,
                    FR.ITEM_NM     Form_Long_Name,         --rownum Ordinal,--
                    FR.ITEM_ID     FORM_ID,
                    FR.VER_NR      Form_Version,
                    FRI.HDR_INSTR FORM_INSTRUCTION,
                    NULL           Module,
                    NULL           Module_INSTRUCTION,
                    NULL          MODULE_LONG_NAME,
                    NULL           QUESTION_Version,
                    NULL           QUESTION_ID,
                    NULL           QUEST_DISP_ORD,
                    'FORM_OID'     QUEST_Long_Name,
                    NULL           QUEST_SORT_Name,
                    NULL           isMandatory,
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
                    NULL           VD_Min_Length,
                    NULL           VD_Display_Format,
                    NULL           VD_DATA_TYPE,
                    NULL           VD_DATA_TYPE_MAP,
                    NULL           VD_ID,
                    NULL           VD_Version,
                     NULL           UOM_ID
      FROM ADMIN_ITEM  FR,
       NCI_FORM FRI,
      
           --           (  SELECT C_ITEM_ID,
           --                     C_ITEM_VER_NR,
           --                     LISTAGG (P_ITEM_ID || 'v' || P_ITEM_VER_NR,
           --                              ':'
           --                              ON OVERFLOW TRUNCATE)
           --                     WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
           --                FROM NCI_ADMIN_ITEM_REL
           --            GROUP BY C_ITEM_ID, C_ITEM_VER_NR)
            (  SELECT /*+ PARALLEL(4) */
                      C_ITEM_ID,
                      C_ITEM_VER_NR,
                      LISTAGG (p.ITEM_LONG_NM, ':' ON OVERFLOW TRUNCATE)
                          WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
                 FROM NCI_ADMIN_ITEM_REL r, ADMIN_ITEM p
                WHERE     P.ADMIN_ITEM_TYP_ID = 50
                      AND p.ITEM_ID = r.P_ITEM_ID
                      AND p.VER_NR = r.P_ITEM_VER_NR
                      AND NVL (p.FLD_DELETE, 0) = 0
             GROUP BY C_ITEM_ID, C_ITEM_VER_NR) REL
     WHERE     FR.ADMIN_ITEM_TYP_ID = 54
           AND NVL (FR.FLD_DELETE, 0) = 0
           AND FR.ITEM_ID = REL.C_ITEM_ID(+)
           AND FR.VER_NR = REL.C_ITEM_VER_NR(+)
           AND FR.ITEM_ID =FRI.ITEM_ID(+)
           AND FR.VER_NR = FRI.VER_NR(+)
        UNION
    SELECT /*+ PARALLEL(4) */
           DISTINCT
           REL.PROTO_ID,
           FR.ITEM_NM
               Form_Long_Name,                             --rownum Ordinal,--
           FR.ITEM_ID
               FORM_ID,
           FR.VER_NR
               Form_Version,
            FORM.HDR_INSTR FORM_INSTRUCTION,
           module.DISP_ORD
               Module,
           MOD.ITEM_NM MODULE_LONG_NAME,
          MODULE.INSTR MODULE_INSTRUCTION,
           QUESTION.NCI_VER_NR
               QUEST_Version,
           QUESTION.NCI_PUB_ID
               QUEST_ID,
           QUESTION.DISP_ORD
               QUEST_DISP_ORD,
           QUESTION.ITEM_LONG_NM
               QUEST_Long_Name,
           QUESTION.ITEM_NM
               QUEST_SHORT_Name,
           DECODE (QUESTION.req_IND,  1, 'TRUE',  0, 'FALSE')
               isMandatory,
           QUESTION.INSTR
               QUEST_INST,
           DE.ITEM_ID
               DE_PUB_ID,
           DE.VER_NR
               DE_VERSION,
           DE.ITEM_LONG_NM
               CDE_Sort_Name,
           DE.ITEM_NM
               CDE_Long_Name,
           VD.ITEM_LONG_NM
               VD_Sort_Name,
           VD.ITEM_NM
               VD_Long_Name,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')
               VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM
               VD_Max_Length,
           VALUE_DOM.VAL_DOM_MIN_CHAR
               VD_Min_Length,
           FMT.FMT_NM
               VD_Display_Format,
           dt.NCI_CD
               VD_DATA_TYPE_NCI,
           dt.NCI_DTTYPE_MAP
               VD_DATA_TYPE_MAP,
           VD.ITEM_id
               VD_ID,
           VD.VER_NR
               VD_Version,
           VALUE_DOM.UOM_ID
      FROM ADMIN_ITEM                  de,
           de                          de2,
           NCI_FORM                    FORM,
           ADMIN_ITEM                  FR,
           NCI_ADMIN_ITEM_REL          MODULE,
           ADMIN_ITEM                  MOD,
           NCI_ADMIN_ITEM_REL_ALT_KEY  QUESTION,
           ADMIN_ITEM                  VD,
           VALUE_DOM,
           FMT,
           DATA_TYP                    DT,
           (  SELECT /*+ PARALLEL(4) */
                     C_ITEM_ID,
                     C_ITEM_VER_NR,
                     LISTAGG (p.ITEM_LONG_NM, ':' ON OVERFLOW TRUNCATE)
                         WITHIN GROUP (ORDER BY DISP_ORD)    PROTO_ID
                FROM NCI_ADMIN_ITEM_REL r, ADMIN_ITEM p
               WHERE     P.ADMIN_ITEM_TYP_ID = 50
                     AND p.ITEM_ID = r.P_ITEM_ID
                     AND p.VER_NR = r.P_ITEM_VER_NR
                     AND NVL (p.FLD_DELETE, 0) = 0
            GROUP BY C_ITEM_ID, C_ITEM_VER_NR) REL,
           (SELECT /*+ PARALLEL(4) */
                   REF.REF_DESC, REF.ITEM_ID, REF.VER_NR
              FROM REF, OBJ_KEY
             WHERE     REF.REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                   AND OBJ_KEY.OBJ_KEY_DESC = 'Preferred Question Text'
                   AND NVL (REF.FLD_DELETE, 0) = 0) REF
     WHERE     DE.ADMIN_ITEM_TYP_ID = 4                                -- (DE)
           AND VD.ADMIN_ITEM_TYP_ID = 3                                 --(VD)
           AND FR.ADMIN_ITEM_TYP_ID = 54
           AND FORM.ITEM_ID = module.P_ITEM_ID
           AND FORM.VER_NR = module.P_ITEM_VER_NR
           AND MOD.ITEM_ID = module.C_ITEM_ID
           AND MOD.VER_NR = module.C_ITEM_VER_NR
           AND FR.ITEM_ID = REL.C_ITEM_ID(+)
           AND FR.VER_NR = REL.C_ITEM_VER_NR(+)
           AND NVL (FR.FLD_DELETE, 0) = 0
           AND module.REL_TYP_ID = 61
           AND NVL (module.FLD_DELETE, 0) = 0
           AND QUESTION.REL_TYP_ID = 63
           AND NVL (QUESTION.FLD_DELETE, 0) = 0
           AND QUESTION.P_ITEM_ID = module.C_ITEM_ID
           AND QUESTION.P_ITEM_VER_NR = module.C_ITEM_VER_NR
           AND QUESTION.C_ITEM_ID = de.ITEM_ID
           AND NVL (DE.FLD_DELETE, 0) = 0
           AND de.ITEM_ID = de2.ITEM_ID
           AND de.ver_nr = de2.VER_NR
           AND QUESTION.C_ITEM_VER_NR = de.VER_NR
           AND DE.ITEM_ID = REF.ITEM_ID(+)
           AND DE.VER_NR = REF.VER_NR(+)                                  /**/
           AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
           AND VALUE_DOM.dttype_id = DT.dttype_id
           AND de2.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND de2.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND NVL (VD.FLD_DELETE, 0) = 0
           AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
           AND VD.VER_NR = VALUE_DOM.VER_NR
           AND FORM.ITEM_ID = FR.ITEM_ID
           AND FORM.VER_NR = FR.VER_NR
    ORDER BY 3, 6, 9;
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD
(COLLECT_ID, COLLECT_TYPE, COLLECT_NAME, COLLECT_DESCRIPTION, PROTOCOL, 
 FORM_ID, FORM_VERSION, FORM_LONG_NAME,FORM_INSTRUCTION, CDE_SHORT_NAME, CDE_LONG_NAME, 
 DE_PUB_ID, DE_VERSION, VD_LONG_NAME, VD_ID, VD_VERSION, 
 MODULE_DISPLAY_ORDER, MODULE_LONG_NAME,MODULE_INSTRUCTION, GR_QVV_VALUE, VV_NUMBERS_IN_QUEST, VAL_DOM_TYP_ID, 
 VD_DATA_TYPE_NCI, VD_DATA_TYPE_MAP, VD_DISPLAY_FORMAT, VAL_DOM_MAX_CHAR, VD_MIN_LENGTH, 
 QUEST_ID, QUEST_VERSION, QUEST_LONG_NAME, QUEST_SHORT_NAME, ISMANDATORY, 
 QUEST_DISP_ORD, QUEST_INSTR, VV_ID, VV_VRERSION, VALID_VALUE, 
 VV_VM_DEFOLD, VV_VM_DEF, VV_DESC_TXT, VV_DISP_ORD, VAL_MEAN_ITEM_ID, 
 VAL_MEAN_VER_NR, COLL_CREAT_DT)
BEQUEATH DEFINER
AS 
SELECT /*+ PARALLEL(4) */
             ALS.HDR_ID         COLLECT_ID,
             92                 COLLECT_TYPE,
             H.DLOAD_HDR_NM     COLLECT_NAME,
             H.CMNT_TXT                                      COLLECT_DESCRIPTION,
             PROTOCOL,
             FORM_ID,
             FORM_VERSION,
             Form_Long_Name,
             FORM_INSTRUCTION,
             CDE_SHORT_NAME,
             CDE_LONG_NAME,
             DE_PUB_ID,
             DE_VERSION,
             VD_LONG_NAME,
             VD_ID,
             VD_Version,
             MODULE_DISPLAY_ORDER,
             MODULE_LONG_NAME,
             MODULE_INSTRUCTION,
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
             VAL_MEAN_VER_NR,
             ALS.CREAT_DT
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
             ALS.CREAT_DT asc,
             Form_ID,
             MODULE_DISPLAY_ORDER NULLS FIRST,
             VD_ID,
             GR_QVV_VALUE NULLS FIRST,
             QUEST_DISP_ORD DESC,
             VV.DISP_ORD;

GRANT SELECT ON ONEDATA_WA.VW_ALS_FIELD_RAW_DATA TO ONEDATA_RO;
GRANT SELECT ON ONEDATA_WA.VW_ALS_FIELD_FORM_DD TO ONEDATA_RO;


