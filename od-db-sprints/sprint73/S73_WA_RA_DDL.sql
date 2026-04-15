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

alter table nci_ds_hdr modify (ENTTY_NM varchar2(4000), ENTTY_NM_USR varchar2(4000));

alter table  nci_ds_prmtr modify (ENTTY_NM varchar2(4000), ENTTY_NM_USR varchar2(4000));

insert into obj_typ (obj_typ_id, obj_typ_desc) values (65, 'AI Model Variant - CDE');
insert into obj_typ (obj_typ_id , obj_typ_desc) values (66, 'AI Model Variant - PV');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-mpnet-base-v2-FT', 252);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-MiniLM-L6-v2-FT',253);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'SapBERT-FT',254);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'PubMedBERT-FT',255);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-mpnet-base-v2',256);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-MiniLM-L6-v2',257);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'SapBERT',258);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'LongName-sapBERT',259);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'LongName-MiniLM-L6-v2',260);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'Definition-MiniLM-L6-v2',262);

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-MiniLM-L6-v2',263);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-Expanded-MiniLM-L6-v2',264);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-sapBERT',265);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-Expanded-sapBERT',266);
--insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, '(None: CDE_Only)',267);
commit;

alter table nci_ds_prmtr add VARIANT_1_NM varchar2(255);
alter table nci_ds_prmtr add VARIANT_2_NM varchar2(255);


