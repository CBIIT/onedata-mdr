--alter table CNCPT add (PRNT_ITEM_ID number, PRNT_ITEM_VER_NR number);

--alter table NCI_USR_CART add RETAIN_IND number(1);


insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (17, 'NCIT Concept Relationship', 68, 'NCIT Concept Relationship', 
											'NCIT Concept Relationship');
commit;


update admin_item set Item_desc = replace(item_desc,'alert','axxxt') where upper(item_desc) like '%JAVASCRIPT:ALERT%' and cntxt_nm_dn = 'TEST';
update admin_item set Item_nm = replace(item_desc,'alert','axxxt') where upper(item_nm) like '%JAVASCRIPT:ALERT%' and cntxt_nm_dn = 'TEST';

commit;

  CREATE OR REPLACE VIEW VW_LIST_USR_CART_NM AS
  SELECT distinct CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, 0 RETAIN_IND, 
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART where nvl(fld_delete,0)  =0;
	   
create table NCI_CNCPT_REL
   (	"P_ITEM_VER_NR" NUMBER(4,2) not null, 
	"P_ITEM_ID" NUMBER not null, 
	"C_ITEM_VER_NR" NUMBER(4,2) not null, 
	"C_ITEM_ID" NUMBER not null, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"REL_TYP_ID" INTEGER not null,
	"DISP_ORD" INTEGER,
    primary key( P_ITEM_ID, P_ITEM_VER_NR,C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID));
   

  CREATE OR REPLACE VIEW VW_NCI_DATA_AUDT_FORM AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete','M','Manual Delete') ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS"
  from NCI_DATA_AUDT where (((item_id, ver_nr) in (Select item_id, ver_nr from nci_form)) or action_typ ='M');
  
  
alter table nci_stg_form_quest_import modify SRC_QUESTION_ID varchar2(4000);
alter table nci_stg_form_quest_import modify SRC_QUEST_LBL varchar2(4000);

alter table admin_item add (MTCH_TERM varchar2(255), MTCH_TERM_ADV varchar(255));
alter table ALT_NMS add (MTCH_TERM varchar2(4000), MTCH_TERM_ADV varchar(4000));
alter table REF add (MTCH_TERM varchar2(4000), MTCH_TERM_ADV varchar(4000));




  CREATE OR REPLACE  VIEW VW_DE
  AS SELECT 
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
decode(VALUE_DOM.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated') VAL_DOM_TYP
FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM
WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+);

