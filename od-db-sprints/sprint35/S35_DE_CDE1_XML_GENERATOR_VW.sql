CREATE OR REPLACE TYPE CDEBROWSER_VD_T749 FORCE      AS OBJECT
( "PublicId"         NUMBER,
  "PreferredName"          VARCHAR2 (30),
  "PreferredDefinition"    VARCHAR2 (4000),
  "LongName"      VARCHAR2(255),
  "Version"                NUMBER (4,2),
  "WorkflowStatus"         VARCHAR2 (20),
  "dateModified"    DATE,
  "ContextName"         VARCHAR2 (30),
  "ContextVersion"     NUMBER (4,2),
  "ConceptualDomain"    ADMIN_COMPONENT_WITH_ID_LN_T,
  "Datatype"                VARCHAR2 (20),
  "ValueDomainType"         VARCHAR2 (50),
  "UnitOfMeasure"          VARCHAR2 (100),
  "DisplayFormat"          VARCHAR2 (30),
  "MaximumLength"          NUMBER (8),
  "MinimumLength"          NUMBER (8),
  "DecimalPlace"           NUMBER (2),
  "CharacterSetName"       VARCHAR2 (20),
  "MaximumValue"           VARCHAR2 (255),
  "MinimumValue"           VARCHAR2 (255),
  "Origin"    VARCHAR2(500),
 "Representation"    ADMIN_COMPONENT_WITH_CON_T,
  "PermissibleValues"     MDSR_749_PV_VD_LIST_T,
 "ValueDomainConcepts"    CONCEPTS_LIST_T
)
/
CREATE OR REPLACE TYPE ONEDATA_WA.CDEBROWSER_DEC_T      FORCE     AS OBJECT
 ("PublicId"      NUMBER,
  "PreferredName"          VARCHAR2 (30),
  "PreferredDefinition"    VARCHAR2 (4000),
  "LongName"     VARCHAR2(255),
  "Version"                NUMBER (4,2),
  "WorkflowStatus"         VARCHAR2 (20),
  "ContextName"            VARCHAR2 (30),
  "ContextVersion"    NUMBER (4,2),
  "ConceptualDomain"    ADMIN_COMPONENT_WITH_ID_LN_T,
  "ObjectClass"            ADMIN_COMPONENT_WITH_CON_T,
  "Property"            ADMIN_COMPONENT_WITH_CON_T,
  "ObjectClassQualifier"   VARCHAR2 (30),
  "PropertyQualifier"    VARCHAR2 (30),
  "Origin"     VARCHAR2(240)
  )
/
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

GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_VW TO ONEDATA_RA;

GRANT SELECT ON ONEDATA_WA.DE_CDE1_XML_GENERATOR_VW TO ONEDATA_RO;

CREATE OR REPLACE FUNCTION GET_CONCEPTS2(V_ITEM_ID IN NUMBER, V_VER_NR IN NUMBER) RETURN VARCHAR2 IS
CURSOR CON IS
SELECT C.ITEM_LONG_NM, CAI.NCI_CNCPT_VAL
FROM CNCPT_ADMIN_ITEM CAI, ADMIN_ITEM C
WHERE CAI.ITEM_ID = V_ITEM_ID AND CAI.VER_NR = V_VER_NR
AND CAI.CNCPT_ITEM_ID = C.ITEM_ID AND CAI.CNCPT_VER_NR = C.VER_NR AND C.ADMIN_ITEM_TYP_ID = 49
ORDER BY  NCI_ORD DESC;

V_NAME VARCHAR2(1000);

BEGIN
    FOR C_REC IN CON LOOP
        IF V_NAME IS NULL THEN
            V_NAME := C_REC.ITEM_LONG_NM;

            /* Check if Integer Concept */
            IF C_REC.ITEM_LONG_NM = 'C45255' THEN
                V_NAME := V_NAME||'::'||C_REC.NCI_CNCPT_VAL;
            END IF;
        ELSE
            V_NAME := V_NAME||','||C_REC.ITEM_LONG_NM;

            /* Check if Integer Concept */
            IF C_REC.ITEM_LONG_NM = 'C45255' THEN
                V_NAME := V_NAME||'::'||C_REC.NCI_CNCPT_VAL;
            END IF;
        END IF;

    END LOOP;
RETURN V_NAME;
END;
/

CREATE OR REPLACE FUNCTION GET_CONCEPTS_PRN(V_ITEM_ID IN NUMBER, V_VER_NR IN NUMBER) RETURN VARCHAR2 IS
CURSOR CON IS
SELECT C.ITEM_NM, CAI.NCI_CNCPT_VAL,ITEM_LONG_NM
FROM CNCPT_ADMIN_ITEM CAI, ADMIN_ITEM C
WHERE CAI.ITEM_ID = V_ITEM_ID AND CAI.VER_NR = V_VER_NR 
AND CAI.CNCPT_ITEM_ID = C.ITEM_ID AND CAI.CNCPT_VER_NR = C.VER_NR AND C.ADMIN_ITEM_TYP_ID = 49
ORDER BY  NCI_ORD DESC;

V_NAME VARCHAR2(1000);

BEGIN
    FOR C_REC IN CON LOOP
        IF V_NAME IS NULL THEN
            V_NAME := ':'||C_REC.ITEM_LONG_NM;

            /* Check if Integer Concept */
            IF C_REC.ITEM_NM = 'C45255' THEN
                V_NAME := V_NAME||'::'||C_REC.NCI_CNCPT_VAL;
            END IF;
        ELSE
            V_NAME := V_NAME||':'||C_REC.ITEM_LONG_NM;

            /* Check if Integer Concept */
            IF C_REC.ITEM_NM = 'C45255' THEN
                V_NAME := V_NAME||'::'||C_REC.NCI_CNCPT_VAL;
            END IF;
        END IF;

    END LOOP;
RETURN V_NAME;
END;
/

CREATE OR REPLACE FUNCTION ONEDATA_WA.GET_CONCEPT_ORIGIN(V_ITEM_ID IN NUMBER, V_VER_NR IN NUMBER) RETURN VARCHAR2 IS
CURSOR CON IS
SELECT DISTINCT ORIGIN FROM (
SELECT  NVL(C.ORIGIN,C.ORIGIN_ID_DN) ORIGIN
FROM CNCPT_ADMIN_ITEM CAI, ADMIN_ITEM C
WHERE CAI.ITEM_ID = V_ITEM_ID AND CAI.VER_NR = V_VER_NR
AND CAI.CNCPT_ITEM_ID = C.ITEM_ID AND CAI.CNCPT_VER_NR = C.VER_NR AND C.ADMIN_ITEM_TYP_ID = 49
ORDER BY  NCI_ORD DESC) A;

V_NAME VARCHAR2(1000);

BEGIN
    FOR C_REC IN CON LOOP
        IF V_NAME IS NULL THEN
            V_NAME := C_REC.ORIGIN;


        ELSE
           V_NAME := V_NAME||','||C_REC.ORIGIN;
          

        END IF;

    END LOOP;
RETURN V_NAME;
END;
/

