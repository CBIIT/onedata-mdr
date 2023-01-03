-- update legacy PV origin


update perm_val pv set nci_origin = (select max(SRC_NAME) from  sbrext.vd_pvs_sources_ext e where e.vp_idseq =  pv.nci_idseq and date_created < sysdate - 365 group by vp_idseq
)
where nci_idseq in (Select vp_idseq from  sbrext.vd_pvs_sources_ext);
commit;
update perm_val pv set nci_origin_id = (select obj_key_id from obj_key where nci_cd = pv.nci_origin and obj_typ_id = 18)
where nci_origin is not null and nci_origin_id is null;
commit;

