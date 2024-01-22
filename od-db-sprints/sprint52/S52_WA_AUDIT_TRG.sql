create or replace TRIGGER TR_NCI_MDL_MAP_AUD_TS
   BEFORE  UPDATE
  on NCI_MDL_MAP
  for each row
BEGIN
   
:new.lst_upd_dt := sysdate;
END;
/

create or replace TRIGGER TR_NCI_MDL_AUD_TS
  BEFORE  UPDATE
  on NCI_MDL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;

END;
/


 
