create or replace TRIGGER TR_NCI_ALT_NMS_DENORM_INS
  for  insert or update   on ALT_NMS
compound trigger
TYPE r_change_row is RECORD (
  NM_ID   number,
  CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  OLD_CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE
);

TYPE t_change_row is TABLE of r_change_row
INDEX by PLS_INTEGER;

t_change t_change_row;

AFTER EACH ROW IS
BEGIN
  t_change(t_change.count+1).NM_ID := :new.NM_ID;
  --t_change(t_change.count).VER_NR := :new.VER_NR;
  t_change(t_change.count).CNTXT_ITEM_ID := nvl(:new.CNTXT_ITEM_ID,9999);
  t_change(t_change.count).OLD_CNTXT_ITEM_ID := nvl(:old.CNTXT_ITEM_ID,9999);

END AFTER EACH ROW;

AFTER STATEMENT IS
s_CNTXT_NM_DN   ADMIN_ITEM.CNTXT_NM_DN%TYPE;

BEGIN
for indx in 1..t_change.count
loop



if ( t_change(indx).CNTXT_ITEM_ID <> t_change(indx).OLD_CNTXT_ITEM_ID) then
select ITEM_NM into s_CNTXT_NM_DN from ADMIN_ITEM where ITEM_ID= t_change(indx).CNTXT_ITEM_ID;
update ALT_NMS set CNTXT_NM_DN = s_CNTXT_NM_DN where NM_ID = t_change(indx).nm_id;
--and ver_nr = t_change(indx).ver_nr;
end if;
end loop;
END AFTER STATEMENT;

END;

/
