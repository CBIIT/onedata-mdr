CREATE OR REPLACE TRIGGER TRG_NCI_QVV_POST
  AFTER INSERT OR UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
  DECLARE
  V_item_id   ADMIN_ITEM.ITEM_ID%TYPE;
  V_VER_NR   ADMIN_ITEM.VER_NR%TYPE;
BEGIN   
select distinct  module.P_ITEM_ID,module.P_ITEM_VER_NR into V_item_id ,  V_VER_NR
    from 
           NCI_ADMIN_ITEM_REL          MODULE,
           NCI_ADMIN_ITEM_REL_ALT_KEY  QUESTION
           where 
           QUESTION.P_ITEM_ID = module.C_ITEM_ID
           AND QUESTION.P_ITEM_VER_NR = module.C_ITEM_VER_NR
           AND QUESTION.NCI_PUB_ID=:NEW.Q_PUB_ID
           AND QUESTION.NCI_VER_NR= :NEW.Q_VER_NR;
                      
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where ITEM_ID = V_item_id and VER_NR = V_VER_NR;
 
           
END;

CREATE OR REPLACE TRIGGER TRG_NCI_AI_POST
  AFTER INSERT OR UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
IF :new.REL_TYP_ID in (60,61) then
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.P_item_id and VER_NR = :new.P_ITEM_VER_NR;
end IF;
END;

CREATE OR REPLACE TRIGGER TRG_NCI_MOD_POST
  AFTER INSERT OR UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
DECLARE
  V_item_id   ADMIN_ITEM.ITEM_ID%TYPE;
  V_VER_NR   ADMIN_ITEM.VER_NR%TYPE;
BEGIN   
select distinct  module.P_ITEM_ID,module.P_ITEM_VER_NR into V_item_id ,  V_VER_NR
    from 
           NCI_ADMIN_ITEM_REL          MODULE,
           NCI_ADMIN_ITEM_REL_ALT_KEY  QUESTION
           where 
           QUESTION.P_ITEM_ID = module.C_ITEM_ID
           AND QUESTION.P_ITEM_VER_NR = module.C_ITEM_VER_NR
           AND QUESTION.NCI_PUB_ID=:NEW.NCI_PUB_ID
           AND QUESTION.NCI_VER_NR= :NEW.NCI_VER_NR;
                      
    update NCI_FORM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID     
    where ITEM_ID = V_item_id and VER_NR = V_VER_NR;
    update ADMIN_ITEM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID 
    where ITEM_ID = V_item_id and VER_NR = V_VER_NR;


END;

CREATE OR REPLACE TRIGGER TRG_NCI_FORM_POST
  AFTER  UPDATE
  on NCI_FORM
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = :new.LST_UPD_DT, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
END;