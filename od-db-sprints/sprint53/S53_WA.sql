-- wa

CREATE OR REPLACE TRIGGER TR_AI_WFS
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
     WHEN ( -- WFS is like retired requires End Date --
  ((DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=1 and (new.ADMIN_STUS_ID > 76 and new.ADMIN_STUS_ID < 82)) and --WFS is changed to like Retired
   (new.UNTL_DT is null)) --new End Date is null error
    or --WFS was like Retired and is not changed, End Date shall not be removed
  (DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=0 and (old.ADMIN_STUS_ID is not null and old.ADMIN_STUS_ID > 76 and old.ADMIN_STUS_ID < 82) and
  (DECODE(new.UNTL_DT, old.UNTL_DT,0,1)=1 and new.UNTL_DT is null) ---changed End Data to n errorull
  )) BEGIN
RAISE_APPLICATION_ERROR( -20001,'!!!! The item is not save "RETIRED" Workflow Status requires "End Date" value to be set !!!!');
END TR_AI_WFS;
/

--WA
insert into obj_key(obj_typ_id, obj_key_desc) values (55,'Term');
insert into obj_key(obj_typ_id, obj_key_desc) values (55,'Code');
commit;

CREATE OR REPLACE TRIGGER TR_AI_AUD_TS
  BEFORE UPDATE ON ADMIN_ITEM
   FOR EACH ROW
   declare 
v_item_typ_nm varchar2(100);
v_nm  varchar2(1000);
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

if (upper(:new.ITEM_NM) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =3) then
for cur in (select ITEM_NM from ADMIN_ITEM ai ,  VALUE_DOM vd where ai.item_id = vd.rep_cls_item_id and ai.ver_nr = vd.rep_cls_ver_nr 
   and vd.item_id = :new.ITEM_ID and vd.ver_nr = :new.VER_NR) loop
:new.ITEM_NM := cur.ITEM_NM;
end loop;
end if;
if (upper(:new.ITEM_DESC) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =3) then
for cur in (select ITEM_DESC from ADMIN_ITEM ai ,  VALUE_DOM vd where ai.item_id = vd.rep_cls_item_id and ai.ver_nr = vd.rep_cls_ver_nr 
   and vd.item_id = :new.ITEM_ID and vd.ver_nr = :new.VER_NR) loop
:new.ITEM_DESC := cur.ITEM_DESC;
end loop;
end if;


if (upper(:new.ITEM_NM) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =4) then
for cur in (select dec.ITEM_NM || ' ' || vd.item_nm  ITEM_NM from ADMIN_ITEM dec ,  admin_item vd, de where dec.item_id = de.de_conc_item_id
and dec.ver_nr = de.de_conc_ver_nr and vd.item_id = de.val_dom_item_id and vd.ver_nr = de.val_dom_ver_nr
and dec.admin_item_typ_id = 2 and vd.admin_item_typ_id = 3 and de.item_id = :new.ITEM_ID and de.ver_nr = :new.VER_NR) loop
:new.ITEM_NM := cur.ITEM_NM;
end loop;
end if;
if (upper(:new.ITEM_DESC) = 'SYSGEN' and :new.ADMIN_ITEM_TYP_ID =4) then
for cur in (select dec.ITEM_DESC || '_' || vd.item_desc  ITEM_desc from ADMIN_ITEM dec ,  admin_item vd, de where dec.item_id = de.de_conc_item_id
and dec.ver_nr = de.de_conc_ver_nr and vd.item_id = de.val_dom_item_id and vd.ver_nr = de.val_dom_ver_nr
and dec.admin_item_typ_id = 2 and vd.admin_item_typ_id = 3 and de.item_id = :new.ITEM_ID and de.ver_nr = :new.VER_NR) loop
:new.ITEM_DESC := cur.ITEM_DESC;
end loop;
end if;

if (:new.CREAT_USR_ID_X is null) then
:new.CREAT_USR_ID_X := :new.CREAT_USR_ID;
end if;
if (:new.LST_UPD_USR_ID_X is null) then
:new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;
end if;
select obj_key_desc into v_item_typ_nm from obj_key where obj_key_id = :new.admin_item_typ_id;

:new.ITEM_NM_ID_VER :=  :new.item_nm || '|' || :new.ITEM_ID || '|' || :new.ver_nr || '|' || v_item_typ_nm ;


END;
/
