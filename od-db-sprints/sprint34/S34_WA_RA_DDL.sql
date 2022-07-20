-- Tracker 1915 - Data Type Reverse
alter table DATA_TYP add  (NCI_DTTYPE_MAP_ID integer);

update data_TYP a set NCI_DTTYPE_MAP_ID = (select DTTYPE_ID from DATA_TYP where 	NCI_DTTYPE_TYP_ID = 2 and DTTYPE_NM = a.NCI_DTTYPE_MAP)
where NCI_DTTYPE_TYP_ID = 1 and NCI_DTTYPE_MAP is not null;

commit;

-- Tracker 1935 - VD Alternate Name Node
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
	
-- Tracker 1672
alter table NCI_STG_PV_VM_IMPORT add (VM_ALT_NM_CNTXT_ITEM_ID number, VM_ALT_NM_CNTXT_VER_NR number(4,2));

-- Tracker 1485 
insert into NCI_AI_TYP_VALID_STUS (ADMIN_ITEM_TYP_ID, STUS_ID) values (9,65);
commit;

-- Tracker 1602
CREATE OR REPLACE  VIEW VW_NCI_VD_PV AS
  SELECT PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
              PV.VAL_DOM_ITEM_ID,
		PV.VAL_DOM_VER_NR ,PV.VAL_DOM_ITEM_ID VAL_DOM_ITEM_ID_RPT,
		PV.VAL_DOM_VER_NR VAL_DOM_VER_NR_RPT, VM.ITEM_NM, VM.ITEM_LONG_NM,
                VM.ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, vm.admin_stus_nm_dn VM_ADMIN_STUS_NM_DN,
                decode(e.cncpt_concat, e.cncpt_concat_nm, null, vm.item_long_nm, null, vm.item_id, null, e.cncpt_concat) cncpt_concat, e.CNCPT_CONCAT_NM,
		PV.CREAT_DT, PV.CREAT_USR_ID, PV.LST_UPD_USR_ID, PV.FLD_DELETE, PV.LST_DEL_DT, PV.S2P_TRN_DT, PV.LST_UPD_DT,
                PV.PRNT_CNCPT_ITEM_ID, PV.PRNT_CNCPT_VER_NR, VM.ITEM_NM || ' ' || VM.ITEM_DESC  VM_SEARCH_STR, PV.NCI_ORIGIN, PV.NCI_ORIGIN_ID
       FROM   PERM_VAL PV, ADMIN_ITEM VM, NCI_ADMIN_ITEM_EXT e where
	PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
        VM.ITEM_ID = e.ITEM_ID and
        VM.VER_NR = e.VER_NR;
	

-- Tracker 1074
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

-- Tracker 1943
alter table NCI_DS_HDR add MTCH_TYP_NM varchar2(50) default 'CDE';


-- Tracker 1943
-- VM Match add Context fo VW_CNCPT
drop materialized view VW_CNCPT;

create materialized view VW_CNCPT 
  BUILD IMMEDIATE
  REFRESH FORCE
  ON DEMAND AS SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CNTXT_ITEM_ID,
ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.CNTXT_NM_DN,
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC,
		      nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') || '|' ||
		      nvl(decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC), 'No EVS Source') DEF_EVS_SRC,
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN
              FROM ADMIN_ITEM,  CNCPT, OBJ_KEY, (select item_id, ver_nr,   LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN from ALT_NMS a group by item_id, ver_nr) a
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+);
    


drop materialized view vw_clsfctn_schm_item;


  create materialized view VW_CLSFCTN_SCHM_ITEM 
  BUILD IMMEDIATE
  REFRESH FORCE
  ON DEMAND AS
  SELECT ADMIN_ITEM.ITEM_ID,
               ADMIN_ITEM.VER_NR,
               ADMIN_ITEM.ITEM_NM,
               ADMIN_ITEM.ITEM_LONG_NM,
               ADMIN_ITEM.ITEM_DESC,
               ADMIN_ITEM.CNTXT_NM_DN,
               ADMIN_ITEM.CURRNT_VER_IND,
               ADMIN_ITEM.REGSTR_STUS_NM_DN,
               ADMIN_ITEM.ADMIN_STUS_NM_DN,
               ADMIN_ITEM.CREAT_DT,
               ADMIN_ITEM.CREAT_USR_ID,
               ADMIN_ITEM.LST_UPD_USR_ID,
               ADMIN_ITEM.FLD_DELETE,
               ADMIN_ITEM.LST_DEL_DT,
               ADMIN_ITEM.S2P_TRN_DT,
               ADMIN_ITEM.LST_UPD_DT,
               ADMIN_ITEM.NCI_IDSEQ,
               CSI.P_ITEM_ID,
               CSI.P_ITEM_VER_NR,
               CSI.CS_ITEM_ID,
               CSI.CS_ITEM_VER_NR,
               CAST (
                      cs.item_nm
                   || SYS_CONNECT_BY_PATH (REPLACE (admin_item.ITEM_NM, '|', ''),
                                           ' | ')
                       AS VARCHAR2 (4000))    FUL_PATH
          FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
         WHERE     ADMIN_ITEM_TYP_ID = 51
               AND ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID
               AND ADMIN_ITEM.VER_NR = CSI.VER_NR
               AND csi.cs_item_id = cs.item_id
               AND csi.cs_item_ver_nr = cs.ver_nr
    START WITH p_item_id IS NULL
   CONNECT BY PRIOR  to_char(csi.item_id || to_char(csi.ver_nr,'99.99')) = to_char(csi.p_item_id || to_char(csi.P_item_ver_nr,'99.99')) ;
-
