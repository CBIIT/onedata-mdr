create or replace TRIGGER OD_TR_DS_HDR_RSLT_CDE  BEFORE INSERT  on  NCI_DS_RSLT for each row
BEGIN
    :new.ITEM_ID_2 := :new.ITEM_ID;
    :new.VER_NR_2 := :new.VER_NR;
END ;
/
