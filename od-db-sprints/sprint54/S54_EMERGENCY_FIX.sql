insert into cncpt (item_id, ver_nr)
select item_id, ver_nr from admin_item where admin_item_typ_id = 49 and (item_id, ver_nr) not in (Select item_id, ver_nr from cncpt);
commit;
