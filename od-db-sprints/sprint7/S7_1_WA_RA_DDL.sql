alter table NCI_FORM add (HDR_INSTR varchar2(4000) , FTR_INSTR varchar2(4000));

alter table NCI_ADMIN_ITEM_REL add (INSTR varchar2(4000));
 

alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (INSTR varchar2(4000));
alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (DEFLT_VAL_ID number);
alter table NCI_ADMIN_ITEM_REL_ALT_KEY add (QUEST_REF_ID number);
alter table NCI_QUEST_VALID_VALUE add (INSTR  varchar2(4000) );
alter table NCI_QUEST_VV_REP add (DEFLT_VAL_ID number);


create unique index idxQUestVV on nci_quest_valid_value (NCI_PUB_ID)


 CREATE OR REPLACE  VIEW VW_NCI_FORM AS
  select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_long_nm, ai.item_desc, ai.REGSTR_STUS_ID, ai.cntxt_item_id, ai.cntxt_ver_nr,
'FORM' admin_item_typ_nm, f.catgry_id, f.FORM_TYP_ID, ai.admin_stus_id, f.HDR_INSTR, f.FTR_INSTR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no
from admin_item ai, nci_admin_item_rel air, nci_form f where 
ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id = 60 and ai.item_id = f.item_id and ai.ver_nr = f.ver_nr;



  CREATE OR REPLACE  VIEW VW_FORM AS
  select  ai.item_id, ai.ver_nr, ai.item_nm, ai.item_long_nm, ai.item_desc, ai.REGSTR_STUS_ID, ai.cntxt_item_id, ai.cntxt_ver_nr,
'FORM' admin_item_typ_nm, f.catgry_id, f.FORM_TYP_ID, ai.admin_stus_id, f.HDR_INSTR, f.FTR_INSTR, ai.REGSTR_STUS_NM_DN, ai.CNTXT_NM_DN, ai.ADMIN_STUS_NM_DN,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT
from admin_item ai,  nci_form f where 
 ai.item_id = f.item_id and ai.ver_nr = f.ver_nr;



  CREATE OR REPLACE VIEW VW_NCI_FORM_MODULE AS
  select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_long_nm, ai.item_desc,
'MODULE' admin_item_typ_nm,air.INSTR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no
from admin_item ai, nci_admin_item_rel air where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id in (61,62);


 
 CREATE OR REPLACE  VIEW VW_DE AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 DE.DE_CONC_VER_NR, DE.DE_CONC_ITEM_ID, DE.VAL_DOM_VER_NR, DE.VAL_DOM_ITEM_ID, DE.REP_CLS_VER_NR, DE.REP_CLS_ITEM_ID, 
DE.CREAT_USR_ID, DE.LST_UPD_USR_ID, DE.FLD_DELETE, DE.LST_DEL_DT, DE.S2P_TRN_DT, DE.LST_UPD_DT, DE.CREAT_DT,
DE.PREF_QUEST_TXT, VALUE_DOM.NON_ENUM_VAL_DOM_DESC, VALUE_DOM.DTTYPE_ID, VAL_DOM_MAX_CHAR, VAL_DOM_TYP_ID, VALUE_DOM.UOM_ID,
VAL_DOM_MIN_CHAR, VAL_DOM_FMT_ID, CHAR_SET_ID, VAL_DOM_HIGH_VAL_NUM, VAL_DOM_LOW_VAL_NUM, FMT_NM, DTTYPE_NM, UOM_NM
   FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+);
/
ALTER TABLE ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY
ADD (P_NCI_PUB_ID        NUMBER   ,
  P_NCI_VER_NR        NUMBER(4,2));
