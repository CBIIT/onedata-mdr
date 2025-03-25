-- Tracker
update nci_mdl_elmnt_char c set (de_conc_item_id, de_conc_ver_nr) = (select de.de_conc_item_id, de.de_conc_ver_nr from
 de where c.cde_item_id = de.item_id and c.cde_ver_nr = de.ver_nr and (c.de_conc_item_id <> de.de_conc_item_id 
or c.de_conc_ver_nr <> de.de_conc_ver_nr))
where (cde_item_id, cde_ver_nr, de_conc_item_id, de_conc_ver_nr) in (select 
x.cde_item_id, x.cde_ver_nr, x.de_conc_item_id, x.de_conc_ver_nr from nci_mdl_elmnt_char x, de where x.cde_item_id = de.item_id and x.cde_ver_nr = de.ver_nr and (x.de_conc_item_id <> de.de_conc_item_id 
or x.de_conc_ver_nr <> de.de_conc_ver_nr))
and c.cde_item_id is not null  and c.de_conc_item_id is not null;
commit;
