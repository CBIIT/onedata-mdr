grant all on CNTCT to onedata_md;
grant select on ADMIN_ITEM to onedata_md;
grant select on od_seq_cntct to onedata_md;



drop trigger TR_AI_AUDIT_TAB_INS;

create or replace TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT  on ADMIN_ITEM  for each row
     BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
if (:new.ITEM_LONG_NM is null) then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || :new.ver_nr;
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;

END ;
/

create or replace trigger TR_AI_AUD_TS
  BEFORE UPDATE
  on ADMIN_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
  :new.LST_UPD_USR_ID_X := :new.LST_UPD_USR_ID;

END TR_AI_AUD_TS;
/

create or replace trigger TR_DE_AUD_TS
  BEFORE UPDATE
  on DE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
 /* if (nvl(:new.PREF_QUEST_TXT,'X') <> nvl(:old.PREF_QUEST_TXT,'X')) then 
 INSERT INTO REF (ITEM_ID,
                     VER_NR,
                     NCI_CNTXT_ITEM_ID,
                     NCI_CNTXT_VER_NR,
                     REF_TYP_ID,
                     DISP_ORD,
                     REF_DESC,
                     REF_NM,
                     LANG_ID,

  end if;
*/  
END TR_DE_AUD_TS;



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
/