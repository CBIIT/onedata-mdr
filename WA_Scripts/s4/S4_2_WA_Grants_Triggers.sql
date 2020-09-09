create or replace trigger TR_NCI_ORG_AUD_TS
  BEFORE  UPDATE
  on NCI_ORG
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_PRSN_AUD_TS
  BEFORE  UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_ALT_DEF_AUD_TS
  BEFORE  UPDATE
  on ALT_DEF
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_ALT_NMS_AUD_TS
  BEFORE  UPDATE
  on ALT_NMS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_OC_RECS_AUD_TS
  BEFORE  UPDATE
  on NCI_OC_RECS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_AI_TYP_VALID_STUS_AUD_TS
  BEFORE  UPDATE
  on NCI_AI_TYP_VALID_STUS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace  trigger TR_NCI_ENTTY_COMM_AUD_TS
  BEFORE UPDATE
  on NCI_ENTTY_COMM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace  trigger TR_NCI_ENTTY_ADDR_AUD_TS
  BEFORE UPDATE
  on NCI_ENTTY_ADDR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_FORM_TA_REL_AUD_TS
  BEFORE UPDATE
  on NCI_FORM_TA_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create or replace trigger TR_NCI_ENTTY_AUD_TS
  BEFORE  UPDATE
  on NCI_ENTTY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

drop trigger TRU_ALT_NMS;

drop trigger TR_NCI_AI_REL_ALT_KEY;
drop trigger TBIU_ALT_DEF;

drop trigger TR_NCI_TEMPLATE_AUD_TS;
drop trigger TRI_CS_AUDIT_TS;


