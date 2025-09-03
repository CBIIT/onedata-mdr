create or replace TRIGGER TR_NCI_MDL_ELMNT_CHAR
  BEFORE  UPDATE
  on NCI_MDL_ELMNT_CHAR
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
   if (:new.CDE_ITEM_ID is null and (:new.VAL_DOM_ITEM_ID is not null or :new.DE_CONC_ITEM_ID is not null)) then
     :new.VAL_DOM_ITEM_ID := null;
     :new.VAL_DOM_VER_NR := null;
     :new.DE_CONC_ITEM_ID := null;
     :new.DE_CONC_VER_NR := null;
   :new.VD_TYP_ID := null;

   end if;
      if (nvl(:new.CDE_ITEM_ID,0) <> nvl(:old.cde_item_id,0) or  nvl(:new.CDE_VER_NR,0) <> nvl(:old.cde_VER_NR,0) ) then
     for cur in (select * from de where item_id = :new.CDE_ITEM_ID and ver_nr = :new.cde_ver_nr) loop
     :new.VAL_DOM_ITEM_ID := cur.VAL_DOM_ITEM_ID;
     :new.VAL_DOM_VER_NR := cur.VAL_DOM_VER_NR;
     :new.DE_CONC_ITEM_ID := cur.DE_CONC_ITEM_ID;
     :new.DE_CONC_VER_NR := cur.DE_CONC_VER_NR;
for cur1 in (select * from value_dom where item_id = cur.val_dom_item_id and ver_nr = cur.val_dom_ver_nr) loop
  :new.vd_typ_id := cur1.val_dom_typ_id;
end loop;
end loop;
  
   end if;

END;
/
  CREATE OR REPLACE EDITIONABLE TRIGGER TR_DS_PRMTR_ID_INS
BEFORE INSERT ON NCI_DS_PRMTR
FOR EACH ROW
BEGIN
    IF (:NEW.PRMTR_ID<= 0  or :NEW.PRMTR_ID is null)  THEN 

        SELECT SEQ_DS_PRMTR_ID.NEXTVAL
        INTO :new.PRMTR_ID
        FROM dual;
    END IF;
END;
/
ALTER TRIGGER TR_DS_PRMTR_ID_INS ENABLE;
