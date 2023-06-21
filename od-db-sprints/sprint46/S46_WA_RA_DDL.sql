
  CREATE OR REPLACE  VIEW VW_NCI_PROT_DE_REL AS
  SELECT  distinct sysdate CREAT_DT, 
           'ONEDATA' CREAT_USR_ID,
           'ONEDATA' LST_UPD_USR_ID,
           sysdate LST_UPD_DT,
            sysdate S2P_TRN_DT,
           sysdate LST_DEL_DT,
           0 FLD_DELETE,
           prot.P_ITEM_ID PROT_ITEM_ID,
           prot.P_ITEM_VER_NR PROT_VER_NR,
           ak.c_item_id item_id,
           ak.c_item_ver_nr ver_nr
           FROM NCI_ADMIN_ITEM_REL r, NCI_ADMIN_ITEM_REL_ALT_KEY ak , nci_admin_item_rel prot
     WHERE  ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 
  and r.p_item_id = prot.c_item_id and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60
  and nvl(ak.fld_delete,0) = 0;

