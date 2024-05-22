drop materialized view VW_VAL_DOM_REF_TERM;

  CREATE MATERIALIZED VIEW VW_VAL_DOM_REF_TERM
  AS select
vd.item_id, vd.ver_nr, vd.term_cncpt_item_id, vd.term_cncpt_ver_nr, nvl(a.nm_desc, c.item_nm) || '/' || o.obj_key_desc  term_use_name, nvl(a.nm_desc, c.item_nm)  term_name,obj_key_desc use_name from
value_dom vd, vw_cncpt c, obj_key o, (select item_id, ver_nr, nm_desc from alt_nms a, obj_key where obj_typ_id = 11 and obj_key_desc = 'Ref Term Short Name' and a.nm_typ_id = obj_key_id) a
where  vd.val_dom_typ_id = 16 and vd.term_cncpt_item_id = c.item_id and vd.term_cncpt_ver_nr = c.ver_nr and vd.TERM_USE_TYP= o.obj_key_id and
vd.term_cncpt_item_id = a.item_id (+) and vd.term_cncpt_ver_nr = a.ver_nr (+);


  CREATE OR REPLACE  VIEW VW_VALUE_DOM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN,  ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
		      ADMIN_ITEM.CURRNT_VER_IND, VALUE_DOM.DTTYPE_ID, VALUE_DOM.VAL_DOM_MAX_CHAR, VALUE_DOM.CONC_DOM_VER_NR, VALUE_DOM.CONC_DOM_ITEM_ID, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.UOM_ID, VALUE_DOM.VAL_DOM_TYP_ID, VALUE_DOM.VAL_DOM_MIN_CHAR, VALUE_DOM.VAL_DOM_FMT_ID, 
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , RC.ITEM_NM  REP_TERM_ITEM_NM,
	  value_dom.NCI_STD_DTTYPE_ID, term.term_name, term.use_name, term.term_use_name
FROM ADMIN_ITEM, VALUE_DOM, VW_REP_CLS RC, vw_val_dom_ref_term term
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 3
AND ADMIN_ITEM.ITEM_ID = VALUE_DOM.ITEM_ID
AND ADMIN_ITEM.VER_NR=VALUE_DOM.VER_NR and
VALUE_DOM.REP_CLS_ITEM_ID = RC.ITEM_ID (+) and 
VALUE_DOM.REP_CLS_VER_NR = RC.VER_NR (+)
and
VALUE_DOM.ITEM_ID = TERM.ITEM_ID (+) and 
VALUE_DOM.VER_NR = TERM.VER_NR (+);


  GRANT SELECT ON "ONEDATA_WA"."VW_VALUE_DOM" TO "ONEDATA_RO";
  GRANT READ ON "ONEDATA_WA"."VW_VALUE_DOM" TO "ONEDATA_RO";
