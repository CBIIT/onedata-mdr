create table NCI_MDL
(ITEM_ID number not null,
  VER_NR number(4,2) not null,
  PRMRY_MDL_LANG_ID  integer null,
  CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
	CMNTS_DESC_TXT varchar2(4000)
primary key (ITEM_ID, ver_NR));


create or replace view vw_nci_mdl as select
	ai.*, m.prmry_mdl_lang_id from admin_item ai, nci_mdl m where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 57;

create table NCI_MDL_ELMNT
( ITEM_ID number not null,
  VER_NR number (4,2) not null,
  MDL_ITEM_ID  number not null,
  MDL_ITEM_VER_NR number(4,2) not null,
  ITEM_LONG_NM varchar2(255) not null,
  ITEM_PHY_OBJ_NM varchar2(255) null,
	ITEM_DESC varchar2(4000) null,
	DOM_ITEM_ID number,
	DOM_VER_NR  number(4,2),
  CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
	ME_TYP_ID integer,
  primary key (ITEM_ID, VER_NR));

create table NCI_MDL_ELMNT_REL
( REL_ID number not null primary key, 
  PRNT_ITEM_ID number not null,
  PRNT_ITEM_VER_NR number (4,2) not null,
  CHLD_ITEM_ID number not null,
  CHLD_ITEM_VER_NR number (4,2) not null,
  REL_TYP_ID integer not null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate);

create table NCI_MDL_ELMNT_CHAR
( MEC_ID number not null primary key,
  MDL_ELMNT_ITEM_ID number not null,
  MDL_ELMNT_VER_NR number (4,2) not null,
  MEC_TYP_ID integer null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate,
		SRC_DTTYPE varchar2(255), 
	STD_DTTYPE_ID NUMBER, 
       SRC_MAX_CHAR NUMBER(*,0), 
	 SRC_MIN_CHAR NUMBER(*,0), 
	VAL_DOM_TYP_ID NUMBER, 
	SRC_UOM  varchar2(255),
	UOM_ID NUMBER, 
	SRC_DEFLT_VAL varchar2(4000), 
  SRC_ENUM_SRC  varchar2(255),
	DE_CONC_ITEM_ID number,
	DE_CONC_VER_NR number(4,2),
	VAL_DOM_ITEM_ID number,
	VAL_DOM_VER_NR  number(4,2),
	CDE_ITEM_ID number,
	CDE_VER_NR number(4,2),
	NUM_PV integer,
	MEC_LONG_NM  varchar2(255),
	MEC_PHY_NM  varchar2(255),
	MEC_DESC varchar2(4000));


create or replace view vw_NCI_MEC
	as select m.item_id mdl_item_id, m.ver_nr mdl_ver_nr, m.item_nm mdl_item_nm, me.item_id ME_ITEM_ID, me.ver_nr me_VER_NR,
	me.ITEM_LONG_NM me_item_nm, me.ITEM_PHY_OBJ_NM me_phy_nm, mec.*
	from admin_item m, NCI_MDL_ELMNT me,NCI_MDL_ELMNT_CHAR mec
	where m.item_id = me.mdl_item_id and m.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID
	and me.ver_nr = mec.MDL_ELMNT_VER_NR and m.admin_item_typ_id = 57;

	
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (57,'Model',4,'Model','Model','Model' );
commit;


insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (58,'Model Mapping',4,'Model Mapping','Model Mapping','Model Mapping' );
commit;

	insert into obj_typ (obj_typ_id, obj_typ_desc) values (40,'Modelling Language');
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (41,'Model Element Type');
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (42,'Model Element Relationship');
        insert into obj_typ (obj_typ_id, obj_typ_desc) values (43,'Model Element Relationship Cardinality');

       commit;

insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (57,66);
insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (57,75);
insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (57,77);
commit;

insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (58,66);
insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (58,75);
insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (58,77);
commit;

create table NCI_MDL_MAP
(ITEM_ID number not null,
  VER_NR number(4,2) not null,
  SRC_MDL_ITEM_ID number not null,
  SRC_MDL_VER_NR number(4,2) not null,
  TGT_MDL_ITEM_ID number not null,
  TGT_MDL_VER_NR number(4,2) not null,
  CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate, 
primary key (ITEM_ID, ver_NR));

create table NCI_MEC_MAP
( MECM_ID number not null primary key,
  SRC_MEC_ID number null,
  TGT_MEC_ID number null,
  MDL_MAP_ITEM_ID number not null,
  MDL_MAP_VER_NR number(4,2) not null,
	TRNS_DESC_TXT varchar2(1000) null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate
);

create table NCI_MEC_VAL_MAP
( MECVM_ID number not null primary key,
  SRC_MEC_ID number not null,
  TGT_MEC_ID number not null,
  MDL_MAP_ITEM_ID number not null,
  MDL_MAP_VER_NR number(4,2) not null,
	SRC_PV  varchar2(255) null,
	TGT_PV  varchar2(255) null,
	VM_CNCPT_CD varchar2(4000) null,
	VM_CNCPT_NM varchar2(4000) null,
   CREAT_DT DATE  DEFAULT sysdate, 
	CREAT_USR_ID VARCHAR2(50) DEFAULT user, 
	LST_UPD_USR_ID VARCHAR2(50) DEFAULT user, 
	FLD_DELETE NUMBER(1,0) DEFAULT 0, 
	LST_DEL_DT DATE DEFAULT sysdate, 
	S2P_TRN_DT DATE DEFAULT sysdate, 
	LST_UPD_DT DATE DEFAULT sysdate
);




