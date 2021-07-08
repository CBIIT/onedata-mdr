create or replace TRIGGER TR_ALT_NMS_POST
  AFTER INSERT OR UPDATE
  on ALT_NMS
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/
