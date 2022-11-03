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
   (	"PRNT_CNCPT_VER_NR" NUMBER(4,2) not null, 
	"PRNT_CNCPT_ITEM_ID" NUMBER not null, 
	"CHLD_CNCPT_VER_NR" NUMBER(4,2) not null, 
	"CHLD_CNCPT_ITEM_ID" NUMBER not null, 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"REL_TYP_ID" INTEGER not null,
	"DISP_ORD" INTEGER,
    primary key( PRNT_CNCPT_ITEM_ID, PRNT_CNCPT_VER_NR,CHLD_CNCPT_ITEM_ID, CHLD_cNCPT_VER_NR, REL_TYP_ID));
   
