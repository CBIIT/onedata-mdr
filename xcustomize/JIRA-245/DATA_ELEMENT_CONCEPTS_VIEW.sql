CREATE OR REPLACE FORCE VIEW DATA_ELEMENT_CONCEPTS_VIEW
(
    DEC_IDSEQ,
    VERSION, 
    DEC_ID,
    PREFERRED_NAME,
    LONG_NAME,
    PREFERRED_DEFINITION,     
    ASL_NAME,    
    LATEST_VERSION_IND,
    DELETED_IND,
    DATE_CREATED,
    BEGIN_DATE,
    CREATED_BY,
    END_DATE,
    DATE_MODIFIED,
    MODIFIED_BY, 
    CHANGE_NOTE,       
    ORIGIN,
    CD_IDSEQ,
    CONTE_IDSEQ,
    PROPL_NAME,
    OCL_NAME,
    OBJ_CLASS_QUALIFIER,
    PROPERTY_QUALIFIER,   
    OC_IDSEQ,
    PROP_IDSEQ,    
    CDR_NAME,
    PROP_ITEM_ID,
    PROP_VER_NR  ,
    OBJ_CLS_ITEM_ID,
    OBJ_CLS_VER_NR
)
BEQUEATH DEFINER
AS
    SELECT 
            ai.nci_idseq DEC_IDSEQ,
            ai.ver_nr DEC_VERSION,
            ai.ITEM_ID DEC_ID,
            ai.ITEM_LONG_NM PREFERRED_NAME,
            ai.ITEM_NM LONG_NAME,
            ai.ITEM_DESC    PREFERRED_DEFINITION,            
            ai.ADMIN_STUS_NM_DN         ASL_NAME,          
            DECODE (AI.CURRNT_VER_IND,  1, 'YES',  0, 'NO')   LATEST_VERSION_IND,
            AI.FLD_DELETE       DELETED_IND,           
            ai.CREAT_DT    DATE_CREATED,
            ai.EFF_DT            BEGIN_DATE, 
            ai.CREAT_USR_ID         CREATED_BY,
            ai.UNTL_DT     END_DATE,
            ai.LST_UPD_DT      DATE_MODIFIED,
            ai.LST_UPD_USR_ID  MODIFIED_BY,
            ai.CHNG_DESC_TXT           CHANGE_NOTE,
             NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)   ORIGIN,
            CD.NCI_IDSEQ CD_IDSEQ,
            CONTE.NCI_IDSEQ        CONTE_IDSEQ,            
            PROP.ITEM_NM PROPL_NAME,
            OC.ITEM_NM OCL_NAME, 
            OBJ_CLS_QUAL OBJ_CLASS_QUALIFIER,
            PROP_QUAL PROPERTY_QUALIFIER,           
            PROP.NCI_IDSEQ    PROP_IDSEQ,
            OC.NCI_IDSEQ OC_IDSEQ, 
            get_concepts_PRN(dec.OBJ_CLS_ITEM_ID,dec.OBJ_CLS_VER_NR)||get_concepts_PRN(dec.PROP_ITEM_ID,dec.PROP_VER_NR) CDR_NAME,        
            dec.PROP_ITEM_ID,
            dec.PROP_VER_NR  ,
            dec.OBJ_CLS_ITEM_ID,
            dec.OBJ_CLS_VER_NR
          /* ai.UNRSLVD_ISSUE,
           ai.UNTL_DT,                
           ai.REGSTR_STUS_NM_DN,          
           ai.CNTXT_NM_DN,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,*/
   --       select count(*)
       FROM ADMIN_ITEM ai, 
           DE_CONC dec,
           ADMIN_ITEM  CONTE,
           ADMIN_ITEM  cd,
           ADMIN_ITEM oc,
           ADMIN_ITEM prop
      where ai.ADMIN_ITEM_TYP_ID=2
      and ai.item_id=dec.ITEM_ID
      and ai.ver_nr=dec.VER_NR
      AND CD.ADMIN_ITEM_TYP_ID = 1
      AND oc.ADMIN_ITEM_TYP_ID = 5
      AND prop.ADMIN_ITEM_TYP_ID = 6
      AND dec.OBJ_CLS_ITEM_ID=oc.ITEM_ID
      AND dec.OBJ_CLS_VER_NR=oc.VER_NR
      AND dec.PROP_ITEM_ID=prop.ITEM_ID
      AND dec.PROP_VER_NR=prop.VER_NR
      AND DEC.CONC_DOM_ITEM_ID=CD.ITEM_ID      
      AND DEC.CONC_DOM_VER_NR=CD.VER_NR
      AND AI.CNTXT_ITEM_ID = CONTE.ITEM_ID
      AND AI.CNTXT_VER_NR = CONTE.VER_NR
      AND CONTE.ADMIN_ITEM_TYP_ID = 8;

      
