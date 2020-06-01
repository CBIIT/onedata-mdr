 
create trigger TR_S2P_CONC_DOM_VAL_MEAN
  BEFORE INSERT or UPDATE
  on CONC_DOM_VAL_MEAN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_CSI
  BEFORE INSERT or UPDATE
  on NCI_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_STG_AI_CNCPT
  BEFORE INSERT or UPDATE
  on NCI_STG_AI_CNCPT
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_VAL_MEAN
  BEFORE INSERT or UPDATE
  on NCI_VAL_MEAN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_PROTCL
  BEFORE INSERT or UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_FORM
  BEFORE INSERT or UPDATE
  on NCI_FORM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/




create trigger TR_S2P_NCI_ADMIN_ITEM_REL
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ADMIN_ITEM_REL_AK
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_AK_ADMIN_ITEM_REL
  BEFORE INSERT or UPDATE
  on NCI_ALT_KEY_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_QUEST_VV
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_CSI_ALT_DEFNMS
  BEFORE INSERT or UPDATE
  on NCI_CSI_ALT_DEFNMS
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_INSTR_S2P
  BEFORE INSERT or UPDATE
  on NCI_INSTR
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/



create trigger TR_S2P_NCI_QUEST_VV_REP
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VV_REP
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_FORM_TA
  BEFORE INSERT or UPDATE
  on NCI_FORM_TA
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/

create trigger TR_S2P_NCI_USR_CART
  BEFORE INSERT or UPDATE
  on NCI_USR_CART
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/





