CREATE OR REPLACE PROCEDURE ONEDATA_MD.CNTCT_USRID_SYNC_WARA
/*Date      Version     Description                                                 Created By
12/10/2020  1.0         The procedure was created as part of DSRMWS-608 to sync     Akhilesh Trikha
                        user ids that are in MD schema but not in WA/RA schema.
*/
AS
BEGIN

--Insert user ids in WA schema
    FOR x IN (SELECT USR_ID
                FROM ONEDATA_MD.OD_MD_OBJSECU a
                WHERE upper(usr_id) not like '%DELETED%'
              MINUS
              SELECT CNTCT_SECU_ID FROM ONEDATA_WA.CNTCT)
    LOOP
        INSERT INTO ONEDATA_WA.CNTCT (CNTCT_ID,
                                      CNTCT_NM,
                                      CREAT_USR_ID,
                                      CNTCT_SECU_ID,
                                      LST_UPD_USR_ID,
                                      CREAT_DT,
                                      LST_UPD_DT)
            SELECT a.OBJ_ID,
                   b.OBJ_NM,
                   a.CREAT_USR_ID,
                   a.USR_ID,
                   a.LST_UPD_USR_ID,
                   a.CREAT_DT,
                   a.LST_UPD_DT
              FROM ONEDATA_MD.OD_MD_OBJSECU a, ONEDATA_MD.od_md_OBJ b
             WHERE a.obj_id = b.OBJ_ID AND USR_ID = x.usr_id;

        COMMIT;
    END LOOP;

--Insert user ids in RA schema    
    FOR x IN (SELECT USR_ID
                FROM ONEDATA_MD.OD_MD_OBJSECU a
                WHERE upper(usr_id) not like '%DELETED%'
              MINUS
              SELECT CNTCT_SECU_ID FROM ONEDATA_RA.CNTCT)
    LOOP
        INSERT INTO ONEDATA_RA.CNTCT (CNTCT_ID,
                                      CNTCT_NM,
                                      CREAT_USR_ID,
                                      CNTCT_SECU_ID,
                                      LST_UPD_USR_ID,
                                      CREAT_DT,
                                      LST_UPD_DT)
            SELECT a.OBJ_ID,
                   b.OBJ_NM,
                   a.CREAT_USR_ID,
                   a.USR_ID,
                   a.LST_UPD_USR_ID,
                   a.CREAT_DT,
                   a.LST_UPD_DT
              FROM ONEDATA_MD.OD_MD_OBJSECU a, ONEDATA_MD.od_md_OBJ b
             WHERE a.obj_id = b.OBJ_ID AND USR_ID = x.usr_id;

        COMMIT;
    END LOOP;
END;
/
