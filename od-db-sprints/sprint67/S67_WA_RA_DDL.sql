
create materialized view vw_prmry_oc_cncpt as select ai.item_id, ai.ver_nr, item_nm from admin_item ai, cncpt c where ai.item_id = c.item_id and ai.ver_nr= c.ver_nr and
nvl(prmry_obj_cls_ind,0) = 1;


create materialized view vw_prmry_oc_cncpt_rel as
select c_item_id, c_item_ver_nr, listagg(sys_path_distinct, '|') sys_path_final
from (
select distinct c_item_id, c_item_ver_nr, substr( sys_path, instr(sys_path,'|',1,1)+1, instr(sys_path,'|',1,2)-instr(sys_path,'|',1,1)-1) sys_path_distinct
 from
(select  c_item_id, c_item_ver_nr,
 CAST (SYS_CONNECT_BY_PATH (ai.ITEM_NM, '|') AS VARCHAR2 (4000)) SYS_PATH
--listagg(ai.item_nm ,'|')
from admin_Item ai, nci_cncpt_rel r where r.rel_typ_id = 68 and ai.item_id = r.p_item_id and ai.ver_nr = r.p_item_ver_nr
and ai.admin_item_typ_id = 49
start with r.p_item_id in (select item_id from vw_prmry_oc_cncpt) 
  CONNECT BY PRIOR  to_char(r.c_item_id || to_char(r.c_item_ver_nr,'99.99')) = to_char(r.p_item_id || to_char(r.P_item_ver_nr,'99.99'))) )
  group by c_iteM_id, c_item_ver_nr
  

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
