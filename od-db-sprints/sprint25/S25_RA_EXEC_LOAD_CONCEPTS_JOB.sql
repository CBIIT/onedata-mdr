CREATE OR REPLACE PROCEDURE ONEDATA_RA.EXEC_LOAD_CONCEPTS_RA AS 
BEGIN
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
dbms_output.put_line('ONEDATA_RA load concepts is completed');
DBMS_MVIEW.REFRESH('VW_CNCPT'); 
END;
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'LOAD_CONCEPTS_JOB_RA_S25',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'EXEC_LOAD_CONCEPTS_RA',
   start_date         =>  '22-OCT-22 10.00.00 PM',
   repeat_interval    =>  'FREQ=DAILY',
   enabled            =>   TRUE);
END;
/