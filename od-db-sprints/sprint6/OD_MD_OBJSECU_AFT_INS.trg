CREATE OR REPLACE TRIGGER ONEDATA_MD.OD_MD_OBJSECU_AFT_INS
AFTER INSERT
   ON ONEDATA_MD.OD_MD_OBJSECU
   FOR EACH ROW
DECLARE
   v_username varchar2(100);
BEGIN

    -- Find username of person performing the INSERT into the table
   SELECT OBJ_NM INTO v_username
   FROM ONEDATA_MD.od_md_OBJ
   WHERE obj_id=:new.OBJ_ID;
   
   -- Insert record into ONEDATA_WA.CNTCT table
   INSERT INTO ONEDATA_WA.CNTCT
   ( CNTCT_ID,
     CNTCT_NM,
     CREAT_USR_ID,
     CNTCT_SECU_ID,
     LST_UPD_USR_ID,
     CREAT_DT,
     LST_UPD_DT )
   VALUES
   ( :new.OBJ_ID,
      v_username,
     :new.CREAT_USR_ID,
     :new.USR_ID,
     :new.LST_UPD_USR_ID,
     :new.CREAT_DT,
     :new.LST_UPD_DT);
     
     INSERT INTO ONEDATA_RA.CNTCT
   ( CNTCT_ID,
     CNTCT_NM,
     CREAT_USR_ID,
     CNTCT_SECU_ID,
     LST_UPD_USR_ID,
     CREAT_DT,
     LST_UPD_DT )
   VALUES
   ( :new.OBJ_ID,
      v_username,
     :new.CREAT_USR_ID,
     :new.USR_ID,
     :new.LST_UPD_USR_ID,
     :new.CREAT_DT,
     :new.LST_UPD_DT);
END;
