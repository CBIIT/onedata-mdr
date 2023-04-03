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
               ONEDATA_WA.CDEBROWSER_DEC_T (
                 DEC.DEC_ID,
                 DEC.DEC_PREFERRED_NAME,
                 DEC.PREFERRED_DEFINITION,
                 DEC.DEC_LONG_NAME,
                 DEC.DEC_VERSION,
                 DEC.ASL_NAME,
                 DEC.DEC_CONTEXT_NAME,
                 DEC.DEC_CONTEXT_VERSION,
              ONEDATA_WA.ADMIN_COMPONENT_WITH_ID_LN_T (
                     DEC.CD_ID,
                     DEC.CD_CONTEXT_NAME,
                     DEC.CD_CONTEXT_VERSION,
                    DEC.CD_PREFERRED_NAME,
                     DEC.CD_VERSION,
                     DEC.CD_LONG_NAME ),
              ONEDATA_WA.ADMIN_COMPONENT_WITH_CON_T (
                     DEC.OC_ID,
                     DEC.OC_CONTEXT_NAME,
                     DEC.OC_CONTEXT_VERSION,
                     DEC.OC_PREFERRED_NAME,
                     DEC.OC_VERSION,
                     DEC.OC_LONG_NAME,
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
                                 FROM ONEDATA_WA.CNCPT_ADMIN_ITEM COM,
                                      ONEDATA_WA.ADMIN_ITEM    CON,
                                      ONEDATA_WA.VW_CNCPT_19   CNCPT
                                WHERE     DEC.OC_ID = COM.ITEM_ID(+)
                                      AND DEC.OC_VERSION = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC)
                             AS ONEDATA_WA.CONCEPTS_LIST_T)),
           ONEDATA_WA.ADMIN_COMPONENT_WITH_CON_T (
                     DEC.PROP_ID,
                     DEC.PT_CONTEXT_NAME,
                     DEC.PT_CONTEXT_VERSION,
                     DEC.PT_PREFERRED_NAME, 
                     DEC.PT_VERSION,
                     DEC.PT_LONG_NAME,
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
                                 FROM ONEDATA_WA.CNCPT_ADMIN_ITEM COM,
                                      ONEDATA_WA.ADMIN_ITEM    CON,
                                      ONEDATA_WA.VW_CNCPT_19   CNCPT
                                WHERE     DEC.PROP_ID = COM.ITEM_ID(+)
                                      AND DEC.PT_VERSION = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC, CNCPT.EVS_SRC)
                             AS ONEDATA_WA.CONCEPTS_LIST_T)),
               DEC.OBJ_CLASS_QUALIFIER,
                DEC.PROPERTY_QUALIFIER,
                 DEC.DEC_ORIGIN)                            "DataElementConcept",
             ONEDATA_WA.CDEBROWSER_VD_T749 (
                 VDAI.ITEM_ID,
                 VDAI.ITEM_LONG_NM,
                 VDAI.ITEM_DESC,
                 VDAI.ITEM_NM,
                 VDAI.VER_NR,
                 VDAI.ADMIN_STUS_NM_DN,
                 NVL (VDAI.LST_UPD_DT, VDAI.CREATION_DT),
                 VDAI.CNTXT_NM_DN,
                 VDAI.CNTXT_VER_NR,
                 ONEDATA_WA.ADMIN_COMPONENT_WITH_ID_LN_T (
                     CD.ITEM_ID,
                     CD.CNTXT_NM_DN,
                     CD.CNTXT_VER_NR,
                     CD.ITEM_LONG_NM,
                     CD.VER_NR,
                     CD.ITEM_NM),                                        /* */
                 DATA_TYP.DTTYPE_NM,
                 DECODE (VD.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non Enumerated'),
                  UOM.UOM_NM,
                  FMT.FMT_NM,
                 VD.VAL_DOM_MAX_CHAR,
                 VD.VAL_DOM_MIN_CHAR,
                 VD.NCI_DEC_PREC,
                 VD.CHAR_SET_ID,
                 VD.VAL_DOM_HIGH_VAL_NUM,
                 VD.VAL_DOM_LOW_VAL_NUM,
                 NVL (VDAI.ORIGIN, VDAI.ORIGIN_ID_DN),
                 ONEDATA_WA.ADMIN_COMPONENT_WITH_CON_T (
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
                                 FROM ONEDATA_WA.CNCPT_ADMIN_ITEM COM,
                                      ONEDATA_WA.ADMIN_ITEM    CON,
                                     ONEDATA_WA.VW_CNCPT_19   CNCPT
                                WHERE     REP.ITEM_ID = COM.ITEM_ID(+)
                                      AND REP.VER_NR = COM.VER_NR(+)
                                      AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                      AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                      AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                      AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                             ORDER BY NCI_ORD DESC, CNCPT.EVS_SRC, CON.ITEM_ID)
                             AS ONEDATA_WA.CONCEPTS_LIST_T)),
             CAST (
                     MULTISET (
                           SELECT PV.PERM_VAL_NM,
                                  PV.PERM_VAL_DESC_TXT,
                                  VM.ITEM_DESC,
                                  ONEDATA_WA.GET_CONCEPTS2 (VM.ITEM_ID, VM.VER_NR)
                                      MEANINGCONCEPTS,
                                  /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                        vm.condr_idseq)
                                        MeaningConceptOrigin,  */
                                  ONEDATA_WA.GET_CONCEPT_ORIGIN (VM.ITEM_ID, VM.VER_NR)
                                      MEANINGCONCEPTORIGIN,
                                  ONEDATA_WA.NCI_11179.GET_CONCEPT_ORDER (VM.ITEM_ID,
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
                                              ) DES, ONEDATA_WA.OBJ_KEY OK
                                             WHERE     VM.ITEM_ID = DES.ITEM_ID(+)
                                                   AND VM.VER_NR = DES.VER_NR(+)
                                                   AND DES.NM_TYP_ID =
                                                       OK.OBJ_KEY_ID(+)
                                    ORDER BY DES.CNTXT_NM_DN, DES.NM_DESC
                                          )
                                          AS ONEDATA_WA.MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM ONEDATA_WA.PERM_VAL PV, ONEDATA_WA.ADMIN_ITEM VM
                            WHERE     PV.VAL_DOM_ITEM_ID = VD.ITEM_ID
                                  AND PV.VAL_DOM_VER_NR = VD.VER_NR
                                  AND PV.NCI_VAL_MEAN_ITEM_ID = VM.ITEM_ID
                                  AND PV.NCI_VAL_MEAN_VER_NR = VM.VER_NR
                                  AND VM.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY PV.PERM_VAL_NM,VM.ITEM_ID
                         )
                         AS ONEDATA_WA.MDSR_749_PV_VD_LIST_T)
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
                             FROM ONEDATA_WA.CNCPT_ADMIN_ITEM COM,
                                  ONEDATA_WA.ADMIN_ITEM    CON,
                                  ONEDATA_WA.VW_CNCPT_19   CNCPT
                            WHERE     VD.ITEM_ID = COM.ITEM_ID(+)
                                  AND VD.VER_NR = COM.VER_NR(+)
                                  AND COM.CNCPT_ITEM_ID = CON.ITEM_ID(+)
                                  AND COM.CNCPT_VER_NR = CON.VER_NR(+)
                                  AND CON.ADMIN_ITEM_TYP_ID(+) = 49
                                  AND COM.CNCPT_ITEM_ID = CNCPT.ITEM_ID(+)
                                  AND COM.CNCPT_VER_NR = CNCPT.VER_NR(+)
                         ORDER BY NCI_ORD DESC, CON.ITEM_ID, CNCPT.EVS_SRC)
                         AS ONEDATA_WA.CONCEPTS_LIST_T))               "ValueDomain" ,
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
                         FROM ONEDATA_WA.REF RD, ONEDATA_WA.OBJ_KEY OK, ONEDATA_WA.NCI_ORG ORG
                        WHERE     RD.REF_TYP_ID = OK.OBJ_KEY_ID(+)
                              AND RD.ORG_ID = ORG.ENTTY_ID(+)
                              --, sbr.organizations org
                              AND DE.ITEM_ID = RD.ITEM_ID
                              AND DE.VER_NR = RD.VER_NR
                     ORDER BY RD.DISP_ORD)
                     AS ONEDATA_WA.CDEBROWSER_RD_LIST_T)               "ReferenceDocumentsList"
             ,CAST (
                 MULTISET (
                       SELECT ONEDATA_WA.ADMIN_COMPONENT_WITH_ID_T (CSV.CS_ITEM_ID,
                                                         CSV.CS_CNTXT_NM,
                                                         CSV.CS_CNTXT_VER_NR,
                                                         CSV.CS_ITEM_LONG_NM,
                                                         CSV.CS_VER_NR),
                              CSV.CSI_ITEM_NM,
                              CSV.CSITL_NM,
                              CSV.CSI_ITEM_ID,
                              CSV.CSI_VER_NR
                         FROM ONEDATA_WA.CDEBROWSER_CS_VIEW_N CSV
                        WHERE     DE.ITEM_ID = CSV.DE_ITEM_ID
                              AND DE.VER_NR = CSV.DE_VER_NR
							  --AND CSV.CS_CNTXT_NM<>'TEST'
                     ORDER BY CSV.CS_ITEM_ID,
                              CSV.CS_VER_NR,
                              CSV.CSI_ITEM_ID,
                              CSV.CSI_VER_NR)
                     AS ONEDATA_WA.CDEBROWSER_CSI_LIST_T)              "ClassificationsList"
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
                         FROM (select*from onedata_wa.ALT_NMS where NVL(FLD_DELETE,0)=0 ) DES, ONEDATA_WA.OBJ_KEY OK
                        WHERE     DE.ITEM_ID = DES.ITEM_ID
                              AND DE.VER_NR = DES.VER_NR
                              AND DES.NM_TYP_ID = OK.OBJ_KEY_ID(+)
                     ORDER BY DES.CNTXT_NM_DN, DES.NM_DESC)
                     AS ONEDATA_WA.CDEBROWSER_ALTNAME_LIST_T)          "AlternateNameList",
         ONEDATA_WA.DERIVED_DATA_ELEMENT_T (CCD.CRTL_NAME,
                                     CCD.DESCRIPTION,
                                     CCD.METHODS,
                                     CCD.RULE,
                                     CCD.CONCAT_CHAR,
                                     "DataElementsList")    "DataElementDerivation"
                FROM ONEDATA_WA.ADMIN_ITEM       AI,
                ONEDATA_WA.DE       DE,
                ONEDATA_WA.VALUE_DOM                   VD,
                ONEDATA_WA.ADMIN_ITEM                  VDAI,
                ONEDATA_WA.ADMIN_ITEM                  CD,
                ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW      DEC,
                (select* from ONEDATA_WA.ADMIN_ITEM  where ADMIN_ITEM_TYP_ID = 7 )            REP,
                ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N CCD,
                ONEDATA_WA.DATA_TYP,
                ONEDATA_WA.FMT,
                ONEDATA_WA.UOM
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
                AND VD.REP_CLS_ITEM_ID = REP.ITEM_ID(+)
                AND VD.REP_CLS_VER_NR = REP.VER_NR(+) 
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
    


GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW TO ONEDATA_RA;

GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW TO ONEDATA_RO;
