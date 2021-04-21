
 CREATE SEQUENCE OD_SEQ_CDE_IMPORT
          INCREMENT BY 1
          START WITH 1000
         ;

 CREATE OR REPLACE TRIGGER OD_TR_CDE_CREAT  BEFORE INSERT  on NCI_STG_CDE_CREAT  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;

/



