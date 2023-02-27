--Related to JIRA851 and JIRA859--
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW
(RAI, PUBLICID, LONGNAME, PREFERREDNAME, PREFERREDDEFINITION, 
 VERSION, WORKFLOWSTATUS, CONTEXTNAME, CONTEXTVERSION, ORIGIN, 
 REGISTRATIONSTATUS, "dateModified", DATAELEMENTCONCEPT, VALUEDOMAIN, REFERENCEDOCUMENTSLIST, 
 CLASSIFICATIONSLIST, ALTERNATENAMELIST, DATAELEMENTDERIVATION)
BEQUEATH DEFINER
AS 
SELECT                                                   ---de.de_idseq,
             '2.16.840.1.113883.3.26.2'                     "RAI",
             AI.ITEM_ID                                     "PublicId",
             AI.ITEM_NM                                     "LongName",
             AI.ITEM_LONG_NM                                "PreferredName",
             AI.ITEM_DESC                                   "PreferredDefinition",
             AI.VER_NR                                      "Version",
             AI.ADMIN_STUS_NM_DN                            "WorkflowStatus",
             AI.CNTXT_NM_DN                                 "ContextName",
             AI.CNTXT_VER_NR                                "ContextVersion",
             NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)               "Origin",
             AI.REGSTR_STUS_NM_DN                           "RegistrationStatus",
             NVL (AI.LST_UPD_DT, AI.CREATION_DT)            "dateModified",
               CDEBROWSER_DEC_T (
                 DEC.DEC_ID,
                 DEC.DEC_LONG_NAME,
                 DEC.PREFERRED_DEFINITION,
                 DEC.DEC_PREFERRED_NAME,
                 DEC.DEC_VERSION,
                 DEC.ASL_NAME,
                 DEC.DEC_CONTEXT_NAME,
                 DEC.DEC_CONTEXT_VERSION,
                 ADMIN_COMPONENT_WITH_ID_LN_T (
                     DEC.CD_ID,
                     DEC.CD_CONTEXT_NAME,
                     DEC.CD_CONTEXT_VERSION,
                     DEC.CD_LONG_NAME,
                     DEC.CD_VERSION,
                     DEC.CD_PREFERRED_NAME),
              ADMIN_COMPONENT_WITH_CON_T (
                     DEC.OC_ID,
                     DEC.OC_CONTEXT_NAME,
                     DEC.OC_CONTEXT_VERSION,
                     DEC.OC_LONG_NAME,
                     DEC.OC_VERSION,
                     DEC.OC_PREFERRED_NAME,
                     CAST (
                         MULTISET (
                               SELECT CON.ITEM_LONG_NM
                                          PREFERRED_NAME,
                                      CON.ITEM_NM
                                          LONG_NAME,
                                      CON.ITEM_ID
                                          CON_ID,
                                      CON.DEF_SRC
                                          DEFINITION_SOURCE,
                                      NVL (CON.ORIGIN, CON.ORIGIN_ID_DN)
                                          ORIGIN,
                                      CNCPT.EVS_SRC
                                          EVS_SOURCE,
                                      DECODE (COM.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          PRIMARY_FLAG_IND,
                                      COM.NCI_ORD
                                          DISPLAY_ORDER
                                 FROM CNCPT_ADMIN_ITEM COM,
                                      ADMIN_ITEM    CON,
                                      VW_CNCPT_19   CNCPT
                                WHERE     DEC.OC_ID = COM.ITEM_ID(+)
                                      AND DEC.OC_VERSION = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC)
                             AS CONCEPTS_LIST_T)),
           ADMIN_COMPONENT_WITH_CON_T (
                     DEC.PROP_ID,
                     DEC.PT_CONTEXT_NAME,
                     DEC.PT_CONTEXT_VERSION,
                     DEC.PT_LONG_NAME,
                     DEC.PT_VERSION,
                     DEC.PT_PREFERRED_NAME,
                     CAST (
                         MULTISET (
                               SELECT CON.ITEM_LONG_NM
                                          PREFERRED_NAME,
                                      CON.ITEM_NM
                                          LONG_NAME,
                                      CON.ITEM_ID
                                          CON_ID,
                                      CON.DEF_SRC
                                          DEFINITION_SOURCE,
                                      NVL (CON.ORIGIN, CON.ORIGIN_ID_DN)
                                          ORIGIN,
                                      CNCPT.EVS_SRC
                                          EVS_SOURCE,
                                      DECODE (COM.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          PRIMARY_FLAG_IND,
                                      COM.NCI_ORD
                                          DISPLAY_ORDER
                                 FROM CNCPT_ADMIN_ITEM COM,
                                      ADMIN_ITEM    CON,
                                      VW_CNCPT_19   CNCPT
                                WHERE     DEC.PROP_ID = COM.ITEM_ID(+)
                                      AND DEC.PT_VERSION = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC, CNCPT.EVS_SRC)
                             AS CONCEPTS_LIST_T)),
               DEC.OBJ_CLASS_QUALIFIER,
                DEC.PROPERTY_QUALIFIER,
                 DEC.DEC_ORIGIN)                            "DataElementConcept",
             CDEBROWSER_VD_T749 (
                 VDAI.ITEM_ID,
                 VDAI.ITEM_LONG_NM,
                 VDAI.ITEM_DESC,
                 VDAI.ITEM_NM,
                 VDAI.VER_NR,
                 VDAI.ADMIN_STUS_NM_DN,
                 NVL (VDAI.LST_UPD_DT, VDAI.CREATION_DT),
                 VDAI.CNTXT_NM_DN,
                 VDAI.CNTXT_VER_NR,
                 ADMIN_COMPONENT_WITH_ID_LN_T (
                     CD.ITEM_ID,
                     CD.CNTXT_NM_DN,
                     CD.CNTXT_VER_NR,
                     CD.ITEM_LONG_NM,
                     CD.VER_NR,
                     CD.ITEM_NM),                                        /* */
                 DATA_TYP.DTTYPE_NM,
                 DECODE (VD.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non-enumerated'),
                  UOM.UOM_NM,
                  FMT.FMT_NM,
                 VD.VAL_DOM_MAX_CHAR,
                 VD.VAL_DOM_MIN_CHAR,
                 VD.NCI_DEC_PREC,
                 VD.CHAR_SET_ID,
                 VD.VAL_DOM_HIGH_VAL_NUM,
                 VD.VAL_DOM_LOW_VAL_NUM,
                 NVL (VDAI.ORIGIN, VDAI.ORIGIN_ID_DN),
                 ADMIN_COMPONENT_WITH_CON_T (
                     REP.ITEM_ID,
                     REP.CNTXT_NM_DN,
                     REP.CNTXT_VER_NR,
                     REP.ITEM_LONG_NM,
                     REP.VER_NR,
                     REP.ITEM_NM,
                     CAST (
                         MULTISET (
                               SELECT CON.ITEM_LONG_NM
                                          PREFERRED_NAME,
                                      CON.ITEM_NM
                                          LONG_NAME,
                                      CON.ITEM_ID
                                          CON_ID,
                                      CON.DEF_SRC
                                          DEFINITION_SOURCE,
                                      NVL (CON.ORIGIN, CON.ORIGIN_ID_DN)
                                          ORIGIN,
                                      CNCPT.EVS_SRC
                                          EVS_SOURCE,
                                      DECODE (COM.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          PRIMARY_FLAG_IND,
                                      COM.NCI_ORD
                                          DISPLAY_ORDER
                                 FROM CNCPT_ADMIN_ITEM COM,
                                      ADMIN_ITEM    CON,
                                      VW_CNCPT_19   CNCPT
                                WHERE     REP.ITEM_ID = COM.ITEM_ID(+)
                                      AND REP.VER_NR = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC, CNCPT.EVS_SRC, CON.ITEM_ID)
                             AS CONCEPTS_LIST_T)),
             CAST (
                     MULTISET (
                           SELECT PV.PERM_VAL_NM,
                                  PV.PERM_VAL_DESC_TXT,
                                  VM.ITEM_DESC,
                                  GET_CONCEPTS2 (VM.ITEM_ID, VM.VER_NR)
                                      MEANINGCONCEPTS,
                                  /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                        vm.condr_idseq)
                                        MeaningConceptOrigin,  */
                                  GET_CONCEPT_ORIGIN (VM.ITEM_ID, VM.VER_NR)
                                      MEANINGCONCEPTORIGIN,
                                  NCI_11179.GET_CONCEPT_ORDER (VM.ITEM_ID,
                                                               VM.VER_NR)
                                      MEANINGCONCEPTDISPLAYORDER,
                                  PV.PERM_VAL_BEG_DT,
                                  PV.PERM_VAL_END_DT,
                                  VM.ITEM_ID,
                                  VM.VER_NR,
                                  NVL (VM.LST_UPD_DT, VM.CREATION_DT),
                                  CAST (
                                      MULTISET (
                                            SELECT DES.CNTXT_NM_DN,
                                                   TO_CHAR (DES.CNTXT_VER_NR),
                                                   DES.NM_DESC,
                                                   OK.OBJ_KEY_DESC,
                                                   DECODE (DES.LANG_ID,
                                                           1000, 'ENGLISH',
                                                           1004, 'SPANISH',
                                                           1007, 'ICELANDIC') -- decode
                                              FROM (select*from onedata_wa.ALT_NMS where NVL(FLD_DELETE,0 )=0
                                              ) DES, OBJ_KEY OK
                                             WHERE     VM.ITEM_ID = DES.ITEM_ID(+)
                                                   AND VM.VER_NR = DES.VER_NR(+)
                                                   AND DES.NM_TYP_ID =
                                                       OK.OBJ_KEY_ID(+)
                                    ORDER BY DES.CNTXT_NM_DN, DES.NM_DESC
                                          )
                                          AS MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM PERM_VAL PV, ADMIN_ITEM VM
                            WHERE     PV.VAL_DOM_ITEM_ID = VD.ITEM_ID
                                  AND PV.VAL_DOM_VER_NR = VD.VER_NR
                                  AND PV.NCI_VAL_MEAN_ITEM_ID = VM.ITEM_ID
                                  AND PV.NCI_VAL_MEAN_VER_NR = VM.VER_NR
                                  AND VM.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY PV.PERM_VAL_NM,VM.ITEM_ID 
                         )
                         AS MDSR_749_PV_VD_LIST_T)
                         ,
                 CAST (
                     MULTISET (
                           SELECT CON.ITEM_LONG_NM
                                      PREFERRED_NAME,
                                  CON.ITEM_NM
                                      LONG_NAME,
                                  CON.ITEM_ID
                                      CON_ID,
                                  CON.DEF_SRC
                                      DEFINITION_SOURCE,
                                  NVL (CON.ORIGIN, CON.ORIGIN_ID_DN)
                                      ORIGIN,
                                  CNCPT.EVS_SRC
                                      EVS_SOURCE,
                                  DECODE (COM.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                      PRIMARY_FLAG_IND,
                                  COM.NCI_ORD
                                      DISPLAY_ORDER
                             FROM CNCPT_ADMIN_ITEM COM,
                                  ADMIN_ITEM    CON,
                                  VW_CNCPT_19   CNCPT
                            WHERE     VD.ITEM_ID = COM.ITEM_ID(+)
                                  AND VD.VER_NR = COM.VER_NR(+)
                                  AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                  AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                  AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                  AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                  AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                         ORDER BY NCI_ORD DESC, CON.ITEM_ID, CNCPT.EVS_SRC)
                         AS CONCEPTS_LIST_T))               "ValueDomain" ,
--     --select     
       CAST (
                 MULTISET (
                       SELECT RD.REF_NM,
                              ORG.ORG_NM,
                              --  ok.OBJ_KEY_DESC,
                              OK.OBJ_KEY_DESC,
                              RD.REF_DESC,
                              RD.URL,
                              DECODE (RD.LANG_ID,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC'),
                              RD.DISP_ORD
                         FROM REF RD, OBJ_KEY OK, NCI_ORG ORG
                        WHERE     RD.REF_TYP_ID = OK.OBJ_KEY_ID(+)
                              AND RD.ORG_ID = ORG.ENTTY_ID(+)
                              --, sbr.organizations org
                              AND DE.ITEM_ID = RD.ITEM_ID
                              AND DE.VER_NR = RD.VER_NR
                     ORDER BY RD.DISP_ORD)
                     AS CDEBROWSER_RD_LIST_T)               "ReferenceDocumentsList"
             ,CAST (
                 MULTISET (
                       SELECT ADMIN_COMPONENT_WITH_ID_T (CSV.CS_ITEM_ID,
                                                         CSV.CS_CNTXT_NM,
                                                         CSV.CS_CNTXT_VER_NR,
                                                         CSV.CS_ITEM_LONG_NM,
                                                         CSV.CS_VER_NR),
                              CSV.CSI_ITEM_NM,
                              CSV.CSITL_NM,
                              CSV.CSI_ITEM_ID,
                              CSV.CSI_VER_NR
                         FROM CDEBROWSER_CS_VIEW_N CSV
                        WHERE     DE.ITEM_ID = CSV.DE_ITEM_ID
                              AND DE.VER_NR = CSV.DE_VER_NR
							  --AND CSV.CS_CNTXT_NM<>'TEST'
                     ORDER BY CSV.CS_ITEM_ID,
                              CSV.CS_VER_NR,
                              CSV.CSI_ITEM_ID,
                              CSV.CSI_VER_NR)
                     AS CDEBROWSER_CSI_LIST_T)              "ClassificationsList"
                     ,
       CAST (
                 MULTISET (
                       SELECT DES.CNTXT_NM_DN,
                              TO_CHAR (DES.CNTXT_VER_NR),
                              DES.NM_DESC,
                              OK.OBJ_KEY_DESC,
                              DECODE (DES.LANG_ID,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC')
                         FROM (select*from onedata_wa.ALT_NMS where NVL(FLD_DELETE,0)=0 ) DES, OBJ_KEY OK
                        WHERE     DE.ITEM_ID = DES.ITEM_ID
                              AND DE.VER_NR = DES.VER_NR
                              AND DES.NM_TYP_ID = OK.OBJ_KEY_ID(+)
                     ORDER BY DES.CNTXT_NM_DN, DES.NM_DESC)
                     AS CDEBROWSER_ALTNAME_LIST_T)          "AlternateNameList",
         DERIVED_DATA_ELEMENT_T (CCD.CRTL_NAME,
                                     CCD.DESCRIPTION,
                                     CCD.METHODS,
                                     CCD.RULE,
                                     CCD.CONCAT_CHAR,
                                     "DataElementsList")    "DataElementDerivation"
FROM ADMIN_ITEM       AI,
DE       DE,
VALUE_DOM                   VD,
ADMIN_ITEM                  VDAI,
ADMIN_ITEM                  CD,
CDEBROWSER_DE_DEC_VIEW      DEC,
ADMIN_ITEM                  REP,
CDEBROWSER_COMPLEX_DE_VIEW_N CCD,
DATA_TYP,
FMT,
UOM
WHERE        AI.ITEM_ID = DEC.DE_ID
             AND AI.VER_NR = DEC.DE_VERSION
             AND AI.ADMIN_STUS_NM_DN NOT IN
                     ('RETIRED WITHDRAWN', 'RETIRED DELETED')
             AND AI.ITEM_ID = DE.ITEM_ID
             AND AI.VER_NR = DE.VER_NR
             AND AI.ADMIN_ITEM_TYP_ID = 4
             AND CD.ADMIN_ITEM_TYP_ID = 1
             AND CD.ITEM_ID = VD.CONC_DOM_ITEM_ID
             AND CD.VER_NR = VD.CONC_DOM_VER_NR
			 AND REP.ADMIN_ITEM_TYP_ID = 7
             AND REP.ITEM_ID = VD.REP_CLS_ITEM_ID(+)
             AND REP.VER_NR = VD.REP_CLS_VER_NR(+)
             AND DE.VAL_DOM_ITEM_ID = VDAI.ITEM_ID
             AND DE.VAL_DOM_VER_NR = VDAI.VER_NR
             AND VDAI.ADMIN_ITEM_TYP_ID = 3
             AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
             AND DE.VAL_DOM_VER_NR = VD.VER_NR
             AND AI.ITEM_ID = CCD.ITEM_ID(+)
             AND AI.VER_NR = CCD.VER_NR(+)
             AND VD.DTTYPE_ID = DATA_TYP.DTTYPE_ID(+)
             AND VD.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
             AND VD.UOM_ID=UOM.UOM_ID(+)
    ORDER BY  AI.CNTXT_NM_DN ,AI.ITEM_ID, AI.VER_NR;

GRANT SELECT on DE_EXCEL_GENERATOR_VIEW to ONEDATA_RO;
GRANT EXECUTE, DEBUG on VALID_VALUE_T_245 to ONEDATAR_RO; 
GRANT EXECUTE,DEBUG on  VALID_VALUE_LIST_T_245 to ONEDATAR_RO;  
GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW TO ONEDATA_RA;
GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW TO ONEDATA_RO;
GRANT DEBUG on NCI_CADSR_PUSH to ONEDATA_RO;
GRANT SELECT on ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on ADMIN_ITEM_AUDIT to ONEDATA_RO;
GRANT SELECT on ADMIN_ITEM_CLSFCTN_SCHM_ITEM to ONEDATA_RO;
GRANT SELECT on ADMIN_ITEM_LANG_VAR to ONEDATA_RO;
GRANT SELECT on ADMIN_ITEM_REF_DOC to ONEDATA_RO;
GRANT SELECT on ALT_DEF to ONEDATA_RO;
GRANT SELECT on ALT_NMS to ONEDATA_RO;
GRANT SELECT on CASE_FILES to ONEDATA_RO;
GRANT SELECT on CHAR_SET to ONEDATA_RO;
GRANT SELECT on CLSFCTN_SCHM to ONEDATA_RO;
GRANT SELECT on CLSFCTN_SCHM_ITEM to ONEDATA_RO;
GRANT SELECT on CLSFCTN_SCHM_ITEM_PERM_VAL to ONEDATA_RO;
GRANT SELECT on CLSFCTN_SCHM_ITEM_REL to ONEDATA_RO;
GRANT SELECT on CNCPT to ONEDATA_RO;
GRANT SELECT on CNCPT_ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on CNCPT_CONC_DOM to ONEDATA_RO;
GRANT SELECT on CNCPT_CSI to ONEDATA_RO;
GRANT SELECT on CNCPT_DEC to ONEDATA_RO;
GRANT SELECT on CNCPT_OBJ_CLS to ONEDATA_RO;
GRANT SELECT on CNCPT_PROP to ONEDATA_RO;
GRANT SELECT on CNCPT_VAL_MEAN to ONEDATA_RO;
GRANT SELECT on CNTCT to ONEDATA_RO;
GRANT SELECT on CNTXT to ONEDATA_RO;
GRANT SELECT on CNTXT_REL to ONEDATA_RO;
GRANT SELECT on COMPONENT_EVENT to ONEDATA_RO;
GRANT SELECT on CONC_DOM to ONEDATA_RO;
GRANT SELECT on CONC_DOM_REL to ONEDATA_RO;
GRANT SELECT on CONC_DOM_VAL_MEAN to ONEDATA_RO;
GRANT SELECT on CONTEXTS_VIEW to ONEDATA_RO;
GRANT SELECT on DATA_ELEMENTS_VIEW to ONEDATA_RO;
GRANT SELECT on DATA_ELEMENT_CONCEPTS_VIEW to ONEDATA_RO;
GRANT SELECT on DATA_TYP to ONEDATA_RO;
GRANT SELECT on DE to ONEDATA_RO;
GRANT SELECT on DERV_RUL to ONEDATA_RO;
GRANT SELECT on DE_CONC to ONEDATA_RO;
GRANT SELECT on DE_CONC_REL to ONEDATA_RO;
GRANT SELECT on DE_DERV to ONEDATA_RO;
GRANT SELECT on DE_REL to ONEDATA_RO;
GRANT SELECT on FMT to ONEDATA_RO;
GRANT SELECT on GLSRY to ONEDATA_RO;
GRANT SELECT on IMPORT_MAPPING_PARAM to ONEDATA_RO;
GRANT SELECT on IMPORT_MAPPING_PARAM_FLTR to ONEDATA_RO;
GRANT SELECT on INSTALLED_COMPONENT to ONEDATA_RO;
GRANT SELECT on LANG to ONEDATA_RO;
GRANT SELECT on MLOG$_ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on NCI_ADMIN_ITEM_EXT to ONEDATA_RO;
GRANT SELECT on NCI_ADMIN_ITEM_REL to ONEDATA_RO;
GRANT SELECT on NCI_ADMIN_ITEM_REL_ALT_KEY to ONEDATA_RO;
GRANT SELECT on NCI_AI_TYP_VALID_STUS to ONEDATA_RO;
GRANT SELECT on NCI_ALT_KEY_ADMIN_ITEM_REL to ONEDATA_RO;
GRANT SELECT on NCI_CHANGE_HISTORY to ONEDATA_RO;
GRANT SELECT on NCI_CLSFCTN_SCHM_ITEM to ONEDATA_RO;
GRANT SELECT on NCI_CSI_ALT_DEFNMS to ONEDATA_RO;
GRANT SELECT on NCI_DATA_AUDT to ONEDATA_RO;
GRANT SELECT on NCI_DLOAD_ALS to ONEDATA_RO;
GRANT SELECT on NCI_DLOAD_ALS_FORM to ONEDATA_RO;
GRANT SELECT on NCI_DLOAD_DTL to ONEDATA_RO;
GRANT SELECT on NCI_DS_DTL to ONEDATA_RO;
GRANT SELECT on NCI_DS_HDR to ONEDATA_RO;
GRANT SELECT on NCI_DS_RSLT to ONEDATA_RO;
GRANT SELECT on NCI_DS_RSLT_DTL to ONEDATA_RO;
GRANT SELECT on NCI_ENTTY to ONEDATA_RO;
GRANT SELECT on NCI_ENTTY_ADDR to ONEDATA_RO;
GRANT SELECT on NCI_ENTTY_COMM to ONEDATA_RO;
GRANT SELECT on NCI_FORM to ONEDATA_RO;
GRANT SELECT on NCI_FORM_TA to ONEDATA_RO;
GRANT SELECT on NCI_FORM_TA_REL to ONEDATA_RO;
GRANT SELECT on NCI_INSTR to ONEDATA_RO;
GRANT SELECT on NCI_JOB_LOG to ONEDATA_RO;
GRANT SELECT on NCI_MDR_DEBUG to ONEDATA_RO;
GRANT SELECT on NCI_MODULE to ONEDATA_RO;
GRANT SELECT on NCI_OC_RECS to ONEDATA_RO;
GRANT SELECT on NCI_ORG to ONEDATA_RO;
GRANT SELECT on NCI_PROTCL to ONEDATA_RO;
GRANT SELECT on NCI_PRSN to ONEDATA_RO;
GRANT SELECT on NCI_QUEST_VALID_VALUE to ONEDATA_RO;
GRANT SELECT on NCI_QUEST_VV_REP to ONEDATA_RO;
GRANT SELECT on NCI_STG_ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on NCI_STG_AI_CNCPT to ONEDATA_RO;
GRANT SELECT on NCI_STG_AI_CNCPT_CREAT to ONEDATA_RO;
GRANT SELECT on NCI_STG_AI_REL to ONEDATA_RO;
GRANT SELECT on NCI_STG_ALT_NMS to ONEDATA_RO;
GRANT SELECT on NCI_STG_CDE_CREAT to ONEDATA_RO;
GRANT SELECT on NCI_STG_PV_VM_BULK to ONEDATA_RO;
GRANT SELECT on NCI_STG_PV_VM_IMPORT to ONEDATA_RO;
GRANT SELECT on NCI_USR_CART to ONEDATA_RO;
GRANT SELECT on NCI_VAL_MEAN to ONEDATA_RO;
GRANT SELECT on OBJ_CLS to ONEDATA_RO;
GRANT SELECT on OBJ_CLS_REL to ONEDATA_RO;
GRANT SELECT on OBJ_KEY to ONEDATA_RO;
GRANT SELECT on OBJ_TYP to ONEDATA_RO;
GRANT SELECT on OD_CNSTRNT_TYP to ONEDATA_RO;
GRANT SELECT on ONEDATA_MIGRATION_ERROR to ONEDATA_RO;
GRANT SELECT on ORG to ONEDATA_RO;
GRANT SELECT on ORG_CNTCT to ONEDATA_RO;
GRANT SELECT on PERM_VAL to ONEDATA_RO;
GRANT SELECT on PROP to ONEDATA_RO;
GRANT SELECT on REF to ONEDATA_RO;
GRANT SELECT on REF_DOC to ONEDATA_RO;
GRANT SELECT on REGIST_RUL to ONEDATA_RO;
GRANT SELECT on REGIST_RUL_REQ_COLMNS to ONEDATA_RO;
GRANT SELECT on REP_CLS to ONEDATA_RO;
GRANT SELECT on RE_MISC to ONEDATA_RO;
GRANT SELECT on RE_OPERATORS to ONEDATA_RO;
GRANT SELECT on RE_RULES to ONEDATA_RO;
GRANT SELECT on RE_RULE_STEPS to ONEDATA_RO;
GRANT SELECT on RUPD$_ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on SAG_LOAD_CONCEPTS_EVS to ONEDATA_RO;
GRANT SELECT on SAG_MIGR_LOV_ERR to ONEDATA_RO;
GRANT SELECT on STUS_MSTR to ONEDATA_RO;
GRANT SELECT on STUS_TYP to ONEDATA_RO;
GRANT SELECT on SYSTEM_APPLICATION to ONEDATA_RO;
GRANT SELECT on SYSTEM_COLUMNS to ONEDATA_RO;
GRANT SELECT on SYSTEM_COLUMNS_DATA to ONEDATA_RO;
GRANT SELECT on SYSTEM_COLUMN_DE to ONEDATA_RO;
GRANT SELECT on SYSTEM_CONSTRAINTS to ONEDATA_RO;
GRANT SELECT on SYSTEM_TABLES to ONEDATA_RO;
GRANT SELECT on TEMP_CSI_PATH to ONEDATA_RO;
GRANT SELECT on TEST_RESULTS to ONEDATA_RO;
GRANT SELECT on TMP_DATA_AUDT to ONEDATA_RO;
GRANT SELECT on UOM to ONEDATA_RO;
GRANT SELECT on USR_GRP to ONEDATA_RO;
GRANT SELECT on VALUE_DOM to ONEDATA_RO;
GRANT SELECT on VALUE_DOMAINS_VIEW to ONEDATA_RO;
GRANT SELECT on VAL_DOM_REL to ONEDATA_RO;
GRANT SELECT on VAL_MEAN to ONEDATA_RO;
GRANT SELECT on VAL_MEAN_LANG_VAR to ONEDATA_RO;
GRANT SELECT on VER_LVL_OPTS to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_ITEM to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_ITEM_GLBL to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_ITEM_VM_MATCH to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_ITEM_WITH_EXT to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_STUS to ONEDATA_RO;
GRANT SELECT on VW_ADMIN_STUS_RUL to ONEDATA_RO;
GRANT SELECT on VW_AI_CSI to ONEDATA_RO;
GRANT SELECT on VW_ALS_CDE_VD_PV_RAW_DATA_DD to ONEDATA_RO;
GRANT SELECT on VW_ALS_FIELD_FORM_DD to ONEDATA_RO;
GRANT SELECT on VW_ALS_FIELD_RAW_DATA to ONEDATA_RO;
GRANT SELECT on VW_ALT_NMS to ONEDATA_RO;
GRANT SELECT on VW_CD_PSV_CNSTRNT to ONEDATA_RO;
GRANT SELECT on VW_CHAR_SET to ONEDATA_RO;
GRANT SELECT on VW_CLSFCTN_SCHM to ONEDATA_RO;
GRANT SELECT on VW_CLSFCTN_SCHM_ITEM to ONEDATA_RO;
GRANT SELECT on VW_CMNTS to ONEDATA_RO;
GRANT SELECT on VW_CNCPT to ONEDATA_RO;
GRANT SELECT on VW_CNCPT_ALL to ONEDATA_RO;
GRANT SELECT on VW_CNCPT_CHLDRN to ONEDATA_RO;
GRANT SELECT on VW_CNCPT_RT_PRMRY to ONEDATA_RO;
GRANT SELECT on VW_CNTCT to ONEDATA_RO;
GRANT SELECT on VW_CNTXT to ONEDATA_RO;
GRANT SELECT on VW_CONC_DOM to ONEDATA_RO;
GRANT SELECT on VW_CSI_FORM_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_NODE_DEC_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_NODE_DE_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_NODE_FORM_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_NODE_VD_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_ONLY_NODE_DE_REL to ONEDATA_RO;
GRANT SELECT on VW_CSI_TREE to ONEDATA_RO;
GRANT SELECT on VW_CSI_TREE_NODE to ONEDATA_RO;
GRANT SELECT on VW_CSI_TREE_NODE_REL to ONEDATA_RO;
GRANT SELECT on VW_DATA_ELEM_RPT to ONEDATA_RO;
GRANT SELECT on VW_DATA_TYP to ONEDATA_RO;
GRANT SELECT on VW_DEC_MTCHG to ONEDATA_RO;
GRANT SELECT on VW_DERV_RUL to ONEDATA_RO;
GRANT SELECT on VW_DE_CONC to ONEDATA_RO;
GRANT SELECT on VW_DE_CONC_RELEASED to ONEDATA_RO;
GRANT SELECT on VW_DE_HORT to ONEDATA_RO;
GRANT SELECT on VW_DE_MTCHG to ONEDATA_RO;
GRANT SELECT on VW_DE_REL to ONEDATA_RO;
GRANT SELECT on VW_EXMPLS to ONEDATA_RO;
GRANT SELECT on VW_FORM to ONEDATA_RO;
GRANT SELECT on VW_LIST_USR_CART_NM to ONEDATA_RO;
GRANT SELECT on VW_NCI_AI_CNCPT to ONEDATA_RO;
GRANT SELECT on VW_NCI_AI_CURRNT to ONEDATA_RO;
GRANT SELECT on VW_NCI_AI_FORM to ONEDATA_RO;
GRANT SELECT on VW_NCI_ALT_DEF to ONEDATA_RO;
GRANT SELECT on VW_NCI_ALT_NMS to ONEDATA_RO;
GRANT SELECT on VW_NCI_CONC_DOM to ONEDATA_RO;
GRANT SELECT on VW_NCI_CSI_AI to ONEDATA_RO;
GRANT SELECT on VW_NCI_CSI_DE to ONEDATA_RO;
GRANT SELECT on VW_NCI_CSI_NM to ONEDATA_RO;
GRANT SELECT on VW_NCI_CSI_NODE to ONEDATA_RO;
GRANT SELECT on VW_NCI_DATA_AUDT to ONEDATA_RO;
GRANT SELECT on VW_NCI_DATA_AUDT_FORM to ONEDATA_RO;
GRANT SELECT on VW_NCI_DEC_CNCPT to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_CNCPT to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_HORT to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_PV to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_PV_LEAN to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_VD_ALT_NMS to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_VM_ALT_DEF to ONEDATA_RO;
GRANT SELECT on VW_NCI_DE_VM_ALT_NMS to ONEDATA_RO;
GRANT SELECT on VW_NCI_FORM to ONEDATA_RO;
GRANT SELECT on VW_NCI_FORM_FLAT to ONEDATA_RO;
GRANT SELECT on VW_NCI_FORM_FLAT_REP to ONEDATA_RO;
GRANT SELECT on VW_NCI_FORM_MODULE to ONEDATA_RO;
GRANT SELECT on VW_NCI_MODULE_QUEST to ONEDATA_RO;
GRANT SELECT on VW_NCI_MOD_QUEST_VV to ONEDATA_RO;
GRANT SELECT on VW_NCI_QUEST_VALID_VALUE to ONEDATA_RO;
GRANT SELECT on VW_NCI_REP_TERM to ONEDATA_RO;
GRANT SELECT on VW_NCI_USED_BY to ONEDATA_RO;
GRANT SELECT on VW_NCI_USR_CART to ONEDATA_RO;
GRANT SELECT on VW_NCI_VD_CNCPT to ONEDATA_RO;
GRANT SELECT on VW_NCI_VD_PV to ONEDATA_RO;
GRANT SELECT on VW_NCI_VD_VM_ALT_DEF to ONEDATA_RO;
GRANT SELECT on VW_NCI_VD_VM_ALT_NMS to ONEDATA_RO;
GRANT SELECT on VW_OBJ_CLS to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_1 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_10 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_11 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_12 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_13 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_14 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_15 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_2 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_3 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_4 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_5 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_6 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_7 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_8 to ONEDATA_RO;
GRANT SELECT on VW_OBJ_KEY_9 to ONEDATA_RO;
GRANT SELECT on VW_OC_PROP to ONEDATA_RO;
GRANT SELECT on VW_PERM_VAL_FOR_DE to ONEDATA_RO;
GRANT SELECT on VW_PERM_VAL_VAL_DOM_CONC_DOM to ONEDATA_RO;
GRANT SELECT on VW_PROP to ONEDATA_RO;
GRANT SELECT on VW_PROTCL to ONEDATA_RO;
GRANT SELECT on VW_REF to ONEDATA_RO;
GRANT SELECT on VW_REGIST_AUTH to ONEDATA_RO;
GRANT SELECT on VW_REGIS_STUS_RUL to ONEDATA_RO;
GRANT SELECT on VW_REGSTR_STUS to ONEDATA_RO;
GRANT SELECT on VW_REP_CLS to ONEDATA_RO;
GRANT SELECT on VW_STG_BULK_CNTXT_UPD to ONEDATA_RO;
GRANT SELECT on VW_SYS_TBL_COL to ONEDATA_RO;
GRANT SELECT on VW_VALUE_DOM to ONEDATA_RO;
GRANT SELECT on VW_VALUE_DOM_COMP to ONEDATA_RO;
GRANT SELECT on VW_VAL_MEAN to ONEDATA_RO;
GRANT SELECT on VW_VAL_MEAN_CONC_DOM to ONEDATA_RO;
GRANT SELECT on VW_VAL_MEAN_PSV_CNSTRNT to ONEDATA_RO;

