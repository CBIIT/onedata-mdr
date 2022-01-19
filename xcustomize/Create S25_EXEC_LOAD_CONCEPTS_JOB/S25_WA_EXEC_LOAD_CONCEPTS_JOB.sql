CREATE OR REPLACE PROCEDURE EXEC_LOAD_CONCEPTS AS 
BEGIN

SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG;
DBMS_MVIEW.REFRESH('VW_CNCPT'); 

END;

BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'ONEDATA_WA.EXEC_LOAD_CONCEPTS_JOB_WA',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'EXEC_LOAD_CONCEPTS',
   start_date         =>  '22-OCT-22 10.00.00 PM',
   repeat_interval    =>  'FREQ=DAILY',
   enabled            =>   TRUE);
END;