

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Person',49,'Person' );
commit;
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Provider',49,'Provider' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Procedure',49,'Procedure' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Observation',49,'Observation' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Diagnosis',49,'Diagnosis' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Specimen',49,'Specimen' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Healthcare Facility Site',49,'Healthcare Facility Site' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Medication',49,'Medication' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Note',49,'Note' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Visit',49,'Visit' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Test Results',49,'Test Results' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Vital Signs',49,'Vital Signs' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Enrollment',49,'Enrollment' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values ('Death',49,'Death' );
commit;


create or replace TRIGGER TR_AI_EXT_TAB_INS
  AFTER INSERT
  on ADMIN_ITEM
  for each row
BEGIN

if (:new.admin_item_typ_id not in (5,6,7,49, 53)) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;

if (:new.admin_item_typ_id =49) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,   CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select :new.ITEM_ID, :new.VER_NR, :new.item_long_nm, :new.item_nm, :new.item_desc from dual;
end if;

if (:new.admin_item_typ_id =52) then
insert into NCI_MODULE (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;

END;
/


create or replace    TRIGGER TR_NCI_MDL_MAP_NM
  AFTER INSERT
  on NCI_MDL_MAP
  for each row
BEGIN
   update ADMIN_ITEM set ITEM_NM_CURATED = (Select s.item_nm || 'v' || :new.src_mdl_ver_nr || ' mapped to ' || t.item_nm || 'v' || :new.tgt_mdl_ver_nr
   from admin_item s, admin_item t where s.item_id = :new.src_mdl_item_id and s.ver_nr = :new.src_mdl_ver_nr and t.item_id = :new.tgt_mdl_item_id and t.ver_nr = :new.tgt_mdl_ver_nr)
   where item_id = :new.item_id and ver_nr = :new.ver_nr;
  -- commit;
END;
/

update ADMIN_ITEM set ITEM_NM_CURATED = (Select s.item_nm || 'v' || s.ver_nr || ' mapped to ' || t.item_nm || 'v' || t.ver_nr
   from admin_item s, admin_item t, nci_mdl_map m where s.item_id = m.src_mdl_item_id and s.ver_nr = m.src_mdl_ver_nr and t.item_id = m.tgt_mdl_item_id 
   and t.ver_nr = m.tgt_mdl_ver_nr and m.item_id = admin_item.item_id and m.ver_nr = admin_item.ver_nr)
   where admin_item_typ_id = 58
   commit;


CREATE OR REPLACE TRIGGER NCI_TR_ENTTY_PRSN  BEFORE INSERT  on NCI_PRSN  for each row
     BEGIN    IF (:NEW.ENTTY_ID = -1  or :NEW.ENTTY_ID is null)  THEN select nci_seq_ENTTY.nextval
 into :new.ENTTY_ID  from  dual ;   END IF;
insert into nci_entty(entty_id, entty_typ_id) values (:new.entty_id, 73);
:new.PRSN_FULL_NM_DERV := :new.FIRST_NM || ' ' || :new.LAST_NM;
end;
/

CREATE OR REPLACE TRIGGER TR_NCI_PRSN_AUD_TS
  BEFORE  UPDATE
  on NCI_PRSN
  for each row
BEGIN
  :new.LST_UPD_DT := SYSDATE;
:new.PRSN_FULL_NM_DERV := :new.FIRST_NM || ' ' || :new.LAST_NM;
END;
/

alter table NCI_PRSN disable all triggers;
update NCI_PRSN set PRSN_FULL_NM_DERV = FIRST_NM || ' ' || LAST_NM;
commit;
alter table NCI_PRSN enable all triggers;

