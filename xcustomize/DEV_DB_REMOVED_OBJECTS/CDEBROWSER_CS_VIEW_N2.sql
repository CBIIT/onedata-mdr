DROP VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW_N2;

CREATE OR REPLACE FORCE VIEW ONEDATA_WA.CDEBROWSER_CS_VIEW_N2
(DE_ITEM_ID, DE_VER_NR, CS_ITEM_ID, CS_VER_NR, CS_ITEM_NM, 
 CS_ITEM_LONG_NM, CS_PREF_DEF, CS_ADMIN_STUS, CS_REGSTR_STUS, CS_CNTXT_NM, 
 CS_CNTXT_VER_NR, CSI_ITEM_ID, CSI_VER_NR, CSI_ITEM_NM, CSI_LONG_NM, 
 CSITL_NM, CSI_PREF_DEF)
BEQUEATH DEFINER
AS 
SELECT 
           de.ITEM_ID DE_ITEM_ID,
           de.VER_NR DE_VER_NR,
           csi.CS_ITEM_ID CS_ID,
           csi.CS_ITEM_VER_NR CS_VER_NR,
           cs.ITEM_NM ,
           cs.ITEM_LONG_NM,           
           cs.ITEM_DESC,           
           cs.ADMIN_STUS_NM_DN,
           cs.REGSTR_STUS_NM_DN, 
           cs.CNTXT_NM_DN,
           cs.CNTXT_VER_NR,         
           acsi.ITEM_ID CS_ITEM_ID,
           acsi.VER_NR CS_ITEM_VER_NR,
           acsi.ITEM_NM ,
           acsi.ITEM_LONG_NM CSI_LONG_NM,
           o.NCI_CD        CSITL_NM,
           acsi.ITEM_DESC   CSI_PREF_DEF 
    
    --   select* 
      FROM NCI_ADMIN_ITEM_REL     ak,
           ADMIN_ITEM             cs,
           NCI_CLSFCTN_SCHM_ITEM  csi,
           DE,
           OBJ_KEY                     o,
           ADMIN_ITEM  acsi          
     WHERE     ak.C_ITEM_ID = de.ITEM_ID
           AND ak.C_ITEM_VER_NR = de.VER_NR          
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR
           AND cs.ITEM_ID = csi.ITEM_ID
           AND cs.VER_NR = csi.VER_NR
           AND csi.CS_ITEM_ID = acsi.ITEM_ID
           AND csi.CS_ITEM_VER_NR = acsi.VER_NR           
           and acsi.ADMIN_ITEM_TYP_ID=9
           and cs.ADMIN_ITEM_TYP_ID=51
           AND  csi.CSI_TYP_ID = o.obj_key_id;
