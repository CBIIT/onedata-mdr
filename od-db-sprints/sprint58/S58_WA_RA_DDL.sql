alter table NCI_MDL add (MAP_USG_TYP_ID integer);

insert into obj_typ(obj_typ_id, obj_typ_desc) values (61,'Model Usage Type for Mapping');
commit;
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,135, 'Source Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,136, 'Target Only');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,137, 'Source or Target');
insert into obj_key(obj_typ_id, obj_key_id, obj_key_desc) values (61,138, 'No Mapping');
commit
