-- Tracker 994

CREATE OR REPLACE TRIGGER TR_AI_AUD_TS
  BEFORE UPDATE ON ADMIN_ITEM
  REFERENCING FOR EACH ROW
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;

if (upper(:new.ITEM_LONG_NM) = 'SYSGEN') then 
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;

if (:new.CREAT_USR_ID_X is null) then
:new.CREAT_USR_ID_X := :new.CREAT_USR_ID;
end if;
if (:new.LST_UPD_USR_ID_X is null) then
:new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;
end if;

END TR_AI_AUD_TS;
/
