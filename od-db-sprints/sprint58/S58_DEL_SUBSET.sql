create table temp_to_delete_de as select ai.item_id, ai.ver_nr from de, admin_item ai where subset_desc is not null and de.item_id = ai.item_id and de.ver_nr = ai.ver_nr and ai.cntxt_nm_dn = 'TEST';

delete from de where (item_id, ver_nr) in (Select item_id, ver_nr from temp_to_delete_de);
delete from admin_item where (item_id, ver_nr) in (Select item_id, ver_nr from temp_to_delete_de);

commit;

drop table temp_to_delete_de;

create table temp_to_delete_vd as select ai.item_id, ai.ver_nr from value_dom vd, admin_item ai where subset_desc is not null and vd.item_id = ai.item_id and vd.ver_nr = ai.ver_nr and ai.cntxt_nm_dn = 'TEST';

delete from value_dom where (item_id, ver_nr) in (Select item_id, ver_nr from temp_to_delete_vd);
delete from admin_item where (item_id, ver_nr) in (Select item_id, ver_nr from temp_to_delete_vd);

commit;

drop table temp_to_delete_vd;

-- update remaining to not have subset desc
alter table de disable all triggers;
update de set subset_desc = null, prnt_subset_item_id = null, prnt_subset_ver_nr = null where subset_desc is not null;
commit;
alter table de enable all triggers;

alter table value_dom disable all triggers;
update value_dom set subset_desc = null, prnt_subset_item_id = null, prnt_subset_ver_nr = null where subset_desc is not null;
commit;
alter table value_dom enable all triggers;

