create or replace TRIGGER TR_NCI_MDL_MAP_AUD_TS
   BEFORE  UPDATE
  on NCI_MDL_MAP
  for each row
BEGIN
   
:new.lst_upd_dt := sysdate;
END;
/

create or replace TRIGGER TR_NCI_MDL_AUD_TS
  BEFORE  UPDATE
  on NCI_MDL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;

END;
/


create or replace TRIGGER TR_NCI_STG_MDL_ELMNT_BEF_UPD
  BEFORE  UPDATE
  on NCI_STG_MDL_ELMNT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;

END;
/

   
create or replace TRIGGER TR_NCI_STG_MDL_ELMNT_CHAR_BEF_UPD
  BEFORE  UPDATE
  on NCI_STG_MDL_ELMNT_CHAR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;

END;
/
   
create or replace TRIGGER TR_NCI_PROC_EXEC_BEF_UPD
  BEFORE  UPDATE
  on NCI_PROC_EXEC
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.START_DT := SYSDATE;

END;
/

create or replace TRIGGER OD_TR_DS_UPD 
BEFORE UPDATE ON NCI_DS_HDR
for each row
BEGIN
  :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
  :new.DT_SORT := systimestamp();
  :new.LST_UPD_DT := SYSDATE;

END;
/
   
create or replace TRIGGER OD_TR_ALT_NMS_UPD 
BEFORE UPDATE ON NCI_STG_ALT_NMS 
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.DT_SORT := systimestamp();
  :new.LST_UPD_DT := SYSDATE;

END;

/



