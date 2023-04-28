drop materialized view VW_CLSFCTN_SCHM_ITEM;


  CREATE MATERIALIZED VIEW VW_CLSFCTN_SCHM_ITEM
  AS SELECT ADMIN_ITEM.ITEM_ID,
               ADMIN_ITEM.VER_NR,
               ADMIN_ITEM.ITEM_NM,
               ADMIN_ITEM.ITEM_LONG_NM,
               ADMIN_ITEM.ITEM_DESC,
               ADMIN_ITEM.CNTXT_NM_DN,
               ADMIN_ITEM.CURRNT_VER_IND,
               ADMIN_ITEM.REGSTR_STUS_NM_DN,
               ADMIN_ITEM.ADMIN_STUS_NM_DN,
               ADMIN_ITEM.CREAT_DT,
               ADMIN_ITEM.CREAT_USR_ID,
               ADMIN_ITEM.LST_UPD_USR_ID,
               ADMIN_ITEM.FLD_DELETE,
               ADMIN_ITEM.LST_DEL_DT,
               ADMIN_ITEM.S2P_TRN_DT,
               ADMIN_ITEM.LST_UPD_DT,
               ADMIN_ITEM.NCI_IDSEQ,
               CSI.P_ITEM_ID,
               CSI.P_ITEM_VER_NR,
               CSI.CS_ITEM_ID,
               CSI.CS_ITEM_VER_NR,
	       CSI.CSI_TYP_ID,
               CAST (
                      cs.item_nm
                   || SYS_CONNECT_BY_PATH (REPLACE (admin_item.ITEM_NM, '|', ''),
                                           ' | ')
                       AS VARCHAR2 (4000))    FUL_PATH,
		            CAST (
                      cs.item_nm
                   || SYS_CONNECT_BY_PATH (REPLACE (admin_item.ITEM_ID || 'v' || to_char(admin_item.ver_nr,'99.99'), '|', ''),
                                           ' | ')
                       AS VARCHAR2 (4000))    FUL_PATH_ID
          FROM ADMIN_ITEM, NCI_CLSFCTN_SCHM_ITEM csi, vw_clsfctn_schm cs
         WHERE     ADMIN_ITEM_TYP_ID = 51
               AND ADMIN_ITEM.ITEM_ID = CSI.ITEM_ID
               AND ADMIN_ITEM.VER_NR = CSI.VER_NR
               AND csi.cs_item_id = cs.item_id
               AND csi.cs_item_ver_nr = cs.ver_nr
    START WITH p_item_id IS NULL
  CONNECT BY PRIOR  to_char(csi.item_id || to_char(csi.ver_nr,'99.99')) = to_char(csi.p_item_id || to_char(csi.P_item_ver_nr,'99.99'));


drop materialized view MVW_CSI_NODE_DE_REL;

  CREATE MATERIALIZED VIEW MVW_CSI_NODE_DE_REL
  AS SELECT  ak.CREAT_DT,
           ak.CREAT_USR_ID,
           ak.LST_UPD_USR_ID,
           ak.LST_UPD_DT,
           ak.S2P_TRN_DT,
           ak.LST_DEL_DT,
           ak.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           ak.P_ITEM_ID,
           ak.P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'CSI' LVL
           FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, de , nci_admin_item_ext e--, vw_clsfctn_schm_item csi
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
--and csi.ful_path_id like '%' || ak.p_item_id ||'v'|| to_char(ak.p_item_ver_nr,'99.99') || '%' 
--and nvl(ai.CURRNT_VER_IND,0) = 1 
and nvl(ak.fld_delete,0) = 0
    UNION
    SELECT distinct ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.LST_UPD_DT,
           ai.S2P_TRN_DT,
           ai.LST_DEL_DT,
           ai.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           csi.CS_ITEM_ID,
           csi.CS_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
       de.PREF_QUEST_TXT,
e.USED_BY, 'CS' LVL
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, de, nci_admin_item_Ext e
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
--and nvl(ai.CURRNT_VER_IND,0) = 1 
union
SELECT distinct ai.CREAT_DT,
           ai.CREAT_USR_ID,
           ai.LST_UPD_USR_ID,
           ai.LST_UPD_DT,
           ai.S2P_TRN_DT,
           ai.LST_DEL_DT,
           ai.FLD_DELETE,
           ai.ITEM_NM,
           ai.ITEM_LONG_NM,
           ai.ITEM_ID,
           ai.VER_NR,
           ai.ITEM_DESC,
           ai.CNTXT_NM_DN,
           ai.ADMIN_STUS_NM_DN,
           ai.REGSTR_STUS_NM_DN,
           cs.CNTXT_ITEM_ID,
           cs.CNTXT_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
            de.PREF_QUEST_TXT,
e.USED_BY, 'Context' LVL
      FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, VW_CLSFCTN_SCHM cs, de, nci_admin_item_ext e
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR
           AND ak.P_ITEM_ID = csi.ITEM_ID
           AND ak.P_ITEM_VER_NR = csi.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65
and csi.CS_ITEM_ID = cs.ITEM_ID and csi.CS_ITEM_VER_NR = cs.VER_NR and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')  and cs.admin_stus_nm_dn ='RELEASED';
--and nvl(ai.CURRNT_VER_IND,0) = 1;


  CREATE OR REPLACE  VIEW VW_NCI_GENERAL_DE as
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
	     ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
	   ADMIN_ITEM.ITEM_DEEP_LINK,
           ext.USED_BY                         CNTXT_AGG,
             vd.VAL_DOM_TYP_ID	 ,
	     an.NM_DESC,
	     an.nm_typ_id,
	     adef.def_desc,
	     adef.nci_def_typ_id
	     FROM ADMIN_ITEM,
           NCI_ADMIN_ITEM_EXT  ext,
	      de, VALUE_DOM vd, MVW_CSI_NODE_DE_REL r,
	     (SELECT an.item_id, an.ver_nr, nm_typ_id, max(nm_desc) as NM_DESC
	      from alt_nms an
          group by an.item_id, an.ver_nr, nm_typ_id) an,
	     (SELECT an.item_id, an.ver_nr, nci_def_typ_id, max(def_desc) as def_DESC
	      from alt_def an
          group by an.item_id, an.ver_nr, nci_def_typ_id) adef
        WHERE     ADMIN_ITEM_TYP_ID = 4
           and ADMIN_ITEM.ITEM_Id = de.item_id
           and ADMIN_ITEM.VER_NR = DE.VER_NR
           and de.VAL_DOM_ITEM_ID = vd.ITEM_ID
	   and de.VAL_DOM_VER_NR = vd.VER_NR
	   AND ADMIN_ITEM.ITEM_ID = EXT.ITEM_ID
           AND ADMIN_ITEM.VER_NR = EXT.VER_NR
	   and admin_item.item_id = r.item_id and admin_item.ver_nr = r.ver_nr and r.p_item_id = 5279492 and r.p_item_ver_nr = 5.31
	   and admin_item.item_id = an.item_id 
	   and admin_item.ver_nr = an.ver_nr 
	   and admin_item.item_id = adef.item_id (+)
	   and admin_item.ver_nr = adef.ver_nr (+);
/

alter table NCI_STG_FORM_IMPORT add (PRTCL_ITEM_ID number, PRTCL_VER_NR number(4,2));

alter table NCI_STG_FORM_IMPORT add (IMP_PRTCL_NM varchar2(30));
