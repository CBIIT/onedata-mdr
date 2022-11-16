
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

create or replace TRIGGER TR_AI_WFS
  BEFORE UPDATE or INSERT ON ADMIN_ITEM
  FOR EACH ROW
    WHEN ( -- WFS is like retired requires End Date --
  ((DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=1 and (new.ADMIN_STUS_ID > 76 and new.ADMIN_STUS_ID < 82)) and --WFS is changed to like Retired
   (new.UNTL_DT is null)) --new End Date is null error
    or --WFS was like Retired and is not changed, End Date shall not be removed
  (DECODE(new.ADMIN_STUS_ID,old.ADMIN_STUS_ID,0,1)=0 and (old.ADMIN_STUS_ID is not null and old.ADMIN_STUS_ID > 76 and old.ADMIN_STUS_ID < 82) and
  (DECODE(new.UNTL_DT, old.UNTL_DT,0,1)=1 and new.UNTL_DT is null) ---changed End Data to n errorull
  )) BEGIN
RAISE_APPLICATION_ERROR( -20001,
'!!!! The item is not saved. "RETIRED" Workflow Status requires "End Date" value to be set !!!!');

:new.MTCH_TERM := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\|','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\|','');


END TR_AI_WFS;
/


CREATE OR REPLACE TRIGGER TR_ALT_NMS_BEFORE
  BEFORE INSERT OR UPDATE
  on ALT_NMS
  for each row
BEGIN
   
:new.MTCH_TERM := regexp_replace(upper(:new.nm_desc),'\(|\)|\;|\-|\_|\|','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.nm_desc),'\(|\)|\;|\-|\_|\|','');  
END;
/

CREATE OR REPLACE TRIGGER TR_REF_BEFORE
  BEFORE INSERT OR UPDATE
  on REF
  for each row
BEGIN

:new.MTCH_TERM := regexp_replace(upper(:new.ref_desc),'\(|\)|\;|\-|\_|\|','');
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.ref_desc),'\(|\)|\;|\-|\_|\|','');  
END;
/

