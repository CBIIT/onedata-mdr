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


CREATE OR REPlACE TRIGGER TR_NCI_AI_DENORM_INS
  for  insert or update   on ADMIN_ITEM
compound trigger
TYPE r_change_row is RECORD (
  item_id   ADMIN_ITEM.ITEM_ID%TYPE,
  VER_NR   ADMIN_ITEM.VER_NR%TYPE,
  REGSTR_STUS_ID ADMIN_ITEM.REGSTR_STUS_ID%TYPE,
  ADMIN_STUS_ID  ADMIN_ITEM.ADMIN_STUS_ID%TYPE,
  CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  ORIGIN_ID  ADMIN_ITEM.ORIGIN_ID%TYPE,
  ITEM_NM  ADMIN_ITEM.ITEM_NM%TYPE,
  ITEM_DESC  ADMIN_ITEM.ITEM_DESC%TYPE,
  ADMIN_ITEM_TYP_ID  ADMIN_ITEM.ADMIN_ITEM_TYP_ID%TYPE,
  OLD_REGSTR_STUS_ID ADMIN_ITEM.REGSTR_STUS_ID%TYPE,
  OLD_ADMIN_STUS_ID  ADMIN_ITEM.ADMIN_STUS_ID%TYPE,
  OLD_CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  OLD_ORIGIN_ID  ADMIN_ITEM.ORIGIN_ID%TYPE,
  OLD_ITEM_NM  ADMIN_ITEM.ITEM_NM%TYPE,
  OLD_ITEM_DESC  ADMIN_ITEM.ITEM_DESC%TYPE
  
);

TYPE t_change_row is TABLE of r_change_row
INDEX by PLS_INTEGER;

t_change t_change_row;

AFTER EACH ROW IS
BEGIN
  t_change(t_change.count+1).ITEM_ID := :new.ITEM_ID;
  t_change(t_change.count).VER_NR := :new.VER_NR;
  t_change(t_change.count).REGSTR_STUS_ID := nvl(:new.REGSTR_STUS_ID,9999);
  t_change(t_change.count).ADMIN_STUS_ID := nvl(:new.ADMIN_STUS_ID,9999);
  t_change(t_change.count).CNTXT_ITEM_ID := nvl(:new.CNTXT_ITEM_ID,9999);
  t_change(t_change.count).ORIGIN_ID := nvl(:new.ORIGIN_ID,9999);
  t_change(t_change.count).ITEM_NM := upper(nvl(:new.ITEM_NM,9999));
  t_change(t_change.count).ITEM_DESC := upper(nvl(:new.ITEM_DESC,9999));
  t_change(t_change.count).ADMIN_ITEM_TYP_ID:= nvl(:new.ADMIN_ITEM_TYP_ID,9999);

  t_change(t_change.count).OLD_REGSTR_STUS_ID := nvl(:old.REGSTR_STUS_ID,9999);
  t_change(t_change.count).OLD_ADMIN_STUS_ID := nvl(:old.ADMIN_STUS_ID,9999);
  t_change(t_change.count).OLD_CNTXT_ITEM_ID := nvl(:old.CNTXT_ITEM_ID,9999);
  t_change(t_change.count).OLD_ORIGIN_ID := nvl(:old.ORIGIN_ID,9999);
 t_change(t_change.count).OLD_ITEM_NM := nvl(:old.ITEM_NM,9999);
 t_change(t_change.count).OLD_ITEM_DESC := nvl(:old.ITEM_DESC,9999);

END AFTER EACH ROW;

AFTER STATEMENT IS
s_REGSTR_STUS_NM_DN  ADMIN_ITEM.REGSTR_STUS_NM_DN%TYPE;
s_ADMIN_STUS_NM_DN  ADMIN_ITEM.ADMIN_STUS_NM_DN%TYPE;
s_CNTXT_NM_DN   ADMIN_ITEM.CNTXT_NM_DN%TYPE;
s_ORIGIN_ID_DN  ADMIN_ITEM.ORIGIN_ID_DN%TYPE;
S_ITEM_NM ADMIN_ITEM.ITEM_NM%TYPE;
S_ITEM_DESC ADMIN_ITEM.ITEM_DESC%TYPE;

BEGIN
for indx in 1..t_change.count
loop

if(t_change(indx).REGSTR_STUS_ID is not null) then
if ( t_change(indx).REGSTR_STUS_ID <> t_change(indx).OLD_REGSTR_STUS_ID) then
    for cur in (select STUS_NM into s_REGSTR_STUS_NM_DN from STUS_MSTR where stus_typ_id = 1 and stus_id = t_change(indx).REGSTR_STUS_ID) loop
        update ADMIN_ITEM set REGSTR_STUS_NM_DN = cur.stus_nm where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end if;

if(t_change(indx).ADMIN_STUS_ID is not null) then
if ( t_change(indx).ADMIN_STUS_ID <> t_change(indx).OLD_ADMIN_STUS_ID) then
    for cur in (select STUS_NM into s_ADMIN_STUS_NM_DN from STUS_MSTR where stus_typ_id = 2 and stus_id = t_change(indx).ADMIN_STUS_ID) loop
        update ADMIN_ITEM set ADMIN_STUS_NM_DN = cur.stus_nm where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end if;

if(t_change(indx).CNTXT_ITEM_ID is not null) then
if ( t_change(indx).CNTXT_ITEM_ID <> t_change(indx).OLD_CNTXT_ITEM_ID) then
    for cur in (select item_nm from admin_item where  ITEM_ID= t_change(indx).CNTXT_ITEM_ID) loop
        update ADMIN_ITEM set CNTXT_NM_DN = cur.item_nm where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end if;

--raise_application_error(-20000, t_change(indx).ORIGIN_ID );
if(t_change(indx).ORIGIN_ID is not null) then
if ( t_change(indx).ORIGIN_ID <> t_change(indx).OLD_ORIGIN_ID) then
    for cur in (select obj_key_desc from obj_key where obj_key_id = t_change(indx).ORIGIN_ID) loop
        update ADMIN_ITEM set ORIGIN_ID_DN = cur.obj_key_desc where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end if;

if(t_change(indx).ADMIN_ITEM_TYP_ID = 3 and t_change(indx).ITEM_NM ='SYSGEN' ) then
  for cur in (select ITEM_NM from ADMIN_ITEM ai ,  VALUE_DOM vd where ai.item_id = vd.rep_cls_item_id and ai.ver_nr = vd.rep_cls_ver_nr 
   and vd.item_id = t_change(indx).item_id and vd.ver_nr = t_change(indx).ver_nr) loop
  update ADMIN_ITEM set Item_nm = cur.item_nm where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;

if(t_change(indx).ADMIN_ITEM_TYP_ID = 4 and t_change(indx).ITEM_NM ='SYSGEN' ) then
 for cur in (select dec.ITEM_NM || ' ' || vd.item_nm  ITEM_NM from ADMIN_ITEM dec ,  admin_item vd, de where dec.item_id = de.de_conc_item_id
and dec.ver_nr = de.de_conc_ver_nr and vd.item_id = de.val_dom_item_id and vd.ver_nr = de.val_dom_ver_nr
and dec.admin_item_typ_id = 2 and vd.admin_item_typ_id = 3 and de.item_id = t_change(indx).item_id  and de.ver_nr = t_change(indx).ver_nr ) loop
  update ADMIN_ITEM set Item_nm = cur.item_nm where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;

if(t_change(indx).ADMIN_ITEM_TYP_ID = 3 and t_change(indx).ITEM_DESC ='SYSGEN' ) then
  for cur in (select ITEM_DESC from ADMIN_ITEM ai ,  VALUE_DOM vd where ai.item_id = vd.rep_cls_item_id and ai.ver_nr = vd.rep_cls_ver_nr 
   and vd.item_id = t_change(indx).item_id and vd.ver_nr = t_change(indx).ver_nr) loop
  update ADMIN_ITEM set Item_desc = cur.item_desc where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;

if(t_change(indx).ADMIN_ITEM_TYP_ID = 4 and t_change(indx).ITEM_DESC ='SYSGEN' ) then
 for cur in (select dec.ITEM_desc || '_' || vd.item_desc  ITEM_desc from ADMIN_ITEM dec ,  admin_item vd, de where dec.item_id = de.de_conc_item_id
and dec.ver_nr = de.de_conc_ver_nr and vd.item_id = de.val_dom_item_id and vd.ver_nr = de.val_dom_ver_nr
and dec.admin_item_typ_id = 2 and vd.admin_item_typ_id = 3 and de.item_id = t_change(indx).item_id  and de.ver_nr = t_change(indx).ver_nr ) loop
  update ADMIN_ITEM set Item_desc = cur.item_desc where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end loop;
END AFTER STATEMENT;

END;
/
