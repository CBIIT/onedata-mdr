create or replace PACKAGE            nci_ds AS
  PROCEDURE            spDSRuleEnum;
  PROCEDURE            spDSRuleNonEnum;
  procedure spDSRun ( v_data_in in clob, v_data_out out clob);
    procedure spDSRunOld ( v_data_in in clob, v_data_out out clob);

  procedure setPrefCDE ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
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

--for cur in (select * from nci_ds_hdr where (hdr_id) not in (select distinct hdr_id from nci_ds_dtl)) loop
--for cur in (select * from nci_ds_hdr where hdr_id = 1037) loop


delete from nci_ds_rslt;

commit;
for cur in (select * from nci_ds_hdr ) loop


insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select cur.hdr_id, de.item_id, de.ver_nr,  1, 100, '1. Preferred Name Exact Match' from   vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18;
commit;

-- Rule id 2:  Entity alternate question text name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  2, 100, '2. Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm)
and
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;



-- Rule id 3:  Entity alternate  name exact match

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr, 3, 100, '3. Alternate Name Exact Match' from alt_nms r, vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc)
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
commit;


-- Rule id 4; Only for non-enumerated, Like
insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, de.item_id, de.ver_nr,  4, 100, '4. Preferred Name Like Match' from vw_de  de where (upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or
upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%')
 and currnt_ver_ind = 1 and de.val_dom_typ_id = 18
 and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;



-- Rule id 5:  Entity alternate question text name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  5, 100, '5. Question Text Like Match' from ref r, obj_key ok, vw_de de
where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%') and
r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18;
commit;


-- Rule id 6:  Entity alternate  name like match for non-enumerated

insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
select distinct cur.hdr_id, r.item_id, r.ver_nr,  6, 100, '6. Alternate Name Like Match' from alt_nms r, vw_de de
where (upper(r.nm_desc) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' ||  upper(r.nm_desc) || '%')
and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
and (cur.hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
commit;

end loop;


END;

procedure spDSRun ( v_data_in in clob, v_data_out out clob)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

    delete from nci_ds_rslt_dtl;
    commit;
    
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
         v_flt_str := '1=1';
   
     if (ihook.getColumnValue(row_ori, 'USR_CMNTS') is not null) then -- Context restriction
     v_cntxt_str := upper(trim(ihook.getColumnValue(row_ori, 'USR_CMNTS')));
     v_cnt := nci_11179.getwordcount(v_cntxt_str);
     v_flt_str := ' de.cntxt_nm_dn in (';
     for i in 1..v_cnt loop
        if (i = v_cnt) then
        v_flt_str := v_flt_str || '''' || nci_11179.getWord(v_cntxt_str, i, v_cnt) || ''')';
        else
             v_flt_str := v_flt_str || '''' || nci_11179.getWord(v_cntxt_str, i, v_cnt) || ''',';
      end if;   
     end loop;
     end if;
        select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
        
        if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if; -- enumerated or non-enumerated 18 - non-enumerated
        delete from nci_ds_rslt where hdr_id = v_hdr_id;
        commit;

        if (v_temp = 0) then        -- Non enumerated section
            for cur in (select * from nci_ds_hdr where hdr_id = v_hdr_id ) loop
           select '''' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '''' into v_entty_nm from dual;
              select '''%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%''' into v_entty_nm_like from dual;
          
                  v_sql := 'insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc) select ' ||  v_hdr_id || ', de.item_id, de.ver_nr,  1, 100, ''Preferred Name Exact Match'' from 
                  vw_de de where ' ||v_entty_nm || ' = upper(de.item_nm)    and currnt_ver_ind = 1                     and de.val_dom_typ_id = 18 and ' || v_flt_str ;
                     execute immediate v_sql;
                   --insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc) select v_hdr_id, de.item_id, de.ver_nr,  1, 100, 'Preferred Name Exact Match' from 
               --   vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)     and currnt_ver_ind = 1                     and de.val_dom_typ_id = v_val_dom_typ;
                 --    exec immediate v_sql;
                    commit;
                    
                    -- Rule id 2:  Entity alternate question text name exact match
                    
                 
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr,  2, 100, ''Question Text Exact Match'' from ref r, obj_key ok, vw_de de 
                    where ' || v_entty_nm || ' = upper(r.ref_nm)
                    and r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)
                    and de.val_dom_typ_id = 18 and ' || v_flt_str;
                      execute immediate v_sql;
                  
                    commit;
        
                    
                    
                    -- Rule id 3:  Entity alternate  name exact match
                    
                     v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr, 3, 100, ''Alternate Name Exact Match'' from alt_nms r, vw_de de
                    where ' || v_entty_nm || ' = upper(r.nm_desc)
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                    and (' || v_hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt) and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
                    
                    
            -- Non enumerated only
            
           -- Rule id 4; Only for non-enumerated, Like
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', de.item_id, de.ver_nr,  4, 100, ''Preferred Name Like Match'' from vw_de  de where (upper(de.item_nm) like ' || v_entty_nm_like || ' or '
                     || v_entty_nm || ' like ''% upper(de.item_nm)  %'')
                     and currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                     and (' || v_hdr_id || ') not in (select distinct hdr_id from nci_ds_rslt) and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
        
                
                    -- Rule id 5:  Entity alternate question text name like match for non-enumerated
                    
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr,  5, 100, ''Question Text Like Match'' from ref r, obj_key ok, vw_de de
                    where (upper(r.ref_nm) like ' || v_entty_nm_like || '  
                    or ' || v_entty_nm || '  like ''% upper(r.ref_nm) %'') and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and r.ref_nm != ''%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (' || v_hdr_id || ') not in (select distinct hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18 and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
                                
                    -- Rule id 6:  Entity alternate  name like match for non-enumerated
                    
                    v_sql := ' insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct ' ||  v_hdr_id || ', r.item_id, r.ver_nr,  6, 100, ''Alternate Name Like Match'' from alt_nms r, vw_de de
                    where (upper(r.nm_desc) like ' || v_entty_nm_like || ' or ' || v_entty_nm || '  like ''% ||  upper(r.nm_desc) || %'')
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                    and (' || v_hdr_id || ') not in (select distinct hdr_id from nci_ds_rslt) and ' || v_flt_str;
                     execute immediate v_sql;
                    commit;
        end loop;
    end if;


    if (v_temp > 0) then -- Enumerated Section

    for cur in (select h.* from nci_ds_hdr h where h.hdr_id = v_hdr_id ) loop
             select '''' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '''' into v_entty_nm from dual;
                select '''%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%''' into v_entty_nm_like from dual;
      
        -- nci_ds_rslt_dlt holds the first level run of name matches.
        
        -- Rule id 1:  Entity preferred name exact match
        delete from nci_ds_rslt_dtl where hdr_id = v_hdr_id;
        commit;

        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc) select ' ||
        cur.hdr_id || ', de.item_id, de.ver_nr, ''NA'', 1, 100, ''Preferred Name Exact Match'' from   vw_de de where ' || v_entty_nm || '  = upper(de.item_nm)
         and currnt_ver_ind = 1 and de.val_dom_typ_id = 17 and ' || v_flt_str;
      --   raise_application_error(-20000, v_sql);
          execute immediate v_sql;
        --commit;
        
        -- Rule id 2:  Entity alternate question text name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || cur.hdr_id || ', r.item_id, r.ver_nr, ''NA'', 2, 100, ''Question Text Exact Match'' from ref r, obj_key ok, vw_de de  where ' || v_entty_nm || '  = upper(r.ref_nm)         and
        r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like ''%QUESTION%'' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
        and (' || cur.hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
         execute immediate v_sql;
        --commit;
        
        
        -- Rule id 3:  Entity alternate  name exact match
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct ' || cur.hdr_id || ', r.item_id, r.ver_nr, ''NA'', 3, 100, ''Alternate Name Exact Match'' from alt_nms r, vw_de de  where 
       ' || v_entty_nm || '  = upper(r.nm_desc)
        and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
        and (' || cur.hdr_id || ',r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and ' || v_flt_str;
         execute immediate v_sql;
        --commit;
        
        -- Rule id 4; Only for enumerated, Like
        v_sql := ' insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select ' ||  cur.hdr_id || ' , de.item_id, de.ver_nr, ''NA'', 4, 100, ''Preferred Name Like Match'' from vw_de  de where  upper(de.item_nm) 
        like ' || v_entty_nm_like ||
         ' and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
        and (' || cur.hdr_id || ' , de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17 and ' || v_flt_str;
         execute immediate v_sql;
        commit;
        end loop;


-- Second level run for PV comparisons
for cur in (select hdr_id,count(*) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr having count(*) = cur.cnt;
--commit;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id,
de_ver_nr having count(*) = cur.cnt;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) >= cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)
from vw_nci_de_pv_lean v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;
commit;
     end loop; 
end if;
  update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id),
  NUM_PV = v_temp
  where hdr_id = v_hdr_id;
  update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
  where hdr_id = v_hdr_id;
  
  end loop;
  commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     
END;


procedure spDSRunOld ( v_data_in in clob, v_data_out out clob)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);

begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   -- raise_application_error(-20000,v_user_id);

    delete from nci_ds_rslt_dtl;
    commit;
    v_flt_str := '1=1';
    
    rows := t_rows();
    for i in 1..hookinput.originalrowset.rowset.count loop  --- Iterate through all the selected rows
        row_ori := hookInput.originalRowset.rowset(i);
        v_hdr_id := ihook.getColumnValue(row_ori, 'HDR_ID');
        
        select count(*) into v_temp from nci_ds_dtl where hdr_id = v_hdr_id;
        
        if (v_temp = 0) then v_val_dom_typ := 18 ; else v_val_dom_typ := 17; end if; -- enumerated or non-enumerated 18 - non-enumerated
        delete from nci_ds_rslt where hdr_id = v_hdr_id;
        commit;

        if (v_temp = 0) then        -- Non enumerated section
            for cur in (select * from nci_ds_hdr where hdr_id = v_hdr_id ) loop
               
                   insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc) select v_hdr_id, de.item_id, de.ver_nr,  1, 100, 'Preferred Name Exact Match' from 
                  vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)     and currnt_ver_ind = 1                     and de.val_dom_typ_id = v_val_dom_typ;
                   commit;
                    
                    -- Rule id 2:  Entity alternate question text name exact match
                    
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct v_hdr_id, r.item_id, r.ver_nr,  2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm)
                    and r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (v_hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt)
                    and de.val_dom_typ_id = v_val_dom_typ;
                    
                   
                    commit;
        
                    
                    
                    -- Rule id 3:  Entity alternate  name exact match
                    
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct v_hdr_id, r.item_id, r.ver_nr, 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc)
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = v_val_dom_typ
                    and (v_hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt);
                    commit;
                    
                    
            -- Non enumerated only
            
           -- Rule id 4; Only for non-enumerated, Like
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct v_hdr_id, de.item_id, de.ver_nr,  4, 100, 'Preferred Name Like Match' from vw_de  de where (upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or
                    upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(de.item_nm) || '%')
                     and currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                     and (v_hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
                    commit;
        
                
                    -- Rule id 5:  Entity alternate question text name like match for non-enumerated
                    
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr,  rule_id, score, rule_desc)
                    select distinct v_hdr_id, r.item_id, r.ver_nr,  5, 100, 'Question Text Like Match' from ref r, obj_key ok, vw_de de
                    where (upper(r.ref_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' || upper(r.ref_nm) || '%') and
                    r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and r.ref_nm != '%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
                    and (v_hdr_id) not in (select distinct hdr_id from nci_ds_rslt) and de.val_dom_typ_id = 18;
                    commit;
                                
                    -- Rule id 6:  Entity alternate  name like match for non-enumerated
                    
                    insert into nci_ds_rslt (hdr_id, item_id, ver_nr, rule_id, score, rule_desc)
                    select distinct v_hdr_id, r.item_id, r.ver_nr,  6, 100, 'Alternate Name Like Match' from alt_nms r, vw_de de
                    where (upper(r.nm_desc) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm)) || '%' or upper(nvl(cur.entty_nm_usr, cur.entty_nm)) like '%' ||  upper(r.nm_desc) || '%')
                    and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 18
                    and (v_hdr_id) not in (select distinct hdr_id from nci_ds_rslt);
                    commit;
        end loop;
    end if;


    if (v_temp > 0) then -- Enumerated Section

    for cur in (select h.* from nci_ds_hdr h where h.hdr_id = v_hdr_id ) loop
        
        -- nci_ds_rslt_dlt holds the first level run of name matches.
        
        -- Rule id 1:  Entity preferred name exact match
        delete from nci_ds_rslt_dtl where hdr_id = v_hdr_id;
        commit;

        insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 1, 100, 'Preferred Name Exact Match' from   vw_de de where  upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(de.item_nm)
         and currnt_ver_ind = 1 and de.val_dom_typ_id = 17;
        --commit;
        
        -- Rule id 2:  Entity alternate question text name exact match
        insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 2, 100, 'Question Text Exact Match' from ref r, obj_key ok, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.ref_nm)
         and
        r.ref_typ_id = ok.obj_key_id and upper(obj_key_desc) like '%QUESTION%' and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1
        and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17;
        --commit;
        
        
        -- Rule id 3:  Entity alternate  name exact match
        insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select distinct cur.hdr_id, r.item_id, r.ver_nr, 'NA', 3, 100, 'Alternate Name Exact Match' from alt_nms r, vw_de de  where upper(nvl(cur.entty_nm_usr, cur.entty_nm)) = upper(r.nm_desc)
        and de.item_id = r.item_id and de.ver_nr = r.ver_nr and de.currnt_ver_ind = 1 and de.val_dom_typ_id = 17
        and (cur.hdr_id,r.item_id, r.ver_nr) not in (select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl);
        --commit;
        
        -- Rule id 4; Only for enumerated, Like
        insert into nci_ds_rslt_dtl (hdr_id, item_id, ver_nr, perm_val_nm, rule_id, score, rule_desc)
        select cur.hdr_id, de.item_id, de.ver_nr, 'NA', 4, 100, 'Preferred Name Like Match' from vw_de  de where  upper(de.item_nm) like '%' || upper(nvl(cur.entty_nm_usr, cur.entty_nm))|| '%'
         and currnt_ver_ind = 1 and de.val_dom_typ_id = 17
        and (cur.hdr_id, de.item_id, de.ver_nr) not in (select  hdr_id, item_id, ver_nr from nci_ds_rslt_dtl) and de.val_dom_typ_id = 17;
        commit;
        end loop;


-- Second level run for PV comparisons
for cur in (select hdr_id,count(*) cnt from nci_ds_dtl d where hdr_id = v_hdr_id  group by hdr_id) loop

insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and v.de_ver_NR = ai.VER_NR
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
group by de_item_id,  de_ver_nr having count(*) = cur.cnt;
--commit;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id,
de_ver_nr having count(*) = cur.cnt;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr,cur.cnt, count(*)  from vw_nci_de_pv_lean v, admin_item ai
where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(v.perm_val_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) >= cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;

if  (sql%rowcount = 0) then
insert into nci_ds_rslt ( HDR_ID,ITEM_ID,VER_NR, NUM_PV_IN_SRC, NUM_PV_MTCH)
select distinct cur.hdr_id, de_item_id item_id, de_ver_nr ver_nr, cur.cnt, count(*)
from vw_nci_de_pv_lean v, admin_item ai where nvl(ai.currnt_ver_ind,0) = 1 and v.de_item_id = ai.item_id and
v.de_ver_NR = ai.VER_NR and upper(V.ITEM_nm) in (select upper(perm_val_nm) from nci_ds_dtl where hdr_id =cur.hdr_id)
and (cur.hdr_id, de_item_id, de_ver_nr) in (Select hdr_id, item_id, ver_nr from nci_ds_rslt_dtl where hdr_id = cur.hdr_id)
group by de_item_id, de_ver_nr having count(*) > cur.cnt*0.5;
--AND CUR.HDR_ID NOT IN (SELECT HDR_ID FROM NCI_DS_RSLT);
--commit;
end if;
commit;
     end loop; 
end if;
  update nci_ds_hdr set NUM_CDE_MTCH = (select count(*) from nci_ds_rslt where hdr_id = v_hdr_id),
  NUM_PV = v_temp
  where hdr_id = v_hdr_id;
  update nci_ds_rslt r set NUM_PV_IN_CDE = (select count(*) from vw_nci_de_pv_lean where de_item_id = r.item_id and de_ver_nr = r.ver_nr)
  where hdr_id = v_hdr_id;
  
  end loop;
  commit;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     
END;

 procedure setPrefCDE ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
AS
hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

 row_ori :=  hookInput.originalRowset.rowset(1);
 rows := t_rows();
row := t_row();
 
            ihook.setColumnValue(row, 'HDR_ID', ihook.getColumnValue(row_ori, 'HDR_ID'));
            ihook.setColumnValue(row, 'CDE_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_ID'));
            ihook.setColumnValue(row, 'CDE_VER_NR', ihook.getColumnValue(row_ori, 'VER_NR'));
            rows:= t_rows();
            rows.extend;
            rows(rows.last) := row;

            action             := t_actionrowset(rows, 'DS Entity To Match', 2, 0,'update');
            actions.extend;
            actions(actions.last) := action;


    hookoutput.actions    := actions;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

 
END;
/
