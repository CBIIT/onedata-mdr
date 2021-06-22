--Tracker 956

create or replace TRIGGER TR_DE_RULE
  BEFORE INSERT OR UPDATE
  on DE
  for each row
BEGIN
  if (:new.DERV_TYP_ID is not null) then
    :new.DERV_DE_IND = 1;
  end if;
END ;
/
