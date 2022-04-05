--drop trigger TR_NCI_ALT_NMS_DENORM_INS;


--create unique index uni_alt_nms on alt_nms (item_id, ver_nr, nm_typ_id, cntxt_item_id, cntxt_ver_nr, nm_desc);
alter table alt_nms add constraint uni_alt_nms unique(item_id, ver_nr, nm_typ_id, cntxt_item_id, cntxt_ver_nr, nm_desc);

alter table test_results add (diff_cnt number);


  CREATE OR REPLACE VIEW VW_NCI_FORM_MODULE AS
  select air.p_item_id, air.p_item_ver_nr, ai.item_id, ai.ver_nr, ai.item_nm, ai.item_nm FORM_NM, ai.item_desc,
'MODULE' admin_item_typ_nm,air.INSTR,
ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, air.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, air.disp_ord, air.rep_no,
ai.regstr_stus_id, ai.admin_stus_id, ai.cntxt_item_id, ai.cntxt_ver_nr, ai.item_long_nm
from admin_item ai, nci_admin_item_rel air where ai.item_id = air.c_item_id and ai.ver_nr = air.c_item_ver_nr and air.rel_typ_id in (61,62);

