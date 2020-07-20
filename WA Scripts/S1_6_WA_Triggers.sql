 CREATE SEQUENCE NCI_SEQ_ENTTY
          INCREMENT BY 1
          START WITH 1000
         ;

CREATE OR REPLACE TRIGGER NCI_TR_ENTTY  BEFORE INSERT  on NCI_ENTTY  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; END ;
/


create trigger TR_NCI_AI_TYP_VALID_STUS_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_AI_TYP_VALID_STUS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/






create trigger TR_NCI_ENTTY_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ENTTY_COMM_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_COMM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ENTTY_ADDR_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ENTTY_ADDR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ORG_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ORG
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_PRSN_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create or replace trigger TR_NCI_AI_DENORM_INS
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
select STUS_NM into s_REGSTR_STUS_NM_DN from STUS_MSTR where stus_typ_id = 1 and stus_id = t_change(indx).REGSTR_STUS_ID;
update ADMIN_ITEM set REGSTR_STUS_NM_DN = s_REGSTR_STUS_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end if;

if(t_change(indx).ADMIN_STUS_ID is not null) then
if ( t_change(indx).ADMIN_STUS_ID <> t_change(indx).OLD_ADMIN_STUS_ID) then
select STUS_NM into s_ADMIN_STUS_NM_DN from STUS_MSTR where stus_typ_id = 2 and stus_id = t_change(indx).ADMIN_STUS_ID;
update ADMIN_ITEM set ADMIN_STUS_NM_DN = s_ADMIN_STUS_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end if;

if(t_change(indx).CNTXT_ITEM_ID is not null) then
if ( t_change(indx).CNTXT_ITEM_ID <> t_change(indx).OLD_CNTXT_ITEM_ID) then
select ITEM_NM into s_CNTXT_NM_DN from ADMIN_ITEM where ITEM_ID= t_change(indx).CNTXT_ITEM_ID;
update ADMIN_ITEM set CNTXT_NM_DN = s_CNTXT_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end if;

if(t_change(indx).ORIGIN_ID is not null) then
if ( t_change(indx).ORIGIN_ID <> t_change(indx).OLD_ORIGIN_ID) then
select OBJ_KEY_DESC into s_ORIGIN_ID_DN from OBJ_KEY where obj_key_id = t_change(indx).ORIGIN_ID;
update ADMIN_ITEM set ORIGIN_ID_DN = s_ORIGIN_ID_DN, ORIGIN = s_ORIGIN_ID_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end if;

end loop;
END AFTER STATEMENT;

END;
/

