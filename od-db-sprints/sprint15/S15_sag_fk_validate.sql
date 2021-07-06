CREATE OR REPLACE PROCEDURE SAG_FK_VALIDATE AS
--DECLARE
/*****************************************************
        Created By : Akhilesh Trikha
        Created on : 06/30/2020
        Version: 1.0
        Details: Compare Referential Integrity constraints between OneData table and caDSR table.
        Update History:

        *****************************************************/
BEGIN

--Check DATA_ELEMENT_CONCEPT Relationship in DATA_ELEMENTS/DE 
FOR X IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai1.Item_Id,
                ai1.Ver_Nr,
                ai1.NCI_IDSEQ,
                ai1.ITEM_LONG_NM
  FROM sbr.data_elements  dae
       INNER JOIN ADMIN_ITEM ai1 ON ai1.nci_idseq = DEC_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.De_Conc_Item_Id = ai1.Item_Id
                                         AND de.De_Conc_Ver_Nr = ai1.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     X.NCI_iDSEQ,
                     X.Item_Id,
                     X.VER_NR,
                     'DATA_ELEMENT_CONCEPT',
                     X.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;                                                 

--Check VALUE_DOMAIN Relationship in DATA_ELEMENTS/DE                 
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM sbr.data_elements  dae
       INNER JOIN ADMIN_ITEM ai3
           ON     ai3.nci_idseq = VD_IDSEQ
              --and ai1.Nci_Idseq = '99BA9DC8-44D9-4E69-E034-080020C9C0E0'
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN de de
                                      ON     De.Item_Id = ai2.Item_Id
                                         AND De.Ver_Nr = Ai2.Ver_Nr
                                         AND de.VAL_DOM_ITEM_ID = ai3.Item_Id
                                         AND de.VAL_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DE_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VALUE_DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE',
                     '');
        COMMIT;
END LOOP;                                         

--Check CONCEPTUAL DOMAIN relationship in DATA_ELEMENT_CONCEPTS/ DE_CONC  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DATA_ELEMENT_CONCEPTS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN DE_CONC dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.DEC_IDSEQ))
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'DE_CONC',
                     '');
        COMMIT;
END LOOP;  

--Check CONCEPTUAL DOMAIN relationship in VALUE_DOMAINS/ VALUE_DOM  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.VALUE_DOMAINS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CD_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN VALUE_DOM dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CONC_DOM_ITEM_ID = ai3.Item_Id
                                         AND dec.CONC_DOM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.VD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONCEPTUAL DOMAIN',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'VALUE_DOM',
                     '');
        COMMIT;
END LOOP;

--Check TRGT_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = T_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.TRGT_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.TRGT_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'TRGT_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;

--Check SRC_OBJ_CLS relationship in OC_RECS_EXT/ NCI_OC_RECS  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.OC_RECS_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = S_OC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_OC_RECS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.SRC_OBJ_CLS_ITEM_ID = ai3.Item_Id
                                         AND dec.SRC_OBJ_CLS_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.OCR_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'SRC_OBJ_CLS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_OC_RECS',
                     '');
        COMMIT;
END LOOP;    

--Check P_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = P_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.P_ITEM_ID = ai3.Item_Id
                                         AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.C_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'P_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;   

--Check C_DE relationship in COMPLEX_DE_RELATIONSHIPS/ NCI_ADMIN_ITEM_REL  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.COMPLEX_DE_RELATIONSHIPS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = C_DE_IDSEQ --FK 736 360
              WHERE NOT  EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.P_DE_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'C_DE',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;   

--Check CONTE_IDSEQ relationship in DEFINITIONS/ ALT_DEF  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DEFINITIONS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_DEF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_DEF',
                     '');
        COMMIT;
END LOOP;  

--Check CONTE_IDSEQ relationship in DESIGNATIONS/ ALT_NMS  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.DESIGNATIONS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN ALT_NMS dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'ALT_NMS',
                     '');
        COMMIT;
END LOOP;  

--Check CONTE_IDSEQ relationship in REFERENCE_DOCUMENTS/ REF  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.REFERENCE_DOCUMENTS  dae, sbr.Administered_Components  ac, admin_item ai3
           WHERE     ai3.nci_idseq = dae.CONTE_IDSEQ --FK
           AND dae.AC_IDSEQ=ac.AC_IDSEQ
           AND ai3.admin_item_typ_id = 8
           AND PUBLIC_ID>0
              AND NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN REF dec
                                      ON     dec.Item_Id = ai2.Item_Id
                                         AND dec.Ver_Nr = Ai2.Ver_Nr
                                         AND dec.NCI_CNTXT_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_CNTXT_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CONTE_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'REF',
                     '');
        COMMIT;
END LOOP;  

--Check VM_IDSEQ relationship in CD_VMS/ CONC_DOM_VAL_MEAN  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CD_VMS  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = VM_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN CONC_DOM_VAL_MEAN dec
                                      ON     dec.CONC_DOM_ITEM_ID = ai2.Item_Id
                                         AND dec.CONC_DOM_VER_NR = Ai2.Ver_Nr
                                         AND dec.NCI_VAL_MEAN_ITEM_ID = ai3.Item_Id
                                         AND dec.NCI_VAL_MEAN_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.CD_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'VM_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'CONC_DOM_VAL_MEAN',
                     '');
        COMMIT;
END LOOP;  

--Check CSI_IDSEQ relationship in CS_CSI/ NCI_CLSFCTN_SCHM_ITEM  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CSI_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CSI',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CSI',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP; 

--Check AC_IDSEQ relationship in AC_CSI/ NCI_CLSFCTN_SCHM_ITEM  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.CS_CSI   dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = CS_IDSEQ --FK
              WHERE  not EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_CLSFCTN_SCHM_ITEM dec
                                      ON    dec.CS_ITEM_ID = ai2.Item_Id
                                         AND dec.CS_ITEM_VER_NR = ai2.Ver_Nr
                                         AND dae.CS_CSI_IDSEQ = dec.CS_CSI_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'CS_CSI_FOR_CS',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH CS/CSI for CS',
                     SYSDATE,
                     USER,
                     'NCI_CLSFCTN_SCHM_ITEM',
                     '');
        COMMIT;
END LOOP;  
    
--Check AC_IDSEQ relationship in AC_CSI/ NCI_ADMIN_ITEM_REL (REL_TYP_ID/obj_key_id 65 AC>>CSI)  
FOR Y IN (
SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBR.AC_CSI  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = AC_IDSEQ --FK
              WHERE NOT EXISTS
                          (SELECT 1
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.AC_IDSEQ)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'AC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH AC_CSI',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;  

--Sprint 5 Tables 

--Check PROTO_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL

FOR Y IN (SELECT /*+ PARALEL(12)*/
           DISTINCT ai3.Item_Id,
                    ai3.Ver_Nr,
                    ai3.NCI_IDSEQ,
                    ai3.ITEM_LONG_NM
      FROM SBREXT.PROTOCOL_QC_EXT  dae
           INNER JOIN admin_item ai3
               ON     ai3.nci_idseq = proto_idseq --FK 
               AND ai3.admin_item_typ_id = 50
                  WHERE NOT  EXISTS
                              (SELECT *
                                 FROM admin_item  ai2
                                      INNER JOIN NCI_ADMIN_ITEM_REL dec
                                          ON   dec.P_ITEM_ID = ai3.Item_Id
                                             AND dec.P_ITEM_VER_NR = ai3.Ver_Nr
                                             AND ai2.Nci_Idseq = dae.proto_idseq)) --PK
    LOOP
    INSERT INTO ONEDATA_MIGRATION_ERROR
                 VALUES (ERR_SEQ.NEXTVAL,
                         Y.NCI_iDSEQ,
                         Y.Item_Id,
                         Y.VER_NR,
                         'PROTO_IDSEQ',
                         Y.ITEM_LONG_NM,
                         'DATA MISMATCH',
                         SYSDATE,
                         USER,
                         'NCI_ADMIN_ITEM_REL',
                         '');
            COMMIT;
END LOOP;

--Check QC_IDSEQ relationship in PROTOCOL_QC_EXT/ NCI_ADMIN_ITEM_REL
FOR Y IN (SELECT /*+ PARALEL(12)*/
       DISTINCT ai3.Item_Id,
                ai3.Ver_Nr,
                ai3.NCI_IDSEQ,
                ai3.ITEM_LONG_NM
  FROM SBREXT.PROTOCOL_QC_EXT  dae
       INNER JOIN admin_item ai3
           ON     ai3.nci_idseq = qc_idseq --FK 
           AND ai3.admin_item_typ_id = 54
              WHERE NOT  EXISTS
                          (SELECT *
                             FROM admin_item  ai2
                                  INNER JOIN NCI_ADMIN_ITEM_REL dec
                                      ON   dec.C_ITEM_ID = ai3.Item_Id
                                         AND dec.C_ITEM_VER_NR = ai3.Ver_Nr
                                         AND ai2.Nci_Idseq = dae.qc_idseq)) --PK
LOOP
INSERT INTO ONEDATA_MIGRATION_ERROR
             VALUES (ERR_SEQ.NEXTVAL,
                     Y.NCI_iDSEQ,
                     Y.Item_Id,
                     Y.VER_NR,
                     'QC_IDSEQ',
                     Y.ITEM_LONG_NM,
                     'DATA MISMATCH',
                     SYSDATE,
                     USER,
                     'NCI_ADMIN_ITEM_REL',
                     '');
        COMMIT;
END LOOP;
                               
END;
/
