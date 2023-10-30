create or replace TRIGGER TR_AI_MTCH
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
  BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s','');


END;
/

alter table admin_item disable all triggers;
alter table alt_nms disable all triggers;

set escape on

update admin_item set 
MTCH_TERM_ADV = regexp_replace(upper(item_nm),'[^A-Za-z0-9]', ''),
 MTCH_TERM= regexp_replace(upper(item_nm),'[^A-Za-z0-9]', '');
commit;



update alt_nms set 
MTCH_TERM_ADV = regexp_replace(upper(nm_desc),'[^A-Za-z0-9]', ''),
 MTCH_TERM= regexp_replace(upper(nm_Desc),'[^A-Za-z0-9]', '');
commit;
alter table admin_item enable all triggers;
alter table alt_nms enable all triggers;

create or replace TRIGGER TR_AI_MTCH
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
  BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'[^A-Za-z0-9]','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'[^A-Za-z0-9]','');


END;
/
