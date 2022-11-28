delete from sbr.administered_components where ac_idseq in (
select  qc_idseq from sbrext.quest_contents_ext where date_created >= sysdate - (sysdate -  
       TO_DATE('2022-05-01', 'YYYY-MM-DD')) and qtl_name = 'VALID_VALUE' and 
qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_Valid_Value));
commit;
delete from sbrext.quest_contents_ext where qc_idseq in (
select  qc_idseq from sbrext.quest_contents_ext where date_created >= sysdate - (sysdate -  
       TO_DATE('2022-05-01', 'YYYY-MM-DD')) and qtl_name = 'VALID_VALUE' and 
qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_Valid_Value));
commit;

