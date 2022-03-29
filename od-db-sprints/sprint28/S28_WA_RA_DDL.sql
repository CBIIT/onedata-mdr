--drop trigger TR_NCI_ALT_NMS_DENORM_INS;


--create unique index uni_alt_nms on alt_nms (item_id, ver_nr, nm_typ_id, cntxt_item_id, cntxt_ver_nr, nm_desc);
alter table alt_nms add constraint uni_alt_nms unique(item_id, ver_nr, nm_typ_id, cntxt_item_id, cntxt_ver_nr, nm_desc);

alter table test_results add (diff_cnt number);
