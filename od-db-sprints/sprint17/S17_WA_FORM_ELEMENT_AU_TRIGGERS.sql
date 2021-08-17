--VV modifyes Question
CREATE OR REPLACE TRIGGER TRG_NCI_QVV_POST
  AFTER INSERT OR UPDATE OR DELETE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN   
                     
    update NCI_ADMIN_ITEM_REL_ALT_KEY set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where NCI_PUB_ID=:NEW.Q_PUB_ID and NCI_VER_NR= :NEW.Q_VER_NR;
           
END;
/

--Qustion updates Module
CREATE OR REPLACE TRIGGER TRG_NCI_QS_MOD_POST
  AFTER INSERT OR UPDATE OR DELETE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row

BEGIN   

                   
    update NCI_ADMIN_ITEM_REL set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where  C_ITEM_ID=:new.P_ITEM_ID
           AND C_ITEM_VER_NR=:new.P_ITEM_VER_NR ;   

END;
/

--MOD or PROTOCOL UPDATING from, MOD updates ADMIN_Item for MODE 
CREATE OR REPLACE TRIGGER TRG_NCI_MOD_PROT_POST
  AFTER INSERT OR UPDATE OR DELETE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN

IF :new.REL_TYP_ID =60 then
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID 
    where ITEM_ID = :new.C_item_id and VER_NR = :new.C_ITEM_VER_NR ;   

end IF;
IF :new.REL_TYP_ID =61 then
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.P_item_id and VER_NR = :new.P_ITEM_VER_NR;
end IF;

END;
/

