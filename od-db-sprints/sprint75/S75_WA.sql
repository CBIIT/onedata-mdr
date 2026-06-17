create or replace TRIGGER TR_ALT_NMS_POST
  AFTER INSERT OR UPDATE
  on ALT_NMS
  for each row
BEGIN
if (nvl(:new.fld_delete,0) = 0) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;
if (nvl(:new.fld_delete,0) = 1) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;

END;
/
create or replace TRIGGER TR_ALT_DEF_POST
  AFTER INSERT OR UPDATE
  on ALT_DEF
  for each row
BEGIN
 if (nvl(:new.fld_delete,0) = 0) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;
if (nvl(:new.fld_delete,0) = 1) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;
END;
/
create or replace TRIGGER TR_REF_POST
  AFTER INSERT OR UPDATE
  on REF
  for each row
BEGIN
 if (nvl(:new.fld_delete,0) = 0) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;
if (nvl(:new.fld_delete,0) = 1) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end if;
END;
/

create or replace TRIGGER TR_CSI_DE_POST
  AFTER INSERT OR UPDATE
  on
NCI_ADMIN_ITEM_REL
  for each row
BEGIN
  if (nvl(:new.fld_delete,0) = 0) then 
if (:new.rel_typ_id = 65) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.c_item_id and VER_NR = :new.c_item_VER_NR;
    end if;
    if (:new.rel_typ_id = 66) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.p_item_id and VER_NR = :new.p_item_VER_NR;
    end if;
end if;
  if (nvl(:new.fld_delete,0) = 1) then 
if (:new.rel_typ_id = 65) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.c_item_id and VER_NR = :new.c_item_VER_NR;
    end if;
    if (:new.rel_typ_id = 66) then
    update ADMIN_ITEM set LST_UPD_DT = sysdate where ITEM_ID = :new.p_item_id and VER_NR = :new.p_item_VER_NR;
    end if;
end if;

END;
/




