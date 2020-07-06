create or replace procedure sp_preprocess
as
v_cnt integer;
begin

update sbr.administered_components set version=2.99 where ac_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.administered_components set version=3.99 where ac_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.administered_components set version=2.99 where ac_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=1.99 where ac_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=99.99 where ac_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;



update sbr.value_domains set version=2.99 where vd_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.value_domains set version=3.99 where vd_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.value_domains set version=2.99 where vd_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.value_domains set version=1.99 where vd_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.value_domains set version=99.99 where vd_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.value_domains set version=3.99 where vd_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.value_domains set version=4.99 where vd_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.value_domains set version=2.99 where vd_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;


update sbr.data_elements set version=2.99 where de_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.data_elements set version=3.99 where de_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.data_elements set version=2.99 where de_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.data_elements set version=1.99 where de_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.data_elements set version=99.99 where de_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.data_elements set version=3.99 where de_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.data_elements set version=4.99 where de_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.data_elements set version=2.99 where de_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;

update sbr.contact_comms set rank_order = 3 where cyber_address = 'Help Desk' and per_idseq = '2D6163C0-33B6-24D0-E044-0003BA3F9857' and rank_order = 1;
commit;

update sbr.ac_contacts set rank_order = 2 where acc_idseq = 'B4C3ADBF-7881-0548-E034-0003BA12F5E7';
commit;


end;

/


create or replace PROCEDURE            sp_create_ai_1
AS
    v_cnt   INTEGER;
BEGIN
    -- Context creation
    DELETE FROM cntxt;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 8;

    COMMIT;

    -- Default version applied to context
    INSERT INTO admin_item (admin_item_typ_id,
                            NCI_iDSEQ,
                            ITEM_DESC,
                            ITEM_NM,
                            ITEM_LONG_NM,
                            VER_NR,
                            CNTXT_NM_DN,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT 8,
               TRIM (conte_idseq),
               description,
               name,
               name,
               version,
               name,
               created_by,
               date_created,
               NVL (date_modified, date_created),
               modified_by
          FROM sbr.contexts;

    COMMIT;

    -- Language is not used in context
    INSERT INTO cntxt (ITEM_ID,
                       VER_NR,
                       LANG_ID,
                       NCI_PRG_AREA_ID,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID)
        SELECT ai.ITEM_ID,
               ai.VER_NR,
               1000,
               ok.OBJ_KEY_ID,
               c.created_by,
               c.date_created,
               NVL (c.date_modified, c.date_created),
               c.modified_by
          FROM sbr.contexts c, admin_item ai, obj_key ok
         WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
               AND TRIM (c.pal_name) = TRIM (ok.NCI_CD)
               AND ok.obj_typ_id = 14
               AND ai.admin_item_typ_id = 8;

    COMMIT;

    -- Conceptual Domain Creation
    DELETE FROM conc_dom;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 1;

    COMMIT;


    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                 --           UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.cd_idseq,
               1,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.cd_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by
          FROM sbr.conceptual_domains  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;

    INSERT INTO conc_dom (item_id,
                          ver_nr,
                          DIMNSNLTY,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.dimensionality,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbr.conceptual_domains cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.CD_IDSEQ;

    COMMIT;

    -- Object class and Property creation. Need to confirm the OC and Property specific attributes
    DELETE FROM obj_cls;

    COMMIT;

    DELETE FROM prop;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (5, 6);

    COMMIT;

    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.oc_idseq,
               5,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.oc_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM admin_item cntxt, stus_mstr s, sbrext.object_classes_ext ac
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.prop_idseq,
               6,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt_ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.prop_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM admin_item cntxt, stus_mstr s, sbrext.properties_ext ac
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO obj_cls (item_id,
                         ver_nr,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.object_classes_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.OC_IDSEQ;

    COMMIT;


    INSERT INTO prop (item_id,
                      ver_nr,
                      CREAT_USR_ID,
                      CREAT_DT,
                      LST_UPD_DT,
                      LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.properties_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.PROP_IDSEQ;

    COMMIT;

    -- Default OC and Property for DECs that do not have OC or Property
    INSERT INTO admin_item (item_id,
                            ver_nr,
                            nci_idseq,
                            admin_item_typ_id,
                            ITEM_LONG_NM,
                            ITEM_DESC,
                            ITEM_NM)
         VALUES (-20000,
                 1,
                 '1',
                 5,
                 'Default Object Class',
                 'Default Object Class',
                 'Default Object Class');

    COMMIT;

    INSERT INTO admin_item (item_id,
                            ver_nr,
                            nci_idseq,
                            admin_item_typ_id,
                            ITEM_LONG_NM,
                            ITEM_DESC,
                            ITEM_NM)
         VALUES (-20001,
                 1,
                 '2',
                 6,
                 'Default Property',
                 'Default Property',
                 'Default Property');

    COMMIT;

    INSERT INTO obj_cls (item_id, ver_nr)
         VALUES (-20000, 1);

    INSERT INTO prop (item_id, ver_nr)
         VALUES (-20001, 1);

    COMMIT;

    -- Classification Scheme and Representation Class creation
    DELETE FROM CLSFCTN_SCHM;

    COMMIT;

    DELETE FROM REP_CLS;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (7, 9);

    COMMIT;

    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                   --         UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.cs_idseq,
              9,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.cs_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by
          FROM sbr.classification_schemes  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;

    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            --UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.rep_idseq,
               7,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.rep_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM sbrext.representations_ext  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;
               
    COMMIT;

    INSERT INTO clsfctn_schm (item_id,
                              ver_nr,
                              CLSFCTN_SCHM_TYP_ID,
                              NCI_LABEL_TYP_FLG,
                              CREAT_USR_ID,
                              CREAT_DT,
                              LST_UPD_DT,
                              LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               label_type_flag,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbr.classification_schemes cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.CS_IDSEQ
               AND TRIM (cstl_name) = ok.nci_cd
               AND ok.obj_typ_id = 3;

    COMMIT;



    INSERT INTO rep_cls (item_id,
                         ver_nr,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.representations_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.REP_IDSEQ;

    COMMIT;


    INSERT INTO admin_item (item_id,
                            ver_nr,
                            admin_item_typ_id,
                            item_nm,
                            ITEM_LONG_NM,
                            ITEM_DESC)
         VALUES (-20002,
                 1,
                 5,
                 'Default CD',
                 'Default CD',
                 'Default CD');

    COMMIT;

    INSERT INTO conc_dom (item_id, ver_nr)
         VALUES (-20002, 1);

    COMMIT;
END;

/

create or replace PROCEDURE            sp_create_ai_4
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_oc_recs;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 56;

    COMMIT;

    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                 --           UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.ocr_idseq,
               56,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.ocr_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by
          FROM sbrext.oc_recs_ext ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is not null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO NCI_OC_RECS (ITEM_ID,
                             VER_NR,
                             TRGT_OBJ_CLS_ITEM_ID,
                             TRGT_OBJ_CLS_VER_NR,
                             SRC_OBJ_CLS_ITEM_ID,
                             SRC_OBJ_CLS_VER_NR,
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
                             ARRAY_IND)
        SELECT ocr.ocr_id,
               ocr.version,
               toc.item_id,
               toc.ver_nr,
               soc.item_id,
               soc.ver_nr,
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
          FROM sbrext.oc_recs_ext ocr, admin_item soc, admin_item toc
         WHERE     soc.admin_item_typ_id = 5
               AND toc.admin_item_typ_id = 5
               AND ocr.t_oc_idseq = toc.nci_idseq
               AND ocr.s_oc_idseq = soc.nci_idseq;

    COMMIT;
END;

/

create or replace procedure sp_migrate_lov 
as
v_cnt integer;
begin
delete from stus_mstr;
commit;

v_cnt := 1;

for cur in (select registration_status,description,
                    comments,created_by, date_created,
                    nvl(date_modified, date_created) date_modified, modified_by,
                    display_order from sbr.reg_status_lov order by display_order) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.registration_status, cur.registration_status, cur.description, cur.comments, cur.created_by, cur.date_created,
cur.date_modified, cur.modified_by, cur.display_order, 1);
v_cnt := v_cnt + 1;

end loop;

v_cnt := 50;

for cur in (select asl_name,description,
                    comments,created_by, date_created,
                    nvl(date_modified, date_created) date_modified, modified_by,
                    display_order from sbr.ac_status_lov order by asl_name) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.asl_name, cur.asl_name, cur.description, cur.comments, cur.created_by, cur.date_created,
cur.date_modified, cur.modified_by, cur.display_order, 2);
v_cnt := v_cnt + 1;
end loop;
commit;



delete from obj_key where obj_typ_id = 14;  -- Program Area
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 14, pal_name, description, pal_name, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.PROGRAM_AREAS_LOV;
commit;


delete from obj_key where obj_typ_id = 11;  -- Name/designation
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 11, detl_name, description, detl_name, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.DESIGNATION_TYPES_LOV;
commit;

-- DOcument type
delete from obj_key where obj_typ_id = 1;  -- 
commit;

-- Preferred Question Text ID needs to be static. Used in views.
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, NCI_CD) values (80,1,'Preferred Question Text', 'Preferred Question Text','Preferred Question Text');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 1, DCTL_NAME, description, DCTL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.document_TYPES_LOV where DCTL_NAME not like 'Preferred Question Text';
commit;


-- Classification Scheme Type
delete from obj_key where obj_typ_id = 3;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 3, CSTL_NAME, description, CSTL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.CS_TYPES_LOV;
commit;

-- Classification Scheme Item Type
delete from obj_key where obj_typ_id = 20;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 20, CSITL_NAME, description, CSITL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.CSI_TYPES_LOV;
commit;

-- Protocol Type
delete from obj_key where obj_typ_id = 19;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd) 
select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null ;
commit;



-- Concept Source
delete from obj_key where obj_typ_id = 23;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select  23, CONCEPT_SOURCE,DESCRIPTION, CONCEPT_SOURCE, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.concept_sources_lov_ext ;
commit;



-- NCI Derivation Type
delete from obj_key where obj_typ_id = 21;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 21, CRTL_NAME,CRTL_NAME, DESCRIPTION , created_by, date_created,
                    nvl(date_modified,date_created), modified_by  from sbr.complex_rep_type_lov ;
commit;



--- Data type

delete from data_typ;
commit;
insert into data_typ ( DTTYPE_NM, NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DTTYPE_SCHM_REF, DTTYPE_ANNTTN)
select DTL_NAME, DTL_NAME, DESCRIPTION,COMMENTS,
created_by, date_created,nvl(date_modified, date_created), modified_by,
SCHEME_REFERENCE, ANNOTATION from sbr.datatypes_lov;
commit;

-- Format
delete from FMT;
commit;
insert into FMT ( FMT_NM, NCI_CD,FMT_DESC,FMT_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select FORML_NAME, FORML_NAME,DESCRIPTION,COMMENTS,
created_by, date_created,nvl(date_modified,date_created), modified_by from sbr.formats_lov;
commit;

-- UOM
delete from UOM;
commit;
insert into UOM ( UOM_NM,NCI_CD, UOM_PREC,UOM_DESC,UOM_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select UOML_NAME,UOML_NAME,PRECISION,
DESCRIPTION,COMMENTS,
created_by, date_created,nvl(date_modified,date_created), modified_by from sbr.unit_of_measures_lov;
commit;




-- Definition type
delete from obj_key where obj_typ_id = 15;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 15, DEFL_NAME, description, DEFL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.definition_types_lov_ext;


commit;





-- Origin
delete from obj_key where obj_typ_id = 18;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 18, SRC_NAME, description, SRC_NAME,  created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.sources_ext;


commit;

-- Form Category
delete from obj_key where obj_typ_id = 22;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 22, QCDL_NAME, description, QCDL_NAME,  created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.QC_DISPLAY_LOV_EXT;


commit;


-- GEt standard data types from Excel spreadsheet

update data_typ set nci_dttype_typ_id = 1;
commit;
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ALPHANUMERIC';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'anyClass';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'binary';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'BOOLEAN';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CHARACTER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CLOB';
update data_typ set NCI_DTTYPE_MAP = 'Date' where DTTYPE_NM = 'DATE';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Date Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'DATE/TIME';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'DATETIME';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'Derived';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'HL7CDv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7EDv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'HL7INTv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7PNv3';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'HL7REALv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7STv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7TELv3';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'HL7TSv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'Integer';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADPartv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCNTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPDALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPSTAv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPZIPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ANYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090BAGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'ISO21090BLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090CDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090DSETv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDTEXTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENONv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENPNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENTNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTNTNEGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTPOSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IVLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090PQTIMEv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090PQv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090QTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090REALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090RTOv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STSIMv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELURLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDATFLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDTTIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090TSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090Tv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090URGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'java.lang.Boolean';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Byte';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Character';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'java.lang.Double';
update data_typ set NCI_DTTYPE_MAP = 'Floating-point' where DTTYPE_NM = 'java.lang.Float';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer[]';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Long';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'java.lang.Object';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Short';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String[]';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.sql.Timestamp';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Collection';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.util.Date';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Map';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'NUMBER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Numeric Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'OBJECT';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Date';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Time';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'TIME';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'UMLBinaryv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLCodev1.0';
update data_typ set NCI_DTTYPE_MAP = 'Octet' where DTTYPE_NM = 'UMLOctetv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUidv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUriv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLXMLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'varchar';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'xsd:boolean';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'xsd:dateTime';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'xsd:string';
commit;

update data_typ set NCI_DTTYPE_MAP = 'Character' where NCI_DTTYPE_MAP is null;
commit;

-- insert standard datatypes
insert into data_typ(dttype_nm, nci_dttype_typ_id)
select distinct NCI_DTTYPE_MAP, 2 from data_typ where NCI_DTTYPE_MAP is not null;
commit;



delete from lang;
commit;

INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1007, 'ICELANDIC', 'Icelandic'); 
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1000, 'ENGLISH', 'English'); 
commit;
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1004, 'SPANISH', 'Spanish'); 
commit;
commit;



delete from obj_key where obj_typ_id = 25;  -- Address Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 25, ATL_NAME, description, ATL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.ADDR_TYPES_LOV	;
commit;

delete from obj_key where obj_typ_id = 26;  -- Communication Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 26, CTL_NAME, description, CTL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.COMM_TYPES_LOV;
	
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, obj_key_id, e.DATE_CREATED,e.CREATED_BY,e.DATE_MODIFIED,e.MODIFIED_BY
from sbrext.ASL_ACTL_EXT e, stus_mstr s, obj_key o
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and o.nci_cd = e.ACTL_NAME and o.obj_typ_id = 4;
commit;


insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 53, e.DATE_CREATED,e.CREATED_BY,e.DATE_MODIFIED,e.MODIFIED_BY
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'VALUE_MEANING';
commit;

--Form
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 54, e.DATE_CREATED,e.CREATED_BY,e.DATE_MODIFIED,e.MODIFIED_BY
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';
commit;

--Module
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 52, e.DATE_CREATED,e.CREATED_BY,e.DATE_MODIFIED,e.MODIFIED_BY
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';
commit;

end;
/
create or replace procedure sp_org_contact
as
v_cnt integer;
begin
update admin_item set (REGSTR_STUS_ID, REGSTR_STUS_NM_DN) = 
(select s.stus_id, s.NCI_STUS
from sbr.ac_registrations ar, stus_mstr s where 
upper(ar.REGISTRATION_STATUS) = upper(s.stus_nm) and ar.ac_idseq = admin_item.nci_idseq
and ar.registration_status is not null);
commit;

--update admin_item set REGSTR_STUS_ID = 10, REGSTR_STUS_NM_DN = 'Historical' where REGSTR_STUS_ID is null; 
--commit;

update admin_item set (ORIGIN_ID, ORIGIN_ID_DN) = 
(Select obj_key_id, obj_key_desc from obj_key ok, sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and ac.origin = ok.obj_key_desc and ok.obj_typ_id = 18);
commit;

update admin_item set (ORIGIN) = 
(Select origin from sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and origin not in (select obj_key_desc from obj_key where obj_typ_id = 18));
commit;

insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY, CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, a.used_by, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai where an.cntxt_item_id = ai.item_id ) 
GROUP BY item_id, ver_nr) a,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+);
commit;


update perm_val set (PRNT_CNCPT_ITEM_ID, PRNT_CNCPT_VER_NR) = (
select 
public_id, version from sbr.administered_components ac, sbr.vd_pvs pvs, admin_item vd where pvs.pv_idseq = perm_val.nci_idseq and ac.ac_idseq = pvs.con_idseq and 
pvs.con_idseq is not null and vd.nci_idseq = pvs.vd_idseq and vd.item_id = perm_val.val_dom_item_id and vd.ver_nr = perm_val.val_dom_ver_nr)
where nci_idseq in (select pv_idseq from sbr.vd_pvs where con_idseq is not null);
commit;


insert into nci_entty(NCI_IDSEQ, ENTTY_TYP_ID,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select org_idseq, 72,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
 from sbr.organizations;
commit;

insert into nci_org (ENTTY_ID, RAI,ORG_NM,RA_IND,MAIL_ADDR,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
select e.ENTTY_ID, RAI,NAME,RA_IND,MAIL_ADDRESS,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
from sbr.organizations o, nci_entty e where e.nci_idseq = o.org_idseq;
commit;

insert into nci_entty(NCI_IDSEQ, ENTTY_TYP_ID,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select per_idseq, 73,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
 from sbr.persons;
commit;


insert into nci_prsn(ENTTY_ID,LAST_NM,FIRST_NM,RNK_ORD,PRNT_ORG_ID,MI,POS,
 CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select e.entty_id, LNAME,FNAME,RANK_ORDER,o.entty_id,MI,POSITION
,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED,date_created)
 from sbr.persons p, nci_entty e, nci_entty o where e.entty_typ_id = 73 and o.entty_typ_id (+)= 72 and e.nci_idseq = p.per_idseq and p.org_idseq = o.nci_idseq (+)  ;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED, date_created),MODIFIED_BY
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED, date_created),MODIFIED_BY
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
per_IDSEQ is not null and c.per_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26 ;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED,date_created), MODIFIED_BY
from sbr.CONTACT_ADDRESSES c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = ATL_NAME and ok.obj_typ_id = 25;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED,date_created), MODIFIED_BY
from sbr.CONTACT_ADDRESSES c, obj_key ok, nci_entty o where
PER_IDSEQ is not null and c.per_idseq = o.nci_idseq and ok.nci_cd = ATL_NAME and ok.obj_typ_id = 25;
commit;

update admin_item ai set submt_org_id = (select distinct entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.org_idseq and a.org_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 1)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where org_idseq is not null and rank_order = 1);
commit;


update admin_item ai set stewrd_org_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.org_idseq and a.org_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 2)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where org_idseq is not null and rank_order = 2);
commit;

update admin_item ai set submt_cntct_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.per_idseq and a.per_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 2)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where per_idseq is not null and rank_order = 2);
commit;


update admin_item ai set stewrd_cntct_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.per_idseq and a.per_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 1)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where per_idseq is not null and rank_order = 1);
commit;

insert into ref_doc (NCI_REF_ID,FILE_NM,NCI_MIME_TYPE,NCI_DOC_SIZE,
NCI_CHARSET,NCI_DOC_LST_UPD_DT,BLOB_COL,
CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
select r.ref_id, rb.NAME,MIME_TYPE,DOC_SIZE,
DAD_CHARSET,LAST_UPDATED,BLOB_CONTENT,
CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
from ref r, sbr.reference_blobs rb where r.nci_idseq = rb.rd_idseq;
commit;


end;
/

create or replace procedure spNCIShowVMDependency (v_data_in in clob, v_data_out out clob)
as

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;
row_cur t_row;

v_admin_item                admin_item%rowtype;
v_tab_admin_item            tab_admin_item_pk;

v_found      boolean;

type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();
--v_tab_val_mean_id  tab_admin_item_pk ;

v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

type      t_admin_item_nm is table of admin_item.item_nm%type;
v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

v_val_mean_desc    val_mean.val_mean_desc%type;
v_perm_val_nm    perm_val.perm_val_nm%type;
v_item_id		 number;
v_ver_nr		 number;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;


    -- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
    for i in 1 .. hookInput.originalRowset.Rowset.count loop

    row_cur := hookInput.originalRowset.Rowset(i);

  for rec in (
  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext
        where val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
  and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and pv.fld_delete=0 and 
     pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop

         v_found := false;
      for j in 1..v_tab_val_mean_cd.count loop
       v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
         end loop;

   if not v_found then
       v_tab_val_mean_cd.extend();
       v_tab_val_mean_nm.extend();
                          --v_tab_val_mean_cd(v_tab_val_mean_cd.count) :=           obj_admin_item_pk(rec.nci_val_mean_item_id, rec.nci_val_mean_ver_nr);
    v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
    v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
    --v_tab_val_mean_id(v_tab_val_mean_id.count).ver_nr := rec.nci_val_mean_ver_nr;
   end if;

  END LOOP;
     v_tab_admin_item_nm.extend();
     v_tab_admin_item_nm(v_tab_admin_item_nm.count) := ihook.getColumnValue(row_cur,'ITEM_ID') || ':' || ihook.getColumnValue(row_cur,'ITEM_NM');
end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        ihook.setColumnValue(row, 'Concept Code', v_tab_val_mean_cd(i));
        ihook.setColumnValue(row, 'Concept Name', v_tab_val_mean_nm(i));

    for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);

      v_perm_val_nm := '';
   for rec in
   (select perm_val_nm
   from perm_val a, nci_admin_item_Ext ext
         where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
   and val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
  and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and a.fld_delete=0) loop

                v_perm_val_nm := rec.perm_val_nm;

            end loop;
       ihook.setColumnValue(row, v_tab_admin_item_nm(j), v_perm_val_nm);
   --   raise_application_error(-20000, v_tab_admin_item_nm(j));
        end loop;

        rows.extend; rows(rows.last) := row;

 end loop;

    showRowset := t_showableRowset(rows, 'Value Meaning Dependency',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'The following Value Meaning dependencies found:';

    v_data_out := ihook.getHookOutput(hookOutput);

end;
/

create or replace procedure spNCIShowVMDependencyDE (v_data_in in clob, v_data_out out clob)
as

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;
row_cur t_row;

v_admin_item                admin_item%rowtype;
v_tab_admin_item            tab_admin_item_pk;

v_found      boolean;

type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();
--v_tab_val_mean_id  tab_admin_item_pk ;

v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

type      t_admin_item_nm is table of admin_item.item_nm%type;
v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

v_val_mean_desc    val_mean.val_mean_desc%type;
v_perm_val_nm    perm_val.perm_val_nm%type;
v_item_id		 number;
v_ver_nr		 number;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;


    -- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
    for i in 1 .. hookInput.originalRowset.Rowset.count loop

    row_cur := hookInput.originalRowset.Rowset(i);

  for rec in (
  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext, de
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
  and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and 
     pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop

         v_found := false;
      for j in 1..v_tab_val_mean_cd.count loop
       v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
         end loop;

   if not v_found then
       v_tab_val_mean_cd.extend();
       v_tab_val_mean_nm.extend();
                          --v_tab_val_mean_cd(v_tab_val_mean_cd.count) :=           obj_admin_item_pk(rec.nci_val_mean_item_id, rec.nci_val_mean_ver_nr);
    v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
    v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
    --v_tab_val_mean_id(v_tab_val_mean_id.count).ver_nr := rec.nci_val_mean_ver_nr;
   end if;

  END LOOP;
     v_tab_admin_item_nm.extend();
     v_tab_admin_item_nm(v_tab_admin_item_nm.count) := ihook.getColumnValue(row_cur,'ITEM_ID') || ':' || ihook.getColumnValue(row_cur,'ITEM_NM');
end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        ihook.setColumnValue(row, 'Concept Code', v_tab_val_mean_cd(i));
        ihook.setColumnValue(row, 'Concept Name', v_tab_val_mean_nm(i));

    for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);

      v_perm_val_nm := '';
   for rec in
   (select perm_val_nm
   from perm_val a, nci_admin_item_Ext ext, de
         where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
   and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
  and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop

                v_perm_val_nm := rec.perm_val_nm;

            end loop;
       ihook.setColumnValue(row, v_tab_admin_item_nm(j), v_perm_val_nm);

        end loop;

        rows.extend; rows(rows.last) := row;

 end loop;

    showRowset := t_showableRowset(rows, 'Value Meaning Dependency',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'The following Value Meaning dependencies found:';

    v_data_out := ihook.getHookOutput(hookOutput);

end;
/

create or replace procedure sp_postprocess
as
v_cnt integer;
begin

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY, CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, a.used_by, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai where an.cntxt_item_id = ai.item_id ) 
GROUP BY item_id, ver_nr) a,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+);
commit;


insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;

commit;
end;

/


create or replace procedure            sp_migrate_change_log
as
v_cnt integer;
begin

for cur in (select ac_idseq from sbr.administered_components) loop
insert into nci_change_history (ACCH_IDSEQ,
AC_IDSEQ,CHANGE_DATETIMESTAMP,CHANGE_ACTION,CHANGED_BY,
CHANGED_TABLE,CHANGED_TABLE_IDSEQ,CHANGED_COLUMN,OLD_VALUE,NEW_VALUE)
select ACCH_IDSEQ,
AC_IDSEQ,CHANGE_DATETIMESTAMP,CHANGE_ACTION,CHANGED_BY,
CHANGED_TABLE,CHANGED_TABLE_IDSEQ,CHANGED_COLUMN,OLD_VALUE,NEW_VALUE
from sbrext.AC_CHANGE_HISTORY_EXT
where ac_idseq = cur.ac_idseq;
commit;
end loop;
end;
/

create or replace procedure sp_test_all 
as
v_cnt integer;
begin

delete from test_results;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'DE', 
(select count(*)-1 from onedata_wa.de) WA_CNT,
(select count(*)-1 from onedata_ra.de) RA_CNT,
(select count(*) from sbr.data_elements) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'DE Concept', 
(select count(*)-1 from onedata_wa.de_conc) WA_CNT,
(select count(*)-1 from onedata_ra.de_conc) RA_CNT,
(select count(*) from sbr.data_element_concepts) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Format', 
(select count(*) from onedata_wa.fmt) WA_CNT,
(select count(*) from onedata_ra.fmt) RA_CNT,
(select count(*) from sbr.formats_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Data type', 
(select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.data_typ where nci_dttype_typ_id = 1) RA_CNT,
(select count(*) from sbr.datatypes_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Registration Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.stus_mstr where stus_typ_id = 1) RA_CNT,
(select count(*) from sbr.reg_status_lov) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Workflow Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2) WA_CNT,
(select count(*) from onedata_ra.stus_mstr where stus_typ_id = 2) RA_CNT,
(select count(*) from sbr.ac_status_lov) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'UOM', 
(select count(*) from onedata_wa.UOM) WA_CNT,
(select count(*) from onedata_ra.UOM) RA_CNT,
(select count(*) from sbr.unit_of_measures_lov) caDSR_CNT
from dual;
commit;




insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'VV Repetition', 
(select count(*) from onedata_wa.NCI_QUEST_VV_REP) WA_CNT,
(select count(*) from onedata_ra.NCI_QUEST_VV_REP) RA_CNT,
(select count(*) from sbrext.quest_vv_ext ) caDSR_CNT
from dual;
commit;





insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Conceptual Domain', 
(select count(*)-1 from onedata_wa.conc_dom) WA_CNT,
(select count(*)-1 from onedata_ra.conc_dom) RA_CNT,
(select count(*) from sbr.conceptual_domains) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Object Class', 
(select count(*)-1 from onedata_wa.obj_cls) WA_CNT,
(select count(*)-1 from onedata_ra.obj_cls) RA_CNT,
(select count(*) from sbrext.object_classes_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Property', 
(select count(*)-1 from onedata_wa.prop) WA_CNT,
(select count(*)-1 from onedata_ra.prop) RA_CNT,
(select count(*) from sbrext.properties_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Value Domain', 
(select count(*)-1 from onedata_wa.value_dom) WA_CNT,
(select count(*)-1 from onedata_ra.value_dom) RA_CNT,
(select count(*) from sbr.value_domains) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Concept', 
(select count(*) from onedata_wa.CNCPT) WA_CNT,
(select count(*) from onedata_ra.CNCPT) RA_CNT,
(select count(*) from sbrext.concepts_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM) WA_CNT,
(select count(*) from onedata_ra.NCI_CLSFCTN_SCHM_ITEM) RA_CNT,
(select count(*) from sbr.cs_items) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Classification Scheme', 
(select count(*) from onedata_wa.CLSFCTN_SCHM) WA_CNT,
(select count(*) from onedata_ra.CLSFCTN_SCHM) RA_CNT,
(select count(*) from sbr.classification_schemes) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Representation Class', 
(select count(*) from onedata_wa.REP_CLS) WA_CNT,
(select count(*) from onedata_ra.REP_CLS) RA_CNT,
(select count(*) from SBREXT.representations_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Value Meaning', 
(select count(*) from onedata_wa.NCI_VAL_MEAN) WA_CNT,
(select count(*) from onedata_ra.NCI_VAL_MEAN) RA_CNT,
(select count(*) from SBR.value_meanings) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Protocol', 
(select count(*) from onedata_wa.NCI_PROTCL) WA_CNT,
(select count(*) from onedata_ra.NCI_PROTCL) RA_CNT,
(select count(*) from sbrext.protocols_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'OC Recs', 
(select count(*) from onedata_wa.NCI_OC_RECS) WA_CNT,
(select count(*) from onedata_ra.NCI_OC_RECS) RA_CNT,
(select count(*) from SBREXT.oc_recs_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Context', 
(select count(*) from onedata_wa.CNTXT) WA_CNT,
(select count(*) from onedata_ra.CNTXT) RA_CNT,
(select count(*) from sbr.contexts) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean) WA_CNT,
(select count(*) from onedata_ra.conc_dom_val_mean) RA_CNT,
(select count(*) from sbr.cd_vms) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'PV', 
(select count(*) from onedata_wa.PERM_VAL) WA_CNT,
(select count(*) from onedata_ra.PERM_VAL) RA_CNT,
(select count(*) from sbr.vd_pvs) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Concept - AI', 
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM) WA_CNT,
(select count(*) from onedata_ra.CNCPT_ADMIN_ITEM) RA_CNT,
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Designations', 
(select count(*) from onedata_wa.ALT_NMS) WA_CNT,
(select count(*) from onedata_ra.ALT_NMS) RA_CNT,
(select count(*) from sbr.designations) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Definitions', 
(select count(*) from onedata_wa.ALT_DEF) WA_CNT,
(select count(*) from onedata_ra.ALT_DEF) RA_CNT,
(select count(*) from sbr.definitions) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Reference Documents', 
(select count(*) from onedata_wa.REF) WA_CNT,
(select count(*) from onedata_ra.REF) RA_CNT,
(select count(*) from SBR.reference_documents) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Trigger Actions', 
(select count(*) from onedata_wa.NCI_FORM_TA) WA_CNT,
(select count(*) from onedata_ra.NCI_FORM_TA) RA_CNT,
(select count(*) from sbrext.triggered_actions_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_wa.NCI_FORM_TA_REL) WA_CNT,
(select count(*) from onedata_ra.NCI_FORM_TA_REL) RA_CNT,
(select count(*) from sbrext.ta_proto_csi_ext) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Organization', 
(select count(*) from onedata_wa.NCI_ORG) WA_CNT,
(select count(*) from onedata_ra.NCI_ORG) RA_CNT,
(select count(*) from sbr.ORGANIZATIONS) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Person', 
(select count(*) from onedata_wa.NCI_PRSN) WA_CNT,
(select count(*) from onedata_ra.NCI_PRSN) RA_CNT,
(select count(*) from sbr.persons) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Addresses', 
(select count(*) from onedata_wa.NCI_ENTTY_ADDR) WA_CNT,
(select count(*) from onedata_ra.NCI_ENTTY_ADDR) RA_CNT,
(select count(*) from sbr.contact_addresses) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Communications', 
(select count(*) from onedata_wa.NCI_ENTTY_COMM) WA_CNT,
(select count(*) from onedata_ra.NCI_ENTTY_COMM) RA_CNT,
(select count(*) from sbr.contact_comms) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Form', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54) WA_CNT,
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 54) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE')) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Module', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52) WA_CNT,
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 52) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE') caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Question', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63) WA_CNT,
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION') caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Question VV', 
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE ) WA_CNT,
(select count(*) from onedata_ra.NCI_QUEST_VALID_VALUE ) RA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE') caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CS CSI', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 64) WA_CNT,
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 64 ) RA_CNT,
(select count(*) from sbr.cs_csi) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CS CSI DE Relationship', 
(select count(*) from onedata_wa.NCI_ALT_KEY_ADMIN_ITEM_REL) WA_CNT,
(select count(*) from onedata_ra.NCI_ALT_KEY_ADMIN_ITEM_REL ) RA_CNT,
(select count(*) from sbr.ac_csi) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Program Area', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 14 ) RA_CNT,
(select count(*) from sbr.PROGRAM_AREAS_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Designation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 11 ) RA_CNT,
(select count(*) from sbr.DESIGNATION_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Address Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 25 ) RA_CNT,
(select count(*) from sbr.ADDR_TYPES_LOV) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Communication Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 26 ) RA_CNT,
(select count(*) from sbr.COMM_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Status-Admin Type Relationship', 
(select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS ) WA_CNT,
(select count(*) from onedata_ra.NCI_AI_TYP_VALID_STUS  ) RA_CNT,
(select count(*) from sbrext.ASL_ACTL_EXT) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Derivation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 21 ) RA_CNT,
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Document Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 1 ) RA_CNT,
(select count(*) from sbr.document_TYPES_LOV) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Classification Scheme Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 3 ) RA_CNT,
(select count(*) from sbr.CS_TYPES_LOV) caDSR_CNT
from dual;
commit;


insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'CSI Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 20 ) RA_CNT,
(select count(*) from sbr.CSI_TYPES_LOV ) caDSR_CNT
from dual;
commit;

insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Definition Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 15 ) RA_CNT,
(select count(*) from sbrext.definition_types_lov_ext) caDSR_CNT
from dual;
commit;



insert into test_results (TABLE_NAME, WA_CNT, RA_CNT, caDSR_CNT)
select 'Origin', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18) WA_CNT,
(select count(*) from onedata_ra.OBJ_KEY where obj_typ_id = 18 ) RA_CNT,
(select count(*) from sbrext.sources_ext) caDSR_CNT
from dual;
commit;


end;
/
