alter table ADMIN_ITEM DISABLE ALL TRIGGERS;

update admin_item set ITEM_NM_ID_VER =  (select item_nm || '|' || ITEM_ID || '|' || ver_nr || '|' || obj_key_desc  from obj_key where obj_Key_id = admin_item.admin_item_typ_id);
commit;

alter table ADMIN_ITEM ENABLE ALL TRIGGERS;

insert into sbr.ac_registrations (ar_idseq, ac_idseq, registration_status, date_created, created_by)
select nci_11179.cmr_guid,nci_idseq, nci_stus, ai.creat_dt, ai.creat_usr_id from stus_mstr, admin_item ai where admin_item_typ_id <> 8 and
stus_typ_id = 1 and stus_id = ai.regstr_stus_id
and ai.regstr_stus_id is not null  and nci_idseq not in (select ac_idseq from sbr.ac_registrations);
commit;

