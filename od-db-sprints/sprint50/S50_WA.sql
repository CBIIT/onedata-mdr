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

alter table admin_item enable all triggers;
alter table alt_nms enable all triggers;

