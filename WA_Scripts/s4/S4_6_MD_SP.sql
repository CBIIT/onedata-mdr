
update od_md_objprop set prop_val = 'VIEW' where prop_id = 10001 and obj_id in (select obj_id from od_md_obj where obj_nm = 'Contexts');
commit;