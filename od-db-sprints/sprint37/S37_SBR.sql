
delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where (preferred_definition is null or preferred_definition = ' ')
and qtl_name in ('QUESTION_INSTR', 'VALUE_INSTR','MODULE_INSTR','FOOTER', 'FORM_INSTR') );
commit;
delete from sbrext.quest_contents_ext where (preferred_definition is null or preferred_definition = ' ')
and qtl_name in ('QUESTION_INSTR', 'VALUE_INSTR','MODULE_INSTR','FOOTER', 'FORM_INSTR') );
commit;
