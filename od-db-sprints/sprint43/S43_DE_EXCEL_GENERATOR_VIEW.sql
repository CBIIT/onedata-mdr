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
                         ONEDATA_WA.get_concepts859 (vm.item_id, vm.ver_nr)
                          MeaningConcepts,
                          pv.PERM_VAL_BEG_DT,--fixed
                          pv.PERM_VAL_END_DT,--fixed
                          vm.item_id,
                          vm.ver_nr,
                          DEF_DESC
                     FROM ONEDATA_WA.PERM_VAL pv, ONEDATA_WA.ADMIN_ITEM vm, ONEDATA_WA.ALT_DEF def
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
                     FROM ONEDATA_WA.REF rd, ONEDATA_WA.obj_key ok, ONEDATA_WA.NCI_ORG org
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
                     FROM ONEDATA_WA.alt_nms des, ONEDATA_WA.obj_key ok
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
                       FROM ONEDATA_WA.cncpt_admin_item com,
                            ONEDATA_WA.admin_item      con,
                            ONEDATA_WA.obj_key         ok,
                            ONEDATA_WA.CNCPT           cn
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
                       FROM ONEDATA_WA.cncpt_admin_item com,
                            ONEDATA_WA.admin_item      con,
                            ONEDATA_WA.obj_key         ok,
                            ONEDATA_WA.CNCPT           cn
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
                       FROM ONEDATA_WA.cncpt_admin_item com,
                            ONEDATA_WA.admin_item      con,
                            ONEDATA_WA.obj_key         ok,
                            ONEDATA_WA.CNCPT           cn
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
                       FROM ONEDATA_WA.cncpt_admin_item com,
                            ONEDATA_WA.admin_item      con,
                            ONEDATA_WA.obj_key         ok,
                            ONEDATA_WA.CNCPT           cn
                      WHERE     con.item_id = com.cncpt_item_id
                            AND con.ver_nr = cn.ver_nr
                            AND con.item_id = cn.item_id
                            AND con.ver_nr = com.cncpt_ver_nr
                            AND cn.EVS_SRC_ID = ok.OBJ_KEY_ID
                            AND com.item_id = rep.item_id
                            AND com.ver_nr = rep.ver_nr
                   ORDER BY NCI_ORD DESC)
                   AS ONEDATA_WA.Concepts_list_t)                    rep_concepts
      FROM ONEDATA_WA.ADMIN_ITEM                    ai,
           ONEDATA_WA.cdebrowser_de_dec_view        dec,
           ONEDATA_WA.admin_item                    vdai,
           ONEDATA_WA.ADMIN_ITEM                    cd,
           (select* from ONEDATA_WA.ADMIN_ITEM  where ADMIN_ITEM_TYP_ID = 7 )            REP,
           ONEDATA_WA.value_dom                     vd,
           ONEDATA_WA.de                            de,
           ONEDATA_WA.data_typ                      dt,
           ONEDATA_WA.fmt,
           ONEDATA_WA.CDEBROWSER_COMPLEX_DE_VIEW_N  ccd,
           (SELECT rd.item_id,
                   rd.ver_nr,
                   rd.NCI_IDSEQ,
                   ok.obj_key_desc,
                   rd.disp_ord
              FROM ONEDATA_WA.REF rd, ONEDATA_WA.obj_key ok
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
           AND VD.REP_CLS_ITEM_ID=REP.ITEM_ID(+)
           AND VD.REP_CLS_VER_NR=REP.VER_NR (+)
           AND de.val_dom_item_id = vdai.item_id
           AND de.val_dom_ver_nr = vdai.ver_nr
           AND vdai.admin_item_typ_id = 3
           AND vd.DTTYPE_ID = dt.DTTYPE_ID
           AND fmt.fmt_id(+) = vd.VAL_DOM_FMT_ID
           AND de.val_dom_item_id = vd.item_id
           AND de.val_dom_ver_nr = vd.ver_nr
           AND ai.item_id = ccd.item_id(+)
           AND ai.ver_nr = ccd.ver_nr(+);           
GRANT SELECT ON ONEDATA_WA.DE_EXCEL_GENERATOR_VIEW TO ONEDATA_RO;
