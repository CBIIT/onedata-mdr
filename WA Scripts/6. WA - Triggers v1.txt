 CREATE SEQUENCE OD_SEQ_ALT_DEF
          INCREMENT BY 1
          START WITH 1000
         ;
         
    CREATE OR REPLACE TRIGGER OD_TR_ALT_DEF  BEFORE INSERT  on ALT_DEF  for each row
         BEGIN    IF (:NEW.DEF_ID<= 0  or :NEW.DEF_ID is null)  THEN 
         select od_seq_ALT_DEF.nextval
    into :new.DEF_ID  from  dual ;   END IF; END ;
/

 CREATE OR REPLACE TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT  on ADMIN_ITEM  for each row
     BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; END ;
/


    CREATE OR REPLACE TRIGGER OD_TR_QUEST_VV  BEFORE INSERT  on NCI_QUEST_VALID_VALUE
  for each row
         BEGIN    IF (:NEW.NCI_PUB_ID<= 0  or :NEW.NCI_PUB_ID is null)  THEN 
         select od_seq_ADMIN_ITEM.nextval
    into :new.NCI_PUB_ID  from  dual ;   END IF; END ;
/

CREATE SEQUENCE NCI_SEQ_INSTR 
 INCREMENT BY 1 
 START WITH 1000 
;
/

drop sequence od_seq_ADMIN_ITEM;

create sequence od_seq_ADMIN_ITEM
increment by 1
start with 8000000;
/


-- Trigger change for ADMIN_ITEM for Public ID

create or replace TRIGGER TR_INSTR  BEFORE INSERT  on NCI_INSTR  for each row
     BEGIN    IF (:NEW.INSTR_ID<= 0  or :NEW.INSTR_ID is null)  THEN select NCI_seq_INSTR.nextval
 into :new.INSTR_ID  from  dual ; END IF;
END ;
/


 CREATE SEQUENCE SEQ_CNCPT_AI
          INCREMENT BY 1
          START WITH 1000
         ;

    CREATE OR REPLACE TRIGGER OD_TR_CNCPT_AI_ID  BEFORE INSERT  on CNCPT_ADMIN_ITEM
  for each row
         BEGIN    IF (:NEW.CNCPT_AI_ID<= 0  or :NEW.CNCPT_AI_ID is null)  THEN 
         select   seq_cncpt_ai.nextval
    into :new.CNCPT_AI_ID  from  dual ;   END IF; END ;
/

    CREATE OR REPLACE TRIGGER OD_TR_ALT_KEY  BEFORE INSERT  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
         BEGIN    IF (:NEW.NCI_PUB_ID<= 0  or :NEW.NCI_PUB_ID is null)  THEN 
         select od_seq_ADMIN_ITEM.nextval
    into :new.NCI_PUB_ID  from  dual ;   END IF; END ;
/


 CREATE SEQUENCE SEQ_QUEST_VV_REP
          INCREMENT BY 1
          START WITH 1000
         ;


    CREATE OR REPLACE TRIGGER TR_STG_QUEST_VV_REP  BEFORE INSERT  on NCI_QUEST_VV_REP
  for each row
         BEGIN    IF (:NEW.QUEST_VV_REP_ID<= 0  or :NEW.QUEST_VV_REP_ID is null)  THEN 
         select seq_QUEST_VV_REP.nextval
    into :new.QUEST_VV_REP_ID  from  dual ;   END IF; END ;
/

 CREATE SEQUENCE SEQ_TA
          INCREMENT BY 1
          START WITH 1000
         ;


    CREATE OR REPLACE TRIGGER TR_STG_TA  BEFORE INSERT  on NCI_FORM_TA
  for each row
         BEGIN    IF (:NEW.TA_ID<= 0  or :NEW.TA_ID is null)  THEN 
         select seq_TA.nextval
    into :new.TA_ID  from  dual ;   END IF; END ;
/



 CREATE SEQUENCE OD_SEQ_STG_AI
          INCREMENT BY 1
          START WITH 1000
         ;


    CREATE OR REPLACE TRIGGER OD_TR_STG_AI  BEFORE INSERT  on NCI_STG_ADMIN_ITEM
  for each row
         BEGIN    IF (:NEW.STG_AI_ID<= 0  or :NEW.STG_AI_ID is null)  THEN 
         select od_seq_STG_AI.nextval
    into :new.STG_AI_ID  from  dual ;   END IF; END ;
/

    CREATE OR REPLACE TRIGGER OD_TR_STG_AI_CNCPT  BEFORE INSERT  on NCI_STG_AI_CNCPT
  for each row
         BEGIN    IF (:NEW.STG_AI_CNCPT_ID<= 0  or :NEW.STG_AI_CNCPT_ID is null)  THEN 
         select od_seq_STG_AI.nextval
    into :new.STG_AI_CNCPT_ID  from  dual ;   END IF; END ;
/

create trigger TR_CONC_DOM_VAL_MEAN_AUD_TS
  BEFORE INSERT or UPDATE
  on CONC_DOM_VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_CSI_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_CLSFCTN_SCHM_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create trigger TR_NCI_VAL_MEAN_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_VAL_MEAN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create trigger TR_NCI_PROTCL_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_FORM_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_FORM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_TEMPLATE_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_PROTCL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_STG_AI_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_STG_ADMIN_ITEM
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_STG_AI_CNCPT_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_STG_AI_CNCPT
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_STG_AI_NM_TS
  BEFORE INSERT
  on NCI_STG_ADMIN_ITEM
  for each row
BEGIN
  :new.CTL_USR_ID := :new.CREAT_USR_ID;
END;
/

create trigger TR_NCI_ADMIN_ITEM_REL_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_ADMIN_ITEM_REL_AK_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ADMIN_ITEM_REL_ALT_KEY
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_AK_ADMIN_ITEM_REL_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_ALT_KEY_ADMIN_ITEM_REL
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_QUEST_VV_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VALID_VALUE
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_CSI_ALT_DEFNMS_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_CSI_ALT_DEFNMS
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create trigger TR_NCI_INSTR_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_INSTR
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/



create trigger TR_NCI_QUEST_VV_REP_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_QUEST_VV_REP
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/


create trigger TR_NCI_FORM_TA_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_FORM_TA
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create trigger TR_NCI_USR_CART_AUD_TS
  BEFORE INSERT or UPDATE
  on NCI_USR_CART
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
END;
/

create or replace trigger TR_NCI_REF
  BEFORE INSERT 
  on REF
  for each row
BEGIN
  if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/




create or replace trigger TR_NCI_ALT_DEF
  BEFORE INSERT 
  on ALT_DEF
  for each row
BEGIN
  if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/


create or replace trigger TR_NCI_AI_REL_ALT_KEY
  BEFORE INSERT 
  on ALT_DEF
  for each row
BEGIN
  if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/

create or replace trigger TR_NCI_ALT_NMS
  BEFORE INSERT  on ALT_NMS
  for each row
BEGIN
   if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
END;
/

create or replace trigger TR_NCI_PERM_VAL
  BEFORE INSERT  on PERM_VAL
  for each row
BEGIN
   if (:new.NCI_IDSEQ is null) then
 :new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
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

if ( t_change(indx).REGSTR_STUS_ID <> t_change(indx).OLD_REGSTR_STUS_ID) then
select STUS_NM into s_REGSTR_STUS_NM_DN from STUS_MSTR where stus_typ_id = 1 and stus_id = t_change(indx).REGSTR_STUS_ID;
update ADMIN_ITEM set REGSTR_STUS_NM_DN = s_REGSTR_STUS_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;

if ( t_change(indx).ADMIN_STUS_ID <> t_change(indx).OLD_ADMIN_STUS_ID) then
select STUS_NM into s_ADMIN_STUS_NM_DN from STUS_MSTR where stus_typ_id = 2 and stus_id = t_change(indx).ADMIN_STUS_ID;
update ADMIN_ITEM set ADMIN_STUS_NM_DN = s_ADMIN_STUS_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;


if ( t_change(indx).CNTXT_ITEM_ID <> t_change(indx).OLD_CNTXT_ITEM_ID) then
select ITEM_NM into s_CNTXT_NM_DN from ADMIN_ITEM where ITEM_ID= t_change(indx).CNTXT_ITEM_ID;
update ADMIN_ITEM set CNTXT_NM_DN = s_CNTXT_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;

if ( t_change(indx).ORIGIN_ID <> t_change(indx).OLD_ORIGIN_ID) then
select OBJ_KEY_DESC into s_ORIGIN_ID_DN from OBJ_KEY where obj_key_id = t_change(indx).ORIGIN_ID;
update ADMIN_ITEM set ORIGIN_ID_DN = s_ORIGIN_ID_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end loop;
END AFTER STATEMENT;

END;
/


create or replace trigger TR_NCI_ALT_NMS_DENORM_INS
  for  insert or update   on ALT_NMS
compound trigger
TYPE r_change_row is RECORD (
  item_id   ADMIN_ITEM.ITEM_ID%TYPE,
  VER_NR   ADMIN_ITEM.VER_NR%TYPE,
  CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE,
  OLD_CNTXT_ITEM_ID  ADMIN_ITEM.CNTXT_ITEM_ID%TYPE
);

TYPE t_change_row is TABLE of r_change_row
INDEX by PLS_INTEGER;

t_change t_change_row;

AFTER EACH ROW IS
BEGIN
  t_change(t_change.count+1).ITEM_ID := :new.ITEM_ID;
  t_change(t_change.count).VER_NR := :new.VER_NR;
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
update ALT_NMS set CNTXT_NM_DN = s_CNTXT_NM_DN where ITEM_ID = t_change(indx).item_id
and ver_nr = t_change(indx).ver_nr;
end if;
end loop;
END AFTER STATEMENT;

END;
/







