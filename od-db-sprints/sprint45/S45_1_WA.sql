CREATE OR REPLACE TRIGGER OD_TR_PV_VM_IMP BEFORE INSERT  on NCI_STG_PV_VM_IMPORT for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 :new.LST_UPD_DT := SYSDATE;
  :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
 END;
/
