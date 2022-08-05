
EXEC DBMS_STATS.GATHER_TABLE_STATS ('SBREXT', 'QUEST_CONTENTS_EXT');

EXEC DBMS_STATS.GATHER_TABLE_STATS ('SBREXT', 'QC_RECS_EXT');

EXEC DBMS_STATS.GATHER_TABLE_STATS ('SBREXT', 'VALID_VALUES_ATT_EXT');

EXEC DBMS_STATS.GATHER_TABLE_STATS ('SBR', 'ADMINISTERED_COMPONENTS');



-- Tracker 1854

delete from administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where qtl_name in ('VALID_VALUE') 
and qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_valid_value where nvl(fld_delete,0) = 0));

commit;

delete from administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where qtl_name in ('VALUE_INSTR') 
and p_val_idseq not in (select nci_idseq from onedata_wa.nci_quest_valid_value) );
commit;

delete from sbrext.quest_contents_ext where qtl_name in ('VALUE_INSTR') 
and p_val_idseq not in (select nci_idseq from onedata_wa.nci_quest_valid_value );

commit;

delete from sbrext.quest_contents_ext where qtl_name in ('VALID_VALUE') 
and qc_idseq not in (select nci_idseq from onedata_wa.nci_quest_valid_value );
commit;
