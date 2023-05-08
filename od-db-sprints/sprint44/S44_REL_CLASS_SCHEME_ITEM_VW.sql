CREATE OR REPLACE FORCE VIEW ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW
(CS_ID, CS_VERSION, PREFERRED_NAME, LONG_NAME, PREFERRED_DEFINITION, 
 ASL_NAME, CS_CONTEXT_NAME, CS_CONTEXT_VERSION, CSITL_NAME, CSI_ID, 
 CSI_VERSION, CSI_NAME, DESCRIPTION, CSI_CONTEXT_NAME, CSI_CONTEXT_VERSION, 
 CS_DATE_CREATED, CSI_DATE_CREATED, P_ITEM_ID, P_ITEM_VER_NR, CSI_LEVEL, 
 LEAF, CS_IDSEQ, CSI_IDSEQ, CS_CONTEXT_ID, CSI_CONTEXT_ID, 
 CS_CSI_IDSEQ)
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
               TO_CHAR(CS.CREAT_DT,'DD-MON-YYYY')
                   CS_DATE_CREATED,
               TO_CHAR(CSI.CREAT_DT,'DD-MON-YYYY')
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
                   CSI_CONTEXT_ID,
               NODE.CS_CSI_IDSEQ
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


GRANT SELECT ON ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW TO ONEDATA_RA;

GRANT SELECT ON ONEDATA_WA.REL_CLASS_SCHEME_ITEM_VW TO ONEDATA_RO;
