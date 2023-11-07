
alter table admin_item disable all triggers;
alter table alt_nms disable all triggers;

set escape on

update admin_item set 
MTCH_TERM_ADV = regexp_replace(upper(item_nm),'[^A-Za-z0-9]', ''),
 MTCH_TERM= regexp_replace(upper(item_nm),'[^ A-Za-z0-9]', '');
commit;



update alt_nms set 
MTCH_TERM_ADV = regexp_replace(upper(nm_desc),'[^A-Za-z0-9]', ''),
 MTCH_TERM= regexp_replace(upper(nm_Desc),'[^ A-Za-z0-9]', '');
commit;
alter table admin_item enable all triggers;
alter table alt_nms enable all triggers;

create or replace TRIGGER TR_AI_MTCH
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
  BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'[^ A-Za-z0-9]','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'[^A-Za-z0-9]','');


END;
/

create or replace TRIGGER TR_ALT_NMS_BEFORE
  BEFORE INSERT OR UPDATE
  on ALT_NMS
  for each row
BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.nm_desc),'[^ A-Za-z0-9]','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.nm_desc),'[^A-Za-z0-9]','');  
END;
/


insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Equals',50,'Equals' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Greater Than',50,'Greater Than' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Greater Than Equal To',50,'Greater Than Equal To' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Less Than',50,'Greater Than' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Greater Than Equal To',50,'Greater Than Equal To' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Contains',50,'Contains' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Begins with',50,'Begins with' );
commit;
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Concat',51,'Concat' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Equal',51,'Equal' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Lookup',51,'Lookup' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Coalese',51,'Coalese' );
commit;
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Column',52,'Column');
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Property',52,'Property');
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Attribute',52,'Attribute');
commit;
alter table nci_stg_mdl_elmnt_char disable all triggers;
update nci_stg_mdl_elmnt_char set MEC_TYP_NM = (select obj_key_id from obj_key where obj_key_desc='Column') where mec_typ_nm = 'Column';
update nci_stg_mdl_elmnt_char set MEC_TYP_NM = (select obj_key_id from obj_key where obj_key_desc='Property') where mec_typ_nm = 'Property';
update nci_stg_mdl_elmnt_char set MEC_TYP_NM = (select obj_key_id from obj_key where obj_key_desc='Attribute') where mec_typ_nm = 'Attribute';
commit;
alter table nci_stg_mdl_elmnt_char enable all triggers;
