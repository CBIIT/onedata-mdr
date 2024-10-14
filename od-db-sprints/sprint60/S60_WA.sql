

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


CREATE OR REPLACE TRIGGER TR_NCI_STG_VAL_MAP_SEQ  BEFORE INSERT  on NCI_STG_MEC_VAL_MAP
  for each row
         BEGIN    IF (:NEW.STG_MECVM_ID<= 0  or :NEW.STG_MECVM_ID is null)  THEN
         select NCI_SEQ_MECVM.nextval
    into :new.STG_MECVM_ID  from  dual ;
END IF;

END ;
/
 


CREATE OR REPLACE TRIGGER OD_TR_NCI_STG_MEC_VAL_MAP_UPD 
BEFORE INSERT or UPDATE ON NCI_STG_MEC_VAL_MAP
for each row
BEGIN
  :new.DT_SORT := systimestamp();
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
  :new.lst_upd_dt := sysdate();
END;
/
