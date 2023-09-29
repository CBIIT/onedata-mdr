

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

alter table NCI_ADMIN_ITEM_EXT NOLOGGING;

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
