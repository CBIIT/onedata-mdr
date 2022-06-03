alter table ADMIN_ITEM DISABLE ALL TRIGGERS;

update admin_item set ITEM_NM_ID_VER =  item_nm || '|' || ITEM_ID || '|' || ver_nr || '|' || obj_key_desc  from obj_key where obj_Key_id = admin_item.admin_item_typ_id;
commit;

alter table ADMIN_ITEM ENABLE ALL TRIGGERS;

