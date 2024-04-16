insert into obj_key select * from onedata_Wa.obj_key where obj_key_id not in (select obj_key_id from Obj_key);
commit;
