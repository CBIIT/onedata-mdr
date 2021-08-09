CREATE OR REPLACE TRIGGER TR_NCI_QVV_POST
  AFTER INSERT OR UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;

CREATE OR REPLACE TRIGGER TR_NCI_AI_POST
  AFTER INSERT OR UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
IF :new.REL_TYP_ID in (60,61) then
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
end IF;
END;

CREATE OR REPLACE TRIGGER TR_NCI_MOD_POST
  AFTER INSERT OR UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
BEGIN
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
    update ADMIN_ITEM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;


END;

CREATE OR REPLACE TRIGGER TR_NCI_FORM_POST
  AFTER  UPDATE
  on NCI_FORM
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/
SHOW ERRORS;
select* from OBJ_KEY where obj_KEY_ID in (
select distinct  REL_TYP_ID from NCI_ADMIN_ITEM_REL)
select* from OBJ_KEY where obj_KEY_ID in (
select distinct  REL_TYP_ID from NCI_ADMIN_ITEM_REL_ALT_KEY)
select*from NCI_ADMIN_ITEM_REL_ALT_KEY