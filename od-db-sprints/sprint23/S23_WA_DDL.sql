create or replace TRIGGER TR_NCI_CSI_POST
  AFTER  UPDATE
  on NCI_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
    
    --update nci_clsfctn_schm_item set Ful_path = (
END;
