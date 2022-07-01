alter table DATA_TYP add  (NCI_DTTYPE_MAP_ID integer);

update data_TYP a set NCI_DTTYPE_MAP_ID = (select DTTYPE_ID from DATA_TYP where 	NCI_DTTYPE_TYP_ID = 2 and DTTYPE_NM = a.NCI_DTTYPE_MAP)
where NCI_DTTYPE_TYP_ID = 1 and NCI_DTTYPE_MAP is not null;

commit;


  CREATE OR REPLACE  VIEW VW_NCI_DE_VD_ALT_NMS As
  SELECT   DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, DE.VAL_DOM_ITEM_ID VAL_DOM_ITEM_ID,  
	DE.VAL_DOM_VER_NR ,
		AN.CREAT_DT, an.CREAT_USR_ID, an.LST_UPD_USR_ID, an.FLD_DELETE, an.LST_DEL_DT, an.S2P_TRN_DT, an.LST_UPD_DT,
         an.NM_DESC,  an.nm_typ_id, an.CNTXT_NM_DN VM_CNTXT_NM_DN  ,
         an.LANG_ID, an.nm_id
       FROM  DE, ALT_NMS an where 
	DE.VAL_DOM_ITEM_ID = an.ITEM_ID and
	DE.VAL_DOM_VER_NR = an.VER_NR ;
	
	alter table NCI_STG_PV_VM_IMPORT add (VM_ALT_NM_CNTXT_ITEM_ID number, VM_ALT_NM_CNTXT_VER_NR number(4,2));
