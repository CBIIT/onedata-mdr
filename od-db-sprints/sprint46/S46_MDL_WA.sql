insert into cntct (cntct_nm, cntct_secu_id) values ('Load Job Administrator','ONEDATA_WA');
commit;
CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT_SEQ  BEFORE INSERT  on NCI_MDL_ELMNT
  for each row
         BEGIN    IF (:NEW.ITEM_ID<= 0  or :NEW.ITEM_ID is null)  THEN
         select od_seq_ADMIN_ITEM.nextval
    into :new.ITEM_ID  from  dual ;
end if;
if (:new.ver_nr is null) then
:new.ver_nr := 1;
end if;

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

   CREATE SEQUENCE NCI_SEQ_MECM  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1;
   CREATE SEQUENCE NCI_SEQ_MECVM  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1;

   CREATE SEQUENCE NCI_SEQ_MER  MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1;

CREATE OR REPLACE TRIGGER TR_NCI_MDL_ELMNT_CHAR_SEQ  BEFORE INSERT  on NCI_MDL_ELMNT_CHAR
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


CREATE OR REPLACE TRIGGER TR_NCI_MEC_VAL_MAP  BEFORE INSERT  on NCI_MEC_VAL_MAP
  for each row
         BEGIN    IF (:NEW.MECVM_ID<= 0  or :NEW.MECVM_ID is null)  THEN
         select NCI_SEQ_MECVM.nextval
    into :new.MECVM_ID  from  dual ;

END IF;

END ;
/
create or replace TRIGGER TR_NCI_MEC_VAL_MAP_TS
  BEFORE  UPDATE
  on NCI_MEC_VAL_MAP
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/



CREATE OR REPLACE TRIGGER TR_NCI_MEC_MAP_SEQ  BEFORE INSERT  on NCI_MEC_MAP
  for each row
         BEGIN    IF (:NEW.MECM_ID<= 0  or :NEW.MECM_ID is null)  THEN
         select NCI_SEQ_MECM.nextval
    into :new.MECM_ID  from  dual ;
END IF;

END ;
/
create or replace TRIGGER TR_NCI_MEC_MAP
  BEFORE  UPDATE
  on NCI_MEC_MAP
  for each row
BEGIN
   :new.LST_UPD_DT := SYSDATE;
 
END;
/
insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Standard',40,'Standard','Standard','Standard' );


insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('UML',40,'UML','UML','UML' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Table',41,'Table','Table','Table' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Class',41,'Class','Class','Class' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Subclass',41,'Subclass','Subclass','Subclass' );

insert into obj_key ( OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Is Child of',42,'Is Child of','Is Child of','Is Child of' );
commit;



create index idxAIMtchTermAdvType on ADMIN_ITEM (admin_item_typ_id, MTCH_TERM_ADV);




