DROP VIEW ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N
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


DROP VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW
(
    DE_ITEM_ID,
    DE_VER_NR,
    CS_ITEM_ID,
    CS_ITEM_NM,
    CS_ITEM_LONG_NM,
    CS_PREF_DEF,
    CS_VER_NR,
    CS_ADMIN_STUS,
    CS_CNTXT_NM,
    CS_CNTXT_VER_NR,
    CSI_LONG_NM,
    CSI_PREF_DEF,
    CSI_ITEM_ID,
    CSI_VER_NR,
    CSI_ITEM_NM
)
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


DROP VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW_N;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW_N
(
    DE_ITEM_ID,
    DE_VER_NR,
    CS_ITEM_ID,
    CS_ITEM_NM,
    CS_ITEM_LONG_NM,
    CS_PREF_DEF,
    CS_VER_NR,
    CS_ADMIN_STUS,
    CS_CNTXT_NM,
    CS_CNTXT_VER_NR,
    CSI_LONG_NM,
    CSITL_NM,
    CSI_PREF_DEF,
    CSI_ITEM_ID,
    CSI_VER_NR,
    CSI_ITEM_NM
)
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
           csi.item_long_nm         csi_long_nm,
           o.NCI_CD                 csitl_nm,
           csi.item_desc            csi_pref_def,
           csi.item_id              csi_item_id,
           csi.ver_nr               csi_ver_nr,
           csi.item_nm              csi_item_nm
      FROM admin_item                  cs,
           NCI_ADMIN_ITEM_REL_ALT_KEY  cs_csi,
           ADMIN_ITEM                  csi,
           NCI_ALT_KEY_ADMIN_ITEM_REL  ac_csi,
           OBJ_KEY                     o,
           NCI_CLSFCTN_SCHM_ITEM       ncsi
     WHERE     cs.item_id = cs_csi.CNTXT_CS_ITEM_ID
           AND cs.ver_nr = cs_csi.CNTXT_CS_VER_NR
           AND csi.item_id = cs_csi.c_item_id
           AND csi.ver_nr = cs_csi.c_item_ver_nr
           AND cs_csi.nci_pub_id = ac_csi.nci_pub_id
           AND cs_csi.nci_ver_nr = ac_csi.nci_ver_nr
           AND csi.item_id = ncsi.item_id
           AND csi.ver_nr = ncsi.ver_nr
           AND ncsi.CSI_TYP_ID = o.obj_key_id;


DROP VIEW ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW
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


DROP VIEW ONEDATA_WA.CNCPT_CONC_DOM;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CNCPT_CONC_DOM
(
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    ITEM_ID,
    VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CNCPT_ADMIN_ITEM.CNCPT_ITEM_ID,
           CNCPT_ADMIN_ITEM.CNCPT_VER_NR,
           CNCPT_ADMIN_ITEM.ITEM_ID,
           CNCPT_ADMIN_ITEM.VER_NR,
           CNCPT_ADMIN_ITEM.CREAT_DT,
           CNCPT_ADMIN_ITEM.CREAT_USR_ID,
           CNCPT_ADMIN_ITEM.LST_UPD_USR_ID,
           CNCPT_ADMIN_ITEM.FLD_DELETE,
           CNCPT_ADMIN_ITEM.LST_DEL_DT,
           CNCPT_ADMIN_ITEM.S2P_TRN_DT,
           CNCPT_ADMIN_ITEM.LST_UPD_DT
      FROM CNCPT_ADMIN_ITEM
     WHERE (ITEM_ID, VER_NR) IN (SELECT ITEM_ID, VER_NR
                                   FROM ADMIN_ITEM
                                  WHERE ADMIN_ITEM_TYP_ID = 1);


DROP VIEW ONEDATA_WA.CNCPT_DEC;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CNCPT_DEC
(
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    ITEM_ID,
    VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CNCPT_ADMIN_ITEM.CNCPT_ITEM_ID,
           CNCPT_ADMIN_ITEM.CNCPT_VER_NR,
           CNCPT_ADMIN_ITEM.ITEM_ID,
           CNCPT_ADMIN_ITEM.VER_NR,
           CNCPT_ADMIN_ITEM.CREAT_DT,
           CNCPT_ADMIN_ITEM.CREAT_USR_ID,
           CNCPT_ADMIN_ITEM.LST_UPD_USR_ID,
           CNCPT_ADMIN_ITEM.FLD_DELETE,
           CNCPT_ADMIN_ITEM.LST_DEL_DT,
           CNCPT_ADMIN_ITEM.S2P_TRN_DT,
           CNCPT_ADMIN_ITEM.LST_UPD_DT
      FROM CNCPT_ADMIN_ITEM
     WHERE (ITEM_ID, VER_NR) IN (SELECT ITEM_ID, VER_NR
                                   FROM ADMIN_ITEM
                                  WHERE ADMIN_ITEM_TYP_ID = 2);


DROP VIEW ONEDATA_WA.CNCPT_OBJ_CLS;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CNCPT_OBJ_CLS
(
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    ITEM_ID,
    VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CNCPT_ADMIN_ITEM.CNCPT_ITEM_ID,
           CNCPT_ADMIN_ITEM.CNCPT_VER_NR,
           CNCPT_ADMIN_ITEM.ITEM_ID,
           CNCPT_ADMIN_ITEM.VER_NR,
           CNCPT_ADMIN_ITEM.CREAT_DT,
           CNCPT_ADMIN_ITEM.CREAT_USR_ID,
           CNCPT_ADMIN_ITEM.LST_UPD_USR_ID,
           CNCPT_ADMIN_ITEM.FLD_DELETE,
           CNCPT_ADMIN_ITEM.LST_DEL_DT,
           CNCPT_ADMIN_ITEM.S2P_TRN_DT,
           CNCPT_ADMIN_ITEM.LST_UPD_DT
      FROM CNCPT_ADMIN_ITEM
     WHERE (ITEM_ID, VER_NR) IN (SELECT ITEM_ID, VER_NR
                                   FROM ADMIN_ITEM
                                  WHERE ADMIN_ITEM_TYP_ID = 5);


DROP VIEW ONEDATA_WA.CNCPT_PROP;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CNCPT_PROP
(
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    ITEM_ID,
    VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CNCPT_ADMIN_ITEM.CNCPT_ITEM_ID,
           CNCPT_ADMIN_ITEM.CNCPT_VER_NR,
           CNCPT_ADMIN_ITEM.ITEM_ID,
           CNCPT_ADMIN_ITEM.VER_NR,
           CNCPT_ADMIN_ITEM.CREAT_DT,
           CNCPT_ADMIN_ITEM.CREAT_USR_ID,
           CNCPT_ADMIN_ITEM.LST_UPD_USR_ID,
           CNCPT_ADMIN_ITEM.FLD_DELETE,
           CNCPT_ADMIN_ITEM.LST_DEL_DT,
           CNCPT_ADMIN_ITEM.S2P_TRN_DT,
           CNCPT_ADMIN_ITEM.LST_UPD_DT
      FROM CNCPT_ADMIN_ITEM
     WHERE (ITEM_ID, VER_NR) IN (SELECT ITEM_ID, VER_NR
                                   FROM ADMIN_ITEM
                                  WHERE ADMIN_ITEM_TYP_ID = 6);


DROP VIEW ONEDATA_WA.CONTEXTS_VIEW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CONTEXTS_VIEW
(
    CONTE_IDSEQ,
    CONTE_ID,
    VERSION,
    PREFERRED_NAME,
    DESCRIPTION,
    LANGUAGE,
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
             -- LL_NAME,
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


DROP VIEW ONEDATA_WA.DATA_ELEMENTS_VIEW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DATA_ELEMENTS_VIEW
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


DROP VIEW ONEDATA_WA.DATA_ELEMENT_CONCEPTS_VIEW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DATA_ELEMENT_CONCEPTS_VIEW
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


DROP VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW;

/* Formatted on 10/6/2021 12:35:20 PM (QP5 v5.354) */
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
    REGISTRATIONSTATUS,
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
    SELECT                                                     ---de.de_idseq,
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
           ai.LST_UPD_DT                                  "dateModified",
           cdebrowser_dec_t (
               dec.dec_id,
               dec.dec_long_name,
               dec.PREFERRED_DEFINITION,
               dec.dec_preferred_name,
               dec.dec_version,
               dec.ASL_NAME,
               dec.dec_context_name,
               dec.dec_context_version,
               admin_component_with_id_ln_t (dec.cd_id,
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
                                    com.NCI_PRMRY_IND
                                        primary_flag_ind,
                                    com.nci_ord
                                        display_order
                               FROM cncpt_admin_item   com,
                                    Admin_item         con,
                                    ONEDATA_WA.VW_CNCPT cncpt
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
                                    com.NCI_PRMRY_IND
                                        primary_flag_ind,
                                    com.nci_ord
                                        display_order
                               FROM cncpt_admin_item   com,
                                    Admin_item         con,
                                    ONEDATA_WA.VW_CNCPT cncpt
                              WHERE     dec.prop_id = com.item_id(+)
                                    AND dec.pt_version = com.ver_nr(+)
                                    AND com.cncpt_item_id = con.item_id(+)
                                    AND com.cncpt_ver_nr = con.ver_nr(+)
                                    AND con.admin_item_typ_id(+) = 49
                                    AND com.cncpt_item_id = cncpt.item_id(+)
                                    AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                           ORDER BY nci_ord DESC)
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
               vdai.cntxt_nm_dn,
               vdai.cntxt_ver_nr,
               admin_component_with_id_ln_T (cd.item_id,
                                             cd.cntxt_nm_dn,
                                             cd.cntxt_ver_nr,
                                             cd.item_long_nm,
                                             cd.ver_nr,
                                             cd.item_nm),                /* */
               vd.dttype_id,
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
                                    com.NCI_PRMRY_IND
                                        primary_flag_ind,
                                    com.nci_ord
                                        display_order
                               FROM cncpt_admin_item   com,
                                    Admin_item         con,
                                    ONEDATA_WA.VW_CNCPT cncpt
                              WHERE     rep.item_id = com.item_id(+)
                                    AND rep.ver_nr = com.ver_nr(+)
                                    AND com.cncpt_item_id = con.item_id(+)
                                    AND com.cncpt_ver_nr = con.ver_nr(+)
                                    AND con.admin_item_typ_id(+) = 49
                                    AND com.cncpt_item_id = cncpt.item_id(+)
                                    AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                           ORDER BY nci_ord DESC)
                           AS Concepts_list_t)),
               CAST (
                   MULTISET (
                       SELECT pv.PERM_VAL_NM,
                              pv.PERM_VAL_DESC_TXT,
                              vm.item_desc,
                              nci_11179.get_concepts (vm.item_id,
                                                      vm.ver_nr)
                                  MeaningConcepts,
                              /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                    vm.condr_idseq)
                                    MeaningConceptOrigin,  */
                              nci_11179.get_concepts (vm.item_id, vm.ver_nr)
                                  MeaningConceptOrigin,
                              nci_11179.get_concept_order (vm.item_id,
                                                           vm.ver_nr)
                                  MeaningConceptDisplayOrder,
                              pv.PERM_VAL_BEG_DT,
                              pv.PERM_VAL_END_DT,
                              vm.item_id,
                              vm.ver_nr,
                              CAST (
                                  MULTISET (
                                      SELECT des.cntxt_nm_dn,
                                             TO_CHAR (des.cntxt_ver_nr),
                                             des.NM_DESC,
                                             ok.obj_key_desc,
                                             TO_CHAR (des.lang_id)   -- decode
                                        FROM alt_nms des, obj_key ok
                                       WHERE     vm.item_id = des.item_id(+)
                                             AND vm.ver_nr = des.ver_nr(+)
                                             AND des.NM_TYP_ID =
                                                 ok.obj_key_id(+))
                                      AS MDSR_749_ALTERNATENAM_LIST_T)
                                  "AlternateNameList"
                         FROM PERM_VAL pv, ADMIN_ITEM vm
                        WHERE     pv.val_dom_item_id = vd.item_id
                              AND pv.Val_dom_ver_nr = vd.ver_nr
                              AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                              AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                              AND vm.ADMIN_ITEM_TYP_ID = 53)
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
                                com.NCI_PRMRY_IND
                                    primary_flag_ind,
                                com.nci_ord
                                    display_order
                           FROM cncpt_admin_item   com,
                                Admin_item         con,
                                ONEDATA_WA.VW_CNCPT cncpt
                          WHERE     vd.item_id = com.item_id(+)
                                AND vd.ver_nr = com.ver_nr(+)
                                AND com.cncpt_item_id = con.item_id(+)
                                AND com.cncpt_ver_nr = con.ver_nr(+)
                                AND con.admin_item_typ_id(+) = 49
                                AND com.cncpt_item_id = cncpt.item_id(+)
                                AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                       ORDER BY nci_ord DESC)
                       AS Concepts_list_t))               "ValueDomain",
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
                   AS cdebrowser_csi_list_t)              "ClassificationsList",
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
                   AS cdebrowser_altname_list_t)          "AlternateNameList",
           derived_data_element_t (ccd.CRTL_NAME,
                                   ccd.DESCRIPTION,
                                   ccd.METHODS,
                                   ccd.RULE,
                                   ccd.CONCAT_CHAR,
                                   "DataElementsList")    "DataElementDerivation"
      FROM ADMIN_ITEM                    ai,
           cdebrowser_de_dec_view        dec,
           admin_item                    vdai,
           ADMIN_ITEM                    cd,
           ADMIN_ITEM                    rep,
           value_dom                     vd,
           de                            de,
           CDEBROWSER_COMPLEX_DE_VIEW_N  ccd
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
           AND ai.ver_nr = ccd.ver_nr(+);


DROP VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW_DEEPALI;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_CDE1_XML_GENERATOR_749VW_DEEPALI
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
    REGISTRATIONSTATUS,
    DATAELEMENTCONCEPT,
    VALUEDOMAIN,
    REFERENCEDOCUMENTSLIST,
    CLASSIFICATIONSLIST,
    ALTERNATENAMELIST
)
BEQUEATH DEFINER
AS
    SELECT                                                     ---de.de_idseq,
           '2.16.840.1.113883.3.26.2'
               "RAI",
           ai.ITEM_ID
               "PublicId",
           ai.ITEM_LONG_NM
               "LongName",
           ai.ITEM_NM
               "PreferredName",
           ai.ITEM_DESC
               "PreferredDefinition",
           ai.VER_NR
               "Version",
           ai.ADMIN_STUS_NM_DN
               "WorkflowStatus",
           ai.CNTXT_NM_DN
               "ContextName",
           ai.CNTXT_VER_NR
               "ContextVersion",
           ai.origin
               "Origin",
           ai.REGSTR_STUS_NM_DN
               "RegistrationStatus",
           cdebrowser_dec_t (
               dec.dec_id,
               dec.dec_preferred_name,
               dec.PREFERRED_DEFINITION,
               dec.dec_long_name,
               dec.dec_version,
               dec.ASL_NAME,
               dec.dec_context_name,
               dec.dec_context_version,
               admin_component_with_id_ln_t (dec.cd_id,
                                             dec.cd_context_name,
                                             dec.cd_context_version,
                                             dec.cd_preferred_name,
                                             dec.cd_version,
                                             dec.cd_long_name),
               admin_component_with_con_t (
                   dec.oc_id,
                   dec.oc_context_name,
                   dec.oc_context_version,
                   dec.oc_preferred_name,
                   dec.oc_version,
                   dec.oc_long_name,
                   CAST (
                       MULTISET (
                             SELECT con.item_nm           preferred_name,
                                    con.item_long_nm      long_name,
                                    con.item_id           con_id,
                                    con.def_src           definition_source,
                                    con.origin            origin,
                                    cncpt.evs_src         evs_Source,
                                    com.NCI_PRMRY_IND     primary_flag_ind,
                                    com.nci_ord           display_order
                               FROM cncpt_admin_item com, Admin_item con, cncpt
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
                   dec.pt_preferred_name,
                   dec.pt_version,
                   dec.pt_long_name,
                   CAST (
                       MULTISET (
                             SELECT con.item_nm           preferred_name,
                                    con.item_long_nm      long_name,
                                    con.item_id           con_id,
                                    con.def_src           definition_source,
                                    con.origin            origin,
                                    cncpt.evs_src         evs_Source,
                                    com.NCI_PRMRY_IND     primary_flag_ind,
                                    com.nci_ord           display_order
                               FROM cncpt_admin_item com, Admin_item con, cncpt
                              WHERE     dec.prop_id = com.item_id(+)
                                    AND dec.pt_version = com.ver_nr(+)
                                    AND com.cncpt_item_id = con.item_id(+)
                                    AND com.cncpt_ver_nr = con.ver_nr(+)
                                    AND con.admin_item_typ_id(+) = 49
                                    AND com.cncpt_item_id = cncpt.item_id(+)
                                    AND com.cncpt_ver_nr = cncpt.ver_nr(+)
                           ORDER BY nci_ord DESC)
                           AS Concepts_list_t)),
               dec.obj_class_qualifier,
               dec.property_qualifier,
               dec.dec_origin)
               "DataElementConcept",
           CDEBROWSER_VD_T749 (
               vdai.item_id,
               vdai.item_nm,
               vdai.item_desc,
               vdai.item_long_nm,
               vdai.ver_nr,
               vdai.admin_stus_nm_dn,
               vdai.cntxt_nm_dn,
               vdai.cntxt_ver_nr,
               /*  admin_component_with_id_ln_T (cd.item_id,
                                               cd.cntxt_nm_dn,
                                               cd.cntxt_ver_nr,
                                               cd.item_nm,
                                               cd.ver_nr,
                                               cd.item_long_nm), */
               vd.dttype_id,
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
               vdai.origin,
               CAST (
                   MULTISET (
                       SELECT pv.PERM_VAL_NM,
                              pv.PERM_VAL_DESC_TXT,
                              vm.item_desc,
                              nci_11179.get_concepts (vm.item_id,
                                                      vm.ver_nr)
                                  MeaningConcepts,
                              /*  SBREXT.MDSR_CDEBROWSER.get_condr_origin (
                                    vm.condr_idseq)
                                    MeaningConceptOrigin,  */
                              nci_11179.get_concepts (vm.item_id, vm.ver_nr)
                                  MeaningConceptOrigin,
                              nci_11179.get_concept_order (vm.item_id,
                                                           vm.ver_nr)
                                  MeaningConceptDisplayOrder,
                              pv.PERM_VAL_BEG_DT,
                              pv.PERM_VAL_END_DT,
                              vm.item_id,
                              vm.ver_nr,
                              CAST (
                                  MULTISET (
                                      SELECT des.cntxt_nm_dn,
                                             TO_CHAR (des.cntxt_ver_nr),
                                             des.NM_DESC,
                                             ok.obj_key_desc,
                                             TO_CHAR (des.lang_id)   -- decode
                                        FROM alt_nms des, obj_key ok
                                       WHERE     vm.item_id = des.item_id(+)
                                             AND vm.ver_nr = des.ver_nr(+)
                                             AND des.NM_TYP_ID =
                                                 ok.obj_key_id(+))
                                      AS MDSR_749_ALTERNATENAM_LIST_T)
                                  "AlternateNameList"
                         FROM PERM_VAL pv, ADMIN_ITEM vm
                        WHERE     pv.val_dom_item_id = vd.item_id
                              AND pv.Val_dom_ver_nr = vd.ver_nr
                              AND pv.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
                              AND pv.NCI_VAL_MEAN_VER_NR = vm.VER_NR
                              AND vm.ADMIN_ITEM_TYP_ID = 53)
                       AS MDSR_749_PV_VD_LIST_T)/*,
                                        CAST (
                                            MULTISET (
                                                  SELECT con.preferred_name,
                                                         con.long_name,
                                                         con.con_id,
                                                         con.definition_source,
                                                         con.origin,
                                                         con.evs_Source,
                                                         com.primary_flag_ind,
                                                         com.display_order
                                                    FROM component_concepts_ext com, concepts_ext con
                                                   WHERE     vd.condr_idseq = com.condr_IDSEQ(+)
                                                         AND com.con_idseq = con.con_idseq(+)
                                                ORDER BY display_order DESC) AS Concepts_list_t) */
                                                )
               "ValueDomain",
           CAST (
               MULTISET (
                   SELECT rd.ref_nm,
                          -- org.name,
                          rd.ref_nm,
                          ok.obj_key_desc,
                          rd.ref_desc,
                          rd.URL,
                          TO_CHAR (rd.lang_id),
                          rd.disp_ord
                     FROM REF rd, obj_key ok
                    WHERE     rd.REF_TYP_ID = ok.obj_key_id(+)
                          --, sbr.organizations org
                          AND de.item_id = rd.item_id
                          AND de.ver_nr = rd.ver_nr)
                   AS cdebrowser_rd_list_t)
               "ReferenceDocumentsList",
           CAST (
               MULTISET (
                   SELECT admin_component_with_id_t (csv.cs_item_id,
                                                     csv.cs_cntxt_nm,
                                                     csv.cs_cntxt_ver_nr,
                                                     csv.cs_item_nm,
                                                     csv.cs_ver_nr),
                          csv.csi_item_nm,
                          --        csv.csitl_name,
                          csv.csi_item_nm,
                          csv.csi_item_id,
                          csv.csi_ver_nr
                     FROM cdebrowser_cs_view csv
                    WHERE     de.item_id = csv.de_item_id
                          AND de.ver_nr = csv.de_ver_nr)
                   AS cdebrowser_csi_list_t)
               "ClassificationsList",
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
                   AS cdebrowser_altname_list_t)
               "AlternateNameList"
      FROM ADMIN_ITEM              ai,
           cdebrowser_de_dec_view  dec,
           admin_item              vdai,
           value_dom               vd,
           de                      de
     WHERE     ai.item_id = dec.de_id
           AND ai.ver_nr = dec.de_version
           AND ai.ADMIN_STUS_NM_DN NOT IN
                   ('RETIRED WITHDRAWN', 'RETIRED DELETED')
           AND ai.item_id = de.item_id
           AND ai.ver_nr = de.ver_nr
           AND ai.admin_item_typ_id = 4
           AND de.val_dom_item_id = vdai.item_id
           AND de.val_dom_ver_nr = vdai.ver_nr
           AND vdai.admin_item_typ_id = 3
           AND de.val_dom_item_id = vd.item_id
           AND de.val_dom_ver_nr = vd.ver_nr;


DROP VIEW ONEDATA_WA.DE_EXCEL_GENERATOR_VIEW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_EXCEL_GENERATOR_VIEW
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
           ai.ITEM_LONG_NM                                "PreferredName",
           ai.ITEM_NM                                     "LongName",
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
                   AS valid_value_list_t)                 valid_values,
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


DROP VIEW ONEDATA_WA.INSTALLED_COMPONENT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.INSTALLED_COMPONENT
(
    COMPONENT_CD,
    COMPONENT_LEVEL,
    COMPONENT_DESC,
    TABLESPACE_DATA,
    TABLESPACE_INDEX
)
BEQUEATH DEFINER
AS
    SELECT DISTINCT COMPONENT_CD,
                    COMPONENT_LEVEL,
                    COMPONENT_DESC,
                    TABLESPACE_DATA,
                    TABLESPACE_INDEX
      FROM COMPONENT_EVENT
     WHERE     COMPONENT_EVENT = 'INSTALL'
           AND COMPONENT_EVENT_ID NOT IN
                   (SELECT E1.COMPONENT_EVENT_ID
                      FROM COMPONENT_EVENT E1, COMPONENT_EVENT E2
                     WHERE     E1.COMPONENT_CD = E2.COMPONENT_CD
                           AND E1.COMPONENT_EVENT_ID < E2.COMPONENT_EVENT_ID);


DROP VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW
(
    "PreferredName",
    "Version",
    "ClassificationList"
)
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
                                                              v2.P_ITEM_ID,
                                                              v2.P_ITEM_VER_NR,
                                                              --                                                              v1.CSI_ID,
                                                              --                                                              v1.CSI_VERSION,
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
                                                                               v3.P_ITEM_ID,
                                                                               v3.P_ITEM_VER_NR,
                                                                               --                                                                               v2.CSI_ID,
                                                                               --                                                                               v2.CSI_VERSION,
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
                                                                                                v4.P_ITEM_ID,
                                                                                                v4.P_ITEM_VER_NR,
                                                                                                --                                                                                                v3.CSI_ID,
                                                                                                --                                                                                                v3.CSI_VERSION,
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
                                                                                                                 v5.P_ITEM_ID,
                                                                                                                 v5.P_ITEM_VER_NR,
                                                                                                                 --                                                                                                                 v4.CSI_ID,
                                                                                                                 --                                                                                                                 v4.CSI_VERSION,
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
                               FROM REL_CLASS_SCHEME_ITEM_VW) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                   ORDER BY CS_ID)
                   AS MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM REL_CLASS_SCHEME_ITEM_VW
            ORDER BY CS_CONTEXT_NAME) con;


DROP VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_2;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_2
(
    "PreferredName",
    "Version",
    "ClassificationList"
)
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
                                                              V1.CSI_IDSEQ,
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
                                                                               V2.CSI_IDSEQ,
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
                                                                                                V3.CSI_IDSEQ,
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
                                                                                                                 V4.CSI_IDSEQ,
                                                                                                                 v5.P_ITEM_ID,
                                                                                                                 v5.P_ITEM_VER_NR,
                                                                                                                 v4.CSI_VERSION,
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
                               FROM REL_CLASS_SCHEME_ITEM_VW) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                   ORDER BY CS_ID)
                   AS MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM REL_CLASS_SCHEME_ITEM_VW
            ORDER BY CS_CONTEXT_NAME) con;


DROP VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_N;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_N
(
    "PreferredName",
    "Version",
    "ClassificationList"
)
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
                               FROM REL_CLASS_SCHEME_ITEM_VW) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                   ORDER BY CS_ID)
                   AS MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM REL_CLASS_SCHEME_ITEM_VW
            ORDER BY CS_CONTEXT_NAME) con;


DROP VIEW ONEDATA_WA.NCI_CDE_EXCEL_GENERATOR_VIEW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.NCI_CDE_EXCEL_GENERATOR_VIEW
(
    NCI_IDSEQ,
    CDE_ID,
    LONG_NAME,
    PREFERRED_NAME,
    PREFERRED_DEFINITION,
    VERSION,
    ORIGIN,
    DE_CONTE_NAME,
    DEC_ID,
    DEC_PREFERRED_NAME,
    DEC_VERSION,
    VD_ID,
    VD_PREFERRED_NAME,
    VD_LONG_NM,
    VD_VERSION,
    VD_CONTE_NAME,
    VALID_VALUES,
    REFERENCE_DOCS
)
BEQUEATH DEFINER
AS
    SELECT de.nci_idseq,
           de.item_id                           cde_id,
           de.item_long_nm                      long_name,
           de.item_nm                           preferred_name,
           --rd.doc_text,
           de.item_desc                         preferred_definition,
           de.ver_nr                            version,
           de.origin,
           --            de.begin_date,
           de.cntxt_nm                          de_conte_name,
           --            de_conte.version de_conte_version,
           de.dec_item_id                       dec_id,
           dec.item_desc                        dec_preferred_name,
           dec.ver_nr                           dec_version,
           --            dec_conte.name dec_conte_name,
           --            dec_conte.version dec_conte_version,
           vd.item_id                           vd_id,
           vd.item_desc                         vd_preferred_name,
           vd.item_long_nm                      vd_long_nm,
           vd.ver_nr                            vd_version,
           vd.cntxt_nm                          vd_conte_name,
           CAST (
               MULTISET (
                   SELECT pv.VALUE,
                          vm.long_name     short_meaning,
                          vm.preferred_definition,
                          vm.vm_id,
                          vm.version
                     FROM perm_val pv, admin_item vm
                    WHERE     pv.val_dom_item_id = vd.item_id
                          AND pv.val_dom_ver_nr = vd.ver_nd
                          AND pv.NCI_VAL_MEAN_ITEM_ID = vm.item_id
                          AND pv.NCI_VAL_MEAN_VER_NR = vm.ver_nr)
                   AS DE_VALID_VALUE_LIST_T)    valid_values,
           CAST (
               MULTISET (
                   SELECT rd.ref_nm, --                                 rd.DCTL_NAME,
                                     rd.ref_desc, --                                rd.URL,
                                                  rd.disp_ord
                     FROM REF rd
                    WHERE     de.item_id = rd.item_id(+)
                          AND de.ver_nr = rd.ver_nr(+))
                   AS cdebrowser_rd_list_t)     reference_docs
      FROM admin_item  de,
           admin_item  dec,
           admin_item  vd,
           de          de1
     WHERE     de1.de_conc_item_id = dec.item_id
           AND de1.val_dom_item_id = vd.item_id
           AND de1.de_conc_ver_nr = dec.ver_nr
           AND de1.val_dom_ver_nr = vd.ver_nr
           AND de1.item_id = de.item_id
           AND de1.ver_nr = de.ver_nr;


DROP VIEW ONEDATA_WA.ONEDATA_CLASS_SCHEME_ITEM_VW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.ONEDATA_CLASS_SCHEME_ITEM_VW
(
    CS_ID,
    CS_VERSION,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    NCI_PUB_ID,
    NCI_VER_NR,
    CSI_ID,
    CSI_VERSION,
    CSITL_NAME,
    CSI_NAME,
    DESCRIPTION,
    CSI_CONTEXT_NAME,
    CSI_CONTEXT_VERSION,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    CSI_LEVEL,
    LEAF,
    P_CSI_ID,
    P_CSI_VERSION
)
BEQUEATH DEFINER
AS
    (    SELECT NODE.CNTXT_CS_ITEM_ID
                    CS_ID,
                NODE.CNTXT_CS_VER_NR
                    CS_VERSION,
                CS.ITEM_LONG_NM
                    PREFERRED_NAME,
                CS.ITEM_NM
                    LONG_NAME,
                CSI.ITEM_DESC
                    PREFERRED_DEFINITION,
                cs.ADMIN_STUS_NM_DN
                    ASL_NAME,
                CS.CNTXT_NM_DN
                    CS_CONTEXT_NAME,
                CS.CNTXT_VER_NR
                    CS_CONTEXT_VERSION,
                -- CONTE_IDSEQ,
                NODE.NCI_PUB_ID,
                NODE.NCI_VER_NR,
                NODE.C_ITEM_ID
                    CSI_ID,
                NODE.C_item_ver_nr
                    CSI_VERSION,
                O.NCI_CD
                    CSITL_NAME,
                -- CSI.ITEM_NM,
                CSI.ITEM_NM
                    CSI_NAME,
                CSI.ITEM_DESC
                    description,
                CSI.CNTXT_NM_DN
                    CSI_CONTEXT_NAME,
                CSI.CNTXT_VER_NR
                    CSI_CONTEXT_VERSION,
                CS.CREAT_DT
                    CS_DATE_CREATED,
                CSI.CREAT_DT
                    CSI_DATE_CREATED,
                LEVEL
                    CSI_LEVEL,
                DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                    "IsLeaf",
                NODE.P_ITEM_ID
                    P_CSI_ID,
                NODE.p_item_ver_nr
                    P_CSI_VERSION
           FROM (SELECT *
                   FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                  WHERE     rel_typ_id = 64
                        AND NCI_PUB_ID NOT IN (15999102, 15999103)) --NCI_ADMIN_ITEM_REL_ALT_KEY
                                                                    NODE,
                admin_item         CS,
                admin_item         CSI,
                NCI_CLSFCTN_SCHM_ITEM NCSI,
                OBJ_KEY            O
          WHERE     cs.ADMIN_ITEM_TYP_ID = 9
                AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
                AND csi.ADMIN_ITEM_TYP_ID = 51
                AND node.c_item_id = csi.item_id
                AND node.c_item_ver_nr = csi.ver_nr
                AND csi.item_id = ncsi.item_id
                AND csi.ver_nr = ncsi.ver_nr
                AND ncsi.CSI_TYP_ID = o.obj_key_id
                AND node.cntxt_cs_item_id = cs.item_id
                AND node.cntxt_cs_Ver_nr = cs.ver_nr
                AND node.rel_typ_id = 64
                AND INSTR (O.NCI_CD, 'testCaseMix') = 0
                -- AND C_ITEM_ID=3070841
                AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
                AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
     --   and ITEM_ID=5635383 --  CONNECT BY  NOCYCLE
     CONNECT BY     PRIOR C_ITEM_ID = P_ITEM_ID
                AND PRIOR C_ITEM_VER_NR = C_ITEM_VER_NR
                AND PRIOR CNTXT_CS_ITEM_ID = CNTXT_CS_ITEM_ID
                AND PRIOR CNTXT_CS_VER_NR = CNTXT_CS_VER_NR
                AND PRIOR NCI_PUB_ID(+) < > NCI_PUB_ID
     START WITH P_ITEM_ID IS NULL)
    UNION
    (    SELECT NODE.CNTXT_CS_ITEM_ID
                    CS_ID,
                NODE.CNTXT_CS_VER_NR
                    CS_VERSION,
                CS.ITEM_LONG_NM
                    PREFERRED_NAME,
                CS.ITEM_NM
                    LONG_NAME,
                CSI.ITEM_DESC
                    PREFERRED_DEFINITION,
                cs.ADMIN_STUS_NM_DN
                    ASL_NAME,
                CS.CNTXT_NM_DN
                    CS_CONTEXT_NAME,
                CS.CNTXT_VER_NR
                    CS_CONTEXT_VERSION,
                -- CONTE_IDSEQ,
                NODE.NCI_PUB_ID,
                NODE.NCI_VER_NR,
                NODE.C_ITEM_ID
                    CSI_ID,
                NODE.C_item_ver_nr
                    CSI_VERSION,
                O.NCI_CD
                    CSITL_NAME,
                -- CSI.ITEM_NM,
                CSI.ITEM_NM
                    CSI_NAME,
                CSI.ITEM_DESC
                    description,
                CSI.CNTXT_NM_DN
                    CSI_CONTEXT_NAME,
                CSI.CNTXT_VER_NR
                    CSI_CONTEXT_VERSION,
                CS.CREAT_DT
                    CS_DATE_CREATED,
                CSI.CREAT_DT
                    CSI_DATE_CREATED,
                LEVEL
                    CSI_LEVEL,
                DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                    "IsLeaf",
                NODE.P_ITEM_ID
                    P_CSI_ID,
                NODE.p_item_ver_nr
                    P_CSI_VERSION
           FROM (SELECT *
                   FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                  WHERE     rel_typ_id = 64
                        AND NCI_PUB_ID IN (15999000,
                                           15999037,
                                           16000083,
                                           16001094,
                                           15999102,
                                           15999103)) --NCI_ADMIN_ITEM_REL_ALT_KEY
                                                      NODE,
                admin_item         CS,
                admin_item         CSI,
                NCI_CLSFCTN_SCHM_ITEM NCSI,
                OBJ_KEY            O
          WHERE     cs.ADMIN_ITEM_TYP_ID = 9
                AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
                AND csi.ADMIN_ITEM_TYP_ID = 51
                AND node.c_item_id = csi.item_id
                AND node.c_item_ver_nr = csi.ver_nr
                AND csi.item_id = ncsi.item_id
                AND csi.ver_nr = ncsi.ver_nr
                AND ncsi.CSI_TYP_ID = o.obj_key_id
                AND node.cntxt_cs_item_id = cs.item_id
                AND node.cntxt_cs_Ver_nr = cs.ver_nr
                AND node.rel_typ_id = 64
                AND INSTR (O.NCI_CD, 'testCaseMix') = 0
                -- AND C_ITEM_ID=3070841
                AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
                AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
     --   and ITEM_ID=5635383 --  CONNECT BY  NOCYCLE
     CONNECT BY     PRIOR C_ITEM_ID = P_ITEM_ID
                AND PRIOR C_ITEM_VER_NR = C_ITEM_VER_NR
                AND PRIOR CNTXT_CS_ITEM_ID = CNTXT_CS_ITEM_ID
                AND PRIOR CNTXT_CS_VER_NR = CNTXT_CS_VER_NR
                AND PRIOR NCI_PUB_ID(+) < > NCI_PUB_ID
     START WITH P_ITEM_ID IS NULL);


DROP VIEW ONEDATA_WA.ONEDATA_CLASS_SCHEME_ITEM_VW_OLD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.ONEDATA_CLASS_SCHEME_ITEM_VW_OLD
(
    CS_ID,
    CS_VERSION,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    NCI_PUB_ID,
    NCI_VER_NR,
    CSI_ID,
    CSI_VERSION,
    CSITL_NAME,
    CSI_NAME,
    DESCRIPTION,
    CSI_CONTEXT_NAME,
    CSI_CONTEXT_VERSION,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    CSI_LEVEL,
    LEAF,
    P_CSI_ID,
    P_CSI_VERSION
)
BEQUEATH DEFINER
AS
    (    SELECT NODE.CNTXT_CS_ITEM_ID
                    CS_ID,
                NODE.CNTXT_CS_VER_NR
                    CS_VERSION,
                CS.ITEM_LONG_NM
                    PREFERRED_NAME,
                CS.ITEM_NM
                    LONG_NAME,
                CSI.ITEM_DESC
                    PREFERRED_DEFINITION,
                cs.ADMIN_STUS_NM_DN
                    ASL_NAME,
                CS.CNTXT_NM_DN
                    CS_CONTEXT_NAME,
                CS.CNTXT_VER_NR
                    CS_CONTEXT_VERSION,
                -- CONTE_IDSEQ,
                NODE.NCI_PUB_ID,
                NODE.NCI_VER_NR,
                NODE.C_ITEM_ID
                    CSI_ID,
                NODE.C_item_ver_nr
                    CSI_VERSION,
                O.NCI_CD
                    CSITL_NAME,
                -- CSI.ITEM_NM,
                CSI.ITEM_NM
                    CSI_NAME,
                CSI.ITEM_DESC
                    description,
                CSI.CNTXT_NM_DN
                    CSI_CONTEXT_NAME,
                CSI.CNTXT_VER_NR
                    CSI_CONTEXT_VERSION,
                CS.CREAT_DT
                    CS_DATE_CREATED,
                CSI.CREAT_DT
                    CSI_DATE_CREATED,
                LEVEL
                    CSI_LEVEL,
                DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                    "IsLeaf",
                NODE.P_ITEM_ID
                    P_CSI_ID,
                NODE.p_item_ver_nr
                    P_CSI_VERSION
           FROM NCI_ADMIN_ITEM_REL_ALT_KEY NODE,
                admin_item              CS,
                admin_item              CSI,
                NCI_CLSFCTN_SCHM_ITEM   NCSI,
                OBJ_KEY                 O
          WHERE     cs.ADMIN_ITEM_TYP_ID = 9
                AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
                AND csi.ADMIN_ITEM_TYP_ID = 51
                AND node.c_item_id = csi.item_id
                AND node.c_item_ver_nr = csi.ver_nr
                AND csi.item_id = ncsi.item_id
                AND csi.ver_nr = ncsi.ver_nr
                AND ncsi.CSI_TYP_ID = o.obj_key_id
                AND node.cntxt_cs_item_id = cs.item_id
                AND node.cntxt_cs_Ver_nr = cs.ver_nr
                AND node.rel_typ_id = 64
                AND INSTR (O.NCI_CD, 'testCaseMix') = 0
                -- AND C_ITEM_ID=3070841
                AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
                AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
     --   and ITEM_ID=5635383 --  CONNECT BY  NOCYCLE
     CONNECT BY     PRIOR C_ITEM_ID = P_ITEM_ID
                AND PRIOR C_ITEM_VER_NR = C_ITEM_VER_NR
                AND PRIOR CNTXT_CS_ITEM_ID = CNTXT_CS_ITEM_ID
                AND PRIOR CNTXT_CS_VER_NR = CNTXT_CS_VER_NR
                AND PRIOR NCI_PUB_ID(+) < > NCI_PUB_ID
     START WITH P_ITEM_ID IS NULL)
    ORDER BY P_ITEM_ID, LEVEL, CNTXT_CS_ITEM_ID;


DROP VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
(
    CS_ID,
    CS_VERSION,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    CSITL_NAME,
    CSI_ID,
    CSI_VERSION,
    CSI_NAME,
    DESCRIPTION,
    CSI_CONTEXT_NAME,
    CSI_CONTEXT_VERSION,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CSI_LEVEL,
    LEAF,
    CS_IDSEQ,
    CSI_IDSEQ,
    CS_CONTEXT_ID,
    CSI_CONTEXT_ID,
    CS_CSI_IDSEQ
)
BEQUEATH DEFINER
AS
        SELECT NODE.CS_ITEM_ID
                   CS_ID,
               NODE.CS_ITEM_VER_NR
                   CS_VERSION,
               CS.ITEM_LONG_NM
                   PREFERRED_NAME,
               CS.ITEM_NM
                   LONG_NAME,
               CS.ITEM_DESC
                   PREFERRED_DEFINITION,
               cs.ADMIN_STUS_NM_DN
                   ASL_NAME,
               CS.CNTXT_NM_DN
                   CS_CONTEXT_NAME,
               CS.CNTXT_VER_NR
                   CS_CONTEXT_VERSION,
               O.NCI_CD
                   CSITL_NAME,
               -- CSI.ITEM_NM,
               CSI.ITEM_ID
                   CSI_ID,
               CSI.VER_NR
                   CSI_VERSION,
               CSI.ITEM_NM
                   CSI_NAME,
               CSI.ITEM_DESC
                   description,
               CSI.CNTXT_NM_DN
                   CSI_CONTEXT_NAME,
               CSI.CNTXT_VER_NR
                   CSI_CONTEXT_VERSION,
               CS.CREAT_DT
                   CS_DATE_CREATED,
               CSI.CREAT_DT
                   CSI_DATE_CREATED,
               NODE.P_ITEM_ID,
               NODE.P_ITEM_VER_NR,
               LEVEL
                   CSI_LEVEL,
               DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                   "IsLeaf",
               CS.NCI_IDSEQ
                   CS_IDSEQ,
               CSI.NCI_IDSEQ
                   CSI_IDSEQ,
               cs.CNTXT_ITEM_ID
                   CS_CONTEXT_ID,
               csi.CNTXT_ITEM_ID
                   CSI_CONTEXT_ID,
               NODE.CS_CSI_IDSEQ
          FROM admin_item         CS,
               admin_item         CSI,
               NCI_CLSFCTN_SCHM_ITEM NODE,
               OBJ_KEY            O
         WHERE     cs.ADMIN_ITEM_TYP_ID = 9
               AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
               AND csi.ADMIN_ITEM_TYP_ID = 51
               AND node.item_id = csi.item_id
               AND node.ver_nr = csi.ver_nr
               AND node.CSI_TYP_ID = o.obj_key_id
               AND node.cs_item_id = cs.item_id
               AND node.CS_ITEM_VER_NR = cs.ver_nr
               AND INSTR (O.NCI_CD, 'testCaseMix') = 0
               -- AND NODE.ITEM_ID=3070841
               AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
               AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
    CONNECT BY     PRIOR node.item_id = node.P_ITEM_ID
               AND node.ver_nr = node.P_ITEM_VER_NR
    START WITH node.P_ITEM_ID IS NULL
      ORDER BY CS_ITEM_ID, node.ITEM_ID, P_ITEM_ID;


DROP VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW_OLD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW_OLD
(
    CS_ID,
    CS_VERSION,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    NCI_PUB_ID,
    NCI_VER_NR,
    CSI_ID,
    CSI_VERSION,
    CSITL_NAME,
    CSI_NAME,
    DESCRIPTION,
    CSI_CONTEXT_NAME,
    CSI_CONTEXT_VERSION,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    P_CSI_ID,
    P_CSI_VERSION,
    NCI_IDSEQ,
    CSI_LEVEL,
    LEAF,
    CS_CSI_IDSEQ,
    PARENT_CSI_IDSEQ,
    PARENT_PUB_ID,
    PARENT_PUB_VER,
    CS_CONTEXT_ID,
    CSI_CONTEXT_ID
)
BEQUEATH DEFINER
AS
        SELECT NODE.CNTXT_CS_ITEM_ID
                   CS_ID,
               NODE.CNTXT_CS_VER_NR
                   CS_VERSION,
               CS.ITEM_LONG_NM
                   PREFERRED_NAME,
               CS.ITEM_NM
                   LONG_NAME,
               CSI.ITEM_DESC
                   PREFERRED_DEFINITION,
               cs.ADMIN_STUS_NM_DN
                   ASL_NAME,
               CS.CNTXT_NM_DN
                   CS_CONTEXT_NAME,
               CS.CNTXT_VER_NR
                   CS_CONTEXT_VERSION,
               -- CONTE_IDSEQ,
               NODE.NCI_PUB_ID,
               NODE.NCI_VER_NR,
               NODE.C_ITEM_ID
                   CSI_ID,
               NODE.C_item_ver_nr
                   CSI_VERSION,
               O.NCI_CD
                   CSITL_NAME,
               -- CSI.ITEM_NM,
               CSI.ITEM_NM
                   CSI_NAME,
               CSI.ITEM_DESC
                   description,
               CSI.CNTXT_NM_DN
                   CSI_CONTEXT_NAME,
               CSI.CNTXT_VER_NR
                   CSI_CONTEXT_VERSION,
               CS.CREAT_DT
                   CS_DATE_CREATED,
               CSI.CREAT_DT
                   CSI_DATE_CREATED,
               --  LEVEL CSI_LEVEL,
               -- DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE') "IsLeaf",
               NODE.P_ITEM_ID
                   P_CSI_ID,
               NODE.p_item_ver_nr
                   P_CSI_VERSION,
               NODE.NCI_IDSEQ,
               LEVEL
                   CSI_LEVEL,
               DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                   "IsLeaf",
               P.CS_CSI_IDSEQ,
               P_CS_CSI_IDSEQ,
               P_NCI_PUB_ID,
               P_NCI_PUB_VER_NM,
               cs.CNTXT_ITEM_ID
                   CS_CONTEXT_ID,
               csi.CNTXT_ITEM_ID
                   CSI_CONTEXT_ID
          FROM NCI_ADMIN_ITEM_REL_ALT_KEY NODE,
               admin_item              CS,
               admin_item              CSI,
               NCI_CLSFCTN_SCHM_ITEM   NCSI,
               OBJ_KEY                 O,
               PC_CS_CSI               p
         WHERE     cs.ADMIN_ITEM_TYP_ID = 9
               AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
               AND csi.ADMIN_ITEM_TYP_ID = 51
               AND node.c_item_id = csi.item_id
               AND node.c_item_ver_nr = csi.ver_nr
               AND csi.item_id = ncsi.item_id
               AND csi.ver_nr = ncsi.ver_nr
               AND ncsi.CSI_TYP_ID = o.obj_key_id
               AND node.cntxt_cs_item_id = cs.item_id
               AND node.cntxt_cs_Ver_nr = cs.ver_nr
               AND node.rel_typ_id = 64
               AND INSTR (O.NCI_CD, 'testCaseMix') = 0
               --  AND C_ITEM_ID=3070841
               AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
               AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
               AND NODE.NCI_IDSEQ = P.CS_CSI_IDSEQ
    CONNECT BY PRIOR CS_CSI_IDSEQ = P_CS_CSI_IDSEQ
    START WITH P_CS_CSI_IDSEQ IS NULL
      ORDER BY CNTXT_CS_ITEM_ID, C_ITEM_ID, P_ITEM_ID             --,LEVEL ,;
;


DROP VIEW ONEDATA_WA.SBREXT_MDSR_CLASS_SCHEME_ITEM_VW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.SBREXT_MDSR_CLASS_SCHEME_ITEM_VW
(
    CS_IDSEQ,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    VERSION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    CONTE_IDSEQ,
    CSI_NAME,
    CSITL_NAME,
    DESCRIPTION,
    CSI_ID,
    CSI_VERSION,
    CSI_IDSEQ,
    CSI_CONTEXT_NAME,
    CS_ID,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    CS_CSI_IDSEQ,
    CSI_LEVEL,
    LEAF,
    PARENT_CSI_IDSEQ
)
BEQUEATH DEFINER
AS
    (    SELECT cs.cs_idseq,
                cs.preferred_name,
                cs.long_name,
                cs.preferred_definition,
                cs.version,
                cs.asl_name,
                cs_conte.name
                    cs_context_name,
                cs_conte.version
                    cs_context_version,
                cs.conte_idseq
                    conte_idseq,
                csi.long_name
                    csi_name,
                csi.csitl_name,
                csi.preferred_definition
                    description,
                csi.csi_id,
                csi.version
                    csi_version,
                csi.CSI_IDSEQ,
                csi_conte.name
                    csi_context_name,
                cs.cs_id,
                cs.date_created
                    cs_date_created,
                csi.date_created
                    csi_date_created,
                CS_CSI_IDSEQ,
                LEVEL,
                DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                    "IsLeaf",
                p_cs_csi_idseq
           FROM sbr.classification_schemes cs,
                sbr.cs_items            csi,
                sbr.cs_csi              csc,
                sbr.contexts            cs_conte,
                sbr.contexts            csi_conte
          WHERE     csc.cs_idseq = cs.cs_idseq
                AND csc.csi_idseq = csi.csi_idseq
                AND cs.conte_idseq = cs_conte.conte_idseq
                AND csi.conte_idseq = csi_conte.conte_idseq
                AND INSTR (csi.CSITL_NAME, 'testCaseMix') = 0
                AND csi_conte.name NOT IN ('TEST', 'Training')
                AND cs_conte.name NOT IN ('TEST', 'Training')
                AND cs.ASL_NAME = 'RELEASED'
     CONNECT BY PRIOR CS_CSI_IDSEQ = P_CS_CSI_IDSEQ
     START WITH P_CS_CSI_IDSEQ IS NULL);


DROP VIEW ONEDATA_WA.VALUE_DOMAINS_VIEW;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VALUE_DOMAINS_VIEW
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


DROP VIEW ONEDATA_WA.VW_ADMIN_ITEM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ADMIN_ITEM
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CLSFCTN_SCHM_ID,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    DATA_ID_STR,
    CLSFCTN_SCHM_VER_NR,
    ADMIN_ITEM_TYP_ID,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    STEWRD_CNTCT_ID,
    SUBMT_CNTCT_ID,
    REGISTRR_CNTCT_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    LEGCY_CD,
    CASE_FILE_ID,
    STEWRD_ORG_ID,
    SUBMT_ORG_ID,
    REGSTR_AUTH_ID,
    BTCH_NR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CLSFCTN_SCHM_ID,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.DATA_ID_STR,
           ADMIN_ITEM.CLSFCTN_SCHM_VER_NR,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.LEGCY_CD,
           ADMIN_ITEM.CASE_FILE_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.BTCH_NR
      FROM ADMIN_ITEM;


DROP VIEW ONEDATA_WA.VW_ADMIN_ITEM_GLBL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ADMIN_ITEM_GLBL
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNTL_DT,
    DATA_ID_STR,
    CLSFCTN_SCHM_VER_NR,
    ADMIN_ITEM_TYP_ID,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    STEWRD_ORG_ID,
    SUBMT_ORG_ID,
    STEWRD_CNTCT_ID,
    SUBMT_CNTCT_ID,
    REGISTRR_CNTCT_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    LEGCY_CD,
    CASE_FILE_ID,
    REGSTR_AUTH_ID,
    BTCH_NR,
    ALT_KEY,
    ITEM_NM_WITH_ID,
    ITEM_NM_WITH_CNTXT,
    CNTXT_NM,
    ITEM_NM_WITH_VER,
    ITEM_NM_WITH_TYPE_ID
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.DATA_ID_STR,
           ADMIN_ITEM.CLSFCTN_SCHM_VER_NR,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.LEGCY_CD,
           ADMIN_ITEM.CASE_FILE_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.BTCH_NR,
           ADMIN_ITEM.ALT_KEY,
           ADMIN_ITEM.ITEM_NM || ' (' || ADMIN_ITEM.ALT_KEY || ')',
              ADMIN_ITEM.ITEM_NM
           || ' ('
           || CNTXT.ITEM_NM
           || ' /  Ver: '
           || ADMIN_ITEM.VER_NR
           || ')',
           CNTXT.ITEM_NM,
           ADMIN_ITEM.ITEM_NM || ' (Ver: ' || ADMIN_ITEM.VER_NR || ')',
              ADMIN_ITEM.ITEM_NM
           || ' ('
           || ADMIN_ITEM.ALT_KEY
           || '/'
           || OBJ_KEY_DESC
           || ')'
      FROM ADMIN_ITEM, ADMIN_ITEM CNTXT, OBJ_KEY
     WHERE     ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID(+)
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR(+)
           AND ADMIN_ITEM.ADMIN_ITEM_TYP_ID = OBJ_KEY.OBJ_KEY_ID;


DROP VIEW ONEDATA_WA.VW_ADMIN_STUS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ADMIN_STUS
(
    STUS_ID,
    STUS_NM,
    STUS_DESC,
    STUS_TYP_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    STUS_MSK,
    STUS_ACRO,
    NCI_STUS,
    NCI_CMNTS,
    NCI_DISP_ORDR
)
BEQUEATH DEFINER
AS
    SELECT "STUS_ID",
           "STUS_NM",
           "STUS_DESC",
           "STUS_TYP_ID",
           "CREAT_DT",
           "CREAT_USR_ID",
           "LST_UPD_USR_ID",
           "FLD_DELETE",
           "LST_DEL_DT",
           "S2P_TRN_DT",
           "LST_UPD_DT",
           "STUS_MSK",
           "STUS_ACRO",
           "NCI_STUS",
           "NCI_CMNTS",
           "NCI_DISP_ORDR"
      FROM STUS_MSTR
     WHERE STUS_TYP_ID = 2;


DROP VIEW ONEDATA_WA.VW_ADMIN_STUS_RUL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ADMIN_STUS_RUL
(
    FROM_STUS_ID,
    TO_STUS_ID,
    REQ_COL_DESC,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REGIST_RUL_ID,
    USR_GRP_ID,
    STUS_TYP_ID
)
BEQUEATH DEFINER
AS
    SELECT REGIST_RUL.FROM_STUS_ID,
           REGIST_RUL.TO_STUS_ID,
           REGIST_RUL.REQ_COL_DESC,
           REGIST_RUL.CREAT_DT,
           REGIST_RUL.CREAT_USR_ID,
           REGIST_RUL.LST_UPD_USR_ID,
           REGIST_RUL.FLD_DELETE,
           REGIST_RUL.LST_DEL_DT,
           REGIST_RUL.S2P_TRN_DT,
           REGIST_RUL.LST_UPD_DT,
           REGIST_RUL.REGIST_RUL_ID,
           REGIST_RUL.USR_GRP_ID,
           REGIST_RUL.STUS_TYP_ID
      FROM REGIST_RUL
     WHERE stus_typ_Id = 2;


DROP VIEW ONEDATA_WA.VW_AI_CSI;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_AI_CSI
(
    ITEM_ID,
    VER_NR,
    CLSFCTN_SCHM_ITEM_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM_CLSFCTN_SCHM_ITEM.ITEM_ID,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.VER_NR,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.CLSFCTN_SCHM_ITEM_ID,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.CREAT_DT,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.CREAT_USR_ID,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.FLD_DELETE,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.LST_DEL_DT,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.S2P_TRN_DT,
           ADMIN_ITEM_CLSFCTN_SCHM_ITEM.LST_UPD_DT
      FROM ADMIN_ITEM_CLSFCTN_SCHM_ITEM;


DROP VIEW ONEDATA_WA.VW_ALS_CDE_VD_PV_RAW_DATA;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_CDE_VD_PV_RAW_DATA
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
    VD_DISPLAY_FORMAT,
    PV_VALUE,
    VM_LONG_NAME,
    VM_ID,
    VM_VERSION
)
BEQUEATH DEFINER
AS
      SELECT h.HDR_ID                                        COLLECT_ID,
             h.DLOAD_TYP_ID                                  COLLECT_TYPE,
             H.DLOAD_HDR_NM                                  COLLECT_NAME,
             DE.ITEM_ID                                      DE_PUB_ID,
             DE.VER_NR                                       DE_VERSION,
             CDE.ITEM_NM                                     DE_Long_Name,
             CDE.ITEM_LONG_NM                                DE_Short_Name,
             REF.ref_desc                                    Preferred_Question,
             VALUE_DOM.ITEM_ID                               VD_ID,
             VALUE_DOM.VER_NR                                VD_VERSION,
             VD.ITEM_LONG_NM                                 VD_Short_Name,
             VD.ITEM_NM                                      VD_Long_Name,
             DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')     VAL_DOM_TYP_ID,
             dt.NCI_CD                                       VD_DATA_TYPE_NCI,
             dt.NCI_DTTYPE_MAP                               VD_DATA_TYPE_MAP,
             VALUE_DOM.VAL_DOM_MAX_CHAR,
             VALUE_DOM.VAL_DOM_HIGH_VAL_NUM                  VD_Maximum_Length,
             FMT.FMT_NM                                      VD_Display_Format,
             PERM_VAL.PERM_VAL_NM                            PV_Value,
             VM.ITEM_NM                                      VM_Long_Name,
             PERM_VAL.NCI_VAL_MEAN_ITEM_ID                   VM_ID,
             PERM_VAL.NCI_VAL_MEAN_VER_NR                    VM_Version
        FROM de           DE,
             ADMIN_ITEM   CDE,
             VALUE_DOM,
             ADMIN_ITEM   VD,
             ADMIN_ITEM   VM,
             PERM_VAL,
             FMT,
             DATA_TYP     DT,
             (SELECT item_id, ver_nr, ref_desc
                FROM REF
               WHERE ref_typ_id = 80) REF,
             NCI_DLOAD_DTL ALS,
             NCI_DLOAD_HDR H
       WHERE     CDE.ITEM_ID = ALS.ITEM_ID
             AND CDE.VER_NR = ALS.VER_NR
             AND h.HDR_ID = ALS.HDR_ID
             AND h.DLOAD_TYP_ID = 93
             AND VD.ADMIN_ITEM_TYP_ID = 3
             AND CDE.ADMIN_ITEM_TYP_ID = 4
             AND VM.ADMIN_ITEM_TYP_ID = 53                   --(Value Meaning)
             AND CDE.ITEM_ID = DE.ITEM_ID
             AND CDE.VER_NR = DE.VER_NR
             AND de.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
             AND de.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
             AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
             AND VD.VER_NR = VALUE_DOM.VER_NR
             AND VD.ITEM_ID = PERM_VAL.VAL_DOM_ITEM_ID
             AND VD.VER_NR = PERM_VAL.VAL_DOM_VER_NR
             AND VALUE_DOM.dttype_id = DT.dttype_id
             AND VM.ITEM_ID = PERM_VAL.NCI_VAL_MEAN_ITEM_ID(+)
             AND VM.VER_NR = PERM_VAL.NCI_VAL_MEAN_VER_NR(+)
             AND CDE.ITEM_ID = REF.ITEM_ID(+)
             AND CDE.VER_NR = REF.VER_NR(+)
             AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
    ORDER BY h.HDR_ID,
             DE_PUB_ID,
             DE_VERSION,
             PERM_VAL.PERM_VAL_NM;


DROP VIEW ONEDATA_WA.VW_ALS_CDE_VD_PV_RAW_DATA_DD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
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
    VD_DISPLAY_FORMAT,
    PV_VALUE,
    VM_LONG_NAME,
    VM_ID,
    VM_VERSION
)
BEQUEATH DEFINER
AS
    SELECT h.HDR_ID             COLLECT_ID,
           h.DLOAD_TYP_ID       COLLECT_TYPE,
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
           NULL                 VD_Display_Format,
           NULL                 PV_Value,
           NULL                 VM_Long_Name,
           NULL                 VM_ID,
           NULL                 VM_Version
      FROM ADMIN_ITEM CDE, NCI_DLOAD_DTL ALS, NCI_DLOAD_HDR H
     WHERE     CDE.ITEM_ID = ALS.ITEM_ID
           AND CDE.VER_NR = ALS.VER_NR
           AND h.HDR_ID = ALS.HDR_ID
           AND h.DLOAD_TYP_ID = 93
    UNION
    SELECT h.HDR_ID                                        COLLECT_ID,
           h.DLOAD_TYP_ID                                  COLLECT_TYPE,
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
           FMT.FMT_NM                                      VD_Display_Format,
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
           FMT,
           DATA_TYP       DT,
           NCI_DLOAD_DTL  ALS,
           NCI_DLOAD_HDR  H
     WHERE     CDE.ITEM_ID = ALS.ITEM_ID
           AND CDE.VER_NR = ALS.VER_NR
           AND h.HDR_ID = ALS.HDR_ID
           AND h.DLOAD_TYP_ID = 93
           AND VD.ADMIN_ITEM_TYP_ID = 3
           AND CDE.ADMIN_ITEM_TYP_ID = 4
           -- AND VM.ADMIN_ITEM_TYP_ID = 53                   --(Value Meaning)
           AND CDE.ITEM_ID = DE.ITEM_ID
           AND CDE.VER_NR = DE.VER_NR
           AND de.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND de.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
           AND VD.VER_NR = VALUE_DOM.VER_NR
           AND VD.ITEM_ID = PVM.VAL_DOM_ITEM_ID(+)
           AND VD.VER_NR = PVM.VAL_DOM_VER_NR(+)
           AND VALUE_DOM.dttype_id = DT.dttype_id
           AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
    ORDER BY COLLECT_ID, DE_PUB_ID, DE_VERSION;


DROP VIEW ONEDATA_WA.VW_ALS_CDE_VD_RAW_DATA;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_CDE_VD_RAW_DATA
(
    DE_PUB_ID,
    DE_VERSION,
    DE_LONG_NAME,
    PREFERRED_QUESTION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    VAL_DOM_TYP_ID,
    VAL_DOM_MAX_CHAR,
    VD_MAXIMUM_LENGTH,
    VD_DISPLAY_FORMAT
)
BEQUEATH DEFINER
AS
      SELECT DE.ITEM_ID                                      DE_PUB_ID,
             DE.VER_NR                                       DE_VERSION,
             CDE.ITEM_NM                                     DE_Long_Name,
             REF.ref_desc                                    Preferred_Question,
             VD.ITEM_NM                                      VD_Long_Name,
             VALUE_DOM.ITEM_ID                               VD_ID,
             VALUE_DOM.VER_NR                                VD_VERSION,
             DECODE (VAL_DOM_TYP_ID,  17, 'E',  18, 'N')     VAL_DOM_TYP_ID,
             VALUE_DOM.VAL_DOM_MAX_CHAR,
             VALUE_DOM.VAL_DOM_HIGH_VAL_NUM                  VD_Maximum_Length,
             FMT.FMT_NM                                      VD_Display_Format
        FROM de        DE,
             ADMIN_ITEM CDE,
             VALUE_DOM,
             ADMIN_ITEM VD,
             FMT,
             (SELECT item_id, ver_nr, ref_desc
                FROM REF
               WHERE ref_typ_id = 80) REF
       WHERE     VD.ADMIN_ITEM_TYP_ID = 3
             AND CDE.ADMIN_ITEM_TYP_ID = 4
             AND CDE.ITEM_ID = DE.ITEM_ID
             AND CDE.VER_NR = DE.VER_NR
             AND de.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
             AND de.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
             AND VD.ITEM_ID = VALUE_DOM.ITEM_ID
             AND VD.VER_NR = VALUE_DOM.VER_NR
             AND CDE.ITEM_ID = REF.ITEM_ID(+)
             AND CDE.VER_NR = REF.VER_NR(+)
             AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
    ORDER BY DE_PUB_ID, DE_VERSION;


DROP VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD
(
    COLLECT_ID,
    COLLECT_TYPE,
    COLLECT_NAME,
    PROTOCOL,
    FORM_ID,
    FORM_VERSION,
    FORM_LONG_NAME,
    CDE_SHORT_NAME,
    CDE_LONG_NAME,
    DE_PUB_ID,
    DE_VERSION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    MODULE_DISPLAY_ORDER,
    GR_QVV_VALUE,
    VV_NUMBERS_IN_QUEST,
    VAL_DOM_TYP_ID,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VD_DISPLAY_FORMAT,
    VAL_DOM_MAX_CHAR,
    QUEST_ID,
    QUEST_VERSION,
    QUEST_LONG_NAME,
    QUEST_SHORT_NAME,
    QUEST_DISP_ORD,
    QUEST_INSTR,
    VV_ID,
    VV_VRERSION,
    VALID_VALUE,
    VV_VM_DEFOLD,
    VV_VM_DEF,
    VV_DESC_TXT,
    VV_DISP_ORD,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR
)
BEQUEATH DEFINER
AS
      SELECT h.HDR_ID           COLLECT_ID,
             h.DLOAD_TYP_ID     COLLECT_TYPE,
             H.DLOAD_HDR_NM     COLLECT_NAME,
             PROTOCOL,
             FORM_ID,
             FORM_VERSION,
             Form_Long_Name,
             CDE_SHORT_NAME,
             CDE_LONG_NAME,
             DE_PUB_ID,
             DE_VERSION,
             VD_LONG_NAME,
             VD_ID,
             VD_Version,
             MODULE_DISPLAY_ORDER,
             GR_QVV_VALUE,
             QVV.max_vv         VV_NUMBERS_IN_QUEST,
             VAL_DOM_TYP_ID,
             VD_DATA_TYPE_NCI,
             VD_DATA_TYPE_MAP,
             VD_DISPLAY_FORMAT,
             VAL_DOM_MAX_CHAR,
             QUEST_ID,
             QUEST_VERSION,
             QUEST_LONG_NAME,
             QUEST_SHORT_NAME,
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
             VAL_MEAN_VER_NR
        FROM VW_ALS_FIELD_RAW_DATA VW,
             (  SELECT Q_PUB_ID,
                       Q_VER_NR,
                       LISTAGG (DISP_ORD || '.' || VALUE,
                                '||'
                                ON OVERFLOW TRUNCATE)
                       WITHIN GROUP (ORDER BY DISP_ORD)    GR_QVV_VALUE,
                       COUNT (DISP_ORD)                    max_VV
                  FROM NCI_QUEST_VALID_VALUE
              GROUP BY Q_PUB_ID, Q_VER_NR) QVV,
             NCI_QUEST_VALID_VALUE VV,
             NCI_DLOAD_DTL        ALS,
             NCI_DLOAD_HDR        H
       WHERE     FORM_ID = ALS.ITEM_ID
             AND Form_Version = ALS.VER_NR
             AND h.HDR_ID = ALS.HDR_ID
             AND h.DLOAD_TYP_ID = 92
             AND QUEST_ID = QVV.Q_PUB_ID(+)
             AND QUEST_VERSION = QVV.Q_VER_NR(+)
             AND QUEST_VERSION = VV.Q_VER_NR(+)
             AND QUEST_ID = VV.Q_PUB_ID(+)
    -- and h.HDR_ID='1140'
    ORDER BY h.HDR_ID,
             Form_ID,
             MODULE_DISPLAY_ORDER NULLS FIRST,
             VD_ID,
             GR_QVV_VALUE NULLS FIRST,
             QUEST_DISP_ORD DESC,
             VV.DISP_ORD;


DROP VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD1;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD1
(
    COLLECT_ID,
    COLLECT_TYPE,
    COLLECT_NAME,
    PROTOCOL,
    FORM_ID,
    FORM_VERSION,
    FORM_LONG_NAME,
    CDE_SHORT_NAME,
    CDE_LONG_NAME,
    DE_PUB_ID,
    DE_VERSION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR,
    MODULE_DISPLAY_ORDER,
    GR_QVV_VALUE,
    VV_NUMBERS_IN_QUEST,
    VAL_DOM_TYP_ID,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VD_DISPLAY_FORMAT,
    VAL_DOM_MAX_CHAR,
    QUEST_ID,
    QUEST_VERSION,
    QUEST_LONG_NAME,
    QUEST_SHORT_NAME,
    QUEST_DISP_ORD,
    QUEST_INSTR,
    VV_ID,
    VV_VRERSION,
    VALID_VALUE,
    VV_VM_DEF,
    VV_DESC_TXT,
    VV_DISP_ORD
)
BEQUEATH DEFINER
AS
      SELECT h.HDR_ID           COLLECT_ID,
             h.DLOAD_TYP_ID     COLLECT_TYPE,
             H.DLOAD_HDR_NM     COLLECT_NAME,
             PROTOCOL,
             FORM_ID,
             FORM_VERSION,
             Form_Long_Name,
             CDE_SHORT_NAME,
             CDE_LONG_NAME,
             DE_PUB_ID,
             DE_VERSION,
             VD_LONG_NAME,
             VD_ID,
             VD_Version,
             vv.val_mean_item_id,
             vv.val_mean_ver_nr,
             MODULE_DISPLAY_ORDER,
             GR_QVV_VALUE,
             QVV.max_vv         VV_NUMBERS_IN_QUEST,
             VAL_DOM_TYP_ID,
             VD_DATA_TYPE_NCI,
             VD_DATA_TYPE_MAP,
             VD_DISPLAY_FORMAT,
             VAL_DOM_MAX_CHAR,
             QUEST_ID,
             QUEST_VERSION,
             QUEST_LONG_NAME,
             QUEST_SHORT_NAME,
             QUEST_DISP_ORD,
             QUEST_INSTR,
             VV.NCI_PUB_ID      VV_ID,
             VV.NCI_VER_NR      VV_VRERSION,
             VV.VALUE           VALID_VALUE,
             VV.VM_DEF          VV_VM_DEF,
             VV.DESC_TXT        VV_DESC_TXT,
             VV.DISP_ORD        VV_DISP_ORD
        FROM VW_ALS_FIELD_RAW_DATA VW,
             (  SELECT Q_PUB_ID,
                       Q_VER_NR,
                       LISTAGG (DISP_ORD || '.' || VALUE,
                                '||'
                                ON OVERFLOW TRUNCATE)
                       WITHIN GROUP (ORDER BY DISP_ORD)    GR_QVV_VALUE,
                       COUNT (DISP_ORD)                    max_VV
                  FROM NCI_QUEST_VALID_VALUE
              GROUP BY Q_PUB_ID, Q_VER_NR) QVV,
             NCI_QUEST_VALID_VALUE VV,
             NCI_DLOAD_DTL        ALS,
             NCI_DLOAD_HDR        H
       WHERE     FORM_ID = ALS.ITEM_ID
             AND Form_Version = ALS.VER_NR
             AND h.HDR_ID = ALS.HDR_ID
             AND h.DLOAD_TYP_ID = 92
             AND QUEST_ID = QVV.Q_PUB_ID(+)
             AND QUEST_VERSION = QVV.Q_VER_NR(+)
             AND QUEST_VERSION = VV.Q_VER_NR(+)
             AND QUEST_ID = VV.Q_PUB_ID(+)
    --and h.HDR_ID='XXX'
    ORDER BY h.HDR_ID,
             Form_ID,
             MODULE_DISPLAY_ORDER NULLS FIRST,
             VD_ID,
             GR_QVV_VALUE NULLS FIRST,
             QUEST_DISP_ORD DESC,
             VV.DISP_ORD;


DROP VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD_TEST;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALS_FIELD_FORM_DD_TEST
(
    COLLECT_ID,
    COLLECT_TYPE,
    COLLECT_NAME,
    PROTOCOL,
    FORM_ID,
    FORM_VERSION,
    FORM_LONG_NAME,
    CDE_SHORT_NAME,
    CDE_LONG_NAME,
    DE_PUB_ID,
    DE_VERSION,
    VD_LONG_NAME,
    VD_ID,
    VD_VERSION,
    MODULE_DISPLAY_ORDER,
    GR_QVV_VALUE,
    VV_NUMBERS_IN_QUEST,
    VAL_DOM_TYP_ID,
    VD_DATA_TYPE_NCI,
    VD_DATA_TYPE_MAP,
    VD_DISPLAY_FORMAT,
    VAL_DOM_MAX_CHAR,
    QUEST_ID,
    QUEST_VERSION,
    QUEST_LONG_NAME,
    QUEST_SHORT_NAME,
    QUEST_DISP_ORD,
    QUEST_INSTR,
    VV_ID,
    VV_VRERSION,
    VALID_VALUE,
    VV_VM_DEF,
    VV_DESC_TXT,
    VV_DISP_ORD,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR
)
BEQUEATH DEFINER
AS
      SELECT h.HDR_ID           COLLECT_ID,
             h.DLOAD_TYP_ID     COLLECT_TYPE,
             H.DLOAD_HDR_NM     COLLECT_NAME,
             PROTOCOL,
             FORM_ID,
             FORM_VERSION,
             Form_Long_Name,
             CDE_SHORT_NAME,
             CDE_LONG_NAME,
             DE_PUB_ID,
             DE_VERSION,
             VD_LONG_NAME,
             VD_ID,
             VD_Version,
             MODULE_DISPLAY_ORDER,
             GR_QVV_VALUE,
             QVV.max_vv         VV_NUMBERS_IN_QUEST,
             VAL_DOM_TYP_ID,
             VD_DATA_TYPE_NCI,
             VD_DATA_TYPE_MAP,
             VD_DISPLAY_FORMAT,
             VAL_DOM_MAX_CHAR,
             QUEST_ID,
             QUEST_VERSION,
             QUEST_LONG_NAME,
             QUEST_SHORT_NAME,
             QUEST_DISP_ORD,
             QUEST_INSTR,
             VV.NCI_PUB_ID      VV_ID,
             VV.NCI_VER_NR      VV_VRERSION,
             VV.VALUE           VALID_VALUE,
             VV.VM_DEF          VV_VM_DEF,
             VV.DESC_TXT        VV_DESC_TXT,
             VV.DISP_ORD        VV_DISP_ORD,
             VAL_MEAN_ITEM_ID,
             VAL_MEAN_VER_NR,
             PERM_VAL.VAL_ID,
             -- PERM_VAL.
             PERM_VAL.PERM_VAL_NM,
             PERM_VAL.PERM_VAL_DESC_TXT,
             VM.ITEM_NM,
             VM.ITEM_DESC,
             VM.ITEM_ID,
             VM.VER_NR
        FROM VW_ALS_FIELD_RAW_DATA VW,
             (  SELECT Q_PUB_ID,
                       Q_VER_NR,
                       LISTAGG (DISP_ORD || '.' || VALUE,
                                '||'
                                ON OVERFLOW TRUNCATE)
                       WITHIN GROUP (ORDER BY DISP_ORD)    GR_QVV_VALUE,
                       COUNT (DISP_ORD)                    max_VV
                  FROM NCI_QUEST_VALID_VALUE
              GROUP BY Q_PUB_ID, Q_VER_NR) QVV,
             NCI_QUEST_VALID_VALUE VV,
             NCI_DLOAD_DTL        ALS,
             NCI_DLOAD_HDR        H,
             ADMIN_ITEM           VM,
             PERM_VAL
       WHERE     FORM_ID = ALS.ITEM_ID
             AND Form_Version = ALS.VER_NR
             AND h.HDR_ID = ALS.HDR_ID
             AND h.DLOAD_TYP_ID = 92
             AND QUEST_ID = QVV.Q_PUB_ID(+)
             AND QUEST_VERSION = QVV.Q_VER_NR(+)
             AND QUEST_VERSION = VV.Q_VER_NR(+)
             AND QUEST_ID = VV.Q_PUB_ID(+)
             AND VD_ID = PERM_VAL.VAL_DOM_ITEM_ID
             AND VD_VERSION = PERM_VAL.VAL_DOM_VER_NR
             --    AND VALUE_DOM.dttype_id = DT.dttype_id
             AND VM.ITEM_ID = PERM_VAL.NCI_VAL_MEAN_ITEM_ID(+)
             AND VM.VER_NR = PERM_VAL.NCI_VAL_MEAN_VER_NR(+)
             AND DE_PUB_ID IN (2436373, 2898505, 2697302)
    -- and h.HDR_ID='1140'
    ORDER BY h.HDR_ID,
             Form_ID,
             MODULE_DISPLAY_ORDER NULLS FIRST,
             VD_ID,
             GR_QVV_VALUE NULLS FIRST,
             QUEST_DISP_ORD DESC,
             VV.DISP_ORD;


DROP VIEW ONEDATA_WA.VW_ALS_FIELD_RAW_DATA;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
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
    -- AND FORM.ITEM_ID = 3284264
    ORDER BY 3, 5, 7;


DROP VIEW ONEDATA_WA.VW_ALT_NMS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_ALT_NMS
(
    NM_ID,
    ITEM_ID,
    VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    NM_DESC,
    PREF_NM_IND,
    LANG_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NM_TYP_ID
)
BEQUEATH DEFINER
AS
    SELECT ALT_NMS.NM_ID,
           ALT_NMS.ITEM_ID,
           ALT_NMS.VER_NR,
           ALT_NMS.CNTXT_ITEM_ID,
           ALT_NMS.CNTXT_VER_NR,
           ALT_NMS.NM_DESC,
           ALT_NMS.PREF_NM_IND,
           ALT_NMS.LANG_ID,
           ALT_NMS.CREAT_DT,
           ALT_NMS.CREAT_USR_ID,
           ALT_NMS.LST_UPD_USR_ID,
           ALT_NMS.FLD_DELETE,
           ALT_NMS.LST_DEL_DT,
           ALT_NMS.S2P_TRN_DT,
           ALT_NMS.LST_UPD_DT,
           ALT_NMS.NM_TYP_ID
      FROM ALT_NMS;


DROP VIEW ONEDATA_WA.VW_CD_PSV_CNSTRNT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CD_PSV_CNSTRNT
(
    CONC_DOM_VER_NR,
    CONC_DOM_ITEM_ID,
    DIMNSNLTY,
    VAL_DOM_TYP_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CONC_DOM.VER_NR,
           CONC_DOM.ITEM_ID,
           CONC_DOM.DIMNSNLTY,
           CONC_DOM.CONC_DOM_TYP_ID,
           CONC_DOM.CREAT_DT,
           CONC_DOM.CREAT_USR_ID,
           CONC_DOM.LST_UPD_USR_ID,
           CONC_DOM.FLD_DELETE,
           CONC_DOM.LST_DEL_DT,
           CONC_DOM.S2P_TRN_DT,
           CONC_DOM.LST_UPD_DT
      FROM CONC_DOM;


DROP VIEW ONEDATA_WA.VW_CHAR_SET;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CHAR_SET
(
    CHAR_SET_ID,
    CHAR_SET_NM,
    CHAR_SET_DESC,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CHAR_SET_NM_DESC
)
BEQUEATH DEFINER
AS
    SELECT CHAR_SET.CHAR_SET_ID,
           CHAR_SET.CHAR_SET_NM,
           CHAR_SET.CHAR_SET_DESC,
           CHAR_SET.CREAT_DT,
           CHAR_SET.CREAT_USR_ID,
           CHAR_SET.LST_UPD_USR_ID,
           CHAR_SET.FLD_DELETE,
           CHAR_SET.LST_DEL_DT,
           CHAR_SET.S2P_TRN_DT,
           CHAR_SET.LST_UPD_DT,
           CHAR_SET.CHAR_SET_NM || ': ' || CHAR_SET.CHAR_SET_DESC
      FROM CHAR_SET;


DROP VIEW ONEDATA_WA.VW_CLASS_SCHEME_ITEM_MDSR;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CLASS_SCHEME_ITEM_MDSR
(
    NCI_PUB_ID,
    NCI_VER_NR,
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CS_IDSEQ,
    CS_LONG_NM,
    CS_ITEM_DESC,
    CS_VER_NR,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    CSITL_NM,
    CS_ITEM_ID,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    PCSI_ITEM_ID,
    PCSI_VER_NR
)
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


DROP VIEW ONEDATA_WA.VW_CLSFCTN_SCHM_ITEM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CLSFCTN_SCHM_ITEM
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_IDSEQ,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CS_ITEM_ID,
    CS_ITEM_VER_NR,
    FUL_PATH
)
BEQUEATH DEFINER
AS
        SELECT ADMIN_ITEM.ITEM_ID,
               ADMIN_ITEM.VER_NR,
               ADMIN_ITEM.ITEM_NM,
               ADMIN_ITEM.ITEM_LONG_NM,
               ADMIN_ITEM.ITEM_DESC,
               ADMIN_ITEM.CNTXT_NM_DN,
               ADMIN_ITEM.CURRNT_VER_IND,
               ADMIN_ITEM.REGSTR_STUS_NM_DN,
               ADMIN_ITEM.ADMIN_STUS_NM_DN,
               ADMIN_ITEM.CREAT_DT,
               ADMIN_ITEM.CREAT_USR_ID,
               ADMIN_ITEM.LST_UPD_USR_ID,
               ADMIN_ITEM.FLD_DELETE,
               ADMIN_ITEM.LST_DEL_DT,
               ADMIN_ITEM.S2P_TRN_DT,
               ADMIN_ITEM.LST_UPD_DT,
               ADMIN_ITEM.NCI_IDSEQ,
               CSI.P_ITEM_ID,
               CSI.P_ITEM_VER_NR,
               CSI.CS_ITEM_ID,
               CSI.CS_ITEM_VER_NR,
               CAST (
                      cs.item_nm
                   || SYS_CONNECT_BY_PATH (REPLACE (admin_item.ITEM_NM, '|', ''),
                                           ' | ')
                       AS VARCHAR2 (4000))    FUL_PATH
          FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
         WHERE     ADMIN_ITEM_TYP_ID = 51
               AND ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID
               AND ADMIN_ITEM.VER_NR = CSI.VER_NR
               AND csi.cs_item_id = cs.item_id
               AND csi.cs_item_ver_nr = cs.ver_nr
    START WITH p_item_id IS NULL
    CONNECT BY PRIOR csi.item_id = csi.p_item_id;


DROP VIEW ONEDATA_WA.VW_CLSFCTN_SCHM_ITEM_2;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CLSFCTN_SCHM_ITEM_2
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_IDSEQ,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CS_ITEM_ID,
    CS_ITEM_VER_NR,
    CANNOTBERES
)
BEQUEATH DEFINER
AS
        SELECT ADMIN_ITEM.ITEM_ID,
               ADMIN_ITEM.VER_NR,
               ADMIN_ITEM.ITEM_NM,
               ADMIN_ITEM.ITEM_LONG_NM,
               ADMIN_ITEM.ITEM_DESC,
               ADMIN_ITEM.CNTXT_NM_DN,
               ADMIN_ITEM.CURRNT_VER_IND,
               ADMIN_ITEM.REGSTR_STUS_NM_DN,
               ADMIN_ITEM.ADMIN_STUS_NM_DN,
               ADMIN_ITEM.CREAT_DT,
               ADMIN_ITEM.CREAT_USR_ID,
               ADMIN_ITEM.LST_UPD_USR_ID,
               ADMIN_ITEM.FLD_DELETE,
               ADMIN_ITEM.LST_DEL_DT,
               ADMIN_ITEM.S2P_TRN_DT,
               ADMIN_ITEM.LST_UPD_DT,
               ADMIN_ITEM.NCI_IDSEQ,
               CSI.P_ITEM_ID,
               CSI.P_ITEM_VER_NR,
               CSI.CS_ITEM_ID,
               CSI.CS_ITEM_VER_NR,
               CAST (SYS_CONNECT_BY_PATH (ITEM_NM, ' | ') AS VARCHAR2 (4000))    cannotberes
          FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi
         WHERE     ADMIN_ITEM_TYP_ID = 51
               AND ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID
               AND ADMIN_ITEM.VER_NR = CSI.VER_NR
    START WITH p_item_id IS NULL
    CONNECT BY PRIOR csi.item_id = csi.p_item_id;


DROP VIEW ONEDATA_WA.VW_CMNTS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CMNTS
(
    REF_ID,
    ITEM_ID,
    VER_NR,
    REF_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REF_DESC,
    REF_TYP_ID,
    DISP_ORD,
    LANG_ID
)
BEQUEATH DEFINER
AS
    SELECT REF.REF_ID,
           REF.ITEM_ID,
           REF.VER_NR,
           REF.REF_NM,
           REF.CREAT_DT,
           REF.CREAT_USR_ID,
           REF.LST_UPD_USR_ID,
           REF.FLD_DELETE,
           REF.LST_DEL_DT,
           REF.S2P_TRN_DT,
           REF.LST_UPD_DT,
           REF.REF_DESC,
           REF.REF_TYP_ID,
           REF.DISP_ORD,
           REF.LANG_ID
      FROM REF
     WHERE REF_TYP_ID = 44;


DROP VIEW ONEDATA_WA.VW_CNCPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CNCPT
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    PRMRY_CNCPT_IND,
    DEF_SRC,
    EVS_SRC
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           CNCPT.PRMRY_CNCPT_IND,
           NVL (
               DECODE (TRIM (ADMIN_ITEM.DEF_SRC),
                       'NCI', '1-NCI',
                       ADMIN_ITEM.DEF_SRC),
               'No Def Source')             DEF_SRC,
           DECODE (TRIM (OBJ_KEY.OBJ_KEY_DESC),
                   'NCI_CONCEPT_CODE', '1-NCC',
                   'NCI_META_CUI', '2-NMC',
                   OBJ_KEY.OBJ_KEY_DESC)    EVS_SRC
      FROM ADMIN_ITEM, CNCPT, OBJ_KEY
     WHERE     ADMIN_ITEM_TYP_ID = 49
           AND ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = CNCPT.VER_NR
           AND cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID(+)
           AND admin_item.admin_stus_nm_dn = 'RELEASED';


DROP VIEW ONEDATA_WA.VW_CNCPT_ALL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CNCPT_ALL
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DEF_SRC,
    EVS_SRC
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           NVL (
               DECODE (ADMIN_ITEM.DEF_SRC,
                       'NCI', '1-NCI',
                       ADMIN_ITEM.DEF_SRC),
               'No Def Source')             DEF_SRC,
           DECODE (OBJ_KEY.OBJ_KEY_DESC,
                   'NCI_CONCEPT_CODE', '1-NCI_CONCEPT_CODE',
                   'NCI_META_CUI', '2-NCI_META_CUI',
                   OBJ_KEY.OBJ_KEY_DESC)    EVS_SRC
      FROM ADMIN_ITEM, CNCPT, OBJ_KEY
     WHERE     ADMIN_ITEM_TYP_ID = 49
           AND ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = CNCPT.VER_NR
           AND cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID(+);


DROP VIEW ONEDATA_WA.VW_CNCPT_CHLDRN;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CNCPT_CHLDRN
(
    ITEM_NM,
    ITEM_DESC,
    CREAT_DT,
    CREAT_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    LST_UPD_DT,
    LST_UPD_USR_ID,
    S2P_TRN_DT,
    ITEM_TYPE,
    CHILD_NM
)
BEQUEATH DEFINER
AS
    SELECT a.ITEM_NM,
           a.ITEM_DESC,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.LST_UPD_DT,
           a.LST_UPD_USR_ID,
           a.S2P_TRN_DT,
           t.OBJ_KEY_DESC     ITEM_TYPE,
           b.ITEM_NM          CHILD_NM
      FROM ADMIN_ITEM        a,
           CNCPT_ADMIN_ITEM  c,
           ADMIN_ITEM        b,
           OBJ_KEY           t
     WHERE     a.ADMIN_ITEM_TYP_ID = 49
           AND a.ITEM_ID = c.CNCPT_ITEM_ID
           AND a.VER_NR = c.CNCPT_VER_NR
           AND c.ITEM_ID = b.ITEM_ID
           AND c.VER_NR = b.VER_NR
           AND b.ADMIN_ITEM_TYP_ID = t.OBJ_KEY_ID
    UNION
    SELECT a.ITEM_NM,
           a.ITEM_DESC,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.LST_UPD_DT,
           a.LST_UPD_USR_ID,
           a.S2P_TRN_DT,
           'Value Meaning'     ITEM_TYPE,
           b.VAL_MEAN_DESC
      FROM ADMIN_ITEM a, CNCPT_VAL_MEAN c, VAL_MEAN b
     WHERE     a.ADMIN_ITEM_TYP_ID = 49
           AND a.ITEM_ID = c.CNCPT_ITEM_ID
           AND a.VER_NR = c.CNCPT_VER_NR
           AND c.VAL_MEAN_ID = b.VAL_MEAN_ID
    UNION
    SELECT a.ITEM_NM,
           a.ITEM_DESC,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.LST_UPD_DT,
           a.LST_UPD_USR_ID,
           a.S2P_TRN_DT,
           'Classification Scheme Item'     ITEM_TYPE,
           b.CLSFCTN_SCHM_ITEM_NM
      FROM ADMIN_ITEM a, CNCPT_CSI c, CLSFCTN_SCHM_ITEM b
     WHERE     a.ADMIN_ITEM_TYP_ID = 49
           AND a.ITEM_ID = c.CNCPT_ITEM_ID
           AND a.VER_NR = c.CNCPT_VER_NR
           AND c.CLSFCTN_SCHM_ITEM_ID = b.CLSFCTN_SCHM_ITEM_ID;


DROP VIEW ONEDATA_WA.VW_CNCPT_RT_PRMRY;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CNCPT_RT_PRMRY
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DEF_SRC,
    EVS_SRC
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           NVL (
               DECODE (ADMIN_ITEM.DEF_SRC,
                       'NCI', '1-NCI',
                       ADMIN_ITEM.DEF_SRC),
               'No Def Source')             DEF_SRC,
           DECODE (OBJ_KEY.OBJ_KEY_DESC,
                   'NCI_CONCEPT_CODE', '1-NCI_CONCEPT_CODE',
                   'NCI_META_CUI', '2-NCI_META_CUI',
                   OBJ_KEY.OBJ_KEY_DESC)    EVS_SRC
      FROM ADMIN_ITEM, CNCPT, OBJ_KEY
     WHERE     ADMIN_ITEM_TYP_ID = 49
           AND ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = CNCPT.VER_NR
           AND cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID(+)
           AND admin_item.admin_stus_nm_dn = 'RELEASED'
           AND ADMIN_ITEM.ITEM_LONG_NM IN ('C13717',
                                           'C25372',
                                           'C25162',
                                           'C25463',
                                           'C25164',
                                           'C37939',
                                           'C25488',
                                           'C25330',
                                           'C48150',
                                           'C25515',
                                           'C48309',
                                           'C25364',
                                           'C25180',
                                           'C45255',
                                           'C25543',
                                           'C25209',
                                           'C42614',
                                           'C25337',
                                           'C20200',
                                           'C38013',
                                           'C25636',
                                           'C25638',
                                           'C25664',
                                           'C25338',
                                           'C25683',
                                           'C25685',
                                           'C16899',
                                           'C25688',
                                           'C25704',
                                           'C25207',
                                           'C25284',
                                           'C25709',
                                           'C25712');


DROP VIEW ONEDATA_WA.VW_CNTCT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CNTCT
(
    CNTCT_ID,
    CNTCT_SECU_ID,
    CNTCT_NM,
    CNTCT_TTL,
    CNTCT_REGSTRR_IND,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT CNTCT.CNTCT_ID,
           CNTCT.CNTCT_SECU_ID,
           CNTCT.CNTCT_NM,
           CNTCT.CNTCT_TTL,
           CNTCT.CNTCT_REGSTRR_IND,
           CNTCT.CREAT_DT,
           CNTCT.CREAT_USR_ID,
           CNTCT.LST_UPD_USR_ID,
           CNTCT.FLD_DELETE,
           CNTCT.LST_DEL_DT,
           CNTCT.S2P_TRN_DT,
           CNTCT.LST_UPD_DT
      FROM CNTCT;


DROP VIEW ONEDATA_WA.VW_CSI_FORM_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_FORM_REL
(
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC,
    CNTXT_NM_DN,
    ADMIN_STUS_NM_DN,
    REGSTR_STUS_NM_DN,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID_X
)
BEQUEATH DEFINER
AS
    SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 54;


DROP VIEW ONEDATA_WA.VW_CSI_NODE_DEC_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_NODE_DEC_REL
(
    NCI_PUB_ID,
    NCI_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC
)
BEQUEATH DEFINER
AS
    SELECT ak.NCI_PUB_ID,
           ak.NCI_VER_NR,
           ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC
      FROM NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 2;


DROP VIEW ONEDATA_WA.VW_CSI_NODE_DE_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_NODE_DE_REL
(
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC,
    CNTXT_NM_DN,
    ADMIN_STUS_NM_DN,
    REGSTR_STUS_NM_DN,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID_X,
    ADMIN_ITEM_TYP_ID,
    ADMIN_ITEM_TYP_DESC
)
BEQUEATH DEFINER
AS
    SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X,
           ai.admin_item_typ_id,
           ok.obj_key_desc       ADMIN_ITEM_TYP_DESC
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, vw_obj_key_4 ok
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = ok.obj_key_id
    UNION
    SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           csi.CS_ITEM_ID,
           csi.CS_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X,
           ai.admin_item_typ_id,
           ok.obj_key_desc       ADMIN_ITEM_TYP_DESC
      FROM NCI_ADMIN_ITEM_REL     ak,
           ADMIN_ITEM             ai,
           NCI_CLSFCTN_SCHM_ITEM  csi,
           vw_obj_key_4           ok
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = ok.obj_key_id
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR;


DROP VIEW ONEDATA_WA.VW_CSI_NODE_FORM_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_NODE_FORM_REL
(
    NCI_PUB_ID,
    NCI_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC
)
BEQUEATH DEFINER
AS
    SELECT ak.NCI_PUB_ID,
           ak.NCI_VER_NR,
           ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC
      FROM NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 54;


DROP VIEW ONEDATA_WA.VW_CSI_NODE_VD_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_NODE_VD_REL
(
    NCI_PUB_ID,
    NCI_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC
)
BEQUEATH DEFINER
AS
    SELECT ak.NCI_PUB_ID,
           ak.NCI_VER_NR,
           ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC
      FROM NCI_ALT_KEY_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 3;


DROP VIEW ONEDATA_WA.VW_CSI_ONLY_NODE_DE_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_ONLY_NODE_DE_REL
(
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_ID,
    VER_NR,
    ITEM_DESC,
    CNTXT_NM_DN,
    ADMIN_STUS_NM_DN,
    REGSTR_STUS_NM_DN,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID_X
)
BEQUEATH DEFINER
AS
    SELECT ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           ak.CREAT_USR_ID       CREAT_USR_ID_X,
           ak.LST_UPD_USR_ID     LST_UPD_USR_ID_X
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ai.ADMIN_ITEM_TYP_ID = 4;


DROP VIEW ONEDATA_WA.VW_CSI_TREE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_TREE
(
    LVL,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    ITEM_ID,
    VER_NR,
    ITEM_DESC,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_LONG_NM,
    ITEM_NM,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    REGISTRR_CNTCT_ID,
    SUBMT_CNTCT_ID,
    STEWRD_CNTCT_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REGSTR_AUTH_ID,
    NCI_IDSEQ,
    ADMIN_STUS_NM_DN,
    CNTXT_NM_DN,
    REGSTR_STUS_NM_DN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID_X
)
BEQUEATH DEFINER
AS
    SELECT 98       LVL,
           NULL     P_ITEM_ID,
           NULL     P_ITEM_VER_NR,
           ITEM_ID,
           VER_NR,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           REGSTR_AUTH_ID,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           CREAT_USR_ID_X,
           LST_UPD_USR_ID_X
      FROM ADMIN_ITEM
     WHERE ADMIN_ITEM_TYP_ID = 8
    UNION
    SELECT 99                LVL,
           CNTXT_ITEM_ID     P_ITEM_ID,
           CNTXT_VER_NR      P_ITEM_VER_NR,
           ITEM_ID,
           VER_NR,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           REGSTR_AUTH_ID,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           CREAT_USR_ID_X,
           LST_UPD_USR_ID_X
      FROM ADMIN_ITEM
     WHERE ADMIN_ITEM_TYP_ID = 9
    UNION
    SELECT 100                LVL,
           CS_ITEM_ID         P_ITEM_ID,
           CS_ITEM_VER_NR     P_ITEM_VER_NR,
           ai.ITEM_ID,
           ai.VER_NR,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT,
           REGSTR_AUTH_ID,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           CREAT_USR_ID_X,
           LST_UPD_USR_ID_X
      FROM ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
     WHERE     ADMIN_ITEM_TYP_ID = 51
           AND ai.item_id = csi.item_id
           AND ai.ver_nr = csi.ver_nr
           AND csi.p_item_id IS NULL
           AND csi.CS_ITEM_ID IS NOT NULL
    UNION
    SELECT 100                   LVL,
           csi.P_ITEM_ID         P_ITEM_ID,
           csi.P_ITEM_VER_NR     P_ITEM_VER_NR,
           ai.ITEM_ID,
           ai.VER_NR,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT,
           REGSTR_AUTH_ID,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           CREAT_USR_ID_X,
           LST_UPD_USR_ID_X
      FROM ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi
     WHERE     ADMIN_ITEM_TYP_ID = 51
           AND ai.item_id = csi.item_id
           AND ai.ver_nr = csi.ver_nr
           AND csi.p_item_id IS NOT NULL;


DROP VIEW ONEDATA_WA.VW_CSI_TREE_NODE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_TREE_NODE
(
    LVL,
    ITEM_ID,
    VER_NR,
    ITEM_DESC,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_LONG_NM,
    ITEM_NM,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    REGISTRR_CNTCT_ID,
    SUBMT_CNTCT_ID,
    STEWRD_CNTCT_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REGSTR_AUTH_ID,
    NCI_IDSEQ,
    ADMIN_STUS_NM_DN,
    CNTXT_NM_DN,
    REGSTR_STUS_NM_DN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID_X
)
BEQUEATH DEFINER
AS
    SELECT DECODE (admin_item_typ_id,  8, 'CONTEXT',  9, 'CS',  51, 'CSI')
               LVL,
           ITEM_ID,
           VER_NR,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           REGSTR_AUTH_ID,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           CREAT_USR_ID_X,
           LST_UPD_USR_ID_X
      FROM ADMIN_ITEM
     WHERE ADMIN_ITEM_TYP_ID IN (8, 9, 51);


DROP VIEW ONEDATA_WA.VW_CSI_TREE_NODE_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_CSI_TREE_NODE_REL
(
    LVL,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    ITEM_ID,
    VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT 'CLASSIFICATION SCHEME'     LVL,
           CNTXT_ITEM_ID               P_ITEM_ID,
           CNTXT_VER_NR                P_ITEM_VER_NR,
           ITEM_ID,
           VER_NR,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT
      FROM ADMIN_ITEM
     WHERE ADMIN_ITEM_TYP_ID = 9
    UNION
    SELECT 'CSI'              LVL,
           CS_ITEM_ID         P_ITEM_ID,
           CS_ITEM_VER_NR     P_ITEM_VER_NR,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT
      FROM NCI_CLSFCTN_SCHM_ITEM ai
     WHERE ai.p_item_id IS NULL
    UNION
    SELECT 'CSI'             LVL,
           P_ITEM_ID         P_ITEM_ID,
           P_ITEM_VER_NR     P_ITEM_VER_NR,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT
      FROM NCI_CLSFCTN_SCHM_ITEM ai
     WHERE ai.p_item_id IS NOT NULL;


DROP VIEW ONEDATA_WA.VW_DATA_ELEM_RPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DATA_ELEM_RPT
(
    ITEM_ID,
    VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_NM,
    ITEM_DESC,
    DTTYPE_ID,
    VAL_DOM_FMT_ID,
    UOM_ID,
    NCI_DEC_PREC,
    NCI_STD_DTTYPE_ID,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_LOW_VAL_NUM,
    VAL_DOM_HIGH_VAL_NUM,
    EFF_DT,
    UNTL_DT,
    CREAT_DT,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    LST_UPD_USR_ID,
    CREAT_USR_ID,
    ADMIN_STUS_NM_DN,
    CURRNT_VER_IND,
    VAL_DOM_TYP_ID,
    ITEM_LONG_NM,
    REGSTR_STUS_NM_DN,
    NON_ENUM_VAL_DOM_DESC,
    ORIGIN,
    REGSTR_AUTH_ID,
    DERV_DE_IND,
    DERV_MTHD,
    DERV_RUL,
    DERV_TYP_ID,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_DESC,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.NCI_DEC_PREC,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           DECODE (VALUE_DOM.VAL_DOM_TYP_ID,
                   17, 'Enumerated',
                   18, 'Non-enumerated')    VAL_DOM_TYP_ID,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           DE.DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           VALUE_DOM.ITEM_ID                VAL_DOM_ITEM_ID,
           VALUE_DOM.VER_NR                 VAL_DOM_VER_NR
      FROM DE, VALUE_DOM, ADMIN_ITEM
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND ADMIN_ITEM.ITEM_ID = DE.ITEM_ID
           AND ADMIN_ITEM.VER_NR = DE.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR;


DROP VIEW ONEDATA_WA.VW_DATA_TYP;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DATA_TYP
(
    DTTYPE_ID,
    DTTYPE_ANNTTN,
    DTTYPE_DESC,
    DTTYPE_NM,
    DTTYPE_SCHM_REF,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DATA_TYP_NM_DESC
)
BEQUEATH DEFINER
AS
    SELECT DATA_TYP.DTTYPE_ID,
           DATA_TYP.DTTYPE_ANNTTN,
           DATA_TYP.DTTYPE_DESC,
           DATA_TYP.DTTYPE_NM,
           DATA_TYP.DTTYPE_SCHM_REF,
           DATA_TYP.CREAT_DT,
           DATA_TYP.CREAT_USR_ID,
           DATA_TYP.LST_UPD_USR_ID,
           DATA_TYP.FLD_DELETE,
           DATA_TYP.LST_DEL_DT,
           DATA_TYP.S2P_TRN_DT,
           DATA_TYP.LST_UPD_DT,
           DATA_TYP.DTTYPE_NM || ': ' || DATA_TYP.DTTYPE_DESC
      FROM DATA_TYP;


DROP VIEW ONEDATA_WA.VW_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DE
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    DE_CONC_VER_NR,
    DE_CONC_ITEM_ID,
    VAL_DOM_VER_NR,
    VAL_DOM_ITEM_ID,
    REP_CLS_VER_NR,
    REP_CLS_ITEM_ID,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    PREF_QUEST_TXT,
    NON_ENUM_VAL_DOM_DESC,
    DTTYPE_ID,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_TYP_ID,
    UOM_ID,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_FMT_ID,
    CHAR_SET_ID,
    VAL_DOM_HIGH_VAL_NUM,
    VAL_DOM_LOW_VAL_NUM,
    FMT_NM,
    DTTYPE_NM,
    UOM_NM,
    VAL_DOM_TYP
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           DE.DE_CONC_VER_NR,
           DE.DE_CONC_ITEM_ID,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           DE.CREAT_USR_ID,
           DE.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           DE.LST_UPD_DT,
           DE.CREAT_DT,
           DE.PREF_QUEST_TXT,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.DTTYPE_ID,
           VAL_DOM_MAX_CHAR,
           VAL_DOM_TYP_ID,
           VALUE_DOM.UOM_ID,
           VAL_DOM_MIN_CHAR,
           VAL_DOM_FMT_ID,
           CHAR_SET_ID,
           VAL_DOM_HIGH_VAL_NUM,
           VAL_DOM_LOW_VAL_NUM,
           FMT_NM,
           DTTYPE_NM,
           UOM_NM,
           DECODE (VALUE_DOM.VAL_DOM_TYP_ID,
                   17, 'Enumerated',
                   18, 'Non-Enumerated')    VAL_DOM_TYP
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           DATA_TYP,
           FMT,
           UOM
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID(+)
           AND VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID(+)
           AND VALUE_DOM.UOM_ID = UOM.UOM_ID(+);


DROP VIEW ONEDATA_WA.VW_DEC_MTCHG;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DEC_MTCHG
(
    ITEM_ID,
    VER_NR,
    CD_ITEM_NM,
    CD_ITEM_LONG_NM,
    CD_ITEM_DESC,
    DEC_ITEM_NM,
    DEC_ITEM_LONG_NM,
    DEC_ITEM_DESC,
    DEC_CONCAT_NM,
    OBJ_ITEM_NM,
    OBJ_ITEM_LONG_NM,
    OBJ_ITEM_DESC,
    OBJ_CONCAT_NM,
    PROP_ITEM_NM,
    PROP_ITEM_LONG_NM,
    PROP_ITEM_DESC,
    PROP_CONCAT_NM,
    ALL_CONCAT_NM,
    CREAT_DT,
    LST_DEL_DT,
    LST_UPD_DT,
    FLD_DELETE,
    S2P_TRN_DT,
    LST_UPD_USR_ID,
    CREAT_USR_ID
)
BEQUEATH DEFINER
AS
    SELECT ai_dec.item_id,
           ai_dec.ver_nr,
           ai_cd.ITEM_NM                                     CD_ITEM_NM,
           ai_cd.ITEM_LONG_NM                                CD_ITEM_LONG_NM,
           ai_cd.ITEM_DESC                                   CD_ITEM_DESC,
           ai_dec.ITEM_NM                                    DEC_ITEM_NM,
           ai_dec.ITEM_LONG_NM                               DEC_ITEM_LONG_NM,
           ai_dec.ITEM_DESC                                  DEC_ITEM_DESC,
           ai_dec.ITEM_NM || ' ' || ai_dec.ITEM_LONG_NM      dec_concat_nm,
           ai_obj.ITEM_NM                                    OBJ_ITEM_NM,
           ai_obj.ITEM_LONG_NM                               OBJ_ITEM_LONG_NM,
           ai_obj.ITEM_DESC                                  OBJ_ITEM_DESC,
           ai_obj.ITEM_NM || ' ' || ai_obj.ITEM_LONG_NM      obj_concat_nm,
           ai_prop.ITEM_NM                                   PROP_ITEM_NM,
           ai_prop.ITEM_LONG_NM                              PROP_ITEM_LONG_NM,
           ai_prop.ITEM_DESC                                 PROP_ITEM_DESC,
           ai_prop.ITEM_NM || ' ' || ai_prop.ITEM_LONG_NM    prop_concat_nm,
              ai_dec.ITEM_NM
           || ai_dec.ITEM_LONG_NM
           || ai_obj.ITEM_NM
           || ai_obj.ITEM_LONG_NM
           || ai_prop.ITEM_NM
           || ai_prop.ITEM_LONG_NM                           all_concat_nm,
           ai_dec.CREAT_DT,
           ai_dec.LST_DEL_DT,
           ai_dec.LST_UPD_DT,
           ai_dec.FLD_DELETE,
           ai_dec.S2P_TRN_DT,
           ai_dec.LST_UPD_USR_ID,
           ai_dec.CREAT_USR_ID
      FROM de_conc     d,
           admin_item  ai_dec,
           admin_item  ai_obj,
           admin_item  ai_prop,
           admin_item  ai_cd
     WHERE     d.CONC_DOM_ITEM_ID = ai_cd.ITEM_ID
           AND d.CONC_DOM_VER_NR = ai_cd.VER_NR
           AND d.OBJ_CLS_VER_NR = ai_obj.VER_NR
           AND d.OBJ_CLS_item_id = ai_obj.item_id
           AND d.ITEM_ID = ai_dec.ITEM_ID
           AND d.VER_NR = ai_dec.ver_nr
           AND ai_dec.CURRNT_VER_IND = 1
           AND d.PROP_ITEM_ID = ai_prop.ITEM_ID
           AND d.PROP_VER_NR = ai_prop.VER_NR;


DROP VIEW ONEDATA_WA.VW_DERV_RUL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DERV_RUL
(
    ITEM_ID,
    VER_NR,
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    LST_UPD_USR_ID,
    CREAT_USR_ID,
    CREAT_DT,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    DATA_ID_STR,
    CLSFCTN_SCHM_ID,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    CLSFCTN_SCHM_VER_NR,
    ADMIN_ITEM_TYP_ID,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    STEWRD_ORG_ID,
    SUBMT_ORG_ID,
    STEWRD_CNTCT_ID,
    SUBMT_CNTCT_ID,
    REGISTRR_CNTCT_ID,
    LEGCY_CD,
    CASE_FILE_ID,
    REGSTR_AUTH_ID,
    BTCH_NR,
    ALT_KEY,
    DERV_RUL_CNTXT_STUS_VER_NM
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.DATA_ID_STR,
           ADMIN_ITEM.CLSFCTN_SCHM_ID,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CLSFCTN_SCHM_VER_NR,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.LEGCY_CD,
           ADMIN_ITEM.CASE_FILE_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.BTCH_NR,
           ADMIN_ITEM.ALT_KEY,
              '['
           || NVL (STUS_MSTR.STUS_ACRO, STUS_MSTR.STUS_NM)
           || '] '
           || CNTXT.CNTXT_ACRO
           || ' : '
           || ADMIN_ITEM.ITEM_NM
           || ' - '
           || ADMIN_ITEM.VER_NR
      FROM ADMIN_ITEM, CNTXT, STUS_MSTR
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 10
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID(+)
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = STUS_MSTR.STUS_ID(+);


DROP VIEW ONEDATA_WA.VW_DE_CONC;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DE_CONC
(
    LST_UPD_DT,
    S2P_TRN_DT,
    LST_DEL_DT,
    FLD_DELETE,
    LST_UPD_USR_ID,
    CREAT_USR_ID,
    CREAT_DT,
    OBJ_CLS_VER_NR,
    OBJ_CLS_ITEM_ID,
    PROP_ITEM_ID,
    PROP_VER_NR,
    CONC_DOM_ITEM_ID,
    CONC_DOM_VER_NR,
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    DATA_ID_STR,
    ADMIN_ITEM_TYP_ID,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    ADMIN_STUS_NM_DN,
    REGSTR_STUS_NM_DN
)
BEQUEATH DEFINER
AS
    SELECT DE_CONC.LST_UPD_DT,
           DE_CONC.S2P_TRN_DT,
           DE_CONC.LST_DEL_DT,
           DE_CONC.FLD_DELETE,
           DE_CONC.LST_UPD_USR_ID,
           DE_CONC.CREAT_USR_ID,
           DE_CONC.CREAT_DT,
           DE_CONC.OBJ_CLS_VER_NR,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           DE_CONC.CONC_DOM_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR,
           ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.DATA_ID_STR,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_STUS_NM_DN,
           REGSTR_STUS_NM_DN
      FROM ADMIN_ITEM, DE_CONC
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 2
           AND ADMIN_ITEM.ITEM_ID = DE_CONC.ITEM_ID
           AND ADMIN_ITEM.VER_NR = DE_CONC.VER_NR;


DROP VIEW ONEDATA_WA.VW_DE_HORT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DE_HORT
(
    ITEM_NM,
    ITEM_DESC,
    DATA_ID_STR,
    VER_NR,
    ITEM_ID,
    LST_UPD_DT,
    CREAT_DT,
    CREAT_USR_ID,
    EFF_DT,
    CURRNT_VER_IND,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    REGSTR_STUS_ID,
    ALT_KEY,
    ADMIN_STUS_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    REGSTR_AUTH_ID,
    DE_PREC,
    DERV_DE_IND,
    VAL_DOM_TYP_ID,
    DTTYPE_ID,
    VAL_DOM_FMT_ID,
    UOM_ID,
    VD_ITEM_NM,
    VD_ALT_KEY,
    DEC_ITEM_NM,
    DEC_ALT_KEY,
    CD_ITEM_NM,
    CD_ALT_KEY,
    OC_ITEM_NM,
    OC_ALT_KEY,
    CNTXT_ITEM_NM,
    CNTXT_ALT_KEY,
    PROP_ITEM_NM,
    PROP_ALT_KEY
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.DATA_ID_STR,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ALT_KEY,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           --  NVL (ADMIN_ITEM.ORIGIN, ADMIN_ITEM.ORIGIN_ID_DN),
           --  ADMIN_ITEM.ORIGIN_ID,
           DE.DE_PREC,
           DE.DERV_DE_IND,
           VALUE_DOM.VAL_DOM_TYP_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.UOM_ID,
           AI_VD.ITEM_NM,
           AI_VD.ALT_KEY,
           AI_DEC.ITEM_NM,
           AI_DEC.ALT_KEY,
           AI_CD.ITEM_NM,
           AI_CD.ALT_KEY,
           AI_OC.ITEM_NM,
           AI_OC.ALT_KEY,
           AI_CNTXT.ITEM_NM,
           AI_CNTXT.ALT_KEY,
           AI_PROP.ITEM_NM,
           AI_PROP.ALT_KEY
      FROM ADMIN_ITEM,
           DE,
           DE_CONC,
           VALUE_DOM,
           ADMIN_ITEM  AI_VD,
           ADMIN_ITEM  AI_DEC,
           ADMIN_ITEM  AI_CD,
           ADMIN_ITEM  AI_OC,
           ADMIN_ITEM  AI_PROP,
           ADMIN_ITEM  AI_CNTXT
     WHERE     ADMIN_ITEM.ITEM_ID = DE.ITEM_ID
           -- AND ADMIN_ITEM.ORIGIN_ID = OBJ_KEY.OBJ_KEY_ID(+)
           AND ADMIN_ITEM.VER_NR = DE.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = AI_CD.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = AI_CD.VER_NR
           AND DE_CONC.OBJ_CLS_ITEM_ID = AI_OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = AI_OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = AI_PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = AI_PROP.VER_NR
           AND DE.VAL_DOM_ITEM_ID = AI_VD.ITEM_ID
           AND DE.VAL_DOM_VER_NR = AI_VD.VER_NR
           AND DE.DE_CONC_ITEM_ID = AI_DEC.ITEM_ID
           AND DE.DE_CONC_VER_NR = AI_DEC.VER_NR
           AND ADMIN_ITEM.CNTXT_ITEM_ID = AI_CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = AI_CNTXT.VER_NR;


DROP VIEW ONEDATA_WA.VW_DE_MTCHG;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DE_MTCHG
(
    ITEM_ID,
    VER_NR,
    DE_ITEM_NM,
    DE_ITEM_LONG_NM,
    DE_ITEM_DESC,
    DE_CONCAT_NM,
    DEC_ITEM_NM,
    DEC_ITEM_LONG_NM,
    DEC_ITEM_DESC,
    DEC_CONCAT_NM,
    VD_ITEM_NM,
    VD_ITEM_LONG_NM,
    VD_ITEM_DESC,
    VD_CONCAT_NM,
    ALL_CONCAT_NM,
    CREAT_DT,
    LST_DEL_DT,
    LST_UPD_DT,
    FLD_DELETE,
    S2P_TRN_DT,
    LST_UPD_USR_ID,
    CREAT_USR_ID,
    DICT_MTCH_TIPS_TXT
)
BEQUEATH DEFINER
AS
    SELECT ai_d.item_id,
           ai_d.ver_nr,
           ai_d.ITEM_NM                                    DE_ITEM_NM,
           ai_d.ITEM_LONG_NM                               DE_ITEM_LONG_NM,
           ai_d.ITEM_DESC                                  DE_ITEM_DESC,
           ai_d.ITEM_NM || ' ' || ai_d.ITEM_LONG_NM        de_concat_nm,
           ai_dec.ITEM_NM                                  DEC_ITEM_NM,
           ai_dec.ITEM_LONG_NM                             DEC_ITEM_LONG_NM,
           ai_dec.ITEM_DESC                                DEC_ITEM_DESC,
           ai_dec.ITEM_NM || ' ' || ai_dec.ITEM_LONG_NM    dec_concat_nm,
           ai_vd.ITEM_NM                                   VD_ITEM_NM,
           ai_vd.ITEM_LONG_NM                              VD_ITEM_LONG_NM,
           ai_vd.ITEM_DESC                                 VD_ITEM_DESC,
           ai_vd.ITEM_NM || ' ' || ai_vd.ITEM_LONG_NM      Vd_concat_nm,
              ai_d.ITEM_NM
           || ' '
           || ai_d.ITEM_LONG_NM
           || ' '
           || ai_dec.ITEM_NM
           || ' '
           || ai_dec.ITEM_LONG_NM                          all_concat_nm,
           ai_d.CREAT_DT,
           ai_d.LST_DEL_DT,
           ai_d.LST_UPD_DT,
           ai_d.FLD_DELETE,
           ai_d.S2P_TRN_DT,
           ai_d.LST_UPD_USR_ID,
           ai_d.CREAT_USR_ID,
           d.DICT_MTCH_TIPS_TXT
      FROM de          d,
           admin_item  ai_d,
           admin_item  ai_dec,
           admin_item  ai_vd
     WHERE     d.DE_CONC_ITEM_ID = ai_dec.ITEM_ID
           AND d.DE_CONC_VER_NR = ai_dec.VER_NR
           AND d.item_id = ai_d.item_id
           AND d.VER_NR = ai_d.ver_nr
           AND ai_d.CURRNT_VER_IND = 1
           AND d.VAL_DOM_ITEM_ID = ai_vd.ITEM_ID
           AND d.VAL_DOM_VER_NR = ai_vd.VER_NR;


DROP VIEW ONEDATA_WA.VW_DE_REL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_DE_REL
(
    PRMRY_VER_NR,
    SCNDRY_ITEM_ID,
    SCNDRY_VER_NR,
    PRMRY_ITEM_ID,
    DE_REL_TYP_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    ITEM_NM,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_ID,
    VER_NR
)
BEQUEATH DEFINER
AS
    SELECT DE_REL.PRMRY_VER_NR,
           DE_REL.SCNDRY_ITEM_ID,
           DE_REL.SCNDRY_VER_NR,
           DE_REL.PRMRY_ITEM_ID,
           DE_REL.DE_REL_TYP_ID,
           DE_REL.CREAT_DT,
           DE_REL.CREAT_USR_ID,
           DE_REL.LST_UPD_USR_ID,
           DE_REL.FLD_DELETE,
           DE_REL.LST_DEL_DT,
           DE_REL.S2P_TRN_DT,
           DE_REL.LST_UPD_DT,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR
      FROM DE_REL, ADMIN_ITEM
     WHERE     DE_REl.SCNDRY_ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE_REL.SCNDRY_VER_NR = ADMIN_ITEM.VER_NR;


DROP VIEW ONEDATA_WA.VW_EXMPLS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_EXMPLS
(
    REF_ID,
    ITEM_ID,
    VER_NR,
    REF_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REF_DESC,
    REF_TYP_ID,
    DISP_ORD,
    LANG_ID
)
BEQUEATH DEFINER
AS
    SELECT REF.REF_ID,
           REF.ITEM_ID,
           REF.VER_NR,
           REF.REF_NM,
           REF.CREAT_DT,
           REF.CREAT_USR_ID,
           REF.LST_UPD_USR_ID,
           REF.FLD_DELETE,
           REF.LST_DEL_DT,
           REF.S2P_TRN_DT,
           REF.LST_UPD_DT,
           REF.REF_DESC,
           REF.REF_TYP_ID,
           REF.DISP_ORD,
           REF.LANG_ID
      FROM REF
     WHERE REF_TYP_ID = 43;


DROP VIEW ONEDATA_WA.VW_FORM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_FORM
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    REGSTR_STUS_ID,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_ITEM_TYP_NM,
    CATGRY_ID,
    FORM_TYP_ID,
    ADMIN_STUS_ID,
    HDR_INSTR,
    FTR_INSTR,
    REGSTR_STUS_NM_DN,
    CNTXT_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT ai.item_id,
           ai.ver_nr,
           ai.item_nm,
           ai.item_long_nm,
           ai.item_desc,
           ai.REGSTR_STUS_ID,
           ai.cntxt_item_id,
           ai.cntxt_ver_nr,
           'FORM'     admin_item_typ_nm,
           f.catgry_id,
           f.FORM_TYP_ID,
           ai.admin_stus_id,
           f.HDR_INSTR,
           f.FTR_INSTR,
           ai.REGSTR_STUS_NM_DN,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT
      FROM admin_item ai, nci_form f
     WHERE ai.item_id = f.item_id AND ai.ver_nr = f.ver_nr;


DROP VIEW ONEDATA_WA.VW_NCI_AI;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_AI
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           CAST ('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2 (4000))
               ITEM_ID_STR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
              TRIM (
                  SUBSTR (
                         TRIM (ADMIN_ITEM.ITEM_LONG_NM)
                      || '||'
                      || TRIM (ADMIN_ITEM.ITEM_NM)
                      || '||'
                      || TRIM (ADMIN_ITEM.ITEM_DESC),
                      1,
                      4290))
           || '||'
           || SUBSTR (TRIM (REF_DESC), 1, 30000)
               SEARCH_STR
      FROM ADMIN_ITEM  ADMIN_ITEM,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (TRIM (ref_desc), '||' ON OVERFLOW TRUNCATE)
                         WITHIN GROUP (ORDER BY ref_desc DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) REF                                   --
     WHERE     ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+);


DROP VIEW ONEDATA_WA.VW_NCI_AI_CNCPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_AI_CNCPT
(
    ALT_NMS_LVL,
    ITEM_ID,
    VER_NR,
    CORE_ITEM_ID,
    CORE_VER_NR,
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_ORD,
    NCI_PRMRY_IND,
    NCI_CNCPT_VAL,
    NCI_PRMRY_IND_TXT
)
BEQUEATH DEFINER
AS
    SELECT '5. Object Class'                                  ALT_NMS_LVL,
           DE.ITEM_ID                                         ITEM_ID,
           DE.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC
     WHERE     a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID
           AND a.VER_NR = DE_CONC.OBJ_CLS_VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
    UNION
    SELECT '4. Property'                                      ALT_NMS_LVL,
           DE.ITEM_ID                                         ITEM_ID,
           DE.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC
     WHERE     a.ITEM_ID = DE_CONC.PROP_ITEM_ID
           AND a.VER_NR = DE_CONC.PROP_VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
    UNION
    SELECT '3. Representation Term'                           ALT_NMS_LVL,
           DE.ITEM_ID                                         ITEM_ID,
           DE.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD
     WHERE     a.ITEM_ID = VD.REP_CLS_ITEM_ID
           AND a.VER_NR = VD.REP_CLS_VER_NR
           AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VD.VER_NR
    UNION
    SELECT '1. Value Meaning'                                 ALT_NMS_LVL,
           DE.ITEM_ID                                         ITEM_ID,
           DE.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV
     WHERE     a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID
           AND a.VER_NR = PV.NCI_VAL_MEAN_VER_NR
           AND DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID
           AND DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
    UNION
    SELECT '2. Value Domain'                                  ALT_NMS_LVL,
           DE.ITEM_ID                                         ITEM_ID,
           DE.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE
     WHERE DE.VAL_DOM_ITEM_ID = a.ITEM_ID AND DE.VAL_DOM_VER_NR = a.VER_NR
    UNION
    SELECT '2. Object Class'                                  ALT_NMS_LVL,
           DEC.ITEM_ID                                        ITEM_ID,
           DEC.VER_NR                                         VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC
     WHERE a.ITEM_ID = DEC.OBJ_CLS_ITEM_ID AND a.VER_NR = DEC.OBJ_CLS_VER_NR
    UNION
    SELECT '1. Property'                                      ALT_NMS_LVL,
           DEC.ITEM_ID                                        ITEM_ID,
           DEC.VER_NR                                         VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC
     WHERE a.ITEM_ID = DEC.PROP_ITEM_ID AND a.VER_NR = DEC.PROP_VER_NR
    UNION
    SELECT 'Component Concept'                                ALT_NMS_LVL,
           a.ITEM_ID,
           a.VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a
    UNION
    SELECT 'Representation Term'                              ALT_NMS_LVL,
           VD.ITEM_ID                                         ITEM_ID,
           VD.VER_NR                                          VER_NR,
           a.ITEM_ID                                          CORE_ITEM_ID,
           a.VER_NR                                           CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL,
           DECODE (a.nci_prmry_ind, 1, 'Yes', 'Qualifier')    NCI_PRMRY_IND_TXT
      FROM CNCPT_ADMIN_ITEM a, VALUE_DOM VD
     WHERE a.ITEM_ID = VD.REP_CLS_ITEM_ID AND a.VER_NR = VD.REP_CLS_VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_AI_CURRNT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_AI_CURRNT
(
    DATA_ID_STR,
    ITEM_ID,
    VER_NR,
    CLSFCTN_SCHM_ID,
    ITEM_DESC,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_LONG_NM,
    ITEM_NM,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    CLSFCTN_SCHM_VER_NR,
    ADMIN_ITEM_TYP_ID,
    CURRNT_VER_IND,
    ADMIN_STUS_ID,
    REGSTR_STUS_ID,
    REGISTRR_CNTCT_ID,
    SUBMT_CNTCT_ID,
    STEWRD_CNTCT_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    LEGCY_CD,
    CASE_FILE_ID,
    REGSTR_AUTH_ID,
    BTCH_NR,
    ALT_KEY,
    ABAC_ATTR,
    NCI_IDSEQ,
    ADMIN_STUS_NM_DN,
    CNTXT_NM_DN,
    REGSTR_STUS_NM_DN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    DEF_SRC
)
BEQUEATH DEFINER
AS
    SELECT DATA_ID_STR,
           ITEM_ID,
           VER_NR,
           CLSFCTN_SCHM_ID,
           ITEM_DESC,
           CNTXT_ITEM_ID,
           CNTXT_VER_NR,
           ITEM_LONG_NM,
           ITEM_NM,
           ADMIN_NOTES,
           CHNG_DESC_TXT,
           CREATION_DT,
           EFF_DT,
           ORIGIN,
           UNRSLVD_ISSUE,
           UNTL_DT,
           CLSFCTN_SCHM_VER_NR,
           ADMIN_ITEM_TYP_ID,
           CURRNT_VER_IND,
           ADMIN_STUS_ID,
           REGSTR_STUS_ID,
           REGISTRR_CNTCT_ID,
           SUBMT_CNTCT_ID,
           STEWRD_CNTCT_ID,
           SUBMT_ORG_ID,
           STEWRD_ORG_ID,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           LEGCY_CD,
           CASE_FILE_ID,
           REGSTR_AUTH_ID,
           BTCH_NR,
           ALT_KEY,
           ABAC_ATTR,
           NCI_IDSEQ,
           ADMIN_STUS_NM_DN,
           CNTXT_NM_DN,
           REGSTR_STUS_NM_DN,
           ORIGIN_ID,
           ORIGIN_ID_DN,
           DEF_SRC
      FROM admin_item
     WHERE ADMIN_ITEM.CURRNT_VER_IND = '1';


DROP VIEW ONEDATA_WA.VW_NCI_AI_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_AI_DE
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           '.' || ADMIN_ITEM.ITEM_ID || '.'    ITEM_ID_STR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
              ADMIN_ITEM.ITEM_LONG_NM
           || ADMIN_ITEM.ITEM_NM
           || ADMIN_ITEM.ITEM_DESC             SEARCH_STR
      FROM ADMIN_ITEM;


DROP VIEW ONEDATA_WA.VW_NCI_ALT_DEF;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_ALT_DEF
(
    DEF_ID,
    ALT_DEF_LVL,
    DE_ITEM_ID,
    DE_VER_NR,
    ITEM_ID,
    VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    DEF_DESC,
    NCI_DEF_TYP_ID,
    PREF_DEF_IND,
    LANG_ID,
    CSI_ALT_DEFS,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT ALT_DEF.DEF_ID,
           'CDE'             ALT_DEF_LVL,
           DE_AI.ITEM_ID     DE_ITEM_ID,
           DE_AI.VER_NR      DE_VER_NR,
           ALT_DEF.ITEM_ID,
           ALT_DEF.VER_NR,
           ALT_DEF.CNTXT_ITEM_ID,
           ALT_DEF.CNTXT_VER_NR,
           ALT_DEF.DEF_DESC,
           ALT_DEF.NCI_DEF_TYP_ID,
           ALT_DEF.PREF_DEF_IND,
           ALT_DEF.LANG_ID,
           AGG.CSI_ALT_DEFS,
           ALT_DEF.CREAT_DT,
           ALT_DEF.CREAT_USR_ID,
           ALT_DEF.LST_UPD_USR_ID,
           ALT_DEF.FLD_DELETE,
           ALT_DEF.LST_DEL_DT,
           ALT_DEF.S2P_TRN_DT,
           ALT_DEF.LST_UPD_DT
      FROM ALT_DEF,
           ADMIN_ITEM  DE_AI,
           (  SELECT a.def_id,
                     LISTAGG (cs.item_nm || '/' || ai.item_nm, CHR (10))
                         WITHIN GROUP (ORDER BY a.item_id)    CSI_ALT_DEFS
                FROM alt_def              a,
                     NCI_CSI_ALT_DEFNMS   n,
                     NCI_CLSFCTN_SCHM_ITEM x,
                     admin_item           ai,
                     admin_item           cs,
                     de
               WHERE     n.nmdef_id = a.def_id
                     AND n.nci_pub_id = x.item_id
                     AND x.item_id = ai.item_id
                     AND a.item_id = de.item_id
                     AND a.ver_nr = de.ver_nr
                     AND x.ver_nr = ai.ver_nr
                     AND x.cs_item_id = cs.item_id
                     AND x.cs_item_ver_nr = cs.ver_nr
            GROUP BY a.def_id) agg
     WHERE     DE_AI.ADMIN_ITEM_TYP_ID = 4
           AND ALT_DEF.ITEM_ID = DE_AI.ITEM_ID
           AND ALT_DEF.VER_NR = DE_AI.VER_NR
           AND ALT_DEF.DEF_ID = AGG.DEF_ID(+);


DROP VIEW ONEDATA_WA.VW_NCI_ALT_NMS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_ALT_NMS
(
    NM_ID,
    ALT_NMS_LVL,
    DE_ITEM_ID,
    DE_VER_NR,
    ITEM_ID,
    VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    NM_DESC,
    PREF_NM_IND,
    LANG_ID,
    CSI_ALT_NMS,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NM_TYP_ID
)
BEQUEATH DEFINER
AS
    SELECT ALT_NMS.NM_ID,
           'CDE'             ALT_NMS_LVL,
           DE_AI.ITEM_ID     DE_ITEM_ID,
           DE_AI.VER_NR      DE_VER_NR,
           ALT_NMS.ITEM_ID,
           ALT_NMS.VER_NR,
           ALT_NMS.CNTXT_ITEM_ID,
           ALT_NMS.CNTXT_VER_NR,
           ALT_NMS.NM_DESC,
           ALT_NMS.PREF_NM_IND,
           ALT_NMS.LANG_ID,
           AGG.CSI_ALT_NMS,
           ALT_NMS.CREAT_DT,
           ALT_NMS.CREAT_USR_ID,
           ALT_NMS.LST_UPD_USR_ID,
           ALT_NMS.FLD_DELETE,
           ALT_NMS.LST_DEL_DT,
           ALT_NMS.S2P_TRN_DT,
           ALT_NMS.LST_UPD_DT,
           ALT_NMS.NM_TYP_ID
      FROM ALT_NMS,
           ADMIN_ITEM  DE_AI,
           (  SELECT a.nm_id,
                     LISTAGG (cs.item_nm || '/' || ai.item_nm, CHR (10))
                         WITHIN GROUP (ORDER BY a.item_id)    CSI_ALT_NMS
                FROM alt_nms              a,
                     NCI_CSI_ALT_DEFNMS   n,
                     NCI_CLSFCTN_SCHM_ITEM x,
                     admin_item           ai,
                     admin_item           cs,
                     de
               WHERE     n.nmdef_id = a.nm_id
                     AND n.nci_pub_id = x.ITEM_id
                     AND x.item_id = ai.item_id
                     AND a.item_id = de.item_id
                     AND a.ver_nr = de.ver_nr
                     AND x.ver_nr = ai.ver_nr
                     AND x.cs_item_id = cs.item_id
                     AND x.cs_item_ver_nr = cs.ver_nr
            GROUP BY a.nm_id) agg
     WHERE     DE_AI.ADMIN_ITEM_TYP_ID = 4
           AND ALT_NMS.ITEM_ID = DE_AI.ITEM_ID
           AND ALT_NMS.VER_NR = DE_AI.VER_NR
           AND UPPER (ALT_NMS.NM_DESC) <> UPPER (ALT_NMS.CNTXT_NM_DN)
           AND alt_nms.nm_id = agg.nm_id(+);


DROP VIEW ONEDATA_WA.VW_NCI_CSI_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_CSI_DE
(
    ITEM_ID,
    VER_NR,
    CSI_ITEM_ID,
    CSI_VER_NR,
    CSI_ITEM_NM,
    CS_ITEM_ID,
    CS_VER_NR,
    REL_TYP_ID,
    CSI_ITEM_LONG_NM,
    CSI_ITEM_DESC,
    P_CS_ITEM_ID,
    P_CS_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CSI_SEARCH_STR,
    CS_ITEM_NM,
    CS_ITEM_LONG_NM
)
BEQUEATH DEFINER
AS
    SELECT aim.c_item_id                        item_id,
           aim.c_item_ver_nr                    ver_nr,
           aim.p_item_id                        csi_item_id,
           aim.p_item_ver_nr                    csi_ver_nr,
           csi.item_nm                          csi_ITEM_NM,
           csist.cs_item_id                     CS_ITEM_ID,
           csist.CS_ITEM_VER_NR                 CS_VER_NR,
           aim.rel_typ_id,
           csi.item_long_nm                     csi_item_long_nm,
           csi.item_desc                        csi_item_desc,
           csist.p_item_Id                      p_CS_ITEM_ID,
           csist.P_ITEM_VER_NR                  p_CS_VER_NR,
           aim.CREAT_DT,
           aim.CREAT_USR_ID,
           aim.LST_UPD_USR_ID,
           aim.FLD_DELETE,
           aim.LST_DEL_DT,
           aim.S2P_TRN_DT,
           aim.LST_UPD_DT,
           csi.item_nm || ' ' || cs.ITEM_NM     CSI_SEARCH_STR,
           cs.ITEM_NM                           CS_ITEM_NM,
           cs.ITEM_LONG_NM                      CS_ITEM_LONG_NM
      FROM admin_item             csi,
           NCI_CLSFCTN_SCHM_ITEM  csist,
           nci_admin_item_rel     aim,
           vw_CLSFCTN_SCHM        cs
     WHERE     csi.item_id = aim.p_item_id
           AND csi.ver_nr = aim.p_item_ver_nr
           AND aim.rel_typ_id = 65
           AND csi.item_id = csist.item_id
           AND csi.ver_nr = csist.ver_nr
           AND csist.cs_item_id = cs.item_id
           AND csist.cs_item_ver_nr = cs.ver_nr;


DROP VIEW ONEDATA_WA.VW_NCI_CSI_NM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_CSI_NM
(
    NCI_PUB_ID,
    NCI_VER_NR,
    CSI_NM,
    CSI_LONG_NM,
    CS_NM,
    CS_ITEM_ID,
    CS_VER_NR,
    CSI_ITEM_ID,
    CSI_VER_NR,
    CSI_FULL_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT x.NCI_PUB_ID,
           x.NCI_VER_NR,
           ai.item_nm                                    CSI_NM,
           ai.item_long_nm                               csi_long_nm,
           cs.ITEM_NM                                    CS_NM,
           cs.item_id                                    cs_item_id,
           cs.ver_nr                                     cs_ver_nr,
           ai.item_id                                    csi_item_id,
           ai.ver_nr                                     csi_ver_nr,
           cs.item_long_nm || '/' || ai.item_long_nm     CSI_FULL_NM,
           x.CREAT_DT,
           x.CREAT_USR_ID,
           x.LST_UPD_USR_ID,
           x.FLD_DELETE,
           x.LST_DEL_DT,
           x.S2P_TRN_DT,
           x.LST_UPD_DT
      FROM nci_admin_item_rel_alt_key x, admin_item ai, admin_item cs
     WHERE     x.c_item_id = ai.item_id
           AND x.c_item_ver_nr = ai.ver_nr
           AND x.cntxt_cs_item_id = cs.item_id
           AND x.cntxt_cs_ver_nr = cs.ver_nr
           AND x.rel_typ_id = 64;


DROP VIEW ONEDATA_WA.VW_NCI_CSI_NODE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_CSI_NODE
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_IDSEQ,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    FUL_PATH,
    CS_ITEM_ID,
    CS_VER_NR,
    CS_LONG_NM,
    CS_ITEM_NM,
    CS_ITEM_DESC,
    CS_ADMIN_STUS_NM_DN,
    CLSFCTN_SCHM_TYP_ID
)
BEQUEATH DEFINER
AS
        SELECT ADMIN_ITEM.ITEM_ID,
               ADMIN_ITEM.VER_NR,
               ADMIN_ITEM.ITEM_NM,
               ADMIN_ITEM.ITEM_LONG_NM,
               ADMIN_ITEM.ITEM_DESC,
               CS.CNTXT_NM_DN,
               ADMIN_ITEM.CURRNT_VER_IND,
               ADMIN_ITEM.REGSTR_STUS_NM_DN,
               ADMIN_ITEM.ADMIN_STUS_NM_DN,
               ADMIN_ITEM.CREAT_DT,
               ADMIN_ITEM.CREAT_USR_ID,
               ADMIN_ITEM.LST_UPD_USR_ID,
               ADMIN_ITEM.FLD_DELETE,
               ADMIN_ITEM.LST_DEL_DT,
               ADMIN_ITEM.S2P_TRN_DT,
               ADMIN_ITEM.LST_UPD_DT,
               ADMIN_ITEM.NCI_IDSEQ,
               CSI.P_ITEM_ID,
               CSI.P_ITEM_VER_NR,
               SUBSTR (
                   CAST (
                       SYS_CONNECT_BY_PATH (
                           REPLACE (admin_item.ITEM_NM, '|', ''),
                           ' | ')
                           AS VARCHAR2 (4000)),
                   4)                 FUL_PATH,
               cs.item_id             cs_item_id,
               cs.ver_nr              cs_ver_nr,
               cs.item_long_nm        cs_long_nm,
               cs.item_nm             cs_item_nm,
               cs.item_desc           cs_item_desc,
               cs.admin_stus_nm_dn    cs_admin_stus_nm_dn,
               CS.CLSFCTN_SCHM_TYP_ID
          FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
         WHERE     ADMIN_ITEM_TYP_ID = 51
               AND ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID
               AND ADMIN_ITEM.VER_NR = CSI.VER_NR
               AND csi.cs_item_id = cs.item_id
               AND csi.cs_item_ver_nr = cs.ver_nr
    START WITH p_item_id IS NULL
    CONNECT BY PRIOR csi.item_id = csi.p_item_id;


DROP VIEW ONEDATA_WA.VW_NCI_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    CNTXT_NM_DN,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    CREAT_USR_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID,
    LST_UPD_USR_ID_X,
    REGSTR_STUS_DISP_ORD,
    ADMIN_STUS_DISP_ORD,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    NCI_IDSEQ,
    NCI_PRG_AREA_ID,
    ADMIN_ITEM_TYP_ID,
    CNTXT_AGG,
    PREF_QUEST_TXT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           CAST ('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2 (4000))
               ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID
               CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID
               LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR
               REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR
               ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
           ext.USED_BY
               CNTXT_AGG,
           REF.ref_desc
               PREF_QUEST_TXT,
           CAST (
               SUBSTR (
                      ADMIN_ITEM.ITEM_LONG_NM
                   || '||'
                   || ADMIN_ITEM.ITEM_NM
                   || '||'
                   || NVL (ref_desc.ref_desc, ''),
                   1,
                   4000)
                   AS VARCHAR2 (4000))
               SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
           NCI_ADMIN_ITEM_EXT  ext,
           (SELECT item_id, ver_nr, ref_desc
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_nm, '||')
                         WITHIN GROUP (ORDER BY OBJ_KEY_DESC DESC)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           --and ADMIN_ITEM.ITEM_Id = de.item_id
           --and ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DEC_CNCPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DEC_CNCPT
(
    ALT_NMS_LVL,
    DEC_ITEM_ID,
    DEC_VER_NR,
    ITEM_ID,
    VER_NR,
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_ORD,
    NCI_PRMRY_IND,
    NCI_CNCPT_VAL
)
BEQUEATH DEFINER
AS
    SELECT '2. Object Class'     ALT_NMS_LVL,
           DEC.ITEM_ID           DEC_ITEM_ID,
           DEC.VER_NR            DEC_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC
     WHERE a.ITEM_ID = DEC.OBJ_CLS_ITEM_ID AND a.VER_NR = DEC.OBJ_CLS_VER_NR
    UNION
    SELECT '1. Property'     ALT_NMS_LVL,
           DEC.ITEM_ID       DEC_ITEM_ID,
           DEC.VER_NR        DEC_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE_CONC DEC
     WHERE a.ITEM_ID = DEC.PROP_ITEM_ID AND a.VER_NR = DEC.PROP_VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_CNCPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_CNCPT
(
    ALT_NMS_LVL,
    DE_ITEM_ID,
    DE_VER_NR,
    ITEM_ID,
    VER_NR,
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_ORD,
    NCI_PRMRY_IND,
    NCI_CNCPT_VAL
)
BEQUEATH DEFINER
AS
    SELECT '5. Object Class'     ALT_NMS_LVL,
           DE.ITEM_ID            DE_ITEM_ID,
           DE.VER_NR             DE_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC
     WHERE     a.ITEM_ID = DE_CONC.OBJ_CLS_ITEM_ID
           AND a.VER_NR = DE_CONC.OBJ_CLS_VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
    UNION
    SELECT '4. Property'     ALT_NMS_LVL,
           DE.ITEM_ID        DE_ITEM_ID,
           DE.VER_NR         DE_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE, DE_CONC
     WHERE     a.ITEM_ID = DE_CONC.PROP_ITEM_ID
           AND a.VER_NR = DE_CONC.PROP_VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
    UNION
    SELECT '3. Representation Term'     ALT_NMS_LVL,
           DE.ITEM_ID                   DE_ITEM_ID,
           DE.VER_NR                    DE_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE, VALUE_DOM VD
     WHERE     a.ITEM_ID = VD.REP_CLS_ITEM_ID
           AND a.VER_NR = VD.REP_CLS_VER_NR
           AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VD.VER_NR
    UNION
    SELECT '1. Value Meaning'     ALT_NMS_LVL,
           DE.ITEM_ID             DE_ITEM_ID,
           DE.VER_NR              DE_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE, PERM_VAL PV
     WHERE     a.ITEM_ID = PV.NCI_VAL_MEAN_ITEM_ID
           AND a.VER_NR = PV.NCI_VAL_MEAN_VER_NR
           AND DE.VAL_DOM_ITEM_ID = PV.VAL_DOM_ITEM_ID
           AND DE.VAL_DOM_VER_NR = PV.VAL_DOM_VER_NR
    UNION
    SELECT '2. Value Domain'     ALT_NMS_LVL,
           DE.ITEM_ID            DE_ITEM_ID,
           DE.VER_NR             DE_VER_NR,
           a.ITEM_ID,
           a.VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, DE
     WHERE DE.VAL_DOM_ITEM_ID = a.ITEM_ID AND DE.VAL_DOM_VER_NR = a.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_EXCEL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_EXCEL
(
    NCI_IDSEQ,
    ITEM_ID,
    VER_NR,
    CDE_ID,
    LONG_NAME,
    PREFERRED_NAME,
    PREFERRED_DEFINITION,
    VERSION,
    ORIGIN,
    DE_CONTE_NAME,
    DEC_ID,
    DEC_PREFERRED_NAME,
    DEC_VERSION,
    VD_ID,
    VD_PREFERRED_NAME,
    VD_LONG_NM,
    VD_VERSION,
    VD_CONTE_NAME,
    VALID_VALUES
)
BEQUEATH DEFINER
AS
    SELECT de.nci_idseq,
           de.item_id,
           de.ver_Nr,
           de.item_id                           cde_id,
           de.item_long_nm                      long_name,
           de.item_nm                           preferred_name,
           --rd.doc_text,
           de.item_desc                         preferred_definition,
           de.ver_nr                            version,
           de.origin,
           --            de.begin_date,
           de.cntxt_nm                          de_conte_name,
           --            de_conte.version de_conte_version,
           de1.de_conc_item_id                  dec_id,
           dec.item_desc                        dec_preferred_name,
           dec.ver_nr                           dec_version,
           --            dec_conte.name dec_conte_name,
           --            dec_conte.version dec_conte_version,
           vd.item_id                           vd_id,
           vd.item_desc                         vd_preferred_name,
           vd.item_long_nm                      vd_long_nm,
           vd.ver_nr                            vd_version,
           vd.cntxt_nm                          vd_conte_name,
           CAST (
               MULTISET (
                   SELECT pv.PERM_VAL_NM,
                          vm.item_nm       short_meaning,
                          vm.item_desc     preferred_definition,
                          vm.item_id       vm_id,
                          vm.ver_nr        version
                     FROM perm_val pv, admin_item vm
                    WHERE     pv.val_dom_item_id = vd.item_id
                          AND pv.val_dom_ver_nr = vd.ver_nr
                          AND pv.NCI_VAL_MEAN_ITEM_ID = vm.item_id
                          AND pv.NCI_VAL_MEAN_VER_NR = vm.ver_nr)
                   AS DE_VALID_VALUE_LIST_T)    valid_values
      FROM admin_item  de,
           admin_item  dec,
           admin_item  vd,
           de          de1
     WHERE     de1.de_conc_item_id = dec.item_id
           AND de1.val_dom_item_id = vd.item_id
           AND de1.de_conc_ver_nr = dec.ver_nr
           AND de1.val_dom_ver_nr = vd.ver_nr
           AND de1.item_id = de.item_id
           AND de1.ver_nr = de.ver_nr
           AND UPPER (de.item_long_nm) LIKE '%STOMACH%'


/*
  SELECT   de.nci_idseq,
	   de.item_id,
           de.ver_Nr,
            de.item_id cde_id,
            de.item_long_nm long_name,
            de.item_nm preferred_name,
            --rd.doc_text,
            de.item_desc preferred_definition,
            de.ver_nr version,
            de.origin,
--            de.begin_date,
            de.cntxt_nm de_conte_name,
--            de_conte.version de_conte_version,
            de.dec_item_id dec_id,
            dec.item_desc dec_preferred_name,
            dec.ver_nr dec_version,
--            dec_conte.name dec_conte_name,
--            dec_conte.version dec_conte_version,
            vd.item_id vd_id,
            vd.item_desc vd_preferred_name,
            vd.item_long_nm vd_long_nm,
            vd.ver_nr  vd_version,
            vd.cntxt_nm vd_conte_name,
            CAST (
               MULTISET(SELECT   pv.VALUE,
                                 vm.item_nm short_meaning,
                                 vm.item_desc preferred_definition,
                                 vm.item_id vm_id,
                                 vm.ver_nr version
                          FROM   perm_val pv,
                                 admin_item vm
                         WHERE       pv.val_dom_item_id = vd.item_id
                                and pv.val_dom_ver_nr = vd.ver_nr
                                 AND pv.NCI_VAL_MEAN_ITEM_ID = vm.item_id
				and pv.NCI_VAL_MEAN_VER_NR = vm.ver_nr
                                                                   ) AS DE_VALID_VALUE_LIST_T
            )
               valid_values,
            CAST (
               MULTISET(SELECT   rd.ref_nm,
--                                 rd.DCTL_NAME,
                                 rd.ref_desc,
 --                                rd.URL,
                                 rd.disp_ord
                          FROM   ref rd
                         WHERE   de.item_id = rd.item_id(+)
				 and de.ver_nr = rd.ver_nr(+)
                           ) AS cdebrowser_rd_list_t
            )               reference_docs
     FROM   admin_item de,
            admin_item dec,
            admin_item vd,
            de  de1
    WHERE       de1.de_conc_item_id = dec.item_id
            AND de1.val_dom_item_id = vd.item_id
	    and de1.de_conc_ver_nr = dec.ver_nr
	    and de1.val_dom_ver_nr = vd.ver_nr
	    and de1.item_id = de.item_id 
	    and de1.ver_nr = de.ver_nr;

*/
;


DROP VIEW ONEDATA_WA.VW_NCI_DE_HORT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_HORT
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    ORIGIN_ID,
    ORIGIN,
    ORIGIN_ID_DN,
    UNTL_DT,
    CURRNT_VER_IND,
    REGISTRR_CNTCT_ID,
    SUBMT_CNTCT_ID,
    STEWRD_CNTCT_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    REGSTR_AUTH_ID,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    PREF_QUEST_TXT,
    DE_PREC,
    DE_CONC_ITEM_ID,
    DE_CONC_VER_NR,
    VAL_DOM_VER_NR,
    VAL_DOM_ITEM_ID,
    REP_CLS_VER_NR,
    REP_CLS_ITEM_ID,
    DERV_DE_IND,
    DERV_MTHD,
    DERV_RUL,
    DERV_TYP_ID,
    CONCAT_CHAR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    CREAT_USR_ID_API,
    LST_UPD_USR_ID_API,
    CREAT_DT_API,
    LST_UPD_DT_API,
    CONC_DOM_VER_NR,
    CONC_DOM_ITEM_ID,
    NON_ENUM_VAL_DOM_DESC,
    UOM_ID,
    VAL_DOM_TYP_ID,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_HIGH_VAL_NUM,
    VAL_DOM_LOW_VAL_NUM,
    VAL_DOM_FMT_ID,
    CHAR_SET_ID,
    VALUE_DOM_CREAT_DT,
    VALUE_DOM_USR_ID,
    VALUE_DOM_LST_UPD_USR_ID,
    VALUE_DOM_LST_UPD_DT,
    VALUE_DOM_ITEM_NM,
    VALUE_DOM_ITEM_LONG_NM,
    VALUE_DOM_ITEM_DESC,
    VALUE_DOM_CNTXT_NM,
    VALUE_DOM_CURRNT_VER_IND,
    VALUE_DOM_REGSTR_STUS_NM,
    VALUE_DOM_ADMIN_STUS_NM,
    NCI_STD_DTTYPE_ID,
    DTTYPE_ID,
    NCI_DEC_PREC,
    DEC_ITEM_NM,
    DEC_ITEM_LONG_NM,
    DEC_ITEM_DESC,
    DEC_CNTXT_NM,
    DEC_CURRNT_VER_IND,
    DEC_REGSTR_STUS_NM,
    DEC_ADMIN_STUS_NM,
    DEC_CREAT_DT,
    DEC_USR_ID,
    DEC_LST_UPD_USR_ID,
    DEC_LST_UPD_DT,
    OBJ_CLS_ITEM_ID,
    OBJ_CLS_VER_NR,
    OBJ_CLS_ITEM_NM,
    OBJ_CLS_ITEM_LONG_NM,
    OC_CNCPT_CONCAT,
    OC_CNCPT_CONCAT_NM,
    PROP_ITEM_NM,
    PROP_ITEM_LONG_NM,
    PROP_ITEM_ID,
    PROP_VER_NR,
    PROP_CNCPT_CONCAT,
    PROP_CNCPT_CONCAT_NM,
    DEC_CD_ITEM_ID,
    DEC_CD_VER_NR,
    DEC_CD_ITEM_NM,
    DEC_CD_ITEM_LONG_NM,
    DEC_CD_ITEM_DESC,
    DEC_CD_CNTXT_NM,
    DEC_CD_CURRNT_VER_IND,
    DEC_CD_REGSTR_STUS_NM,
    DEC_CD_ADMIN_STUS_NM,
    CD_ITEM_NM,
    CD_ITEM_LONG_NM,
    CD_ITEM_DESC,
    CD_CNTXT_NM,
    CD_CURRNT_VER_IND,
    CD_REGSTR_STUS_NM,
    CD_ADMIN_STUS_NM,
    ADMIN_ITEM_TYP_ID,
    CNTXT_AGG,
    LST_UPD_CHG_DAYS
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID                ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           DE.PREF_QUEST_TXT,
           DE.DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           DE.DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID           CREAT_USR_ID_API,
           ADMIN_ITEM.LST_UPD_USR_ID         LST_UPD_USR_ID_API,
           ADMIN_ITEM.CREAT_DT               CREAT_DT_API,
           ADMIN_ITEM.LST_UPD_DT             LST_UPD_DT_API,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID          VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM_AI.CREAT_DT             VALUE_DOM_CREAT_DT,
           VALUE_DOM_AI.CREAT_USR_ID         VALUE_DOM_USR_ID,
           VALUE_DOM_AI.LST_UPD_USR_ID       VALUE_DOM_LST_UPD_USR_ID,
           VALUE_DOM_AI.LST_UPD_DT           VALUE_DOM_LST_UPD_DT,
           VALUE_DOM_AI.ITEM_NM              VALUE_DOM_ITEM_NM,
           VALUE_DOM_AI.ITEM_LONG_NM         VALUE_DOM_ITEM_LONG_NM,
           VALUE_DOM_AI.ITEM_DESC            VALUE_DOM_ITEM_DESC,
           VALUE_DOM_AI.CNTXT_NM_DN          VALUE_DOM_CNTXT_NM,
           VALUE_DOM_AI.CURRNT_VER_IND       VALUE_DOM_CURRNT_VER_IND,
           VALUE_DOM_AI.REGSTR_STUS_NM_DN    VALUE_DOM_REGSTR_STUS_NM,
           VALUE_DOM_AI.ADMIN_STUS_NM_DN     VALUE_DOM_ADMIN_STUS_NM,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.NCI_DEC_PREC,
           DEC_AI.ITEM_NM                    DEC_ITEM_NM,
           DEC_AI.ITEM_LONG_NM               DEC_ITEM_LONG_NM,
           DEC_AI.ITEM_DESC                  DEC_ITEM_DESC,
           DEC_AI.CNTXT_NM_DN                DEC_CNTXT_NM,
           DEC_AI.CURRNT_VER_IND             DEC_CURRNT_VER_IND,
           DEC_AI.REGSTR_STUS_NM_DN          DEC_REGSTR_STUS_NM,
           DEC_AI.ADMIN_STUS_NM_DN           DEC_ADMIN_STUS_NM,
           DEC_AI.CREAT_DT                   DEC_CREAT_DT,
           DEC_AI.CREAT_USR_ID               DEC_USR_ID,
           DEC_AI.LST_UPD_USR_ID             DEC_LST_UPD_USR_ID,
           DEC_AI.LST_UPD_DT                 DEC_LST_UPD_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           OC.ITEM_NM                        OBJ_CLS_ITEM_NM,
           OC.ITEM_LONG_NM                   OBJ_CLS_ITEM_LONG_NM,
           CONOC.CNCPT_CONCAT                OC_CNCPT_CONCAT,
           CONOC.CNCPT_CONCAT_NM             OC_CNCPT_CONCAT_NM,
           PROP.ITEM_NM                      PROP_ITEM_NM,
           PROP.ITEM_LONG_NM                 PROP_ITEM_LONG_NM,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           CONPROP.CNCPT_CONCAT              PROP_CNCPT_CONCAT,
           CONPROP.CNCPT_CONCAT_NM           PROP_CNCPT_CONCAT_NM,
           DE_CONC.CONC_DOM_ITEM_ID          DEC_CD_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR           DEC_CD_VER_NR,
           DEC_CD.ITEM_NM                    DEC_CD_ITEM_NM,
           DEC_CD.ITEM_LONG_NM               DEC_CD_ITEM_LONG_NM,
           DEC_CD.ITEM_DESC                  DEC_CD_ITEM_DESC,
           DEC_CD.CNTXT_NM_DN                DEC_CD_CNTXT_NM,
           DEC_CD.CURRNT_VER_IND             DEC_CD_CURRNT_VER_IND,
           DEC_CD.REGSTR_STUS_NM_DN          DEC_CD_REGSTR_STUS_NM,
           DEC_CD.ADMIN_STUS_NM_DN           DEC_CD_ADMIN_STUS_NM,
           CD_AI.ITEM_NM                     CD_ITEM_NM,
           CD_AI.ITEM_LONG_NM                CD_ITEM_LONG_NM,
           CD_AI.ITEM_DESC                   CD_ITEM_DESC,
           CD_AI.CNTXT_NM_DN                 CD_CNTXT_NM,
           CD_AI.CURRNT_VER_IND              CD_CURRNT_VER_IND,
           CD_AI.REGSTR_STUS_NM_DN           CD_REGSTR_STUS_NM,
           CD_AI.ADMIN_STUS_NM_DN            CD_ADMIN_STUS_NM,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ''                                CNTXT_AGG,
             SYSDATE
           - GREATEST (DE.LST_UPD_DT,
                       admin_item.lst_upd_dt,
                       Value_dom.LST_UPD_DT,
                       dec_ai.LST_UPD_DT)    LST_UPD_CHG_DAYS
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           ADMIN_ITEM          VALUE_DOM_AI,
           ADMIN_ITEM          DEC_AI,
           DE_CONC,
           VW_CONC_DOM         DEC_CD,
           VW_CONC_DOM         CD_AI,
           ADMIN_ITEM          OC,
           ADMIN_ITEM          PROP,
           NCI_ADMIN_ITEM_EXT  CONOC,
           NCI_ADMIN_ITEM_EXT  CONPROP
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           AND OC.ITEM_ID = CONOC.ITEM_ID
           AND OC.VER_NR = CONOC.VER_NR
           AND PROP.ITEM_ID = CONPROP.ITEM_ID
           AND PROP.VER_NR = CONPROP.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_HORT_TEST;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_HORT_TEST
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    ORIGIN_ID,
    ORIGIN,
    ORIGIN_ID_DN,
    UNTL_DT,
    CURRNT_VER_IND,
    REGISTRR_CNTCT_ID,
    SUBMT_CNTCT_ID,
    STEWRD_CNTCT_ID,
    SUBMT_ORG_ID,
    STEWRD_ORG_ID,
    REGSTR_AUTH_ID,
    DE_PREC,
    DE_CONC_ITEM_ID,
    DE_CONC_VER_NR,
    VAL_DOM_VER_NR,
    VAL_DOM_ITEM_ID,
    REP_CLS_VER_NR,
    REP_CLS_ITEM_ID,
    DERV_DE_IND,
    DERV_MTHD,
    DERV_RUL,
    DERV_TYP_ID,
    CONCAT_CHAR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    CREAT_USR_ID_API,
    LST_UPD_USR_ID_API,
    CREAT_DT_API,
    LST_UPD_DT_API,
    CONC_DOM_VER_NR,
    CONC_DOM_ITEM_ID,
    NON_ENUM_VAL_DOM_DESC,
    UOM_ID,
    VAL_DOM_TYP_ID,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_HIGH_VAL_NUM,
    VAL_DOM_LOW_VAL_NUM,
    VAL_DOM_FMT_ID,
    CHAR_SET_ID,
    VALUE_DOM_CREAT_DT,
    VALUE_DOM_USR_ID,
    VALUE_DOM_LST_UPD_USR_ID,
    VALUE_DOM_LST_UPD_DT,
    VALUE_DOM_ITEM_NM,
    VALUE_DOM_ITEM_LONG_NM,
    VALUE_DOM_ITEM_DESC,
    VALUE_DOM_CNTXT_NM,
    VALUE_DOM_CURRNT_VER_IND,
    VALUE_DOM_REGSTR_STUS_NM,
    VALUE_DOM_ADMIN_STUS_NM,
    NCI_STD_DTTYPE_ID,
    DTTYPE_ID,
    NCI_DEC_PREC,
    DEC_ITEM_NM,
    DEC_ITEM_LONG_NM,
    DEC_ITEM_DESC,
    DEC_CNTXT_NM,
    DEC_CURRNT_VER_IND,
    DEC_REGSTR_STUS_NM,
    DEC_ADMIN_STUS_NM,
    DEC_CREAT_DT,
    DEC_USR_ID,
    DEC_LST_UPD_USR_ID,
    DEC_LST_UPD_DT,
    OBJ_CLS_ITEM_ID,
    OBJ_CLS_VER_NR,
    OBJ_CLS_ITEM_NM,
    OBJ_CLS_ITEM_LONG_NM,
    OC_CNCPT_CONCAT,
    OC_CNCPT_CONCAT_NM,
    PROP_ITEM_NM,
    PROP_ITEM_LONG_NM,
    PROP_ITEM_ID,
    PROP_VER_NR,
    PROP_CNCPT_CONCAT,
    PROP_CNCPT_CONCAT_NM,
    DEC_CD_ITEM_ID,
    DEC_CD_VER_NR,
    DEC_CD_ITEM_NM,
    DEC_CD_ITEM_LONG_NM,
    DEC_CD_ITEM_DESC,
    DEC_CD_CNTXT_NM,
    DEC_CD_CURRNT_VER_IND,
    DEC_CD_REGSTR_STUS_NM,
    DEC_CD_ADMIN_STUS_NM,
    CD_ITEM_NM,
    CD_ITEM_LONG_NM,
    CD_ITEM_DESC,
    CD_CNTXT_NM,
    CD_CURRNT_VER_IND,
    CD_REGSTR_STUS_NM,
    CD_ADMIN_STUS_NM,
    ADMIN_ITEM_TYP_ID,
    CNTXT_AGG,
    LST_UPD_CHG_DAYS
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID                ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           DE.DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           DE.DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
           DE.CREAT_USR_ID,
           DE.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           DE.LST_UPD_DT,
           DE.CREAT_DT,
           DE.CREAT_USR_ID                   CREAT_USR_ID_API,
           DE.LST_UPD_USR_ID                 LST_UPD_USR_ID_API,
           DE.CREAT_DT                       CREAT_DT_API,
           DE.LST_UPD_DT                     LST_UPD_DT_API,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID          VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM.CREAT_DT                VALUE_DOM_CREAT_DT,
           VALUE_DOM.CREAT_USR_ID            VALUE_DOM_USR_ID,
           VALUE_DOM.LST_UPD_USR_ID          VALUE_DOM_LST_UPD_USR_ID,
           VALUE_DOM.LST_UPD_DT              VALUE_DOM_LST_UPD_DT,
           VALUE_DOM_AI.ITEM_NM              VALUE_DOM_ITEM_NM,
           VALUE_DOM_AI.ITEM_LONG_NM         VALUE_DOM_ITEM_LONG_NM,
           VALUE_DOM_AI.ITEM_DESC            VALUE_DOM_ITEM_DESC,
           VALUE_DOM_AI.CNTXT_NM_DN          VALUE_DOM_CNTXT_NM,
           VALUE_DOM_AI.CURRNT_VER_IND       VALUE_DOM_CURRNT_VER_IND,
           VALUE_DOM_AI.REGSTR_STUS_NM_DN    VALUE_DOM_REGSTR_STUS_NM,
           VALUE_DOM_AI.ADMIN_STUS_NM_DN     VALUE_DOM_ADMIN_STUS_NM,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.NCI_DEC_PREC,
           DEC_AI.ITEM_NM                    DEC_ITEM_NM,
           DEC_AI.ITEM_LONG_NM               DEC_ITEM_LONG_NM,
           DEC_AI.ITEM_DESC                  DEC_ITEM_DESC,
           DEC_AI.CNTXT_NM_DN                DEC_CNTXT_NM,
           DEC_AI.CURRNT_VER_IND             DEC_CURRNT_VER_IND,
           DEC_AI.REGSTR_STUS_NM_DN          DEC_REGSTR_STUS_NM,
           DEC_AI.ADMIN_STUS_NM_DN           DEC_ADMIN_STUS_NM,
           DEC_AI.CREAT_DT                   DEC_CREAT_DT,
           DEC_AI.CREAT_USR_ID               DEC_USR_ID,
           DEC_AI.LST_UPD_USR_ID             DEC_LST_UPD_USR_ID,
           DEC_AI.LST_UPD_DT                 DEC_LST_UPD_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           OC.ITEM_NM                        OBJ_CLS_ITEM_NM,
           OC.ITEM_LONG_NM                   OBJ_CLS_ITEM_LONG_NM,
           CONOC.CNCPT_CONCAT,
           CONOC.CNCPT_CONCAT_NM,
           PROP.ITEM_NM                      PROP_ITEM_NM,
           PROP.ITEM_LONG_NM                 PROP_ITEM_LONG_NM,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           CONPROP.CNCPT_CONCAT,
           CONPROP.CNCPT_CONCAT_NM,
           DE_CONC.CONC_DOM_ITEM_ID          DEC_CD_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR           DEC_CD_VER_NR,
           DEC_CD.ITEM_NM                    DEC_CD_ITEM_NM,
           DEC_CD.ITEM_LONG_NM               DEC_CD_ITEM_LONG_NM,
           DEC_CD.ITEM_DESC                  DEC_CD_ITEM_DESC,
           DEC_CD.CNTXT_NM_DN                DEC_CD_CNTXT_NM,
           DEC_CD.CURRNT_VER_IND             DEC_CD_CURRNT_VER_IND,
           DEC_CD.REGSTR_STUS_NM_DN          DEC_CD_REGSTR_STUS_NM,
           DEC_CD.ADMIN_STUS_NM_DN           DEC_CD_ADMIN_STUS_NM,
           CD_AI.ITEM_NM                     CD_ITEM_NM,
           CD_AI.ITEM_LONG_NM                CD_ITEM_LONG_NM,
           CD_AI.ITEM_DESC                   CD_ITEM_DESC,
           CD_AI.CNTXT_NM_DN                 CD_CNTXT_NM,
           CD_AI.CURRNT_VER_IND              CD_CURRNT_VER_IND,
           CD_AI.REGSTR_STUS_NM_DN           CD_REGSTR_STUS_NM,
           CD_AI.ADMIN_STUS_NM_DN            CD_ADMIN_STUS_NM,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ''                                CNTXT_AGG,
             SYSDATE
           - GREATEST (DE.LST_UPD_DT,
                       admin_item.lst_upd_dt,
                       Value_dom.LST_UPD_DT,
                       dec_ai.LST_UPD_DT)    LST_UPD_CHG_DAYS
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           ADMIN_ITEM          VALUE_DOM_AI,
           ADMIN_ITEM          DEC_AI,
           DE_CONC,
           VW_CONC_DOM         DEC_CD,
           VW_CONC_DOM         CD_AI,
           ADMIN_ITEM          OC,
           ADMIN_ITEM          PROP,
           NCI_ADMIN_ITEM_EXT  CONOC,
           NCI_ADMIN_ITEM_EXT  CONPROP
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           AND OC.ITEM_ID = CONOC.ITEM_ID
           AND OC.VER_NR = CONOC.VER_NR
           AND PROP.ITEM_ID = CONPROP.ITEM_ID
           AND PROP.VER_NR = CONPROP.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_OLD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_OLD
(
    ITEM_ID,
    VER_NR,
    ITEM_ID_STR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    ADMIN_NOTES,
    CHNG_DESC_TXT,
    CREATION_DT,
    EFF_DT,
    ORIGIN,
    ORIGIN_ID,
    ORIGIN_ID_DN,
    UNRSLVD_ISSUE,
    UNTL_DT,
    CURRNT_VER_IND,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    CNTXT_NM_DN,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    CREAT_USR_ID,
    CREAT_USR_ID_X,
    LST_UPD_USR_ID,
    LST_UPD_USR_ID_X,
    REGSTR_STUS_DISP_ORD,
    ADMIN_STUS_DISP_ORD,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CREAT_DT,
    NCI_IDSEQ,
    NCI_PRG_AREA_ID,
    ADMIN_ITEM_TYP_ID,
    CNTXT_AGG,
    PREF_QUEST_TXT,
    SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           '.' || ADMIN_ITEM.ITEM_ID || '.'    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR                    REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR                    ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
           ext.USED_BY                         CNTXT_AGG,
           REF.ref_desc                        PREF_QUEST_TXT,
           SUBSTR (
                  ADMIN_ITEM.ITEM_LONG_NM
               || '||'
               || ADMIN_ITEM.ITEM_NM
               || '||'
               || NVL (REF.ref_desc, ''),
               1,
               4000)                           SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
           NCI_ADMIN_ITEM_EXT  ext,
           (SELECT item_id, ver_nr, ref_desc
              FROM REF
             WHERE ref_typ_id = 80) REF,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           --and ADMIN_ITEM.ITEM_Id = de.item_id
           --and ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_PV;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_PV
(
    PERM_VAL_BEG_DT,
    PERM_VAL_END_DT,
    PERM_VAL_NM,
    PERM_VAL_DESC_TXT,
    DE_ITEM_ID,
    DE_VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    NCI_VAL_MEAN_ITEM_ID,
    NCI_VAL_MEAN_VER_NR,
    CNCPT_CONCAT,
    CNCPT_CONCAT_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    PRNT_CNCPT_ITEM_ID,
    PRNT_CNCPT_VER_NR,
    VM_SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT PV.PERM_VAL_BEG_DT,
           PERM_VAL_END_DT,
           PERM_VAL_NM,
           PERM_VAL_DESC_TXT,
           DE.ITEM_ID                           DE_ITEM_ID,
           DE.VER_NR                            DE_VER_NR,
           VM.ITEM_NM,
           VM.ITEM_LONG_NM,
           VM.ITEM_DESC,
           NCI_VAL_MEAN_ITEM_ID,
           NCI_VAL_MEAN_VER_NR,
           DECODE (e.cncpt_concat,
                   e.cncpt_concat_nm, NULL,
                   vm.item_long_nm, NULL,
                   vm.item_id, NULL,
                   e.cncpt_concat)              cncpt_concat,
           e.CNCPT_CONCAT_NM,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT,
           PV.PRNT_CNCPT_ITEM_ID,
           PV.PRNT_CNCPT_VER_NR,
           VM.ITEM_NM || ' ' || VM.ITEM_DESC    VM_SEARCH_STR
      FROM DE,
           PERM_VAL            PV,
           ADMIN_ITEM          VM,
           NCI_ADMIN_ITEM_EXT  e
     WHERE     PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID
           AND PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR
           AND VM.ITEM_ID = e.ITEM_ID
           AND VM.VER_NR = e.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_PV_LEAN;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_PV_LEAN
(
    PERM_VAL_BEG_DT,
    PERM_VAL_END_DT,
    PERM_VAL_NM,
    ITEM_NM,
    DE_ITEM_ID,
    DE_VER_NR,
    NCI_VAL_MEAN_ITEM_ID,
    NCI_VAL_MEAN_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT PV.PERM_VAL_BEG_DT,
           PERM_VAL_END_DT,
           PERM_VAL_NM,
           PERM_VAL_DESC_TXT     ITEM_NM,
           DE.ITEM_ID            DE_ITEM_ID,
           DE.VER_NR             DE_VER_NR,
           NCI_VAL_MEAN_ITEM_ID,
           NCI_VAL_MEAN_VER_NR,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT
      FROM DE, PERM_VAL PV
     WHERE     PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID
           AND PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_VM_ALT_DEF;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_VM_ALT_DEF
(
    DE_ITEM_ID,
    DE_VER_NR,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR,
    VAL_MEAN_LONG_NM,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DEF_DESC,
    NCI_DEF_TYP_ID,
    LANG_ID,
    DEF_ID,
    PERM_VAL_NM,
    PERM_VAL_DESC_TXT,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR
)
BEQUEATH DEFINER
AS
    SELECT DE.ITEM_ID                  DE_ITEM_ID,
           DE.VER_NR                   DE_VER_NR,
           PV.NCI_VAL_MEAN_ITEM_ID     VAL_MEAN_ITEM_ID,
           PV.NCI_VAL_MEAN_VER_NR      VAL_MEAN_VER_NR,
           vm.ITEM_NM                  VAL_MEAN_LONG_NM,
           PV.VAL_DOM_ITEM_ID          VAL_DOM_ITEM_ID,
           PV.VAL_DOM_VER_NR           VAL_DOM_VER_NR,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT,
           an.DEF_DESC,
           an.NCI_DEF_TYP_ID,
           an.LANG_ID,
           an.def_id,
           PV.PERM_VAL_NM,
           PV.PERM_VAL_DESC_TXT,
           an.CNTXT_ITEM_ID,
           an.CNTXT_VER_NR
      FROM DE,
           PERM_VAL    PV,
           ALT_DEF     an,
           ADMIN_ITEM  vm
     WHERE     PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID
           AND PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = an.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = an.VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_DE_VM_ALT_NMS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_DE_VM_ALT_NMS
(
    DE_ITEM_ID,
    DE_VER_NR,
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR,
    VAL_MEAN_LONG_NM,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NM_DESC,
    NM_TYP_ID,
    VM_CNTXT_NM_DN,
    LANG_ID,
    NM_ID,
    PERM_VAL_NM,
    PERM_VAL_DESC_TXT
)
BEQUEATH DEFINER
AS
    SELECT DE.ITEM_ID                  DE_ITEM_ID,
           DE.VER_NR                   DE_VER_NR,
           PV.NCI_VAL_MEAN_ITEM_ID     VAL_MEAN_ITEM_ID,
           PV.NCI_VAL_MEAN_VER_NR      VAL_MEAN_VER_NR,
           vm.ITEM_NM                  VAL_MEAN_LONG_NM,
           PV.VAL_DOM_ITEM_ID          VAL_DOM_ITEM_ID,
           PV.VAL_DOM_VER_NR           VAL_DOM_VER_NR,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT,
           an.NM_DESC,
           an.nm_typ_id,
           an.CNTXT_NM_DN              VM_CNTXT_NM_DN,
           an.LANG_ID,
           an.nm_id,
           PV.PERM_VAL_NM,
           PV.PERM_VAL_DESC_TXT
      FROM DE,
           PERM_VAL    PV,
           ALT_NMS     an,
           ADMIN_ITEM  vm
     WHERE     PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID
           AND PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = an.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = an.VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_FORM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_FORM
(
    P_ITEM_ID,
    P_ITEM_VER_NR,
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    REGSTR_STUS_ID,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ADMIN_ITEM_TYP_NM,
    CATGRY_ID,
    FORM_TYP_ID,
    ADMIN_STUS_ID,
    HDR_INSTR,
    FTR_INSTR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DISP_ORD,
    REP_NO
)
BEQUEATH DEFINER
AS
    SELECT air.p_item_id,
           air.p_item_ver_nr,
           ai.item_id,
           ai.ver_nr,
           ai.item_nm,
           ai.item_long_nm,
           ai.item_desc,
           ai.REGSTR_STUS_ID,
           ai.cntxt_item_id,
           ai.cntxt_ver_nr,
           'FORM'     admin_item_typ_nm,
           f.catgry_id,
           f.FORM_TYP_ID,
           ai.admin_stus_id,
           f.HDR_INSTR,
           f.FTR_INSTR,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT,
           air.disp_ord,
           air.rep_no
      FROM admin_item ai, nci_admin_item_rel air, nci_form f
     WHERE     ai.item_id = air.c_item_id
           AND ai.ver_nr = air.c_item_ver_nr
           AND air.rel_typ_id = 60
           AND ai.item_id = f.item_id
           AND ai.ver_nr = f.ver_nr;


DROP VIEW ONEDATA_WA.VW_NCI_FORM_FLAT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_FORM_FLAT
(
    FRM_ITEM_LONG_NM,
    FRM_ITEM_NM,
    FRM_ITEM_ID,
    FRM_VER_NR,
    FRM_ITEM_DEF,
    HDR_INSTR,
    FTR_INSTR,
    MOD_ITEM_ID,
    MOD_VER_NR,
    MOD_INSTR,
    DE_ITEM_ID,
    DE_VER_NR,
    QUEST_DISP_ORD,
    MOD_DISP_ORD,
    MOD_REP_NO,
    MOD_ITEM_NM,
    QUEST_INSTR,
    QUEST_REQ_IND,
    QUEST_DEFLT_VAL,
    QUEST_EDIT_IND,
    MOD_ITEM_LONG_NM,
    MOD_ITEM_DESC,
    QUEST_ITEM_ID,
    QUEST_VER_NR,
    CDE_CNTXT_NM,
    CDE_ITEM_NM,
    CDE_CNTXT_ITEM_ID,
    CDE_CNTXT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    QUEST_LONG_TXT,
    QUEST_TXT,
    VM_NM,
    VM_LNM,
    VM_DEF,
    VV_VALUE,
    VV_EDIT_IND,
    VV_SEQ_NR,
    VV_MEAN_TXT,
    VV_DESC_TXT,
    VV_ITEM_ID,
    VV_VER_NR,
    VV_INSTR
)
BEQUEATH DEFINER
AS
    SELECT frm.item_long_nm           frm_item_long_nm,
           frm.item_nm                frm_item_nm,
           frm.item_id                frm_item_id,
           frm.ver_nr                 frm_ver_nr,
           frm.item_desc              frm_item_def,
           frmst.hdr_instr,
           frmst.ftr_instr,
           air.p_item_id              mod_item_id,
           air.p_item_ver_nr          mod_ver_nr,
           frm_mod.INSTR              MOD_INSTR,
           air.c_item_id              de_item_id,
           air.c_item_ver_nr          de_ver_nr,
           air.disp_ord               quest_disp_ord,
           frm_mod.disp_ord           mod_disp_ord,
           frm_mod.rep_no             mod_rep_no,
           aim.item_nm                MOD_ITEM_NM,
           air.INSTR                  QUEST_INSTR,
           air.REQ_IND                QUEST_REQ_IND,
           air.DEFLT_VAL              QUEST_DEFLT_VAL,
           air.EDIT_IND               QUEST_EDIT_IND,
           aim.item_long_nm           mod_item_long_nm,
           aim.item_desc              mod_item_desc,
           air.nci_pub_id             QUEST_ITEM_ID,
           air.nci_ver_nr             QUEST_VER_NR,
           de.CNTXT_NM_DN             CDE_CNTXT_NM,
           de.item_nm                 CDE_ITEM_NM,
           de.cntxt_item_id           CDE_CNTXT_ITEM_ID,
           de.cntxt_VER_NR            CDE_CNTXT_VER_NR,
           air.CREAT_DT,
           air.CREAT_USR_ID,
           air.LST_UPD_USR_ID,
           air.FLD_DELETE,
           air.LST_DEL_DT,
           air.S2P_TRN_DT,
           air.LST_UPD_DT,
           air.item_long_nm           QUEST_LONG_TXT,
           air.item_nm                QUEST_TXT,
           vv.VM_NM,
           vv.VM_LNM,
           vv.VM_DEF,
           vv.VALUE                   VV_VALUE,
           vv.EDIT_IND                VV_EDIT_IND,
           vv.SEQ_NBR                 VV_SEQ_NR,
           vv.MEAN_TXT                VV_MEAN_TXT,
           vv.DESC_TXT                VV_DESC_TXT,
           NVL (vv.nci_pub_id, 1)     VV_ITEM_ID,
           NVL (vv.nci_ver_nr, 1)     VV_VER_NR,
           vv.INSTR                   VV_INSTR
      FROM nci_admin_item_rel_alt_key  air,
           admin_item                  aim,
           admin_item                  frm,
           nci_admin_item_rel          frm_mod,
           admin_item                  de,
           nci_quest_valid_value       vv,
           nci_form                    frmst
     WHERE     air.rel_typ_id = 63
           AND aim.item_id = air.p_item_id
           AND aim.ver_nr = air.p_item_ver_nr
           AND frm.item_id = frm_mod.p_item_id
           AND frm.ver_nr = frm_mod.p_item_ver_nr
           AND aim.item_id = frm_mod.c_item_id
           AND aim.ver_nr = frm_mod.c_item_ver_nr
           AND frm.item_id = frmst.item_id
           AND frm.ver_nr = frmst.ver_nr
           AND frm_mod.rel_typ_id IN (61, 62)
           AND frm.admin_item_typ_id IN (54, 55)
           AND air.c_item_id = de.item_id(+)
           AND air.c_item_ver_nr = de.ver_nr(+)
           AND air.NCI_PUB_ID = vv.q_pub_id(+)
           AND air.nci_ver_nr = vv.q_ver_nr(+);


DROP VIEW ONEDATA_WA.VW_NCI_FORM_MODULE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_FORM_MODULE
(
    P_ITEM_ID,
    P_ITEM_VER_NR,
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    FORM_NM,
    ITEM_DESC,
    ADMIN_ITEM_TYP_NM,
    INSTR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DISP_ORD,
    REP_NO,
    REGSTR_STUS_ID,
    ADMIN_STUS_ID,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    ITEM_LONG_NM
)
BEQUEATH DEFINER
AS
    SELECT air.p_item_id,
           air.p_item_ver_nr,
           ai.item_id,
           ai.ver_nr,
           ai.item_nm,
           ai.item_nm     FORM_NM,
           ai.item_desc,
           'MODULE'       admin_item_typ_nm,
           air.INSTR,
           ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.FLD_DELETE,
           ai.LST_DEL_DT,
           ai.S2P_TRN_DT,
           ai.LST_UPD_DT,
           air.disp_ord,
           air.rep_no,
           ai.regstr_stus_id,
           ai.admin_stus_id,
           ai.cntxt_item_id,
           ai.cntxt_ver_nr,
           ai.item_long_nm
      FROM admin_item ai, nci_admin_item_rel air
     WHERE     ai.item_id = air.c_item_id
           AND ai.ver_nr = air.c_item_ver_nr
           AND air.rel_typ_id IN (61, 62);


DROP VIEW ONEDATA_WA.VW_NCI_MODULE_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_MODULE_DE
(
    FRM_ITEM_LONG_NM,
    FRM_ITEM_NM,
    FRM_ITEM_ID,
    FRM_VER_NR,
    MOD_ITEM_ID,
    MOD_VER_NR,
    DE_ITEM_ID,
    DE_VER_NR,
    QUEST_DISP_ORD,
    MOD_DISP_ORD,
    MOD_ITEM_NM,
    INSTR,
    MOD_ITEM_LONG_NM,
    MOD_ITEM_DESC,
    ADMIN_ITEM_TYP_NM,
    NCI_PUB_ID,
    NCI_VER_NR,
    CNTXT_NM_DN,
    DE_ITEM_NM,
    DE_CNTXT_ITEM_ID,
    DE_CNTXT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    QUEST_LONG_TXT,
    QUEST_TXT
)
BEQUEATH DEFINER
AS
    SELECT frm.item_long_nm      frm_item_long_nm,
           frm.item_nm           frm_item_nm,
           frm.item_id           frm_item_id,
           frm.ver_nr            frm_ver_nr,
           air.p_item_id         mod_item_id,
           air.p_item_ver_nr     mod_ver_nr,
           air.c_item_id         de_item_id,
           air.c_item_ver_nr     de_ver_nr,
           air.disp_ord          quest_disp_ord,
           frm_mod.disp_ord      mod_disp_ord,
           aim.item_nm           MOD_ITEM_NM,
           air.INSTR,
           aim.item_long_nm      mod_item_long_nm,
           aim.item_desc         mod_item_desc,
           'QUESTION'            admin_item_typ_nm,
           air.nci_pub_id,
           air.nci_ver_nr,
           de.CNTXT_NM_DN,
           de.item_nm            DE_ITEM_NM,
           de.cntxt_item_id      DE_CNTXT_ITEM_ID,
           de.cntxt_VER_NR       DE_CNTXT_VER_NR,
           air.CREAT_DT,
           air.CREAT_USR_ID,
           air.LST_UPD_USR_ID,
           air.FLD_DELETE,
           air.LST_DEL_DT,
           air.S2P_TRN_DT,
           air.LST_UPD_DT,
           air.item_long_nm      QUEST_LONG_TXT,
           air.item_nm           QUEST_TXT
      FROM nci_admin_item_rel_alt_key  air,
           admin_item                  aim,
           admin_item                  frm,
           nci_admin_item_rel          frm_mod,
           admin_item                  de
     WHERE     air.rel_typ_id = 63
           AND aim.item_id = air.p_item_id
           AND aim.ver_nr = air.p_item_ver_nr
           AND frm.item_id = frm_mod.p_item_id
           AND frm.ver_nr = frm_mod.p_item_ver_nr
           AND aim.item_id = frm_mod.c_item_id
           AND aim.ver_nr = frm_mod.c_item_ver_nr
           AND frm_mod.rel_typ_id IN (61, 62)
           AND frm.admin_item_typ_id IN (54, 55)
           AND air.c_item_id = de.item_id
           AND air.c_item_ver_nr = de.ver_nr;


DROP VIEW ONEDATA_WA.VW_NCI_MODULE_QUEST;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_MODULE_QUEST
(
    FRM_ITEM_ID,
    FRM_VER_NR,
    MOD_ITEM_ID,
    MOD_VER_NR,
    DE_ITEM_ID,
    DE_VER_NR,
    DISP_ORD,
    NCI_PUB_ID,
    NCI_VER_NR,
    CNTXT_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    QUEST_LONG_TXT,
    QUEST_TXT,
    REL_TYP_ID
)
BEQUEATH DEFINER
AS
    SELECT rel.p_item_id         frm_item_id,
           rel.p_item_ver_nr     frm_ver_nr,
           air.p_item_id         mod_item_id,
           air.p_item_ver_nr     mod_ver_nr,
           air.c_item_id         de_item_id,
           air.c_item_ver_nr     de_ver_nr,
           air.disp_ord,
           air.nci_pub_id,
           air.nci_ver_nr,
           de.CNTXT_NM_DN,
           air.CREAT_DT,
           air.CREAT_USR_ID,
           air.LST_UPD_USR_ID,
           air.FLD_DELETE,
           air.LST_DEL_DT,
           air.S2P_TRN_DT,
           air.LST_UPD_DT,
           air.item_long_nm      QUEST_LONG_TXT,
           air.item_nm           QUEST_TXT,
           63                    REL_TYP_ID
      FROM nci_admin_item_rel_alt_key  air,
           nci_admin_item_rel          rel,
           admin_item                  de
     WHERE     air.rel_typ_id = 63
           AND air.c_item_id = de.item_id
           AND air.c_item_ver_nr = de.ver_nr
           AND air.p_item_id = rel.c_item_id
           AND air.p_item_ver_nr = rel.c_item_ver_nr
           AND rel.rel_typ_id IN (61, 62);


DROP VIEW ONEDATA_WA.VW_NCI_USED_BY;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_USED_BY
(
    ITEM_ID,
    VER_NR,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    OWNED_BY,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
      SELECT ITEM_ID,
             VER_NR,
             CNTXT_ITEM_ID,
             CNTXT_VER_NR,
             MAX (owned_by)     OWNED_BY,
             SYSDATE            CREAT_DT,
             'ONEDATA'          CREAT_USR_ID,
             'ONEDATA'          LST_UPD_USR_ID,
             0                  FLD_DELETE,
             SYSDATE            LST_DEL_DT,
             SYSDATE            S2P_TRN_DT,
             SYSDATE            LST_UPD_DT
        FROM (SELECT DISTINCT DE.ITEM_ID,
                              DE.VER_NR,
                              de.CNTXT_ITEM_ID,
                              de.CNTXT_VER_NR,
                              1             OWNED_BY,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              de.FLD_DELETE,
                              de.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM ADMIN_ITEM DE
               WHERE NVL (de.fld_delete, 0) = 0 AND de.admin_item_typ_id = 4
              UNION
              SELECT DISTINCT DE.ITEM_ID,
                              DE.VER_NR,
                              a.CNTXT_ITEM_ID,
                              a.CNTXT_VER_NR,
                              0,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              a.FLD_DELETE,
                              a.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM DE, ALT_NMS a
               WHERE     DE.ITEM_ID = a.ITEM_ID
                     AND DE.VER_NR = a.VER_NR
                     AND NVL (a.fld_delete, 0) = 0
                     AND NVL (de.fld_delete, 0) = 0
                     AND a.CNTXT_ITEM_ID IS NOT NULL
              UNION
              SELECT DISTINCT DE.ITEM_ID,
                              DE.VER_NR,
                              a.NCI_CNTXT_ITEM_ID,
                              a.NCI_CNTXT_VER_NR,
                              0,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              a.FLD_DELETE,
                              a.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM DE, REF a
               WHERE     DE.ITEM_ID = a.ITEM_ID
                     AND DE.VER_NR = a.VER_NR
                     AND NVL (a.fld_delete, 0) = 0
                     AND NVL (de.fld_delete, 0) = 0
                     AND a.NCI_CNTXT_ITEM_ID IS NOT NULL
              UNION
              SELECT DISTINCT DE.C_ITEM_ID,
                              DE.C_ITEM_VER_NR,
                              cs.CNTXT_ITEM_ID,
                              cs.CNTXT_VER_NR,
                              0,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              cscsi.FLD_DELETE,
                              cscsi.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM NCI_ALT_KEY_ADMIN_ITEM_REL de,
                     NCI_ADMIN_ITEM_REL_ALT_KEY cscsi,
                     admin_item                cs
               WHERE     DE.NCI_PUB_ID = cscsi.NCI_PUB_ID
                     AND de.NCI_VER_NR = cscsi.NCI_VER_NR
                     AND NVL (cscsi.fld_delete, 0) = 0
                     AND NVL (de.fld_delete, 0) = 0
                     AND NVL (cs.fld_delete, 0) = 0
                     AND cscsi.CNTXT_CS_ITEM_ID = cs.item_id
                     AND cscsi.CNTXT_CS_VER_NR = cs.ver_nr
                     AND cs.admin_item_typ_id = 9
                     AND cs.CNTXT_ITEM_ID IS NOT NULL
              UNION
              SELECT DISTINCT quest.C_ITEM_ID,
                              quest.C_ITEM_VER_NR,
                              ai.CNTXT_ITEM_ID,
                              ai.CNTXT_VER_NR,
                              0,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              quest.FLD_DELETE,
                              quest.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM NCI_ADMIN_ITEM_REL_ALT_KEY quest,
                     ADMIN_ITEM                ai,
                     NCI_ADMIN_ITEM_REL        rel
               WHERE     AI.ITEM_ID = rel.P_ITEM_ID
                     AND AI.VER_NR = rel.P_ITEM_VER_NR
                     AND NVL (ai.fld_delete, 0) = 0
                     AND NVL (rel.fld_delete, 0) = 0
                     AND NVL (quest.fld_delete, 0) = 0
                     AND rel.C_ITEM_ID = quest.P_ITEM_ID
                     AND rel.C_ITEM_VER_NR = quest.P_ITEM_VER_NR
                     AND ai.admin_stus_id = 75     -- only for released forms.
              UNION
              SELECT DISTINCT quest.C_ITEM_ID,
                              quest.C_ITEM_VER_NR,
                              cs.CNTXT_ITEM_ID,
                              cs.CNTXT_VER_NR,
                              0,
                              SYSDATE       CREAT_DT,
                              'ONEDATA'     CREAT_USR_ID,
                              'ONEDATA'     LST_UPD_USR_ID,
                              quest.FLD_DELETE,
                              quest.LST_DEL_DT,
                              SYSDATE       S2P_TRN_DT,
                              SYSDATE       LST_UPD_DT
                FROM NCI_ADMIN_ITEM_REL   quest,
                     ADMIN_ITEM           cs,
                     NCI_CLSFCTN_SCHM_ITEM csi
               WHERE     cs.ITEM_ID = csi.cs_ITEM_ID
                     AND cs.VER_NR = csi.CS_ITEM_VER_NR
                     AND NVL (cs.fld_delete, 0) = 0
                     AND NVL (csi.fld_delete, 0) = 0
                     AND NVL (quest.fld_delete, 0) = 0
                     AND csi.ITEM_ID = quest.P_ITEM_ID
                     AND cs.VER_NR = quest.P_ITEM_VER_NR)
    GROUP BY ITEM_ID,
             VER_NR,
             CNTXT_ITEM_ID,
             CNTXT_VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_USR_CART;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_USR_CART
(
    ITEM_ID,
    VER_NR,
    ITEM_LONG_NM,
    CNTXT_NM_DN,
    ITEM_NM,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    ADMIN_ITEM_TYP_ID,
    ADMIN_ITEM_TYP_NM,
    CNTCT_SECU_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    GUEST_USR_NM
)
BEQUEATH DEFINER
AS
    SELECT AI.ITEM_ID,
           AI.VER_NR,
           AI.ITEM_LONG_NM,
           AI.CNTXT_NM_DN,
           AI.ITEM_NM,
           AI.REGSTR_STUS_NM_DN,
           AI.ADMIN_STUS_NM_DN,
           AI.ADMIN_ITEM_TYP_ID,
           DECODE (AI.ADMIN_ITEM_TYP_ID,
                   4, 'Data Element',
                   54, 'Form',
                   52, 'Module')    ADMIN_ITEM_TYP_NM,
           UC.CNTCT_SECU_ID,
           UC.CREAT_DT,
           UC.CREAT_USR_ID,
           UC.LST_UPD_USR_ID,
           UC.FLD_DELETE,
           UC.LST_DEL_DT,
           UC.S2P_TRN_DT,
           UC.LST_UPD_DT,
           UC.GUEST_USR_NM
      FROM NCI_USR_CART UC, ADMIN_ITEM AI
     WHERE     AI.ITEM_ID = UC.ITEM_ID
           AND AI.VER_NR = UC.VER_NR
           AND admin_item_typ_id IN (4, 52, 54);


DROP VIEW ONEDATA_WA.VW_NCI_VD_CNCPT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_VD_CNCPT
(
    ALT_NMS_LVL,
    ITEM_ID,
    VER_NR,
    CORE_ITEM_ID,
    CORE_VER_NR,
    CNCPT_ITEM_ID,
    CNCPT_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NCI_ORD,
    NCI_PRMRY_IND,
    NCI_CNCPT_VAL
)
BEQUEATH DEFINER
AS
    SELECT 'Component Concept'     ALT_NMS_LVL,
           a.ITEM_ID,
           a.VER_NR,
           a.ITEM_ID               CORE_ITEM_ID,
           a.VER_NR                CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           a.NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a
    UNION
    SELECT 'Representation Term'     ALT_NMS_LVL,
           VD.ITEM_ID                ITEM_ID,
           VD.VER_NR                 VER_NR,
           a.ITEM_ID                 CORE_ITEM_ID,
           a.VER_NR                  CORE_VER_NR,
           a.CNCPT_ITEM_ID,
           a.CNCPT_VER_NR,
           a.CREAT_DT,
           a.CREAT_USR_ID,
           a.LST_UPD_USR_ID,
           a.FLD_DELETE,
           a.LST_DEL_DT,
           a.S2P_TRN_DT,
           a.LST_UPD_DT,
           a.NCI_ORD,
           a.NCI_PRMRY_IND,
           NCI_CNCPT_VAL
      FROM CNCPT_ADMIN_ITEM a, VALUE_DOM VD
     WHERE a.ITEM_ID = VD.REP_CLS_ITEM_ID AND a.VER_NR = VD.REP_CLS_VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_VD_VM_ALT_DEF;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_VD_VM_ALT_DEF
(
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR,
    VAL_MEAN_LONG_NM,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    DEF_DESC,
    NCI_DEF_TYP_ID,
    LANG_ID,
    DEF_ID,
    PERM_VAL_NM,
    PERM_VAL_DESC_TXT,
    CNTXT_ITEM_ID,
    CNTXT_VER_NR
)
BEQUEATH DEFINER
AS
    SELECT PV.NCI_VAL_MEAN_ITEM_ID     VAL_MEAN_ITEM_ID,
           PV.NCI_VAL_MEAN_VER_NR      VAL_MEAN_VER_NR,
           vm.ITEM_NM                  VAL_MEAN_LONG_NM,
           PV.VAL_DOM_ITEM_ID          VAL_DOM_ITEM_ID,
           PV.VAL_DOM_VER_NR           VAL_DOM_VER_NR,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT,
           an.DEF_DESC,
           an.NCI_DEF_TYP_ID,
           an.LANG_ID,
           an.def_id,
           PV.PERM_VAL_NM,
           PV.PERM_VAL_DESC_TXT,
           an.CNTXT_ITEM_ID,
           an.CNTXT_VER_NR
      FROM PERM_VAL PV, ALT_DEF an, ADMIN_ITEM vm
     WHERE     PV.NCI_VAL_MEAN_ITEM_ID = an.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = an.VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR;


DROP VIEW ONEDATA_WA.VW_NCI_VD_VM_ALT_NMS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_NCI_VD_VM_ALT_NMS
(
    VAL_MEAN_ITEM_ID,
    VAL_MEAN_VER_NR,
    VAL_MEAN_LONG_NM,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    NM_DESC,
    NM_TYP_ID,
    VM_CNTXT_NM_DN,
    LANG_ID,
    NM_ID,
    PERM_VAL_NM,
    PERM_VAL_DESC_TXT
)
BEQUEATH DEFINER
AS
    SELECT PV.NCI_VAL_MEAN_ITEM_ID     VAL_MEAN_ITEM_ID,
           PV.NCI_VAL_MEAN_VER_NR      VAL_MEAN_VER_NR,
           vm.ITEM_NM                  VAL_MEAN_LONG_NM,
           PV.VAL_DOM_ITEM_ID          VAL_DOM_ITEM_ID,
           PV.VAL_DOM_VER_NR           VAL_DOM_VER_NR,
           PV.CREAT_DT,
           PV.CREAT_USR_ID,
           PV.LST_UPD_USR_ID,
           PV.FLD_DELETE,
           PV.LST_DEL_DT,
           PV.S2P_TRN_DT,
           PV.LST_UPD_DT,
           an.NM_DESC,
           an.nm_typ_id,
           an.CNTXT_NM_DN              VM_CNTXT_NM_DN,
           an.LANG_ID,
           an.nm_id,
           PV.PERM_VAL_NM,
           PV.PERM_VAL_DESC_TXT
      FROM PERM_VAL PV, ALT_NMS an, ADMIN_ITEM vm
     WHERE     PV.NCI_VAL_MEAN_ITEM_ID = an.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = an.VER_NR
           AND PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID
           AND PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR;


DROP VIEW ONEDATA_WA.VW_OBJ_CLS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_CLS
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CNCPT_CONCAT,
    CNCPT_CONCAT_NM
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           e.CNCPT_CONCAT,
           e.CNCPT_CONCAT_NM
      FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT e
     WHERE     ADMIN_ITEM_TYP_ID = 5
           AND ADMIN_ITEM.ITEM_ID = e.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = e.VER_NR(+);


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_1;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_1
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE OBJ_TYP_ID = 1;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_10;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_10
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 10;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_11;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_11
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 11;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_12;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_12
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 12;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_13;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_13
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 13;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_14;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_14
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 14;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_15;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_15
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 15;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_2;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_2
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE OBJ_TYP_ID = 2;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_3;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_3
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE OBJ_TYP_ID = 3;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_4;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_4
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 4;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_5;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_5
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 5;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_6;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_6
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 6;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_7;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_7
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE OBJ_TYP_ID = 7;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_8;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_8
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 8;


DROP VIEW ONEDATA_WA.VW_OBJ_KEY_9;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OBJ_KEY_9
(
    OBJ_KEY_ID,
    OBJ_KEY_DESC,
    OBJ_TYP_ID,
    OBJ_KEY_DEF,
    OBJ_KEY_CD,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    OBJ_KEY_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT OBJ_KEY.OBJ_KEY_ID,
           OBJ_KEY.OBJ_KEY_DESC,
           OBJ_KEY.OBJ_TYP_ID,
           OBJ_KEY.OBJ_KEY_DEF,
           OBJ_KEY.OBJ_KEY_CD,
           OBJ_KEY.CREAT_DT,
           OBJ_KEY.CREAT_USR_ID,
           OBJ_KEY.LST_UPD_USR_ID,
           OBJ_KEY.FLD_DELETE,
           OBJ_KEY.LST_DEL_DT,
           OBJ_KEY.S2P_TRN_DT,
           OBJ_KEY.LST_UPD_DT,
           OBJ_KEY.OBJ_KEY_CMNTS
      FROM OBJ_KEY
     WHERE obj_typ_id = 9;


DROP VIEW ONEDATA_WA.VW_OC_PROP;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_OC_PROP
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ADMIN_ITEM_TYP_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CNCPT_CD,
    CNCPT_NM
)
BEQUEATH DEFINER
AS
    SELECT admin_item.item_id,
           admin_item.ver_nr,
           admin_item.item_nm,
           admin_item.item_long_nm,
           admin_item.admin_item_typ_id,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           CNCPT_AGG.CNCPT_CD,
           CNCPT_AGG.CNCPT_NM
      FROM admin_item,
           (  SELECT cai.item_id,
                     cai.ver_nr,
                     LISTAGG (ai.item_nm, ';')
                         WITHIN GROUP (ORDER BY cai.ITEM_ID)    AS CNCPT_CD,
                     LISTAGG (ai.item_long_nm, ';')
                         WITHIN GROUP (ORDER BY cai.ITEM_ID)    AS CNCPT_NM
                FROM cncpt_admin_item cai, admin_item ai
               WHERE     ai.item_id = cai.cncpt_item_id
                     AND ai.ver_nr = cai.cncpt_ver_nr
            GROUP BY cai.item_id, cai.ver_nr) CNCPT_AGG
     WHERE     admin_item.item_id = cncpt_agg.item_id(+)
           AND admin_item.ver_nr = cncpt_agg.ver_nr(+)
           AND admin_item.admin_item_typ_id IN (5, 6);


DROP VIEW ONEDATA_WA.VW_PERM_VAL_FOR_DE;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_PERM_VAL_FOR_DE
(
    VAL_ID,
    PERM_VAL_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    VAL_MEAN_DESC,
    ITEM_ID,
    VER_NR
)
BEQUEATH DEFINER
AS
    SELECT PERM_VAL.VAL_ID,
           PERM_VAL.PERM_VAL_NM,
           PERM_VAL.CREAT_DT,
           PERM_VAL.CREAT_USR_ID,
           PERM_VAL.LST_UPD_USR_ID,
           PERM_VAL.FLD_DELETE,
           PERM_VAL.LST_DEL_DT,
           PERM_VAL.S2P_TRN_DT,
           PERM_VAL.LST_UPD_DT,
           VAL_MEAN.VAL_MEAN_DESC,
           DE.ITEM_ID,
           DE.VER_NR
      FROM PERM_VAL, DE, VAL_MEAN
     WHERE     DE.VAL_DOM_ITEM_ID = PERM_VAL.VAL_DOM_ITEM_ID
           AND DE.VAL_DOM_VER_NR = PERM_VAL.VAL_DOM_VER_NR
           AND PERM_VAL.VAL_MEAN_ID = VAL_MEAN.VAL_MEAN_ID;


DROP VIEW ONEDATA_WA.VW_PERM_VAL_VAL_DOM_CONC_DOM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_PERM_VAL_VAL_DOM_CONC_DOM
(
    CONC_DOM_ITEM_ID,
    CONC_DOM_VER_NR,
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    LST_UPD_DT,
    LST_UPD_USR_ID,
    S2P_TRN_DT,
    PERM_VAL_DESC_TXT,
    PERM_VAL_BEG_DT,
    PERM_VAL_END_DT,
    PERM_VAL_NM,
    VAL_MEAN_ID,
    VAL_ID,
    VAL_MEAN_DESC,
    VAL_MEAN_BEG_DT,
    VAL_MEAN_END_DT
)
BEQUEATH DEFINER
AS
    SELECT v.CONC_DOM_ITEM_ID,
           v.CONC_DOM_VER_NR,
           pv.VAL_DOM_ITEM_ID,
           pv.VAL_DOM_VER_NR,
           pv.CREAT_DT,
           pv.CREAT_USR_ID,
           pv.FLD_DELETE,
           pv.LST_DEL_DT,
           pv.LST_UPD_DT,
           pv.LST_UPD_USR_ID,
           pv.S2P_TRN_DT,
           pv.PERM_VAL_DESC_TXT,
           pv.PERM_VAL_BEG_DT,
           pv.PERM_VAL_END_DT,
           pv.PERM_VAL_NM,
           pv.VAL_MEAN_ID,
           pv.VAL_ID,
           vm.VAL_MEAN_DESC,
           vm.VAL_MEAN_BEG_DT,
           vm.VAL_MEAN_END_DT
      FROM PERM_VAL pv, VALUE_DOM v, VAL_MEAN vm
     WHERE     pv.VAL_DOM_ITEM_ID = v.ITEM_ID
           AND pv.VAL_DOM_VER_NR = v.VER_NR
           AND pv.VAL_MEAN_ID = vm.VAL_MEAN_ID;


DROP VIEW ONEDATA_WA.VW_PROP;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_PROP
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CNCPT_CONCAT,
    CNCPT_CONCAT_NM
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           e.CNCPT_CONCAT,
           e.CNCPT_CONCAT_NM
      FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT e
     WHERE     ADMIN_ITEM_TYP_ID = 6
           AND ADMIN_ITEM.ITEM_ID = e.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = e.VER_NR(+);


DROP VIEW ONEDATA_WA.VW_PROTCL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_PROTCL
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    PROTCL_ID
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           p.PROTCL_ID
      FROM ADMIN_ITEM, NCI_PROTCL p
     WHERE     ADMIN_ITEM_TYP_ID = 50
           AND admin_item.item_id = p.item_id
           AND admin_item.ver_nr = p.ver_nr;


DROP VIEW ONEDATA_WA.VW_REF;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REF
(
    REF_ID,
    REF_NM,
    ITEM_ID,
    CREAT_DT,
    VER_NR,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REF_DESC,
    REF_TYP_ID,
    DISP_ORD,
    LANG_ID,
    NCI_CNTXT_ITEM_ID,
    NCI_CNTXT_VER_NR,
    URL,
    NCI_IDSEQ,
    REF_SEARCH_STR
)
BEQUEATH DEFINER
AS
    SELECT REF_ID,
           REF_NM,
           ITEM_ID,
           CREAT_DT,
           VER_NR,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT,
           REF_DESC,
           REF_TYP_ID,
           DISP_ORD,
           LANG_ID,
           NCI_CNTXT_ITEM_ID,
           NCI_CNTXT_VER_NR,
           URL,
           NCI_IDSEQ,
           REF_NM || ' ' || REF_DESC     REF_SEARCH_STR
      FROM REF;


DROP VIEW ONEDATA_WA.VW_REGIST_AUTH;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REGIST_AUTH
(
    ORG_ID,
    NCI_IDSEQ,
    ORG_NM,
    RA_IND,
    ORG_MAIL_ADR,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT ENTTY_ID      ORG_ID,
           RAI           NCI_IDSEQ,
           ORG_NM,
           RA_IND,
           MAIL_ADDR     ORG_MAIL_ADR,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT
      FROM NCI_ORG
     WHERE RA_IND = 'Yes';


DROP VIEW ONEDATA_WA.VW_REGIST_AUTH_OLD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REGIST_AUTH_OLD
(
    ORG_ID,
    ORG_MAIL_ADR,
    ORG_NM,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    ORG_WEBSITE,
    ROUTE_SYM,
    LINE_OF_BUS,
    MDR_ORG_ID,
    RA_IND
)
BEQUEATH DEFINER
AS
    SELECT ORG.ORG_ID,
           ORG.ORG_MAIL_ADR,
           ORG.ORG_NM,
           ORG.CREAT_DT,
           ORG.CREAT_USR_ID,
           ORG.LST_UPD_USR_ID,
           ORG.FLD_DELETE,
           ORG.LST_DEL_DT,
           ORG.S2P_TRN_DT,
           ORG.LST_UPD_DT,
           ORG.ORG_WEBSITE,
           ORG.ROUTE_SYM,
           ORG.LINE_OF_BUS,
           ORG.MDR_ORG_ID,
           ORG.RA_IND
      FROM ORG
     WHERE RA_IND = '1';


DROP VIEW ONEDATA_WA.VW_REGIS_STUS_RUL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REGIS_STUS_RUL
(
    FROM_STUS_ID,
    TO_STUS_ID,
    REQ_COL_DESC,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REGIST_RUL_ID,
    USR_GRP_ID,
    STUS_TYP_ID
)
BEQUEATH DEFINER
AS
    SELECT REGIST_RUL.FROM_STUS_ID,
           REGIST_RUL.TO_STUS_ID,
           REGIST_RUL.REQ_COL_DESC,
           REGIST_RUL.CREAT_DT,
           REGIST_RUL.CREAT_USR_ID,
           REGIST_RUL.LST_UPD_USR_ID,
           REGIST_RUL.FLD_DELETE,
           REGIST_RUL.LST_DEL_DT,
           REGIST_RUL.S2P_TRN_DT,
           REGIST_RUL.LST_UPD_DT,
           REGIST_RUL.REGIST_RUL_ID,
           REGIST_RUL.USR_GRP_ID,
           REGIST_RUL.STUS_TYP_ID
      FROM REGIST_RUL
     WHERE stus_typ_id = 1;


DROP VIEW ONEDATA_WA.VW_REGSTR_STUS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REGSTR_STUS
(
    STUS_ID,
    STUS_NM,
    STUS_DESC,
    STUS_TYP_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    STUS_MSK,
    STUS_ACRO,
    NCI_STUS,
    NCI_CMNTS,
    NCI_DISP_ORDR
)
BEQUEATH DEFINER
AS
    SELECT "STUS_ID",
           "STUS_NM",
           "STUS_DESC",
           "STUS_TYP_ID",
           "CREAT_DT",
           "CREAT_USR_ID",
           "LST_UPD_USR_ID",
           "FLD_DELETE",
           "LST_DEL_DT",
           "S2P_TRN_DT",
           "LST_UPD_DT",
           "STUS_MSK",
           "STUS_ACRO",
           "NCI_STUS",
           "NCI_CMNTS",
           "NCI_DISP_ORDR"
      FROM STUS_MSTR
     WHERE STUS_TYP_ID = 1;


DROP VIEW ONEDATA_WA.VW_REP_CLS;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_REP_CLS
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT
      FROM ADMIN_ITEM
     WHERE ADMIN_ITEM_TYP_ID = 7;


DROP VIEW ONEDATA_WA.VW_STG_BULK_CNTXT_UPD;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_STG_BULK_CNTXT_UPD
(
    CNTXT_ITEM_ID,
    CNTXT_VER_NR,
    TO_CNTXT_ITEM_ID,
    TO_CNTXT_VER_NR,
    IND_ALL_TYPES,
    IND_TYP_1,
    IND_TYP_2,
    IND_TYP_3,
    IND_TYP_4,
    IND_TYP_5,
    IND_TYP_6,
    IND_TYP_7,
    IND_TYP_9,
    IND_TYP_49,
    IND_TYP_50,
    IND_TYP_51,
    IND_TYP_52,
    IND_TYP_54,
    IND_ALT_NMS,
    IND_ALT_DEF,
    IND_REF_DOC,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT item_id         cntxt_item_id,
           ver_nr          cntxt_ver_nr,
           item_id         to_cntxt_item_id,
           ver_nr          to_cntxt_ver_nr,
           derv_de_ind     IND_ALL_TYPES,
           derv_de_ind     IND_TYP_1,
           derv_de_ind     IND_TYP_2,
           derv_de_ind     IND_TYP_3,
           derv_de_ind     IND_TYP_4,
           derv_de_ind     IND_TYP_5,
           derv_de_ind     IND_TYP_6,
           derv_de_ind     IND_TYP_7,
           derv_de_ind     IND_TYP_9,
           derv_de_ind     IND_TYP_49,
           derv_de_ind     IND_TYP_50,
           derv_de_ind     IND_TYP_51,
           derv_de_ind     IND_TYP_52,
           derv_de_ind     IND_TYP_54,
           derv_de_ind     IND_ALT_NMS,
           derv_de_ind     IND_ALT_DEF,
           derv_de_ind     IND_REF_DOC,
           CREAT_DT,
           CREAT_USR_ID,
           LST_UPD_USR_ID,
           FLD_DELETE,
           LST_DEL_DT,
           S2P_TRN_DT,
           LST_UPD_DT
      FROM de;


DROP VIEW ONEDATA_WA.VW_SYS_TBL_COL;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_SYS_TBL_COL
(
    SYSTEM_ID,
    SYSTEM_NM,
    SYSTEM_DESC,
    TABLE_ID,
    TABLE_NM,
    TABLE_DESC,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    COLUMN_ID,
    COLUMN_NM,
    COLUMN_DESC,
    COLUMN_DATATYP,
    COLUMN_NULLABLE,
    COLUMN_LEN,
    COLUMN_PREC,
    CMNTS,
    PHYS_ORD,
    COLUMN_DFLT_VAL,
    ITEM_ID,
    VER_NR
)
BEQUEATH DEFINER
AS
    SELECT SYSTEM_APPLICATION.SYSTEM_ID,
           SYSTEM_APPLICATION.SYSTEM_NM,
           SYSTEM_APPLICATION.SYSTEM_DESC,
           SYSTEM_TABLES.TABLE_ID,
           SYSTEM_TABLES.TABLE_NM,
           SYSTEM_TABLES.TABLE_DESC,
           SYSTEM_TABLES.CREAT_DT,
           SYSTEM_TABLES.CREAT_USR_ID,
           SYSTEM_TABLES.LST_UPD_USR_ID,
           SYSTEM_TABLES.FLD_DELETE,
           SYSTEM_TABLES.LST_DEL_DT,
           SYSTEM_TABLES.S2P_TRN_DT,
           SYSTEM_TABLES.LST_UPD_DT,
           SYSTEM_COLUMNS.COLUMN_ID,
           SYSTEM_COLUMNS.COLUMN_NM,
           SYSTEM_COLUMNS.COLUMN_DESC,
           SYSTEM_COLUMNS.COLUMN_DATATYP     COLUMN_DATATYP,
           SYSTEM_COLUMNS.COLUMN_NULLABLE,
           SYSTEM_COLUMNS.COLUMN_LEN,
           SYSTEM_COLUMNS.COLUMN_PREC,
           SYSTEM_COLUMNS.CMNTS,
           SYSTEM_COLUMNS.PHYS_ORD,
           1,
           SYSTEM_COLUMNS.item_id,
           SYSTEM_COLUMNS.ver_nr
      FROM SYSTEM_TABLES, SYSTEM_COLUMNS, SYSTEM_APPLICATION
     WHERE     system_application.system_id = system_tables.system_id
           AND system_tables.table_id = system_columns.table_id;


DROP VIEW ONEDATA_WA.VW_VALUE_DOM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VALUE_DOM
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CURRNT_VER_IND,
    DTTYPE_ID,
    VAL_DOM_MAX_CHAR,
    CONC_DOM_VER_NR,
    CONC_DOM_ITEM_ID,
    NON_ENUM_VAL_DOM_DESC,
    UOM_ID,
    VAL_DOM_TYP_ID,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_FMT_ID,
    CHAR_SET_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    REP_TERM_ITEM_NM
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM.CREAT_DT,
           VALUE_DOM.CREAT_USR_ID,
           VALUE_DOM.LST_UPD_USR_ID,
           VALUE_DOM.FLD_DELETE,
           VALUE_DOM.LST_DEL_DT,
           VALUE_DOM.S2P_TRN_DT,
           VALUE_DOM.LST_UPD_DT,
           RC.ITEM_NM     REP_TERM_ITEM_NM
      FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
           AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
           AND ADMIN_ITEM.VER_NR = VALUE_DOM.VER_NR
           AND VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID(+)
           AND VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR(+);


DROP VIEW ONEDATA_WA.VW_VALUE_DOM_33;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VALUE_DOM_33
(
    ITEM_ID,
    VER_NR,
    ITEM_LONG_NM,
    ITEM_NM,
    ITEM_DESC
)
BEQUEATH DEFINER
AS
    SELECT item_id,
           ver_nr,
           ITEM_LONG_NM,
           ITEM_NM,
           ITEM_DESC
      FROM admin_item
     WHERE     ITEM_LONG_NM IN ('C13717',
                                'C25372',
                                'C25162',
                                'C25463',
                                'C25164',
                                'C37939',
                                'C25488',
                                'C25330',
                                'C48150',
                                'C25515',
                                'C48309',
                                'C25364',
                                'C25180',
                                'C45255',
                                'C25543',
                                'C25209',
                                'C42614',
                                'C25337',
                                'C20200',
                                'C38013',
                                'C25636',
                                'C25638',
                                'C25664',
                                'C25338',
                                'C25683',
                                'C25685',
                                'C16899',
                                'C25688',
                                'C25704',
                                'C25207',
                                'C25284',
                                'C25709',
                                'C25712')
           AND admin_item_typ_id = 7
           AND ADMIN_STUS_NM_DN NOT LIKE 'RETIRED%';


DROP VIEW ONEDATA_WA.VW_VALUE_DOM_COMP;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VALUE_DOM_COMP
(
    NON_ENUM_VAL_DOM_DESC,
    DTTYPE_ID,
    VAL_DOM_MAX_CHAR,
    VAL_DOM_TYP_ID,
    UOM_ID,
    CREAT_DT,
    CONC_DOM_VER_NR,
    CREAT_USR_ID,
    CONC_DOM_ITEM_ID,
    LST_UPD_USR_ID,
    REP_CLS_VER_NR,
    FLD_DELETE,
    REP_CLS_ITEM_ID,
    LST_DEL_DT,
    VER_NR,
    S2P_TRN_DT,
    ITEM_ID,
    LST_UPD_DT,
    VAL_DOM_MIN_CHAR,
    VAL_DOM_FMT_ID,
    CHAR_SET_ID,
    VAL_DOM_SYS_NM,
    VAL_DOM_HIGH_VAL_NUM,
    VAL_DOM_LOW_VAL_NUM,
    X_VAL_DOM_ITEM_ID,
    Y_VAL_DOM_ITEM_ID,
    Z_VAL_DOM_ITEM_ID,
    X_VAL_DOM_VER_NR,
    Y_VAL_DOM_VER_NR,
    Z_VAL_DOM_VER_NR,
    NCI_DEC_PREC,
    NCI_STD_DTTYPE_ID,
    CODE_NAME
)
BEQUEATH DEFINER
AS
    SELECT v."NON_ENUM_VAL_DOM_DESC",
           v."DTTYPE_ID",
           v."VAL_DOM_MAX_CHAR",
           v."VAL_DOM_TYP_ID",
           v."UOM_ID",
           v."CREAT_DT",
           v."CONC_DOM_VER_NR",
           v."CREAT_USR_ID",
           v."CONC_DOM_ITEM_ID",
           v."LST_UPD_USR_ID",
           v."REP_CLS_VER_NR",
           v."FLD_DELETE",
           v."REP_CLS_ITEM_ID",
           v."LST_DEL_DT",
           v."VER_NR",
           v."S2P_TRN_DT",
           v."ITEM_ID",
           v."LST_UPD_DT",
           v."VAL_DOM_MIN_CHAR",
           v."VAL_DOM_FMT_ID",
           v."CHAR_SET_ID",
           v."VAL_DOM_SYS_NM",
           v."VAL_DOM_HIGH_VAL_NUM",
           v."VAL_DOM_LOW_VAL_NUM",
           v."X_VAL_DOM_ITEM_ID",
           v."Y_VAL_DOM_ITEM_ID",
           v."Z_VAL_DOM_ITEM_ID",
           v."X_VAL_DOM_VER_NR",
           v."Y_VAL_DOM_VER_NR",
           v."Z_VAL_DOM_VER_NR",
           v."NCI_DEC_PREC",
           v."NCI_STD_DTTYPE_ID",
           pv.code_name
      FROM value_dom  v,
           --(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat_nm || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,2000) AS CODE_NAME
           --(SELECT val_dom_item_id, val_dom_ver_nr, substr(LISTAGG(PERM_VAL_NM|| ':' || PERM_VAL_DESC_TXT || ':' || e.cncpt_concat, '   ,  ') WITHIN GROUP (ORDER by PERM_VAL_DESC_TXT),1,2000) AS CODE_NAME
            (  SELECT val_dom_item_id,
                      val_dom_ver_nr,
                      SUBSTR (
                          LISTAGG (
                                 PERM_VAL_NM
                              || ':'
                              || e.cncpt_concat_nm
                              || ':'
                              || e.cncpt_concat,
                              '   ,  ')
                          WITHIN GROUP (ORDER BY PERM_VAL_DESC_TXT),
                          1,
                          2000)    AS CODE_NAME
                 FROM PERM_VAL, nci_admin_item_ext e
                WHERE     perm_val.nci_val_mean_item_id = e.item_id
                      AND perm_val.nci_val_mean_ver_nr = e.ver_nr
             GROUP BY val_dom_item_id, val_dom_ver_nr) pv
     WHERE     v.item_id = pv.val_dom_item_id(+)
           AND v.ver_nr = pv.val_dom_ver_nr(+);


DROP VIEW ONEDATA_WA.VW_VAL_MEAN;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VAL_MEAN
(
    ITEM_ID,
    VER_NR,
    ITEM_NM,
    ITEM_LONG_NM,
    ITEM_DESC,
    CNTXT_NM_DN,
    CURRNT_VER_IND,
    REGSTR_STUS_NM_DN,
    ADMIN_STUS_NM_DN,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT,
    CNCPT_CONCAT,
    CNCPT_CONCAT_NM,
    ORIGIN_NM
)
BEQUEATH DEFINER
AS
    SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           DECODE (ext.cncpt_concat,
                   ext.cncpt_concat_nm, NULL,
                   admin_item.item_long_nm, NULL,
                   admin_item.item_id, NULL,
                   ext.cncpt_concat)                cncpt_concat,
           ext.cncpt_concat_nm,
           NVL (admin_item.origin_id_dn, origin)    ORIGIN_NM
      FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT ext
     WHERE     ADMIN_ITEM_TYP_ID = 53
           AND admin_item.item_id = ext.item_id
           AND admin_item.ver_nr = ext.ver_nr;


DROP VIEW ONEDATA_WA.VW_VAL_MEAN_CONC_DOM;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VAL_MEAN_CONC_DOM
(
    CONC_DOM_ITEM_ID,
    CONC_DOM_VER_NR,
    CREAT_DT,
    CREAT_USR_ID,
    FLD_DELETE,
    LST_UPD_DT,
    LST_DEL_DT,
    S2P_TRN_DT,
    VAL_MEAN_ID,
    VAL_MEAN_DESC,
    VAL_MEAN_LONG_DESC,
    VAL_MEAN_CMNTS
)
BEQUEATH DEFINER
AS
    SELECT c.CONC_DOM_ITEM_ID,
           c.CONC_DOM_VER_NR,
           c.CREAT_DT,
           c.CREAT_USR_ID,
           c.FLD_DELETE,
           c.LST_UPD_DT,
           c.LST_DEL_DT,
           c.S2P_TRN_DT,
           v.VAL_MEAN_ID,
           v.VAL_MEAN_DESC,
           v.VAL_MEAN_LONG_DESC,
           v.VAL_MEAN_CMNTS
      FROM CONC_DOM_VAL_MEAN c, VAL_MEAN v
     WHERE c.VAL_MEAN_ID = v.VAL_MEAN_ID;


DROP VIEW ONEDATA_WA.VW_VAL_MEAN_PSV_CNSTRNT;

/* Formatted on 10/6/2021 12:35:21 PM (QP5 v5.354) */
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.VW_VAL_MEAN_PSV_CNSTRNT
(
    VAL_DOM_ITEM_ID,
    VAL_DOM_VER_NR,
    CONC_DOM_ITEM_ID,
    CONC_DOM_VER_NR,
    VAL_MEAN_ID,
    CREAT_DT,
    CREAT_USR_ID,
    LST_UPD_USR_ID,
    FLD_DELETE,
    LST_DEL_DT,
    S2P_TRN_DT,
    LST_UPD_DT
)
BEQUEATH DEFINER
AS
    SELECT VALUE_DOM.ITEM_ID,
           VALUE_DOM.VER_NR,
           CONC_DOM.ITEM_ID,
           CONC_DOM.VER_NR,
           CONC_DOM_VAL_MEAN.VAL_MEAN_ID,
           CONC_DOM_VAL_MEAN.CREAT_DT,
           CONC_DOM_VAL_MEAN.CREAT_USR_ID,
           CONC_DOM_VAL_MEAN.LST_UPD_USR_ID,
           CONC_DOM_VAL_MEAN.FLD_DELETE,
           CONC_DOM_VAL_MEAN.LST_DEL_DT,
           CONC_DOM_VAL_MEAN.S2P_TRN_DT,
           CONC_DOM_VAL_MEAN.LST_UPD_DT
      FROM VALUE_DOM, CONC_DOM, CONC_DOM_VAL_MEAN
     WHERE     VALUE_DOM.CONC_DOM_ITEM_ID = CONC_DOM.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CONC_DOM.VER_NR
           AND CONC_DOM.ITEM_ID = CONC_DOM_VAL_MEAN.CONC_DOM_ITEM_ID
           AND CONC_DOM.VER_NR = CONC_DOM_VAL_MEAN.CONC_DOM_VER_NR;


GRANT SELECT ON ONEDATA_WA.CNCPT_CONC_DOM TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.CNCPT_DEC TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.CNCPT_OBJ_CLS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.CNCPT_PROP TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.INSTALLED_COMPONENT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_ADMIN_ITEM TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_ADMIN_ITEM_GLBL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_ADMIN_STUS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_ADMIN_STUS_RUL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_AI_CSI TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_ALT_NMS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_CD_PSV_CNSTRNT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_CHAR_SET TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_CMNTS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_CNCPT_CHLDRN TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_CNTCT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DATA_ELEM_RPT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DATA_TYP TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DEC_MTCHG TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DERV_RUL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DE_CONC TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DE_HORT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DE_MTCHG TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_DE_REL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_EXMPLS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_AI TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_AI_CURRNT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_ALT_DEF TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_ALT_NMS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_CSI_DE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_DE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_DE_CNCPT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_DE_EXCEL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_DE_HORT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_DE_PV TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_FORM_MODULE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_NCI_MODULE_DE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_CLS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_1 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_10 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_11 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_12 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_13 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_14 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_15 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_2 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_3 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_4 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_5 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_6 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_7 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_8 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OBJ_KEY_9 TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_OC_PROP TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_PERM_VAL_FOR_DE TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_PERM_VAL_VAL_DOM_CONC_DOM TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_PROP TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_REF TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_REGIST_AUTH TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_REGIS_STUS_RUL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_REGSTR_STUS TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_SYS_TBL_COL TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_VALUE_DOM TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_VAL_MEAN TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_VAL_MEAN_CONC_DOM TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.VW_VAL_MEAN_PSV_CNSTRNT TO ONEDATA_RO;

GRANT SELECT ON ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW_OLD TO PUBLIC;
