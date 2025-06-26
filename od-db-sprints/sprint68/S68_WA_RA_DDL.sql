
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

