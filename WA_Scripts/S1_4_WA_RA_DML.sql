update obj_key set obj_key_desc = 'CRF' where obj_key_id = 70;
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (25, 'Address Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (26, 'Communication Type');
commit;


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (27, 'Entity Type');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) 
values (72,27,'Organization', 'Organization');


insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) 
values (73,27,'Person', 'Person');
commit;
