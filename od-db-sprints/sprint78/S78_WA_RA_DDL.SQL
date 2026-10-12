
alter table ref disable all triggers;
update ref set mtch_scr = 0 where ref_typ_id in (select obj_key_id from obj_Key where obj_typ_id = 1 and upper(obj_key_Desc) like '%QUESTION%') and mtch_scr is null;
commit;
alter table ref enable all triggers;

