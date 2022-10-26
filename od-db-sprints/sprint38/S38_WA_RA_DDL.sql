

insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Form Review - Excel', 115, 'Form Review - Excel', 
											'Form Review - Excel');
commit;

-- Standalone module


  CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE ("FRM_ITEM_LONG_NM", "FRM_ITEM_NM", "FRM_ITEM_ID", "FRM_VER_NR", "FRM_CNTXT_NM_DN", "FRM_ADMIN_STUS_NM_DN", "FRM_REGSTR_STUS_NM_DN", "FRM_CNTXT_ITEM_ID", "FRM_CNTXT_VER_NR", "MOD_ITEM_ID", "MOD_VER_NR", "DE_ITEM_ID", "DE_VER_NR", "QUEST_DISP_ORD", "MOD_DISP_ORD", "MOD_ITEM_NM", "INSTR", "MOD_ITEM_LONG_NM", "MOD_ITEM_DESC", "ADMIN_ITEM_TYP_NM", "NCI_PUB_ID", "NCI_VER_NR", "CNTXT_NM_DN", "DE_ITEM_NM", "DE_ITEM_DESC", "DE_CNTXT_ITEM_ID", "DE_CNTXT_VER_NR", "DE_ADMIN_STUS_NM_DN", "DE_REGSTR_STUS_NM_DN", "DE_CURRNT_VER_IND", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "QUEST_LONG_TXT", "QUEST_TXT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT FRM.ITEM_LONG_NM FRM_ITEM_LONG_NM, FRM.ITEM_NM FRM_ITEM_NM, FRM.ITEM_ID FRM_ITEM_ID, FRM.VER_NR FRM_VER_NR,  FRM.CNTXT_NM_DN FRM_CNTXT_NM_DN,
  FRM.ADMIN_STUS_NM_DN FRM_ADMIN_STUS_NM_DN, FRM.REGSTR_STUS_NM_DN FRM_REGSTR_STUS_NM_DN,
FRM.CNTXT_ITEM_ID FRM_CNTXT_ITEM_ID, FRM.CNTXT_VER_NR FRM_CNTXT_VER_NR,
AIR.P_ITEM_ID MOD_ITEM_ID, AIR.P_ITEM_VER_NR MOD_VER_NR,
AIR.C_ITEM_ID DE_ITEM_ID, AIR.C_ITEM_VER_NR DE_VER_NR, AIR.DISP_ORD QUEST_DISP_ORD,FRM_MOD.DISP_ORD MOD_DISP_ORD,
AIM.ITEM_NM MOD_ITEM_NM, AIR.INSTR,
AIM.ITEM_LONG_NM  MOD_ITEM_LONG_NM, AIM.ITEM_DESC MOD_ITEM_DESC,
'QUESTION' ADMIN_ITEM_TYP_NM, AIR.NCI_PUB_ID,AIR.NCI_VER_NR,
DE.CNTXT_NM_DN, DE.ITEM_NM DE_ITEM_NM, DE.ITEM_DESC DE_ITEM_DESC, DE.CNTXT_ITEM_ID DE_CNTXT_ITEM_ID, DE.CNTXT_VER_NR DE_CNTXT_VER_NR, 
DE.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, DE.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,DE.CURRNT_VER_IND DE_CURRNT_VER_IND, 
AIR.CREAT_DT, AIR.CREAT_USR_ID, AIR.LST_UPD_USR_ID, AIR.FLD_DELETE, AIR.LST_DEL_DT, AIR.S2P_TRN_DT, AIR.LST_UPD_DT, AIR.ITEM_LONG_NM QUEST_LONG_TXT, AIR.ITEM_NM QUEST_TXT
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
ADMIN_ITEM FRM, NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND FRM.ITEM_ID = FRM_MOD.P_ITEM_ID AND FRM.VER_NR = FRM_MOD.P_ITEM_VER_NR AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND FRM.ADMIN_ITEM_TYP_ID IN ( 54,55)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR
union
 SELECT 'No Form Relationship' FRM_ITEM_LONG_NM,'No Form Relationship' FRM_ITEM_NM,-1 FRM_ITEM_ID, 1 FRM_VER_NR,  'NCIP' FRM_CNTXT_NM_DN,
  'RELEASED' FRM_ADMIN_STUS_NM_DN, 'STANDARD' FRM_REGSTR_STUS_NM_DN,
20000000024 FRM_CNTXT_ITEM_ID, 1 FRM_CNTXT_VER_NR,
AIR.P_ITEM_ID MOD_ITEM_ID, AIR.P_ITEM_VER_NR MOD_VER_NR,
AIR.C_ITEM_ID DE_ITEM_ID, AIR.C_ITEM_VER_NR DE_VER_NR, AIR.DISP_ORD QUEST_DISP_ORD,FRM_MOD.DISP_ORD MOD_DISP_ORD,
AIM.ITEM_NM MOD_ITEM_NM, AIR.INSTR,
AIM.ITEM_LONG_NM  MOD_ITEM_LONG_NM, AIM.ITEM_DESC MOD_ITEM_DESC,
'QUESTION' ADMIN_ITEM_TYP_NM, AIR.NCI_PUB_ID,AIR.NCI_VER_NR,
DE.CNTXT_NM_DN, DE.ITEM_NM DE_ITEM_NM, DE.ITEM_DESC DE_ITEM_DESC, DE.CNTXT_ITEM_ID DE_CNTXT_ITEM_ID, DE.CNTXT_VER_NR DE_CNTXT_VER_NR, 
DE.ADMIN_STUS_NM_DN DE_ADMIN_STUS_NM_DN, DE.REGSTR_STUS_NM_DN DE_REGSTR_STUS_NM_DN,DE.CURRNT_VER_IND DE_CURRNT_VER_IND, 
AIR.CREAT_DT, AIR.CREAT_USR_ID, AIR.LST_UPD_USR_ID, AIR.FLD_DELETE, AIR.LST_DEL_DT, AIR.S2P_TRN_DT, AIR.LST_UPD_DT, AIR.ITEM_LONG_NM QUEST_LONG_TXT, AIR.ITEM_NM QUEST_TXT
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, ADMIN_ITEM AIM,
 NCI_ADMIN_ITEM_REL FRM_MOD , ADMIN_ITEM DE
WHERE  AIR.REL_TYP_ID = 63
AND AIM.ITEM_ID = AIR.P_ITEM_ID AND AIM.VER_NR = AIR.P_ITEM_VER_NR
AND AIM.ITEM_ID = FRM_MOD.C_ITEM_ID AND AIM.VER_NR = FRM_MOD.C_ITEM_VER_NR
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND AIR.C_ITEM_ID = DE.ITEM_ID
AND AIR.C_ITEM_VER_NR = DE.VER_NR
and FRM_MOD.P_ITEM_ID = -1;


-- Stand-alone module


  CREATE OR REPLACE  VIEW VW_NCI_FORM_MODULE AS
  select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_nm FORM_NM, ai.item_desc,
'MODULE' admin_item_typ_nm,air.INSTR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, air.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no,
ai.regstr_stus_id, ai.admin_stus_id, ai.cntxt_item_id, ai.cntxt_ver_nr, ai.item_long_nm, air.CPY_MOD_ITEM_ID,
air.CPY_MOD_VER_NR
from admin_item ai, nci_admin_item_rel air where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id in (61,62);


-- New Form upload

create table NCI_STG_FORM_IMPORT 
(FORM_IMP_ID	    NUMBER       not null PRIMARY KEY,
 SRC_FORM_NM varchar2(255),
 CTL_VAL_STUS varchar2(50),
 CTL_VAL_MSG  varchar2(4000),
FORM_NM	varchar2(255)	,
CNTXT_ITEM_ID number,
CNTXT_VER_NR number(4,2),
 PROCESS_DT varchar2(20),
 	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);


create table NCI_STG_FORM_QUEST_IMPORT 
(QUEST_IMP_ID	    NUMBER       not null PRIMARY KEY,
 FORM_IMP_ID number not null,
SRC_QUESTION_ID	varchar2(255)	,
 CTL_VAL_STUS varchar2(50),
 CTL_VAL_MSG  varchar2(4000),
SRC_MOD_NM	varchar2(255)	,
MOD_NM	varchar2(255)	,
SRC_QUEST_TYP	varchar2(255)	,
SRC_QUEST_LBL	varchar2(255)	,
SRC_VV	varchar2(4000)	,
 SRC_VAL_TYP varchar2(2000),
 SRC_VAL_MIN_VAL varchar2(2000),
 SRC_VAL_MAX_VAL  varchar2(2000),
SRC_CDE_NM	varchar2(255)	,
QUEST_TXT	varchar2(255)	,
SRC_QUEST_INSTR  varchar2(6000),
CDE_ITEM_ID	number	,
CDE_VER_NR	number(4,2)	,
 NUM_CDE_MTCH  integer,
SRC_FMT	varchar2(255),
 	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);
 

create table NCI_STG_FORM_VV_IMPORT (		
VAL_IMP_ID	number	 not null PRIMARY KEY,
QUEST_IMP_ID	Number	not null,
 CTL_VAL_STUS varchar2(50),
 CTL_VAL_MSG  varchar2(4000),
PERM_VAL_ID	number	,
	SRC_PERM_VAL  varchar2(255),
 SRC_VM_NM  varchar2(4000),
VV_ALT_NM	varchar2(255),	
VV_ALT_DEF	varchar2(4000),
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);



-- Form Match
alter table NCI_DS_RSLT_DTL add user_id varchar2(255);
alter table nci_ds_rslt add mtch_typ  varchar2(50);
alter table nci_ds_rslt_DTL add mtch_typ  varchar2(50);

-- Designation Alt Naes
alter table NCI_STG_ALT_NMS add  (SRC_ITEM_ID  number, SRC_VER_NR number(4,2),  SRC_AI_TYP varchar2(255));


alter table NCI_STG_ALT_NMS modify (nm_desc null, ITEM_ID null, VER_NR null, ADMIN_ITEM_TYP_ID null);
create or replace view vw_nci_mod_copy as select 
C_ITEM_ID, C_ITEM_VER_NR, CNTXT_ITEM_ID, CNTXT_VER_NR, REL_TYP_ID,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,  CPY_MOD_ITEM_ID, CPY_MOD_VER_NR
from nci_admin_item_rel where rel_typ_id = 61 and CPY_MOD_ITEM_ID is not null;


CREATE OR REPLACE  VIEW  "VW_NCI_DATA_AUDT_FORM" ("DA_ID", "ITEM_ID", "VER_NR", "ADMIN_ITEM_TYP_ID", "ACTION_TYP", "LVL", "LVL_PK", "ATTR_NM", "FROM_VAL", "TO_VAL", "CREAT_USR_ID_AUDT", "LVL_1_ITEM_ID", "LVL_1_VER_NR", "LVL_1_ITEM_NM", "LVL_2_ITEM_ID", "LVL_2_VER_NR", "LVL_2_ITEM_NM", "LVL_3_ITEM_ID", "LVL_3_VER_NR", "LVL_3_ITEM_NM", "LVL_1_DISP_ORD", "LVL_2_DISP_ORD", "LVL_3_DISP_ORD", "LST_UPD_USR_ID_AUDT", "CREAT_DT_AUDT", "LST_UPD_DT_AUDT", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "AUDT_CMNTS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete') ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS"
  from NCI_DATA_AUDT where (item_id, ver_nr) in (Select item_id, ver_nr from nci_form);

truncate table nci_data_audt;

alter table nci_data_audt modify ver_nr number(4,2);

alter table nci_data_audt modify (LVL_1_ITEM_NM varchar2(4000), LVL_2_ITEM_NM varchar2(4000), LVL_3_ITEM_NM varchar2(4000));

alter view vw_nci_data_audt compile;
alter view vw_nci_data_audt_form compile;


alter table admin_item add (ITEM_DEEP_LINK  varchar2(500));
--DeepLink changed per environment
insert into NCI_MDR_CNTRL( ID, PARAM_NM, PARAM_VAL) values (11, 'DEEP_LINK', 'https://cadsr-qa.cancer.gov/onedata/dmdirect/NIH/NCI');
commit;


alter table admin_item disable all triggers;

update ADMIN_ITEM set ITEM_DEEP_LINK = (Select param_val || '/CO/CDEDD?filter=CDEDD.ITEM_ID=' || item_id ||  '%20and%20ver_nr=' || ver_nr
from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK')
where admin_item_typ_id = 4 ;
commit;

update ADMIN_ITEM set ITEM_DEEP_LINK = (Select param_val || '/CO/FRMDD?filter=FRMDD.ITEM_ID=' || item_id || '%20and%20ver_nr=' || ver_nr
from NCI_MDR_CNTRL where PARAM_NM = 'DEEP_LINK')
where admin_item_typ_id = 54 ;
commit;

alter table admin_item enable all triggers;



  CREATE OR REPLACE VIEW "VW_NCI_DE"  AS
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
          CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           -- ADMIN_ITEM.REGSTR_STUS_NM_DN,
           -- ADMIN_ITEM.ADMIN_STUS_NM_DN,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           rs.NCI_DISP_ORDR                    REGSTR_STUS_DISP_ORD,
           ws.NCI_DISP_ORDR                    ADMIN_STUS_DISP_ORD,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
           CNTXT.NCI_PRG_AREA_ID,
           ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
	   replace (ADMIN_ITEM.ITEM_NM_ID_VER,'|Data Element','') ITEM_NM_ID_VER,
           ext.USED_BY                         CNTXT_AGG,
           REF.ref_desc                        PREF_QUEST_TXT,
        trim(SUBSTR (
                 trim(ADMIN_ITEM.ITEM_LONG_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_NM) ,1,
              4290))
              || '||'
              ||
              SUBSTR ( trim(ref_desc.REF_DESC),
             1,
              30000)                          SEARCH_STR
      FROM ADMIN_ITEM,
           VW_CNTXT            CNTXT,
           NCI_ADMIN_ITEM_EXT  ext,
           (SELECT item_id, ver_nr, ref_desc
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||' ON OVERFLOW TRUNCATE ) WITHIN GROUP (ORDER BY OBJ_KEY_DESC desc)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc,
           VW_REGSTR_STUS      rs,
           VW_ADMIN_STUS       ws
     WHERE     ADMIN_ITEM_TYP_ID = 4
           --and ADMIN_ITEM.ITEM_Id = de.item_id
           --and ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
           AND ADMIN_ITEM.REGSTR_STUS_ID = rs.STUS_ID(+)
           AND ADMIN_ITEM.ADMIN_STUS_ID = ws.STUS_ID(+)
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CNTXT.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CNTXT.VER_NR;

alter table ADMIN_ITEM add (RVWR_CMNTS  varchar2(4000));


