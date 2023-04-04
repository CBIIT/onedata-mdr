CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW
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
       dec.ITEM_LONG_NM                       dec_preferred_name,
       dec.ITEM_NM                            dec_long_name,           
       dec.ITEM_DESC                          PREFERRED_DEFINITION,
       dec.ver_nr                             dec_version,
       dec.admin_stus_nm_dn                   ASL_NAME,
       dec.CNTXT_NM_DN                        dec_context_name,
       dec.CNTXT_ver_NR                       dec_context_version,
       oc.ITEM_LONG_NM                        oc_preferred_name,
       oc.VER_NR                              oc_version,
       oc.ITEM_NM                             oc_long_name,
       oc.CNTXT_NM_DN                         oc_context_name,
       oc.cntxt_VER_NR                        oc_context_version,
       pt.item_long_nm                        pt_preferred_name,
       pt.ver_NR                              pt_version,
       pt.ITEM_NM                             pt_long_name,
       pt.CNTXT_NM_DN                         pt_context_name,
       pt.cntxt_VER_NR                        pt_context_version,
       cd.ITEM_LONG_NM                        cd_preferred_name,
       cd.ver_NR                              cd_version,
       cd.ITEM_NM                             cd_long_name,
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


GRANT SELECT ON ONEDATA_WA.CDEBROWSER_DE_DEC_VIEW TO ONEDATA_RO;
