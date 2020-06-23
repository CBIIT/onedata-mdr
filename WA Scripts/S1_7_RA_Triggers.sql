 
create trigger TR_S2P_NCI_ENTTY
  BEFORE INSERT or UPDATE
  on NCI_ENTTY
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ENTTY_COMM
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_COMM
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ENTTY_ADDR
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_ADDR
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_ORG
  BEFORE INSERT or UPDATE
  on NCI_ORG
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/


create trigger TR_S2P_NCI_PRSN
  BEFORE INSERT or UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.S2P_TRN_DT := SYSDATE;
END;
/
