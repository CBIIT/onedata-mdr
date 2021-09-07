create or replace procedure            sp_postprocess
as
v_cnt integer;
begin

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

--- Data Element
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY)
select ai.item_id, ai.ver_nr, a.used_by
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct ub.item_id,ub.ver_nr, c.item_nm from vw_nci_used_by ub, vw_cntxt c where ub.cntxt_item_id = c.item_id and ub.cntxt_ver_nr = c.ver_nr and ub.owned_by=0 ) 
GROUP BY item_id, ver_nr) a
where ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+)
and ai.admin_item_typ_id = 4;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_nm, ' ')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), '_')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.admin_item_typ_id in (1,2,3,5,6,7,53);
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, ai.item_long_nm, ai.item_nm, ai.item_desc
from admin_item ai where ai.admin_item_typ_id = 49;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select ai.item_id, ai.ver_nr from  admin_item ai
where ai.admin_item_typ_id in (8,9,50,51,52,54,56);
commit;


update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm) = (select item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and 
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;


insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;

delete from nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;
end;
/

create or replace procedure            sp_revprocess
as
v_cnt integer;
begin

nci_cadsr_push_core.spPushAI(1);

nci_cadsr_push.spPushAIChildren(1);

nci_cadsr_push.spPushAISpecific(1);

raise_application_error(-20000, 'Completed');

end;
/

create or replace procedure            sp_revform
as
v_cnt integer;
begin

nci_cadsr_push_core.spPushAIType(1,54);

nci_cadsr_push_form.PushModule(1);

nci_cadsr_push_form.PushQuestion(1);

nci_cadsr_push_form.PushQuestValidValue(1);

raise_application_error(-20000, 'Completed');

end;
/
