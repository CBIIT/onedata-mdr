
  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT_SHRT AS
  select   map.MDL_MAP_ITEM_ID ,
    map.mdl_map_ver_nr ,
    map.MEC_MAP_NM,
    map.sort_ord,
    tme.ITEM_PHY_OBJ_NM ||  '.'  || tmec."MEC_PHY_NM"  TGT_MEC_PHY_NM,
    tme.ITEM_PHY_OBJ_NM  TGT_ME_PHY_NM,
  --   tmec.MEC_PHY_NM  TGT_MEC_PHY_NM,
    sme.ITEM_PHY_OBJ_NM  SRC_ME_PHY_NM,
    -- smec.MEC_PHY_NM  SRC_MEC_PHY_NM,
    sme.ITEM_PHY_OBJ_NM ||  '.'  || smec."MEC_PHY_NM"  SRC_MEC_PHY_NM,
    --    tmecd."MEC_PHY_NM",
  --       tmecd.MEC_LONG_NM,
  decode(tvd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') TGT_VAL_DOM_TYP,
  decode(svd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') SRC_VAL_DOM_TYP,
  tmec.cde_item_id tgt_cde_item_id,
  tmec.cde_ver_nr tgt_cde_ver_nr,
   smec.cde_item_id src_cde_item_id,
  smec.cde_ver_nr src_cde_ver_nr,
  MEC_MAP_NOTES,
  TRNS_DESC_TXT,
      TRANS_RUL_NOT,
  map.PCODE_SYSGEN,
	  VALID_PLTFORM,
  PROV_ORG_ID,
  PROV_CNTCT_ID,
  PROV_RSN_TXT,
  PROV_TYP_RVW_TXT,
  PROV_RVW_DT,
  PROV_APRV_DT,
  cmnts_desc_txt,
    sysdate creat_dt,
  'ONEDATA' creat_usr_id,  
   sysdate lst_upd_dt,
  'ONEDATA' lst_upd_usr_id,
     map.creat_dt creat_dt_x,
   map.creat_usr_id creat_usr_id_x,  
   map.lst_upd_dt lst_upd_dt_x,
   map.lst_upd_usr_id lst_upd_usr_id_x,
     0 FLD_DELETE,
     sysdate S2P_TRN_DT,
     sysdate LST_DEL_DT
from
    nci_MEC_MAP map,
  NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, VALUE_DOM tvd,VALUE_DOM svd,
      NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec
where   tmec.MDL_ELMNT_ITEM_ID = tme.item_id (+) 
and tmec.MDL_ELMNT_VER_NR =tme.ver_nr (+)   
and map.TGT_MEC_ID = tmec.mec_id (+)
    and  smec.MDL_ELMNT_ITEM_ID = sme.item_id  (+)
and smec.MDL_ELMNT_VER_NR= sme.ver_nr  (+)
and map.SRC_MEC_ID = smec.mec_id (+)
  --and map.map_deg in (86,87,120)
  and tmec.VAL_DOM_ITEM_ID = tvd.ITEM_ID (+)
and tmec.VAL_DOM_VER_NR = tvd.VER_NR (+)
 and smec.VAL_DOM_ITEM_ID = svd.ITEM_ID (+)
and smec.VAL_DOM_VER_NR = svd.VER_NR (+);

-- To check if needs to be executed.

delete from nci_mec_map where src_mec_id in (select mec_id from nci_mdl_elmnt_Char where upper(mec_long_nm) like '%DELETED%')
and map_deg in (129,130,131);

delete from nci_mec_map where tgt_mec_id in (select mec_id from nci_mdl_elmnt_Char where upper(mec_long_nm) like '%DELETED%')
and map_deg in (129,130,131);

commit;


  CREATE OR REPLACE  VIEW VW_ADMIN_ITEM_VER_CREATED AS
  SELECT "ITEM_ID","VER_NR","ITEM_DESC","CNTXT_ITEM_ID","CNTXT_VER_NR","ITEM_LONG_NM","ITEM_NM","ADMIN_NOTES","CHNG_DESC_TXT","CREATION_DT","EFF_DT","ORIGIN","UNRSLVD_ISSUE","UNTL_DT","CLSFCTN_SCHM_VER_NR","ADMIN_ITEM_TYP_ID",
  "CURRNT_VER_IND","ADMIN_STUS_ID","REGSTR_STUS_ID","REGISTRR_CNTCT_ID","SUBMT_CNTCT_ID","STEWRD_CNTCT_ID","SUBMT_ORG_ID","STEWRD_ORG_ID",
  "CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","REGSTR_AUTH_ID",
  "ADMIN_STUS_NM_DN","CNTXT_NM_DN","REGSTR_STUS_NM_DN","ORIGIN_ID","ORIGIN_ID_DN","DEF_SRC",
  "CREAT_USR_ID_X","LST_UPD_USR_ID_X","ITEM_NM_CURATED","ITEM_NM_ID_VER","RVWR_CMNTS","LST_UPD_DT_X"
       FROM ADMIN_ITEM
       where (item_id) in (Select item_id from admin_item where admin_item_typ_id in (2,3,4,54,57,58)
       group by item_id having count(*) > 1)
       and admin_item_typ_id in (2,3,4,54,57,58)
       and ver_nr <> 1;

