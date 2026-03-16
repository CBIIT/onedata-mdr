alter table nci_ds_rslt add (src_mtch_engn varchar2(100) default 'CDE Match')


alter table  NCI_DS_PRMTR add (THRESHOLD_1 int, THRESHOLD_2 int, VARIANT_1 int, VARIANT_2 int)

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (64, 'CDE Model Variant (CDE AI Matching)');
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (65, 'PV/VM Model Variant (CDE AI Matching)');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (250,64,'CDE Long Name', 'CDE Long Name');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (251,64,'CDE Alternate Name', 'CDE Alternate Name');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (252,64,'CDE Question Text', 'CDE Question Text');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (253,64,'CDE Definition', 'CDE Definition');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (254,65,'PV Code', 'PV Code');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (255,65,'Value Meaning Long Name', 'Value Meaning Long Name');
commit;
