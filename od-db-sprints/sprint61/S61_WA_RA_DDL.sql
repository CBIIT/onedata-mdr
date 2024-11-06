alter table sag_load_mt add (syn_match number(1));

alter table sag_load_mt add (item_id number, ver_nr number(4,2));

alter table nci_mec_map add (SRC_CDE_ITEM_ID number, SRC_CDE_VER_NR number(4,2), TGT_CDE_ITEM_ID number, TGT_CDE_VER_NR number(4,2));


  CREATE OR REPLACE  VIEW VW_NCI_MEC_NO_CDE AS
  select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, 
    mec."MEC_ID",mec."MDL_ELMNT_ITEM_ID",mec."MDL_ELMNT_VER_NR",mec."MEC_TYP_ID",mec."CREAT_DT",
mec."CREAT_USR_ID",mec."LST_UPD_USR_ID",mec."FLD_DELETE", mec.char_ord, mec.pk_ind,
	  mec."LST_DEL_DT",mec."S2P_TRN_DT",mec."LST_UPD_DT",mec."SRC_DTTYPE",mec."STD_DTTYPE_ID",mec."SRC_MAX_CHAR",mec."SRC_MIN_CHAR",
mec."SRC_UOM",mec."UOM_ID",mec."SRC_DEFLT_VAL",mec."SRC_ENUM_SRC",mec."DE_CONC_ITEM_ID",mec."DE_CONC_VER_NR",
mec."VAL_DOM_ITEM_ID",mec."VAL_DOM_VER_NR",mec."NUM_PV",
    mec."MEC_LONG_NM",
    mec."MEC_PHY_NM",
    upper(me.ITEM_PHY_OBJ_NM || '.' || mec."MEC_PHY_NM") me_mec_phy_nm, 
    mec."MEC_DESC",mec."CDE_ITEM_ID",mec."CDE_VER_NR"
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57;


  CREATE OR REPLACE  VIEW VW_DE AS
  SELECT 
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, 
ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, 
ADMIN_ITEM.REGSTR_STUS_NM_DN, 
ADMIN_ITEM.ADMIN_STUS_NM_DN,
ADMIN_ITEM.REGSTR_STUS_ID, 
ADMIN_ITEM.ADMIN_STUS_ID,
ADMIN_ITEM.MTCH_TERM,
ADMIN_ITEM.MTCH_TERM_ADV,
 DE.DE_CONC_VER_NR, 
 DE.DE_CONC_ITEM_ID, 
 DE.VAL_DOM_VER_NR, 
 DE.VAL_DOM_ITEM_ID, 
 DE.REP_CLS_VER_NR, 
 DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, 
DE.LST_UPD_USR_ID, 
DE.FLD_DELETE, 
DE.LST_DEL_DT, 
DE.S2P_TRN_DT, 
DE.LST_UPD_DT, 
DE.CREAT_DT,
DE.PREF_QUEST_TXT, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
VALUE_DOM.DTTYPE_ID, 
VAL_DOM_MAX_CHAR, 
VAL_DOM_TYP_ID, 
VALUE_DOM.UOM_ID,
VAL_DOM_MIN_CHAR, 
VAL_DOM_FMT_ID, 
CHAR_SET_ID, 
VAL_DOM_HIGH_VAL_NUM, 
VAL_DOM_LOW_VAL_NUM, 
FMT_NM, 
DTTYPE_NM, 
UOM_NM,
decode(VALUE_DOM.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated', 16, 'Enumerated by Reference') VAL_DOM_TYP
value_dom.TERM_CNCPT_ITEM_ID,
value_dom.TERM_CNCPT_VER_NR,
term.term_use_name TERM_CNCPT_DESC
FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM, vw_val_dom_ref_term term
WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+)
and value_dom.ITEM_ID = term.item_id (+)
and value_dom.ver_nr = term.ver_nr (+);

  GRANT SELECT ON "ONEDATA_WA"."VW_DE" TO "ONEDATA_RO";
  GRANT READ ON "ONEDATA_WA"."VW_DE" TO "ONEDATA_RO";

