

--RA
insert into obj_key select * from onedata_wa.obj_key where obj_typ_id = 55;
commit;

insert into obj_key select * from onedata_wa.obj_key where obj_key_desc='OMOP_CODE';
commit;
