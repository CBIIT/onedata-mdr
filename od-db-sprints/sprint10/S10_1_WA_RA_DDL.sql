CREATE OR REPLACE  VIEW VW_NCI_USR_CART AS
  SELECT AI.ITEM_ID, AI.VER_NR, AI.ITEM_LONG_NM, AI.CNTXT_NM_DN, AI.ITEM_NM, AI.REGSTR_STUS_NM_DN, AI.ADMIN_STUS_NM_DN,
  AI.ADMIN_ITEM_TYP_ID,
  DECODE(AI.ADMIN_ITEM_TYP_ID, 4, 'Data Element', 54, 'Form', 52, 'Module') ADMIN_ITEM_TYP_NM,
UC.CNTCT_SECU_ID, UC.CREAT_DT, UC.CREAT_USR_ID, UC.LST_UPD_USR_ID, 
UC.FLD_DELETE, UC.LST_DEL_DT, UC.S2P_TRN_DT, UC.LST_UPD_DT, UC.GUEST_USR_NM
FROM NCI_USR_CART UC, ADMIN_ITEM AI WHERE AI.ITEM_ID = UC.ITEM_ID AND AI.VER_NR = UC.VER_NR
and admin_item_typ_id in (4,52,54);

CREATE OR REPLACE VIEW VW_NCI_USED_BY AS
  select distinct ITEM_ID, VER_NR , CNTXT_ITEM_ID, CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, 0 FLD_DELETE, sysdate LST_DEL_DE, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
from (
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.CNTXT_ITEM_ID, a.CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, ALT_NMS a, obj_key ok
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
       and a.nm_typ_id = ok.obj_key_id and ok.obj_typ_id =11 and ok.obj_key_desc <> 'USED_BY'
      and a.CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.ITEM_ID, DE.VER_NR, a.NCI_CNTXT_ITEM_ID, a.NCI_CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, a.FLD_DELETE, a.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM DE, REF a
       WHERE DE.ITEM_ID = a.ITEM_ID and DE.VER_NR = a.VER_NR
       and nvl(a.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
      and a.NCI_CNTXT_ITEM_ID is not null
union
  SELECT distinct DE.C_ITEM_ID, DE.C_ITEM_VER_NR, cs.CNTXT_ITEM_ID, cs.CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, cscsi.FLD_DELETE, cscsi.LST_DEL_DT, sysdate S2P_TRN_DT, 
  sysdate LST_UPD_DT
       FROM NCI_ALT_KEY_ADMIN_ITEM_REL de, NCI_ADMIN_ITEM_REL_ALT_KEY cscsi, admin_item cs
       WHERE DE.NCI_PUB_ID = cscsi.NCI_PUB_ID and de.NCI_VER_NR = cscsi.NCI_VER_NR
       and nvl(cscsi.fld_delete,0) = 0
       and nvl(de.fld_delete,0) = 0
       and cscsi.CNTXT_CS_ITEM_ID = cs.item_id and 
       cscsi.CNTXT_CS_VER_NR = cs.ver_nr and
       cs.admin_item_typ_id = 9       and cs.CNTXT_ITEM_ID is not null
union
  SELECT distinct quest.C_ITEM_ID, quest.C_ITEM_VER_NR, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, sysdate CREAT_DT, 'ONEDATA' CREAT_USR_ID, 'ONEDATA' LST_UPD_USR_ID, quest.FLD_DELETE, quest.LST_DEL_DT, sysdate S2P_TRN_DT, sysdate LST_UPD_DT
       FROM NCI_ADMIN_ITEM_REL_ALT_KEY quest, ADMIN_ITEM ai, NCI_ADMIN_ITEM_REL rel
       WHERE AI.ITEM_ID = rel.P_ITEM_ID and AI.VER_NR = rel.P_ITEM_VER_NR
       and nvl(ai.fld_delete,0) = 0
       and nvl(rel.fld_delete,0) = 0
       and rel.C_ITEM_ID = quest.P_ITEM_ID
       and rel.C_ITEM_VER_NR = quest.P_ITEM_VER_NR
      );

