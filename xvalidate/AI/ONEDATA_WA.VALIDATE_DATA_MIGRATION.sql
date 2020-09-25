BEGIN
  SYS.DBMS_SCHEDULER.DROP_JOB
    (job_name  => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION');
END;
/

BEGIN
  SYS.DBMS_SCHEDULER.CREATE_JOB
    (
       job_name        => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
      ,start_date      => NULL
      ,repeat_interval => NULL
      ,end_date        => NULL
      ,program_name    => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION_STEPS'
      ,comments        => 'Execute Validate_Data_Migration_steps'
    );
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'RESTARTABLE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'LOGGING_LEVEL'
     ,value     => SYS.DBMS_SCHEDULER.LOGGING_OFF);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'MAX_FAILURES');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'MAX_RUNS');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'STOP_ON_WINDOW_CLOSE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'JOB_PRIORITY'
     ,value     => 3);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE_NULL
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'SCHEDULE_LIMIT');
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'AUTO_DROP'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'RESTART_ON_RECOVERY'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'RESTART_ON_FAILURE'
     ,value     => FALSE);
  SYS.DBMS_SCHEDULER.SET_ATTRIBUTE
    ( name      => 'ONEDATA_WA.VALIDATE_DATA_MIGRATION'
     ,attribute => 'STORE_OUTPUT'
     ,value     => TRUE);
END;
/
