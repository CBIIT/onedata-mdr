
  CREATE OR REPLACE  VIEW VW_NCI_MODULE_DE AS
  select frm.item_long_nm frm_item_long_nm, frm.item_nm frm_item_nm, frm.item_id frm_item_id, frm.ver_nr frm_ver_nr,
air.p_item_id mod_item_id, air.p_item_ver_nr mod_ver_nr,
 air.c_item_id de_item_id, air.c_item_ver_nr de_ver_nr, air.disp_ord quest_disp_ord,frm_mod.disp_ord mod_disp_ord,
aim.item_nm MOD_ITEM_NM, air.instr,
 aim.item_long_nm  mod_item_long_nm, aim.item_desc mod_item_desc,
'QUESTION' admin_item_typ_nm, air.nci_pub_id,air.nci_ver_nr,
de.CNTXT_NM_DN, de.item_nm DE_ITEM_NM, de.cntxt_item_id DE_CNTXT_ITEM_ID, de.cntxt_VER_NR DE_CNTXT_VER_NR,
air.CREAT_DT, air.CREAT_USR_ID, air.LST_UPD_USR_ID, air.FLD_DELETE, air.LST_DEL_DT, air.S2P_TRN_DT, air.LST_UPD_DT, air.item_long_nm QUEST_LONG_TXT, air.item_nm QUEST_TXT
from  nci_admin_item_rel_alt_key air, admin_item aim,
admin_item frm, nci_admin_item_rel frm_mod , admin_item de
where  air.rel_typ_id = 63
and aim.item_id = air.p_item_id and aim.ver_nr = air.p_item_ver_nr
and frm.item_id = frm_mod.p_item_id and frm.ver_nr = frm_mod.p_item_ver_nr and aim.item_id = frm_mod.c_item_id and aim.ver_nr = frm_mod.c_item_ver_nr
and frm_mod.rel_typ_id in (61,62)
and frm.admin_item_typ_id in ( 54,55)
and air.c_item_id = de.item_id
and air.c_item_ver_nr = de.ver_nr;

alter table CNCPT add (PRMRY_CNCPT_IND  number(1) default 0);


  CREATE OR REPLACE  VIEW VW_CNCPT AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, 
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC
       FROM ADMIN_ITEM, CNCPT, OBJ_KEY
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED';



  CREATE OR REPLACE  VIEW VW_NCI_USED_BY AS
  select ITEM_ID, VER_NR , CNTXT_ITEM_ID, CNTXT_VER_NR, max(owned_by) OWNED_BY, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from (
	SELECT distinct DE.ITEM_ID, DE.VER_NR, de.CNTXT_ITEM_ID, de.CNTXT_VER_NR, 1 OWNED_BY, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID,
	'ONEDATA' LST_UPD_USR_ID, de.FLD_DELETE, de.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM ADMIN_ITEM DE
       WHERE nvl(de.fld_delete,0) = 0
      and de.admin_item_typ_id = 4
	union
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.CNTXT_ITEM_ID, a.CNTXT_VER_NR, 0, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, ALT_NMS a
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
      and a.CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.NCI_CNTXT_ITEM_ID, a.NCI_CNTXT_VER_NR, 0, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, REF a
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
      and a.NCI_CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.C_ITEM_ID, DE.C_ITEM_VER_NR, cs.CNTXT_ITEM_ID, cs.CNTXT_VER_NR, 0, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, cscsi.FLD_DELETE, cscsi.LST_DEL_DT, sysdate S2P_TRN_DT,
  sysdate LST_UPD_DT
       FROM NCI_ALT_KEY_ADMIN_ITEM_REL de, NCI_ADMIN_ITEM_REL_ALT_KEY cscsi, admin_item cs
       WHERE DE.NCI_PUB_ID = cscsi.NCI_PUB_ID and de.NCI_VER_NR = cscsi.NCI_VER_NR
       and nvl(cscsi.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
       and nvl(cs.fld_delete,0) = 0
       and cscsi.CNTXT_CS_ITEM_ID = cs.item_id and
       cscsi.CNTXT_CS_VER_NR = cs.ver_nr and
       cs.admin_item_typ_id = 9       and cs.CNTXT_ITEM_ID is not null
union
  SELECT distinct quest.C_ITEM_ID, quest.C_ITEM_VER_NR, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, 0, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, quest.FLD_DELETE, quest.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM NCI_ADMIN_ITEM_REL_ALT_KEY quest, ADMIN_ITEM ai, NCI_ADMIN_ITEM_REL rel
       WHERE AI.ITEM_ID = rel.P_ITEM_ID and AI.VER_NR = rel.P_ITEM_VER_NR
       and nvl(ai.fld_delete,0) = 0
       and nvl(rel.fld_delete,0) = 0
       and nvl(quest.fld_delete,0) = 0
       and rel.C_ITEM_ID = quest.P_ITEM_ID
       and rel.C_ITEM_VER_NR = quest.P_ITEM_VER_NR
       and ai.admin_stus_id = 75 -- only for released forms.
union
  SELECT distinct quest.C_ITEM_ID, quest.C_ITEM_VER_NR, cs.CNTXT_ITEM_ID, cs.CNTXT_VER_NR, 0, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, quest.FLD_DELETE, quest.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM NCI_ADMIN_ITEM_REL quest, ADMIN_ITEM cs, NCI_CLSFCTN_SCHM_ITEM csi
       WHERE cs.ITEM_ID = csi.cs_ITEM_ID and cs.VER_NR = csi.CS_ITEM_VER_NR
       and nvl(cs.fld_delete,0) = 0
       and nvl(csi.fld_delete,0) = 0
       and nvl(quest.fld_delete,0) = 0
       and csi.ITEM_ID = quest.P_ITEM_ID
       and cs.VER_NR = quest.P_ITEM_VER_NR
      )
      group by ITEM_ID, VER_NR , CNTXT_ITEM_ID, CNTXT_VER_NR;





 CREATE OR REPLACE VIEW VW_CLSFCTN_SCHM_ITEM AS
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM,  ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT,
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT,
ADMIN_ITEM.LST_UPD_DT, ADMIN_ITEM.NCI_IDSEQ, CSI.P_ITEM_ID, CSI.P_ITEM_VER_NR, CSI.CS_ITEM_ID, CSI.CS_ITEM_VER_NR,   CAST(cs.item_nm || SYS_CONNECT_BY_PATH(replace(admin_item.ITEM_NM,'|',''), ' | ') as varchar2(4000)) FUL_PATH
FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
       WHERE ADMIN_ITEM_TYP_ID = 51 and ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID and ADMIN_ITEM.VER_NR = CSI.VER_NR and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
   start with p_item_id is null
   CONNECT BY PRIOR csi.item_id = csi.p_item_id;
   
