CREATE OR REPLACE PROCEDURE ONEDATA_WA.SP_OD_CADSR_TAB_28_INSERT as
/*insert XML*/
V_OWNER VARCHAR2(100 BYTE);
V_TABLE VARCHAR2(100 BYTE);
V_COLUMN VARCHAR2(100BYTE);
V_TYPE VARCHAR2(100 BYTE);
V_LENGTH NUMBER;
V_PREC VARCHAR2(10);
errmsg VARCHAR2(200 BYTE);
CURSOR c_od IS
select *
FROM VW_OD_CADSR_TAB_COLUM_DEF_SIZE
WHERE OWNER ='ONEDATA_WA';

CURSOR c_cadsr IS
select *
FROM OD_CADSR_TAB_28_INSERT ;

BEGIN


delete from OD_CADSR_TAB_28_INSERT;
commit;
            INSERT INTO OD_CADSR_TAB_28_INSERT (DB_OBJECT,
            OD_OWNER ,
            OD_TABLE_NAME ,
            OD_COLUMN_NAME ,
            OD_DATA_TYPE ,
            OD_DATA_LENGTH) 
            SELECT DB_OBJECTS,OWNER,TABLE_NAME,COLUMN_NAME,DATA_TYPE,DATA_LENGTH FROM VW_OD_CADSR_TAB_COLUM_DEF_SIZE WHERE OWNER ='ONEDATA_WA';
            COMMIT; 
            DELETE FROM OD_CADSR_TAB_28_INSERT WHERE  OD_COLUMN_NAME LIKE '%_ID' OR OD_COLUMN_NAME  LIKE '%VER_NR';
            COMMIT; 
            MERGE INTO OD_CADSR_TAB_28_INSERT T1
            USING
            (
            -- For more complicated queries you can use WITH clause here
            SELECT DISTINCT TABLE_NAME,OWNER, DB_OBJECTS FROM VW_OD_CADSR_TAB_COLUM_DEF_SIZE  WHERE OWNER IN ('SBR','SBREXT')
            )T2
            ON(T1.DB_OBJECT = T2.DB_OBJECTS)
            WHEN MATCHED THEN UPDATE SET
            T1.CADSR_TABLE_NAME=T2.TABLE_NAME,
            T1.CADSR_OWNER=T2.OWNER;
            COMMIT;

            UPDATE OD_CADSR_TAB_28_INSERT SET  CADSR_TABLE_NAME='QUEST_CONTENTS_EXT',
            CADSR_OWNER='SBREXT' WHERE INSTR(DB_OBJECT,'Form,Form')>0 OR INSTR(DB_OBJECT,'Module')>0 
            OR INSTR(DB_OBJECT,'Question')>0  ;          
            COMMIT;
                       
            UPDATE OD_CADSR_TAB_28_INSERT SET CADSR_TABLE_NAME='N/A',CADSR_COLUMN_NAME='N/A'
            WHERE OD_TABLE_NAME='ADMIN_ITEM' AND 
            OD_COLUMN_NAME 
            IN  ( 'ADMIN_STUS_ID','REGSTR_STUS_ID','SUBMT_CNTCT_ID','SUBMT_ORG_ID','STEWRD_CNTCT_ID','STEWRD_ORG_ID','ADMIN_NOTES');
            COMMIT;   
            UPDATE OD_CADSR_TAB_28_INSERT SET CADSR_COLUMN_NAME='DEFINITION_SOURCE',CADSR_TABLE_NAME='VALUE_MEANINGS',CADSR_OWNER='SBR'
            WHERE OD_TABLE_NAME='ADMIN_ITEM' AND OD_COLUMN_NAME ='DEF_SRC';
            COMMIT;             
            UPDATE OD_CADSR_TAB_28_INSERT SET CADSR_TABLE_NAME='AC_REGISTRATIONS', CADSR_OWNER='SBR',CADSR_COLUMN_NAME='REGISTRATION_STATUS'
            WHERE OD_TABLE_NAME='ADMIN_ITEM' AND OD_COLUMN_NAME ='REGSTR_STUS_NM_DN';
            COMMIT;  
            UPDATE OD_CADSR_TAB_28_INSERT SET CADSR_TABLE_NAME='SOURCES_EXT', CADSR_OWNER='SBR',CADSR_COLUMN_NAME='SRC_NAME'
            WHERE OD_TABLE_NAME='ADMIN_ITEM' AND OD_COLUMN_NAME ='ORIGIN_ID_DN';
            COMMIT;  



        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='ADMIN_STUS_NM_DN' THEN 'ASL_NAME'
        WHEN OD_COLUMN_NAME='ITEM_DESC' THEN 'PREFERRED_DEFINITION'
        WHEN OD_COLUMN_NAME='ITEM_LONG_NM' THEN 'PREFERRED_NAME'
        WHEN OD_COLUMN_NAME='ITEM_NM' THEN 'LONG_NAME'        
        WHEN OD_COLUMN_NAME='CHNG_DESC_TXT' THEN 'CHANGE_NOTE'
        WHEN OD_COLUMN_NAME='ORIGIN' THEN 'ORIGIN'
        ELSE
        CADSR_COLUMN_NAME
        END
        where OD_TABLE_NAME='ADMIN_ITEM';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='AC_STATUS_LOV',
        CADSR_COLUMN_NAME
        = CASE WHEN OD_COLUMN_NAME in('NCI_STUS','STUS_NM')
        THEN 'ASL_NAME'
        WHEN OD_COLUMN_NAME='STUS_DESC'
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='NCI_CMNTS'
        THEN 'COMMENTS'
        WHEN OD_COLUMN_NAME='NCI_DISP_ORDR'
        THEN 'DISPLAY_ORDER'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Workflow Status';
        commit;
   
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='REG_STATUS_LOV',
        CADSR_COLUMN_NAME
        = CASE WHEN OD_COLUMN_NAME in('NCI_STUS','STUS_NM')
        THEN 'REGISTRATION_STATUS'
        WHEN OD_COLUMN_NAME='STUS_DESC'
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='NCI_CMNTS'
        THEN 'COMMENTS'
        WHEN OD_COLUMN_NAME='NCI_DISP_ORDR'
        THEN 'DISPLAY_ORDER'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Registration Status';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='REG_STATUS_LOV',
        CADSR_COLUMN_NAME
        = CASE WHEN OD_COLUMN_NAME ='RAI'
        THEN 'RAI'
        WHEN OD_COLUMN_NAME='ORG_NM'
        THEN 'NAME'
        WHEN OD_COLUMN_NAME='RA_IND'
        THEN 'RA_IND'
        WHEN OD_COLUMN_NAME='MAIL_ADDR'
        THEN 'MAIL_ADDRESS'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Organization';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='ADDR_TYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'ATL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Address Type';
        commit; 

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CSI_TYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'CSITL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='CSI Type';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CS_TYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'CSTL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Classification Scheme Type';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='COMM_TYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'CTL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Communication Type';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='DEFINITION_TYPES_LOV_EXT',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'DEFL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Definition Type';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='DESIGNATION_TYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'DETL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Designation Type';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='COMPLEX_REP_TYPE_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME in('OBJ_KEY_DESC','NCI_CD')
        THEN 'CRTL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Derivation Type';
        commit;


        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='SOURCES_EXT',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME in('OBJ_KEY_DESC','NCI_CD')
        THEN 'SRC_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'        
        ELSE
        'N/A'
        END
        where DB_OBJECT='Origin';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='PROGRAM_AREAS_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME in('OBJ_KEY_DESC','NCI_CD')
        THEN 'PAL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Program Area';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='PROTOCOLS_EXT',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME in('OBJ_KEY_DESC','NCI_CD')
        THEN 'TYPE'         
        ELSE
        'N/A'
        END
        where DB_OBJECT='Protocol Type';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CONTACT_ADDRESSES',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='RNK_ORD'
        THEN 'RANK_ORDER'
        WHEN OD_COLUMN_NAME ='CNTRY'
        THEN 'COUNTRY'
        WHEN OD_COLUMN_NAME ='POSTAL_CD'
        THEN 'POSTAL_CODE'
        ELSE
        OD_COLUMN_NAME
        END
        where DB_OBJECT='Addresses';
        commit; 

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='COMPLEX_DE_RELATIONSHIPS',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='DISP_ORD'
        THEN 'DISPLAY_ORDER'
        ELSE
        'N/A'
        END
        where DB_OBJECT='COMPLEX DE Relationship';
        commit; 
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CS_ITEMS',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='DESCRIPTION'
        THEN 'CSI_DESC_TXT'
        WHEN OD_COLUMN_NAME ='COMMENTS'
        THEN 'CSI_DESC_TXT'
        WHEN OD_COLUMN_NAME ='DELETED_IND'
        THEN 'CSI_DESC_TXT'
        ELSE
        'N/A'
        END
        where DB_OBJECT='CSI';
        commit; 

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CLASSIFICATION_SCHEMES',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='NCI_LABEL_TYP_FLG'
        THEN 'LABEL_TYPE_FLAG'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Classification Scheme';
        commit; 

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CONTACT_COMMS',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='CYB_ADDR'
        THEN 'CYBER_ADDRESSG'
        WHEN OD_COLUMN_NAME ='RNK_ORD'
        THEN 'RANK_ORDER'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Communications';
        commit; 
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CONCEPTUAL_DOMAINS',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='DIMNSNLTY'
        THEN 'DIMENSIONALITY'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Conceptual Domain';
        commit;      
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CONCEPTS_EXT', CADSR_COLUMN_NAME='N/A' where DB_OBJECT='Concept';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='CONTEXTS', CADSR_COLUMN_NAME='N/A' where DB_OBJECT='Context';
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='REFERENCE_DOCUMENTS',CADSR_COLUMN_NAME='DOC_TEXT'
        where OD_COLUMN_NAME ='PREF_QUEST_TXT' and DB_OBJECT='DE';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='COMPLEX_DATA_ELEMENTS',
        CADSR_COLUMN_NAME= CASE
        WHEN OD_COLUMN_NAME ='CONCAT_CHAR'
        THEN  'CONCAT_CHAR'
        WHEN OD_COLUMN_NAME ='DERV_MTHD'
        THEN 'METHODS'
        WHEN OD_COLUMN_NAME ='DERV_RUL'
        THEN 'RULE'
        ELSE
        'N/A'
        END
        where DB_OBJECT='DE' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='DOCUMENT_TYPES_LOV',
        CADSR_COLUMN_NAME= CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'DCTL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='OBJ_KEY_CMNTS'
        THEN 'COMMENTS'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Document Type' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='QC_DISPLAY_LOV_EXT',
        CADSR_COLUMN_NAME= CASE
        WHEN OD_COLUMN_NAME ='OBJ_KEY_DESC'
        THEN 'QCDL_NAME'
        WHEN OD_COLUMN_NAME='OBJ_KEY_DEF'     
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='DISP_ORD
        '
        THEN 'DISPLAY_ORDER'     
        ELSE
        'N/A'
        END
        where DB_OBJECT='Form Category' and CADSR_COLUMN_NAME is NULL;
        commit;


        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='DATA_ELEMENT_CONCEPTS',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='OBJ_CLS_QUAL'
        THEN 'OBJ_CLASS_QUALIFIER'
        WHEN OD_COLUMN_NAME ='PROP_QUAL'
        THEN 'PROPERTY_QUALIFIER'
        ELSE
        'N/A'
        END
        where OD_TABLE_NAME='DE_CONC';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='DATATYPES_LOV',
        CADSR_COLUMN_NAME
        = CASE
        WHEN OD_COLUMN_NAME ='DTTYPE_ANNTTN'  
        THEN 'ANNOTATION'
        WHEN OD_COLUMN_NAME ='DTTYPE_SCHM_REF' 
        THEN 'SCHEME_REFERENCE'
        WHEN OD_COLUMN_NAME ='DTTYPE_DESC'
        THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME ='DTTYPE_NM'
        THEN 'DTL_NAME'
        WHEN OD_COLUMN_NAME ='NCI_CD'
        THEN 'DTL_NAME'
        WHEN OD_COLUMN_NAME ='NCI_DTTYPE_CMNTS'
        THEN 'COMMENTS'
        WHEN OD_COLUMN_NAME ='NCI_DTTYPE_MAP'
        THEN 'DTL_NAME'
        ELSE
        'N/A'
        END
        where OD_TABLE_NAME='DATA_TYP';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='QUEST_CONTENTS_EXT',
        CADSR_COLUMN_NAME= 'PREFERRED_DEFINITION'
        where OD_TABLE_NAME='NCI_FORM' and OD_COLUMN_NAME in ('FTR_INSTR','HDR_INSTR');
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='QUEST_CONTENTS_EXT',
        CADSR_COLUMN_NAME= CASE
        WHEN OD_COLUMN_NAME='DISP_ORD'     
        THEN 'DISPLAY_ORDER'   
        WHEN OD_COLUMN_NAME='INSTR'
        THEN 'PREFERRED_DEFINITION'   
        WHEN OD_COLUMN_NAME='REP_NO'  
        THEN'REPEAT_NO'  
        ELSE
        'N/A'
        END
        where DB_OBJECT='Module, Module Instruction' and CADSR_COLUMN_NAME is NULL;
        commit;


        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='QUEST_CONTENTS_EXT',
        CADSR_COLUMN_NAME= CASE

        WHEN OD_COLUMN_NAME='DISP_ORD'     
        THEN 'DISPLAY_ORDER'   
        WHEN OD_COLUMN_NAME='INSTR'
        THEN 'PREFERRED_DEFINITION'   
        WHEN OD_COLUMN_NAME='REP_NO'  
        THEN'REPEAT_NO'  
        WHEN OD_COLUMN_NAME='DEFLT_VAL'
        THEN 'DEFAULT_VALUE'
        WHEN OD_COLUMN_NAME='ITEM_LONG_NM'
        THEN 'LONG_NAME'
        WHEN OD_COLUMN_NAME in('PREF_NM_MIGRATED','ITEM_NM')
        THEN 'PREFERRED_NAME' 
        ELSE
        'N/A'
        END
        where DB_OBJECT='Question, Question Instruction' and CADSR_COLUMN_NAME is NULL;
        commit;


        -- 	ONEDATA_WA	NCI_ADMIN_ITEM_REL_ALT_KEY	REQ_IND

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='VALID_VALUES_ATT_EXT',CADSR_OWNER='SBREXT',
        CADSR_COLUMN_NAME= CASE     
        WHEN OD_COLUMN_NAME='DESC_TXT'
        THEN'DESCRIPTION_TEXT'
        WHEN OD_COLUMN_NAME='MEAN_TXT'
        THEN 'MEANING_TEXT'
        END
        where OD_TABLE_NAME ='NCI_QUEST_VALID_VALUE' and OD_COLUMN_NAME in('DESC_TXT','MEAN_TXT');
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='QUEST_CONTENTS_EXT',
        CADSR_COLUMN_NAME= CASE
        WHEN OD_COLUMN_NAME='DISP_ORD'     
        THEN 'DISPLAY_ORDER'   
        WHEN OD_COLUMN_NAME='INSTR'
        THEN 'PREFERRED_DEFINITION' 
        WHEN OD_COLUMN_NAME='VALUE'
        THEN 'LONG_NAME'
        WHEN OD_COLUMN_NAME='VM_DEF'
        THEN 'PREFERRED_DEFINITION'
        WHEN OD_COLUMN_NAME='VM_NM'
        THEN 'PREFERRED_NAME'
        WHEN OD_COLUMN_NAME='REP_NO'  
        THEN'REPEAT_NO'  
        WHEN OD_COLUMN_NAME='DISP_ORD'     
        THEN 'DISPLAY_ORDER'      
        ELSE
        'N/A'
        END
        where OD_TABLE_NAME ='NCI_QUEST_VALID_VALUE' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE

        WHEN OD_COLUMN_NAME='DEF_DESC'
        THEN 'DEFINITION'   
        ELSE
        'N/A'
        END
        where DB_OBJECT='Definitions' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='NM_DESC'     
        THEN 'NAME'   
        ELSE
        'N/A'
        END
        where DB_OBJECT='Designations' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='FMT_DESC'     
        THEN 'DESCRIPTION'  
        WHEN OD_COLUMN_NAME = 'FMT_CMNTS'   
        THEN 'COMMENTS'   
        WHEN OD_COLUMN_NAME in ('FMT_NM','NCI_CD')    
        THEN 'FORML_NAME' 
        ELSE
        'N/A'
        END
        where DB_OBJECT='Formats' and CADSR_COLUMN_NAME is NULL;
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='LANG_NM' THEN 'NAME'   
        WHEN OD_COLUMN_NAME='LANG_DESC' THEN 'NDESCRIPTION'   
        ELSE
        'N/A'
        END
        where DB_OBJECT='Language' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='DIMNSNLTY' THEN 'DIMENSIONALITY'
        WHEN OD_COLUMN_NAME='DISP_ORD' THEN 'DISPLAY_ORDER'
        WHEN OD_COLUMN_NAME='DRCTN' THEN 'DIRECTION'
        WHEN OD_COLUMN_NAME='REL_TYP_NM' THEN 'RL_NAME'
        WHEN OD_COLUMN_NAME='ARRAY_IND' THEN 'ARRAY_IND'
        WHEN OD_COLUMN_NAME='SRC_HIGH_MULT' THEN 'SOURCE_HIGH_MULTIPLICITY'
        WHEN OD_COLUMN_NAME='SRC_LOW_MULT' THEN 'SOURCE_LOW_MULTIPLICITY'
        WHEN OD_COLUMN_NAME='SRC_ROLE' THEN 'SOURCE_ROLE'
        WHEN OD_COLUMN_NAME='TRGT_HIGH_MULT' THEN 'TARGET_HIGH_MULTIPLICITY'
        WHEN OD_COLUMN_NAME='TRGT_LOW_MULT' THEN 'TARGET_LOW_MULTIPLICITY'
        WHEN OD_COLUMN_NAME='TRGT_ROLE' THEN 'TARGET_ROLE'
        ELSE
        'N/A'
        END
        where DB_OBJECT='OC Recs' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='PROTCL_PHASE' THEN 'PHASE'   
        WHEN OD_COLUMN_NAME='LEAD_ORG' THEN 'NLEAD_ORG' 
        WHEN OD_COLUMN_NAME='CHNG_TYP' THEN 'CHANGE_TYPE'  
        WHEN OD_COLUMN_NAME='CHNG_NBR' THEN 'CHANGE_NUMBER'    
        ELSE
        'N/A'
        END
        where DB_OBJECT='Protocol' and CADSR_COLUMN_NAME is NULL;
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='FIRST_NM' THEN 'FNAME'   
        WHEN OD_COLUMN_NAME='LAST_NM' THEN 'LNAME' 
        WHEN OD_COLUMN_NAME='MI' THEN 'MI'  
        WHEN OD_COLUMN_NAME='POS' THEN 'POSITION' 
        WHEN OD_COLUMN_NAME='RNK_ORD' THEN 'RANK_ORDER'    
        ELSE
        'N/A'
        END
        where DB_OBJECT='Person' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='NCI_DEC_PREC' THEN 'DECIMAL_PLACE'   
        WHEN OD_COLUMN_NAME='VAL_DOM_HIGH_VAL_NUM' THEN 'HIGH_VALUE_NUM'
        WHEN OD_COLUMN_NAME='VAL_DOM_LOW_VAL_NUM' THEN 'LOW_VALUE_NUM'
        WHEN OD_COLUMN_NAME='VAL_DOM_MAX_CHAR' THEN 'MAX_LENGTH_NUM'
        WHEN OD_COLUMN_NAME='VAL_DOM_MIN_CHAR' THEN 'MIN_LENGTH_NUM'
        ELSE
        'N/A'
        END
        where DB_OBJECT='Value Domain' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='VM_CMNTS' THEN 'COMMENTS'   
        WHEN OD_COLUMN_NAME='VM_DESC_TXT' THEN 'DESCRIPTION'        
        ELSE
        'N/A'
        END
        where DB_OBJECT='Value Meaning' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME='ORIGIN' 
        Where  DB_OBJECT='PV' and  OD_COLUMN_NAME='NCI_ORIGIN';
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_TABLE_NAME='PERMISSIBLE_VALUES',CADSR_COLUMN_NAME= CASE   
        WHEN OD_COLUMN_NAME='PERM_VAL_DESC_TXT' THEN 'SHORT_MEANING'
        WHEN OD_COLUMN_NAME='PERM_VAL_NM' THEN 'VALUE'            
        ELSE
        'N/A'
        END
        where DB_OBJECT='PV' and CADSR_COLUMN_NAME is NULL;
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE 
        WHEN OD_COLUMN_NAME='DISP_ORD' THEN 'DISPLAY_ORDER'  
        WHEN OD_COLUMN_NAME='REF_DESC' THEN 'DOC_TEXT'
        WHEN OD_COLUMN_NAME='REF_NM' THEN 'NAME'   
        WHEN OD_COLUMN_NAME='URL' THEN 'URL'          
        ELSE
        'N/A'
        END
        where DB_OBJECT='Reference Documents' and CADSR_COLUMN_NAME is NULL;
        commit;
        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE 
        WHEN OD_COLUMN_NAME='SRC_TYP_NM' THEN 'S_QTL_NAME'  
        WHEN OD_COLUMN_NAME='TA_INSTR' THEN 'TA_INSTRUCTION'
        WHEN OD_COLUMN_NAME='TRGT_TYP_NM' THEN 'T_QTL_NAME'   
        ELSE
        'N/A'
        END
        where DB_OBJECT='Trigger Actions' and CADSR_COLUMN_NAME is NULL;
        commit;

        UPDATE OD_CADSR_TAB_28_INSERT set CADSR_COLUMN_NAME= CASE 
        WHEN OD_COLUMN_NAME='UOM_CMNTS' THEN 'COMMENTS'  
        WHEN OD_COLUMN_NAME='UOM_DESC' THEN 'DESCRIPTION'
        WHEN OD_COLUMN_NAME='UOM_PREC' THEN 'PRECISION'   
        WHEN OD_COLUMN_NAME in('NCI_CD','UOM_NM') THEN 'UOML_NAME'        
        ELSE
        'N/A'
        END
        where DB_OBJECT='UOM' and CADSR_COLUMN_NAME is NULL;
        commit;
    
MERGE INTO OD_CADSR_TAB_28_INSERT T1
            USING
            (
            -- For more complicated queries you can use WITH clause here
            SELECT DISTINCT TABLE_NAME,OWNER,COLUMN_NAME, DATA_TYPE,DATA_LENGTH FROM all_tab_columns  WHERE OWNER IN ('SBR','SBREXT')
            )T2
            ON(T1.CADSR_TABLE_NAME=T2.TABLE_NAME
            AND T1.CADSR_COLUMN_NAME=T2.COLUMN_NAME
             and T1.CADSR_OWNER=T2.OWNER)
            WHEN MATCHED THEN UPDATE SET
            T1.CADSR_DATA_TYPE=T2.DATA_TYPE,
            T1.CADSR_DATA_LENGTH=T2.DATA_LENGTH;
            COMMIT;
            
--     select*from OD_CADSR_TAB_28_INSERT T1, all_tab_columns t2
--           where T1.CADSR_TABLE_NAME=T2.TABLE_NAME
--            AND T1.CADSR_COLUMN_NAME=T2.COLUMN_NAME
--             and T1.CADSR_OWNER=T2.OWNER       
--            
--            
--
--    
--   FOR rec IN c_cadsr LOOP     
--        
--SELECT DATA_TYPE,DATA_LENGTH,  DATA_PRECISION||','||DATA_SCALE 
--into  V_TYPE,V_LENGTH,  V_PREC  FROM all_tab_columns  
--where owner =rec.cadsr_owner and table_name=rec.cadsr_table_name and column_name=rec.cadsr_column_name;
--
--
--UPDATE OD_CADSR_TAB_28_INSERT
-- set CADSR_DATA_TYPE=V_TYPE,
--CADSR_DATA_LENGTH=V_LENGTH
--where CADSR_OWNER =rec.cadsr_owner and CADSR_table_name=rec.cadsr_table_name and CADSR_column_name=rec.cadsr_column_name;
-- commit;
--select*from all_tab_columns where table_name='CONTACT_ADDRESSES' and  column_name='ADDR_LINE1';
--
----  elsif c_rec.DB_OBJECTS='DE Concept' THEN where 
----  UPDATE OD_CADSR_TAB_28_INSERT
---- set CADSR_TABLE_NAME='DATA_ELEMENT_CONCEPTS', CADSR_OWNER='SBR';
---- commit;
----  elsif c_rec.DB_OBJECTS='Conceptual Domain' THEN
----  UPDATE OD_CADSR_TAB_28_INSERT
---- set CADSR_TABLE_NAME='CONCEPTUAL_DOMAINS', CADSR_OWNER='SBR';
---- commit;
----  elsif c_rec.DB_OBJECTS='DE Concept' THEN
----  UPDATE OD_CADSR_TAB_28_INSERT
---- set CADSR_TABLE_NAME='DATA_ELEMENT_CONCEPTS', CADSR_OWNER='SBR';
---- commit;
----  elsif c_rec.DB_OBJECTS='DE Concept' THEN
----  UPDATE OD_CADSR_TAB_28_INSERT
---- set CADSR_TABLE_NAME='DATA_ELEMENT_CONCEPTS', CADSR_OWNER='SBR';
---- commit;
----    END IF;
-- END LOOP;

 EXCEPTION
 
    WHEN OTHERS THEN
   errmsg := SQLERRM;
         dbms_output.put_line('errmsg  - '||errmsg);
        insert into CDE_19_REPORTS_ERR_LOG VALUES ('A',  errmsg, sysdate);
 commit;

END ;
/
