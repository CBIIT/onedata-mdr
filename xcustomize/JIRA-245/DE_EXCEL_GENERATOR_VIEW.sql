CREATE OR REPLACE FORCE VIEW DE_EXCEL_GENERATOR_VIEW
(    DE_IDSEQ,
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

--CREATE OR REPLACE  VIEW DE_EXCEL_GENERATOR_VIEW
AS
    SELECT 
    
    
       
 ai.NCI_IDSEQ                                   DE_IDSEQ,
        ai.ITEM_ID                                     CDE_ID,          
        ai.ITEM_LONG_NM                                "PreferredName",           
        ai.ITEM_NM      "LongName",                               
        ai.ITEM_DESC                                   "PreferredDefinition",
        de.PREF_QUEST_TXT  DOC_TEXT,
        ai.VER_NR                                      Version,
        NVL(AI.ORIGIN, AI.ORIGIN_ID_DN) ORIGIN,
        AI.EFF_DT BEGIN_DATE, 
        AI.CNTXT_NM_DN   DE_CONTE_NAME,
        AI.CNTXT_ITEM_ID  DE_CONTE_ITEM_ID,
        AI.CNTXT_VER_NR  DE_CONTE_VER_NR,	      
        DEC_ID,
        DEC_PREFERRED_NAME,    
        DEC_VERSION,
        DEC_CONTEXT_NAME DEC_CONTE_NAME, 
        DEC_CONTEXT_VERSION DEC_CONTE_VERSION,
 	VAL_DOM_ITEM_ID VD_ID,
	vdai.ITEM_LONG_NM VD_PREFERRED_NAME,
	VAL_DOM_VER_NR VD_VERSION,
	vdai.CNTXT_NM_DN   VD_CONTE_NAME,
    vdai.CNTXT_VER_NR  VD_CONTE_VERSION,
	VAL_DOM_TYP_ID VD_TYPE,
	dt.NCI_CD DTL_NAME,
	VAL_DOM_HIGH_VAL_NUM  MAX_LENGTH_NUM,
    VAL_DOM_LOW_VAL_NUM MIN_LENGTH_NUM,
    VAL_DOM_MAX_CHAR  HIGH_VALUE_NUM,
    VAL_DOM_MIN_CHAR LOW_VALUE_NUM,
    NCI_DEC_PREC DECIMAL_PLACE,
    fmt.nci_cd FORML_NAME,
    vdai.ITEM_NM VD_LONG_NAME,
    CD_ID,
    CD_PREFERRED_NAME,
    CD_VERSION,
    CD_CONTEXT_NAME CD_CONTE_NAME,
    --CD_PREFERRED_NAME,
    OC_ID,
    OC_PREFERRED_NAME,
    OC_LONG_NAME,
    OC_VERSION,
    OC_CONTEXT_NAME OC_CONTE_NAME,
    PROP_ID PROP_ID,
    PT_PREFERRED_NAME PROP_PREFERRED_NAME,
    PT_VERSION PROP_VERSION,
    PT_LONG_NAME PROP_LONG_NAME,
    PT_CONTEXT_NAME PROP_CONTE_NAME,
    DEC_LONG_NAME,
    ai.ADMIN_STUS_NM_DN   DE_WK_FLOW_STATUS,
    ai.REGSTR_STUS_NM_DN   REGISTRATION_STATUS,
       CAST (
               MULTISET (
              SELECT pv.PERM_VAL_NM,
                              pv.PERM_VAL_DESC_TXT,
                              vm.item_desc,
                              nci_11179.get_concepts (vm.item_id,
                                                      vm.ver_nr)
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
                              AND vm.NCI_IDSEQ=def.NCI_IDSEQ(+)
                              AND vm.ADMIN_ITEM_TYP_ID = 53  --GF32647 JR1047
                                                            )
                   AS valid_value_list_t)                 valid_values
                   ,
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
                   AS cdebrowser_rd_list_t)               "ReferenceDocumentsList"
                   ,
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
                   AS cdebrowser_csi_list_t)              ClassificationsList
                   ,
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
                     SELECT con.item_long_nm ,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item  com, admin_item con
                       , obj_key ok,CNCPT cn
                      WHERE con.item_id = com.cncpt_item_id
                     AND con.ver_nr = cn.ver_nr
                     AND con.item_id = cn.item_id
                     AND con.ver_nr = com.cncpt_ver_nr
                     And cn.EVS_SRC_ID=ok.OBJ_KEY_ID
                     and com.item_id=VDAI.ITEM_ID
                     and com.ver_nr=VDAI.VER_NR
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    vd_concepts,
                                      CAST (
               MULTISET (
                     SELECT con.item_long_nm ,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item  com, admin_item con
                       , obj_key ok,CNCPT cn
                      WHERE con.item_id = com.cncpt_item_id
                     AND con.ver_nr = cn.ver_nr
                     AND con.item_id = cn.item_id
                     AND con.ver_nr = com.cncpt_ver_nr
                     And cn.EVS_SRC_ID=ok.OBJ_KEY_ID
                     and com.item_id=OC_id
                     and com.ver_nr=OC_VERSION
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    oc_concepts,
                   CAST (
               MULTISET (
                    SELECT con.item_long_nm ,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item  com, admin_item con
                       , obj_key ok,CNCPT cn
                      WHERE con.item_id = com.cncpt_item_id
                     AND con.ver_nr = cn.ver_nr
                     AND con.item_id = cn.item_id
                     AND con.ver_nr = com.cncpt_ver_nr
                     And cn.EVS_SRC_ID=ok.OBJ_KEY_ID
                     and com.item_id=PROP_ID
                     and com.ver_nr=PT_VERSION
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)                    prop_concepts,
                   
           rep.item_id                        rep_id,
           rep.item_long_nm                   rep_preferred_name,
           rep.item_nm                     rep_long_name,
           rep.ver_nr                         rep_version,
           rep.CNTXT_NM_DN                    rep_conte_name,
           CAST (
               MULTISET (
                        SELECT con.item_long_nm ,
                            con.item_nm,
                            con.item_id,
                            con.DEF_SRC,
                            NVL (con.origin, con.ORIGIN_ID_DN),
                            ok.OBJ_KEY_DESC,
                            com.NCI_PRMRY_IND,
                            com.NCI_ORD
                       FROM cncpt_admin_item  com, admin_item con
                       , obj_key ok,CNCPT cn
                      WHERE con.item_id = com.cncpt_item_id
                     AND con.ver_nr = cn.ver_nr
                     AND con.item_id = cn.item_id
                     AND con.ver_nr = com.cncpt_ver_nr
                     And cn.EVS_SRC_ID=ok.OBJ_KEY_ID
                     and com.item_id=rep.item_id
                     and com.ver_nr=rep.ver_nr
                   ORDER BY NCI_ORD DESC)
                   AS Concepts_list_t)
                                     rep_concepts 
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
           ( SELECT rd.item_id,rd.ver_nr,rd.NCI_IDSEQ,
                          ok.obj_key_desc,
                          rd.disp_ord
                     FROM REF rd, obj_key ok
                    WHERE     rd.REF_TYP_ID = ok.obj_key_id
                          AND ok.obj_key_desc='Preferred Question Text'
                          )rfd
           
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
           and vd.DTTYPE_ID=dt.DTTYPE_ID
           AND fmt.fmt_id(+)=vd.VAL_DOM_FMT_ID
           AND de.val_dom_item_id = vd.item_id
           AND de.val_dom_ver_nr = vd.ver_nr
           AND ai.item_id = ccd.item_id(+)
           AND ai.ver_nr = ccd.ver_nr(+);         
                   
                   
        /*           
                   
      FROM sbr.data_elements           de,
           sbr.data_element_concepts   dec,
           sbr.contexts                de_conte,
           sbr.value_domains           vd,
           sbr.contexts                vd_conte,
           sbr.contexts                dec_conte,
           sbr.ac_registrations        acr,
           cdebrowser_complex_de_view  ccd,
           conceptual_domains          cd,
           contexts                    cd_conte,
           object_classes_Ext          oc,
           contexts                    oc_conte,
           properties_ext              prop,
           representations_ext         rep,
           contexts                    prop_conte,
           contexts                    rep_conte,
           (SELECT ac_idseq, doc_text
              FROM reference_documents
             WHERE dctl_name = 'Preferred Question Text') rd
     WHERE     de.dec_idseq = dec.dec_idseq
           AND de.conte_idseq = de_conte.conte_idseq
           AND de.vd_idseq = vd.vd_idseq
           AND vd.conte_idseq = vd_conte.conte_idseq
           AND dec.conte_idseq = dec_conte.conte_idseq
           AND de.de_idseq = rd.ac_idseq(+)
           AND de.de_idseq = acr.ac_idseq(+)
           AND de.de_idseq = ccd.p_de_idseq(+)
           AND vd.cd_idseq = cd.cd_idseq
           AND cd.conte_idseq = cd_conte.conte_idseq
           AND dec.oc_idseq = oc.oc_idseq(+)
           AND oc.conte_idseq = oc_conte.conte_idseq(+)
           AND dec.prop_idseq = prop.prop_idseq(+)
           AND prop.conte_idseq = prop_conte.conte_idseq(+)
           AND vd.rep_idseq = rep.rep_idseq(+)
           AND rep.conte_idseq = rep_conte.conte_idseq(+);*/
           
           --desc DE
          -- select*from DE_EXCEL_GENERATOR_VIEW where CDE_ID=791;
          -- select*from sbrext.DE_EXCEL_GENERATOR_VIEW where CDE_ID=791;