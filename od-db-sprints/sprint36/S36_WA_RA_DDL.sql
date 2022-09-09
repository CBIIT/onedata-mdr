-- New download collection Type


insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (31, 'Printer Friendly Form', 113, 'Printer Friendly Form', 
											'Printer Friendly Form');
commit;

-- Download URL
alter table admin_item add ITEM_RPT_URL varchar2(255);

-- Tracker 2104

alter table NCI_STG_PV_VM_IMPORT add VW_SPEC_DEF varchar2(6000);



-- Data Audit table

create table NCI_DATA_AUDT 
( DA_ID number not null primary key,
ITEM_ID number not null,
  VER_NR number not null,
  ADMIN_ITEM_TYP_ID int  null,
  ACTION_TYP  char(1) not null,
  LVL varchar2(100) not null,
  LVL_PK  varchar2(255) null,
  ATTR_NM  varchar2(255) null,
  FROM_VAL  varchar2(4000) null,
  TO_VAL varchar2(4000) null,
  CREAT_USR_ID_AUDT varchar2(255) null,
  LST_UPD_USR_ID_AUDT varchar2(255) null,
  CREAT_DT_AUDT date null,
  LST_UPD_DT_AUDT date null,
LVL_1_ITEM_ID  number, LVL_1_VER_NR number(4,2), LVL_1_ITEM_NM varchar2(255), LVL_1_DISP_ORD integer,
    LVL_2_ITEM_ID number, LVL_2_VER_NR number(4,2), LVL_2_ITEM_NM varchar2(255), LVL_2_DISP_ORD integer,
    LVL_3_ITEM_ID number, LVL_3_VER_NR number(4,2), LVL_3_ITEM_NM varchar2(255), LVL_3_DISP_ORD integer,
  tbl_nm varchar2(50), obj_id number, ATTR_NM_STD varchar2(255),
 AUDT_CMNTS varchar2(4000) null,
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE)  DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate);
  
  
  CREATE OR REPLACE  VIEW VW_NCI_DATA_AUDT_FORM
  AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete') ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS" from NCI_DATA_AUDT;


  CREATE OR REPLACE  VIEW VW_NCI_DATA_AUDT
  AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete') ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS" from NCI_DATA_AUDT;

-- Tracker 2082
create or replace view VW_ADMIN_ITEM_WITH_EXT
as
select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, ai.ITEM_NM, ai.ADMIN_NOTES, ai.CHNG_DESC_TXT, 
ai.EFF_DT, ai.ORIGIN, ai.UNRSLVD_ISSUE, ai.UNTL_DT, ai.ADMIN_ITEM_TYP_ID,ai. CURRNT_VER_IND, ai.ADMIN_STUS_ID, 
ai.REGSTR_STUS_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,
decode(e.CNCPT_CONCAT,e.cncpt_concat_nm, null, e.cncpt_concat)  cncpt_concat, e.CNCPT_CONCAT_NM, e.CNCPT_CONCAT_DEF
from admin_item ai, nci_admin_item_Ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr;


-- Tracker 2092

  CREATE OR REPLACE  VIEW VW_NCI_DE AS
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


-- Tracker 1918
  CREATE OR REPLACE VIEW VW_NCI_AI_FORM AS
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
           CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
          nvl(greatest(ADMIN_ITEM.FLD_DELETE,PROT.FLD_DELETE),0) FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.ITEM_DESC,
         trim(SUBSTR (
                 trim(ADMIN_ITEM.ITEM_LONG_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_NM)
              || '||'
              || trim(ADMIN_ITEM.ITEM_DESC),1,
              4290))         SEARCH_STR,
	      P_ITEM_ID PROT_ITEM_ID, P_ITEM_VER_NR PROT_ITEM_VER_NR
      FROM ADMIN_ITEM  ADMIN_ITEM, NCI_ADMIN_ITEM_REL prot
     WHERE     ADMIN_ITEM.ITEM_ID = PROT.c_ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = PROT.C_ITEM_VER_NR(+)
           and prot.rel_typ_id (+) = 60 
	   and ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 54;
       
-- Tracker 2081

  CREATE OR REPLACE VIEW VW_ADMIN_ITEM_VM_MATCH AS
  SELECT CNTXT_ITEM_ID, admin_item_typ_id, ITEM_DESC, ITEM_LONG_NM, REGSTR_STUS_ID, ai.ITEM_ID, ai.VER_NR, ITEM_NM, ai.CREAT_DT, CNTXT_VER_NR, ADMIN_STUS_ID,
   ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN,
  decode(admin_item_typ_id, 49, ITEM_LONG_NM, 53, ai.ITEM_ID, ITEM_NM)  ID_OR_CODE, 
  decode(admin_item_typ_id, 53, decode(e.cncpt_concat, e.cncpt_concat_nm, '',e.cncpt_concat),'') VM_CONCEPTS, 
  decode(admin_item_typ_id, 49, 'Concepts', 53 ,'ID', 'Other') MATCH_TYP
       FROM ADMIN_ITEM ai, NCI_ADMIN_ITEM_EXT e where admin_item_typ_id in (49,53)
       and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr;

-- Tracker 2106
alter table NCI_STG_CDE_CREAT add (DT_LAST_MODIFIED VARCHAR2(32) DEFAULT sysdate);
commit;

CREATE OR REPLACE TRIGGER OD_TR_CDE_UPD 
BEFORE UPDATE ON NCI_STG_CDE_CREAT
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;

create or replace TRIGGER OD_TR_CDE_CREAT
BEFORE INSERT  on NCI_STG_CDE_CREAT
for each row
BEGIN
IF (:NEW.STG_AI_ID = -1  or :NEW.STG_AI_ID is null)  THEN select od_seq_CDE_IMPORT.nextval
into :new.STG_AI_ID  from  dual ;
END IF;
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;

alter table NCI_STG_ALT_NMS add (DT_LAST_MODIFIED VARCHAR2(32) DEFAULT sysdate);
commit;

CREATE OR REPLACE TRIGGER OD_TR_CDE_UPD 
BEFORE UPDATE ON NCI_STG_ALT_NMS
for each row
BEGIN
:new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;

--Tracker 2086
alter table NCI_STG_PV_VM_IMPORT add (VM_ALT_NM_LANG VARCHAR2(16));
commit;


--Tracker 2126, 2117
alter table NCI_DS_HDR add (DT_LAST_MODIFIED VARCHAR2(32) DEFAULT sysdate);
commit;

create or replace TRIGGER OD_TR_DS_HDR  BEFORE INSERT  on  NCI_DS_HDR for each row
         BEGIN    IF (:NEW.HDR_ID<= 0  or :NEW.HDR_ID is null)  THEN 
         select od_seq_DS_HDR.nextval
    into :new.HDR_ID  from  dual ;   END IF; 
      :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
      END ;

CREATE OR REPLACE TRIGGER OD_TR_DS_UPD 
BEFORE UPDATE ON NCI_DS_HDR
for each row
BEGIN
  :new.DT_LAST_MODIFIED := TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS');
END;


