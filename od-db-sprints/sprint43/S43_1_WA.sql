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
:new.MTCH_TERM_ADV := regexp_replace(upper(:new.item_nm),'\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}| ','');

END TR_AI_WFS;
