
create sequence od_seq_MDL_IMPORT start with 1;

CREATE OR REPLACE TRIGGER "OD_TR_MDL" BEFORE INSERT  on NCI_STG_MDL  for each row
     BEGIN    IF (:NEW.MDL_IMP_ID = -1  or :NEW.MDL_IMP_ID is null)  THEN select od_seq_MDL_IMPORT.nextval
 into :new.MDL_IMP_ID  from  dual ;   END IF;
 END;

/

  CREATE OR REPLACE  TRIGGER "ONEDATA_WA"."OD_TR_MDL_IMPORT_AUD" 
BEFORE INSERT OR UPDATE ON NCI_STG_MDL
for each row
BEGIN
:new.LST_UPD_DT := sysdate;
:new.DT_SORT := systimestamp();
END;
/

