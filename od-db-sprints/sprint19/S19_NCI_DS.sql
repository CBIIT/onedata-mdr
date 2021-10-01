create or replace PACKAGE            nci_ds AS
  PROCEDURE            spDSRuleEnum;
  PROCEDURE            spDSRuleNonEnum;
END;
/
create or replace PACKAGE BODY            nci_ds AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';

PROCEDURE            spDSRuleEnum
AS
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_entity      varchar2(255);
BEGIN



--delete from ncI_ds_rslt_dtl;
--commit;
delete from nci_ds_rslt;
commit;



--- Enumerated section

/*


for cur in (select * from nci_ds_hdr where (hdr_id)  in (select distinct hdr_id from nci_ds_dtl)) loop
-- Rule id 1:  Entity preferred name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 1, 100, 'Preferred Name Exact Match' from   vw_de de where  upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17;
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm)
 and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;



-- Rule id 3:  Entity alternate  name exact match

insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc) 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_detl);
commit;


-- Rule id 4; Only for enumerated, Like 
insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 4, 100, 'Preferred Name Like Match' from vw_de  de where  upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm))|| '%'  
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;

*/

/*

-- Rule id 4; Only for enumerated, Like 
insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 4, 100, 'Preferred Name Like Match' from vw_de  de where   
 upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%'
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;
/*

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 5, 100, 'Question Text Like Match' from ref r, obj_key ok, vw_de de  where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm))|| '%'  
or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%')  and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;



-- Rule id 6:  Entity alternate  name like match for non-enumerated

insert into nci_ds_rslt_detl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 6, 100, 'Alternate Name Like Match' from alt_nms r, vw_de de  where upper(cur.entty_nm) like  '%' || upper(r.nm_desc) || '%' 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_detl) and de.val_dom_typ_id = 17;
commit;
*/

--end loop;




for cur in (select hdr_id,count(*) cnt from nci_ds_dtl group by hdr_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR 
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr having count(*) = cur.cnt;
commit;

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai 
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;


insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, de_ver_nr having count(*) >= cur.cnt*0.5
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  
from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) 
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id) 
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
commit;

/*
insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);

commit;

insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;

/*
insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) >= cur.cnt*0.75
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;

insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) = cur.cnt*0.75
AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSULT);
commit;
/* insert into nci_ds_rsult ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv where upper(item_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id = cur.hdr_id) group by de_item_id, 
de_ver_nr having count(*) >= cur.cnt/2
and ( de_item_id, de_ver_nr) not in (select  item_id,ver_nr from nci_ds_rsult where hdr_id = cur.hdr_id);
*/

commit;


end loop;


END;

PROCEDURE            spDSRuleNonEnum
AS
    v_temp           INT;
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_entity      varchar2(255);
BEGIN


--- Non enumerated section

-- Rule id 1:  Entity preferred name exact match

for cur in (select * from nci_ds_hdr where (hdr_id) not in (select distinct hdr_id from nci_ds_dtl)) loop
--for cur in (select * from nci_ds_hdr where hdr_id = 1037) loop
insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr,  1, 100, 'Preferred Name Exact Match' from   vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18;
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm) 
and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;



-- Rule id 3:  Entity alternate  name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc) 
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
commit;


-- Rule id 4; Only for non-enumerated, Like 
insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, de.item_id, de.ver_nr,  4, 100, 'Preferred Name Like Match' from vw_de  de where (upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or
upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%')
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18
 and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;



-- Rule id 5:  Entity alternate question text name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  5, 100, 'Question Text Like Match' from ref r, obj_key ok, vw_de de 
where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%') and 
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;


-- Rule id 6:  Entity alternate  name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  6, 100, 'Alternate Name Like Match' from alt_nms r, vw_de de  
where (upper(r.nm_desc) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' ||  upper(r.nm_desc) || '%')
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;

end loop;


END;

END;
/
