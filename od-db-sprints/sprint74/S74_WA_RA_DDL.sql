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


