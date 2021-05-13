 CREATE SEQUENCE OD_SEQ_IMPORT
          INCREMENT BY 1
          START WITH 1000
         ;

-- Tracker 870
 CREATE OR REPLACE TRIGGER OD_TR_AI_CNCPT_CREAT  BEFORE INSERT  on NCI_STG_AI_CNCPT_CREAT  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 END;
/

CREATE OR REPLACE TRIGGER TR_AI_AUD_TS
  BEFORE UPDATE ON ADMIN_ITEM
  REFERENCING FOR EACH ROW
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;

if (upper(:new.ITEM_LONG_NM) = 'SYSGEN') then 
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;
END TR_AI_AUD_TS;
/
