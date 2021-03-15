create or replace TRIGGER TR_AI_EXT_TAB_INS
  AFTER INSERT
  on ADMIN_ITEM
  for each row
BEGIN

if (:new.admin_item_typ_id not in (5,6,7)) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;
END;
