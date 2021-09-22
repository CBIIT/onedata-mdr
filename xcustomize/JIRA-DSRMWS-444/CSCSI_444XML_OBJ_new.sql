
/* Formatted on 9/22/2021 9:12:06 AM (QP5 v5.354) */
CREATE OR REPLACE TYPE MDSR759_XML_CSI_L5_T as object(
"CSILevel" number,
 "ClassificationSchemeItemName" VARCHAR2(255),
 "ClassificationSchemeItemType"   VARCHAR2(20),
 "PublicId"        NUMBER,
 "Version"          VARCHAR2(7), 
 "DateCreated"  VARCHAR2(40),
 "CSI_IDSEQ" VARCHAR2(60),
 "ParentIdseq" VARCHAR2(60), 
  --sc_csi_id VARCHAR2(60),
 "ParentPublicID"        NUMBER,
 "ParentVersion"          VARCHAR2(7),
 "AnyChildCSI" VARCHAR2(10))
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_LIST5_T as table of MDSR759_XML_CSI_L5_T
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_L4_T as object(
"CSILevel" number,
 "ClassificationSchemeItemName" VARCHAR2(255),
 "ClassificationSchemeItemType"   VARCHAR2(20),
 "PublicId"        NUMBER,
 "Version"          VARCHAR2(7), 
"DateCreated"  VARCHAR2(40),
 "CSI_IDSEQ" VARCHAR2(60),
 "ParentIdseq" VARCHAR2(60), 
--  sc_csi_id VARCHAR2(60),
 "ParentPublicID"        NUMBER,
 "ParentVersion"          VARCHAR2(7),
 "AnyChildCSI" VARCHAR2(10),
 "ChildCSIList" MDSR759_XML_CSI_LIST5_T) 
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_LIST4_T as table of MDSR759_XML_CSI_L4_T
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_L3_T as object(
"CSILevel" number,
 "ClassificationSchemeItemName" VARCHAR2(255),
 "ClassificationSchemeItemType"   VARCHAR2(20),
 "PublicId"        NUMBER,
 "Version"          VARCHAR2(7), 
"DateCreated"  VARCHAR2(40),
 "CSI_IDSEQ" VARCHAR2(60),
 "ParentIdseq" VARCHAR2(60), 
 -- sc_csi_id VARCHAR2(60),
 "ParentPublicID"        NUMBER,
 "ParentVersion"          VARCHAR2(7),
 "AnyChildCSI" VARCHAR2(10),
 "ChildCSIList" MDSR759_XML_CSI_LIST4_T) 
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_LIST3_T as table of MDSR759_XML_CSI_L3_T
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_L2_T as object(
"CSILevel" number,
 "ClassificationSchemeItemName" VARCHAR2(255),
 "ClassificationSchemeItemType"   VARCHAR2(20),
 "PublicId"        NUMBER,
 "Version"          VARCHAR2(7), 
"DateCreated"  VARCHAR2(40),
 "CSI_IDSEQ" VARCHAR2(60),
 "ParentIdseq" VARCHAR2(60), 
--sc_csi_id VARCHAR2(60),
 "ParentPublicID"        NUMBER,
 "ParentVersion"          VARCHAR2(7),
 "AnyChildCSI" VARCHAR2(10),
 "ChildCSIList" MDSR759_XML_CSI_LIST3_T) 
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_LIST2_T as table of MDSR759_XML_CSI_L2_T
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_L1_T as object(
"CSILevel" number,
 "ClassificationSchemeItemName" VARCHAR2(255),
 "ClassificationSchemeItemType"   VARCHAR2(20),
 "PublicId"        NUMBER,
 "Version"          VARCHAR2(7), 
"DateCreated"  VARCHAR2(40),
 "CSI_IDSEQ" VARCHAR2(60),
 "ParentIdseq" VARCHAR2(60), 
--  sc_csi_id VARCHAR2(60),
 "ParentPublicID"        NUMBER,
 "ParentVersion"          VARCHAR2(7),
 "AnyChildCSI" VARCHAR2(10),
 "ChildCSIList" MDSR759_XML_CSI_LIST2_T) 
/
CREATE OR REPLACE TYPE MDSR759_XML_CSI_LIST1_T as table of MDSR759_XML_CSI_L1_T
/
CREATE OR REPLACE TYPE MDSR759_XML_CS_L5_T as object(
"PublicId"        NUMBER,
"PreferredName" VARCHAR2(60),
"LongName" VARCHAR2(255),
"Version"          VARCHAR2(7),
"DateCreated"  VARCHAR2(40),
"ClassificationItem_LIST"  MDSR759_XML_CSI_LIST1_T)
/
CREATE OR REPLACE TYPE MDSR759_XML_CS_L5_LIST_T  as table of MDSR759_XML_CS_L5_T
/
CREATE OR REPLACE TYPE MDSR759_XML_Context_T1   as object(
"PreferredName" VARCHAR(60),
"Version"          VARCHAR2(7),
--"ContextID" VARCHAR(60),
"ClassificationScheme" MDSR759_XML_CS_L5_LIST_T)
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L5_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST5_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L4_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST4_T TO ONEDATA_RO

/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L3_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST3_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L2_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST2_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L1_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST1_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CS_L5_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CS_L5_LIST_T TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_Context_T1 TO ONEDATA_RO
/

GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L5_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST5_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L4_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST4_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L3_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST3_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L2_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST2_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_L1_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CSI_LIST1_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CS_L5_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_CS_L5_LIST_T TO GUEST
/
GRANT EXECUTE, DEBUG ON MDSR759_XML_Context_T1 TO GUEST
/
CREATE OR REPLACE FORCE VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
(
    CS_ID,
    CS_VERSION,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,
    ASL_NAME,
    CS_CONTEXT_NAME,
    CS_CONTEXT_VERSION,
    CSITL_NAME,
    CSI_ID,
    CSI_VERSION,
    CSI_NAME,
    DESCRIPTION,
    CSI_CONTEXT_NAME,
    CSI_CONTEXT_VERSION,
    CS_DATE_CREATED,
    CSI_DATE_CREATED,
    P_ITEM_ID,
    P_ITEM_VER_NR,
    CSI_LEVEL,
    LEAF,
    CS_IDSEQ,
    CSI_IDSEQ,
    CS_CONTEXT_ID,
    CSI_CONTEXT_ID
)
BEQUEATH DEFINER
AS
        SELECT NODE.CS_ITEM_ID
                   CS_ID,
               NODE.CS_ITEM_VER_NR
                   CS_VERSION,
               CS.ITEM_LONG_NM
                   PREFERRED_NAME,
               CS.ITEM_NM
                   LONG_NAME,
               CS.ITEM_DESC
                   PREFERRED_DEFINITION,
               cs.ADMIN_STUS_NM_DN
                   ASL_NAME,
               CS.CNTXT_NM_DN
                   CS_CONTEXT_NAME,
               CS.CNTXT_VER_NR
                   CS_CONTEXT_VERSION,
               O.NCI_CD
                   CSITL_NAME,
               -- CSI.ITEM_NM,
               CSI.ITEM_ID
                   CSI_ID,
               CSI.VER_NR
                   CSI_VERSION,
               CSI.ITEM_NM
                   CSI_NAME,
               CSI.ITEM_DESC
                   description,
               CSI.CNTXT_NM_DN
                   CSI_CONTEXT_NAME,
               CSI.CNTXT_VER_NR
                   CSI_CONTEXT_VERSION,
               CS.CREAT_DT
                   CS_DATE_CREATED,
               CSI.CREAT_DT
                   CSI_DATE_CREATED,
               NODE.P_ITEM_ID,
               NODE.P_ITEM_VER_NR,
               LEVEL
                   CSI_LEVEL,
               DECODE (CONNECT_BY_ISLEAF,  '1', 'FALSE',  '0', 'TRUE')
                   "IsLeaf",
               CS.NCI_IDSEQ
                   CS_IDSEQ,
               CSI.NCI_IDSEQ
                   CSI_IDSEQ,
               cs.CNTXT_ITEM_ID
                   CS_CONTEXT_ID,
               csi.CNTXT_ITEM_ID
                   CSI_CONTEXT_ID
          FROM admin_item         CS,
               admin_item         CSI,
               NCI_CLSFCTN_SCHM_ITEM NODE,
               OBJ_KEY            O
         WHERE     cs.ADMIN_ITEM_TYP_ID = 9
               AND cs.ADMIN_STUS_NM_DN = 'RELEASED'
               AND csi.ADMIN_ITEM_TYP_ID = 51
               AND node.item_id = csi.item_id
               AND node.ver_nr = csi.ver_nr
               AND node.CSI_TYP_ID = o.obj_key_id
               AND node.cs_item_id = cs.item_id
               AND node.CS_ITEM_VER_NR = cs.ver_nr
               AND INSTR (O.NCI_CD, 'testCaseMix') = 0
               -- AND NODE.ITEM_ID=3070841
               AND CS.CNTXT_NM_DN NOT IN ('TEST', 'Training')
               AND CSI.CNTXT_NM_DN NOT IN ('TEST', 'Training')
    CONNECT BY     PRIOR node.item_id = node.P_ITEM_ID
               AND node.ver_nr = node.P_ITEM_VER_NR
    START WITH node.P_ITEM_ID IS NULL
      ORDER BY CS_ITEM_ID, node.ITEM_ID, P_ITEM_ID;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW
(
    "PreferredName",
    "Version",
    "ClassificationList"
)
BEQUEATH DEFINER
AS
    SELECT CS_CONTEXT_NAME,
           CS_CONTEXT_VERSION,
           CAST (
               MULTISET (
                     SELECT CS_ID,
                            PREFERRED_NAME,
                            LONG_NAME,
                            CS_VERSION,
                            cs_date_created,
                            CAST (
                                MULTISET (
                                      SELECT v1.CSI_LEVEL,
                                             v1.CSI_NAME,
                                             v1.CSITL_NAME,
                                             v1.CSI_ID,
                                             v1.CSI_VERSION,
                                             v1.csi_date_created,
                                             A.NCI_IDSEQ,
                                             NULL,
                                             '',
                                             v1.LEAF,
                                             CAST (
                                                 MULTISET (
                                                       SELECT v2.CSI_LEVEL,
                                                              v2.CSI_NAME,
                                                              v2.CSITL_NAME,
                                                              v2.CSI_ID,
                                                              v2.CSI_VERSION,
                                                              v2.csi_date_created,
                                                              A.NCI_IDSEQ,
                                                              v2.P_ITEM_ID, 
                                                              v2.P_ITEM_VER_NR,
--                                                              v1.CSI_ID,
--                                                              v1.CSI_VERSION,
                                                              v2.LEAF,
                                                              CAST (
                                                                  MULTISET (
                                                                        SELECT v3.CSI_LEVEL,
                                                                               v3.CSI_NAME,
                                                                               v3.CSITL_NAME,
                                                                               v3.CSI_ID,
                                                                               v3.CSI_VERSION,
                                                                               v3.csi_date_created,
                                                                               A.NCI_IDSEQ,
                                                                               v3.P_ITEM_ID,
                                                                               v3.P_ITEM_VER_NR,                       
--                                                                               v2.CSI_ID,
--                                                                               v2.CSI_VERSION,
                                                                               v3.LEAF,
                                                                               CAST (
                                                                                   MULTISET (
                                                                                         SELECT v4.CSI_LEVEL,
                                                                                                v4.CSI_NAME,
                                                                                                v4.CSITL_NAME,
                                                                                                v4.CSI_ID,
                                                                                                v4.CSI_VERSION,
                                                                                                v4.csi_date_created,
                                                                                                A.NCI_IDSEQ,
                                                                                                v4.P_ITEM_ID,
                                                                                                v4.P_ITEM_VER_NR, 
--                                                                                                v3.CSI_ID,
--                                                                                                v3.CSI_VERSION,
                                                                                                v4.LEAF,
                                                                                                CAST (
                                                                                                    MULTISET (
                                                                                                          SELECT v5.CSI_LEVEL,
                                                                                                                 v5.CSI_NAME,
                                                                                                                 v5.CSITL_NAME,
                                                                                                                 v5.CSI_ID,
                                                                                                                 v5.CSI_VERSION,
                                                                                                                 v5.csi_date_created,
                                                                                                                 A.NCI_IDSEQ,
                                                                                                                 v5.P_ITEM_ID,
                                                                                                                 v5.P_ITEM_VER_NR, 
--                                                                                                                 v4.CSI_ID,
--                                                                                                                 v4.CSI_VERSION,
                                                                                                                 v5.LEAF
                                                                                                            FROM REL_CLASS_SCHEME_ITEM_VW
                                                                                                                 v5,
                                                                                                                 ADMIN_ITEM
                                                                                                                 a
                                                                                                           --   ,(select* from  REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                                           WHERE     a.ITEM_ID = v5.CSI_ID
                                                                                                                 AND a.VER_NR = v5.CSI_VERSION
                                                                                                                 AND v5.P_ITEM_VER_NR = v4.CSI_VERSION
                                                                                                                 AND v5.P_ITEM_ID = v4.CSI_ID
                                                                                                                 AND v5.CSI_LEVEL =5
                                                                                                        --   group by csi.CSI_LEVEL,   csi.CSI_ID
                                                                                                        ORDER BY v5.CSI_ID)
                                                                                                        AS MDSR759_XML_CSI_LIST5_T)
                                                                                                    "level5"
                                                                                           FROM REL_CLASS_SCHEME_ITEM_VW
                                                                                                V4,
                                                                                                ADMIN_ITEM
                                                                                                a
                                                                                          --   ,(select* from  REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                          WHERE         a.ITEM_ID = v4.CSI_ID
                                                                                                                 AND a.VER_NR = v4.CSI_VERSION
                                                                                                                 AND v4.P_ITEM_VER_NR = v3.CSI_VERSION
                                                                                                                 AND v4.P_ITEM_ID = v3.CSI_ID
                                                                                                                 AND v4.CSI_LEVEL =4
                                                                                       ORDER BY v4.CSI_ID)
                                                                                       AS MDSR759_XML_CSI_LIST4_T)
                                                                                   "level4"
                                                                          FROM REL_CLASS_SCHEME_ITEM_VW
                                                                               V3,
                                                                               ADMIN_ITEM
                                                                               a
                                                                         --   ,(select* from  REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4--4551586
                                                                             WHERE     a.ITEM_ID = v3.CSI_ID
                                                                                                                 AND a.VER_NR = v3.CSI_VERSION
                                                                                                                 AND v3.P_ITEM_VER_NR = v2.CSI_VERSION
                                                                                                                 AND v3.P_ITEM_ID = v2.CSI_ID
                                                                                                                 AND v3.CSI_LEVEL =3
                                                                      ORDER BY v3.CSI_ID)
                                                                      AS MDSR759_XML_CSI_LIST3_T)
                                                                  "level3"
                                                         FROM REL_CLASS_SCHEME_ITEM_VW
                                                              V2,
                                                              ADMIN_ITEM
                                                              a
                                                        WHERE   a.ITEM_ID = v2.CSI_ID
                                                                                                                 AND a.VER_NR = v2.CSI_VERSION
                                                                                                                 AND v2.P_ITEM_VER_NR = v1.CSI_VERSION
                                                                                                                 AND v2.P_ITEM_ID = v1.CSI_ID
                                                                                                                 AND v2.CSI_LEVEL =2
                                                     ORDER BY v2.CSI_ID)
                                                     AS MDSR759_XML_CSI_LIST2_T)    "level2"
                                        FROM REL_CLASS_SCHEME_ITEM_VW V1,
                                             ADMIN_ITEM            a
                                       WHERE     a.ITEM_ID = v1.CSI_ID
                                             AND a.VER_NR =
                                                 v1.CSI_VERSION
                                             AND v1.CS_ID = cl.CS_ID
                                             AND CSI_LEVEL = 1
                                             AND v1.CS_VERSION =
                                                 cl.CS_VERSION
                                    ORDER BY v1.CSI_ID)
                                    AS MDSR759_XML_CSI_LIST1_T)    "ClassificationItemList"
                       FROM (SELECT DISTINCT a.NCI_IDSEQ     CS_IDSEQ,
                                             CS_ID,
                                             CS_VERSION,
                                             PREFERRED_NAME,
                                             LONG_NAME,
                                             PREFERRED_DEFINITION,
                                             CS_DATE_CREATED,
                                             ASL_NAME,
                                             CS_CONTEXT_NAME,
                                             CS_CONTEXT_VERSION,
                                             CS_CONTEXT_ID
                               FROM REL_CLASS_SCHEME_ITEM_VW v, ADMIN_ITEM a
                              WHERE     a.ITEM_ID = v.CSI_ID
                                    AND v.CS_VERSION = a.VER_NR) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                   ORDER BY CS_ID)
                   AS MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM REL_CLASS_SCHEME_ITEM_VW
            ORDER BY CS_CONTEXT_NAME) con;
CREATE OR REPLACE PROCEDURE CSCSI_XML444_Insert as
/*insert XML*/
P_file number;
l_file_name      VARCHAR2(100);
l_file_path      VARCHAR2(200);
l_result         CLOB:=null;
l_xmldoc          CLOB:=null; 
errmsg VARCHAR2(500):='Non';
  
BEGIN
 
select count(*) into P_file from CSCSI_444_GENERATED_XML;
IF P_file>0 then
 select max(NVL(SEQ_ID,0))+1 into P_file from CSCSI_444_GENERATED_XML;
end if;
        l_file_path := 'SBREXT_DIR';
       
         l_file_name := 'CS_CSI_XML_'||P_file||'.xml';

        SELECT dbms_xmlgen.getxml( 'select* from MDSR444XML_5CSI_LEVEL_VIEW_N')
        INTO l_result
        FROM DUAL ;
        insert into CSCSI_444_GENERATED_XML VALUES ( l_file_name ,l_result,SYSDATE,P_file);      

 commit;
 EXCEPTION
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into MDSR_REPORTS_ERR_LOG VALUES (l_file_name,  errmsg, sysdate);
 commit;

END ;
/
CREATE OR REPLACE PROCEDURE CSCSI_XML444_TRANSFORM IS

P_file number;
l_file_name VARCHAR2(500) ;
 errmsg VARCHAR2(500):='Non';
 
BEGIN
select max(SEQ_ID) into P_file from CSCSI_444_GENERATED_XML;
select FILE_NAME into l_file_name from CSCSI_444_GENERATED_XML where SEQ_ID=P_file;


update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CS_L5_T','ClassificationScheme') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L1_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L2_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L3_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L4_T','CSI') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'MDSR759_XML_CSI_L5_T','CSI') where SEQ_ID=P_FILE;

UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'ROWSET','Classifications' ) where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'</ROW>','</Context>') where SEQ_ID=P_FILE;
update CSCSI_444_GENERATED_XML set text=replace(text,'<ROW>','<Context>') where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ChildCSIList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ChildCSIList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ChildCSIList/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationItem_LIST>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationItem_LIST/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ClassificationItem_LIST>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<ClassificationList/>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'</ClassificationList>'||chr(10)) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'ParentIdseq','ParentChildIdseq' ) where SEQ_ID=P_FILE;
UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'<?xml version="1.0"?>','<?xml version="1.0" encoding="UTF-8"?>') where SEQ_ID=P_FILE;
--UPDATE CSCSI_444_GENERATED_XML set text=replace(text,'2016-08-01 16:20:20',TO_CHAR(SYSDATE,'YYYY-MM-DD')||'T00:00:00.0') where SEQ_ID=P_FILE;
 commit;
 EXCEPTION
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into CSCSI_444_REPORTS_ERR_LOG VALUES (l_file_name,  errmsg, sysdate);
 commit;

END ;
/
CREATE OR REPLACE PROCEDURE ONEDATA_WA.CSCSI_XML444_GENER AS
BEGIN
  delete  from CSCSI_444_GENERATED_XML where CREATED_DATE<SYSDATE-7;
  commit;
  CSCSI_XML444_Insert;
  CSCSI_XML444_TRANSFORM;
END;
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
   job_name           =>  'CSCSI_XML444_GENER_JOB',
   job_type           =>  'STORED_PROCEDURE',
   job_action         =>  'CSCSI_XML444_GENER',
   start_date         =>  '13-SEP-21 10.00.00 PM',
   repeat_interval    =>  'FREQ=DAILY;INTERVAL=7',
   enabled            =>  TRUE);

END;