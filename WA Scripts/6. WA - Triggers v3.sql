
 CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT  on ADMIN_ITEM  for each row
     BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
if (:new.ITEM_LONG_NM is null) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || :new.ver_nr;
end if;

END ;
/
