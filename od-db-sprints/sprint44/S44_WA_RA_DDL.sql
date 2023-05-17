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

create materialized view MVW_CSI_REL as
select connect_by_root p_item_id base_id, connect_by_root p_item_ver_nr base_ver_nr,  p_item_id, p_item_ver_nr, item_id, ver_nr
from nci_clsfctn_schm_item
connect by prior item_id = p_item_id and ver_nr = p_item_ver_nr
union
select item_id base_id, ver_nr base_ver_nr,  item_id, ver_nr, item_id, ver_nr
from nci_clsfctn_schm_item;



drop materialized view MVW_CSI_NODE_DE_REL;


  CREATE MATERIALIZED VIEW MVW_CSI_NODE_DE_REL
  AS SELECT  distinct ai.CREAT_DT,
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
           csi.BASE_ID P_ITEM_ID,
           csi.BASE_VER_NR P_ITEM_VER_NR,
           ai.CNTXT_ITEM_ID,
           ai.CNTXT_VER_NR,
           ai.ADMIN_STUS_ID,
           ai.REGSTR_STUS_ID,
           de.PREF_QUEST_TXT, 
	   e.USED_BY,
	   'CSI' LVL
           FROM NCI_ADMIN_ITEM_REL ak, ADMIN_ITEM ai, de , nci_admin_item_ext e, MVW_CSI_REL csi
     WHERE     ak.C_ITEM_ID = ai.ITEM_ID
           AND ak.C_ITEM_VER_NR = ai.VER_NR and ai.admin_item_typ_id = 4 and ak.rel_typ_id = 65 and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
and ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.regstr_stus_nm_dn not like '%RETIRED%' and ai.admin_stus_nm_dn not like '%RETIRED%'
and ai.admin_stus_nm_dn not like '%NON-CMPLNT%' and upper(ai.CNTXT_NM_DN) not in ('TEST','TRAINING')
and csi.ITEM_ID= ak.P_ITEM_ID and csi.VER_NR = ak.P_item_ver_nr  
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
           translate(ADMIN_ITEM.UNRSLVD_ISSUE,chr(10)||chr(11)||chr(13),' ')          UNRESOLVED_ISSUE,
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



  CREATE OR REPLACE VIEW DATA_ELEMENT_CONCEPTS_VIEW AS
  SELECT ai.nci_idseq
               DEC_IDSEQ,
          ai.ver_nr
               VERSION,
           ai.ITEM_ID
               DEC_ID,
           ai.ITEM_LONG_NM
               PREFERRED_NAME,
           ai.ITEM_NM
               LONG_NAME,
            translate(ai.ITEM_DESC,chr(10)||chr(11)||chr(13),' ')  PREFERRED_DEFINITION,
           ai.ADMIN_STUS_NM_DN
               ASL_NAME,
	   ai.REGSTR_STUS_NM_DN
               REGISTRATION_STATUS,
	   ai.CNTXT_NM_DN     CONTE_NAME,
           DECODE (AI.CURRNT_VER_IND,  1, 'YES',  0, 'NO')
               LATEST_VERSION_IND,
           AI.FLD_DELETE
               DELETED_IND,
           ai.CREAT_DT
               DATE_CREATED,
           ai.EFF_DT
               BEGIN_DATE,
           ai.CREAT_USR_ID
               CREATED_BY,
           ai.UNTL_DT
               END_DATE,
           ai.LST_UPD_DT
               DATE_MODIFIED,
           ai.LST_UPD_USR_ID
               MODIFIED_BY,
	       translate(ai.ADMIN_NOTES,chr(10)||chr(11)||chr(13),' ') ADMIN_NOTES,
       translate(ai.CHNG_DESC_TXT,chr(10)||chr(11)||chr(13),' ')          CHANGE_NOTE,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)
               ORIGIN,
           CD.NCI_IDSEQ
               CD_IDSEQ,
           CONTE.NCI_IDSEQ
               CONTE_IDSEQ,
               ai.CNTXT_NM_DN,
           PROP.ITEM_NM
               PROPL_NAME,
           OC.ITEM_NM
               OCL_NAME,
           OBJ_CLS_QUAL
               OBJ_CLASS_QUALIFIER,
           PROP_QUAL
               PROPERTY_QUALIFIER,
           PROP.NCI_IDSEQ
               PROP_IDSEQ,
           OC.NCI_IDSEQ
               OC_IDSEQ,
           oe.cncpt_concat || ':' || pe.cncpt_concat      CDR_NAME,
         dec.PROP_ITEM_ID,
           dec.PROP_VER_NR,
           dec.OBJ_CLS_ITEM_ID,
           dec.OBJ_CLS_VER_NR
          FROM ADMIN_ITEM  ai,
           DE_CONC     dec,
           ADMIN_ITEM  CONTE,
           ADMIN_ITEM  cd,
           ADMIN_ITEM  oc,
           ADMIN_ITEM  prop,
	        nci_admin_item_ext oe,
           nci_admin_item_Ext pe
     WHERE     ai.ADMIN_ITEM_TYP_ID = 2
           AND ai.item_id = dec.ITEM_ID
           AND ai.ver_nr = dec.VER_NR
           AND CD.ADMIN_ITEM_TYP_ID = 1
           AND oc.ADMIN_ITEM_TYP_ID = 5
           AND prop.ADMIN_ITEM_TYP_ID = 6
           AND dec.OBJ_CLS_ITEM_ID = oc.ITEM_ID
           AND dec.OBJ_CLS_VER_NR = oc.VER_NR
           AND dec.PROP_ITEM_ID = prop.ITEM_ID
           AND dec.PROP_VER_NR = prop.VER_NR
           AND DEC.CONC_DOM_ITEM_ID = CD.ITEM_ID
           AND DEC.CONC_DOM_VER_NR = CD.VER_NR
           AND AI.CNTXT_ITEM_ID = CONTE.ITEM_ID
           AND AI.CNTXT_VER_NR = CONTE.VER_NR
           AND CONTE.ADMIN_ITEM_TYP_ID = 8
	       and oc.item_id = oe.item_id
           and oc.ver_nr = oe.ver_nr
           and prop.item_id = pe.item_id
           and prop.ver_nr = pe.ver_nr;



  CREATE OR REPLACE  VIEW VALUE_DOMAINS_VIEW AS
  SELECT ai.NCI_IDSEQ
               VD_IDSEQ,
           ai.ver_nr
               VERSION,
           ai.ITEM_LONG_NM
               PREFERRED_NAME,
           con.nci_idseq
               CONTE_IDSEQ,
           translate(ai.ITEM_DESC,chr(10)||chr(11)||chr(13),' ')  PREFERRED_DEFINITION,
            AI.EFF_DT
               BEGIN_DATE,
           AI.CNTXT_NM_DN
               CONTE_NAME,
	   ai.REGSTR_STUS_NM_DN
               REGISTRATION_STATUS,
           AI.CNTXT_ITEM_ID
               CONTE_ITEM_ID,
           AI.CNTXT_VER_NR
               CONTE_VER_NR,
           data_typ.nci_cd
               DTL_NAME,
           cd.nci_idseq
               CD_IDSEQ,
           CONC_DOM_ITEM_ID,
           CONC_DOM_VER_NR,
           ai.UNTL_DT
               END_DATE,
           VAL_DOM_TYP_ID
               VD_TYPE,
           ai.ADMIN_STUS_NM_DN
               ASL_NAME,
	       translate(ai.ADMIN_NOTES,chr(10)||chr(11)||chr(13),' ') ADMIN_NOTES,
       translate(ai.CHNG_DESC_TXT,chr(10)||chr(11)||chr(13),' ')          CHANGE_NOTE,
           uom.nci_cd
               UOML_NAME,
           ai.ITEM_NM
               LONG_NAME,
           fmt.nci_cd
               FORML_NAME,
           VAL_DOM_HIGH_VAL_NUM
               MAX_LENGTH_NUM,
           VAL_DOM_LOW_VAL_NUM
               MIN_LENGTH_NUM,
           VAL_DOM_MAX_CHAR
               HIGH_VALUE_NUM,
           VAL_DOM_MIN_CHAR
               LOW_VALUE_NUM,
           NCI_DEC_PREC
               DECIMAL_PLACE,
           DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No')
               LATEST_VERSION_IND,
           DECODE (ai.FLD_DELETE,  1, 'Yes',  0, 'No')
               DELETED_IND,
           ai.CREAT_USR_ID
               CREATED_BY,
           ai.LST_UPD_USR_ID
               MODIFIED_BY,
           ai.LST_UPD_DT
               DATE_MODIFIED,
           ai.CREAT_DT
               DATE_CREATED,
           --ai.LST_DEL_DT                                 END_DATE,
           CHAR_SET_ID
               CHAR_SET_NAME,
           rep.NCI_IDSEQ
               REP_IDSEQ,
           --QUALIFIER_NAME,
           NVL (AI.ORIGIN, AI.ORIGIN_ID_DN)
               ORIGIN,
           ai.item_id
               VD_ID,
           DECODE (vd.VAL_DOM_TYP_ID,  17, 'E',  18, 'N')
               VD_TYPE_FLAG
      FROM ONEDATA_WA.VALUE_DOM   vd,
           ONEDATA_WA.admin_item  ai,
           ONEDATA_WA.admin_item  cd,
           ONEDATA_WA.fmt,
           ONEDATA_WA.admin_item  con,
           ONEDATA_WA.admin_item  rep,
           ONEDATA_WA.uom,
           ONEDATA_WA.data_typ
     WHERE     vd.item_id = ai.item_id
           AND vd.ver_nr = ai.ver_nr
           AND ai.ADMIN_ITEM_TYP_ID = 3
           AND ai.CNTXT_ITEM_ID = con.ITEM_ID
           AND AI.CNTXT_VER_NR = con.VER_NR
           AND REP_CLS_ITEM_ID = rep.item_id(+)
           AND vd.REP_CLS_VER_NR = rep.ver_nr(+)
           AND fmt.fmt_id(+) = vd.VAL_DOM_FMT_ID
           AND vd.uom_id = uom.uom_id(+)
           AND vd.DTTYPE_ID = data_typ.DTTYPE_ID
           AND cd.item_id = vd.CONC_DOM_ITEM_ID
           AND cd.ver_nr = vd.CONC_DOM_VER_NR;



  CREATE OR REPLACE  VIEW VW_NCI_DE_HORT_FOR_COMP AS
  SELECT ADMIN_ITEM.ITEM_ID                ITEM_ID,
           ADMIN_ITEM.VER_NR,
           ADMIN_ITEM.ITEM_NM,
           ADMIN_ITEM.ITEM_LONG_NM,
           ADMIN_ITEM.ITEM_DESC,
           ADMIN_ITEM.CNTXT_NM_DN,
           ADMIN_ITEM.ORIGIN_ID,
           ADMIN_ITEM.ORIGIN,
           ADMIN_ITEM.ORIGIN_ID_DN,
           ADMIN_ITEM.UNTL_DT,
           ADMIN_ITEM.CURRNT_VER_IND,
           ADMIN_ITEM.REGISTRR_CNTCT_ID,
           ADMIN_ITEM.SUBMT_CNTCT_ID,
           ADMIN_ITEM.STEWRD_CNTCT_ID,
           ADMIN_ITEM.SUBMT_ORG_ID,
           ADMIN_ITEM.STEWRD_ORG_ID,
           ADMIN_ITEM.REGSTR_AUTH_ID,
           ADMIN_ITEM.REGSTR_STUS_NM_DN,
           ADMIN_ITEM.ADMIN_STUS_NM_DN,
           DE.PREF_QUEST_TXT ,
           VALUE_DOM.NCI_DEC_PREC DE_PREC,
           DE.DE_CONC_ITEM_ID,
           DE.DE_CONC_VER_NR,
           DE.VAL_DOM_VER_NR,
           DE.VAL_DOM_ITEM_ID,
           DE.REP_CLS_VER_NR,
           DE.REP_CLS_ITEM_ID,
           nvl(DE.DERV_DE_IND,0) DERV_DE_IND,
           DE.DERV_MTHD,
           DE.DERV_RUL,
           DE.DERV_TYP_ID,
           DE.CONCAT_CHAR,
           ADMIN_ITEM.CREAT_USR_ID,
           ADMIN_ITEM.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           ADMIN_ITEM.LST_UPD_DT,
           ADMIN_ITEM.CREAT_DT,
           ADMIN_ITEM.CREAT_USR_ID                   CREAT_USR_ID_API,
          ADMIN_ITEM.LST_UPD_USR_ID                 LST_UPD_USR_ID_API,
           ADMIN_ITEM.CREAT_DT                       CREAT_DT_API,
           ADMIN_ITEM.LST_UPD_DT                     LST_UPD_DT_API,
           VALUE_DOM.CONC_DOM_VER_NR,
           VALUE_DOM.CONC_DOM_ITEM_ID,
           VALUE_DOM.NON_ENUM_VAL_DOM_DESC,
           VALUE_DOM.UOM_ID,
           VALUE_DOM.VAL_DOM_TYP_ID          VAL_DOM_TYP_ID,
           VALUE_DOM.VAL_DOM_MIN_CHAR,
           VALUE_DOM.VAL_DOM_MAX_CHAR,
           VALUE_DOM.VAL_DOM_HIGH_VAL_NUM,
           VALUE_DOM.VAL_DOM_LOW_VAL_NUM,
           VALUE_DOM.VAL_DOM_FMT_ID,
           VALUE_DOM.CHAR_SET_ID,
           VALUE_DOM_AI.CREAT_DT                VALUE_DOM_CREAT_DT,
           VALUE_DOM_AI.CREAT_USR_ID            VALUE_DOM_USR_ID,
           VALUE_DOM_AI.LST_UPD_USR_ID          VALUE_DOM_LST_UPD_USR_ID,
           VALUE_DOM_AI.LST_UPD_DT              VALUE_DOM_LST_UPD_DT,
           VALUE_DOM_AI.ITEM_NM              VALUE_DOM_ITEM_NM,
           VALUE_DOM_AI.ITEM_LONG_NM         VALUE_DOM_ITEM_LONG_NM,
           VALUE_DOM_AI.ITEM_DESC            VALUE_DOM_ITEM_DESC,
           VALUE_DOM_AI.CNTXT_NM_DN          VALUE_DOM_CNTXT_NM,
           VALUE_DOM_AI.CURRNT_VER_IND       VALUE_DOM_CURRNT_VER_IND,
           VALUE_DOM_AI.REGSTR_STUS_NM_DN    VALUE_DOM_REGSTR_STUS_NM,
           VALUE_DOM_AI.ADMIN_STUS_NM_DN     VALUE_DOM_ADMIN_STUS_NM,
           VALUE_DOM.NCI_STD_DTTYPE_ID,
           VALUE_DOM.DTTYPE_ID,
           VALUE_DOM.NCI_DEC_PREC,
           DEC_AI.ITEM_NM                    DEC_ITEM_NM,
           DEC_AI.ITEM_LONG_NM               DEC_ITEM_LONG_NM,
           DEC_AI.ITEM_DESC                  DEC_ITEM_DESC,
           DEC_AI.CNTXT_NM_DN                DEC_CNTXT_NM,
           DEC_AI.CURRNT_VER_IND             DEC_CURRNT_VER_IND,
           DEC_AI.REGSTR_STUS_NM_DN          DEC_REGSTR_STUS_NM,
           DEC_AI.ADMIN_STUS_NM_DN           DEC_ADMIN_STUS_NM,
           DEC_AI.CREAT_DT                   DEC_CREAT_DT,
           DEC_AI.CREAT_USR_ID               DEC_USR_ID,
           DEC_AI.LST_UPD_USR_ID             DEC_LST_UPD_USR_ID,
           DEC_AI.LST_UPD_DT                 DEC_LST_UPD_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           OC.ITEM_NM                        OBJ_CLS_ITEM_NM,
           OC.ITEM_LONG_NM                   OBJ_CLS_ITEM_LONG_NM,
           CONOC.CNCPT_CONCAT 			OC_CNCPT_CONCAT,
           CONOC.CNCPT_CONCAT_NM			OC_CNCPT_CONCAT_NM,
           PROP.ITEM_NM                      PROP_ITEM_NM,
           PROP.ITEM_LONG_NM                 PROP_ITEM_LONG_NM,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
           CONPROP.CNCPT_CONCAT			PROP_CNCPT_CONCAT,
           CONPROP.CNCPT_CONCAT_NM			PROP_CNCPT_CONCAT_NM	,
           CONRT.CNCPT_CONCAT			REP_TERM_CNCPT_CONCAT,
           CONRT.CNCPT_CONCAT_NM			REP_TERM_CNCPT_CONCAT_NM	,
           DE_CONC.CONC_DOM_ITEM_ID          DEC_CD_ITEM_ID,
           DE_CONC.CONC_DOM_VER_NR           DEC_CD_VER_NR,
           DEC_CD.ITEM_NM                    DEC_CD_ITEM_NM,
           DEC_CD.ITEM_LONG_NM               DEC_CD_ITEM_LONG_NM,
           DEC_CD.ITEM_DESC                  DEC_CD_ITEM_DESC,
           DEC_CD.CNTXT_NM_DN                DEC_CD_CNTXT_NM,
           DEC_CD.CURRNT_VER_IND             DEC_CD_CURRNT_VER_IND,
           DEC_CD.REGSTR_STUS_NM_DN          DEC_CD_REGSTR_STUS_NM,
           DEC_CD.ADMIN_STUS_NM_DN           DEC_CD_ADMIN_STUS_NM,
           CD_AI.ITEM_NM                     CD_ITEM_NM,
           CD_AI.ITEM_LONG_NM                CD_ITEM_LONG_NM,
           CD_AI.ITEM_DESC                   CD_ITEM_DESC,
           CD_AI.CNTXT_NM_DN                 CD_CNTXT_NM,
           CD_AI.CURRNT_VER_IND              CD_CURRNT_VER_IND,
           CD_AI.REGSTR_STUS_NM_DN           CD_REGSTR_STUS_NM,
           CD_AI.ADMIN_STUS_NM_DN            CD_ADMIN_STUS_NM,
           ADMIN_ITEM.ADMIN_ITEM_TYP_ID,
           ''                                CNTXT_AGG,
             SYSDATE
           - GREATEST (DE.LST_UPD_DT,
                       admin_item.lst_upd_dt,
                       Value_dom.LST_UPD_DT,
                       dec_ai.LST_UPD_DT)    LST_UPD_CHG_DAYS
      FROM ADMIN_ITEM,
           DE,
           VALUE_DOM,
           ADMIN_ITEM          VALUE_DOM_AI,
           ADMIN_ITEM          DEC_AI,
           DE_CONC,
           VW_CONC_DOM         DEC_CD,
           VW_CONC_DOM         CD_AI,
           ADMIN_ITEM          OC,
           ADMIN_ITEM          PROP,
           NCI_ADMIN_ITEM_EXT  CONOC,
           NCI_ADMIN_ITEM_EXT  CONPROP,
           NCI_ADMIN_ITEM_EXT  CONRT
     WHERE     ADMIN_ITEM.ADMIN_ITEM_TYP_ID = 4
           AND DE.ITEM_ID = ADMIN_ITEM.ITEM_ID
           AND DE.VER_NR = ADMIN_ITEM.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM_AI.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM_AI.VER_NR
           AND DE.VAL_DOM_ITEM_ID = VALUE_DOM.ITEM_ID
           AND DE.VAL_DOM_VER_NR = VALUE_DOM.VER_NR
           AND DE.DE_CONC_ITEM_ID = DEC_AI.ITEM_ID
           AND DE.DE_CONC_VER_NR = DEC_AI.VER_NR
           AND DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
           AND DE_CONC.OBJ_CLS_ITEM_ID = OC.ITEM_ID
           AND DE_CONC.OBJ_CLS_VER_NR = OC.VER_NR
           AND DE_CONC.PROP_ITEM_ID = PROP.ITEM_ID
           AND DE_CONC.PROP_VER_NR = PROP.VER_NR
           AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
           AND DE_CONC.CONC_DOM_ITEM_ID = DEC_CD.ITEM_ID
           AND DE_CONC.CONC_DOM_VER_NR = DEC_CD.VER_NR
           AND VALUE_DOM.CONC_DOM_ITEM_ID = CD_AI.ITEM_ID
           AND VALUE_DOM.CONC_DOM_VER_NR = CD_AI.VER_NR
           AND OC.ITEM_ID = CONOC.ITEM_ID
           AND OC.VER_NR = CONOC.VER_NR
           AND PROP.ITEM_ID = CONPROP.ITEM_ID
           AND PROP.VER_NR = CONPROP.VER_NR
	     AND VALUE_DOM.REP_CLS_ITEM_ID = CONRT.ITEM_ID
           AND VALUE_DOM.REP_CLS_VER_NR = CONRT.VER_NR
         ;


drop materialized view MVW_CSI_TREE_CDE ;

set escape on;

  CREATE MATERIALIZED VIEW MVW_CSI_TREE_CDE   AS 
  select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  
  ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='Context' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES
 from 
ADMIN_ITEM ai, (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CS' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ADMIN_ITEM_TYP_ID = 9 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and admin_stus_nm_dn ='RELEASED' and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 union
  select 100 LVL, csi.CS_ITEM_ID P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
 c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********'  CHNG_NOTES
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100 LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=104\&type=csi\\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=103\&type=csi\\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '\&p_item_ver_nr=' || ai.ver_nr || '\&formatid=114\&type=csi\\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST';
 --and ai.admin_stus_nm_dn not like '%RETIRED%';


alter table admin_item disable all triggers;

update ADMIN_ITEM set ITEM_RPT_URL = (select PARAM_VAL || '/invoke/downloads.form/printerFriendly?item_id=' || item_id ||  chr(38) || 'version=' || ver_nr || '\Click_to_View'
from NCI_MDR_CNTRL where PARAM_NM = 'DOWNLOAD_HOST') where ADMIN_ITEM_TYP_ID = 54;
commit;

alter table admin_item enable all triggers;

alter table NCI_PROTCL modify (CHNG_TYP  varchar2(30));

