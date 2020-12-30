PROCEDURE            sp_create_csi
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM admin_item
          WHERE admin_item_typ_id = 51;

    COMMIT;

    DELETE FROM nci_clsfctn_schm_item;

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
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.csi_idseq,
               51,
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
               ac.csi_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
      nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
            FROM sbr.cs_items ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is not null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;

/*
    INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID,
                                       CS_ITEM_ID, CS_VER_NR, P_CSI_ITEM_ID, P_CSI_VER_NR)
        SELECT cd.CSI_id,
               cd.version,
               ok.obj_key_id,
               description,
               comments,
      nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr),
               cs.ITEM_ID, CS.VER_NR, pcsi.ITEM_ID, pcsi.VER_NR
          FROM sbr.cs_items cd, obj_key ok, sbr.cs_csi cscsi, vw_CLSFCTN_SCHM cs, vw_clsfctn_schm_item pcsi
         WHERE     TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20 and 
               cd.csi_idseq = cscsi.csi_idseq and 
               cscsi.cs_idseq = cs.nci_idseq and 
               cscsi.p_cs_csi_idseq = pcsi.nci_idseq (+);

    COMMIT;
*/

 INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               description,
               comments,
       nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created, v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
          FROM sbr.cs_items cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
               AND TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20;

    COMMIT;

    -- cs_csi - give it an alternate key.
    DELETE FROM nci_admin_item_rel_alt_key
          WHERE rel_typ_id = 64;

    COMMIT;

/*
    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            P_ITEM_ID,
                                            P_ITEM_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               pcsi.item_id,
               pcsi.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
            FROM admin_item  cs,
               admin_item  pcsi,
               admin_item  ccsi,
               sbr.cs_csi  cscsi,
               sbr.cs_csi  pcscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NOT NULL
               AND pcscsi.cs_csi_idseq = cscsi.p_cs_csi_idseq
               AND pcscsi.csi_idseq = pcsi.nci_idseq
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;


---- New version

    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
          FROM admin_item cs, admin_item ccsi, sbr.cs_csi cscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NULL
               AND cscsi.csi_idseq = ccsi.nci_idseq;


---- New

    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
            FROM admin_item  cs,
               admin_item  ccsi,
               sbr.cs_csi  cscsi         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NOT NULL
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;

 update nci_admin_item_rel_alt_key k set (P_ITEM_ID, P_ITEM_VER_NR)
 = (select nci_pub_id, 1 from nci_admin_item_rel_alt_key a, sbr.cs_csi cscsi where k.nci_idseq = cscsi.cs_csi_idseq and cscsi.p_cs_csi_idseq = a.nci_idseq
 and cscsi.p_cs_csi_idseq is not null
 )
 where rel_typ_id = 64;*/
 --last version 12/10/2020
 INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
          FROM admin_item cs, admin_item ccsi, sbr.cs_csi cscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NULL
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;
  INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            P_ITEM_ID,
                                            P_ITEM_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               pcsi.item_id,
               pcsi.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
            FROM admin_item  cs,
               admin_item  pcsi,
               admin_item  ccsi,
               sbr.cs_csi  cscsi,
               sbr.cs_csi  pcscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NOT NULL
               AND pcscsi.cs_csi_idseq = cscsi.p_cs_csi_idseq
               AND pcscsi.csi_idseq = pcsi.nci_idseq
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;


    
     update nci_admin_item_rel_alt_key k set (P_NCI_PUB_ID, P_NCI_VER_NR)
 = (select nci_pub_id, NCI_VER_NR from nci_admin_item_rel_alt_key a, sbr.cs_csi cscsi where k.nci_idseq = cscsi.cs_csi_idseq and cscsi.p_cs_csi_idseq = a.nci_idseq
 and cscsi.p_cs_csi_idseq is not null
 )
 where rel_typ_id = 64;
 commit;
END;
