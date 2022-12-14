truncate table NCI_STG_FORM_IMPORT;
truncate table NCI_STG_FORM_QUEST_IMPORT;
truncate table NCI_STG_FORM_VV_IMPORT;

alter table NCI_STG_FORM_IMPORT
add (BTCH_USR_NM varchar2(100) not null, BTCH_NM varchar2(100) not null, CREATED_FORM_ITEM_ID number);

alter table NCI_STG_FORM_IMPORT
add (LST_UPD_DT_CHAR varchar2(20));


alter table NCI_STG_FORM_QUEST_IMPORT
add (BTCH_SEQ_NBR number not null);

alter table nci_data_audt add audt_desc varchar2(4000);

alter table NCI_STG_FORM_QUEST_IMPORT
add (SRC_REQ_IND varchar2(10));

  CREATE OR REPLACE VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN,
  AI.ADMIN_ITEM_TYP_ID,
  ok.OBJ_KEY_DESC ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID,
UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM, UC.CART_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI , OBJ_KEY ok WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR and ai.admin_item_typ_id = ok.obj_key_id and ok.obj_typ_id = 4
and admin_item_typ_id in (4,52,54,2,3);

-- Tracker 2320
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (36, 'Data Audit Action Type');
commit;
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (37, 'Form Audit Entity Type');
commit;
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (38, 'Data Audit Entity Type');
commit;


  CREATE OR REPLACE VIEW VW_NCI_DATA_AUDT_FORM AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID", ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS"
  from NCI_DATA_AUDT where (((item_id, ver_nr) in (Select item_id, ver_nr from nci_form)) or action_typ ='M');


  CREATE OR REPLACE VIEW VW_NCI_DATA_AUDT AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS" from NCI_DATA_AUDT;


alter table NCI_CNCPT_REL add (REL_CATGRY_NM varchar2(100)  default 'Default' not null);

alter table NCI_CNCPT_REL drop primary key;

alter table NCI_CNCPT_REL add Primary KEY  (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID, REL_CATGRY_NM);

insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (17, 'Subset Relationship', 69, 'Subset Relationship', 
											'Subset Relationship');
commit;

-- Add audt_desc column
  CREATE OR REPLACE  VIEW VW_NCI_DATA_AUDT_FORM AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID", ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS",
  AUDT_DESC
  from NCI_DATA_AUDT where (((item_id, ver_nr) in (Select item_id, ver_nr from nci_form)) or action_typ ='M');


  CREATE OR REPLACE  VIEW VW_NCI_DATA_AUDT AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS",
  AUDT_DESC from NCI_DATA_AUDT;


create table NCI_STG_MEDDRA 
( L1_CD  varchar2(50) not null,
 L1_NM varchar2(255) not null,
 L2_CD  varchar2(50) not null,
 L2_NM varchar2(255) not null,
 L3_CD  varchar2(50) not null,
 L3_NM varchar2(255) not null,
 L4_CD  varchar2(50) not null,
 L4_NM varchar2(255) not null,
 L5_CD  varchar2(50) not null primary key,
 L5_NM varchar2(255) not null ,
"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);
 
 
 
