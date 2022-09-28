
create or replace TRIGGER OD_TR_FORM_IMPORT  BEFORE INSERT  on NCI_STG_FORM_IMPORT  for each row
     BEGIN    IF (:NEW.STG_ID = -1  or :NEW.STG_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_ID  from  dual ;   END IF;
 END;
/
create or replace TRIGGER OD_TR_FORM_VV_IMPORT  BEFORE INSERT  on NCI_STG_FORM_VV_IMPORT  for each row
     BEGIN    IF (:NEW.STG_VAL_ID = -1  or :NEW.STG_VAL_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_VAL_ID  from  dual ;   END IF;
END;
/

