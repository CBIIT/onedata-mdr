select* from sbr.administered_components 
where ac_idseq in (select a.QC_IDSEQ from(
select i.QC_IDSEQ,i.P_VAL_IDSEQ from sbrext.quest_contents_ext i
where i.qtl_name = 'VALUE_INSTR'and i.preferred_definition !=' ' and nvl(i.deleted_ind,'No') ='No' )a,
(select NCI_IDSEQ from ONEDATA_WA.NCI_QUEST_VALID_VALUE V 
WHERE  NVL(FLD_DELETE,0)=0 AND INSTR is not NULL ) V
WHERE a.P_VAL_IDSEQ=v.NCI_IDSEQ(+)
and v.NCI_IDSEQ IS NULL);

select*from sbrext.quest_contents_ext 
where qc_idseq in (select
a.QC_IDSEQ from(
select i.QC_IDSEQ,i.P_VAL_IDSEQ from sbrext.quest_contents_ext i
where i.qtl_name = 'VALUE_INSTR'and i.preferred_definition !=' ' and nvl(i.deleted_ind,'No') ='No' )a,
(select NCI_IDSEQ from ONEDATA_WA.NCI_QUEST_VALID_VALUE V 
WHERE  NVL(FLD_DELETE,0)=0 AND INSTR is not NULL ) V
WHERE a.P_VAL_IDSEQ=v.NCI_IDSEQ(+)
and v.NCI_IDSEQ IS NULL);

