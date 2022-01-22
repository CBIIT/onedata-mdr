set serveroutput on size 1000000
SPOOL S22_RA_LOAD_CONCEPTS.log
set timing on
--insert concepts from ONEDATA_WA to ONEDATA_RA
insert into onedata_ra.admin_item ra select * from onedata_wa.admin_item wa
where wa.admin_item_typ_id = 49
and creat_usr_id = 'ONEDATA' and lst_upd_usr_id = 'ONEDATA'
and (wa.item_id, wa.ver_nr) not in (select item_id, ver_nr from onedata_ra.admin_item);
commit;
-- remove all alt names synonyms loaded by ONEDATA
delete from alt_nms where creat_usr_id = 'ONEDATA' and lst_upd_usr_id = 'ONEDATA'
and NM_TYP_ID = 1064;
commit;
--insert alt names synonyms to ONEDATA_RA from ONEDATA_WA loaded by ONEDATA
insert into onedata_ra.alt_nms 
select * from onedata_wa.alt_nms where creat_usr_id = 'ONEDATA' and lst_upd_usr_id = 'ONEDATA' and nm_typ_id = 1064
and (item_id, ver_nr) not in (select item_id, ver_nr from onedata_ra.alt_nms);
commit;
begin
dbms_output.put_line('ONEDATA_RA load concepts is completed');
end;
/
SPOOL OFF
