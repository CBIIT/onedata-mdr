# Create the following objects and jobs on ONEDATA_WA
AI_INPUT_TAB-Init.sql  
ONEDATA_MIGRATION_ERROR.sql  
ONEDATA_WA.VALIDATE_DATA_MIGRATION.sql  
ONEDATA_WA.VALIDATE_DATA_MIGRATION_STEPS.sql  

# Compile the following procedures on ONEDATA_WA
ONEDATA_WA.SAG_AI_VALIDATION.prc  
ONEDATA_WA.SAG_FK_VALIDATE.prc  
ONEDATA_WA.SAG_ITEM_VALIDATION.prc  
ONEDATA_WA.SAG_MIGR_VAL_LOV_FULL.prc  

# execute the scheduled job VALIDATE_DATA_MIGRATION on ONEDATA_WA to start the validation process. This can be done though the Toad/SQL Developer or following procedure.
DBMS_SCHEDULER.RUN_JOB ('VALIDATE_DATA_MIGRATION')  

# Validation
Once the job is complete, check the errors in ONEDATA_MIGRATION_ERROR.
Test  
Based on the error, run the queries from the Migration_Validation_Results.sql file to identify the difference.  

# SAG_AI_VALIDATION procedure
procedure validates the following items in ADMIN_ITEM table.  
 1 - CONCEPTUAL DOMAIN  
 2 - DATA ELEMENT CONCEPT  
 3 - VALUE DOMAIN  
 4 - DATA ELEMENT  
 5 - OBJECT CLASS  
 6 - PROPERTY  
 7 - REPRESENTATION CLASS  
 8 - CONTEXT  
 9 - CLASSIFICATION SCHEME  
 49 - CONCEPT  
 50 - PROTOCOL  
 51 - CLASSIFICATION SCHEME ITEM  
 52 - MODULE  
 53 - VALUE MEANING  
 54 - FORM  
 56 – OCRECS  
 ## execute 
SAG_AI_VALIDATION  
