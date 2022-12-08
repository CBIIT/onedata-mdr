CREATE OR REPLACE TRIGGER OD_TR_FORM_IMPORT_AUD
BEFORE INSERT OR UPDATE ON NCI_STG_FORM_IMPORT
for each row
BEGIN
:new.LST_UPD_DT_CHAR := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
:new.LST_UPD_DT := sysdate;
END;
/


alter table admin_item disable all triggers;

update admin_item set MTCH_TERM = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table admin_item enable all triggers;


alter table alt_nms disable all triggers;

update alt_nms set MTCH_TERM = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table alt_nms enable all triggers;


alter table ref disable all triggers;

update ref set MTCH_TERM = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}',''),
MTCH_TERM_ADV = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
commit;

alter table ref enable all triggers;
                                                 
                                                 
create or replace TRIGGER TR_AI_MTCH
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
  BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');


END;
/


CREATE OR REPLACE TRIGGER TR_ALT_NMS_BEFORE
  BEFORE INSERT OR UPDATE
  on ALT_NMS
  for each row
BEGIN
   
:new.MTCH_TERM := regexp_replace(upper(:new.nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.nm_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');  
END;
/

CREATE OR REPLACE TRIGGER TR_REF_BEFORE
  BEFORE INSERT OR UPDATE
  on REF
  for each row
BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.ref_desc),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');  
END;
/
                                                 

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('I',36,'Insert','Insert','I' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('U',36,'Update','Update','U' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('D',36,'Delete','Delete','D' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('M',36,'Manual Delete','Manual Delete','M' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('R',36,'Restore','Restore','R' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('P',36,'Purge','Purge','P' );
commit;

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form-Protocol',37,'Form-Protocol','Form-Protocol','Form-Protocol' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Classifications',37,'Classifications','Classifications','Classifications' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Definitions',37,'Alternate Definitions','Alternate Definitions','Alternate Definitions' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form Question',37,'Form Question','Form Question','Form Question' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form-Module',37,'Form-Module','Form-Module','Form-Module' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Form Question Valid Values',37,'Form Question Valid Values',
                                                                                           'Form Question Valid Values','Form Question Valid Values' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Administered Item',37,'Administered Item','Administered Item','Administered Item' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Designations',37,'Alternate Designations',
                                                                                           'Alternate Designations','Alternate Designations' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Reference Documents',37,'Reference Documents',
                                                                                           'Reference Documents','Reference Documents' );

insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Classifications',38,'Classifications','Classifications','Classifications' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Definitions',38,'Alternate Definitions','Alternate Definitions','Alternate Definitions' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Administered Item',38,'Administered Item','Administered Item','Administered Item' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Alternate Designations',38,'Alternate Designations',
                                                                                           'Alternate Designations','Alternate Designations' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Reference Documents',38,'Reference Documents',
                                                                                           'Reference Documents','Reference Documents' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Concept Relationship',38,'Concept Relationship',
                                                                                           'Concept Relationship','Concept Relationship' );
insert into obj_key (OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values ('Permissible Value',38,'Permissible Value',
                                                                                           'Permissible Value','Permissible Value' );


commit;

