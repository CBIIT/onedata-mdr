--alter table CNCPT add (PRNT_ITEM_ID number, PRNT_ITEM_VER_NR number);

--alter table NCI_USR_CART add RETAIN_IND number(1);


insert into obj_key (obj_typ_id, obj_key_Desc, obj_key_id, obj_key_def, NCI_CD) values (17, 'NCIT Concept Relationship', 68, 'NCIT Concept Relationship', 
											'NCIT Concept Relationship');
commit;


update admin_item set Item_desc = replace(item_desc,'alert','axxxt') where upper(item_desc) like '%JAVASCRIPT:ALERT%' and cntxt_nm_dn = 'TEST';
update admin_item set Item_nm = replace(item_desc,'alert','axxxt') where upper(item_nm) like '%JAVASCRIPT:ALERT%' and cntxt_nm_dn = 'TEST';

commit;

  CREATE OR REPLACE VIEW VW_LIST_USR_CART_NM AS
  SELECT distinct CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, 0 RETAIN_IND, 
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART where nvl(fld_delete,0)  =0;
	   
create table NCI_CNCPT_REL
   (	"P_ITEM_VER_NR" NUMBER(4,2) not null, 
	"P_ITEM_ID" NUMBER not null, 
	"C_ITEM_VER_NR" NUMBER(4,2) not null, 
	"C_ITEM_ID" NUMBER not null, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"REL_TYP_ID" INTEGER not null,
	"DISP_ORD" INTEGER,
    primary key( P_ITEM_ID, P_ITEM_VER_NR,C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID));
   

  CREATE OR REPLACE VIEW VW_NCI_DATA_AUDT_FORM AS
  select "DA_ID","ITEM_ID","VER_NR","ADMIN_ITEM_TYP_ID",decode(ACTION_TYP, 'I', 'Insert','U', 'Update','D', 'Delete','M','Manual Delete') ACTION_TYP,
  "LVL","LVL_PK", ATTR_NM_STD ATTR_NM,"FROM_VAL","TO_VAL","CREAT_USR_ID_AUDT",LVL_1_ITEM_ID , LVL_1_VER_NR , LVL_1_ITEM_NM,
  LVL_2_ITEM_ID , LVL_2_VER_NR , LVL_2_ITEM_NM,LVL_3_ITEM_ID , LVL_3_VER_NR , LVL_3_ITEM_NM,
LVL_1_DISP_ORD ,LVL_2_DISP_ORD,LVL_3_DISP_ORD ,
  "LST_UPD_USR_ID_AUDT","CREAT_DT_AUDT","LST_UPD_DT_AUDT","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","AUDT_CMNTS"
  from NCI_DATA_AUDT where (((item_id, ver_nr) in (Select item_id, ver_nr from nci_form)) or action_typ ='M');
  
  
alter table nci_stg_form_quest_import modify SRC_QUESTION_ID varchar2(4000);
alter table nci_stg_form_quest_import modify SRC_QUEST_LBL varchar2(4000);

alter table admin_item add (MTCH_TERM varchar2(255), MTCH_TERM_ADV varchar(255));
alter table ALT_NMS add (MTCH_TERM varchar2(4000), MTCH_TERM_ADV varchar(4000));
alter table REF add (MTCH_TERM varchar2(4000), MTCH_TERM_ADV varchar(4000));



