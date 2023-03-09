CREATE OR REPLACE FORCE VIEW ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_N
("PreferredName", "Version", "ClassificationList")
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
                                             V1.CSI_IDSEQ,
                                             NULL,
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
                                                              V2.CSI_IDSEQ,
                                                              V1.CS_CSI_IDSEQ,
                                                              v2.P_ITEM_ID,
                                                              v2.P_ITEM_VER_NR,
                                                              v2.LEAF,
                                                              CAST (
                                                                  MULTISET (
                                                                        SELECT v3.CSI_LEVEL,
                                                                               v3.CSI_NAME,
                                                                               v3.CSITL_NAME,
                                                                               v3.CSI_ID,
                                                                               v3.CSI_VERSION,
                                                                               v3.csi_date_created,
                                                                               V3.CSI_IDSEQ,
                                                                               V2.CS_CSI_IDSEQ,
                                                                               v3.P_ITEM_ID,
                                                                               v3.P_ITEM_VER_NR,
                                                                               v3.LEAF,
                                                                               CAST (
                                                                                   MULTISET (
                                                                                         SELECT v4.CSI_LEVEL,
                                                                                                v4.CSI_NAME,
                                                                                                v4.CSITL_NAME,
                                                                                                v4.CSI_ID,
                                                                                                v4.CSI_VERSION,
                                                                                                v4.csi_date_created,
                                                                                                V4.CSI_IDSEQ,
                                                                                                V3.CS_CSI_IDSEQ,
                                                                                                v4.P_ITEM_ID,
                                                                                                v4.P_ITEM_VER_NR,
                                                                                                v4.LEAF,
                                                                                                CAST (
                                                                                                    MULTISET (
                                                                                                          SELECT v5.CSI_LEVEL,
                                                                                                                 v5.CSI_NAME,
                                                                                                                 v5.CSITL_NAME,
                                                                                                                 v5.CSI_ID,
                                                                                                                 v5.CSI_VERSION,
                                                                                                                 v5.csi_date_created,
                                                                                                                 V5.CSI_IDSEQ,
                                                                                                                 V4.CS_CSI_IDSEQ,
                                                                                                                 v5.P_ITEM_ID,
                                                                                                                 v5.P_ITEM_VER_NR,
                                                                                                                 v5.LEAF
                                                                                                            FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
                                                                                                                 v5
                                                                                                           --   ,(select* from  ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                                           WHERE     v5.P_ITEM_VER_NR =
                                                                                                                     v4.CSI_VERSION
                                                                                                                 AND v5.P_ITEM_ID =
                                                                                                                     v4.CSI_ID
                                                                                                                 AND v5.CSI_LEVEL =
                                                                                                                     5
                                                                                                                 AND V5.CS_IDSEQ =
                                                                                                                     CL.CS_IDSEQ
                                                                                                        ORDER BY v5.CSI_ID)
                                                                                                        AS ONEDATA_WA.MDSR759_XML_CSI_LIST5_T)
                                                                                                    "level5"
                                                                                           FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
                                                                                                V4
                                                                                          --   ,(select* from  ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW  where CSI_LEVEL=4)v4
                                                                                          WHERE     v4.P_ITEM_VER_NR =
                                                                                                    v3.CSI_VERSION
                                                                                                AND v4.P_ITEM_ID =
                                                                                                    v3.CSI_ID
                                                                                                AND v4.CSI_LEVEL =
                                                                                                    4
                                                                                                AND V4.CS_IDSEQ =
                                                                                                    CL.CS_IDSEQ
                                                                                       ORDER BY v4.CSI_ID)
                                                                                       AS ONEDATA_WA.MDSR759_XML_CSI_LIST4_T)
                                                                                   "level4"
                                                                          FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
                                                                               V3
                                                                         WHERE     v3.P_ITEM_VER_NR =
                                                                                   v2.CSI_VERSION
                                                                               AND v3.P_ITEM_ID =
                                                                                   v2.CSI_ID
                                                                               AND v3.CSI_LEVEL =
                                                                                   3
                                                                               AND V3.CS_IDSEQ =
                                                                                   V2.CS_IDSEQ
                                                                      ORDER BY v3.CSI_ID)
                                                                      AS ONEDATA_WA.MDSR759_XML_CSI_LIST3_T)
                                                                  "level3"
                                                         FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
                                                              V2
                                                        WHERE     v2.P_ITEM_VER_NR =
                                                                  v1.CSI_VERSION
                                                              AND v2.P_ITEM_ID =
                                                                  v1.CSI_ID
                                                              AND v2.CSI_LEVEL =
                                                                  2
                                                              AND V2.CS_IDSEQ =
                                                                  V1.CS_IDSEQ
                                                     ORDER BY v2.CSI_ID)
                                                     AS ONEDATA_WA.MDSR759_XML_CSI_LIST2_T)    "level2"
                                        FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW V1
                                       WHERE     v1.CS_IDSEQ =
                                                 cl.CS_IDSEQ
                                             AND CSI_LEVEL = 1
                                    ORDER BY v1.CSI_ID)
                                    AS ONEDATA_WA.MDSR759_XML_CSI_LIST1_T)    "ClassificationItemList"
                       FROM (SELECT DISTINCT CS_IDSEQ,
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
                               FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW) cl
                      WHERE     cl.CS_CONTEXT_ID = con.CS_CONTEXT_ID
                            AND cl.CS_CONTEXT_VERSION = con.CS_CONTEXT_VERSION
                   ORDER BY CS_ID)
                   AS ONEDATA_WA.MDSR759_XML_CS_L5_LIST_T)    "ClassificationList"
      FROM (  SELECT DISTINCT
                     CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CS_CONTEXT_ID
                FROM ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW 
            ORDER BY CS_CONTEXT_NAME) con;
			
GRANT SELECT ON ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_N TO ONEDATA_RA;

GRANT SELECT ON ONEDATA_WA.MDSR444XML_5CSI_LEVEL_VIEW_N TO ONEDATA_RO;



