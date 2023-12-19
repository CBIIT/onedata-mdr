

delete from nci_form where (item_id , ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54);
delete from onedata_Ra.nci_form where (item_id , ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54);
commit;
delete from nci_module where (item_id , ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
delete from onedata_Ra.nci_module where (item_id , ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
commit;
-- Protocol form
delete from nci_admin_item_rel where rel_typ_id = 60 and (c_item_id,c_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54);
delete from onedata_ra.nci_admin_item_rel where rel_typ_id = 60 and (c_item_id,c_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54);
commit;
-- form-module
delete from nci_admin_item_rel where rel_typ_id = 61 and (c_item_id,c_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
delete from onedata_ra.nci_admin_item_rel where rel_typ_id = 61 and (c_item_id,c_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
commit;
delete from nci_admin_item_rel where rel_typ_id = 61 and (p_item_id,p_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54)
and p_item_id <> -1;
delete from onedata_ra.nci_admin_item_rel where rel_typ_id = 61 and (p_item_id,p_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 54)
and p_item_id <> -1;
commit;

-- Question
delete from nci_admin_item_rel_alt_key where (p_item_id, p_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
delete from onedata_ra.nci_admin_item_rel_alt_key where (p_item_id, p_item_ver_nr) not in (Select item_id, ver_nr from admin_item where admin_item_typ_id = 52);
commit;

-- REpetition
delete from nci_quest_vv_rep where (quest_pub_id, quest_ver_nr) not in (Select nci_pub_id, nci_ver_nr from nci_admin_item_rel_alt_key);
delete from onedata_ra.nci_quest_vv_rep where (quest_pub_id, quest_ver_nr) not in (Select nci_pub_id, nci_ver_nr from nci_admin_item_rel_alt_key);
commit;

-- Valid Value
delete from nci_quest_valid_value where (q_pub_id, q_ver_nr) not in (Select nci_pub_id, nci_ver_nr from nci_admin_item_rel_alt_key);
delete from onedata_Ra.nci_quest_valid_value where (q_pub_id, q_ver_nr) not in (Select nci_pub_id, nci_ver_nr from nci_admin_item_rel_alt_key);
commit;



