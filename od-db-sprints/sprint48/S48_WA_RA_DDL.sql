alter table NCI_STG_MDL_ELMNT add ME_TYP_ID integer;

alter table NCI_MEC_MAP add (SRC_MDL_ITEM_ID number, SRC_MDL_VER_NR number(4,2),TGT_MDL_ITEM_ID number, TGT_MDL_VER_NR number(4,2));

alter table nci_mec_map disable all triggers;

update nci_mec_map set (src_mdl_item_id, src_mdl_ver_nr) = (select mdl_item_id, mdl_item_ver_nr from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where mec.mdl_elmnt_item_id = me.item_id and
mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = nci_mec_map.src_mec_id);
commit;

update nci_mec_map set (tgt_mdl_item_id, tgt_mdl_ver_nr) = (select mdl_item_id, mdl_item_ver_nr from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where mec.mdl_elmnt_item_id = me.item_id and
mec.mdl_elmnt_ver_nr = me.ver_nr and mec.mec_id = nci_mec_map.tgt_mec_id);
commit;

alter table nci_mec_map enable all triggers;

insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (57,65);  -- draft mod for Model
commit;

insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (58,65);  -- draft mod for Model Map
commit;

insert into obj_key ( OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (84, 'Subset Created From',8,'Subset Created From','Subset Created From','Subset Created From' );
commit;


insert into obj_key (obj_key_id, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (85,'YAML',40,'YAML','YAML','YAML' );
commit;

/* Item_mapping name Free text or derive from Source and Target models 
mappingDegree: Drop down: Semantically equivalent, Semantics similar, Has Derivation
description:  free text 
transformationRule: free text
transformationRuleNotation: Drop down: Text, Pseudo Code, SQL, R?, SAS?
directionality:  Drop down: Directional, Bi-Directional, 1..*, *..1? 
validatedPlatform: free text */

alter table NCI_MEC_MAP add ( MEC_MAP_NM varchar2(4000), MAP_DEG  integer, MEC_MAP_DESC varchar2(4000), DIRECT_TYP integer, TRANS_RUL_NOT integer, VALID_PLTFORM  varchar2(4000), PROV_ORG_ID number);
alter table NCI_MEC_MAP add (MEC_GRP_RUL_NBR integer, MEC_GRP_RUL_DESC varchar2(4000));
alter table NCI_MEC_MAP add (SRC_VAL varchar2(4000), TGT_VAL varchar2(4000));



	
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (45,'Model Map Degree');
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (46,'Model Map Directionality');

insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (86,'Semantic Equivalent',45,'Semantic Equivalent','Semantic Equivalent','Semantic Equivalent' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (87,'Semantic Similar',45,'Semantic Similar','Semantic Similar','Semantic Similar' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (116,'Directional',46,'Directional','Directional','Directional' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (117,'Bi-Directional',46,'Bi-Directional','Bi-Directional','Bi-Directional' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (118,'1..*',46,'1..*','1..*','1..*' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (119,'*..1',46,'*..1','*..1','*..1' );
commit;


alter table NCI_STG_MDL_ELMNT add (DOM_ITEM_ID  number, DOM_VER_NR number(4,2));


