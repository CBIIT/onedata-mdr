
CREATE OR REPLACE TRIGGER TR_AI_AUD_TS
  BEFORE UPDATE ON ADMIN_ITEM
   FOR EACH ROW
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;

if (upper(:new.ITEM_LONG_NM) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =4) then
for cur in (select * from de where item_id = :new.ITEM_ID and ver_nr = :new.ver_nr) loop
:new.ITEM_LONG_NM := cur.DE_CONC_ITEM_ID || 'v' || trim(to_char(cur.DE_CONC_VER_NR, '9999.99')) || ':' || cur.VAL_DOM_ITEM_ID || 'v' || trim(to_char(cur.VAL_DOM_VER_NR, '9999.99'));
end loop;
end if;


if (upper(:new.ITEM_LONG_NM) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =2) then
for cur in (select * from de_conc where item_id = :new.ITEM_ID and ver_nr = :new.ver_nr) loop
:new.ITEM_LONG_NM := cur.OBJ_CLS_ITEM_ID || 'v' || trim(to_char(cur.OBJ_CLS_VER_NR, '9999.99')) || ':' || cur.PROP_ITEM_ID || 'v' || trim(to_char(cur.PROP_VER_NR, '9999.99'));
end loop;
end if;

if (upper(:new.ITEM_LONG_NM) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID not in (2,4)) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || trim(to_char(:new.ver_nr, '9999.99'));
end if;

if (:new.CREAT_USR_ID_X is null) then
:new.CREAT_USR_ID_X := :new.CREAT_USR_ID;
end if;
if (:new.LST_UPD_USR_ID_X is null) then
:new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;
end if;

:new.ITEM_NM_ID_VER :=  :new.item_nm || '|' || :new.ITEM_ID || '|' || :new.ver_nr || '|' || v_item_typ_nm ;

end if;

END TR_AI_AUD_TS;
/


