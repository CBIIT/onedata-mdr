--Tracker 956

create or replace TRIGGER TR_DE_RULE
  BEFORE INSERT OR UPDATE
  on DE
  for each row
BEGIN
  if (:new.DERV_TYP_ID is not null and nvl(:new.DERV_DE_IND,0) = 0) then
    :new.DERV_DE_IND := 1;
  end if;
    if (:new.DERV_TYP_ID is null and nvl(:new.DERV_DE_IND,0) = 1) then
    :new.DERV_DE_IND := 0;
  end if;
END ;
/
