truncate table NCI_STG_FORM_IMPORT;
truncate table NCI_STG_FORM_QUEST_IMPORT;
truncate table NCI_STG_FORM_VV_IMPORT;

alter table NCI_STG_FORM_IMPORT
add (BTCH_USR_NM varchar2(100) not null, BTCH_NM varchar2(100) not null, CREATED_FORM_ITEM_ID number);

alter table NCI_STG_FORM_IMPORT
add (LST_UPD_DT_CHAR varchar2(20));


alter table NCI_STG_FORM_QUEST_IMPORT
add (BTCH_SEQ_NBR number not null);


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


insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('I',36,'Insert','Insert','I' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('U',36,'Update','Update','U' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('D',36,'Delete','Delete','D' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('M',36,'Manual Delete','Manual Delete','M' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('R',36,'Restore','Restore','R' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('P',36,'Purge','Purge','P' );
commit;

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form-Protocol',37,'Form-Protocol','Form-Protocol','Form-Protocol' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Classifications',37,'Classifications','Classifications','Classifications' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Definitions',37,'Alternate Definitions','Alternate Definitions','Alternate Definitions' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form Question',37,'Form Question','Form Question','Form Question' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form-Module',37,'Form-Module','Form-Module','Form-Module' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form Question Valid Values',37,'Form Question Valid Values',
                                                                                           'Form Question Valid Values','Form Question Valid Values' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Administered Item',37,'Administered Item','Administered Item','Administered Item' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Designations',37,'Alternate Designations',
                                                                                           'Alternate Designations','Alternate Designations' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Reference Documents',37,'Reference Documents',
                                                                                           'Reference Documents','Reference Documents' );

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Classifications',38,'Classifications','Classifications','Classifications' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Definitions',38,'Alternate Definitions','Alternate Definitions','Alternate Definitions' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Administered Item',38,'Administered Item','Administered Item','Administered Item' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Designations',38,'Alternate Designations',
                                                                                           'Alternate Designations','Alternate Designations' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Reference Documents',38,'Reference Documents',
                                                                                           'Reference Documents','Reference Documents' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Concept Relationship',38,'Concept Relationship',
                                                                                           'Concept Relationship','Concept Relationship' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Permissible Value',38,'Permissible Value',
                                                                                           'Permissible Value','Permissible Value' );


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



