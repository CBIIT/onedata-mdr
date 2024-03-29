--Related to JIRA859 -- 
create or replace function get_concepts859(v_item_id in number, v_ver_nr in number) return varchar2 is
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
GRANT DEBUG, EXECUTE on get_concepts859 to ONEDATA_RO;
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N
(ITEM_ID, VER_NR, CRTL_NAME, DESCRIPTION, METHODS, 
 RULE, CONCAT_CHAR, "DataElementsList")
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
                    WHERE cdr.C_ITEM_ID = de.ITEM_ID
                          AND cdr.C_ITEM_VER_NR = de.VER_NR
                          AND de.admin_item_typ_id = 4
                          AND cde.ITEM_ID = cdr.p_ITEM_ID(+)
                          AND cde.VER_NR = cdr.p_ITEM_VER_NR(+)
                          order by cdr.DISP_ORD)
                   AS ONEDATA_WA.data_element_derivation_list_t)    "DataElementsList"
      FROM DE cde, OBJ_KEY ctl
     WHERE cde.DERV_TYP_ID = ctl.OBJ_KEY_ID AND ctl.OBJ_TYP_ID = 21;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.DE_EXCEL_GENERATOR_VIEW
(DE_IDSEQ, CDE_ID, LONG_NAME, PREFERRED_NAME, PREFERRED_DEFINITION, 
 DOC_TEXT, VERSION, ORIGIN, BEGIN_DATE, DE_CONTE_NAME, 
 DE_CONTE_ITEM_ID, DE_CONTE_VERSION, DEC_ID, DEC_PREFERRED_NAME, DEC_VERSION, 
 DEC_CONTE_NAME, DEC_CONTE_VERSION, VD_ID, VD_PREFERRED_NAME, VD_VERSION, 
 VD_CONTE_NAME, VD_CONTE_VERSION, VD_TYPE, DTL_NAME, MAX_LENGTH_NUM, 
 MIN_LENGTH_NUM, HIGH_VALUE_NUM, LOW_VALUE_NUM, DECIMAL_PLACE, FORML_NAME, 
 VD_LONG_NAME, CD_ID, CD_PREFERRED_NAME, CD_VERSION, CD_CONTE_NAME, 
 OC_ID, OC_PREFERRED_NAME, OC_LONG_NAME, OC_VERSION, OC_CONTE_NAME, 
 PROP_ID, PROP_PREFERRED_NAME, PROP_LONG_NAME, PROP_VERSION, PROP_CONTE_NAME, 
 DEC_LONG_NAME, DE_WK_FLOW_STATUS, REGISTRATION_STATUS, VALID_VALUES, REFERENCE_DOCS, 
 CLASSIFICATIONS, DESIGNATIONS, DE_DERIVATION, VD_CONCEPTS, OC_CONCEPTS, 
 PROP_CONCEPTS, REP_ID, REP_PREFERRED_NAME, REP_LONG_NAME, REP_VERSION, 
 REP_CONTE_NAME, REP_CONCEPTS)
BEQUEATH DEFINER
AS 
SELECT ai.NCI_IDSEQ                                   DE_IDSEQ,
           ai.ITEM_ID                                     CDE_ID,
           ai.ITEM_NM                                     LONG_NAME, 
           ai.ITEM_LONG_NM                                PREFERRED_NAME, 
           ai.ITEM_DESC                                   PREFERRED_DEFINITION,
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
           DECODE(VAL_DOM_TYP_ID,17,'Enumerated',18,'Non Enumerated')  VD_TYPE,--fixed
           dt.NCI_CD                                      DTL_NAME,
           VAL_DOM_MAX_CHAR                            MAX_LENGTH_NUM , --fixed
           VAL_DOM_MIN_CHAR                           MIN_LENGTH_NUM,
           VAL_DOM_HIGH_VAL_NUM                               HIGH_VALUE_NUM,--fixed
           VAL_DOM_LOW_VAL_NUM                              LOW_VALUE_NUM,                
           NCI_DEC_PREC                                   DECIMAL_PLACE,
           fmt.nci_cd                                     FORML_NAME,
           vdai.ITEM_NM                                   VD_LONG_NAME,
           CD_ID,
           CD_PREFERRED_NAME,
           CD_VERSION,
           CD_CONTEXT_NAME                                CD_CONTE_NAME,
           OC_ID,
           OC_PREFERRED_NAME, 
		   OC_LONG_NAME,          
           OC_VERSION,
           OC_CONTEXT_NAME                                OC_CONTE_NAME,
           PROP_ID                                        PROP_ID,
           PT_PREFERRED_NAME                              PROP_PREFERRED_NAME,           
           PT_LONG_NAME                                   PROP_LONG_NAME,
           PT_VERSION                                     PROP_VERSION,
           PT_CONTEXT_NAME                                PROP_CONTE_NAME,
           DEC_LONG_NAME,
           ai.ADMIN_STUS_NM_DN                            DE_WK_FLOW_STATUS,
           ai.REGSTR_STUS_NM_DN                           REGISTRATION_STATUS,
           CAST (
               MULTISET (
                   SELECT pv.PERM_VAL_NM,
                          pv.PERM_VAL_DESC_TXT,
                          vm.item_desc,
                          get_concepts859 (vm.item_id, vm.ver_nr)
                          MeaningConcepts,
                          pv.PERM_VAL_BEG_DT,--fixed
                          pv.PERM_VAL_END_DT,--fixed
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
                   AS ONEDATA_WA.VALID_VALUE_LIST_T_245)             valid_values,
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
                   AS ONEDATA_WA.cdebrowser_rd_list_t)               "ReferenceDocumentsList",
           CAST (
               MULTISET (
                   SELECT ONEDATA_WA.admin_component_with_id_t (csv.cs_item_id,
                                                     csv.cs_cntxt_nm,
                                                     csv.cs_cntxt_ver_nr,
                                                     csv.cs_item_long_nm,
                                                     csv.cs_ver_nr),
                          csv.csi_item_nm,
                          csv.csitl_nm,
                          csv.csi_item_id,
                          csv.csi_ver_nr
                     FROM ONEDATA_WA.cdebrowser_cs_view_n csv
                    WHERE     de.item_id = csv.de_item_id
                          AND de.ver_nr = csv.de_ver_nr)
                   AS ONEDATA_WA.cdebrowser_csi_list_t)              ClassificationsList,
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
                   AS ONEDATA_WA.cdebrowser_altname_list_t)          designations,
           ONEDATA_WA.derived_data_element_t (ccd.CRTL_NAME,
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
                            decode(com.NCI_PRMRY_IND,'1','Yes','0','No'),
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
                   AS ONEDATA_WA.Concepts_list_t)                    vd_concepts,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            DECODE(com.NCI_PRMRY_IND,1,'Yes',0,'No'),
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
                   AS ONEDATA_WA.Concepts_list_t)                    oc_concepts,
           CAST (
               MULTISET (
                     SELECT con.item_long_nm,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            DECODE(com.NCI_PRMRY_IND,1,'Yes',0,'No'),
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
                   AS ONEDATA_WA.Concepts_list_t)                    prop_concepts,
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
                             DECODE(com.NCI_PRMRY_IND,1,'Yes',0,'No'),
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
                   AS ONEDATA_WA.Concepts_list_t)                    rep_concepts
      FROM ADMIN_ITEM                    ai,
           ONEDATA_WA.cdebrowser_de_dec_view        dec,
           admin_item                    vdai,
           ADMIN_ITEM                    cd,
           ADMIN_ITEM                    rep,
           value_dom                     vd,
           de                            de,
           data_typ                      dt,
           fmt,
           ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N  ccd,
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


GRANT SELECT on CDEBROWSER_COMPLEX_DE_VIEW_N to ONEDATA_RO;
GRANT SELECT on DE_EXCEL_GENERATOR_VIEW to ONEDATA_RO;
GRANT EXECUTE,DEBUG on VALID_VALUE_T_245 to ONEDATA_RO; 
GRANT EXECUTE,DEBUG on VALID_VALUE_LIST_T_245 to ONEDATA_RO;  
GRANT EXECUTE on NCI_CADSR_PUSH to ONEDATA_RO;
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
/* view has errors VW_CNCPT_CHLDRN
GRANT SELECT on VW_CNCPT_CHLDRN to ONEDATA_RO;
*/
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

