create or replace TRIGGER TR_NCI_MDL_MAP_NM
  AFTER INSERT or update
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set ITEM_NM_CURATED = item_nm || ' | ' || (Select s.item_nm || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || 'v' || :new.tgt_mdl_ver_nr
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr) || ' | ' || item_id || 'v' || ver_nr
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;
END;
/

alter table admin_item disable all triggers;

update ADMIN_ITEM set ITEM_NM_CURATED =  item_nm || ' | ' || (Select s.item_nm || 'v' || s.ver_nr || ' -> ' || t.item_nm || 'v' || t.ver_nr
   from admin_item s, admin_item t, nci_mdl_map m where s.item_id = m.src_mdl_item_id and s.ver_nr = m.src_mdl_ver_nr and t.item_id = m.tgt_mdl_item_id 
   and t.ver_nr = m.tgt_mdl_ver_nr and m.item_id = admin_item.item_id and m.ver_nr = admin_item.ver_nr) || ' | ' || item_id || 'v' || ver_nr
   where admin_item_typ_id = 58
   commit;

alter table admin_item enable all triggers;

