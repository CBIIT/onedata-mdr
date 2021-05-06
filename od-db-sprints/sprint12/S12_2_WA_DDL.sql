
 CREATE SEQUENCE OD_SEQ_CDE_IMPORT
          INCREMENT BY 1
          START WITH 1000
         ;

 CREATE OR REPLACE TRIGGER OD_TR_CDE_CREAT  BEFORE INSERT  on NCI_STG_CDE_CREAT  for each row
     BEGIN    IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
 into :new.STG_AI_ID  from  dual ;   END IF;
 END;
/

create or replace TRIGGER TR_NCI_AI_DENORM_INS
  for  insert or update   on ADMIN_ITEM
compound trigger
TYPE r_change_row is RECORD (
  item_id   ADMIN_ITEM.ITEM_ID%TYPE,
  VER_NR   ADMIN_ITEM.VER_NR%TYPE,
  REGSTR_STUS_ID ADMIN_ITEM.REGSTR_STUS_ID%TYPE,
  ADMIN_STUS_ID  ADMIN_ITEM.ADMIN_STUS_ID%TYPE,
  CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  ORIGIN_ID  ADMIN_ITEM.ORIGIN_ID%TYPE,
  OLD_REGSTR_STUS_ID ADMIN_ITEM.REGSTR_STUS_ID%TYPE,
  OLD_ADMIN_STUS_ID  ADMIN_ITEM.ADMIN_STUS_ID%TYPE,
  OLD_CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  OLD_ORIGIN_ID  ADMIN_ITEM.ORIGIN_ID%TYPE
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
  t_change(t_change.count).OLD_REGSTR_STUS_ID := nvl(:old.REGSTR_STUS_ID,9999);
  t_change(t_change.count).OLD_ADMIN_STUS_ID := nvl(:old.ADMIN_STUS_ID,9999);
  t_change(t_change.count).OLD_CNTXT_ITEM_ID := nvl(:old.CNTXT_ITEM_ID,9999);
  t_change(t_change.count).OLD_ORIGIN_ID := nvl(:old.ORIGIN_ID,9999);

END AFTER EACH ROW;

AFTER STATEMENT IS
s_REGSTR_STUS_NM_DN  ADMIN_ITEM.REGSTR_STUS_NM_DN%TYPE;
s_ADMIN_STUS_NM_DN  ADMIN_ITEM.ADMIN_STUS_NM_DN%TYPE;
s_CNTXT_NM_DN   ADMIN_ITEM.CNTXT_NM_DN%TYPE;
s_ORIGIN_ID_DN  ADMIN_ITEM.ORIGIN_ID_DN%TYPE;

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
        update ADMIN_ITEM set ORIGIN_ID_DN = cur.obj_key_desc, ORIGIN = cur.obj_key_desc where ITEM_ID = t_change(indx).item_id
        and ver_nr = t_change(indx).ver_nr;
    end loop;
end if;
end if;


end loop;
END AFTER STATEMENT;

END;
/
