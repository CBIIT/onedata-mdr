create or replace TRIGGER TR_NCI_DLOAD_HDR_TS
  BEFORE  UPDATE  OF DLOAD_TYP_ID,DLOAD_FMT_ID,DLOAD_HDR_NM,EMAIL_ADDR,CMNT_TXT
  on NCI_DLOAD_HDR
  for each row
BEGIN

  :new.LST_UPD_DT := SYSDATE;
END;
/

  
  create or replace TRIGGER TR_NCI_DLOAD_DTL_TS
  before  INSERT OR UPDATE
  on NCI_DLOAD_DTL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;
 END;
/

  create or replace TRIGGER TR_NCI_DLOAD_ALS_TS
  BEFORE  UPDATE
  on NCI_DLOAD_ALS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  update NCI_DLOAD_HDR set LST_UPD_DT = sysdate, lst_upd_usr_id =:new.lst_upd_usr_id where hdr_id = :new.hdr_id;
  
END;
/
  
create or replace TRIGGER TR_NCI_PERM_VAL
  BEFORE INSERT  on PERM_VAL
  for each row
BEGIN
   if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
 /*for cur in (select nci_idseq from perm_val where perm_val_nm = :new.perm_val_nm and nci_val_mean_item_id = :new.nci_val_mean_item_id and
             nci_val_mean_ver_nr = :new.nci_val_mean_ver_nr) loop
      :new.NCI_IDSEQ := cur.nci_idseq;
  end loop;
   */          
end if;
END;
/


create or replace TRIGGER OD_TR_ALT_KEY  BEFORE INSERT  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
         BEGIN    IF (:NEW.NCI_PUB_ID<= 0  or :NEW.NCI_PUB_ID is null)  THEN 
         select od_seq_ADMIN_ITEM.nextval
    into :new.NCI_PUB_ID  from  dual ;   
 :new.nci_idseq := nci_11179.cmr_guid;
END IF; END ;
/
