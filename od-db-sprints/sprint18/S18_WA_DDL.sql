create or replace TRIGGER TR_NCI_DLOAD_HDR_TS
  BEFORE  UPDATE  OF DLOAD_TYP_ID,DLOAD_FMT_ID,DLOAD_HDR_NM,EMAIL_ADDR,CMNT_TXT
  on NCI_DLOAD_HDR
  for each row
BEGIN

  :new.LST_UPD_DT := SYSDATE;
END;
/

  
  create or replace TRIGGER TR_NCI_DLOAD_DTL_TS
  before  INSERT OR UPDATE
  on NCI_DLOAD_DTL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;
  commit;
END;
/

  create or replace TRIGGER TR_NCI_DLOAD_ALS_TS
  BEFORE  UPDATE
  on NCI_DLOAD_ALS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;
  commit;
END;
/
  
