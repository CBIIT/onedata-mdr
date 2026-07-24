create or replace procedure spResetidseq as 
maxval number;
begin

execute immediate 'alter table admin_item disable all triggers';
for cur in (Select item_id, ver_nr from admin_item where nci_idseq is null) loop

update admin_item set nci_idseq = nci_11179.cmr_guid() where item_id = cur.item_id and ver_nr = cur.ver_nr;
end loop;
commit;

for cur in (Select item_id, ver_nr from admin_item where nci_idseq in (select nci_idseq from admin_item group by nci_idseq having count(*) > 1)) loop

update admin_item set nci_idseq = nci_11179.cmr_guid() where item_id = cur.item_id and ver_nr = cur.ver_nr;
end loop;
commit;
execute immediate 'alter table admin_item enable all triggers';

end;
/

exec spResetidseq;

