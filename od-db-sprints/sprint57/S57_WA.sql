create or replace TRIGGER "ONEDATA_WA"."OD_TR_MDL_IMPORT_AUD" 
BEFORE INSERT OR UPDATE ON NCI_STG_MDL
for each row
BEGIN
:new.LST_UPD_DT := sysdate;
:new.DT_SORT := systimestamp();
:new.DT_LST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;
/
