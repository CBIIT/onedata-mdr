create or replace TRIGGER TR_MDL_POST
  AFTER  UPDATE
  on NCI_MDL
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/

create or replace TRIGGER TR_MDL_MAP_POST
  AFTER  UPDATE
  on NCI_MDL_MAP
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/
  
create or replace TRIGGER TR_AI_END_EFF_DT
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
   -- WHEN ( (DECODE(new.UNTL_DT, old.CREAT_DT,0,1)=0) and new.UNTL_DT is not null) --new End Date is same as create date
    WHEN (new.UNTL_DT < new.EFF_DT and new.UNTL_DT is not null and new.EFF_DT is not null)
    DECLARE --for debugging
        v_dt date := :new.untl_dt;
        v_dt_old date := :new.eff_dt;
    BEGIN
        RAISE_APPLICATION_ERROR( -20001,'!!!! The item is not saved. "End Date" must be set later than "Effective Date"  !!!!');
END TR_AI_END_EFF_DT;
/
