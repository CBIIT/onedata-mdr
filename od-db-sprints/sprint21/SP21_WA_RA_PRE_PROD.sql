delete from obj_key where obj_typ_id = 11 and obj_key_desc = 'Manually-curated';
commit;
/
insert into obj_key (obj_key_id, obj_typ_id, obj_key_desc, obj_key_def, nci_cd)
values (83, 11, 'Manually-curated', 'Manually-curated', 'Manually-curated');
commit;
/
delete from obj_key where obj_typ_id = 15 and obj_key_desc = 'Manually-curated';
commit;
/
insert into obj_key (obj_key_id, obj_typ_id, obj_key_desc, obj_key_def, nci_cd)
values (82, 15, 'Manually-curated', 'Manually-curated', 'Manually-curated');
commit;
/