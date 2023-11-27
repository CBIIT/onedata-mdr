--jira 3015
insert into obj_key (obj_key_desc, obj_typ_id, obj_key_def) values ('NIH CDE Submission Template', 31, 'NIH CDE Submission Template');
commit;


insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values (125,'NCIT-External Concept Relationship',39,'NCIT-External Concept Relationship' );
commit;

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) select 'ICD-O_CODE',23,'ICD-O_CODE'  from dual where ('ICD-O_CODE') not in 
(Select  upper(obj_key_desc) from obj_key where obj_typ_id = 23) ;
commit;

create or replace TRIGGER TR_ADMIN_ITEM_REL_FOR_CONCAT
  before INSERT 
  on
NCI_ADMIN_ITEM_REL
  for each row
BEGIN

     :new.P_ITEM_ID_VER := :new.P_ITEM_ID || 'v'|| :new.P_ITEM_VER_NR;
     :new.C_ITEM_ID_VER := :new.C_ITEM_ID || 'v' || :new.C_ITEM_VER_NR;

END;
/
