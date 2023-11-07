insert into obj_key select * from onedata_wa.obj_key where obj_typ_id in (50,51,52) and obj_key_id not in (Select obj_key_id from obj_key)
commit;
