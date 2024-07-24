create or replace TRIGGER "ONEDATA_WA"."OD_TR_MDL_IMPORT_AUD" 
BEFORE INSERT OR UPDATE ON NCI_STG_MDL
for each row
BEGIN
:new.LST_UPD_DT := sysdate;
:new.DT_SORT := systimestamp();
:new.DT_LST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;
/


create or replace TRIGGER TR_NCI_MDL_ELMNT_CHAR
  BEFORE  UPDATE
  on NCI_MDL_ELMNT_CHAR
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
   if (:new.CDE_ITEM_ID is null and :new.VAL_DOM_ITEM_ID is not null) then
     :new.VAL_DOM_ITEM_ID := null;
     :new.VAL_DOM_VER_NR := null;
     :new.DE_CONC_ITEM_ID := null;
     :new.DE_CONC_VER_NR := null;
     
   end if;

END;
/
