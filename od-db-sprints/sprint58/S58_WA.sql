CREATE OR REPLACE EDITIONABLE TRIGGER TR_NCI_DLOAD_MDL_MAP_TS
  BEFORE  UPDATE
  on NCI_DLOAD_MDL_MAP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;

END;
/
ALTER TRIGGER TR_NCI_DLOAD_MDL_MAP_TS ENABLE;
