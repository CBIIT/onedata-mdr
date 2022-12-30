delete from SBREXT.VD_PVS_SOURCES_EXT  where vp_idseq in (select nci_idseq from onedata_Wa.perm_val where lst_upd_dt >= sysdate - 2 and nvl(fld_delete,0) = 1);
commit;
