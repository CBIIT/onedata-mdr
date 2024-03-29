DROP VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW
(DE_ITEM_ID, DE_VER_NR, CS_ITEM_ID, CS_ITEM_NM, CS_ITEM_LONG_NM, 
 CS_PREF_DEF, CS_VER_NR, CS_ADMIN_STUS, CS_CNTXT_NM, CS_CNTXT_VER_NR, 
 CSI_LONG_NM, CSI_PREF_DEF, CSI_ITEM_ID, CSI_VER_NR, CSI_ITEM_NM)
BEQUEATH DEFINER
AS 
SELECT ac_csi.c_item_id         de_item_id,
           ac_csi.c_item_ver_nr     de_ver_nr,
           cs.item_id               cs_item_id,
           cs.item_nm               cs_item_nm,
           cs.item_long_nm          cs_item_long_nm,
           cs.item_desc             cs_pref_def,
           cs.ver_nr                cs_ver_nr,
           cs.admin_stus_nm_dn      cs_admin_stus,
           cs.cntxt_nm_dn           cs_cntxt_nm,
           cs.cntxt_ver_nr          cs_cntxt_ver_nr,
           csi.item_long_nm         csi_long_nm--,csi.csitl_name
                                               ,
           csi.item_desc            csi_pref_def,
           csi.item_id              csi_item_id,
           csi.ver_nr               csi_ver_nr,
           csi.item_nm              csi_item_nm
      FROM admin_item                  cs,
           NCI_ADMIN_ITEM_REL_ALT_KEY  cs_csi,
           ADMIN_ITEM                  csi,
           NCI_ALT_KEY_ADMIN_ITEM_REL  ac_csi
     WHERE     cs.item_id = cs_csi.CNTXT_CS_ITEM_ID
           AND cs.ver_nr = cs_csi.CNTXT_CS_VER_NR
           AND csi.item_id = cs_csi.c_item_id
           AND csi.ver_nr = cs_csi.c_item_ver_nr
           AND cs_csi.nci_pub_id = ac_csi.nci_pub_id
           AND cs_csi.nci_ver_nr = ac_csi.nci_ver_nr;


DROP VIEW ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW_OLD;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW_OLD
(DE_ID, DE_VERSION, DEC_PREFERRED_NAME, DEC_LONG_NAME, PREFERRED_DEFINITION, 
 DEC_VERSION, ASL_NAME, DEC_CONTEXT_NAME, DEC_CONTEXT_VERSION, OC_PREFERRED_NAME, 
 OC_VERSION, OC_LONG_NAME, OC_CONTEXT_NAME, OC_CONTEXT_VERSION, PT_PREFERRED_NAME, 
 PT_VERSION, PT_LONG_NAME, PT_CONTEXT_NAME, PT_CONTEXT_VERSION, CD_PREFERRED_NAME, 
 CD_VERSION, CD_LONG_NAME, CD_CONTEXT_NAME, CD_CONTEXT_VERSION, OBJ_CLASS_QUALIFIER, 
 PROPERTY_QUALIFIER, OC_ID, PROP_ID, CD_ID, DEC_ID, 
 DEC_ORIGIN, OC_IDSEQ, PROP_IDSEQ, OC_CONDR_IDSEQ, PROP_CONDR_IDSEQ)
BEQUEATH DEFINER
AS 
SELECT de.item_id                             de_id,
           de.ver_nr                              de_version,
           dec.ITEM_NM                            dec_preferred_name,
           dec.ITEM_LONG_NM                       dec_long_name,
           dec.ITEM_DESC                          PREFERRED_DEFINITION,
           dec.ver_nr                             dec_version,
           dec.admin_stus_nm_dn                   ASL_NAME,
           dec.CNTXT_NM_DN                        dec_context_name,
           dec.CNTXT_ver_NR                       dec_context_version,
           oc.ITEM_NM                             oc_preferred_name,
           oc.VER_NR                              oc_version,
           oc.ITEM_LONG_NM                        oc_long_name,
           oc.CNTXT_NM_DN                         oc_context_name,
           oc.ver_NR                              oc_context_version,
           pt.ITEM_NM                             pt_preferred_name,
           pt.ver_NR                              pt_version,
           pt.item_long_nm                        pt_long_name,
           pt.CNTXT_NM_DN                         pt_context_name,
           pt.cntxt_VER_NR                        pt_context_version,
           cd.ITEM_NM                             cd_preferred_name,
           cd.ver_NR                              cd_version,
           cd.ITEM_LONG_NM                        cd_long_name,
           cd.CNTXT_NM_DN                         cd_context_name,
           cd.cntxt_ver_NR                        cd_context_version,
           de_conc.obj_cls_qual                   obj_class_qualifier,
           de_conc.prop_qual                      property_qualifier,
           oc.item_id                             oc_id,
           pt.item_id                             prop_id,
           cd.item_id                             cd_id,
           dec.item_id                            dec_id,
           NVL (dec.origin, dec.ORIGIN_ID_DN)     dec_origin,
           oc.nci_idseq                           oc_idseq,
           pt.nci_idseq                           prop_idseq,
           oc.nci_idseq                           oc_condr_idseq,
           pt.nci_idseq                           prop_condr_idseq
      FROM DE          de,
           ADMIN_ITEM  dec,
           DE_CONC     de_conc,
           ADMIN_ITEM  oc,
           ADMIN_ITEM  pt,
           ADMIN_ITEM  cd
     WHERE     de.de_conc_item_id = dec.item_id
           AND dec.item_id = de_conc.item_id
           AND dec.ver_nr = de_conc.ver_nr
           AND de_conc.obj_cls_item_id = oc.item_id
           AND de_conc.prop_item_id = pt.item_id
           AND de_conc.conc_dom_item_id = cd.item_id
           AND de.de_conc_ver_nr = dec.ver_nr
           AND de_conc.obj_cls_ver_nr = oc.ver_nr
           AND de_conc.prop_ver_nr = pt.ver_nr
           AND de_conc.conc_dom_ver_nr = cd.ver_nr
           AND dec.admin_item_typ_id = 2
           AND oc.admin_item_typ_id = 5
           AND pt.admin_item_typ_id = 6
           AND cd.admin_item_typ_id = 1;


DROP VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_VW;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_VW
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
                                              FROM ALT_NMS DES, OBJ_KEY OK
                                             WHERE     VM.ITEM_ID = DES.ITEM_ID(+)
                                                   AND VM.VER_NR = DES.VER_NR(+)
                                                   AND DES.NM_TYP_ID =
                                                       OK.OBJ_KEY_ID(+)
                                          ORDER BY DES.CNTXT_NM_DN, DES.NM_DESC)
                                          AS MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM PERM_VAL PV, ADMIN_ITEM VM
                            WHERE     PV.VAL_DOM_ITEM_ID = VD.ITEM_ID
                                  AND PV.VAL_DOM_VER_NR = VD.VER_NR
                                  AND PV.NCI_VAL_MEAN_ITEM_ID = VM.ITEM_ID
                                  AND PV.NCI_VAL_MEAN_VER_NR = VM.VER_NR
                                  AND VM.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY VM.ITEM_ID, PV.PERM_VAL_NM)
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
                         FROM ALT_NMS DES, OBJ_KEY OK
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


DROP VIEW ONEDATA_WA.DE_EXCEL_GENERATOR_VW;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_EXCEL_GENERATOR_VW
(RAI, PUBLICID, LONGNAME, PREFERREDNAME, PREFERREDDEFINITION, 
 VERSION, WORKFLOWSTATUS, CONTEXTNAME, CONTEXTVERSION, ORIGIN, 
 REGISTRATIONSTATUS, "dateModified", DATAELEMENTCONCEPT, VALUEDOMAIN, REFERENCEDOCUMENTSLIST, 
 CLASSIFICATIONSLIST, ALTERNATENAMELIST, DATAELEMENTDERIVATION)
BEQUEATH DEFINER
AS 
SELECT                                                   ---de.de_idseq,
             '2.16.840.1.113883.3.26.2'                     "RAI",
             ai.ITEM_ID                                     "PublicId",
             ai.ITEM_NM                                     "LongName",
             ai.ITEM_LONG_NM                                "PreferredName",
             ai.ITEM_DESC                                   "PreferredDefinition",
             ai.VER_NR                                      "Version",
             ai.ADMIN_STUS_NM_DN                            "WorkflowStatus",
             ai.CNTXT_NM_DN                                 "ContextName",
             ai.CNTXT_VER_NR                                "ContextVersion",
             NVL (ai.origin, ai.ORIGIN_ID_DN)               "Origin",
             ai.REGSTR_STUS_NM_DN                           "RegistrationStatus",
             NVL (ai.LST_UPD_DT, ai.CREATION_DT)            "dateModified",
               cdebrowser_dec_t (
                 dec.dec_id,
                 dec.dec_long_name,
                 dec.PREFERRED_DEFINITION,
                 dec.dec_preferred_name,
                 dec.dec_version,
                 dec.ASL_NAME,
                 dec.dec_context_name,
                 dec.dec_context_version,
                 admin_component_with_id_ln_t (
                     dec.cd_id,
                     dec.cd_context_name,
                     dec.cd_context_version,
                     dec.cd_long_name,
                     dec.cd_version,
                     dec.cd_preferred_name),
              admin_component_with_con_t (
                     dec.oc_id,
                     dec.oc_context_name,
                     dec.oc_context_version,
                     dec.oc_long_name,
                     dec.oc_version,
                     dec.oc_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.oc_id = com.item_id(+)
                                      AND dec.oc_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC)
                             AS Concepts_list_t)),
           admin_component_with_con_t (
                     dec.prop_id,
                     dec.pt_context_name,
                     dec.pt_context_version,
                     dec.pt_long_name,
                     dec.pt_version,
                     dec.pt_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.prop_id = com.item_id(+)
                                      AND dec.pt_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src)
                             AS Concepts_list_t)),
               dec.obj_class_qualifier,
                dec.property_qualifier,
                 dec.dec_origin)                            "DataElementConcept",
             CDEBROWSER_VD_T749 (
                 vdai.item_id,
                 vdai.item_long_nm,
                 vdai.item_desc,
                 vdai.item_nm,
                 vdai.ver_nr,
                 vdai.admin_stus_nm_dn,
                 NVL (vdai.LST_UPD_DT, vdai.CREATION_DT),
                 vdai.cntxt_nm_dn,
                 vdai.cntxt_ver_nr,
                 admin_component_with_id_ln_T (
                     cd.item_id,
                     cd.cntxt_nm_dn,
                     cd.cntxt_ver_nr,
                     cd.item_long_nm,
                     cd.ver_nr,
                     cd.item_nm),                                        /* */
                 data_typ.DTTYPE_NM,
                 DECODE (vd.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non-enumerated'),
                    UOM.UOM_NM,
                 FMT.FMT_NM,
                -- null,
                 vd.VAL_DOM_MAX_CHAR,
                 vd.VAL_DOM_MIN_CHAR,
                 vd.NCI_DEC_PREC,
                 vd.CHAR_SET_ID,
                 vd.VAL_DOM_HIGH_VAL_NUM,
                 vd.VAL_DOM_LOW_VAL_NUM,
                 NVL (vdai.origin, vdai.ORIGIN_ID_DN),
                 admin_component_with_con_t (
                     rep.item_id,
                     rep.cntxt_nm_dn,
                     rep.CNTXT_VER_NR,
                     rep.ITEM_LONG_NM,
                     rep.VER_NR,
                     rep.ITEM_NM,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     rep.item_id = com.item_id(+)
                                      AND rep.ver_nr = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src, con.item_id)
                             AS Concepts_list_t)),
             CAST (
                     MULTISET (
                           SELECT pv.PERM_VAL_NM,
                                  pv.PERM_VAL_DESC_TXT,
                                  vm.item_desc,
                                  get_concepts2 (vm.item_id, vm.ver_nr)
                                      MeaningConcepts,
                                  /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                        vm.condr_idseq)
                                        MeaningConceptOrigin,  */
                                  get_concept_origin (vm.item_id, vm.ver_nr)
                                      MeaningConceptOrigin,
                                  nci_11179.get_concept_order (vm.item_id,
                                                               vm.ver_nr)
                                      MeaningConceptDisplayOrder,
                                  pv.PERM_VAL_BEG_DT,
                                  pv.PERM_VAL_END_DT,
                                  vm.item_id,
                                  vm.ver_nr,
                                  NVL (vm.LST_UPD_DT, vm.CREATION_DT),
                                  CAST (
                                      MULTISET (
                                            SELECT des.cntxt_nm_dn,
                                                   TO_CHAR (des.cntxt_ver_nr),
                                                   des.NM_DESC,
                                                   ok.obj_key_desc,
                                                   DECODE (des.lang_id,
                                                           1000, 'ENGLISH',
                                                           1004, 'SPANISH',
                                                           1007, 'ICELANDIC') -- decode
                                              FROM alt_nms des, obj_key ok
                                             WHERE     vm.item_id = des.item_id(+)
                                                   AND vm.ver_nr = des.ver_nr(+)
                                                   AND des.NM_TYP_ID =
                                                       ok.obj_key_id(+)
                                          ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                                          AS MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM PERM_VAL pv, ADMIN_ITEM vm
                            WHERE     pv.val_dom_item_id = vd.item_id
                                  AND pv.Val_dom_ver_nr = vd.ver_nr
                                  AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                                  AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                                  AND vm.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY vm.item_id, pv.PERM_VAL_NM)
                         AS MDSR_749_PV_VD_LIST_T)
                         ,
                 CAST (
                     MULTISET (
                           SELECT con.item_long_nm
                                      preferred_name,
                                  con.item_nm
                                      long_name,
                                  con.item_id
                                      con_id,
                                  con.def_src
                                      definition_source,
                                  NVL (con.origin, con.ORIGIN_ID_DN)
                                      origin,
                                  cncpt.evs_src
                                      evs_Source,
                                  DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                      primary_flag_ind,
                                  com.nci_ord
                                      display_order
                             FROM cncpt_admin_item com,
                                  Admin_item    con,
                                  VW_CNCPT_19   cncpt
                            WHERE     vd.item_id = com.item_id(+)
                                  AND vd.ver_nr = com.ver_nr(+)
                                  AND com.cncpt_item_id = con.item_id(+)
                                  AND com.cncpt_ver_nr = con.ver_nr(+)
                                  AND con.admin_item_typ_id(+) = 49
                                  AND com.cncpt_item_id = cncpt.item_id(+)
                                  AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                         ORDER BY nci_ord DESC, con.item_id, cncpt.evs_src)
                         AS Concepts_list_t))               "ValueDomain" ,
--     --select     
       CAST (
                 MULTISET (
                       SELECT rd.ref_nm,
                              org.org_nm,
                              --  ok.OBJ_KEY_DESC,
                              ok.obj_key_desc,
                              rd.ref_desc,
                              rd.URL,
                              DECODE (rd.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC'),
                              rd.disp_ord
                         FROM REF rd, obj_key ok, NCI_ORG org
                        WHERE     rd.REF_TYP_ID = ok.obj_key_id(+)
                              AND rd.ORG_ID = org.ENTTY_ID(+)
                              --, sbr.organizations org
                              AND de.item_id = rd.item_id
                              AND de.ver_nr = rd.ver_nr
                     ORDER BY rd.disp_ord)
                     AS cdebrowser_rd_list_t)               "ReferenceDocumentsList"
             ,CAST (
                 MULTISET (
                       SELECT admin_component_with_id_t (csv.cs_item_id,
                                                         csv.cs_cntxt_nm,
                                                         csv.cs_cntxt_ver_nr,
                                                         csv.cs_item_long_nm,
                                                         csv.cs_ver_nr),
                              csv.csi_item_nm,
                              csv.csitl_nm,
                              csv.csi_item_id,
                              csv.csi_ver_nr
                         FROM cdebrowser_cs_view_n csv
                        WHERE     de.item_id = csv.de_item_id
                              AND de.ver_nr = csv.de_ver_nr
                     ORDER BY csv.cs_item_id,
                              csv.cs_ver_nr,
                              csv.csi_item_id,
                              csv.csi_ver_nr)
                     AS cdebrowser_csi_list_t)              "ClassificationsList"
                     ,
       CAST (
                 MULTISET (
                       SELECT des.cntxt_nm_dn,
                              TO_CHAR (des.cntxt_ver_nr),
                              des.NM_DESC,
                              ok.obj_key_desc,
                              DECODE (des.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC')
                         FROM alt_nms des, obj_key ok
                        WHERE     de.item_id = des.item_id
                              AND de.ver_nr = des.ver_nr
                              AND des.nm_typ_id = ok.obj_key_id(+)
                     ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                     AS cdebrowser_altname_list_t)          "AlternateNameList",
         derived_data_element_t (ccd.CRTL_NAME,
                                     ccd.DESCRIPTION,
                                     ccd.METHODS,
                                     ccd.RULE,
                                     ccd.CONCAT_CHAR,
                                     "DataElementsList")    "DataElementDerivation"
FROM ADMIN_ITEM       AI,
DE       DE,
VALUE_DOM                   VD,
ADMIN_ITEM                  VDAI,
ADMIN_ITEM                  CD,
CDEBROWSER_DE_DEC_VIEW      DEC,
ADMIN_ITEM                  REP,
CDEBROWSER_COMPLEX_DE_VIEW_N ccd,
DATA_TYP,
FMT,
UOM
WHERE     AI.ADMIN_STUS_NM_DN NOT IN
('RETIRED WITHDRAWN', 'RETIRED DELETED')
AND ai.item_id = dec.de_id
AND ai.ver_nr = dec.de_version
AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
AND DE.VAL_DOM_VER_NR = VD.VER_NR
AND AI.ITEM_ID = DE.ITEM_ID(+)
AND AI.VER_NR = DE.VER_NR(+)
AND DE.VAL_DOM_ITEM_ID = VDAI.ITEM_ID
AND DE.VAL_DOM_VER_NR = VDAI.VER_NR
AND CD.ADMIN_ITEM_TYP_ID = 1
AND CD.ITEM_ID = VD.CONC_DOM_ITEM_ID
AND CD.VER_NR = VD.CONC_DOM_VER_NR
AND VDAI.ADMIN_ITEM_TYP_ID = 3
AND REP.ADMIN_ITEM_TYP_ID = 7
AND REP.ITEM_ID = VD.REP_CLS_ITEM_ID(+)
AND REP.VER_NR = VD.REP_CLS_VER_NR(+)
AND vd.dttype_id = DATA_TYP.DTTYPE_ID(+)
AND vd.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
AND vd.uom_id=UOM.UOM_ID(+);


DROP VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_TEST;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_TEST
("PreferredName", "Version", "ClassificationList")
BEQUEATH DEFINER
AS 
SELECT CS_CONTEXT_NAME,
           CS_CONTEXT_VERSION,
           CAST (
               MULTISET (
                     SELECT CS_ID,
                            PREFERRED_NAME,
                            LONG_NAME,
                            CS_VERSION,
                            cs_date_created,
                            CAST (
                                MULTISET (
                                      SELECT v1.CSI_LEVEL,
                                             v1.CSI_NAME,
                                             v1.CSITL_NAME,
                                             v1.CSI_ID,
                                             v1.CSI_VERSION,
                                             v1.csi_date_created,
                                             V1.CSI_IDSEQ,
                                             NULL,
                                             NULL,
                                             '',
                                             v1.LEAF,
                                             CAST (
                                                 MULTISET (
                                                       SELECT v2.CSI_LEVEL,
                                                              v2.CSI_NAME,
                                                              v2.CSITL_NAME,
                                                              v2.CSI_ID,
                                                              v2.CSI_VERSION,
                                                              v2.csi_date_created,
                                                              V2.CSI_IDSEQ,
                                                              V1.CS_CSI_IDSEQ,
                                                              v2.P_ITEM_ID,
                                                              v2.P_ITEM_VER_NR,
                                                              v2.LEAF,
                                                              CAST (
                                                                  MULTISET (
                                                                        SELECT v3.CSI_LEVEL,
                                                                               v3.CSI_NAME,
                                                                               v3.CSITL_NAME,
                                                                               v3.CSI_ID,
                                                                               v3.CSI_VERSION,
                                                                               v3.csi_date_created,
                                                                               V3.CSI_IDSEQ,
                                                                               V2.CS_CSI_IDSEQ,
                                                                               v3.P_ITEM_ID,
                                                                               v3.P_ITEM_VER_NR,
                                                                               v3.LEAF,
                                                                               CAST (
                                                                                   MULTISET (
                                                                                         SELECT v4.CSI_LEVEL,
                                                                                                v4.CSI_NAME,
                                                                                                v4.CSITL_NAME,
                                                                                                v4.CSI_ID,
                                                                                                v4.CSI_VERSION,
                                                                                                v4.csi_date_created,
                                                                                                V4.CSI_IDSEQ,
                                                                                                V3.CS_CSI_IDSEQ,
                                                                                                v4.P_ITEM_ID,
                                                                                                v4.P_ITEM_VER_NR,
                                                                                                v4.LEAF,
                                                                                                CAST (
                                                                                                    MULTISET (
                                                                                                          SELECT v5.CSI_LEVEL,
                                                                                                                 v5.CSI_NAME,
                                                                                                                 v5.CSITL_NAME,
                                                                                                                 v5.CSI_ID,
                                                                                                                 v5.CSI_VERSION,
                                                                                                                 v5.csi_date_created,
                                                                                                                 V5.CSI_IDSEQ,
                                                                                                                 V4.CS_CSI_IDSEQ,
                                                                                                                 v5.P_ITEM_ID,
                                                                                                                 v5.P_ITEM_VER_NR,
                                                                                                                 v5.LEAF
                                                                                                            FROM REL_CLASS_SCHEME_ITEM_VW
                                                                                                                 v5
                                                                                                           --   ,(select* from  REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                                           WHERE     v5.P_ITEM_VER_NR =
                                                                                                                     v4.CSI_VERSION
                                                                                                                 AND v5.P_ITEM_ID =
                                                                                                                     v4.CSI_ID
                                                                                                                 AND v5.CSI_LEVEL =
                                                                                                                     5
                                                                                                                 AND V5.CS_IDSEQ =
                                                                                                                     CL.CS_IDSEQ
                                                                                                        ORDER BY v5.CSI_ID)
                                                                                                        AS MDSR759_XML_CSI_LIST5_T)
                                                                                                    "level5"
                                                                                           FROM REL_CLASS_SCHEME_ITEM_VW
                                                                                                V4
                                                                                          --   ,(select* from  REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                          WHERE     v4.P_ITEM_VER_NR =
                                                                                                    v3.CSI_VERSION
                                                                                                AND v4.P_ITEM_ID =
                                                                                                    v3.CSI_ID
                                                                                                AND v4.CSI_LEVEL =
                                                                                                    4
                                                                                                AND V4.CS_IDSEQ =
                                                                                                    CL.CS_IDSEQ
                                                                                       ORDER BY v4.CSI_ID)
                                                                                       AS MDSR759_XML_CSI_LIST4_T)
                                                                                   "level4"
                                                                          FROM REL_CLASS_SCHEME_ITEM_VW
                                                                               V3
                                                                         WHERE     v3.P_ITEM_VER_NR =
                                                                                   v2.CSI_VERSION
                                                                               AND v3.P_ITEM_ID =
                                                                                   v2.CSI_ID
                                                                               AND v3.CSI_LEVEL =
                                                                                   3
                                                                               AND V3.CS_IDSEQ =
                                                                                   V2.CS_IDSEQ
                                                                      ORDER BY v3.CSI_ID)
                                                                      AS MDSR759_XML_CSI_LIST3_T)
                                                                  "level3"
                                                         FROM REL_CLASS_SCHEME_ITEM_VW
                                                              V2
                                                        WHERE     v2.P_ITEM_VER_NR =
                                                                  v1.CSI_VERSION
                                                              AND v2.P_ITEM_ID =
                                                                  v1.CSI_ID
                                                              AND v2.CSI_LEVEL =
                                                                  2
                                                              AND V2.CS_IDSEQ =
                                                                  V1.CS_IDSEQ
                                                     ORDER BY v2.CSI_ID)
                                                     AS MDSR759_XML_CSI_LIST2_T)    "level2"
                                        FROM REL_CLASS_SCHEME_ITEM_VW V1
                                       WHERE     v1.CS_IDSEQ =
                                                 cl.CS_IDSEQ
                                             AND CSI_LEVEL = 1
                                    ORDER BY v1.CSI_ID)
                                    AS MDSR759_XML_CSI_LIST1_T)    "ClassificationItemList"
                       FROM (SELECT DISTINCT CS_IDSEQ,
                                             CS_ID,
                                             CS_VERSION,
                                             PREFERRED_NAME,
                                             LONG_NAME,
                                             PREFERRED_DEFINITION,
                                             CS_DATE_CREATED,
                                             ASL_NAME,
                                             CS_CONTEXT_NAME,
                                             CS_CONTEXT_VERSION,
                                             CS_CONTEXT_ID
                               FROM REL_CLASS_SCHEME_ITEM_VW
                               where cs_id=2192345 and csi_id in (10000289,10000344,10000706) ) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                            
                   ORDER BY CS_ID)
                   AS MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM REL_CLASS_SCHEME_ITEM_VW
            ORDER BY CS_CONTEXT_NAME) con;


DROP VIEW ONEDATA_WA.VW_CLASS_SCHEME_ITEM_MDSR;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CLASS_SCHEME_ITEM_MDSR
(NCI_PUB_ID, NCI_VER_NR, ITEM_ID, VER_NR, ITEM_NM, 
 ITEM_LONG_NM, ITEM_DESC, CNTXT_NM_DN, CURRNT_VER_IND, REGSTR_STUS_NM_DN, 
 ADMIN_STUS_NM_DN, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, 
 LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT, CS_IDSEQ, CS_LONG_NM, 
 CS_ITEM_DESC, CS_VER_NR, ASL_NAME, CS_CONTEXT_NAME, CS_CONTEXT_VERSION, 
 CSITL_NM, CS_ITEM_ID, CS_DATE_CREATED, CSI_DATE_CREATED, P_ITEM_ID, 
 P_ITEM_VER_NR, PCSI_ITEM_ID, PCSI_VER_NR)
BEQUEATH DEFINER
AS 
SELECT NODE.NCI_PUB_ID,
             NODE.NCI_VER_NR,
             CSI.ITEM_ID             ITEM_ID,
             CSI.VER_NR              VER_NR,
             CSI.ITEM_NM,
             CSI.ITEM_LONG_NM,
             CSI.ITEM_DESC,
             CSI.CNTXT_NM_DN,
             CSI.CURRNT_VER_IND,
             CSI.REGSTR_STUS_NM_DN,
             CSI.ADMIN_STUS_NM_DN,
             NODE.CREAT_DT,
             NODE.CREAT_USR_ID,
             NODE.LST_UPD_USR_ID,
             NODE.FLD_DELETE,
             NODE.LST_DEL_DT,
             NODE.S2P_TRN_DT,
             NODE.LST_UPD_DT,
             cs.NCI_IDSEQ            cs_idseq,
             cs.ITEM_NM              CS_LONG_NM,
             cs.ITEM_DESC            CS_ITEM_DESC,
             cs.VER_NR               CS_VER_NR,
             cs.ADMIN_STUS_NM_DN     asl_name,
             cs.CNTXT_NM_DN          cs_context_name,
             cs.CNTXT_VER_NR         cs_context_version,
             o.NCI_CD                csitl_nm,
             cs.ITEM_ID              cs_item_id,
             cs.CREAT_DT             cs_date_created,
             csi.CREAT_DT            csi_date_created,
             NODE.P_ITEM_ID,
             NODE.p_item_ver_nr,
             pcsi.C_item_id          pcsi_item_id,
             pcsi.C_item_ver_nr      pcsi_ver_nr
        FROM admin_item                cs,
             NCI_ADMIN_ITEM_REL_ALT_KEY NODE,
             ADMIN_ITEM                csi,
             NCI_CLSFCTN_SCHM_ITEM     ncsi,
             OBJ_KEY                   o,
             (SELECT c_item_ver_nr,
                     c_item_id,
                     cntxt_cs_item_id,
                     cntxt_cs_Ver_nr
                FROM NCI_ADMIN_ITEM_REL_ALT_KEY p
               WHERE rel_typ_id = 64) pcsi
       WHERE     csi.ADMIN_ITEM_TYP_ID = 51
             AND node.c_item_id = csi.item_id
             AND node.c_item_ver_nr = csi.ver_nr
             AND node.cntxt_cs_item_id = cs.item_id
             AND node.cntxt_cs_Ver_nr = cs.ver_nr
             AND node.rel_typ_id = 64
             AND node.p_item_id = pcsi.C_item_id(+)
             AND node.p_item_ver_nr = pcsi.C_item_ver_nr(+)
             --  and node.NCI_PUB_ID <> pcsi.P_NCI_PUB_ID(+)
             --  and node.NCI_VER_NR <>pcsi.P_NCI_VER_NR(+)
             AND node.cntxt_cs_item_id = pcsi.cntxt_cs_item_id(+)
             AND node.cntxt_cs_Ver_nr = pcsi.cntxt_cs_Ver_nr(+)
             AND cs.admin_item_typ_id = 9
             --  and cs.CNTXT_NM_DN='CTEP'
             AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
             AND csi.CNTXT_NM_DN NOT IN ('TEST', 'Training')
             AND cs.CNTXT_NM_DN NOT IN ('TEST', 'Training')
             AND csi.item_id = ncsi.item_id
             AND csi.ver_nr = ncsi.ver_nr
             AND ncsi.CSI_TYP_ID = o.obj_key_id
             AND INSTR (o.NCI_CD, 'testCaseMix') = 0
            -- AND csi.item_id = 3070841
    --  and CS.item_id=4272096 and
    --csi.item_id=4272129
    ORDER BY cs.ITEM_ID, csi.item_id, pcsi.C_item_id;


DROP VIEW ONEDATA_WA.XML_TEST_19;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.XML_TEST_19
("PublicId", "LongName", "PreferredName", "PreferredDefinition", "Version", 
 "WorkflowStatus", "ContextName", "ContextVersion", "Origin", "RegistrationStatus", 
 "dateModified", "DataElementConcept", "ValueDomain", "ReferenceDocumentsList", "ClassificationsList", 
 "AlternateNameList", "DataElementDerivation")
BEQUEATH DEFINER
AS 
select      ai.ITEM_ID                                     "PublicId",
             ai.ITEM_NM                                     "LongName",
             ai.ITEM_LONG_NM                                "PreferredName",
             ai.ITEM_DESC                                   "PreferredDefinition",
             ai.VER_NR                                      "Version",
             ai.ADMIN_STUS_NM_DN                            "WorkflowStatus",
             ai.CNTXT_NM_DN                                 "ContextName",
             ai.CNTXT_VER_NR                                "ContextVersion",
             NVL (ai.origin, ai.ORIGIN_ID_DN)               "Origin",
             ai.REGSTR_STUS_NM_DN                           "RegistrationStatus",
             NVL (ai.LST_UPD_DT, ai.CREATION_DT)            "dateModified",
               cdebrowser_dec_t (
                 dec.dec_id,
                 dec.dec_long_name,
                 dec.PREFERRED_DEFINITION,
                 dec.dec_preferred_name,
                 dec.dec_version,
                 dec.ASL_NAME,
                 dec.dec_context_name,
                 dec.dec_context_version,
                 admin_component_with_id_ln_t (
                     dec.cd_id,
                     dec.cd_context_name,
                     dec.cd_context_version,
                     dec.cd_long_name,
                     dec.cd_version,
                     dec.cd_preferred_name),
              admin_component_with_con_t (
                     dec.oc_id,
                     dec.oc_context_name,
                     dec.oc_context_version,
                     dec.oc_long_name,
                     dec.oc_version,
                     dec.oc_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.oc_id = com.item_id(+)
                                      AND dec.oc_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC)
                             AS Concepts_list_t)),
           admin_component_with_con_t (
                     dec.prop_id,
                     dec.pt_context_name,
                     dec.pt_context_version,
                     dec.pt_long_name,
                     dec.pt_version,
                     dec.pt_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.prop_id = com.item_id(+)
                                      AND dec.pt_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src)
                             AS Concepts_list_t)),
               dec.obj_class_qualifier,
                dec.property_qualifier,
                 dec.dec_origin)                            "DataElementConcept",
             CDEBROWSER_VD_T749 (
                 vdai.item_id,
                 vdai.item_long_nm,
                 vdai.item_desc,
                 vdai.item_nm,
                 vdai.ver_nr,
                 vdai.admin_stus_nm_dn,
                 NVL (vdai.LST_UPD_DT, vdai.CREATION_DT),
                 vdai.cntxt_nm_dn,
                 vdai.cntxt_ver_nr,
                 admin_component_with_id_ln_T (
                     cd.item_id,
                     cd.cntxt_nm_dn,
                     cd.cntxt_ver_nr,
                     cd.item_long_nm,
                     cd.ver_nr,
                     cd.item_nm),                                        /* */
                 data_typ.DTTYPE_NM,
                 DECODE (vd.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non-enumerated'),
                    UOM.UOM_NM,
                 FMT.FMT_NM,
                -- null,
                 vd.VAL_DOM_MAX_CHAR,
                 vd.VAL_DOM_MIN_CHAR,
                 vd.NCI_DEC_PREC,
                 vd.CHAR_SET_ID,
                 vd.VAL_DOM_HIGH_VAL_NUM,
                 vd.VAL_DOM_LOW_VAL_NUM,
                 NVL (vdai.origin, vdai.ORIGIN_ID_DN),
                 admin_component_with_con_t (
                     rep.item_id,
                     rep.cntxt_nm_dn,
                     rep.CNTXT_VER_NR,
                     rep.ITEM_LONG_NM,
                     rep.VER_NR,
                     rep.ITEM_NM,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     rep.item_id = com.item_id(+)
                                      AND rep.ver_nr = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src, con.item_id)
                             AS Concepts_list_t)),
             CAST (
                     MULTISET (
                           SELECT pv.PERM_VAL_NM,
                                  pv.PERM_VAL_DESC_TXT,
                                  vm.item_desc,
                                  get_concepts2 (vm.item_id, vm.ver_nr)
                                      MeaningConcepts,
                                  /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                        vm.condr_idseq)
                                        MeaningConceptOrigin,  */
                                  get_concept_origin (vm.item_id, vm.ver_nr)
                                      MeaningConceptOrigin,
                                  nci_11179.get_concept_order (vm.item_id,
                                                               vm.ver_nr)
                                      MeaningConceptDisplayOrder,
                                  pv.PERM_VAL_BEG_DT,
                                  pv.PERM_VAL_END_DT,
                                  vm.item_id,
                                  vm.ver_nr,
                                  NVL (vm.LST_UPD_DT, vm.CREATION_DT),
                                  CAST (
                                      MULTISET (
                                            SELECT des.cntxt_nm_dn,
                                                   TO_CHAR (des.cntxt_ver_nr),
                                                   des.NM_DESC,
                                                   ok.obj_key_desc,
                                                   DECODE (des.lang_id,
                                                           1000, 'ENGLISH',
                                                           1004, 'SPANISH',
                                                           1007, 'ICELANDIC') -- decode
                                              FROM alt_nms des, obj_key ok
                                             WHERE     vm.item_id = des.item_id(+)
                                                   AND vm.ver_nr = des.ver_nr(+)
                                                   AND des.NM_TYP_ID =
                                                       ok.obj_key_id(+)
                                          ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                                          AS MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM PERM_VAL pv, ADMIN_ITEM vm
                            WHERE     pv.val_dom_item_id = vd.item_id
                                  AND pv.Val_dom_ver_nr = vd.ver_nr
                                  AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                                  AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                                  AND vm.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY vm.item_id, pv.PERM_VAL_NM)
                         AS MDSR_749_PV_VD_LIST_T)
                         ,
                 CAST (
                     MULTISET (
                           SELECT con.item_long_nm
                                      preferred_name,
                                  con.item_nm
                                      long_name,
                                  con.item_id
                                      con_id,
                                  con.def_src
                                      definition_source,
                                  NVL (con.origin, con.ORIGIN_ID_DN)
                                      origin,
                                  cncpt.evs_src
                                      evs_Source,
                                  DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                      primary_flag_ind,
                                  com.nci_ord
                                      display_order
                             FROM cncpt_admin_item com,
                                  Admin_item    con,
                                  VW_CNCPT_19   cncpt
                            WHERE     vd.item_id = com.item_id(+)
                                  AND vd.ver_nr = com.ver_nr(+)
                                  AND com.cncpt_item_id = con.item_id(+)
                                  AND com.cncpt_ver_nr = con.ver_nr(+)
                                  AND con.admin_item_typ_id(+) = 49
                                  AND com.cncpt_item_id = cncpt.item_id(+)
                                  AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                         ORDER BY nci_ord DESC, con.item_id, cncpt.evs_src)
                         AS Concepts_list_t))               "ValueDomain" ,
--     --select     
       CAST (
                 MULTISET (
                       SELECT rd.ref_nm,
                              org.org_nm,
                              --  ok.OBJ_KEY_DESC,
                              ok.obj_key_desc,
                              rd.ref_desc,
                              rd.URL,
                              DECODE (rd.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC'),
                              rd.disp_ord
                         FROM REF rd, obj_key ok, NCI_ORG org
                        WHERE     rd.REF_TYP_ID = ok.obj_key_id(+)
                              AND rd.ORG_ID = org.ENTTY_ID(+)
                              --, sbr.organizations org
                              AND de.item_id = rd.item_id
                              AND de.ver_nr = rd.ver_nr
                     ORDER BY rd.disp_ord)
                     AS cdebrowser_rd_list_t)               "ReferenceDocumentsList"
             ,CAST (
                 MULTISET (
                       SELECT admin_component_with_id_t (csv.cs_item_id,
                                                         csv.cs_cntxt_nm,
                                                         csv.cs_cntxt_ver_nr,
                                                         csv.cs_item_long_nm,
                                                         csv.cs_ver_nr),
                              csv.csi_item_nm,
                              csv.csitl_nm,
                              csv.csi_item_id,
                              csv.csi_ver_nr
                         FROM cdebrowser_cs_view_n csv
                        WHERE     de.item_id = csv.de_item_id
                              AND de.ver_nr = csv.de_ver_nr
                     ORDER BY csv.cs_item_id,
                              csv.cs_ver_nr,
                              csv.csi_item_id,
                              csv.csi_ver_nr)
                     AS cdebrowser_csi_list_t)              "ClassificationsList"
                     ,
       CAST (
                 MULTISET (
                       SELECT des.cntxt_nm_dn,
                              TO_CHAR (des.cntxt_ver_nr),
                              des.NM_DESC,
                              ok.obj_key_desc,
                              DECODE (des.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC')
                         FROM alt_nms des, obj_key ok
                        WHERE     de.item_id = des.item_id
                              AND de.ver_nr = des.ver_nr
                              AND des.nm_typ_id = ok.obj_key_id(+)
                     ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                     AS cdebrowser_altname_list_t)          "AlternateNameList",
         derived_data_element_t (ccd.CRTL_NAME,
                                     ccd.DESCRIPTION,
                                     ccd.METHODS,
                                     ccd.RULE,
                                     ccd.CONCAT_CHAR,
                                     "DataElementsList")    "DataElementDerivation"
FROM ADMIN_ITEM       AI,
DE       DE,
VALUE_DOM                   VD,
ADMIN_ITEM                  VDAI,
ADMIN_ITEM                  CD,
CDEBROWSER_DE_DEC_VIEW      DEC,
ADMIN_ITEM                  REP,
CDEBROWSER_COMPLEX_DE_VIEW_N ccd,
DATA_TYP,
FMT,
UOM
WHERE     AI.ADMIN_STUS_NM_DN NOT IN
('RETIRED WITHDRAWN', 'RETIRED DELETED')
AND ai.item_id = dec.de_id
AND ai.ver_nr = dec.de_version
AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
AND DE.VAL_DOM_VER_NR = VD.VER_NR
AND AI.ITEM_ID = DE.ITEM_ID(+)
AND AI.VER_NR = DE.VER_NR(+)
AND DE.VAL_DOM_ITEM_ID = VDAI.ITEM_ID
AND DE.VAL_DOM_VER_NR = VDAI.VER_NR
AND CD.ADMIN_ITEM_TYP_ID = 1
AND CD.ITEM_ID = VD.CONC_DOM_ITEM_ID
AND CD.VER_NR = VD.CONC_DOM_VER_NR
AND VDAI.ADMIN_ITEM_TYP_ID = 3
AND REP.ADMIN_ITEM_TYP_ID = 7
AND REP.ITEM_ID = VD.REP_CLS_ITEM_ID(+)
AND REP.VER_NR = VD.REP_CLS_VER_NR(+)
AND vd.dttype_id = DATA_TYP.DTTYPE_ID(+)
AND vd.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
AND vd.uom_id=UOM.UOM_ID(+);


DROP VIEW ONEDATA_WA.XML_TEST_19_V2;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.XML_TEST_19_V2
(RAI, PUBLICID, LONGNAME, PREFERREDNAME, PREFERREDDEFINITION, 
 VERSION, WORKFLOWSTATUS, CONTEXTNAME, CONTEXTVERSION, ORIGIN, 
 REGISTRATIONSTATUS, "dateModified", DATAELEMENTCONCEPT, VALUEDOMAIN, REFERENCEDOCUMENTSLIST, 
 CLASSIFICATIONSLIST, ALTERNATENAMELIST, DATAELEMENTDERIVATION)
BEQUEATH DEFINER
AS 
SELECT                                                   ---de.de_idseq,
             '2.16.840.1.113883.3.26.2'                     "RAI",
             ai.ITEM_ID                                     "PublicId",
             ai.ITEM_NM                                     "LongName",
             ai.ITEM_LONG_NM                                "PreferredName",
             ai.ITEM_DESC                                   "PreferredDefinition",
             ai.VER_NR                                      "Version",
             ai.ADMIN_STUS_NM_DN                            "WorkflowStatus",
             ai.CNTXT_NM_DN                                 "ContextName",
             ai.CNTXT_VER_NR                                "ContextVersion",
             NVL (ai.origin, ai.ORIGIN_ID_DN)               "Origin",
             ai.REGSTR_STUS_NM_DN                           "RegistrationStatus",
             NVL (ai.LST_UPD_DT, ai.CREATION_DT)            "dateModified",
               cdebrowser_dec_t (
                 dec.dec_id,
                 dec.dec_long_name,
                 dec.PREFERRED_DEFINITION,
                 dec.dec_preferred_name,
                 dec.dec_version,
                 dec.ASL_NAME,
                 dec.dec_context_name,
                 dec.dec_context_version,
                 admin_component_with_id_ln_t (
                     dec.cd_id,
                     dec.cd_context_name,
                     dec.cd_context_version,
                     dec.cd_long_name,
                     dec.cd_version,
                     dec.cd_preferred_name),
              admin_component_with_con_t (
                     dec.oc_id,
                     dec.oc_context_name,
                     dec.oc_context_version,
                     dec.oc_long_name,
                     dec.oc_version,
                     dec.oc_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.oc_id = com.item_id(+)
                                      AND dec.oc_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC)
                             AS Concepts_list_t)),
           admin_component_with_con_t (
                     dec.prop_id,
                     dec.pt_context_name,
                     dec.pt_context_version,
                     dec.pt_long_name,
                     dec.pt_version,
                     dec.pt_preferred_name,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     dec.prop_id = com.item_id(+)
                                      AND dec.pt_version = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src)
                             AS Concepts_list_t)),
               dec.obj_class_qualifier,
                dec.property_qualifier,
                 dec.dec_origin)                            "DataElementConcept",
             CDEBROWSER_VD_T749 (
                 vdai.item_id,
                 vdai.item_long_nm,
                 vdai.item_desc,
                 vdai.item_nm,
                 vdai.ver_nr,
                 vdai.admin_stus_nm_dn,
                 NVL (vdai.LST_UPD_DT, vdai.CREATION_DT),
                 vdai.cntxt_nm_dn,
                 vdai.cntxt_ver_nr,
                 admin_component_with_id_ln_T (
                     cd.item_id,
                     cd.cntxt_nm_dn,
                     cd.cntxt_ver_nr,
                     cd.item_long_nm,
                     cd.ver_nr,
                     cd.item_nm),                                        /* */
                 data_typ.DTTYPE_NM,
                 DECODE (vd.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non-enumerated'),
                    UOM.UOM_NM,
                 FMT.FMT_NM,
                -- null,
                 vd.VAL_DOM_MAX_CHAR,
                 vd.VAL_DOM_MIN_CHAR,
                 vd.NCI_DEC_PREC,
                 vd.CHAR_SET_ID,
                 vd.VAL_DOM_HIGH_VAL_NUM,
                 vd.VAL_DOM_LOW_VAL_NUM,
                 NVL (vdai.origin, vdai.ORIGIN_ID_DN),
                 admin_component_with_con_t (
                     rep.item_id,
                     rep.cntxt_nm_dn,
                     rep.CNTXT_VER_NR,
                     rep.ITEM_LONG_NM,
                     rep.VER_NR,
                     rep.ITEM_NM,
                     CAST (
                         MULTISET (
                               SELECT con.item_long_nm
                                          preferred_name,
                                      con.item_nm
                                          long_name,
                                      con.item_id
                                          con_id,
                                      con.def_src
                                          definition_source,
                                      NVL (con.origin, con.ORIGIN_ID_DN)
                                          origin,
                                      cncpt.evs_src
                                          evs_Source,
                                      DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                          primary_flag_ind,
                                      com.nci_ord
                                          display_order
                                 FROM cncpt_admin_item com,
                                      Admin_item    con,
                                      VW_CNCPT_19   cncpt
                                WHERE     rep.item_id = com.item_id(+)
                                      AND rep.ver_nr = com.ver_nr(+)
                                      AND com.cncpt_item_id = con.item_id(+)
                                      AND com.cncpt_ver_nr = con.ver_nr(+)
                                      AND con.admin_item_typ_id(+) = 49
                                      AND com.cncpt_item_id = cncpt.item_id(+)
                                      AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                             ORDER BY nci_ord DESC, cncpt.evs_src, con.item_id)
                             AS Concepts_list_t)),
             CAST (
                     MULTISET (
                           SELECT pv.PERM_VAL_NM,
                                  pv.PERM_VAL_DESC_TXT,
                                  vm.item_desc,
                                  get_concepts2 (vm.item_id, vm.ver_nr)
                                      MeaningConcepts,
                                  /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                        vm.condr_idseq)
                                        MeaningConceptOrigin,  */
                                  get_concept_origin (vm.item_id, vm.ver_nr)
                                      MeaningConceptOrigin,
                                  nci_11179.get_concept_order (vm.item_id,
                                                               vm.ver_nr)
                                      MeaningConceptDisplayOrder,
                                  pv.PERM_VAL_BEG_DT,
                                  pv.PERM_VAL_END_DT,
                                  vm.item_id,
                                  vm.ver_nr,
                                  NVL (vm.LST_UPD_DT, vm.CREATION_DT),
                                  CAST (
                                      MULTISET (
                                            SELECT des.cntxt_nm_dn,
                                                   TO_CHAR (des.cntxt_ver_nr),
                                                   des.NM_DESC,
                                                   ok.obj_key_desc,
                                                   DECODE (des.lang_id,
                                                           1000, 'ENGLISH',
                                                           1004, 'SPANISH',
                                                           1007, 'ICELANDIC') -- decode
                                              FROM alt_nms des, obj_key ok
                                             WHERE     vm.item_id = des.item_id(+)
                                                   AND vm.ver_nr = des.ver_nr(+)
                                                   AND des.NM_TYP_ID =
                                                       ok.obj_key_id(+)
                                          ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                                          AS MDSR_749_ALTERNATENAM_LIST_T)
                                      "AlternateNameList"
                             FROM PERM_VAL pv, ADMIN_ITEM vm
                            WHERE     pv.val_dom_item_id = vd.item_id
                                  AND pv.Val_dom_ver_nr = vd.ver_nr
                                  AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                                  AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                                  AND vm.ADMIN_ITEM_TYP_ID = 53
                         ORDER BY vm.item_id, pv.PERM_VAL_NM)
                         AS MDSR_749_PV_VD_LIST_T)
                         ,
                 CAST (
                     MULTISET (
                           SELECT con.item_long_nm
                                      preferred_name,
                                  con.item_nm
                                      long_name,
                                  con.item_id
                                      con_id,
                                  con.def_src
                                      definition_source,
                                  NVL (con.origin, con.ORIGIN_ID_DN)
                                      origin,
                                  cncpt.evs_src
                                      evs_Source,
                                  DECODE (com.NCI_PRMRY_IND, 1, 'Yes', 'No')
                                      primary_flag_ind,
                                  com.nci_ord
                                      display_order
                             FROM cncpt_admin_item com,
                                  Admin_item    con,
                                  VW_CNCPT_19   cncpt
                            WHERE     vd.item_id = com.item_id(+)
                                  AND vd.ver_nr = com.ver_nr(+)
                                  AND com.cncpt_item_id = con.item_id(+)
                                  AND com.cncpt_ver_nr = con.ver_nr(+)
                                  AND con.admin_item_typ_id(+) = 49
                                  AND com.cncpt_item_id = cncpt.item_id(+)
                                  AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                         ORDER BY nci_ord DESC, con.item_id, cncpt.evs_src)
                         AS Concepts_list_t))               "ValueDomain" ,
--     --select     
       CAST (
                 MULTISET (
                       SELECT rd.ref_nm,
                              org.org_nm,
                              --  ok.OBJ_KEY_DESC,
                              ok.obj_key_desc,
                              rd.ref_desc,
                              rd.URL,
                              DECODE (rd.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC'),
                              rd.disp_ord
                         FROM REF rd, obj_key ok, NCI_ORG org
                        WHERE     rd.REF_TYP_ID = ok.obj_key_id(+)
                              AND rd.ORG_ID = org.ENTTY_ID(+)
                              --, sbr.organizations org
                              AND de.item_id = rd.item_id
                              AND de.ver_nr = rd.ver_nr
                     ORDER BY rd.disp_ord)
                     AS cdebrowser_rd_list_t)               "ReferenceDocumentsList"
             ,CAST (
                 MULTISET (
                       SELECT admin_component_with_id_t (csv.cs_item_id,
                                                         csv.cs_cntxt_nm,
                                                         csv.cs_cntxt_ver_nr,
                                                         csv.cs_item_long_nm,
                                                         csv.cs_ver_nr),
                              csv.csi_item_nm,
                              csv.csitl_nm,
                              csv.csi_item_id,
                              csv.csi_ver_nr
                         FROM cdebrowser_cs_view_n csv
                        WHERE     de.item_id = csv.de_item_id
                              AND de.ver_nr = csv.de_ver_nr
                     ORDER BY csv.cs_item_id,
                              csv.cs_ver_nr,
                              csv.csi_item_id,
                              csv.csi_ver_nr)
                     AS cdebrowser_csi_list_t)              "ClassificationsList"
                     ,
       CAST (
                 MULTISET (
                       SELECT des.cntxt_nm_dn,
                              TO_CHAR (des.cntxt_ver_nr),
                              des.NM_DESC,
                              ok.obj_key_desc,
                              DECODE (des.lang_id,
                                      1000, 'ENGLISH',
                                      1004, 'SPANISH',
                                      1007, 'ICELANDIC')
                         FROM alt_nms des, obj_key ok
                        WHERE     de.item_id = des.item_id
                              AND de.ver_nr = des.ver_nr
                              AND des.nm_typ_id = ok.obj_key_id(+)
                     ORDER BY des.cntxt_nm_dn, des.NM_DESC)
                     AS cdebrowser_altname_list_t)          "AlternateNameList",
         derived_data_element_t (ccd.CRTL_NAME,
                                     ccd.DESCRIPTION,
                                     ccd.METHODS,
                                     ccd.RULE,
                                     ccd.CONCAT_CHAR,
                                     "DataElementsList")    "DataElementDerivation"
FROM ADMIN_ITEM       AI,
DE       DE,
VALUE_DOM                   VD,
ADMIN_ITEM                  VDAI,
ADMIN_ITEM                  CD,
CDEBROWSER_DE_DEC_VIEW      DEC,
ADMIN_ITEM                  REP,
CDEBROWSER_COMPLEX_DE_VIEW_N ccd,
DATA_TYP,
FMT,
UOM
WHERE     AI.ADMIN_STUS_NM_DN NOT IN
('RETIRED WITHDRAWN', 'RETIRED DELETED')
AND ai.item_id = dec.de_id
AND ai.ver_nr = dec.de_version
AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
AND DE.VAL_DOM_VER_NR = VD.VER_NR
AND AI.ITEM_ID = DE.ITEM_ID(+)
AND AI.VER_NR = DE.VER_NR(+)
AND DE.VAL_DOM_ITEM_ID = VDAI.ITEM_ID
AND DE.VAL_DOM_VER_NR = VDAI.VER_NR
AND CD.ADMIN_ITEM_TYP_ID = 1
AND CD.ITEM_ID = VD.CONC_DOM_ITEM_ID
AND CD.VER_NR = VD.CONC_DOM_VER_NR
AND VDAI.ADMIN_ITEM_TYP_ID = 3
AND REP.ADMIN_ITEM_TYP_ID = 7
AND REP.ITEM_ID = VD.REP_CLS_ITEM_ID(+)
AND REP.VER_NR = VD.REP_CLS_VER_NR(+)
AND vd.dttype_id = DATA_TYP.DTTYPE_ID(+)
AND vd.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
AND vd.uom_id=UOM.UOM_ID(+);

DROP VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA_BF0607;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA_BF0607
(PROTOCOL, FORM_LONG_NAME, FORM_ID, FORM_VERSION, MODULE_DISPLAY_ORDER, 
 MODULE_LONG_NAME, QUEST_VERSION, QUEST_ID, QUEST_DISP_ORD, QUEST_LONG_NAME, 
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
                    NULL           Module,
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
           module.DISP_ORD
               Module,
           MOD.ITEM_NM MODULE_LONG_NAME,
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
    ORDER BY 3, 5, 7;

GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_VW TO ONEDATA_RA;

GRANT SELECT ON ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW_OLD TO ONEDATA_RO;
