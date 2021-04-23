CREATE OR REPLACE TRIGGER ONEDATA_WA.TR_AI_WFS
  BEFORE UPDATE or INSERT ON ONEDATA_WA.ADMIN_ITEM
  FOR EACH ROW
  when ( -- WFS is like retired requires End Date
  (new.ADMIN_STUS_ID <> old.ADMIN_STUS_ID and (new.ADMIN_STUS_ID > 70 and new.ADMIN_STUS_ID < 82)) and --WFS is changed to like Retired
  	--new End Date is null and old was null - error
   ((new.UNTL_DT is null and old.UNTL_DT is null) or
   	--new End Date is null and old was not null - error
    (new.UNTL_DT is null and old.UNTL_DT is not null))
    or --WFS was like Retired and is not changed, End Date shall not be removed
  ((new.ADMIN_STUS_ID = old.ADMIN_STUS_ID) and (old.ADMIN_STUS_ID > 70 and old.ADMIN_STUS_ID < 82) and (new.UNTL_DT is null and old.UNTL_DT is not null)))
BEGIN
RAISE_APPLICATION_ERROR( -20001, 
'!!!! The item is not saved. This Workflow Status requires "Effective End Date" value to be set !!!!');
END TR_AI_WFS;
/