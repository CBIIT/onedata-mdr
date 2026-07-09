/*create or replace TRIGGER TR_MEC_MAP_POST
  AFTER UPDATE
  on NCI_MEC_MAP
  for each row
BEGIN
if (nvl(:new.fld_delete,0) = 0) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.mdl_Map_item_id and VER_NR = :new.mdl_Map_VER_NR;
end if;
if (nvl(:new.fld_delete,0) = 1) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.mdl_Map_item_id and VER_NR = :new.mdl_map_VER_NR;
end if;

END;
*/

