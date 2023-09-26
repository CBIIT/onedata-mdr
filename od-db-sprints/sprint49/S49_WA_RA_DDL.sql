--alter table NCI_MEC_MAP add ( MEC_SUB_GRP_NBR integer);
alter table NCI_STG_MDL add (CNTXT_ITEM_ID number, CNTXT_VER_NR number(4,2));

alter table NCI_STG_MDL_ELMNT add ( IMP_GRP_NM  varchar2(1000), ME_GRP_ID integer);

alter table NCI_MDL_ELMNT add (  ME_GRP_ID integer);

alter table NCI_STG_MDL_ELMNT_CHAR add (  CMNTS_DESC_TXT varchar2(4000));



	
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (49,'Mapping Groups');
	     commit;
