set serveroutput on size 1000000
SPOOL S22_WA_LOAD_CONCEPTS.log
update SAG_LOAD_CONCEPTS_EVS set con_idseq = null where con_idseq is not null;
commit;
--load concepts
set timing on
exec SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG;
begin
dbms_output.put_line('SAG_LOAD_CONCEPT_ADMIN_ITEM_DESIG is completed');
end;
/
SPOOL OFF
