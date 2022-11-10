
alter table admin_item disable all triggers;

update admin_item set MTCH_TERM = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\|',''),
MTCH_TERM_ADV = regexp_replace(upper(item_nm),'\(|\)|\;|\-|\_|\|','');
commit;

alter table admin_item enable all triggers;


alter table alt_nms disable all triggers;

update alt_nms set MTCH_TERM = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\|',''),
MTCH_TERM_ADV = regexp_replace(upper(nm_desc),'\(|\)|\;|\-|\_|\|','');
commit;

alter table alt_nms enable all triggers;


alter table ref disable all triggers;

update ref set MTCH_TERM = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\|',''),
MTCH_TERM_ADV = regexp_replace(upper(ref_desc),'\(|\)|\;|\-|\_|\|','');
commit;

alter table ref enable all triggers;

