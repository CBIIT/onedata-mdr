grant all on NCI_ADMIN_ITEM_XMAP to onedata_wa;

insert into obj_key select * from onedata_wa.obj_key where  obj_key_id not in (Select obj_key_id from obj_key);
commit;
