BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'CS_CSI_XML444_GENER_JOB',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'CSCSI_XML444_GENER',
   start_date         =>  '24-OCT-22 10.00.00 PM',
   repeat_interval    =>  'FREQ=DAILY',
   enabled            =>   TRUE);
END;

/