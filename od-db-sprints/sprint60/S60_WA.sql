

 CREATE SEQUENCE SEQ_CODE_CNFG
          INCREMENT BY 1
          START WITH 1000
         ;

create or replace TRIGGER TR_CODE_CNFG  BEFORE INSERT  on  NCI_MDL_MAP_CNFG for each row
BEGIN    IF (:NEW.CNFG_ID<= 0  or :NEW.CNFG_ID is null)  THEN
         select SEQ_CODE_CNFG.nextval
    into :new.CNFG_ID  from  dual ;   END IF;
    :new.CREATED_BY := :new.CREAT_USR_ID;
    :new.CREATED_DT := :new.CREAT_DT;
    END ;
/
