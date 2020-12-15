set serveroutput on size 1000000
SPOOL DSRMWS-302.log

declare 
errmsg varchar2(1000);
errcode varchar2(20);
begin

delete from NCI_AI_TYP_VALID_STUS;
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, obj_key_id, e.DATE_CREATED,e.CREATED_BY,NVL(e.DATE_MODIFIED,e.DATE_CREATED),NVL(e.MODIFIED_BY,e.CREATED_BY)
from sbrext.ASL_ACTL_EXT e, stus_mstr s, obj_key o
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and o.nci_cd = e.ACTL_NAME and o.obj_typ_id = 4;

insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 53, e.DATE_CREATED,e.CREATED_BY,NVL(e.DATE_MODIFIED,e.DATE_CREATED),NVL(e.MODIFIED_BY,e.CREATED_BY)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'VALUE_MEANING';


--Form
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 54, e.DATE_CREATED,e.CREATED_BY,NVL(e.DATE_MODIFIED,e.DATE_CREATED),NVL(e.MODIFIED_BY,e.CREATED_BY)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';


--Module
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 52, e.DATE_CREATED,e.CREATED_BY,NVL(e.DATE_MODIFIED,e.DATE_CREATED),NVL(e.MODIFIED_BY,e.CREATED_BY)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';
commit;

EXCEPTION
  WHEN OTHERS THEN
 dbms_output.put_line('An error was encountered: '||SQLCODE||' - '||SQLERRM);


rollback;
end;

SPOOL OFF