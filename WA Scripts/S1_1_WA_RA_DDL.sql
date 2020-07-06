

create table NCI_AI_TYP_VALID_STUS
( ADMIN_ITEM_TYP_ID integer not null,
  STUS_ID  integer not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
primary key (ADMIN_ITEM_TYP_ID, STUS_ID));

create table NCI_ENTTY
( ENTTY_ID number not null primary key,
  ENTTY_TYP_ID  integer not null,
  NCI_IDSEQ  char(36) not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_ORG
( ENTTY_ID number not null primary key,
   RAI  varchar2(255) null,
 ORG_NM varchar2(80) not null,
 RA_IND  varchar2(3) null,
  MAIL_ADDR  varchar2(240) null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_PRSN
( ENTTY_ID number not null primary key,
  PRNT_ORG_ID  number null,
  LAST_NM varchar2(80) not null,
  FIRST_NM varchar2(30) not null,
  RNK_ORD  number(3,0) not null,
  MI varchar2(2) null,
  POS varchar2(80) null,
       CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);

create table NCI_ENTTY_COMM
( ENTTY_ID number not null,
  COMM_TYP_ID integer not null, 
  RNK_ORD  number(3,0) not null,
  CYB_ADDR varchar2(255) not null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
   primary key (ENTTY_ID, COMM_TYP_ID, RNK_ORD));

create table NCI_ENTTY_ADDR
( ENTTY_ID number not null,
  ADDR_TYP_ID integer not null, 
  RNK_ORD number(3,0) not null,
  ADDR_LINE1  varchar2(80) not null,
  ADDR_LINE2 varchar2(80) null,
  CITY  varchar2(30) not null,
  STATE_PROV varchar2(30) not null,
  POSTAL_CD varchar2(10) not null,
  CNTRY  varchar2(30) null,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL,
   primary key (ENTTY_ID, ADDR _TYP_ID, RNK_ORD));


create table NCI_CHANGE_HISTORY
(ACCH_IDSEQ  char(36) not null primary key,
 AC_IDSEQ char(36) not null,
CHANGE_DATETIMESTAMP date NOT NULL,           
CHANGE_ACTION        VARCHAR2(10) NOT NULL  ,  
CHANGED_BY           VARCHAR2(30) NOT NULL  , 
CHANGED_TABLE         VARCHAR2(30)   NOT NULL ,
CHANGED_TABLE_IDSEQ   CHAR(36)   NOT NULL  ,   
CHANGED_COLUMN        VARCHAR2(30) NOT NULL ,  
OLD_VALUE                     VARCHAR2(4000), 
NEW_VALUE                     VARCHAR2(4000) ,
      CREAT_DT             DATE DEFAULT sysdate NULL,
       CREAT_USR_ID         VARCHAR2(50) DEFAULT user NULL,
       LST_UPD_USR_ID       VARCHAR2(50) DEFAULT user NULL,
       FLD_DELETE           NUMBER(1) DEFAULT 0 NULL,
       LST_DEL_DT           DATE DEFAULT sysdate NULL,
       S2P_TRN_DT           DATE DEFAULT sysdate NULL,
       LST_UPD_DT           DATE DEFAULT sysdate NOT NULL);


alter table ref_doc add (NCI_MIME_TYPE	VARCHAR2(128 BYTE) null, 
NCI_DOC_SIZE	number null,
NCI_CHARSET	VARCHAR2(128 BYTE) null,
NCI_DOC_LST_UPD_DT	DATE null,
NCI_REF_ID  number not null);


alter table REF_DOC modify (REF_DOC_TYP_ID null);


--- Tracker - VW_NCI_DE_HORT


  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT AS 
  SELECT 
	ADMIN_ITEM.ITEM_ID ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
	ADMIN_ITEM.ITEM_NM, 
	ADMIN_ITEM.ITEM_LONG_NM, 
	ADMIN_ITEM.ITEM_DESC, 
	ADMIN_ITEM.CNTXT_NM_DN, 
	ADMIN_ITEM.ORIGIN, 
	ADMIN_ITEM.UNTL_DT, 
	ADMIN_ITEM.CURRNT_VER_IND, 
	DE.DE_PREC,
	DE.DE_CONC_ITEM_ID,
	DE.DE_CONC_VER_NR, 
	DE.VAL_DOM_VER_NR, 
	DE.VAL_DOM_ITEM_ID,
	DE.REP_CLS_VER_NR, 
	DE.REP_CLS_ITEM_ID, 
DE.DERV_DE_IND,
DE.DERV_MTHD,
DE.DERV_RUL,
DE.DERV_TYP_ID,
	DE.CREAT_USR_ID, 
	DE.LST_UPD_USR_ID, 
	DE.FLD_DELETE, 
	DE.LST_DEL_DT, 
	DE.S2P_TRN_DT, 
	DE.LST_UPD_DT, 
	DE.CREAT_DT, 
	DE.CREAT_USR_ID CREAT_USR_ID_API, 
	DE.LST_UPD_USR_ID LST_UPD_USR_ID_API, 
	DE.CREAT_DT CREAT_DT_API, 
	DE.LST_UPD_DT LST_UPD_DT_API, 
	VALUE_DOM.CONC_DOM_VER_NR, 
	VALUE_DOM.CONC_DOM_ITEM_ID, 
	VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
	VALUE_DOM.UOM_ID, 
	VALUE_DOM.VAL_DOM_TYP_ID VAL_DOM_TYP_ID, 
	VALUE_DOM.VAL_DOM_MIN_CHAR, 
	VALUE_DOM.VAL_DOM_FMT_ID, 
	VALUE_DOM.CHAR_SET_ID, 
	VALUE_DOM.CREAT_DT VALUE_DOM_CREAT_DT, 
	VALUE_DOM.CREAT_USR_ID VALUE_DOM_USR_ID, 
	VALUE_DOM.LST_UPD_USR_ID VALUE_DOM_LST_UPD_USR_ID, 
	VALUE_DOM.LST_UPD_DT VALUE_DOM_LST_UPD_DT,
	VALUE_DOM_AI.ITEM_NM VALUE_DOM_ITEM_NM, 
	VALUE_DOM_AI.ITEM_LONG_NM VALUE_DOM_ITEM_LONG_NM, 
	VALUE_DOM_AI.ITEM_DESC  VALUE_DOM_ITEM_DESC, 
	VALUE_DOM_AI.CNTXT_NM_DN VALUE_DOM_CNTXT_NM, 
	VALUE_DOM_AI.CURRNT_VER_IND VALUE_DOM_CURRNT_VER_IND, 
	VALUE_DOM_AI.REGSTR_STUS_NM_DN VALUE_DOM_REGSTR_STUS_NM, 
	VALUE_DOM_AI.ADMIN_STUS_NM_DN VALUE_DOM_ADMIN_STUS_NM, 
	VALUE_DOM.NCI_STD_DTTYPE_ID,
    VALUE_DOM.DTTYPE_ID,
	ADMIN_ITEM.REGSTR_AUTH_ID,
	DEC_AI.ITEM_NM DEC_ITEM_NM, 
	DEC_AI.ITEM_LONG_NM DEC_ITEM_LONG_NM, 
	DEC_AI.ITEM_DESC  DEC_ITEM_DESC, 
	DEC_AI.CNTXT_NM_DN DEC_CNTXT_NM, 
	DEC_AI.CURRNT_VER_IND DEC_CURRNT_VER_IND, 
	DEC_AI.REGSTR_STUS_NM_DN DEC_REGSTR_STUS_NM, 
	DEC_AI.ADMIN_STUS_NM_DN DEC_ADMIN_STUS_NM, 
	DE_CONC.OBJ_CLS_ITEM_ID,
	DE_CONC.OBJ_CLS_VER_NR,
        OC.ITEM_NM OBJ_CLS_ITEM_NM,
        OC.ITEM_LONG_NM OBJ_CLS_ITEM_LONG_NM,
        PROP.ITEM_NM PROP_ITEM_NM,
        PROP.ITEM_LONG_NM PROP_ITEM_LONG_NM,
	DE_CONC.PROP_ITEM_ID,
	DE_CONC.PROP_VER_NR,
	CD_AI.ITEM_NM CD_ITEM_NM, 
	CD_AI.ITEM_LONG_NM CD_ITEM_LONG_NM, 
	CD_AI.ITEM_DESC  CD_ITEM_DESC, 
	CD_AI.CNTXT_NM_DN CD_CNTXT_NM, 
	CD_AI.CURRNT_VER_IND CD_CURRNT_VER_IND, 
	CD_AI.REGSTR_STUS_NM_DN CD_REGSTR_STUS_NM, 
	CD_AI.ADMIN_STUS_NM_DN CD_ADMIN_STUS_NM, 
	       ADMIN_ITEM.ADMIN_ITEM_TYP_ID ,
        '' CNTXT_AGG,
        SYSDATE - greatest(DE.LST_UPD_DT, admin_item.lst_upd_dt, Value_dom.LST_UPD_DT, dec_ai.LST_UPD_DT) LST_UPD_CHG_DAYS
       FROM ADMIN_ITEM, DE,  VALUE_DOM, ADMIN_ITEM VALUE_DOM_AI, 
	ADMIN_ITEM DEC_AI, DE_CONC,
	ADMIN_ITEM CD_AI, ADMIN_ITEM OC, ADMIN_ITEM PROP
       WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
and DE.DE_CONC_VER_NR = DEC_AI.VER_NR
and DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
and DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
and DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
and DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
and DE_CONC.PROP_VER_NR = PROP.VER_NR
and DE.DE_CONC_VER_NR = DE_CONC.VER_NR
and DE_CONC.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
and DE_CONC.CONC_DOM_VER_NR = CD_AI.VER_NR;

-- Tracker # 328 - Added Origin ID DN


  CREATE OR REPLACE  VIEW VW_NCI_DE AS
  select 
	ADMIN_ITEM.ITEM_ID, 
	ADMIN_ITEM.VER_NR, 
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
	ADMIN_ITEM.REGSTR_STUS_NM_DN,
	ADMIN_ITEM.ADMIN_STUS_NM_DN,
	ADMIN_ITEM.CNTXT_NM_DN,
	ADMIN_ITEM.CNTXT_ITEM_ID,
	ADMIN_ITEM.CNTXT_VER_NR,
	ADMIN_ITEM.CREAT_USR_ID, 
	ADMIN_ITEM.LST_UPD_USR_ID, 
	ADMIN_ITEM.FLD_DELETE, 
	ADMIN_ITEM.LST_DEL_DT, 
	ADMIN_ITEM.S2P_TRN_DT, 
	ADMIN_ITEM.LST_UPD_DT, 
	ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.NCI_IDSEQ,
ADMIN_ITEM_TYP_ID,
  ext.USED_BY CNTXT_AGG,
	ref.ref_desc PREF_QUEST_TXT,
	    substr(ADMIN_ITEM.ITEM_LONG_NM || 	ADMIN_ITEM.ITEM_NM || nvl(ref.ref_desc, ''),1,4000)  SEARCH_STR 
from ADMIN_ITEM, 
NCI_ADMIN_ITEM_EXT ext,
 (select item_id, ver_nr, ref_desc from ref where ref_typ_id = 80) ref
  where ADMIN_ITEM_TYP_ID = 4 
--and ADMIN_ITEM.ITEM_Id = de.item_id 
--and ADMIN_ITEM.VER_NR = DE.VER_NR
and ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
and ADMIN_ITEM.VER_NR = EXT.VER_NR
and ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
and ADMIN_ITEM.VER_NR = REF.VER_NR(+);



-- Tracker 
alter table PERM_VAL add  (PRNT_CNCPT_ITEM_ID number null, PRNT_CNCPT_VER_NR number(4,2) null);





--VW_NCI_CSI_DE Tracker 324


  CREATE OR REPLACE  VIEW VW_NCI_CSI_DE as
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, ai.item_id csi_item_id, ai.ver_nr csi_ver_nr, 
  ai.item_nm csi_ITEM_NM, air.cntxt_cs_item_id CS_ITEM_ID, air.CNTXT_CS_VER_NR CS_VER_NR, aim.rel_typ_id,
 ai.item_long_nm  csi_item_long_nm, ai.item_desc csi_item_desc, air.p_item_Id p_CS_ITEM_ID, air.P_ITEM_VER_NR p_CS_VER_NR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT
from admin_item ai, nci_admin_item_rel_alt_key air, nci_alt_key_admin_item_rel aim 
where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr 
and air.rel_typ_id = 64
and aim.nci_pub_id = air.nci_pub_id and aim.nci_ver_nr = air.nci_ver_nr;


-- Tracker 323

create or replace view vw_nci_module_de as
select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr, 
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord,
aim.item_nm MOD_ITEM_NM,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod 
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62) 
and frm.admin_item_typ_id in ( 54,55) ;


-- Missing in core MDR.

alter table ref_doc add (BLOB_COL BLOB);

