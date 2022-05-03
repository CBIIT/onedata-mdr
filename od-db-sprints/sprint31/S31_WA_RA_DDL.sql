
alter table ref add constraint uni_ref_nm unique(item_id, ver_nr, ref_typ_id,  ref_nm);
