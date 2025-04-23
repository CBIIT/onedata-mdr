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
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
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
