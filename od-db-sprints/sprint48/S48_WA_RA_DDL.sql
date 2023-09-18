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
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (47,'Model Map Cardinality');
        insert into obj_typ (obj_typ_id, obj_typ_desc) values (48,'Model Map Transformation Notation');

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
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (120,'Has Derivation',45,'Has Derivation','Has Derivation','Has Derivation' );
commit;

delete from obj_key where obj_key_id in (118, 119,121);
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (118,'One-To-Many',47,'One-To-Many','One-To-Many','One-To-Many' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (119,'Many-To-One',47,'Many-To-One','Many-To-One','Many-To-One' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (121,'One-To-One',47,'One-To-One','One-To-One','One-To-One' );
commit;
-- Transformation Notation
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (122,'Text',48,'Text','Text','Text' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (123,'Pseudo Code',48,'Pseudo Code','Pseudo Code','Pseudo Code' );
commit;
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (124,'SQL',48,'SQL','SQL','SQL' );
commit;

alter table NCI_STG_MDL_ELMNT add (DOM_ITEM_ID  number, DOM_VER_NR number(4,2));



  CREATE OR REPLACE  VIEW VW_NCI_MEC_MAP_FOR_VIEW as
  select s.item_id MDL_ITEM_ID, s.ver_nr MDL_VER_NR, 'Source' LVL_TYP, s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm src_mdl_item_nm, sme.item_id SRC_ME_ITEM_ID, 
  sme.ver_nr SRC_me_VER_NR,
	sme.ITEM_LONG_NM SRC_me_item_nm, sme.ITEM_PHY_OBJ_NM SRC_me_phy_nm, smec."MEC_ID" SRC_MEC_ID, 
	  smec."MEC_TYP_ID" SRC_MEC_TYP_ID,map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  smec."DE_CONC_ITEM_ID" SRC_DE_CONC_ITEM_ID,smec."DE_CONC_VER_NR" SRC_DE_CONC_VER_NR,smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" SRC_MEC_LONG_NM ,smec."MEC_PHY_NM" SRC_MEC_PHY_NM, smec."CDE_ITEM_ID" SRC_CDE_ITEM_ID,smec."CDE_VER_NR" SRC_CDE_VER_NR,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm, 
	tme.ITEM_LONG_NM tgt_me_item_nm, tme.ITEM_PHY_OBJ_NM tgt_me_phy_nm, tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  tmec."DE_CONC_ITEM_ID" tgt_DE_CONC_ITEM_ID,tmec."DE_CONC_VER_NR" tgt_DE_CONC_VER_NR,tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" tgt_MEC_LONG_NM ,tmec."MEC_PHY_NM" tgt_MEC_PHY_NM, tmec."CDE_ITEM_ID" tgt_CDE_ITEM_ID,tmec."CDE_VER_NR" tgt_CDE_VER_NR 
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID
union
  select t.item_id MDL_ITEM_ID, t.ver_nr MDL_VER_NR, 'Target' LVL_TYP, s.item_id src_mdl_item_id, s.ver_nr src_mdl_ver_nr, s.item_nm src_mdl_item_nm, sme.item_id SRC_ME_ITEM_ID, 
  sme.ver_nr SRC_me_VER_NR,
	sme.ITEM_LONG_NM SRC_me_item_nm, sme.ITEM_PHY_OBJ_NM SRC_me_phy_nm, smec."MEC_ID" SRC_MEC_ID, 
	  smec."MEC_TYP_ID" SRC_MEC_TYP_ID,map."CREAT_DT",map."CREAT_USR_ID",map."LST_UPD_USR_ID",map."FLD_DELETE",map."LST_DEL_DT",map."S2P_TRN_DT",map."LST_UPD_DT",
	  smec."DE_CONC_ITEM_ID" SRC_DE_CONC_ITEM_ID,smec."DE_CONC_VER_NR" SRC_DE_CONC_VER_NR,smec."VAL_DOM_ITEM_ID" SRC_VAL_DOM_ITEM_ID,smec."VAL_DOM_VER_NR" SRC_VAL_DOM_VER_NR,
	  smec."MEC_LONG_NM" SRC_MEC_LONG_NM ,smec."MEC_PHY_NM" SRC_MEC_PHY_NM, smec."CDE_ITEM_ID" SRC_CDE_ITEM_ID,smec."CDE_VER_NR" SRC_CDE_VER_NR,
	 t.item_id tgt_mdl_item_id, t.ver_nr tgt_mdl_ver_nr, t.item_nm tgt_mdl_item_nm, 
	tme.ITEM_LONG_NM tgt_me_item_nm, tme.ITEM_PHY_OBJ_NM tgt_me_phy_nm, tmec."MEC_ID" tgt_MEC_ID, tmec."MDL_ELMNT_ITEM_ID" tgt_ME_ITEM_ID,tmec."MDL_ELMNT_VER_NR" tgt_ME_VER_NR,
	tmec."MEC_TYP_ID" tgt_MEC_TYP_ID,  tmec."DE_CONC_ITEM_ID" tgt_DE_CONC_ITEM_ID,tmec."DE_CONC_VER_NR" tgt_DE_CONC_VER_NR,tmec."VAL_DOM_ITEM_ID" tgt_VAL_DOM_ITEM_ID,
	  tmec."VAL_DOM_VER_NR" tgt_VAL_DOM_VER_NR,
	  tmec."MEC_LONG_NM" tgt_MEC_LONG_NM ,tmec."MEC_PHY_NM" tgt_MEC_PHY_NM, tmec."CDE_ITEM_ID" tgt_CDE_ITEM_ID,tmec."CDE_VER_NR" tgt_CDE_VER_NR 
	from admin_item s, NCI_MDL_ELMNT sme,NCI_MDL_ELMNT_CHAR smec, admin_item t, NCI_MDL_ELMNT tme,NCI_MDL_ELMNT_CHAR tmec, nci_MEC_MAP map
	where s.item_id = sme.mdl_item_id and s.ver_nr = sme.mdl_item_ver_nr and sme.item_id = smec.MDL_ELMNT_ITEM_ID
	and sme.ver_nr = smec.MDL_ELMNT_VER_NR and s.admin_item_typ_id = 57 and
	  t.item_id = tme.mdl_item_id and t.ver_nr = tme.mdl_item_ver_nr and tme.item_id = tmec.MDL_ELMNT_ITEM_ID
	and tme.ver_nr = tmec.MDL_ELMNT_VER_NR and t.admin_item_typ_id = 57 and
	   smec.MEC_ID = map.SRC_MEC_ID and tmec.mec_id = map.TGT_MEC_ID;


alter table NCI_DS_HDR add (FLTR_MDL_ITEM_ID number, FLTR_MDL_VER_NR number(4,2));

--DSRMWS-2818. Added by Surinder on 9/8/23
DELETE from obj_key  where OBJ_TYP_ID = 5;
DELETE from obj_typ where OBJ_TYP_ID = 5;
COMMIT ;

alter table NCI_MEC_MAP add (CRDNLITY_ID integer);

alter table NCI_MEC_MAP add (MEC_MAP_NOTES varchar2(4000));

alter table NCI_MEC_MAP add ( MEC_SUB_GRP_NBR integer);
