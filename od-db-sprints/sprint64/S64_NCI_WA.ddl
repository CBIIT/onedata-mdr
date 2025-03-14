create or replace TRIGGER TR_NCI_MDL_ELMNT_CHAR
  BEFORE  UPDATE
  on NCI_MDL_ELMNT_CHAR
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
   if ((:new.CDE_ITEM_ID is null and (:new.VAL_DOM_ITEM_ID is not null or :new.DE_CONC_ITEM_ID is not null) then
     :new.VAL_DOM_ITEM_ID := null;
     :new.VAL_DOM_VER_NR := null;
     :new.DE_CONC_ITEM_ID := null;
     :new.DE_CONC_VER_NR := null;

   end if;
      if (nvl(:new.CDE_ITEM_ID,0) <> nvl(:old.cde_item_id,0) or  nvl(:new.CDE_VER_NR,0) <> nvl(:old.cde_VER_NR,0) ) then
     for cur in (select * from de where item_id = :new.CDE_ITEM_ID and ver_nr = :new.cde_ver_nr) loop
     :new.VAL_DOM_ITEM_ID := cur.VAL_DOM_ITEM_ID;
     :new.VAL_DOM_VER_NR := cur.VAL_DOM_VER_NR;
     :new.DE_CONC_ITEM_ID := cur.DE_CONC_ITEM_ID;
     :new.DE_CONC_VER_NR := cur.DE_CONC_VER_NR;
end loop;
   end if;

END;
/
  
