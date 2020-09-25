CREATE OR REPLACE PROCEDURE ONEDATA_WA.SAG_ITEM_VALIDATION
AS
BEGIN
    /*****************************************************
    Created By : Akhilesh Trikha
    Created on : 06/24/2020
    Version: 1.0
    Details: Validate SBR and SBREXT tables
    Update History:

    *****************************************************/
    -- Validate sbr.DATA_ELEMENTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             TO_CHAR (REPLACE (FLD_DELETE, 0, 'No'))
                                 FLD_DELETE,
                             LST_UPD_DT
                        FROM ONEDATA_WA.DE
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT CDE_ID,
                             VERSION,
                             NVL (DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (CREATED_BY, 'ONEDATA'),
                             NVL (MODIFIED_BY, 'ONEDATA'),
                             DELETED_IND,
                             NVL (NVL (DATE_MODIFIED, DATE_CREATED),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
                        FROM sbr.data_elements) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     FLD_DELETE,
                     LST_UPD_DT
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   DE_IDSEQ,
                   CDE_ID,
                   VERSION,
                   'DATAELEMENTS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE',
                   'ONEDATA_WA'
              FROM sbr.data_elements
             WHERE CDE_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONTEXTS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             LANG_ID,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM ONEDATA_WA.CNTXT
                       WHERE item_id <> -20005
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             1000,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.contexts c, ONEDATA_WA.admin_item ai
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                             AND ai.admin_item_typ_id = 8) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     LANG_ID,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONTEXTS',
                   NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNTXT',
                   'ONEDATA_WA'
              FROM sbr.contexts c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CONCEPTUAL_DOMAINS
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             DIMNSNLTY,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CONC_DOM
                       WHERE item_id <> -20002
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             dimensionality,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.conceptual_domains c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     DIMNSNLTY,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   CONTE_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CONCEPTUAL_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CONC_DOM',
                   'ONEDATA_WA'
              FROM sbr.conceptual_domains c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate OBJECT_CLASSES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.OBJ_CLS
                       WHERE item_id <> -20000
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.OBJECT_CLASSES_EXT c,
                             ONEDATA_WA.admin_item    ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   OC_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'OBJECT_CLASSES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'OBJ_CLS',
                   'ONEDATA_WA'
              FROM sbrext.object_classes_ext c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROPERTIES_EXT
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.PROP
                       WHERE item_id <> -20001
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.properties_ext c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   PROP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROPERTIES_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PROP',
                   'ONEDATA_WA'
              FROM sbrext.properties_ext c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.PROP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate CLASSIFICATION_SCHEMES
    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CLSFCTN_SCHM_TYP_ID,
                             NCI_LABEL_TYP_FLG,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CLSFCTN_SCHM
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             ok.obj_key_id,
                             label_type_flag,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.classification_schemes c,
                             ONEDATA_WA.admin_item     ai,
                             ONEDATA_WA.obj_key        ok
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.CS_idseq)
                             AND TRIM (cstl_name) = ok.nci_cd
                             AND ok.obj_typ_id = 3) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CLSFCTN_SCHM_TYP_ID,
                     NCI_LABEL_TYP_FLG,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   CS_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CLASSIFICATION_SCHEMES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CLSFCTN_SCHM',
                   'ONEDATA_WA'
              FROM sbr.CLASSIFICATION_SCHEMES c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.cs_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate REPRESENTATIONS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.REP_CLS
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.representations_ext c,
                             ONEDATA_WA.admin_item     ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   REP_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'REPRESENTATIONS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'REP_CLS',
                   'ONEDATA_WA'
              FROM sbrext.REPRESENTATIONS_EXT c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.REP_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate DATA_ELEMENT_CONCEPTS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             OBJ_CLS_QUAL,
                             PROP_QUAL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.DE_CONC
                       WHERE item_id NOT IN -20003
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             c.version,
                             OBJ_CLASS_QUALIFIER,
                             PROPERTY_QUALIFIER,
                             NVL (c.created_by, 'ONEDATA'),
                             NVL (c.date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (c.date_modified, c.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (c.modified_by, 'ONEDATA')
                        FROM sbr.DATA_ELEMENT_CONCEPTS  c,
                             ONEDATA_WA.admin_item      ai,
                             sbr.Administered_Components ac
                       WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                             AND c.CD_IDSEQ = ac_idseq
                             AND public_id > 0) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     OBJ_CLS_QUAL,
                     PROP_QUAL,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   DEC_IDSEQ,
                   ai.ITEM_ID,
                   c.VERSION,
                   'DATA_ELEMENT_CONCEPTS',
                   c.PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'DE_CONC',
                   'ONEDATA_WA'
              FROM sbr.data_element_concepts    c,
                   ONEDATA_WA.admin_item        ai,
                   sbr.Administered_Components  ac
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.dec_idseq)
                   AND c.CD_IDSEQ = ac_idseq
                   AND public_id > 0
                   AND ai.ITEM_ID = x.ITEM_ID
                   AND c.VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_DOMAINS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             NCI_DEC_PREC,
                             VAL_DOM_HIGH_VAL_NUM,
                             VAL_DOM_LOW_VAL_NUM,
                             VAL_DOM_MAX_CHAR,
                             VAL_DOM_MIN_CHAR,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.VALUE_DOM
                       WHERE item_id <> -20004
                      UNION ALL
                      SELECT ai.ITEM_ID,
                             version,
                             decimal_place,
                             high_value_num,
                             low_value_num,
                             max_length_num,
                             min_length_num,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.VALUE_DOMAINS c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     NCI_DEC_PREC,
                     VAL_DOM_HIGH_VAL_NUM,
                     VAL_DOM_LOW_VAL_NUM,
                     VAL_DOM_MAX_CHAR,
                     VAL_DOM_MIN_CHAR,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   vd_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_DOMAINS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'VALUE_DOM',
                   'ONEDATA_WA'
              FROM sbr.value_domains c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.vd_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate OC_RECS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             REL_TYP_NM,
                             SRC_ROLE,
                             TRGT_ROLE,
                             DRCTN,
                             SRC_LOW_MULT,
                             SRC_HIGH_MULT,
                             TRGT_LOW_MULT,
                             TRGT_HIGH_MULT,
                             DISP_ORD,
                             DIMNSNLTY,
                             ARRAY_IND
                        FROM onedata_wa.NCI_OC_RECS
                      UNION ALL
                      SELECT ocr_id,
                             version,
                             rl_name,
                             source_role,
                             target_role,
                             direction,
                             source_low_multiplicity,
                             source_high_multiplicity,
                             target_low_multiplicity,
                             target_high_multiplicity,
                             display_order,
                             dimensionality,
                             array_ind
                        FROM sbrext.oc_recs_ext c, ONEDATA_WA.admin_item ai
                       WHERE TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     REL_TYP_NM,
                     SRC_ROLE,
                     TRGT_ROLE,
                     DRCTN,
                     SRC_LOW_MULT,
                     SRC_HIGH_MULT,
                     TRGT_LOW_MULT,
                     TRGT_HIGH_MULT,
                     DISP_ORD,
                     DIMNSNLTY,
                     ARRAY_IND
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   t_oc_idseq,
                   ITEM_ID,
                   VERSION,
                   'OC_RECS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_OC_RECS',
                   'ONEDATA_WA'
              FROM sbrext.OC_RECS_EXT c, ONEDATA_WA.admin_item ai
             WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.t_oc_idseq)
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CONCEPTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             evs_src_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.CNCPT
                      UNION ALL
                      SELECT con_id,
                             version,
                             ok.obj_key_id,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.CONCEPTS_EXT c, ONEDATA_WA.obj_key ok
                       WHERE     c.evs_source = ok.obj_key_desc(+)
                             AND ok.obj_typ_id(+) = 23) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     evs_src_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   CON_IDSEQ,
                   con_id,
                   VERSION,
                   'CONCEPTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'CNCPT',
                   'ONEDATA_WA'
              FROM sbrext.CONCEPTS_EXT c
             WHERE con_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate CS_ITEMS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             CSI_DESC_TXT,
                             CSI_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_CLSFCTN_SCHM_ITEM
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.cs_items cd, ONEDATA_WA.admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.CSI_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CSI_DESC_TXT,
                     CSI_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   CSI_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'CS_ITEMS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_CLSFCTN_SCHM_ITEM',
                   'ONEDATA_WA'
              FROM sbr.CS_ITEMS cd, ONEDATA_WA.admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALUE_MEANINGS

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             VM_DESC_TXT,
                             VM_CMNTS,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_VAL_MEAN
                      UNION ALL
                      SELECT item_id,
                             version,
                             description,
                             comments,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbr.VALUE_MEANINGS cd, ONEDATA_WA.admin_item ai
                       WHERE ai.NCI_IDSEQ = cd.VM_IDSEQ) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     VM_DESC_TXT,
                     VM_CMNTS,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   VM_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'VALUE_MEANINGS',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_VAL_MEAN',
                   'ONEDATA_WA'
              FROM sbr.value_meanings cd, ONEDATA_WA.admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.VM_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    -- Validate QUEST_CONTENTS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             catgry_id,
                             form_typ_id,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_FORM
                      UNION ALL
                      SELECT qc_id,
                             version,
                             ok.obj_key_id,
                             DECODE (qc.qtl_name,  'CRF', 70,  'TEMPLATE', 71),
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA')
                        FROM sbrext.quest_contents_ext qc,
                             ONEDATA_WA.obj_key       ok
                       WHERE     qc.qcdl_name = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 22
                             AND qc.qtl_name IN ('TEMPLATE', 'CRF')) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     catgry_id,
                     form_typ_id,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   QC_IDSEQ,
                   qc_id,
                   VERSION,
                   'QUEST_CONTENTS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM',
                   'ONEDATA_WA'
              FROM sbrext.QUEST_CONTENTS_EXT
             WHERE qc_id = x.ITEM_ID AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate PROTOCOLS_EXT

    FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (SELECT ITEM_ID,
                             VER_NR,
                             PROTCL_TYP_ID,
                             PROTCL_ID,
                             LEAD_ORG,
                             PROTCL_PHASE,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID,
                             CHNG_TYP,
                             CHNG_NBR,
                             RVWD_DT,
                             RVWD_USR_ID,
                             APPRVD_DT,
                             APPRVD_USR_ID
                        FROM onedata_wa.NCI_PROTCL
                      UNION ALL
                      SELECT ai.item_id,
                             version,
                             ok.obj_key_id,
                             protocol_id,
                             LEAD_ORG,
                             PHASE,
                             NVL (created_by, 'ONEDATA'),
                             NVL (date_created,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (date_modified, date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (modified_by, 'ONEDATA'),
                                 CHANGE_TYPE,
                             CHANGE_NUMBER,
                             REVIEWED_DATE,
                             REVIEWED_BY,
                             APPROVED_DATE,
                             APPROVED_BY
                        FROM sbrext.PROTOCOLS_EXT cd,
                             ONEDATA_WA.admin_item ai,
                             ONEDATA_WA.obj_key   ok
                       WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                             AND TRIM (TYPE) = ok.nci_cd(+)
                             AND ok.obj_typ_id(+) = 19
                             AND ai.admin_item_typ_id = 50) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     PROTCL_TYP_ID,
                     PROTCL_ID,
                     LEAD_ORG,
                     PROTCL_PHASE,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID,
                     CHNG_TYP,
                     CHNG_NBR,
                     RVWD_DT,
                     RVWD_USR_ID,
                     APPRVD_DT,
                     APPRVD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   proto_IDSEQ,
                   ITEM_ID,
                   VERSION,
                   'PROTOCOLS_EXT',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_PROTCL',
                   'ONEDATA_WA'
              FROM sbrext.protocols_ext cd, ONEDATA_WA.admin_item ai
             WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
                   AND ITEM_ID = x.ITEM_ID
                   AND VERSION = x.VER_NR;

        COMMIT;
    END LOOP;

    --Validate VALID_QUESTION_VALUES
    FOR x
        IN (  SELECT DISTINCT NCI_PUB_ID,                       --Primary Keys
                                          Q_VER_NR
                FROM (SELECT NCI_PUB_ID,
                             Q_PUB_ID,
                             Q_VER_NR,
                             VM_NM,
                             VM_DEF,
                             VALUE,
                             NCI_IDSEQ,
                             DESC_TXT,
                             MEAN_TXT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_DT,
                             LST_UPD_USR_ID
                        FROM onedata_wa.NCI_QUEST_VALID_VALUE
                      UNION ALL
                      SELECT qc.qc_id,
                             qc1.qc_id,
                             qc1.VERSION,
                             qc.preferred_name,
                             qc.preferred_definition,
                             qc.long_name,
                             qc.qc_idseq,
                             vv.description_text,
                             vv.meaning_text,
                             NVL (qc.created_by, 'ONEDATA'),
                             NVL (qc.DATE_CREATED,
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (NVL (qc.date_modified, qc.date_created),
                                  TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                             NVL (qc.modified_by, 'ONEDATA')
                        FROM sbrext.QUEST_CONTENTS_EXT  qc,
                             sbrext.quest_contents_ext  qc1,
                             sbrext.valid_values_att_ext vv
                       WHERE     qc.qtl_name = 'VALID_VALUE'
                             AND qc1.qtl_name = 'QUESTION'
                             AND qc1.qc_idseq = qc.p_qst_idseq
                             AND qc.qc_idseq = vv.qc_idseq(+)) t
            GROUP BY NCI_PUB_ID,
                     Q_PUB_ID,
                     Q_VER_NR,
                     VM_NM,
                     VM_DEF,
                     VALUE,
                     NCI_IDSEQ,
                     DESC_TXT,
                     MEAN_TXT,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
            ORDER BY NCI_PUB_ID, Q_VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   vv.qc_idseq,
                   qc_id,
                   VERSION,
                   'VALID_QUESTION_VALUES',
                   PREFERRED_NAME,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VALID_VALUE',
                   'ONEDATA_WA'
              FROM sbrext.valid_values_att_ext  vv,
                   sbrext.quest_contents_ext    qc
             WHERE     qc.qc_idseq = vv.qc_idseq
                   AND qc_id = x.NCI_PUB_ID
                   AND VERSION = x.Q_VER_NR;

        COMMIT;
    END LOOP;
    
--Sprint 5 Tables

--Validate COMPLEX_DATA_ELEMENTS
FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (SELECT DISTINCT de.ITEM_ID,                          --Primary Keys
                                           de.VER_NR, DERV_MTHD,
                            DERV_RUL,
                            de.DERV_TYP_ID,
                            de.CONCAT_CHAR,
                            DERV_DE_IND
                            from de , admin_item ai, sbr.complex_data_elements  cdr
                            WHERE de.item_id = ai.item_id
                           AND de.ver_nr = ai.ver_nr
                           AND cdr.p_de_idseq = ai.nci_idseq
                          UNION ALL
                          SELECT DISTINCT ai.ITEM_ID,                          --Primary Keys
                                           ai.VER_NR, METHODS,
                           RULE,
                           o.obj_key_id,
                           cdr.CONCAT_CHAR,
                           1
                      FROM sbr.complex_data_elements  cdr,
                           obj_key                    o,
                           admin_item                 ai
                     WHERE     cdr.CRTL_NAME = o.nci_cd(+)
                           AND o.obj_typ_id(+) = 21
                           AND cdr.p_de_idseq = ai.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR
                  HAVING COUNT (*) <> 2
                  ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
		                   NCI_IDSEQ,
		                   de.ITEM_ID,
		                   de.VER_NR,
		                   'COMPLEX_DATA_ELEMENTS',
		                   ITEM_NM,
		                   'DATA MISMATCH',
		                   SYSDATE,
		                   USER,
		                   'DE',
		                   'ONEDATA_WA'
		              FROM ONEDATA_WA.DE,ONEDATA_WA.admin_item ai 
		             WHERE ai.ITEM_ID=de.ITEM_ID and ai.VER_NR=de.VER_NR
             AND de.ITEM_ID = x.ITEM_ID AND de.VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
  
--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=5
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=5
    UNION ALL                                  
    SELECT con.item_id, 
                   con.ver_nr,
                   oc.item_id,
                   oc.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
               FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.object_classes_ext      oce,
                   admin_item                     con,
                   admin_item                     oc
             WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
                   AND oce.oc_idseq = oc.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH OBJECT_CLASSES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
   
 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=6
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=6 --106,987
    UNION ALL                                  
    SELECT con.item_id, --106,910
                   con.ver_nr,
                   prop.item_id,
                   prop.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.properties_ext          prope,
                   admin_item                     con,
                   admin_item                     prop
             WHERE     cc.CONDR_IDSEQ = prope.CONDR_IDSEQ
                   AND prope.prop_idseq = prop.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH PROPERTIES_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
   
 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=7
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=7 --28,142
    UNION ALL                                  
    SELECT con.item_id,
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbrext.representations_ext     repe,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = repe.CONDR_IDSEQ
                   AND Repe.rep_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH REPRESENTATIONS_EXT',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
    
--Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=53    
    
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=53 --85,641
    UNION ALL                                  
    SELECT con.item_id,--85,641
                   con.ver_nr,
                   rep.item_id,
                   rep.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbr.value_meanings             vm,
                   admin_item                     con,
                   admin_item                     rep
             WHERE     cc.CONDR_IDSEQ = vm.CONDR_IDSEQ
                   AND vm.vm_idseq = rep.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH VALUE_MEANINGS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
    
 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=3   
  FOR x
        IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                       VER_NR
                FROM (Select cncpt_item_id,
                                  cncpt_ver_nr,
                                  cai.item_id,
                                  cai.ver_nr,
                                  cai.nci_ord,
                                  cai.nci_prmry_ind,
                                  nci_cncpt_val,
                                  cai.CREAT_USR_ID,
                                  cai.CREAT_DT,
                                  cai.LST_UPD_DT,
                                  cai.LST_UPD_USR_ID
from cncpt_admin_item cai, admin_item ai
where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
and ADMIN_ITEM_TYP_ID=3 --85,641
UNION ALL                                  
SELECT con.item_id,
               con.ver_nr,
               vd.item_id,
               vd.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,'ONEDATA'),
               nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(cc.modified_by,'ONEDATA')
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbr.value_domains              vde,
               admin_item                     con,
               admin_item                     vd
         WHERE     cc.CONDR_IDSEQ = vde.CONDR_IDSEQ
               AND vde.vd_idseq = vd.nci_idseq
               AND cc.con_idseq = con.nci_idseq) t
            GROUP BY ITEM_ID,
                     VER_NR,
                     CREAT_DT,
                     CREAT_USR_ID,
                     LST_UPD_USR_ID,
                     LST_UPD_DT,
                     nci_ord
              HAVING COUNT (*) <> 2
            ORDER BY ITEM_ID, VER_NR)
    LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   ITEM_ID,
                   VER_NR,
                   'COMPONENT_CONCEPTS_EXT',
                   ITEM_NM,
                   'DATA MISMATCH VALUE_DOMAINS',
                   SYSDATE,
                   USER,
                   'CNCPT_ADMIN_ITEM',
                   'ONEDATA_WA'
              FROM ONEDATA_WA.ADMIN_ITEM
             WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;

        COMMIT;
    END LOOP;
    
 --Validate  COMPONENT_CONCEPTS_EXT for ADMIN_ITEM_TYP_ID=1   
    FOR x
            IN (  SELECT DISTINCT ITEM_ID,                          --Primary Keys
                                           VER_NR
                    FROM (Select cncpt_item_id,
                                      cncpt_ver_nr,
                                      cai.item_id,
                                      cai.ver_nr,
                                      cai.nci_ord,
                                      cai.nci_prmry_ind,
                                      nci_cncpt_val,
                                      cai.CREAT_USR_ID,
                                      cai.CREAT_DT,
                                      cai.LST_UPD_DT,
                                      cai.LST_UPD_USR_ID
    from cncpt_admin_item cai, admin_item ai
    where cai.ITEM_ID=ai.ITEM_ID and cai.VER_NR=ai.VER_NR
    and ADMIN_ITEM_TYP_ID=1 
    UNION ALL                                  
    SELECT con.item_id,
                   con.ver_nr,
                   cd.item_id,
                   cd.ver_nr,
                   cc.DISPLAY_ORDER,
                   DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
                   concept_value,
            nvl(cc.created_by,'ONEDATA'),
                   nvl(cc.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(NVL (cc.date_modified, cc.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(cc.modified_by,'ONEDATA')
              FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
                   sbr.conceptual_domains         cde,
                   admin_item                     con,
                   admin_item                     cd
             WHERE     cc.CONDR_IDSEQ = cde.CONDR_IDSEQ
                   AND cde.cd_idseq = cd.nci_idseq
                   AND cc.con_idseq = con.nci_idseq) t
                GROUP BY ITEM_ID,
                         VER_NR,
                         CREAT_DT,
                         CREAT_USR_ID,
                         LST_UPD_USR_ID,
                         LST_UPD_DT,
                         nci_ord
                  HAVING COUNT (*) <> 2
                ORDER BY ITEM_ID, VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'COMPONENT_CONCEPTS_EXT',
                       ITEM_NM,
                       'DATA MISMATCH CONCEPTUAL_DOMAINS',
                       SYSDATE,
                       USER,
                       'CNCPT_ADMIN_ITEM',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.ITEM_ID AND VER_NR = x.VER_NR;
    
            COMMIT;
    END LOOP;
 
--Validate  PERMISSIBLE_VALUES
    FOR x
            IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR
                    FROM (Select PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
    from ONEDATA_WA.PERM_VAL
    UNION ALL                                 
    SELECT pvs.BEGIN_DATE, 
                   pvs.END_DATE,
                   VALUE,
                   SHORT_MEANING,
                   vd.item_id,
                   vd.ver_nr,
                   nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
                   nvl(pvs.created_by,'ONEDATA'),
                   nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
                   nvl(pvs.modified_by,'ONEDATA'),
                   vm.item_id,
                   vm.ver_nr,
                   pv.pv_idseq
              FROM sbr.PERMISSIBLE_VALUES  pv,
                   admin_item              vm,
                   admin_item              vd,
                   sbr.vd_pvs              pvs
             WHERE     pv.pv_idseq = pvs.pv_idseq
                   AND pvs.vd_idseq = vd.nci_idseq
                   AND pv.vm_idseq = vm.nci_idseq) t
                GROUP BY PERM_VAL_BEG_DT,
                              PERM_VAL_END_DT,
                              PERM_VAL_NM,
                              PERM_VAL_DESC_TXT,
                              VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR,
                              CREAT_DT,
                              CREAT_USR_ID,
                              LST_UPD_DT,
                              LST_UPD_USR_ID,
                              NCI_VAL_MEAN_ITEM_ID,
                              NCI_VAL_MEAN_VER_NR,
                              NCI_IDSEQ
                  HAVING COUNT (*) <> 2
                ORDER BY VAL_DOM_ITEM_ID,
                              VAL_DOM_VER_NR)
        LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NCI_IDSEQ,
                       ITEM_ID,
                       VER_NR,
                       'PERMISSIBLE_VALUES',
                       ITEM_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'PERM_VAL',
                       'ONEDATA_WA'
                  FROM ONEDATA_WA.ADMIN_ITEM
                 WHERE ITEM_id = x.VAL_DOM_ITEM_ID AND VER_NR = x.VAL_DOM_VER_NR;
    
            COMMIT;
    END LOOP;
    
--Validate QUEST_VV_EXT  
FOR x
        IN (  SELECT DISTINCT VV_PUB_ID,
                                  VV_VER_NR
                FROM (select DISTINCT VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID
from NCI_QUEST_VV_REP      
UNION ALL                                      
SELECT   DISTINCT vv.NCI_PUB_ID,
               vv.NCI_VER_NR,
               qvv.VALUE,
               DECODE (editable_ind,  'Yes', 1,  'No', 0),
               repeat_sequence,
          nvl(qvv.created_by,'ONEDATA'),
               nvl(qvv.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
             nvl(NVL (qvv.date_modified, qvv.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(qvv.modified_by,'ONEDATA')
          FROM sbrext.QUEST_VV_EXT         qvv,
               NCI_QUEST_VALID_VALUE       vv
         WHERE    qvv.vv_idseq = vv.NCI_IDSEQ(+)) t
            GROUP BY VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID
              HAVING COUNT (*) <> 2
              ORDER BY VV_PUB_ID,
                                  VV_VER_NR)
LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   NCI_IDSEQ,
                   NCI_PUB_ID,
                   NCI_VER_NR,
                   'QUEST_VV_EXT',
                   VM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_QUEST_VV_REP',
                   'ONEDATA_WA'
              FROM ONEDATA_WA.NCI_QUEST_VALID_VALUE 
             WHERE NCI_PUB_ID = x.VV_PUB_ID AND NCI_VER_NR = x.VV_VER_NR;
        COMMIT;
    END LOOP; 
    
  --Validate REFERENCE_BLOBS    
    FOR x
            IN (  SELECT DISTINCT FILE_NM
                    FROM (select FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             BLOB_COL,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
    FROM ref_doc
    UNION ALL                         
            SELECT rb.NAME,
                   MIME_TYPE,
                   DOC_SIZE,
                   DAD_CHARSET,
                   LAST_UPDATED,
                   TO_BLOB(BLOB_CONTENT),
                   NVL (created_by, 'ONEDATA'),
                   NVL (date_created, TO_DATE ('8/18/2020', 'mm/dd/yyyy')),
                   NVL (modified_by, 'ONEDATA'),
                   NVL (NVL (date_modified, date_created),
                        TO_DATE ('8/18/2020', 'mm/dd/yyyy'))
              FROM  sbr.REFERENCE_BLOBS rb) t
                GROUP BY FILE_NM,
                             NCI_MIME_TYPE,
                             NCI_DOC_SIZE,
                             NCI_CHARSET,
                             NCI_DOC_LST_UPD_DT,
                             CREAT_USR_ID,
                             CREAT_DT,
                             LST_UPD_USR_ID,
                             LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY FILE_NM)
    LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       NULL,
                       NULL,
                       NULL,
                       'REFERENCE_BLOBS',
                       x.FILE_NM,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'REF_DOC',
                       'ONEDATA_WA'
                  FROM DUAL;
            COMMIT;
        END LOOP;                                  
           
--Validate TA_PROTO_CSI_EXT           
FOR x
        IN (  SELECT DISTINCT TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR
                FROM (select TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT from NCI_FORM_TA_REL
UNION ALL                                 
        SELECT ta.ta_id,
               ai.item_id,
               ai.ver_nr,
               nvl(t.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
          nvl(t.created_by,'ONEDATA'),
               nvl(t.modified_by,'ONEDATA'),
             nvl(NVL (t.date_modified, t.date_created), to_date('8/18/2020','mm/dd/yyyy'))
          FROM nci_form_ta ta, sbrext.TA_PROTO_CSI_EXT t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL) t
            GROUP BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
              HAVING COUNT (*) <> 2
              ORDER BY TA_ID,NCI_PUB_ID,
                                 NCI_VER_NR)
LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   NCI_idseq,
                   item_id,
                   ver_nr,
                   'TA_PROTO_CSI_EXT',
                   ITEM_NM,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'NCI_FORM_TA_REL',
                   'ONEDATA_WA'
              FROM  nci_form_ta ta, sbrext.ta_proto_csi_ext t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL and ta_ID=x.ta_ID;
        COMMIT;
    END LOOP;        

--Validate  TRIGGERED_ACTIONS_EXT   
    FOR x
            IN (  SELECT DISTINCT TA_IDSEQ
                    FROM (Select 
                                 TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT From NCI_FORM_TA
    UNION ALL                             
     SELECT      TA_INSTRUCTION,
                   S_QTL_NAME,
                   T_QTL_NAME,
                   TA_IDSEQ,
                   nvl(ta.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
              nvl(ta.created_by,'ONEDATA'),
                   nvl(ta.modified_by,'ONEDATA'),
                 nvl(NVL (ta.date_modified, ta.date_created), to_date('8/18/2020','mm/dd/yyyy'))
              FROM sbrext.TRIGGERED_ACTIONS_EXT  ta) t
                GROUP BY TA_INSTR,
                                 SRC_TYP_NM,
                                 TRGT_TYP_NM,
                                 TA_IDSEQ,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT
                  HAVING COUNT (*) <> 2
                  ORDER BY TA_IDSEQ)
    LOOP
            INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
                SELECT SBREXT.ERR_SEQ.NEXTVAL,
                       TA_IDSEQ,
                       ac1.public_id,
                       ac1.version,
                       'TRIGGERED_ACTIONS_EXT',
                       ac1.PREFERRED_NAME,
                       'DATA MISMATCH',
                       SYSDATE,
                       USER,
                       'NCI_FORM_TA',
                       'ONEDATA_WA'
                  from sbrext.triggered_actions_ext,sbr.administered_components ac1, sbr.administered_components ac2
                    where ac1.ac_idseq = S_QC_IDSEQ
                    and ac2.ac_idseq = S_QC_IDSEQ
                    and TA_IDSEQ=x.TA_IDSEQ;
            COMMIT;
        END LOOP;                                  
           
--Validate VD_PVS           
FOR x
        IN (  SELECT DISTINCT VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ
                FROM (select DISTINCT PERM_VAL_BEG_DT, 
                          PERM_VAL_END_DT,
                          VAL_DOM_ITEM_ID,
                          VAL_DOM_VER_NR,
                          CREAT_USR_ID,                          
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ,NCI_ORIGIN from  PERM_VAL 
UNION ALL                          
        SELECT DISTINCT pvs.BEGIN_DATE,
               pvs.END_DATE,
               vd.item_id,
               vd.ver_nr,
               nvl(pvs.created_by,'ONEDATA'),
               nvl(pvs.date_created,to_date('8/18/2020','mm/dd/yyyy')) ,
               nvl(NVL (pvs.date_modified, pvs.date_created), to_date('8/18/2020','mm/dd/yyyy')),
               nvl(pvs.modified_by,'ONEDATA'),
               pv.pv_idseq, pvs.ORIGIN
          FROM sbr.PERMISSIBLE_VALUES  pv,
               admin_item              vd,
               sbr.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq ) t
            GROUP BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,PERM_VAL_BEG_DT, 
                          PERM_VAL_END_DT,
                          CREAT_USR_ID,                          
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_IDSEQ
              HAVING COUNT (*) <> 2
              ORDER BY VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,NCI_IDSEQ)
LOOP
        INSERT INTO SBREXT.ONEDATA_MIGRATION_ERROR
            SELECT SBREXT.ERR_SEQ.NEXTVAL,
                   x.NCI_IDSEQ,
                   x.VAL_DOM_ITEM_ID,
                   x.VAL_DOM_VER_NR,
                   'VD_PVS',
                   NULL,
                   'DATA MISMATCH',
                   SYSDATE,
                   USER,
                   'PERM_VAL',
                   'ONEDATA_WA'
              from dual;
        COMMIT;
    END LOOP;       
    
END;
/
