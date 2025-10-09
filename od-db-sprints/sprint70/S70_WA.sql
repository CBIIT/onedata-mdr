create or replace TRIGGER TR_MDL_POST
  AFTER  UPDATE
  on NCI_MDL
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/

create or replace TRIGGER TR_MDL_MAP_POST
  AFTER  UPDATE
  on NCI_MDL_MAP
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;
/
  
create or replace TRIGGER TR_AI_END_EFF_DT
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
   -- WHEN ( (DECODE(new.UNTL_DT, old.CREAT_DT,0,1)=0) and new.UNTL_DT is not null) --new End Date is same as create date
    WHEN (new.UNTL_DT < new.EFF_DT and new.UNTL_DT is not null and new.EFF_DT is not null)
    DECLARE --for debugging
        v_dt date := :new.untl_dt;
        v_dt_old date := :new.eff_dt;
    BEGIN
        RAISE_APPLICATION_ERROR( -20001,'!!!! The item is not saved. "End Date" must be set later than "Effective Date"  !!!!');
END TR_AI_END_EFF_DT;
/


CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT_CHAR
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
  :new.OC_CNCPT_CD := null;
  :new.PROP_CNCPT_CD := null;
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
for cur1 in (select e.cncpt_concat from nci_admin_item_ext e, de_conc dec where e.item_id = dec.obj_cls_item_id and e.ver_nr = dec.obj_cls_ver_nr and dec.item_id = cur.de_conc_item_id and dec.ver_nr = cur.de_conc_ver_nr) loop
  :new.oc_cncpt_cd := cur1.cncpt_concat;
end loop;
for cur1 in (select e.cncpt_concat from nci_admin_item_ext e, de_conc dec where e.item_id = dec.prop_item_id and e.ver_nr = dec.prop_ver_nr and dec.item_id = cur.de_conc_item_id and dec.ver_nr = cur.de_conc_ver_nr) loop
  :new.prop_cncpt_cd := cur1.cncpt_concat;
end loop;
end loop;
   end if;

END;
/
