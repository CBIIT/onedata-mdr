
create or replace function get_concepts2(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select c.item_long_nm, cai.NCI_CNCPT_VAL
from cncpt_admin_item cai, admin_item c
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr
and cai.cncpt_item_id = c.item_id and cai.cncpt_ver_nr = c.ver_nr and c.admin_item_typ_id = 49
order by  nci_ord desc;

v_name varchar2(255);

begin
    for c_rec in con loop
        if v_name is null then
            v_name := c_rec.item_long_nm;

            /* Check if Integer Concept */
            if c_rec.item_long_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        else
            v_name := v_name||','||c_rec.item_long_nm;

            /* Check if Integer Concept */
            if c_rec.item_long_nm = 'C45255' then
                v_name := v_name||'::'||c_rec.nci_cncpt_val;
            end if;
        end if;

    end loop;
return v_name;
end;
/
create or replace function get_concept_origin(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select NVL(c.ORIGIN,c.ORIGIN_ID_DN) origin
from cncpt_admin_item cai, admin_item c
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr
and cai.cncpt_item_id = c.item_id and cai.cncpt_ver_nr = c.ver_nr and c.admin_item_typ_id = 49
order by  nci_ord desc;

v_name varchar2(255);

begin
    for c_rec in con loop
        if v_name is null then
            v_name := c_rec.origin;

       
        else
            v_name := v_name||','||c_rec.origin;

        end if;

    end loop;
return v_name;
end;
/
DROP TYPE CDEBROWSER_VD_T749     
/
DROP TYPE CDEBROWSER_DEC_T  
/
DROP TYPE DERIVED_DATA_ELEMENT_T  
/
DROP TYPE DATA_ELEMENT_DERIVATION_LIST_T 
/
DROP TYPE DATA_ELEMENT_DERIVATION_T
/
DROP TYPE CDEBROWSER_RD_LIST_T  ;
/
DROP TYPE CDEBROWSER_RD_T ;
/
DROP TYPE CDEBROWSER_CSI_LIST_T   
/
DROP TYPE CDEBROWSER_CSI_T   
/
DROP TYPE DE_VALID_VALUE_LIST_T      
/
DROP TYPE DE_VALID_VALUE_T    
/
DROP TYPE MDSR_749_PV_VD_LIST_T 
/
DROP  TYPE MDSR_749_PV_VD_ITEM_T            
/
DROP TYPE CDEBROWSER_ALTNAME_LIST_T   
/
DROP TYPE CDEBROWSER_ALTNAME_T2     
/
DROP TYPE MDSR_749_ALTERNATENAM_LIST_T  
/
DROP TYPE MDSR_749_ALTERNATENAME_ITEM_T   
/
DROP TYPE MDSR_749_PV_VD_LIST_T 
/
DROP  TYPE MDSR_749_PV_VD_ITEM_T            
/
DROP TYPE CDEBROWSER_ALTNAME_LIST_T   
/
DROP TYPE CDEBROWSER_ALTNAME_T2     
/
DROP TYPE ADMIN_COMPONENT_WITH_CON_T        
/
DROP TYPE ADMIN_COMPONENT_WITH_ID_LN_T       
/
DROP TYPE ADMIN_COMPONENT_WITH_ID_T    
/
DROP TYPE CONCEPTS_LIST_T    
/
DROP TYPE CONCEPT_DETAIL_T  
/


CREATE OR REPLACE TYPE DATA_ELEMENT_DERIVATION_T                                          as object (
  "PublicId"               number,
  "LongName"			   varchar2(255),
  "PreferredName"          varchar2(30),
  "PreferredDefinition"    varchar2(2000),
  "Version"                number(4,2),
  "WorkflowStatus"         varchar2(20),
  "ContextName"            varchar2(30),
  "DisplayOrder"           number
  );

/
CREATE OR REPLACE TYPE DATA_ELEMENT_DERIVATION_LIST_T                                          
                                        AS TABLE OF data_element_derivation_t;
/
CREATE OR REPLACE TYPE CONCEPT_DETAIL_T                                          AS OBJECT (
preferred_name         varchar2(30)
,long_name             varchar2(255)
,con_id                number
,definition_source     varchar2(2000)
,origin               varchar2(240)
,evs_Source            varchar2(255)
,primary_flag_ind  varchar2(3)
,display_order    number);
/
CREATE OR REPLACE TYPE CONCEPTS_LIST_T                                          AS TABLE OF CONCEPT_DETAIL_T;

/
CREATE OR REPLACE TYPE ADMIN_COMPONENT_WITH_CON_T                                          AS OBJECT
("PublicId"          number,
 "ContextName"	    varchar2(30),
 "ContextVersion"   number(4,2),
 "PreferredName"    varchar2(30),
 "Version" 	    number(4,2),
 "LongName" 	    varchar2(255),
 "ConceptDetails"   Concepts_list_t
);
/
CREATE OR REPLACE TYPE ADMIN_COMPONENT_WITH_ID_LN_T                                          AS OBJECT
 ("PublicId"          number,
 "ContextName"     varchar2(30),
 "ContextVersion"   number(4,2),
 "PreferredName"    varchar2(30),
 "Version"       number(4,2),
 "LongName"   varchar2(255)
  );
/

CREATE OR REPLACE TYPE ADMIN_COMPONENT_WITH_ID_T                                          AS OBJECT
("PublicId"          number,
 "ContextName"	    varchar2 (30),
 "ContextVersion"   number (4,2),
 "PreferredName"    varchar2(30),
 "Version" 		    number (4,2)
);

/
/
CREATE OR REPLACE TYPE MDSR_749_ALTERNATENAME_ITEM_T                                          as object(
"ContextName"                             VARCHAR2(30),
"ContextVersion"                        VARCHAR2(10),
"AlternateName"                                VARCHAR2(2000)
,"AlternateNameType"                           VARCHAR2(20)
,"Language"                        VARCHAR2(30)
);

/
CREATE OR REPLACE TYPE MDSR_749_ALTERNATENAM_LIST_T                                          as table of MDSR_749_ALTERNATENAME_ITEM_T;

/
CREATE OR REPLACE TYPE MDSR_749_PV_VD_ITEM_T                                          as object(ValidValue varchar2(255),
    ValueMeaning varchar2(255),
    MeaningDescription varchar2(2000),
    MeaningConcepts varchar2(2000),
    MeaningConceptOrigin               varchar2(2000),
	MeaningConceptDisplayOrder varchar2(2000),
    PvBeginDate Date,
    PvEndDate Date,
    VmPublicId Number,
    VmVersion Number(4,2),
	"dateModified" Date,
    "ALTERNATENAMELIST"    MDSR_749_ALTERNATENAM_LIST_T);
/
CREATE OR REPLACE TYPE MDSR_749_PV_VD_LIST_T   as table of MDSR_749_PV_VD_ITEM_T;


/
CREATE OR REPLACE TYPE CDEBROWSER_VD_T749                                          AS OBJECT
( "PublicId"         NUMBER,
  "PreferredName"          VARCHAR2 (30),
  "PreferredDefinition"    VARCHAR2 (2000),
  "LongName"      VARCHAR2(255),
  "Version"                NUMBER (4,2),
  "WorkflowStatus"         VARCHAR2 (20),
  "dateModified"    date,
  "ContextName"         VARCHAR2 (30),  
  "ContextVersion"     NUMBER (4,2),
  "ConceptualDomain"    admin_component_with_id_ln_t,
  "Datatype"                VARCHAR2 (20),
  "ValueDomainType"         VARCHAR2 (50),
  "UnitOfMeasure"          VARCHAR2 (20),
  "DisplayFormat"          VARCHAR2 (20),
  "MaximumLength"          NUMBER (8),
  "MinimumLength"          NUMBER (8),
  "DecimalPlace"           NUMBER (2),
  "CharacterSetName"       VARCHAR2 (20),
  "MaximumValue"           VARCHAR2 (255),
  "MinimumValue"           VARCHAR2 (255),
  "Origin"    VARCHAR2(240),
 "Representation"    admin_component_with_con_t,
  "PermissibleValues"     MDSR_749_PV_VD_LIST_T,
 "ValueDomainConcepts"    Concepts_list_t
);
/

CREATE OR REPLACE TYPE CDEBROWSER_DEC_T                                          AS OBJECT
 ("PublicId"      number,
  "PreferredName"          varchar2 (30),
  "PreferredDefinition"    varchar2 (2000),
  "LongName"     varchar2(255),
  "Version"                number (4,2),
  "WorkflowStatus"         varchar2 (20),
  "ContextName"            varchar2 (30),
  "ContextVersion"    number (4,2),
  "ConceptualDomain"    admin_component_with_id_ln_t,
  "ObjectClass"            admin_component_with_con_t,
  "Property"            admin_component_with_con_t,
  "ObjectClassQualifier"   varchar2 (30),
  "PropertyQualifier"    varchar2 (30),
  "Origin"     varchar2(240)
  );
/

CREATE OR REPLACE TYPE DERIVED_DATA_ELEMENT_T                                          as object (
  "DerivationType"                 varchar2(30),
  "DerivationTypeDescription"     varchar2(200),
  "Methods"                       varchar2(4000),
  "Rule"						  varchar2(4000),
  "ConcatenationCharacter"        varchar2(1),
  "ComponentDataElementsList"     data_element_derivation_list_t
);

/

CREATE OR REPLACE TYPE CDEBROWSER_RD_T                                          AS OBJECT (
  "Name"           	   	   VARCHAR2(255),
  "OrganizationName"       VARCHAR2(80),
  "DocumentType"       	   VARCHAR2(60),
  "DocumentText"       	   VARCHAR2(4000),
  "URL"            		     VARCHAR2(240),
  "Language"       		     VARCHAR2(30),
  "DisplayOrder"  		     VARCHAR2(2)
);

/
CREATE OR REPLACE TYPE CDEBROWSER_RD_LIST_T                                          as TABLE of CDEBROWSER_RD_T;

/

CREATE OR REPLACE TYPE CDEBROWSER_DEC_T                                          AS OBJECT
 ("PublicId"      number,
  "PreferredName"          varchar2 (30),
  "PreferredDefinition"    varchar2 (2000),
  "LongName"     varchar2(255),
  "Version"                number (4,2),
  "WorkflowStatus"         varchar2 (20),
  "ContextName"            varchar2 (30),
  "ContextVersion"    number (4,2),
  "ConceptualDomain"    admin_component_with_id_ln_t,
  "ObjectClass"            admin_component_with_con_t,
  "Property"            admin_component_with_con_t,
  "ObjectClassQualifier"   varchar2 (30),
  "PropertyQualifier"    varchar2 (30),
  "Origin"     varchar2(240)
  );
/

CREATE OR REPLACE TYPE CDEBROWSER_ALTNAME_T                                          as object(
    "ContextName"                                        VARCHAR2(30)
    ,"ContextVersion"                                     NUMBER(4,2)
    ,"AlternateName"                                      VARCHAR2(2000)
    ,"AlternateNameType"                                   VARCHAR2(20)
    ,"Language"                                           VARCHAR2(30));

/
CREATE OR REPLACE TYPE CDEBROWSER_ALTNAME_T2                                           as object(
    "ContextName"                                        VARCHAR2(30)
    ,"ContextVersion"                                     NUMBER(4,2)
    ,"AlternateName"                                      VARCHAR2(2000)
   ,"AlternateNameType"                                   VARCHAR2(20)
    ,"Language"                                           VARCHAR2(30));

/
CREATE OR REPLACE TYPE CDEBROWSER_ALTNAME_LIST_T                                          AS TABLE OF CDEBROWSER_ALTNAME_T2

/

CREATE OR REPLACE TYPE CDEBROWSER_CSI_T                                          as object
("ClassificationScheme"					admin_component_with_id_t
,"ClassificationSchemeItemName"			varchar2(255)
,"ClassificationSchemeItemType" 			varchar2(20)
,"CsiPublicId"                                  number
,"CsiVersion"                                  number(4,2)
);
/
CREATE OR REPLACE TYPE CDEBROWSER_CSI_LIST_T                                          AS TABLE OF CDEBROWSER_CSI_T;
/
CREATE OR REPLACE TYPE DE_VALID_VALUE_T                                          as object(
    ValidValue varchar2(255),
    ValueMeaning varchar2(255),
    MeaningDescription varchar2(2000),
    VmPublicId Number,
    VmVersion Number(4,2))
    ;

/
CREATE OR REPLACE TYPE DE_VALID_VALUE_LIST_T                                          AS TABLE OF DE_VALID_VALUE_T;
/

CREATE OR REPLACE FORCE VIEW CDEBROWSER_COMPLEX_DE_VIEW_N
(
    ITEM_ID,
    VER_NR,
    CRTL_NAME,
    DESCRIPTION,
    METHODS,
    RULE,
    CONCAT_CHAR,
    "DataElementsList"
)
BEQUEATH DEFINER
AS
    SELECT cde.ITEM_ID,
           cde.ver_NR,
           ctl.OBJ_KEY_DESC,
           ctl.OBJ_KEY_DEF,
           cde.DERV_MTHD,
           cde.DERV_RUL,
           cde.CONCAT_CHAR,
           CAST (
               MULTISET (
                   SELECT de.item_id,
                          de.ITEM_NM,
                          de.ITEM_LONG_NM,
                          de.ITEM_DESC,
                          de.VER_NR,
                          de.ADMIN_STUS_NM_DN,
                          de.CNTXT_NM_DN,
                          cdr.DISP_ORD
                     FROM NCI_ADMIN_ITEM_REL cdr, ADMIN_ITEM de
                    WHERE     cdr.C_ITEM_ID = de.ITEM_ID
                          --AND DE.ITEM_ID=2181785
                          AND cdr.C_ITEM_VER_NR = de.VER_NR
                          AND de.admin_item_typ_id = 4
                          AND cde.ITEM_ID = cdr.p_ITEM_ID(+)
                          AND cde.VER_NR = cdr.p_ITEM_VER_NR(+))
                   AS data_element_derivation_list_t)    "DataElementsList"
      FROM DE cde, OBJ_KEY ctl
     WHERE cde.DERV_TYP_ID = ctl.OBJ_KEY_ID AND ctl.OBJ_TYP_ID = 21;

CREATE OR REPLACE FORCE VIEW CDEBROWSER_DE_DEC_VIEW
(
    DE_ID,
    DE_VERSION,
    DEC_PREFERRED_NAME,
    DEC_LONG_NAME,
    PREFERRED_DEFINITION,
    DEC_VERSION,
    ASL_NAME,
    DEC_CONTEXT_NAME,
    DEC_CONTEXT_VERSION,
    OC_PREFERRED_NAME,
    OC_VERSION,
    OC_LONG_NAME,
    OC_CONTEXT_NAME,
    OC_CONTEXT_VERSION,
    PT_PREFERRED_NAME,
    PT_VERSION,
    PT_LONG_NAME,
    PT_CONTEXT_NAME,
    PT_CONTEXT_VERSION,
    CD_PREFERRED_NAME,
    CD_VERSION,
    CD_LONG_NAME,
    CD_CONTEXT_NAME,
    CD_CONTEXT_VERSION,
    OBJ_CLASS_QUALIFIER,
    PROPERTY_QUALIFIER,
    OC_ID,
    PROP_ID,
    CD_ID,
    DEC_ID,
    DEC_ORIGIN,
    OC_IDSEQ,
    PROP_IDSEQ,
    OC_CONDR_IDSEQ,
    PROP_CONDR_IDSEQ
)
BEQUEATH DEFINER
AS
    SELECT de.item_id               de_id,
           de.ver_nr                de_version,
           dec.ITEM_NM              dec_preferred_name,
           dec.ITEM_LONG_NM         dec_long_name,
           dec.ITEM_DESC            PREFERRED_DEFINITION,
           dec.ver_nr               dec_version,
           dec.admin_stus_nm_dn     ASL_NAME,
           dec.CNTXT_NM_DN          dec_context_name,
           dec.CNTXT_ver_NR         dec_context_version,
           oc.ITEM_NM               oc_preferred_name,
           oc.VER_NR                oc_version,
           oc.ITEM_LONG_NM          oc_long_name,
           oc.CNTXT_NM_DN           oc_context_name,
           oc.ver_NR                oc_context_version,
           pt.ITEM_NM               pt_preferred_name,
           pt.ver_NR                pt_version,
           pt.item_long_nm          pt_long_name,
           pt.CNTXT_NM_DN           pt_context_name,
           pt.cntxt_VER_NR          pt_context_version,
           cd.ITEM_NM               cd_preferred_name,
           cd.ver_NR                cd_version,
           cd.ITEM_LONG_NM          cd_long_name,
           cd.CNTXT_NM_DN           cd_context_name,
           cd.cntxt_ver_NR          cd_context_version,
           de_conc.obj_cls_qual     obj_class_qualifier,
           de_conc.prop_qual        property_qualifier,
           oc.item_id               oc_id,
           pt.item_id               prop_id,
           cd.item_id               cd_id,
           dec.item_id              dec_id,
           dec.origin               dec_origin,
           oc.nci_idseq             oc_idseq,
           pt.nci_idseq             prop_idseq,
           oc.nci_idseq             oc_condr_idseq,
           pt.nci_idseq             prop_condr_idseq
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
/
    CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW_N
(
    DE_ITEM_ID,
    DE_VER_NR,
    CS_ITEM_ID,
    CS_VER_NR,
    CS_ITEM_NM,
    CS_ITEM_LONG_NM,
    CS_PREF_DEF,
    CS_ADMIN_STUS,
    CS_REGSTR_STUS,
    CS_CNTXT_NM,
    CS_CNTXT_VER_NR,
    CSI_ITEM_ID,
    CSI_VER_NR,
    CSI_ITEM_NM,
    CSI_LONG_NM,
    CSITL_NM,
    CSI_PREF_DEF
)
BEQUEATH DEFINER
AS
    SELECT de.ITEM_ID             DE_ITEM_ID,
           de.VER_NR              DE_VER_NR,
           csi.CS_ITEM_ID         CS_ID,
           csi.CS_ITEM_VER_NR     CS_VER_NR,
           cs.ITEM_NM,
           cs.ITEM_LONG_NM,
           cs.ITEM_DESC,
           cs.ADMIN_STUS_NM_DN,
           cs.REGSTR_STUS_NM_DN,
           cs.CNTXT_NM_DN,
           cs.CNTXT_VER_NR,
           acsi.ITEM_ID           CS_ITEM_ID,
           acsi.VER_NR            CS_ITEM_VER_NR,
           acsi.ITEM_NM           CSI_ITEM_NM,
           acsi.ITEM_LONG_NM      CSI_LONG_NM,
           o.NCI_CD               CSITL_NM,
           acsi.ITEM_DESC         CSI_PREF_DEF
      --   select*
      FROM NCI_ADMIN_ITEM_REL     ak,
           ADMIN_ITEM             cs,
           NCI_CLSFCTN_SCHM_ITEM  csi,
           DE,
           OBJ_KEY                o,
           ADMIN_ITEM             acsi
     WHERE     ak.C_ITEM_ID = de.ITEM_ID
           AND ak.C_ITEM_VER_NR = de.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR
           AND acsi.ITEM_ID = csi.ITEM_ID
           AND acsi.VER_NR = csi.VER_NR
           AND csi.CS_ITEM_ID = cs.ITEM_ID
           AND csi.CS_ITEM_VER_NR = cs.VER_NR
           AND cs.ADMIN_ITEM_TYP_ID = 9
           AND acsi.ADMIN_ITEM_TYP_ID = 51
           AND csi.CSI_TYP_ID = o.obj_key_id;
/


CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW
(
    RAI,
    PUBLICID,
    LONGNAME,
    PREFERREDNAME,
    PREFERREDDEFINITION,
    VERSION,
    WORKFLOWSTATUS,
    CONTEXTNAME,
    CONTEXTVERSION,
    ORIGIN,
    "dateModified",
    DATAELEMENTCONCEPT,
    VALUEDOMAIN,
    REFERENCEDOCUMENTSLIST,
    CLASSIFICATIONSLIST,
    ALTERNATENAMELIST,
    DATAELEMENTDERIVATION
)
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
             -- ai.REGSTR_STUS_NM_DN                           "RegistrationStatus",
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
                 onedata_wa.admin_component_with_id_ln_t (dec.cd_id,
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
                                      VW_CNCPT      cncpt
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
                                      VW_CNCPT      cncpt
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
             -- select
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
                onedata_WA.admin_component_with_id_ln_T (cd.item_id,
                                               cd.cntxt_nm_dn,
                                               cd.cntxt_ver_nr,
                                               cd.item_long_nm,
                                               cd.ver_nr,
                                               cd.item_nm),              /* */
                 data_typ.DTTYPE_NM,
                 DECODE (vd.VAL_DOM_TYP_ID,
                         17, 'Enumerated',
                         18, 'Non-enumerated'),
                 vd.uom_id,
                 vd.VAL_DOM_FMT_ID,
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
                                      VW_CNCPT      cncpt
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
                         AS MDSR_749_PV_VD_LIST_T),
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
                                  VW_CNCPT      cncpt
                            WHERE     vd.item_id = com.item_id(+)
                                  AND vd.ver_nr = com.ver_nr(+)
                                  AND com.cncpt_item_id = con.item_id(+)
                                  AND com.cncpt_ver_nr = con.ver_nr(+)
                                  AND con.admin_item_typ_id(+) = 49
                                  AND com.cncpt_item_id = cncpt.item_id(+)
                                  AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                         ORDER BY nci_ord DESC, con.item_id, cncpt.evs_src)
                         AS Concepts_list_t))               "ValueDomain",
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
                     AS cdebrowser_rd_list_t)               "ReferenceDocumentsList",
             CAST (
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
                         FROM cdebrowser_cs_view_n2 csv
                        WHERE     de.item_id = csv.de_item_id
                              AND de.ver_nr = csv.de_ver_nr
                     ORDER BY csv.cs_cntxt_nm,
                              csv.cs_item_id,
                              csv.cs_ver_nr,
                              csv.csi_item_id,
                              csv.csi_ver_nr)
                     AS cdebrowser_csi_list_t)              "ClassificationsList",
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
        FROM ADMIN_ITEM                  ai,
             cdebrowser_de_dec_view      dec,
             admin_item                  vdai,
             ADMIN_ITEM                  cd,
             ADMIN_ITEM                  rep,
             value_dom                   vd,
             de                          de,
             CDEBROWSER_COMPLEX_DE_VIEW_N ccd,
             data_typ
       WHERE     ai.item_id = dec.de_id
             AND ai.ver_nr = dec.de_version
             AND ai.ADMIN_STUS_NM_DN NOT IN
                     ('RETIRED WITHDRAWN', 'RETIRED DELETED')
             AND ai.item_id = de.item_id
             AND ai.ver_nr = de.ver_nr
             AND ai.admin_item_typ_id = 4
             AND cd.admin_item_typ_id = 1
             AND cd.item_id = vd.CONC_DOM_ITEM_ID
             AND cd.ver_nr = vd.CONC_DOM_VER_NR
             AND rep.ADMIN_ITEM_TYP_ID = 7
             AND rep.item_id = vd.REP_CLS_ITEM_ID(+)
             AND rep.ver_nr = vd.REP_CLS_VER_NR(+)
             AND de.val_dom_item_id = vdai.item_id
             AND de.val_dom_ver_nr = vdai.ver_nr
             AND vdai.admin_item_typ_id = 3
             AND de.val_dom_item_id = vd.item_id
             AND de.val_dom_ver_nr = vd.ver_nr
             AND ai.item_id = ccd.item_id(+)
             AND ai.ver_nr = ccd.ver_nr(+)
             AND vd.dttype_id = DATA_TYP.DTTYPE_ID(+)
    ORDER BY ai.ITEM_ID, ai.ver_nr;
/
CREATE TABLE CDE_19_REPORTS_ERR_LOG
(
  FILE_NAME         VARCHAR2(50 BYTE),
  REPORT_ERROR_TXT  VARCHAR2(1100 BYTE),
  DATE_PROCESSED    DATE
)
;

GRANT SELECT ON CDE_19_REPORTS_ERR_LOG TO ONEDATA_RA;

GRANT SELECT ON CDE_19_REPORTS_ERR_LOG TO ONEDATA_RO;
/
CREATE TABLE CDE_19_GENERATED_XML
(
  FILE_NAME     VARCHAR2(200 BYTE),
  TEXT          CLOB,
  CREATED_DATE  DATE                            DEFAULT SYSDATE,
  SEQ_ID        NUMBER
);
/

CREATE OR REPLACE PROCEDURE CDE_XML_19_INSERT as
/*insert XML*/
P_file number;
l_file_name      VARCHAR2(100);
l_file_path      VARCHAR2(200);
l_result         CLOB:=null;
l_xmldoc          CLOB:=null;
errmsg VARCHAR2(500):='Non';

BEGIN

select count(*) into P_file from CDE_19_GENERATED_XML;
IF P_file>0 then
 select max(NVL(SEQ_ID,0))+1 into P_file from CDE_19_GENERATED_XML;
end if;
        l_file_path := 'SBREXT_DIR';

         l_file_name := 'CDE_XML_'||P_file||'.xml';

        SELECT dbms_xmlgen.getxml( 'select* from DE_CDE1_XML_GENERATOR_749VW where PUBLICID=62')
        INTO l_result
        FROM DUAL ;
        insert into CDE_19_GENERATED_XML VALUES ( l_file_name ,l_result,SYSDATE,P_file);

 commit;
 EXCEPTION
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into CDE_19_REPORTS_ERR_LOG VALUES (l_file_name,  errmsg, sysdate);
 commit;

END ;
/

