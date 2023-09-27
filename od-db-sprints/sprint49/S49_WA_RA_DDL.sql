--alter table NCI_MEC_MAP add ( MEC_SUB_GRP_NBR integer);
alter table NCI_STG_MDL add (CNTXT_ITEM_ID number, CNTXT_VER_NR number(4,2));

alter table NCI_STG_MDL_ELMNT add ( IMP_GRP_NM  varchar2(1000), ME_GRP_ID integer);

alter table NCI_MDL_ELMNT add (  ME_GRP_ID integer);

alter table NCI_STG_MDL_ELMNT_CHAR add (  CMNTS_DESC_TXT varchar2(4000));



	
	insert into obj_typ (obj_typ_id, obj_typ_desc) values (49,'Mapping Groups');
	     commit;

--- Views for API

create or replace view vw_mdl_flat as
select ai.item_id mdl_item_id, ai.ver_nr mdl_ver_nr, ai.item_long_nm mdl_long_nm, ai.item_desc mdl_item_desc,
ai.cntxt_item_id mdl_cntxt_item_id, ai.cntxt_ver_nr  mdl_cntxt_ver_nr,
ai.cntxt_nm_dn mdl_cntxt_nm_dn, ai.admin_stus_id mdl_admin_stus_id, ai.regstr_stus_id mdl_regstr_stus_id,
ai.admin_stus_nm_dn mdl_admin_stus_nm_dn, ai.regstr_stus_nm_dn mdl_regstr_stus_nm_dn,
mdl.prmry_mdl_lang_id, mdl.mdl_typ_id, ai.currnt_ver_ind mdl_currnt_ver_ind, 
me.item_long_nm mdl_elmnt_long_nm, me.item_phy_obj_nm mdl_elmnt_phy_nm ,me.me_typ_id mdl_elmnt_typ_id, me.item_desc mdl_elmnt_item_desc,
me.me_grp_id mdl_elmnt_grp_id, me.item_id mdl_elmnt_item_id, me.ver_nr mdl_elmnt_ver_nr, 
mec.creat_dt, mec.creat_usr_id, mec.lst_upd_dt, mec.lst_upd_usr_id, mec.s2p_trn_dt, mec.fld_delete, mec.lst_del_dt,
mec.src_dttype, mec.src_max_char, mec.src_min_char, mec.src_uom, mec.src_deflt_val, mec.de_conc_item_id, mec.de_conc_ver_nr, mec.val_dom_item_id,
mec.val_dom_ver_nr, mec.mec_long_nm, mec.mec_phy_nm, mec.mec_desc, mec.cde_item_id, mec.cde_ver_nr
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr;

