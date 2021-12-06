set serveroutput on size 1000000
SPOOL S22_LOAD_CONCEPTS.log
update SAG_LOAD_CONCEPTS_EVS set con_idseq = null where con_idseq is not null;
commit;
--load concepts
set timing on
exec SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG;
begin
dbms_output.put_line('SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG is completed');
end;
/
--insert concepts from ONEDATA_WA to ONEDATA_RA
insert into onedata_ra.admin_item ra select * from onedata_wa.admin_item wa
where wa.admin_item_typ_id = 49
and creat_usr_id = 'ONEDATA' and lst_upd_usr_id = 'ONEDATA'
and (wa.item_id, wa.ver_nr) not in (select item_id, ver_nr from onedata_ra.admin_item);
commit;
--insert concepts synonyms to ONEDATA_RA
insert into onedata_ra.alt_nms 
select * from onedata_wa.alt_nms where creat_usr_id = 'ONEDATA' and lst_upd_usr_id = 'ONEDATA' and nm_typ_id = 1064
and (item_id, ver_nr) not in (select item_id, ver_nr from onedata_ra.alt_nms);
commit;
SPOOL OFF
