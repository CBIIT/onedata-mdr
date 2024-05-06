


update value_dom set (subset_desc,prnt_subset_item_id, prnt_subset_ver_nr) = (select 'Subset',de1.val_dom_item_id, de1.val_dom_ver_nr from de de, de de1 where de.subset_desc = 'Subset' and (de.val_dom_item_id, de.val_dom_Ver_nr)
not in (Select item_id, ver_nr from value_dom where subset_desc = 'Subset')
and de.prnt_subset_item_id=de1.item_id and de.prnt_subset_ver_nr=de1.ver_nr
and de.val_dom_item_id = value_dom.item_id and de.val_dom_ver_nr = value_dom.ver_nr)
where (item_id,ver_nr) in (select  de.val_dom_item_id, de.val_dom_ver_nr from de de where de.subset_desc = 'Subset' and (de.val_dom_item_id, de.val_dom_Ver_nr)
not in (Select item_id, ver_nr from value_dom where subset_desc = 'Subset'));
commit;
update value_dom set subset_desc = 'Parent'
where (item_id, ver_nr) in (select de1.val_dom_item_id, de1.val_dom_ver_nr from de de, de de1 where de.subset_desc = 'Subset' 
and de.prnt_subset_item_id=de1.item_id and de.prnt_subset_ver_nr=de1.ver_nr)
and subset_desc is null;
commit;



