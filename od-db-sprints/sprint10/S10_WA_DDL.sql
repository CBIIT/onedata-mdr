create or replace TRIGGER TR_AI_EXT_TAB_INS
  AFTER INSERT
  on ADMIN_ITEM
  for each row
BEGIN

if (:new.admin_item_typ_id not in (5,6,7)) then
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select :new.ITEM_ID, :new.VER_NR from dual;
end if;
END;

                                   
 create or replace TRIGGER OD_TR_ADMIN_ITEM  BEFORE INSERT ON ADMIN_ITEM for each row
BEGIN    IF (:NEW.ITEM_ID = -1  or :NEW.ITEM_ID is null)  THEN select od_seq_ADMIN_ITEM.nextval
 into :new.ITEM_ID  from  dual ;   END IF;
if (:new.nci_idseq is null) then 
 :new.nci_idseq := nci_11179.cmr_guid();
end if; 
if (:new.admin_item_typ_id  in (4,3,2,1,54) and :new.ver_nr = 1 and :new.admin_stus_id is null) then -- draft new
:new.admin_stus_id := 66;
end if;
--if (:new.admin_item_typ_id  in (4,3,2) and :new.ver_nr = 1 and :new.regstr_stus_id is null) then -- default new reg status Application
--:new.regstr_stus_id := 9; -- not sure if rules are changed
--end if;
 -- Tracker 806
if (:new.regstr_stus_id is null) then -- default new reg status Application
:new.regstr_stus_id := 9; -- not sure if rules are changed
end if;
                                   
if (:new.admin_item_typ_id  in (4,3,2,1) and :new.ver_nr > 1) then -- draft mod
:new.admin_stus_id := 65;
end if;
if (:new.admin_item_typ_id  in (5,6,49,53,7)) then -- Released
:new.admin_stus_id := 75;
end if;
if (:new.admin_item_typ_id  in (49) and :new.cntxt_item_id is null) then -- Set the default context for concept if empty
 :new.cntxt_item_id := 20000000024;
 :new.cntxt_ver_nr := 1;
end if;
if (:new.admin_item_typ_id  in (5,6)) then -- Set the default context
 :new.cntxt_item_id := 20000000024;
:new.cntxt_ver_nr := 1;
end if;
if (:new.ITEM_LONG_NM is null) then
if instr(to_char(:new.ver_nr),'.')=0 then
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || :new.ver_nr||'.0';
else
:new.ITEM_LONG_NM := :new.ITEM_ID || 'v' || :new.ver_nr;
end if;
end if;
:new.creat_usr_id_x := :new.creat_usr_id;
:new.lst_upd_usr_id_x := :new.lst_upd_usr_id;
if (:new.lst_upd_dt is null) then
:new.lst_upd_dt := sysdate;
end if; 
END ;
                                /
                                
                                   
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
FROM (select distinct ub.item_id,ub.ver_nr, c.item_nm from vw_nci_used_by ub, vw_cntxt c where ub.cntxt_item_id = c.item_id and ub.cntxt_ver_nr = c.ver_nr ) 
GROUP BY item_id, ver_nr) a
where ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+)
and ai.admin_item_typ_id = 4;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, '_')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
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
