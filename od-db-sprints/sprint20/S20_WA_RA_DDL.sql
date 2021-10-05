 CREATE OR REPLACE  VIEW VW_NCI_DE_PV_LEAN AS
  SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT ITEM_NM,
              DE.ITEM_ID  DE_ITEM_ID,
		DE.VER_NR DE_VER_NR, 
             NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT
       FROM  DE, PERM_VAL PV where
	PV.VAL_DOM_ITEM_ID = DE.VAL_DOM_ITEM_ID and
	PV.VAL_DOM_VER_NR = DE.VAL_DOM_VER_NR;
	
alter table 	NCI_DS_HDR add (NUM_CDE_MTCH  integer);
alter table 	NCI_DS_HDR add (NUM_PV  integer);
alter table 	NCI_DS_HDR add (BTCH_NM  varchar2(50));


drop table nci_ds_rslt_detl;

truncate table NCI_FORM_TA;

alter table NCI_FORM_TA add (FORM_ITEM_ID number not null, FORM_VER_NR number(4,2) not null, MOD_ITEM_ID number not null, MOD_VER_NR number(4,2) not null);


