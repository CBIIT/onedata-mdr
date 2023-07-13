
insert into obj_key select * from onedata_wa.obj_key where obj_typ_id in (40,41);
commit;

grant all on NCI_MEC_VAL_MAP to onedata_wa;
