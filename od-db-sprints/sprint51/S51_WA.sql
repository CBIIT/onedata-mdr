set escape off;
--jira 3015
insert into obj_key (obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (223, 'NIH CDE Submission Template', 31, 'NIH CDE Submission Template');
commit;


insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values (125,'NCIT-External Concept Relationship',39,'NCIT-External Concept Relationship' );
commit;

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) select 'ICD-O_CODE',23,'ICD-O_CODE'  from dual where ('ICD-O_CODE') not in 
(Select  upper(obj_key_desc) from obj_key where obj_typ_id = 23) ;
commit;

CREATE OR REPLACE TRIGGER OD_TR_NCI_STG_MEC_MAP_UPD 
BEFORE UPDATE ON NCI_STG_MEC_MAP
for each row
BEGIN
  :new.DT_SORT := systimestamp();
  :new.lst_upd_dt := sysdate();
END;
/
