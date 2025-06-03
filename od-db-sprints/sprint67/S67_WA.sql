
create or replace TRIGGER TR_NCI_MDL_MAP_SHORT_NM
  AFTER INSERT 
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm ||' '|| :new.src_mdl_item_id || 'v' || :new.src_mdl_ver_nr || ' -> ' || t.item_nm || ' ' || :new.tgt_mdl_item_id || 'v' || :new.tgt_mdl_ver_nr ,1,255)
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;

END;
/

CREATE OR REPLACE TRIGGER OD_TR_MEC_VAL_MAP_UPD 
BEFORE INSERT OR UPDATE ON NCI_STG_MEC_VAL_MAP
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.DT_SORT := systimestamp();
  :new.LST_UPD_DT := SYSDATE;

END;
/

  
  alter table admin_item disable all triggers;

 update ADMIN_ITEM set MDL_MAP_SNAME = (Select substr(s.item_nm ||' '|| mm.src_mdl_item_id || 'v' || mm.src_mdl_ver_nr || ' -> ' || t.item_nm || ' ' || mm.tgt_mdl_item_id || 'v' || mm.tgt_mdl_ver_nr ,1,255)
   from admin_item s, admin_item t, nci_mdl_Map mm where s.item_id = mm.src_mdl_item_id and s.ver_nr = mm.src_mdl_ver_nr and t.item_id = mm.tgt_mdl_item_id and t.ver_nr = mm.tgt_mdl_ver_nr
   and mm.item_id = admin_item.item_id and mm.ver_nr = admin_item.ver_nr)
   where admin_item_typ_id = 58;
commit;
alter table admin_item enable all triggers;
