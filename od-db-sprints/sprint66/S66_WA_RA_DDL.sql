alter table nci_mec_map add (MEC_SUB_GRP_NBR_DUP number(6,2));
alter table nci_mec_map disable all triggers;
update nci_mec_map set MEC_SUB_GRP_NBR_DUP= MEC_SUB_GRP_NBR;
commit;
alter table nci_mec_map enable all triggers;
alter table nci_mec_Map drop column  MEC_SUB_GRP_NBR;
alter table nci_mec_map rename column mec_sub_grp_nbr_dup to MEC_SUB_GRP_NBR;

alter table nci_stg_mec_map add (MEC_SUB_GRP_NBR_DUP number(6,2));
alter table nci_stg_mec_map disable all triggers;
update nci_stg_mec_map set MEC_SUB_GRP_NBR_DUP= MEC_SUB_GRP_NBR;
commit;
alter table nci_stg_mec_map enable all triggers;
alter table nci_stg_mec_Map drop column  MEC_SUB_GRP_NBR;
alter table nci_stg_mec_map rename column mec_sub_grp_nbr_dup to MEC_SUB_GRP_NBR;


  CREATE OR REPLACE  VIEW VW_VALUE_DOM_CM
    AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND,  VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID,  VALUE_DOM.VAL_DOM_MIN_CHAR,
 VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.subset_desc, fmt.fmt_nm , uom.uom_nm, sdt.DTTYPE_NM STD_DTTYPE, ldt.DTTYPE_NM LGY_DTTYPE,
	   term.term_name, term.use_name, term.term_use_name, DECODE(value_dom.val_dom_typ_id, 17, 'Enumerated', 18, 'Non-enumerated', 16, 'Enumerated by Reference') VAL_DOM_TYP_NM
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC, vw_val_dom_ref_term term,
    fmt fmt , uom uom, data_typ sdt, data_typ ldt
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+) and
    value_dom.uom_id = uom.uom_id (+) and
    value_dom.val_dom_fmt_id = fmt.fmt_id (+) and
    value_dom.NCI_STD_DTTYPE_ID = sdt.dttype_id and
    value_dom.DTTYPE_ID = ldt.dttype_id (+) and 
 VALUE_DOM.ITEM_ID = TERM.ITEM_ID (+) and 
VALUE_DOM.VER_NR = TERM.VER_NR (+);


  CREATE OR REPLACE VIEW VW_MDL_IMP_TEMPLATE AS
  SELECT ' '                DO_NOT_USE,
       ' '                  BATCH_USER,
       ' '                  BATCH_NAME,
       ROWNUM               SEQ_ID,
       ai.item_nm           MDL_NM, 
       ai.item_id           MDL_ID, 
       ai.ver_nr            MDL_VER_NR, 
       me.item_long_nm      ME_LONG_NM, 
       me.item_phy_obj_nm   ME_PHY_NM, 
       me.item_desc         ME_DESC, 
       me_typ.obj_key_desc ME_TYP_DESC,   
       mec.mec_long_nm      MEC_LONG_NM, 
       mec.MEC_PHY_NM       MEC_PHY_NM, 
       mec.CHAR_ORD         MEC_CHAR_ORD, 
       mec.                 MEC_DESC, 
       mec_typ.obj_key_Desc MEC_TYP_DESC,  
       mec.src_min_char     MEC_MIN_CHAR, 
       mec.src_max_char     MEC_MAX_CHAR, 
       dt.dttype_nm         MEC_DT_TYP_DESC, 
       uom.uom_nm           UOM_DESC,  
       mec_req.obj_key_Desc          MEC_MNDTRY,  
       decode(mec.pk_ind,1,'Yes','No')           MEC_PK_IND,    
       mec.src_deflt_val    MEC_DEFLT_VAL, 
       mec.cde_item_id      CDE_ID, 
       mec.cde_ver_nr       CDE_vERSION, 
       decode(mec.FK_IND,1,'Yes','No')           MEC_FK_IND, 
       mec.                 FK_ELMNT_PHY_NM, 
       mec.                 FK_ELMNT_CHAR_PHY_NM, 
       ' '                  COMMENTS            
FROM admin_item            ai,
     nci_mdl               mdl,
     nci_mdl_elmnt         me,
     nci_mdl_elmnt_char    mec,
     obj_key               mec_typ,
     obj_key               me_typ,
     obj_key               mec_req,
     data_typ              dt,
     uom                   uom,
     value_dom             vdst 
WHERE ai.item_id                  = mdl.item_id
  AND ai.ver_nr                   = mdl.ver_nr
  AND ai.admin_item_typ_id        = 57
  AND mdl.item_id                 = me.mdl_item_id
  AND mdl.ver_nr                  = me.mdl_item_ver_nr
  AND me.item_id                  = mec.mdl_elmnt_item_id
  AND me.ver_nr                   = mec.mdl_elmnt_ver_nr
  AND mec.val_dom_item_id         = vdst.item_id (+)
  AND mec.val_dom_ver_nr          = vdst.ver_nr (+)
  AND mec.mdl_elmnt_char_typ_id   = mec_typ.obj_key_id (+)
  AND mec.req_ind  = mec_req.obj_key_id (+)
  AND me.ME_TYP_ID  = me_typ.obj_key_id (+)
  AND vdst.nci_std_dttype_id      = dt.dttype_id (+)
  AND vdst.uom_id                 = uom.uom_id (+);


  CREATE OR REPLACE  VIEW VW_MDL_MAP_RSLT_SHRT AS
  select   map.MDL_MAP_ITEM_ID ,
    map.mdl_map_ver_nr ,
    map.MEC_MAP_NM,
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



