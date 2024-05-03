SELECT * FROM VW_NCI_PCDC_DE
  CREATE OR REPLACE  VIEW   "VW_NCI_PCDC_DE"  AS
  SELECT distinct ADMIN_ITEM.ITEM_ID,
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
           ADMIN_ITEM.LST_UPD_DT                LST_UPD_DT_X,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.NCI_IDSEQ,
	   dom.csi_concat,
           de.subset_desc,
	  de.prnt_subset_item_id,
	  de.prnt_subset_ver_nr,
          ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
           nvl(PCDC_NM.NM_DESC,admin_item.item_nm)                        PCDC_NM,
           TIER TIER,
           PCDC_DEF.DEF_DESC                 PCDC_DEF,
               CODE_INSTR_REF_DESC PCDC_CODE_INSTR,
            INSTR_REF_DESC                            PCDC_INSTR,
          EXAMPL                           PCDC_EXMPL,
            de.de_conc_item_id DEC_ID,
            de.de_conc_ver_nr DEC_VER,
            vd.VAL_DOM_TYP_ID,
            vd.item_id VD_ID,
            vd.ver_nr VD_VER,
            REF.PREF_QUEST_TXT                        PREF_QUEST_TXT	  
            FROM ADMIN_ITEM, NCI_ADMIN_ITEM_EXT  ext, de, VALUE_DOM vd, nci_admin_item_rel r, vw_clsfctn_schm_item csi,
       (  SELECT item_id, ver_nr,  
       max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS', ref_desc) ) CODE_INSTR_REF_DESC,
 --      max(decode(upper(obj_key_Desc),'CODING INSTRUCTIONS',ref_desc) ) CODE_INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'INSTRUCTIONS', ref_desc) ) INSTR_REF_DESC,
       max(decode(upper(obj_key_Desc),'EXAMPLE', ref_desc) ) EXAMPL,
       max(decode(upper(obj_key_Desc),'TIER', ref_desc) ) TIER
       FROM REF, OBJ_KEY WHERE REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id = 1 and nvl(ref.fld_delete,0) = 0
           AND UPPER(OBJ_KEY_DESC) in ('INSTRUCTIONS', 'CODING INSTRUCTIONS','EXAMPLE','TIER')  and NCI_CNTXT_ITEM_ID = 12119072 --pediatric cancer context
           group by item_id ,ver_nr)  CODE_INSTR,
             (  SELECT item_id,ver_nr, max(nm_desc) nm_desc FROM ALT_NMS, OBJ_KEY WHERE NM_TYP_ID = OBJ_KEY.OBJ_KEY_ID   and obj_key.obj_typ_id =  11 
             AND UPPER(OBJ_KEY_DESC)='PED CANCER ALT NAME' group by item_id, ver_nr)  PCDC_NM,
           (  SELECT item_id, ver_nr, max(def_desc) def_desc FROM ALT_DEF, OBJ_KEY 
           WHERE NCI_DEF_TYP_ID = OBJ_KEY.OBJ_KEY_ID   AND UPPER(OBJ_KEY_DESC)='PED CANCER ALT DEFINITION'  and obj_key.obj_typ_id =  15 group by item_id, ver_nr)  PCDC_DEF,
           (SELECT item_id, ver_nr, ref_desc PREF_QUEST_TXT
              FROM REF
             WHERE ref_typ_id = 80) REF,
           (  SELECT item_id,
                     ver_nr,
                     LISTAGG (ref_desc, '||' ON OVERFLOW TRUNCATE ) WITHIN GROUP (ORDER BY REF_DESC desc)    ref_desc
                FROM REF, OBJ_KEY
               WHERE     REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID
                     AND LOWER (OBJ_KEY_DESC) LIKE '%question%'
            GROUP BY item_id, ver_nr) ref_desc  ,
      (SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS CSI_concat
FROM (select distinct r.c_item_id item_id,r.c_item_ver_nr ver_nr, x.item_nm from vw_CLSFCTN_SCHM_ITEM x, NCI_ADMIN_ITEM_REL r
where  x.item_id = r.p_item_id and x.ver_nr = r.p_item_ver_nr and r.rel_typ_id = 65 and x.CS_item_id = 13954630) group by item_id, ver_nr) dom
     WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
           AND ADMIN_ITEM.ITEM_ID = PCDC_NM.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = PCDC_NM.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = PCDC_DEF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = PCDC_DEF.VER_NR(+)
 AND ADMIN_ITEM.ITEM_ID = CODE_INSTR.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = CODE_INSTR.VER_NR(+)
            AND ADMIN_ITEM.ITEM_ID = REF.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = REF.VER_NR(+)
           AND ADMIN_ITEM.ITEM_ID = ref_desc.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = ref_desc.VER_NR(+)
	     AND ADMIN_ITEM.ITEM_ID = dom.ITEM_ID(+)
           AND ADMIN_ITEM.VER_NR = dom.VER_NR(+)
	   and admin_item.item_id = r.c_item_id and admin_item.ver_nr = r.c_item_ver_nr and r.p_item_id = csi.item_id and r.p_item_ver_nr = csi.ver_nr 
	   and csi.cs_item_id = 13954630
       and r.rel_typ_id = 65
     --  and admin_item.regstr_stus_id not in (9)
       and admin_item.admin_stus_nm_dn not like '%RETIRED%';

