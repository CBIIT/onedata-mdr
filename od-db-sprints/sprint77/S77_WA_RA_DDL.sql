
  CREATE OR REPLACE  VIEW VW_VALUE_DOM_TYPE_ONLY AS
  SELECT VALUE_DOM.ITEM_ID, VALUE_DOM.VER_NR,
VALUE_DOM.CHAR_SET_ID, VALUE_DOM.CREAT_DT, VALUE_DOM.CREAT_USR_ID, VALUE_DOM.LST_UPD_USR_ID, 
VALUE_DOM.FLD_DELETE, VALUE_DOM.LST_DEL_DT, VALUE_DOM.S2P_TRN_DT, VALUE_DOM.LST_UPD_DT , 
	 DECODE(value_dom.val_dom_typ_id, 17, 'Enumerated', 18, 'Non-enumerated', 16, 'Enumerated by Reference') VAL_DOM_TYPE
FROM VALUE_DOM;

alter table ref add mtch_scr number(10,5);

alter table alt_nms add mtch_scr number(10,5);

     
