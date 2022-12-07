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
                                                 
