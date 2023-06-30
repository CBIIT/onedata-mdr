CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT  BEFORE INSERT  on NCI_MDL_ELMNT
  for each row
         BEGIN    IF (:NEW.ITEM_ID<= 0  or :NEW.ITEM_ID is null)  THEN
         select od_seq_ADMIN_ITEM.nextval
    into :new.ITEM_ID  from  dual ;
:new.ver_nr := 1;

END IF;

END ;
/
create or replace TRIGGER TR_NCI_MDL_ELMNT
  BEFORE  UPDATE
  on NCI_MDL_ELMNT
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/


   CREATE SEQUENCE NCI_SEQ_MEC  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1;

   CREATE SEQUENCE NCI_SEQ_MER  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1;

CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT_CHAR  BEFORE INSERT  on NCI_MDL_ELMNT_CHAR
  for each row
         BEGIN    IF (:NEW.MEC_ID<= 0  or :NEW.MEC_ID is null)  THEN
         select NCI_SEQ_MEC.nextval
    into :new.MEC_ID  from  dual ;
END IF;

END ;
/
create or replace TRIGGER TR_NCI_MDL_ELMNT_CHAR
  BEFORE  UPDATE
  on NCI_MDL_ELMNT_CHAR
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/


CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT_REL  BEFORE INSERT  on NCI_MDL_ELMNT_REL
  for each row
         BEGIN    IF (:NEW.REL_ID<= 0  or :NEW.REL_ID is null)  THEN
         select NCI_SEQ_MER.nextval
    into :new.REL_ID  from  dual ;

END IF;

END ;
/
create or replace TRIGGER TR_NCI_MDL_ELMNT_REL
  BEFORE  UPDATE
  on NCI_MDL_ELMNT_REL
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/



insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Standard',40,'Standard','Standard','Standard' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Table',41,'Table','Table','Table' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Class',41,'Class','Class','Class' );
commit;






