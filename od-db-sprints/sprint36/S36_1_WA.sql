CREATE OR replace TRIGGER OD_TR_STG_ALT_NMS  BEFORE INSERT  on NCI_STG_ALT_NMS  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ; 
 END IF;
 :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
 END;
/
