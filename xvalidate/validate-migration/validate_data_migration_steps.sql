BEGIN
  SYS.DBMS_SCHEDULER.CREATE_PROGRAM
    (
      program_name         => 'VALIDATE_DATA_MIGRATION_STEPS'
     ,program_type         => 'PLSQL_BLOCK'
     ,program_action       => 'Begin
DELETE FROM ONEDATA_MIGRATION_ERROR;
COMMIT;
SAG_AI_VALIDATION;
SAG_FK_VALIDATE;
SAG_ITEM_VALIDATION;
SAG_MIGR_VAL_LOV_FULL;
END;
'
     ,number_of_arguments  => 0
     ,enabled              => FALSE
     ,comments             => 'Execute the following
DELET FROM ONEDATA_MIGRATION_ERROR'';
SAG_AI_VALIDATION;
SAG_FK_VALIDATE;
SAG_ITEM_VALIDATION;
SAG_MIGR_VAL_LOV_FULL;'
    );

  SYS.DBMS_SCHEDULER.ENABLE
    (name                  => 'VALIDATE_DATA_MIGRATION_STEPS');
END;
/
