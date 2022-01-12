CREATE OR REPLACE FORCE VIEW CONTEXTS_VIEW
(
    CONTE_IDSEQ,
    CONTE_ID,
    VERSION,
    PREFERRED_NAME,
    DESCRIPTION,
    LANGUAGE,
    LL_NAME,
    PAL_NAME,
    NAME,
    CREATED_BY,
    DATE_CREATED,
    MODIFIED_BY,
    DATE_MODIFIED
)
BEQUEATH DEFINER
AS
      SELECT ai.NCI_IDSEQ          conte_IDSEQ,
             ai.ITEM_ID            conte_ID,
             ai.ver_nr             VERSION,
             ai.ITEM_LONG_NM       PREFERRED_NAME,
             ai.ITEM_DESC          DESCRIPTION,
             LANG_NM               LANGUAGE,
             'UNASSIGNED'          LL_NAME,
             NCI_CD                PAL_NAME,
             ai.ITEM_NM            NAME,
             ai.CREAT_USR_ID       CREATED_BY,
             ai.CREAT_DT           DATE_CREATED,
             ai.LST_UPD_USR_ID     MODIFIED_BY,
             ai.LST_UPD_DT         DATE_MODIFIED
        FROM admin_item ai,
             CNTXT     CX,
             OBJ_KEY,
             LANG
       WHERE     cx.item_id = ai.item_id
             AND cx.ver_nr = ai.ver_nr
             AND ai.ADMIN_ITEM_TYP_ID = 8
             AND LANG.LANG_ID = CX.LANG_ID
             AND cx.NCI_PRG_AREA_ID = OBJ_KEY.OBJ_KEY_ID
             AND OBJ_KEY.OBJ_TYP_ID = 14
    ORDER BY 4;
CREATE OR REPLACE FORCE VIEW DATA_ELEMENT_CONCEPTS_VIEW
(
    DEC_IDSEQ,
    VERSION,
    DEC_ID,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    LATEST_VERSION_IND,
    DELETED_IND,
    DATE_CREATED,
    BEGIN_DATE,
    CREATED_BY,
    END_DATE,
    DATE_MODIFIED,
    MODIFIED_BY,
    CHANGE_NOTE,
    ORIGIN,
    CD_IDSEQ,
    CONTE_IDSEQ,
    PROPL_NAME,
    OCL_NAME,
    OBJ_CLASS_QUALIFIER,
    PROPERTY_QUALIFIER,
    OC_IDSEQ,
    PROP_IDSEQ,
    CDR_NAME,
    PROP_ITEM_ID,
    PROP_VER_NR,
    OBJ_CLS_ITEM_ID,
    OBJ_CLS_VER_NR
)
BEQUEATH DEFINER
AS
    SELECT ai.nci_idseq
               DEC_IDSEQ,
           ai.ver_nr
               DEC_VERSION,
           ai.ITEM_ID
               DEC_ID,
           ai.ITEM_LONG_NM
               PREFERRED_NAME,
           ai.ITEM_NM
               LONG_NAME,
           ai.ITEM_DESC
               PREFERRED_DEFINITION,
           ai.ADMIN_STUS_NM_DN
               ASL_NAME,
           DECODE (AI.CURRNT_VER_IND,  1, 'YES',  0, 'NO')
               LATEST_VERSION_IND,
           AI.FLD_DELETE
               DELETED_IND,
           ai.CREAT_DT
               DATE_CREATED,
           ai.EFF_DT
               BEGIN_DATE,
           ai.CREAT_USR_ID
               CREATED_BY,
           ai.UNTL_DT
               END_DATE,
           ai.LST_UPD_DT
               DATE_MODIFIED,
           ai.LST_UPD_USR_ID
               MODIFIED_BY,
           ai.CHNG_DESC_TXT
               CHANGE_NOTE,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)
               ORIGIN,
           CD.NCI_IDSEQ
               CD_IDSEQ,
           CONTE.NCI_IDSEQ
               CONTE_IDSEQ,
           PROP.ITEM_NM
               PROPL_NAME,
           OC.ITEM_NM
               OCL_NAME,
           OBJ_CLS_QUAL
               OBJ_CLASS_QUALIFIER,
           PROP_QUAL
               PROPERTY_QUALIFIER,
           PROP.NCI_IDSEQ
               PROP_IDSEQ,
           OC.NCI_IDSEQ
               OC_IDSEQ,
              get_concepts_PRN (dec.OBJ_CLS_ITEM_ID, dec.OBJ_CLS_VER_NR)
           || get_concepts_PRN (dec.PROP_ITEM_ID, dec.PROP_VER_NR)
               CDR_NAME,
           dec.PROP_ITEM_ID,
           dec.PROP_VER_NR,
           dec.OBJ_CLS_ITEM_ID,
           dec.OBJ_CLS_VER_NR
      /* ai.UNRSLVD_ISSUE,
       ai.UNTL_DT,
       ai.REGSTR_STUS_NM_DN,
       ai.CNTXT_NM_DN,
       ai.CNTXT_ITEM_ID,
       ai.CNTXT_VER_NR,*/
      --       select count(*)
      FROM ADMIN_ITEM  ai,
           DE_CONC     dec,
           ADMIN_ITEM  CONTE,
           ADMIN_ITEM  cd,
           ADMIN_ITEM  oc,
           ADMIN_ITEM  prop
     WHERE     ai.ADMIN_ITEM_TYP_ID = 2
           AND ai.item_id = dec.ITEM_ID
           AND ai.ver_nr = dec.VER_NR
           AND CD.ADMIN_ITEM_TYP_ID = 1
           AND oc.ADMIN_ITEM_TYP_ID = 5
           AND prop.ADMIN_ITEM_TYP_ID = 6
           AND dec.OBJ_CLS_ITEM_ID = oc.ITEM_ID
           AND dec.OBJ_CLS_VER_NR = oc.VER_NR
           AND dec.PROP_ITEM_ID = prop.ITEM_ID
           AND dec.PROP_VER_NR = prop.VER_NR
           AND DEC.CONC_DOM_ITEM_ID = CD.ITEM_ID
           AND DEC.CONC_DOM_VER_NR = CD.VER_NR
           AND AI.CNTXT_ITEM_ID = CONTE.ITEM_ID
           AND AI.CNTXT_VER_NR = CONTE.VER_NR
           AND CONTE.ADMIN_ITEM_TYP_ID = 8;
		   
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


CREATE OR REPLACE FORCE VIEW DATA_ELEMENTS_VIEW
(
    DE_IDSEQ,
    CDE_ID,
    VERSION,
    LONG_NAME,
    PREFERRED_NAME,
    VD_IDSEQ,
    DEC_IDSEQ,
    CONTE_IDSEQ,
    DEC_ID,
    DEC_VERSION,
    VD_ID,
    VD_VERSION,
    PREFERRED_DEFINITION,
    ADMIN_NOTES,
    CHANGE_NOTE,
    BEGIN_DATE,
    ORIGIN,
    UNRESOLVED_ISSUE,
    UNTL_DT,
    LATEST_VERSION_IND,
    REGISTRATION_STATUS,
    ASL_NAME,
    WORKFLOW_STATUS_DESC,
    CONTEXTS_NAME,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    CREATED_BY,
    MODIFIED_BY,
    DELETED_IND,
    DATE_MODIFIED,
    DATE_CREATED,
    END_DATE,
    ADMIN_ITEM_TYP_ID,
    QUESTION
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.NCI_IDSEQ
               DE_IDSEQ,
           ADMIN_ITEM.ITEM_ID
               CDE_ID,
           ADMIN_ITEM.VER_NR
               VERSION,
           ADMIN_ITEM.ITEM_NM
               LONG_NAME,
           ADMIN_ITEM.ITEM_LONG_NM
               PREFERRED_NAME,
           VD.NCI_IDSEQ
               VD_IDSEQ,
           DE_CONC.NCI_IDSEQ
               DEC_IDSEQ,
           CONTE.NCI_IDSEQ
               CONTE_IDSEQ,
           DE_CONC_ITEM_ID
               DEC_ID,
           DE_CONC_VER_NR
               DEC_VERSION,
           VAL_DOM_ITEM_ID
               VD_ID,
           VAL_DOM_VER_NR
               VD_VERSION,
           ADMIN_ITEM.ITEM_DESC
               PREFERRED_DEFINITION,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT
               CHANGE_NOTE,
           --ADMIN_ITEM.CREATION_DT DATE_CREATED,
           TRUNC (ADMIN_ITEM.EFF_DT)
               BEGIN_DATE,
           NVL (ADMIN_ITEM.ORIGIN, ADMIN_ITEM.ORIGIN_ID_DN)
               ORIGIN,
           ADMIN_ITEM.UNRSLVD_ISSUE
               UNRESOLVED_ISSUE,
           ADMIN_ITEM.UNTL_DT
               END_DATE,
           DECODE (ADMIN_ITEM.CURRNT_VER_IND,  1, 'Yes',  0, 'No')
               LATEST_VERSION_IND,
           --ADMIN_ITEM.REGSTR_STUS_ID,
           --ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN
               REGISTRATION_STATUS,
           ADMIN_ITEM.ADMIN_STUS_NM_DN
               ASL_NAME,
           wf.STUS_DESC
               WORKFLOW_STATUS_DESC,
           ADMIN_ITEM.CNTXT_NM_DN
               CONTEXTS_NAME,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID
               CREATED_BY,
           ADMIN_ITEM.LST_UPD_USR_ID
               MODIFIED_BY,
           DECODE (ADMIN_ITEM.FLD_DELETE,  1, 'Yes',  0, 'No')
               DELETED_IND,
           TRUNC (ADMIN_ITEM.LST_UPD_DT)
               DATE_MODIFIED,
           TRUNC (ADMIN_ITEM.CREAT_DT)
               DATE_CREATED,
           TRUNC (ADMIN_ITEM.UNTL_DT)
               END_DATE,
           --ADMIN_ITEM.S2P_TRN_DT BEGIN_DATE,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           DE.PREF_QUEST_TXT
               QUESTION
      --SELECT*
      FROM ADMIN_ITEM  ADMIN_ITEM,
           DE,
           ADMIN_ITEM  DE_CONC,
           ADMIN_ITEM  VD,
           ADMIN_ITEM  CONTE,
           STUS_MSTR   wf
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND ADMIN_ITEM.ITEM_ID = DE.ITEM_ID
           AND ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ADMIN_STUS_ID = wf.STUS_ID
           AND wf.STUS_TYP_ID = 2
           AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VD.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND VD.ADMIN_ITEM_TYP_ID = 3
           AND DE_CONC.ADMIN_ITEM_TYP_ID = 2
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CONTE.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CONTE.VER_NR
           AND CONTE.ADMIN_ITEM_TYP_ID = 8;

CREATE OR REPLACE FORCE VIEW VALUE_DOMAINS_VIEW
(
    VD_IDSEQ,
    VERSION,
    PREFERRED_NAME,
    CONTE_IDSEQ,
    PREFERRED_DEFINITION,
    BEGIN_DATE,
    CONTE_NAME,
    CONTE_ITEM_ID,
    CONTE_VER_NR,
    DTL_NAME,
    CD_IDSEQ,
    CONC_DOM_ITEM_ID,
    CONC_DOM_VER_NR,
    END_DATE,
    VD_TYPE,
    ASL_NAME,
    CHANGE_NOTE,
    UOML_NAME,
    LONG_NAME,
    FORML_NAME,
    MAX_LENGTH_NUM,
    MIN_LENGTH_NUM,
    HIGH_VALUE_NUM,
    LOW_VALUE_NUM,
    DECIMAL_PLACE,
    LATEST_VERSION_IND,
    DELETED_IND,
    CREATED_BY,
    MODIFIED_BY,
    DATE_MODIFIED,
    DATE_CREATED,
    CHAR_SET_NAME,
    REP_IDSEQ,
    ORIGIN,
    VD_ID,
    VD_TYPE_FLAG
)
BEQUEATH DEFINER
AS
    SELECT ai.NCI_IDSEQ
               VD_IDSEQ,
           ai.ver_nr
               VERSION,
           ai.ITEM_LONG_NM
               PREFERRED_NAME,
           con.nci_idseq
               CONTE_IDSEQ,
           ai.ITEM_DESC
               PREFERRED_DEFINITION,
           AI.EFF_DT
               BEGIN_DATE,
           AI.CNTXT_NM_DN
               CONTE_NAME,
           AI.CNTXT_ITEM_ID
               CONTE_ITEM_ID,
           AI.CNTXT_VER_NR
               CONTE_VER_NR,
           data_typ.nci_cd
               DTL_NAME,
           cd.nci_idseq
               CD_IDSEQ,
           CONC_DOM_ITEM_ID,
           CONC_DOM_VER_NR,
           ai.UNTL_DT
               END_DATE,
           VAL_DOM_TYP_ID
               VD_TYPE,
           ai.ADMIN_STUS_NM_DN
               ASL_NAME,
           ai.CHNG_DESC_TXT
               CHANGE_NOTE,
           uom.nci_cd
               UOML_NAME,
           ai.ITEM_NM
               LONG_NAME,
           fmt.nci_cd
               FORML_NAME,
           VAL_DOM_HIGH_VAL_NUM
               MAX_LENGTH_NUM,
           VAL_DOM_LOW_VAL_NUM
               MIN_LENGTH_NUM,
           VAL_DOM_MAX_CHAR
               HIGH_VALUE_NUM,
           VAL_DOM_MIN_CHAR
               LOW_VALUE_NUM,
           NCI_DEC_PREC
               DECIMAL_PLACE,
           DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No')
               LATEST_VERSION_IND,
           DECODE (ai.FLD_DELETE,  1, 'Yes',  0, 'No')
               DELETED_IND,
           ai.CREAT_USR_ID
               CREATED_BY,
           ai.LST_UPD_USR_ID
               MODIFIED_BY,
           ai.LST_UPD_DT
               DATE_MODIFIED,
           ai.CREAT_DT
               DATE_CREATED,
           --ai.LST_DEL_DT                                 END_DATE,
           CHAR_SET_ID
               CHAR_SET_NAME,
           rep.NCI_IDSEQ
               REP_IDSEQ,
           --QUALIFIER_NAME,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)
               ORIGIN,
           ai.item_id
               VD_ID,
           DECODE (vd.VAL_DOM_TYP_ID,  17, 'E',  18, 'N')
               VD_TYPE_FLAG
      FROM VALUE_DOM   vd,
           admin_item  ai,
           admin_item  cd,
           fmt,
           admin_item  con,
           admin_item  rep,
           uom,
           data_typ
     WHERE     vd.item_id = ai.item_id
           AND vd.ver_nr = ai.ver_nr
           AND ai.ADMIN_ITEM_TYP_ID = 3
           AND ai.CNTXT_ITEM_ID = con.ITEM_ID
           AND AI.CNTXT_VER_NR = con.VER_NR
           AND REP_CLS_ITEM_ID = rep.item_id
           AND vd.REP_CLS_VER_NR = rep.ver_nr
           AND fmt.fmt_id(+) = vd.VAL_DOM_FMT_ID
           AND vd.uom_id = uom.uom_id(+)
           AND vd.DTTYPE_ID = data_typ.DTTYPE_ID
           AND cd.item_id = vd.CONC_DOM_ITEM_ID
           AND cd.ver_nr = vd.CONC_DOM_VER_NR;


CREATE OR REPLACE FORCE VIEW DE_EXCEL_GENERATOR_VIEW
(
    DE_IDSEQ,
    CDE_ID,
    LONG_NAME,
    PREFERRED_NAME,
    DOC_TEXT,
    PREFERRED_DEFINITION,
    VERSION,
    ORIGIN,
    BEGIN_DATE,
    DE_CONTE_NAME,
    DE_CONTE_ITEM_ID,
    DE_CONTE_VERSION,
    DEC_ID,
    DEC_PREFERRED_NAME,
    DEC_VERSION,
    DEC_CONTE_NAME,
    DEC_CONTE_VERSION,
    VD_ID,
    VD_PREFERRED_NAME,
    VD_VERSION,
    VD_CONTE_NAME,
    VD_CONTE_VERSION,
    VD_TYPE,
    DTL_NAME,
    MAX_LENGTH_NUM,
    MIN_LENGTH_NUM,
    HIGH_VALUE_NUM,
    LOW_VALUE_NUM,
    DECIMAL_PLACE,
    FORML_NAME,
    VD_LONG_NAME,
    CD_ID,
    CD_PREFERRED_NAME,
    CD_VERSION,
    CD_CONTE_NAME,
    OC_ID,
    OC_PREFERRED_NAME,
    OC_LONG_NAME,
    OC_VERSION,
    OC_CONTE_NAME,
    PROP_ID,
    PROP_PREFERRED_NAME,
    PROP_LONG_NAME,
    PROP_VERSION,
    PROP_CONTE_NAME,
    DEC_LONG_NAME,
    DE_WK_FLOW_STATUS,
    REGISTRATION_STATUS,
    VALID_VALUES,
    REFERENCE_DOCS,
    CLASSIFICATIONS,
    DESIGNATIONS,
    DE_DERIVATION,
    VD_CONCEPTS,
    OC_CONCEPTS,
    PROP_CONCEPTS,
    REP_ID,
    REP_PREFERRED_NAME,
    REP_LONG_NAME,
    REP_VERSION,
    REP_CONTE_NAME,
    REP_CONCEPTS
)
BEQUEATH DEFINER
AS
    SELECT ai.NCI_IDSEQ                                   DE_IDSEQ,
           ai.ITEM_ID                                     CDE_ID,
           ai.ITEM_NM                                     "LongName",
           ai.ITEM_LONG_NM                                "PreferredName",
           ai.ITEM_DESC                                   "PreferredDefinition",
           de.PREF_QUEST_TXT                              DOC_TEXT,
           ai.VER_NR                                      Version,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)               ORIGIN,
           AI.EFF_DT                                      BEGIN_DATE,
           AI.CNTXT_NM_DN                                 DE_CONTE_NAME,
           AI.CNTXT_ITEM_ID                               DE_CONTE_ITEM_ID,
           AI.CNTXT_VER_NR                                DE_CONTE_VER_NR,
           DEC_ID,
           DEC_PREFERRED_NAME,
           DEC_VERSION,
           DEC_CONTEXT_NAME                               DEC_CONTE_NAME,
           DEC_CONTEXT_VERSION                            DEC_CONTE_VERSION,
           VAL_DOM_ITEM_ID                                VD_ID,
           vdai.ITEM_LONG_NM                              VD_PREFERRED_NAME,
           VAL_DOM_VER_NR                                 VD_VERSION,
           vdai.CNTXT_NM_DN                               VD_CONTE_NAME,
           vdai.CNTXT_VER_NR                              VD_CONTE_VERSION,
           VAL_DOM_TYP_ID                                 VD_TYPE,
           dt.NCI_CD                                      DTL_NAME,
           VAL_DOM_HIGH_VAL_NUM                           MAX_LENGTH_NUM,
           VAL_DOM_LOW_VAL_NUM                            MIN_LENGTH_NUM,
           VAL_DOM_MAX_CHAR                               HIGH_VALUE_NUM,
           VAL_DOM_MIN_CHAR                               LOW_VALUE_NUM,
           NCI_DEC_PREC                                   DECIMAL_PLACE,
           fmt.nci_cd                                     FORML_NAME,
           vdai.ITEM_NM                                   VD_LONG_NAME,
           CD_ID,
           CD_PREFERRED_NAME,
           CD_VERSION,
           CD_CONTEXT_NAME                                CD_CONTE_NAME,
           --CD_PREFERRED_NAME,
           OC_ID,
           OC_PREFERRED_NAME,
           OC_LONG_NAME,
           OC_VERSION,
           OC_CONTEXT_NAME                                OC_CONTE_NAME,
           PROP_ID                                        PROP_ID,
           PT_PREFERRED_NAME                              PROP_PREFERRED_NAME,
           PT_VERSION                                     PROP_VERSION,
           PT_LONG_NAME                                   PROP_LONG_NAME,
           PT_CONTEXT_NAME                                PROP_CONTE_NAME,
           DEC_LONG_NAME,
           ai.ADMIN_STUS_NM_DN                            DE_WK_FLOW_STATUS,
           ai.REGSTR_STUS_NM_DN                           REGISTRATION_STATUS,
           CAST (
               MULTISET (
                   SELECT pv.PERM_VAL_NM,
                          pv.PERM_VAL_DESC_TXT,
                          vm.item_desc,
                          nci_11179.get_concepts (vm.item_id, vm.ver_nr)
                              MeaningConcepts,
                          pv.PERM_VAL_BEG_DT,
                          pv.PERM_VAL_END_DT,
                          vm.item_id,
                          vm.ver_nr,
                          DEF_DESC
                     FROM PERM_VAL pv, ADMIN_ITEM vm, ALT_DEF def
                    WHERE     pv.val_dom_item_id = vd.item_id
                          AND pv.Val_dom_ver_nr = vd.ver_nr
                          AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                          AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                          AND vm.NCI_IDSEQ = def.NCI_IDSEQ(+)
                          AND vm.ADMIN_ITEM_TYP_ID = 53       --GF32647 JR1047
                                                       )
                   AS VALID_VALUE_LIST_T_245)             valid_values,
           CAST (
               MULTISET (
                   SELECT rd.ref_nm,
                          org.org_nm,
                          --  ok.OBJ_KEY_DESC,
                          ok.obj_key_desc,
                          rd.ref_desc,
                          rd.URL,
                          TO_CHAR (rd.lang_id),
                          rd.disp_ord
                     FROM REF rd, obj_key ok, NCI_ORG org
                    WHERE     rd.REF_TYP_ID = ok.obj_key_id(+)
                          AND rd.ORG_ID = org.ENTTY_ID(+)
                          --, sbr.organizations org
                          AND de.item_id = rd.item_id
                          AND de.ver_nr = rd.ver_nr)
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
                     FROM cdebrowser_cs_view_n csv
                    WHERE     de.item_id = csv.de_item_id
                          AND de.ver_nr = csv.de_ver_nr)
                   AS cdebrowser_csi_list_t)              ClassificationsList,
           CAST (
               MULTISET (
                   SELECT des.cntxt_nm_dn,
                          TO_CHAR (des.cntxt_ver_nr),
                          des.NM_DESC,
                          ok.obj_key_desc,
                          TO_CHAR (des.lang_id)
                     FROM alt_nms des, obj_key ok
                    WHERE     de.item_id = des.item_id
                          AND de.ver_nr = des.ver_nr
                          AND des.nm_typ_id = ok.obj_key_id(+))
                   AS cdebrowser_altname_list_t)          designations,
           derived_data_element_t (ccd.CRTL_NAME,
                                   ccd.DESCRIPTION,
                                   ccd.METHODS,
                                   ccd.RULE,
                                   ccd.CONCAT_CHAR,
                                   "DataElementsList")    DE_DERIVATION,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item com,
                            admin_item      con,
                            obj_key         ok,
                            CNCPT           cn
                      WHERE     con.item_id = com.cncpt_item_id
                            AND con.ver_nr = cn.ver_nr
                            AND con.item_id = cn.item_id
                            AND con.ver_nr = com.cncpt_ver_nr
                            AND cn.EVS_SRC_ID = ok.OBJ_KEY_ID
                            AND com.item_id = VDAI.ITEM_ID
                            AND com.ver_nr = VDAI.VER_NR
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    vd_concepts,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item com,
                            admin_item      con,
                            obj_key         ok,
                            CNCPT           cn
                      WHERE     con.item_id = com.cncpt_item_id
                            AND con.ver_nr = cn.ver_nr
                            AND con.item_id = cn.item_id
                            AND con.ver_nr = com.cncpt_ver_nr
                            AND cn.EVS_SRC_ID = ok.OBJ_KEY_ID
                            AND com.item_id = OC_id
                            AND com.ver_nr = OC_VERSION
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    oc_concepts,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item com,
                            admin_item      con,
                            obj_key         ok,
                            CNCPT           cn
                      WHERE     con.item_id = com.cncpt_item_id
                            AND con.ver_nr = cn.ver_nr
                            AND con.item_id = cn.item_id
                            AND con.ver_nr = com.cncpt_ver_nr
                            AND cn.EVS_SRC_ID = ok.OBJ_KEY_ID
                            AND com.item_id = PROP_ID
                            AND com.ver_nr = PT_VERSION
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    prop_concepts,
           rep.item_id                                    rep_id,
           rep.item_long_nm                               rep_preferred_name,
           rep.item_nm                                    rep_long_name,
           rep.ver_nr                                     rep_version,
           rep.CNTXT_NM_DN                                rep_conte_name,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item com,
                            admin_item      con,
                            obj_key         ok,
                            CNCPT           cn
                      WHERE     con.item_id = com.cncpt_item_id
                            AND con.ver_nr = cn.ver_nr
                            AND con.item_id = cn.item_id
                            AND con.ver_nr = com.cncpt_ver_nr
                            AND cn.EVS_SRC_ID = ok.OBJ_KEY_ID
                            AND com.item_id = rep.item_id
                            AND com.ver_nr = rep.ver_nr
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    rep_concepts
      FROM ADMIN_ITEM                    ai,
           cdebrowser_de_dec_view        dec,
           admin_item                    vdai,
           ADMIN_ITEM                    cd,
           ADMIN_ITEM                    rep,
           value_dom                     vd,
           de                            de,
           data_typ                      dt,
           fmt,
           CDEBROWSER_COMPLEX_DE_VIEW_N  ccd,
           (SELECT rd.item_id,
                   rd.ver_nr,
                   rd.NCI_IDSEQ,
                   ok.obj_key_desc,
                   rd.disp_ord
              FROM REF rd, obj_key ok
             WHERE     rd.REF_TYP_ID = ok.obj_key_id
                   AND ok.obj_key_desc = 'Preferred Question Text') rfd
     WHERE     ai.item_id = dec.de_id
           AND ai.ver_nr = dec.de_version
           AND ai.nci_idseq = rfd.nci_idseq(+)
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
           AND vd.DTTYPE_ID = dt.DTTYPE_ID
           AND fmt.fmt_id(+) = vd.VAL_DOM_FMT_ID
           AND de.val_dom_item_id = vd.item_id
           AND de.val_dom_ver_nr = vd.ver_nr
           AND ai.item_id = ccd.item_id(+)
           AND ai.ver_nr = ccd.ver_nr(+);


