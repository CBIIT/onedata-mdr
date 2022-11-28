delete from sbr.administered_components where ac_idseq in (
select  qc_idseq from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE' and
qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_Valid_Value)
and P_QST_IDSEQ in (select nci_idseq from onedata_wa.nci_admin_item_rel_alt_key where lst_upd_dt >= to_Date('05/01/2022','mm/dd/yyyy')));
commit;
delete from sbrext.quest_contents_ext where qc_idseq in (
select  qc_idseq from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE' and 
qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_Valid_Value )
and P_QST_IDSEQ in (select nci_idseq from onedata_wa.nci_admin_item_rel_alt_key where lst_upd_dt >= to_Date('05/01/2022','mm/dd/yyyy')));
commit;
