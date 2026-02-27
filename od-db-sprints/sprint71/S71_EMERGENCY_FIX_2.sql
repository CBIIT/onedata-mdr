
create or replace trigger TR_NCI_REF
  BEFORE INSERT 
  on REF
  for each row
BEGIN
  if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/




create or replace trigger TR_NCI_ALT_DEF
  BEFORE INSERT 
  on ALT_DEF
  for each row
BEGIN
  if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/


create or replace trigger TR_NCI_ALT_NMS
  BEFORE INSERT  on ALT_NMS
  for each row
BEGIN
   if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/

create or replace trigger TR_NCI_PERM_VAL
  BEFORE INSERT  on PERM_VAL
  for each row
BEGIN
   if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/


CREATE OR REPLACE TRIGGER OD_TR_REF_DOC  BEFORE INSERT  on REF_DOC  for each row
                  BEGIN    IF (:NEW.REF_DOC_ID<= 0  or :NEW.REF_DOC_ID is null)  THEN 
                  select od_seq_REF_DOC.nextval
            into :new.REF_DOC_ID  from  dual ;   END IF; 
  
                  :new.nci_idseq := nci_11179.cmr_guid(); 
  END ;          
/

create or replace PROCEDURE            spUpdateCMRGUID2
AS
i int;
 BEGIN
  
  for cur in (select * from alt_nms where NCI_IDSEQ is null) loop
     update alt_nms set nci_idseq  =nci_11179.cmr_guid where nm_id = cur.nm_id;
  end loop;
  commit;
  
  for cur in (select * from alt_def where NCI_IDSEQ is null) loop
     update alt_def set nci_idseq  =nci_11179.cmr_guid where def_id = cur.def_id;
  end loop;
  commit;
  
  
  for cur in (select * from ref where NCI_IDSEQ is null) loop
     update ref set nci_idseq  =nci_11179.cmr_guid where ref_id = cur.ref_id;
  end loop;
  commit;
  
  
  for cur in (select * from ref_doc where NCI_IDSEQ is null) loop
     update ref_doc set nci_idseq  =nci_11179.cmr_guid where ref_doc_id = cur.ref_doc_id;
  end loop;
  commit;
  
  
  for cur in (select * from perm_val where NCI_IDSEQ is null) loop
     update perm_val set nci_idseq  =nci_11179.cmr_guid where val_id = cur.val_id;
  end loop;
  commit;
  
END;
/


execute spUpdateCMRGUID2;

