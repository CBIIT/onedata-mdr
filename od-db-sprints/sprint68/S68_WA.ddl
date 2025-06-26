
drop materialized view vw_Admin_item_with_ext;



  CREATE MATERIALIZED VIEW VW_ADMIN_ITEM_WITH_EXT
  AS select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.ITEM_LONG_NM, ai.ITEM_NM, ai.CHNG_DESC_TXT, 
 'Value Meaning' ADMIN_ITEM_TYP_ID ,ai.CURRNT_VER_IND,
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, e.cncpt_concat_src_typ evs_src_ori,
decode(e.CNCPT_CONCAT,e.cncpt_concat_nm, null, e.cncpt_concat)  cncpt_concat, e.CNCPT_CONCAT_NM, e.CNCPT_CONCAT_DEF,'NA' SYN
from admin_item ai, nci_admin_item_Ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr
and ai.admin_item_typ_id in (53)
	  union
	  select ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.ITEM_LONG_NM, ai.ITEM_NM, '' CHNG_DESC_TXT, 
  'Concept' ADMIN_ITEM_TYP_ID ,ai.CURRNT_VER_IND,
 ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT, 
 ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.EVS_SRC_ORI evs_src_ori,
ai.ITEM_LONG_NM cncpt_concat, ai.item_nm CNCPT_CONCAT_NM, ai.item_desc CNCPT_CONCAT_DEF, ai.syn
from vw_cncpt ai
union
	    select 0,1, 'No NCIt Concept Associated',  'NA', 'No NCIt Concept Associated', '',
'Concept' ,1, 
sysdate, 'ONEDATA', 'ONEDATA', 0,sysdate, sysdate ,sysdate,
 'NA', 'NA', 'Application', 'NA',
'NA'  , 'NA', 'NA' , 'NA' from dual;
