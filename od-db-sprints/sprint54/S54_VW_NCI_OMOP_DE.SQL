CREATE OR REPLACE FORCE EDITIONABLE VIEW "ONEDATA_WA"."VW_NCI_OMOP_DE" ("ITEM_ID", "VER_NR", "ITEM_ID_STR", "ITEM_NM", "ITEM_LONG_NM", "ITEM_DESC", "ADMIN_NOTES", "CHNG_DESC_TXT", "CREATION_DT", "EFF_DT", "ORIGIN", "ORIGIN_ID", "ORIGIN_ID_DN", "UNRSLVD_ISSUE", "UNTL_DT", "CURRNT_VER_IND", "REGSTR_STUS_ID", "ADMIN_STUS_ID", "CNTXT_NM_DN", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "CREAT_USR_ID", "CREAT_USR_ID_X", "LST_UPD_USR_ID", "LST_UPD_USR_ID_X", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "CREAT_DT", "NCI_IDSEQ", "ADMIN_ITEM_TYP_ID", "ITEM_DEEP_LINK", "CNTXT_AGG", "VAL_DOM_TYP_ID", "OMOP_TABLE", "OMOP_NAME", "CSI_LIST") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT distinct ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
          CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
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
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	     ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
             vd.VAL_DOM_TYP_ID	 ,
	     an.OMOP_TABLE, an.OMOP_NAME,
	     csi.csi_list
	     FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	      de, VALUE_DOM vd, MVW_CSI_NODE_DE_REL r,
	     (SELECT an.item_id, an.ver_nr, LISTAGG(decode(obj_key_desc, 'OMOP Table', nm_desc,''), ', ') WITHIN GROUP (ORDER by nm_desc) as OMOP_TABLE,
 LISTAGG(decode(obj_key_desc, 'OMOP Name', nm_desc,''), ', ') WITHIN GROUP (ORDER by nm_desc) as OMOP_NAME
	      from alt_nms an, obj_key ok where an.nm_typ_id = ok.obj_key_id and ok.obj_key_desc in ('OMOP Table', 'OMOP Name')
          group by an.item_id, an.ver_nr) an,
	     (SELECT r.c_item_id, r.c_item_ver_nr, LISTAGG(csi.item_nm ,', ') WITHIN GROUP (ORDER by item_nm) as CSI_LIST
	      from nci_admin_item_rel r, vw_clsfctn_schm_item csi where r.p_item_id = csi.item_id and r.p_item_ver_nr = csi.ver_nr 
	      and csi.cs_item_id = 14522466 and csi.cs_item_ver_nr = 1.00
          group by r.c_item_id, r.c_item_ver_nr) csi
        WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
	   and admin_item.item_id = r.item_id and admin_item.ver_nr = r.ver_nr and r.p_item_id = 14522466 and r.p_item_ver_nr = 1.00
	   and admin_item.item_id = an.item_id (+)
	   and admin_item.ver_nr = an.ver_nr (+)
	   and admin_item.item_id = csi.c_item_id (+)
	   and admin_item.ver_nr = csi.c_item_ver_nr (+);
