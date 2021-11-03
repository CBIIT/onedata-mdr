alter table ADMIN_ITEM add (ITEM_NM_CURATED varchar2(255));


  CREATE OR REPLACE  VIEW VW_VAL_MEAN AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, 
decode(ext.cncpt_concat, ext.cncpt_concat_nm, null, admin_item.item_long_nm, null, admin_item.item_id, null, ext.cncpt_concat)  cncpt_concat,
ext.cncpt_concat_nm, nvl(admin_item.origin_id_dn, origin) ORIGIN_NM, ok.nm_desc ALT_NM
FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT ext, (select item_id, ver_nr, NM_DESC from ALT_NMS a, OBJ_KEY o where a.nm_typ_id = o.obj_key_id and o.obj_typ_id = 11 and o.obj_key_desc = 'Biomarker Synonym') ok
       WHERE ADMIN_ITEM_TYP_ID = 53 and admin_item.item_id = ext.item_id and admin_item.ver_nr = ext.ver_nr
       and admin_item.item_id = ok.item_id (+) and admin_item.ver_nr = ok.ver_nr (+);
