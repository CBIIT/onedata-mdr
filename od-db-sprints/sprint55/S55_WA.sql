


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

insert into nci_admin_item_rel (p_item_id, p_item_Ver_nr, c_item_id, c_item_ver_Nr, rel_typ_id, rep_no)
select distinct prnt_subset_item_id, prnt_subset_ver_nr, item_id, ver_nr , 84,0 from value_dom where prnt_subset_item_id is not null
and (prnt_subset_item_id, prnt_subset_ver_nr, item_id, ver_nr ) not in (Select p_item_id, p_item_Ver_nr, c_item_id, c_item_ver_Nr from 
nci_admin_item_rel where rel_typ_id = 84);
commit;

insert into onedata_ra.nci_admin_item_rel select * from nci_admin_item_rel where (p_item_id, p_item_Ver_nr, c_item_id, c_item_ver_Nr, rel_typ_id) not in 
(select p_item_id, p_item_Ver_nr, c_item_id, c_item_ver_Nr, rel_typ_id from onedata_ra.nci_admin_item_rel);
commit;



