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


set escape on;
drop MATERIALIZED VIEW VW_FORM_TREE_CDE;


  CREATE MATERIALIZED VIEW VW_FORM_TREE_CDE
  AS select CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  ITEM_NM || ' (' 
 || nvl(y.cnt,'0') || ')' ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X 
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=102\&type=protocol\\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=105\&type=protocol\\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=109\&type=protocol\\REDCap_DD_Form'  FORM_RPT_RED_CAP,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Protocol' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 50 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+)
 and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') 
 and c.param_nm='DOWNLOAD_HOST'
 union
select  r.P_ITEM_ID, r.P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN,ai. REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=102\&type=frm\\Legacy_Form_Builder_Excel' FORM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=105\&type=frm\\Form_Excel'  FORM_RPT_EXCEL,
c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=109\&type=frm\\REDCap_DD_Form'  FORM_RPT_RED_CAP,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Form' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c, nci_admin_item_rel r
 where ADMIN_ITEM_TYP_ID = 54 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+)
and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
 and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') 
 and c.param_nm='DOWNLOAD_HOST'
 and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 60
 union
 select  distinct null P_ITEM_ID,null P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM,  
ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')' , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN,ai. REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X
 ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=frm\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=frm\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=frm\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_PRIOR_EXCEL,
'NA' FORM_RPT_EXCEL,
'NA' FORM_RPT_RED_CAP,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES 
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_FORM_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+)  and ver_nr = y.p_item_ver_nr (+)
 --and admin_stus_nm_dn ='RELEASED' 
 and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') 
 and c.param_nm='DOWNLOAD_HOST';
 
 /
 
alter table NCI_STG_FORM_IMPORT add (PRTCL_ITEM_ID number, PRTCL_VER_NR number(4,2));

alter table NCI_STG_FORM_IMPORT add (IMP_PRTCL_NM varchar2(30));




  CREATE OR REPLACE FORCE  VIEW DATA_ELEMENTS_VIEW
  ("DE_IDSEQ", "CDE_ID", "VERSION", "LONG_NAME", "PREFERRED_NAME", "VD_IDSEQ", "DEC_IDSEQ", "CONTE_IDSEQ", "DEC_ID", "DEC_VERSION", "VD_ID", "VD_VERSION", "PREFERRED_DEFINITION", "ADMIN_NOTES", "CHANGE_NOTE", "BEGIN_DATE", "ORIGIN", "UNRESOLVED_ISSUE", "UNTL_DT", "LATEST_VERSION_IND", "REGISTRATION_STATUS", "ASL_NAME", "WORKFLOW_STATUS_DESC", "CONTEXTS_NAME", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "CREATED_BY", "MODIFIED_BY", "DELETED_IND", "DATE_MODIFIED", "DATE_CREATED", "END_DATE", "ADMIN_ITEM_TYP_ID", "QUESTION") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT ADMIN_ITEM.NCI_IDSEQ
               DE_IDSEQ,
           ADMIN_ITEM.ITEM_ID
               CDE_ID,
           ADMIN_ITEM.VER_NR
               VERSION,
           ADMIN_ITEM.ITEM_NM
               LONG_NAME,
           ADMIN_ITEM.ITEM_LONG_NM
               PREFERRED_NAME,
           VD.NCI_IDSEQ
               VD_IDSEQ,
           DE_CONC.NCI_IDSEQ
               DEC_IDSEQ,
           CONTE.NCI_IDSEQ
               CONTE_IDSEQ,
           DE_CONC_ITEM_ID
               DEC_ID,
           DE_CONC_VER_NR
               DEC_VERSION,
           VAL_DOM_ITEM_ID
               VD_ID,
           VAL_DOM_VER_NR
               VD_VERSION,
           translate(ADMIN_ITEM.ITEM_DESC,chr(10)||chr(11)||chr(13),' ')
               PREFERRED_DEFINITION,
           translate(ADMIN_ITEM.ADMIN_NOTES,chr(10)||chr(11)||chr(13),' ') ADMIN_NOTES,
            translate(ADMIN_ITEM.CHNG_DESC_TXT, chr(10)||chr(11)||chr(13),' ')
               CHANGE_NOTE,
           --ADMIN_ITEM.CREATION_DT DATE_CREATED,
           TRUNC (ADMIN_ITEM.EFF_DT)
               BEGIN_DATE,
           NVL (ADMIN_ITEM.ORIGIN, ADMIN_ITEM.ORIGIN_ID_DN)
               ORIGIN,
           ADMIN_ITEM.UNRSLVD_ISSUE
               UNRESOLVED_ISSUE,
           ADMIN_ITEM.UNTL_DT
               END_DATE,
           DECODE (ADMIN_ITEM.CURRNT_VER_IND,  1, 'Yes',  0, 'No')
               LATEST_VERSION_IND,
           --ADMIN_ITEM.REGSTR_STUS_ID,
           --ADMIN_ITEM.ADMIN_STUS_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN
               REGISTRATION_STATUS,
           ADMIN_ITEM.ADMIN_STUS_NM_DN
               ASL_NAME,
           wf.STUS_DESC
               WORKFLOW_STATUS_DESC,
           ADMIN_ITEM.CNTXT_NM_DN
               CONTEXTS_NAME,
           ADMIN_ITEM.CNTXT_ITEM_ID,
           ADMIN_ITEM.CNTXT_VER_NR,
           ADMIN_ITEM.CREAT_USR_ID
               CREATED_BY,
           ADMIN_ITEM.LST_UPD_USR_ID
               MODIFIED_BY,
           DECODE (ADMIN_ITEM.FLD_DELETE,  1, 'Yes',  0, 'No')
               DELETED_IND,
           TRUNC (ADMIN_ITEM.LST_UPD_DT)
               DATE_MODIFIED,
           TRUNC (ADMIN_ITEM.CREAT_DT)
               DATE_CREATED,
           TRUNC (ADMIN_ITEM.UNTL_DT)
               END_DATE,
           --ADMIN_ITEM.S2P_TRN_DT BEGIN_DATE,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           DE.PREF_QUEST_TXT
               QUESTION
      --SELECT*
      FROM ADMIN_ITEM  ADMIN_ITEM,
           DE,
           ADMIN_ITEM  DE_CONC,
           ADMIN_ITEM  VD,
           ADMIN_ITEM  CONTE,
           STUS_MSTR   wf
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND ADMIN_ITEM.ITEM_ID = DE.ITEM_ID
           AND ADMIN_ITEM.VER_NR = DE.VER_NR
           AND ADMIN_ITEM.ADMIN_STUS_ID = wf.STUS_ID
           AND wf.STUS_TYP_ID = 2
           AND DE.VAL_DOM_ITEM_ID = VD.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VD.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND VD.ADMIN_ITEM_TYP_ID = 3
           AND DE_CONC.ADMIN_ITEM_TYP_ID = 2
           AND ADMIN_ITEM.CNTXT_ITEM_ID = CONTE.ITEM_ID
           AND ADMIN_ITEM.CNTXT_VER_NR = CONTE.VER_NR
           AND CONTE.ADMIN_ITEM_TYP_ID = 8;

CREATE OR REPLACE  VIEW ADMIN_ITEM_VIEW AS
  select "ITEM_ID","VER_NR",
    translate(ITEM_DESC,chr(10)||chr(11)||chr(13),' ') ITEM_DESC,
    "CNTXT_ITEM_ID","CNTXT_VER_NR","ITEM_LONG_NM","ITEM_NM",
    translate(ADMIN_NOTES,chr(10)||chr(11)||chr(13),' ') ADMIN_NOTES,
    translate(CHNG_DESC_TXT,chr(10)||chr(11)||chr(13),' ') CHNG_DESC_TXT,
  "CREATION_DT","EFF_DT","ORIGIN",
    translate(UNRSLVD_ISSUE,chr(10)||chr(11)||chr(13),' ') UNRSLVD_ISSUE,
  "UNTL_DT","ADMIN_ITEM_TYP_ID","CURRNT_VER_IND","ADMIN_STUS_ID","REGSTR_STUS_ID",
  "REGISTRR_CNTCT_ID","SUBMT_CNTCT_ID","STEWRD_CNTCT_ID","SUBMT_ORG_ID","STEWRD_ORG_ID",
  "CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT",
  "REGSTR_AUTH_ID",
  "NCI_IDSEQ","ADMIN_STUS_NM_DN","CNTXT_NM_DN","REGSTR_STUS_NM_DN","ORIGIN_ID","ORIGIN_ID_DN",
  "DEF_SRC","CREAT_USR_ID_X","LST_UPD_USR_ID_X","ITEM_NM_CURATED","ITEM_NM_ID_VER","ITEM_RPT_URL","ITEM_DEEP_LINK",
  "RVWR_CMNTS","MTCH_TERM_ADV","MTCH_TERM" from admin_item;

