alter table CNCPT add (PRMRY_RT_ORI_NM varchar2(255));

alter table cncpt disable all triggers;
update CNCPT set PRMRY_RT_ORI_NM = (select ITEM_NM from ADMIN_ITEM ai where ai.item_id = cncpt.item_id and ai.ver_nr = cncpt.ver_nr)
where cncpt.PRMRY_CNCPT_IND = 1;
commit;
update cncpt set prmry_rt_ori_nm = 'Stage' where PRMRY_CNCPT_IND = 1 and prmry_rt_ori_nm like '% Stage%';
commit;

alter table cncpt enable all triggers;


drop materialized view vw_cncpt;

  CREATE MATERIALIZED VIEW VW_CNCPT
  AS SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM,  ADMIN_ITEM.ITEM_LONG_NM, '.' ||ADMIN_ITEM.ITEM_NM ||'.' ITEM_NM_PERIOD,  '.' ||ADMIN_ITEM.ITEM_LONG_NM || '.' ITEM_LONG_NM_PERIOD, ADMIN_ITEM.ITEM_DESC, ADMIN_ITEM.CREATION_DT, 
ADMIN_ITEM.EFF_DT, ADMIN_ITEM.ORIGIN,  ADMIN_ITEM.UNTL_DT,  ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CNTXT_ITEM_ID,
ADMIN_ITEM.CNTXT_VER_NR, ADMIN_ITEM.CNTXT_NM_DN,
 ADMIN_ITEM.CREAT_DT, ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, ADMIN_ITEM.LST_UPD_DT, CNCPT.PRMRY_CNCPT_IND,
nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') DEF_SRC, e.CNCPT_CONCAT_WITH_INT,
		      decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC) EVS_SRC,
		      trim(OBJ_KEY.OBJ_KEY_DESC) EVS_SRC_ORI,
			cncpt.evs_Src_id,nvl(cncpt.ref_term_ind,0) REF_TERM_IND,
		      nvl(decode(trim(ADMIN_ITEM.DEF_SRC), 'NCI', '1-NCI', ADMIN_ITEM.DEF_SRC), 'No Def Source') || '|' ||
		      nvl(decode(trim(OBJ_KEY.OBJ_KEY_DESC), 'NCI_CONCEPT_CODE', '1-NCC', 'NCI_META_CUI', '2-NMC', OBJ_KEY.OBJ_KEY_DESC), 'No EVS Source') DEF_EVS_SRC,
        substr(ADMIN_ITEM.ITEM_NM || ' | ' || a.SYN, 1, 4000) SYN,substr(a.SYN_MTCH_TERM,1,4000) SYN_MTCH_TERM, MTCH_TERM, MTCH_TERM_ADV,
    nvl(PRMRY_OBJ_CLS_IND,0) PRMRY_OBJ_CLS_IND,  decode(PRMRY_OBJ_CLS_IND,1,'Yes','') PRMRY_OBJ_CLS_IND_NM ,
    b.sys_path_final,
	  b.lvl,
    nvl(cncpt.PRMRY_RT_ORI_NM, admin_item.item_nm) CNCPT_ORI_NM,
 'TEST' NCI_META_CUI
  --  xm.xmap_cd NCI_META_CUI
              FROM ADMIN_ITEM,  CNCPT, nci_admin_item_ext e, OBJ_KEY, (select item_id, ver_nr,  substr( LISTAGG(nm_desc, ' | ') WITHIN GROUP (ORDER by ITEM_ID),1,8000) AS SYN,
			        LISTAGG(MTCH_TERM_ADV , ' | ') WITHIN GROUP (ORDER by ITEM_ID) AS SYN_MTCH_TERM from ALT_NMS a group by item_id, ver_nr) a,
                vw_prmry_oc_cncpt_rel b
       WHERE ADMIN_ITEM_TYP_ID = 49 and ADMIN_ITEM.ITEM_ID = CNCPT.ITEM_ID and ADMIN_ITEM.VER_NR = CNCPT.VER_NR
       and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr
	and cncpt.EVS_SRC_ID = OBJ_KEY.OBJ_KEY_ID (+) and admin_item.admin_stus_nm_dn = 'RELEASED' 
	and ADMIN_ITEM.ITEM_ID = a.ITEM_ID (+) and ADMIN_ITEM.VER_NR = a.VER_NR (+)
    and admin_item.item_id = b.c_item_id  (+) and admin_item.ver_nr = b.c_item_ver_nr (+);



  CREATE OR REPLACE  VIEW VW_DE AS
  SELECT 
ADMIN_ITEM.ITEM_ID, 
ADMIN_ITEM.VER_NR, 
ADMIN_ITEM.ITEM_NM, 
ADMIN_ITEM.ITEM_LONG_NM, 
ADMIN_ITEM.ITEM_DESC, 
ADMIN_ITEM.CNTXT_NM_DN, 
ADMIN_ITEM.CURRNT_VER_IND, 
ADMIN_ITEM.REGSTR_STUS_NM_DN, 
ADMIN_ITEM.ADMIN_STUS_NM_DN,
ADMIN_ITEM.REGSTR_STUS_ID, 
ADMIN_ITEM.ADMIN_STUS_ID,
ADMIN_ITEM.MTCH_TERM,
ADMIN_ITEM.MTCH_TERM_ADV,
 DE.DE_CONC_VER_NR, 
 DE.DE_CONC_ITEM_ID, 
 DE.VAL_DOM_VER_NR, 
 DE.VAL_DOM_ITEM_ID, 
 DE.REP_CLS_VER_NR, 
 DE.REP_CLS_ITEM_ID, 
ADMIN_ITEM.CREAT_USR_ID, 
ADMIN_ITEM.LST_UPD_USR_ID, 
ADMIN_ITEM.FLD_DELETE, 
ADMIN_ITEM.LST_DEL_DT, 
ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, 
ADMIN_ITEM.CREAT_DT,
DE.PREF_QUEST_TXT, 
VALUE_DOM.NON_ENUM_VAL_DOM_DESC, 
VALUE_DOM.DTTYPE_ID, 
VAL_DOM_MAX_CHAR, 
VAL_DOM_TYP_ID, 
VALUE_DOM.UOM_ID,
VAL_DOM_MIN_CHAR, 
VAL_DOM_FMT_ID, 
CHAR_SET_ID, 
VAL_DOM_HIGH_VAL_NUM, 
VAL_DOM_LOW_VAL_NUM, 
FMT_NM, 
DTTYPE_NM, 
UOM_NM,
decode(VALUE_DOM.VAL_DOM_TYP_ID,17 ,'Enumerated', 18,'Non-Enumerated', 16, 'Enumerated by Reference') VAL_DOM_TYP,
value_dom.TERM_CNCPT_ITEM_ID,
value_dom.TERM_CNCPT_VER_NR,
term.term_use_name TERM_CNCPT_DESC,
e.USED_BY
FROM ADMIN_ITEM, DE, VALUE_DOM, DATA_TYP, FMT, UOM, vw_val_dom_ref_term term, nci_admin_item_ext e
WHERE ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
and DE.VER_NR = ADMIN_ITEM.VER_NR
and DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
and DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
and VALUE_DOM.VAL_DOM_FMT_ID = FMT.FMT_ID (+)
and VALUE_DOM.DTTYPE_ID = DATA_TYP.DTTYPE_ID (+)
and VALUE_DOM.UOM_ID = UOM.UOM_ID (+)
and value_dom.ITEM_ID = term.item_id (+)
and value_dom.ver_nr = term.ver_nr (+)
and admin_item.item_id = e.item_id and admin_item.ver_nr = e.ver_nr;



  CREATE OR REPLACE  VIEW VW_MDL_FLAT_VAL_MAP AS
  select ai.item_id MDL_ITEM_ID, 
	ai.ver_nr  MDL_VER_NR, 
	ai.item_nm  MDL_NM, 
        ai.cntxt_nm_dn  MDL_CNTXT_NM, 
	ai.admin_stus_nm_dn  MDL_ADMIN_STUS_NM, 
	ai.regstr_stus_nm_dn  MDL_REGSTR_STUS_NM,
	ai.currnt_ver_ind MDL_CURRNT_VER_IND, 
	me.item_long_nm  ME_LONG_NM, 
	me.item_phy_obj_nm ME_PHY_NM ,
	me.item_desc ME_DESC,
	me.item_id ME_ITEM_ID, 
	me.ver_nr ME_VER_NR, 
	mec.creat_dt, 
	mec.creat_usr_id, 
	mec.lst_upd_dt, 
	mec.lst_upd_usr_id, 
	mec.s2p_trn_dt, 
	mec.fld_delete, 
	mec.lst_del_dt,
--	mec.src_dttype MEC_DTTYP, 
--	mec.CHAR_ORD MEC_CHAR_ORD, 
--	mec.src_max_char MEC_MAX_CHAR, 
--	mec.src_min_char MEC_MIN_CHAR, 
--	mec.src_uom MEC_UOM, 
--	mec.src_deflt_val MEC_DEFLT_VAL, 
--	  mec.cmnts_desc_txt,
--	mec.de_conc_item_id, 
--	mec.de_conc_ver_nr,
--	mec.val_dom_item_id,
--	mec.val_dom_ver_nr, 
	mec.mec_long_nm , 
	mec.mec_phy_nm , 
	mec.mec_desc , 
	mec.cde_item_id , 
	  mec.val_dom_item_id, 
	  mec.val_dom_ver_nr,
   	mec.cde_ver_nr ,
	cde.Item_nm CDE_NM,
	cde.cntxt_nm_dn CDE_CNTXT_NM,
	  mec.mec_id,
	  mec.req_ind,
	  mec.pk_ind,
	  mec.fk_ind,
	  mec.mdl_pk_ind,
	  mec.FK_ELMNT_PHY_NM,
	  mec.FK_ELMNT_CHAR_PHY_NM,
	  PV.PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,
             -- PV.VAL_DOM_ITEM_ID,
		--PV.VAL_DOM_VER_NR , 
        VM.ITEM_NM VM_ITEM_NM, VM.ITEM_LONG_NM VM_ITEM_LONG_NM,
                VM.ITEM_DESC VM_ITEM_DESC, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, vm.admin_stus_nm_dn VM_ADMIN_STUS_NM_DN
from admin_item ai, nci_mdl mdl, nci_mdl_elmnt me, nci_mdl_elmnt_char mec, admin_item cde, PERM_VAL PV, ADMIN_ITEM VM	 
where ai.item_id = mdl.item_id and ai.ver_nr = mdl.ver_nr and ai.admin_item_typ_id = 57 and mdl.item_id = me.mdl_item_id
and mdl.ver_nr = me.mdl_item_ver_nr and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr
	and mec.cde_item_id = cde.item_id (+)
	and mec.cde_ver_nr = cde.ver_nr (+)
	and cde.admin_item_typ_id (+)= 4
	  and PV.NCI_VAL_MEAN_ITEM_ID = vm.ITEM_ID and
	PV.NCI_VAL_MEAN_VER_NR = vm.VER_NR and
	  pv.val_dom_item_id = mec.val_dom_item_id and 
	  pv.val_dom_Ver_nr = mec.val_dom_ver_nr
	  
