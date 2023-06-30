CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT  BEFORE INSERT  on NCI_MDL_ELMNT
  for each row
         BEGIN    IF (:NEW.ITEM_ID<= 0  or :NEW.ITEM_ID is null)  THEN
         select od_seq_ADMIN_ITEM.nextval
    into :new.ITEM_ID  from  dual ;
:new.ver_nr := 1;

END IF;

END ;
/
create or replace TRIGGER TR_NCI_MDL_ELMNT
  BEFORE  UPDATE
  on NCI_MDL_ELMNT
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/




