
  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT   AS 
  select   map.MDL_MAP_ITEM_ID ,
         map.mdl_map_ver_nr ,
         map.MEC_MAP_NM,
          tmed.ITEM_PHY_OBJ_NM ||  '.'  || tmecd."MEC_PHY_NM"  MEC_PHY_NM,
        --    tmecd."MEC_PHY_NM",
	   --       tmecd.MEC_LONG_NM,
	          tmed.	ITEM_LONG_NM || '.' ||        tmecd.MEC_LONG_NM MEC_LONG_NM,
	  decode(vd.val_dom_typ_id, 16, 'Enumerated by Reference', 17, 'Enumerated', 18, 'Non-enumerated', '') VAL_DOM_TYP,
            map.PCODE_SYSGEN,
	  MEC_MAP_NOTES,
	  TRNS_DESC_TXT,
	  map.PROV_ORG_ID,
	  map.PROV_CNTCT_ID,
	  map.PROV_RSN_TXT,
	  	map.PROV_TYP_RVW_TXT,
	  map.PROV_RVW_DT,
	  map.PROV_APRV_DT,
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
      sysdate LST_DEL_DT,
      decode(map.TRANS_RUL_NOT, 122, 'Text', 124, 'SQL', 123, 'Pseudocode') TRNS_RUL_NOT,
SORT_ORD
	from
     nci_MEC_MAP map,
	  NCI_MDL_ELMNT tmed,NCI_MDL_ELMNT_CHAR tmecd, VALUE_DOM vd
	where  	 tmed.item_id = tmecd.MDL_ELMNT_ITEM_ID
	and tmed.ver_nr = tmecd.MDL_ELMNT_VER_NR  
	  and tmecd.mec_id = map.TGT_MEC_ID_DERV
      and map.map_deg in (86,87,120,129,130)
and tmecd.VAL_DOM_ITEM_ID = vd.ITEM_ID (+)
	  and tmecd.VAL_DOM_VER_NR = vd.VER_NR (+)
      and (pcode_sysgen is not null or mec_map_notes is not null);



