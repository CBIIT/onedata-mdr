
  CREATE OR REPLACE  VIEW VW_NCI_CRDC_DE
  SELECT ADMIN_ITEM.ITEM_ID,
           ADMIN_ITEM.VER_NR,
          CAST('.' || ADMIN_ITEM.ITEM_ID || '.' AS VARCHAR2(4000))    ITEM_ID_STR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.ADMIN_NOTES,
           ADMIN_ITEM.CHNG_DESC_TXT,
           ADMIN_ITEM.CREATION_DT,
           ADMIN_ITEM.EFF_DT,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNRSLVD_ISSUE,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGSTR_STUS_ID,
           ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.CREAT_USR_ID             CREAT_USR_ID_X,
           ADMIN_ITEM.LST_UPD_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID           LST_UPD_USR_ID_X,
           ADMIN_ITEM.FLD_DELETE,
           ADMIN_ITEM.LST_DEL_DT,
           ADMIN_ITEM.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	   ext.csi_concat,
           ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
       replace (ADMIN_ITEM.ITEM_NM_ID_VER,'|Data Element','') ITEM_NM_ID_VER,
           ext.USED_BY                         CNTXT_AGG,
           CRDC_NM.NM_DESC                        CRDC_NM,
           CRDC_DEF.DEF_DESC                        CRDC_DEF,
           CODING_INSTR.REF_DESC                        CRDC_CODE_INSTR,
            EXMPL.REF_DESC                        CRDC_EXMPL,
	   vd.VAL_DOM_TYP_ID	,
        trim(SUBSTR (                 trim(ADMIN_ITEM.ITEM_LONG_NM)  || '||'   || trim(ADMIN_ITEM.ITEM_NM) ,1,   4290))   || '||'   ||   SUBSTR ( trim(ref_desc.REF_DESC),  1,  30000)                          SEARCH_STR
      FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	      de, VALUE_DOM vd,
           (  SELECT item_id, ver_nr, ref_desc  FROM REF, OBJ_KEY WHERE REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='EXAMPLE' order by creat_dt desc fetch first row only)  EXMPL,
           (  SELECT item_id, ver_nr, ref_desc  FROM REF, OBJ_KEY WHERE REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='CODING INSTRUCTIONS' order by creat_dt desc fetch first row only)  CODE_INSTR,
           (  SELECT item_id,ver_nr, nm_desc  FROM ALT_NM, OBJ_KEY WHERE NM_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='CRDC NAME' order by creat_dt desc fetch first row only)  CRDC_NM,
           (  SELECT item_id, ver_nr, def_desc  FROM ALT_DEF, OBJ_KEY WHERE NCI_DEF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='CRDC DEFINITION' order by creat_dt desc fetch first row only)  CRDC_DEF        
     WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = EXMPL.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = EXMPL.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = CRDC_NM.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CRDC_NM.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = CRDC_DEF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CRDC_DEF.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = CODING_INSTR.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CODING_INSTR.VER_NR(+)
and ADMIN_ITEM.CNTXT_NM_DN = 'CRDC';

