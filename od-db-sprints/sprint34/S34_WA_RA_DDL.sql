alter table DATA_TYP add  (NCI_DTTYPE_MAP_ID integer);

update data_TYP a set NCI_DTTYPE_MAP_ID = (select DTTYPE_ID from DATA_TYP where 	NCI_DTTYPE_TYP_ID = 2 and DTTYPE_NM = a.NCI_DTTYPE_MAP)
where NCI_DTTYPE_TYP_ID = 1 and NCI_DTTYPE_MAP is not null;

commit;


  CREATE OR REPLACE  VIEW VW_NCI_DE_VD_ALT_NMS As
  SELECT   DE.ITEM_ID  DE_ITEM_ID, 
		DE.VER_NR DE_VER_NR, DE.VAL_DOM_ITEM_ID VAL_DOM_ITEM_ID,  
	DE.VAL_DOM_VER_NR ,
		AN.CREAT_DT, an.CREAT_USR_ID, an.LST_UPD_USR_ID, an.FLD_DELETE, an.LST_DEL_DT, an.S2P_TRN_DT, an.LST_UPD_DT,
         an.NM_DESC,  an.nm_typ_id, an.CNTXT_NM_DN CNTXT_NM_DN  , an.CNTXT_ITEM_ID ALT_NM_CNTXT_ITEM_ID, an.CNTXT_VER_NR ALT_NM_CNTXT_VER_NR,
         an.LANG_ID, an.nm_id
       FROM  DE, ALT_NMS an where 
	DE.VAL_DOM_ITEM_ID = an.ITEM_ID and
	DE.VAL_DOM_VER_NR = an.VER_NR ;
	
	alter table NCI_STG_PV_VM_IMPORT add (VM_ALT_NM_CNTXT_ITEM_ID number, VM_ALT_NM_CNTXT_VER_NR number(4,2));

insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (9,65);
commit;

CREATE OR REPLACE  VIEW VW_NCI_VD_PV AS
  SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              PV.VAL_DOM_ITEM_ID,
		PV.VAL_DOM_VER_NR ,VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR, PV.NCI_ORIGIN, PV.NCI_ORIGIN_ID
       FROM   PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR;
	
	
	  CREATE OR REPLACE  VIEW VW_NCI_CSI_AI AS
  select  aim.c_item_id item_id, aim.c_item_ver_nr ver_nr, aim.p_item_id csi_item_id, aim.p_item_ver_nr csi_ver_nr,
  csi.item_nm csi_ITEM_NM, csi.cs_item_id CS_ITEM_ID, csi.CS_ITEM_VER_NR CS_VER_NR, aim.rel_typ_id,
 csi.item_long_nm  csi_item_long_nm, csi.item_desc csi_item_desc, csi.p_item_Id p_CS_ITEM_ID, csi.P_ITEM_VER_NR p_CS_VER_NR,
aim.CREAT_DT, aim.CREAT_USR_ID, aim.LST_UPD_USR_ID, aim.FLD_DELETE, aim.LST_DEL_DT, aim.S2P_TRN_DT, aim.LST_UPD_DT,
 csi.item_nm || ' ' || cs.ITEM_NM CSI_SEARCH_STR, cs.ITEM_NM  CS_ITEM_NM, cs.ITEM_LONG_NM CS_ITEM_LONG_NM,
 cs.cntxt_item_id , cs.cntxt_ver_nr, csi.ful_path,
 ai.item_nm, ai.item_long_nm, ai.regstr_stus_nm_dn, ai.admin_stus_nm_dn, ai.cntxt_nm_dn, ai.admin_item_typ_id
from   VW_CLSFCTN_SCHM_ITEM csi, nci_admin_item_rel aim, vw_CLSFCTN_SCHM cs, admin_item ai
where csi.item_id = aim.p_item_id and csi.ver_nr = aim.p_item_ver_nr
and aim.rel_typ_id = 65
and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and aim.c_item_id = ai.item_id and aim.c_item_ver_nr = ai.ver_nr;


