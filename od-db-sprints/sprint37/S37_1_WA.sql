create table temp_cntxt as select * from admin_item where admin_item_typ_id = 8;


update sbr.reference_documents d set conte_idseq = (select c.nci_idseq from temp_cntxt c, ref r
where r.nci_cntxt_item_id = c.item_id and r.nci_cntxt_ver_nr = c.ver_nr and r.nci_idseq = d.rd_idseq)
where conte_idseq is null;
commit;

drop table temp_cntxt;

