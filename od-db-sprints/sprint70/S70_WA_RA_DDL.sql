	alter table NCI_STG_MDL add ("PROV_ORG_ID" integer, 
	"PROV_CNTCT_ID" integer, 
	"PROV_RSN_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_TYP_RVW_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_RVW_DT" DATE, 
	"PROV_APRV_DT" DATE,
		IMP_PROV_ORG varchar2(1000),
		IMP_PROV_CNTCT varchar2(1000));


	alter table NCI_STG_MDL_ELMNT add ("PROV_ORG_ID" integer, 
	"PROV_CNTCT_ID" integer, 
	"PROV_RSN_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_TYP_RVW_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_RVW_DT" DATE, 
	"PROV_APRV_DT" DATE,
		IMP_PROV_ORG varchar2(1000),
		IMP_PROV_CNTCT varchar2(1000));


alter table NCI_MDL_ELMNT_CHAR add (CONSTNT_DESC_TXT varchar2(1000));

    alter table nci_mdl_elmnt_char add (OC_CNCPT_CD varchar2(8000), PROP_CNCPT_CD varchar2(8000));
    

	alter table NCI_MDL_ELMNT_CHAR add ("PROV_ORG_ID" integer, 
	"PROV_CNTCT_ID" integer, 
	"PROV_RSN_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_TYP_RVW_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_RVW_DT" DATE, 
	"PROV_APRV_DT" DATE);


	alter table NCI_STG_MDL_ELMNT_CHAR add ("PROV_ORG_ID" integer, 
	"PROV_CNTCT_ID" integer, 
	"PROV_RSN_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_TYP_RVW_TXT" VARCHAR2(4000 BYTE) , 
	"PROV_RVW_DT" DATE, 
	"PROV_APRV_DT" DATE,
		IMP_PROV_ORG varchar2(1000),
		IMP_PROV_CNTCT varchar2(1000),
		CONSTNT_DESC_TXT varchar2(1000));

  CREATE OR REPLACE  VIEW VW_MDL_IMP_TEMPLATE AS
  SELECT ' '                DO_NOT_USE,
       ' '                  BATCH_USER,
       ' '                  BATCH_NAME,
       ROWNUM               SEQ_ID,
       ai.item_nm           MDL_NM, 
       ai.item_id           MDL_ID, 
       ai.ver_nr            MDL_VER_NR,
	   mdl_org.org_nm MDL_PROV_ORG_NM,
	   mdl_cntct.PRSN_FULL_NM_DERV MDL_PROV_CNTCT_NM,
	  mdl.PROV_RSN_TXT  MDL_PROV_RSN_TXT, 
	mdl.PROV_TYP_RVW_TXT MDL_PROV_TYP_RVW_TXT , 
	mdl.PROV_RVW_DT MDL_PROV_RVW_DT, 
	mdl.PROV_APRV_DT MDL_PROV_APRV_DT,
       me.item_long_nm      ME_LONG_NM, 
       me.item_phy_obj_nm   ME_PHY_NM, 
       me.item_desc         ME_DESC, 
       me_typ.obj_key_desc ME_TYP_DESC,   
       me_org.org_nm ME_PROV_ORG_NM,
	   me_cntct.PRSN_FULL_NM_DERV ME_PROV_CNTCT_NM,
	    me.PROV_RSN_TXT  ME_PROV_RSN_TXT, 
	me.PROV_TYP_RVW_TXT ME_PROV_TYP_RVW_TXT , 
	me.PROV_RVW_DT ME_PROV_RVW_DT, 
	me.PROV_APRV_DT ME_PROV_APRV_DT,
       mec.mec_long_nm      MEC_LONG_NM, 
       mec.MEC_PHY_NM       MEC_PHY_NM, 
       mec.CHAR_ORD         MEC_CHAR_ORD, 
       mec.                 MEC_DESC, 
       mec_typ.obj_key_Desc MEC_TYP_DESC,  
       mec.src_min_char     MEC_MIN_CHAR, 
       mec.src_max_char     MEC_MAX_CHAR, 
       SRC_DTTYPE         MEC_DT_TYP_DESC, 
       SRC_UOM             UOM_DESC,  
       mec_req.obj_key_Desc          MEC_MNDTRY,  
       decode(mec.pk_ind,1,'Yes','No')           MEC_PK_IND,    
       decode(mec.mdl_pk_ind,1,'Yes','No')           MEC_MDL_PK_IND,    
       mec.src_deflt_val    MEC_DEFLT_VAL, 
       mec.cde_item_id      CDE_ID, 
       mec.cde_ver_nr       CDE_vERSION, 
       decode(mec.FK_IND,1,'Yes','No')           MEC_FK_IND, 
       mec.                 FK_ELMNT_PHY_NM, 
       mec.                 FK_ELMNT_CHAR_PHY_NM, 
       mec.cmnts_desc_txt                  COMMENTS     ,
	  mec.CONSTNT_DESC_TXT,
	   mec_org.org_nm MEC_PROV_ORG_NM,
	   mec_cntct.PRSN_FULL_NM_DERV MEC_PROV_CNTCT_NM,
	    mec.PROV_RSN_TXT  MEC_PROV_RSN_TXT, 
	mec.PROV_TYP_RVW_TXT MEC_PROV_TYP_RVW_TXT , 
	mec.PROV_RVW_DT MEC_PROV_RVW_DT, 
	mec.PROV_APRV_DT MEC_PROV_APRV_DT
FROM admin_item            ai,
     nci_mdl               mdl,
     nci_mdl_elmnt         me,
     nci_mdl_elmnt_char    mec,
     obj_key               mec_typ,
     obj_key               me_typ,
     obj_key               mec_req,
	  nci_org		   mdl_org,
	  nci_org			me_org,
	  nci_prsn			mdl_cntct,
	  nci_prsn			me_cntct,
	  	  nci_org			mec_org,
	  nci_prsn			mec_cntct
WHERE ai.item_id                  = mdl.item_id
  AND ai.ver_nr                   = mdl.ver_nr
  AND ai.admin_item_typ_id        = 57
  AND mdl.item_id                 = me.mdl_item_id
  AND mdl.ver_nr                  = me.mdl_item_ver_nr
  AND me.item_id                  = mec.mdl_elmnt_item_id
  AND me.ver_nr                   = mec.mdl_elmnt_ver_nr
  AND mec.mdl_elmnt_char_typ_id   = mec_typ.obj_key_id (+)
  AND mec.req_ind  = mec_req.obj_key_id (+)
  AND me.ME_TYP_ID  = me_typ.obj_key_id (+)
	  and mdl.prov_org_id = mdl_org.entty_id (+)
	  and mdl.prov_cntct_id = mdl_cntct.entty_id (+)
	  and me.prov_org_id = me_org.entty_id (+)
	  and me.prov_cntct_id = me_cntct.entty_id (+)
	    and mec.prov_org_id = mec_org.entty_id (+)
	  and mec.prov_cntct_id = mec_cntct.entty_id (+)
	  ;

create view vw_mdl as select ai.*,
m.PRMRY_MDL_LANG_ID, m.MDL_TYP_ID, m.ASSOC_NM_TYP_ID, 
m.ASSOC_TBL_NM_TYP_ID, m.ASSOC_CS_ITEM_ID, m.ASSOC_CS_VER_NR, m.MAP_USG_TYP_ID, m.PROV_ORG_ID, m.PROV_CNTCT_ID, m.PROV_RSN_TXT, m.PROV_TYP_RVW_TXT, 
m.PROV_RVW_DT, m.PROV_APRV_DT
from admin_item ai, nci_mdl m
where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 57;


  CREATE OR REPLACE VIEW VW_MDL_MAP AS
  select ai."DATA_ID_STR",ai."ITEM_ID",ai."VER_NR",ai."CLSFCTN_SCHM_ID",ai."ITEM_DESC",ai."CNTXT_ITEM_ID",ai."CNTXT_VER_NR",ai."ITEM_LONG_NM",ai."ITEM_NM",ai."ADMIN_NOTES",
	  ai."CHNG_DESC_TXT",ai."CREATION_DT",ai."EFF_DT",ai."ORIGIN",ai."UNRSLVD_ISSUE",ai."UNTL_DT",ai."CLSFCTN_SCHM_VER_NR",ai."ADMIN_ITEM_TYP_ID",ai."CURRNT_VER_IND",ai."ADMIN_STUS_ID",
	  ai."REGSTR_STUS_ID",ai."REGISTRR_CNTCT_ID",ai."SUBMT_CNTCT_ID",ai."STEWRD_CNTCT_ID",ai."SUBMT_ORG_ID",ai."STEWRD_ORG_ID",ai."CREAT_DT",ai."CREAT_USR_ID",ai."LST_UPD_USR_ID",ai."FLD_DELETE",
	  ai."LST_DEL_DT",ai."S2P_TRN_DT",ai."LST_UPD_DT",ai."LEGCY_CD",ai."CASE_FILE_ID",ai."REGSTR_AUTH_ID",ai."BTCH_NR",ai."ALT_KEY",ai."ABAC_ATTR",ai."NCI_IDSEQ",ai."ADMIN_STUS_NM_DN",ai."CNTXT_NM_DN",
	  ai."REGSTR_STUS_NM_DN",ai."ORIGIN_ID",ai."ORIGIN_ID_DN",ai."DEF_SRC",ai."CREAT_USR_ID_X",ai."LST_UPD_USR_ID_X",ai."ITEM_NM_CURATED",ai."ITEM_NM_ID_VER",ai."ITEM_RPT_URL",ai."ITEM_DEEP_LINK",
	  ai."RVWR_CMNTS",ai."MTCH_TERM_ADV",ai."MTCH_TERM",ai."LST_UPD_DT_X",INT_1, INT_2, INT_3, INT_4, INT_5, INT_6, INT_7, INT_8,
m.SRC_MDL_ITEM_ID,m.SRC_MDL_VER_NR, m.TGT_MDL_ITEM_ID,m.TGT_MDL_VER_NR,  m.PROV_ORG_ID, m.PROV_CNTCT_ID, m.PROV_RSN_TXT, m.PROV_TYP_RVW_TXT, 
m.PROV_RVW_DT, m.PROV_APRV_DT, ai.MDL_MAP_SNAME
from admin_item ai, nci_mdl_map m
where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 58;

create or replace view vw_NCI_MODULE_DE_SHORT as SELECT FRM.ITEM_LONG_NM FRM_ITEM_LONG_NM, FRM.ITEM_NM FRM_ITEM_NM, FRM.ITEM_ID FRM_ITEM_ID, FRM.VER_NR FRM_VER_NR,  FRM.CNTXT_NM_DN FRM_CNTXT_NM_DN,
  FRM.ADMIN_STUS_NM_DN FRM_ADMIN_STUS_NM_DN, FRM.REGSTR_STUS_NM_DN FRM_REGSTR_STUS_NM_DN,
FRM.CNTXT_ITEM_ID FRM_CNTXT_ITEM_ID, FRM.CNTXT_VER_NR FRM_CNTXT_VER_NR,
AIR.P_ITEM_ID MOD_ITEM_ID, AIR.P_ITEM_VER_NR MOD_VER_NR,
AIR.C_ITEM_ID DE_ITEM_ID, AIR.C_ITEM_VER_NR DE_VER_NR, AIR.DISP_ORD QUEST_DISP_ORD,FRM_MOD.DISP_ORD MOD_DISP_ORD,
 FRM.ITEM_ID ||'v'||FRM.VER_NR FRM_ITEM_VER_NR
FROM  NCI_ADMIN_ITEM_REL_ALT_KEY AIR, 
ADMIN_ITEM FRM, NCI_ADMIN_ITEM_REL FRM_MOD 
WHERE  AIR.REL_TYP_ID = 63
AND FRM.ITEM_ID = FRM_MOD.P_ITEM_ID AND FRM.VER_NR = FRM_MOD.P_ITEM_VER_NR 
AND FRM_MOD.REL_TYP_ID IN (61,62)
AND FRM.ADMIN_ITEM_TYP_ID IN ( 54,55)

	
  CREATE OR REPLACE VIEW VW_NCI_PROT_DE_REL_SHORT AS
  SELECT  distinct 
           prot.P_ITEM_ID PROT_ITEM_ID,
           prot.P_ITEM_VER_NR PROT_VER_NR,
           ak.c_item_id item_id,
           ak.c_item_ver_nr ver_nr,
	  prot.P_ITEM_ID || 'v' ||prot.P_ITEM_VER_NR PROT_ITEM_VER_NR,
      ai.item_nm prot_nm,
      p.protcl_id
           FROM NCI_ADMIN_ITEM_REL r, NCI_ADMIN_ITEM_REL_ALT_KEY ak , nci_admin_item_rel prot, admin_item ai, nci_protcl p
     WHERE  ak.P_ITEM_ID = r.C_ITEM_ID and ak.P_ITEM_VER_NR = r.C_ITEM_VER_NR and
	   r.rel_typ_id = 61 
  and r.p_item_id = prot.c_item_id 
  and r.p_item_ver_nr = prot.c_item_ver_nr and prot.rel_typ_id=60 and prot.p_item_id = ai.item_id and prot.p_item_ver_nr = ai.ver_nr
  and ai.item_id = p.item_id and ai.ver_nr = p.ver_nr
  and nvl(ak.fld_delete,0) = 0;


drop materialized view VW_NCI_DE_HORT_EXPANDED;

  CREATE MATERIALIZED VIEW VW_NCI_DE_HORT_EXPANDED AS 
	  SELECT DE.ITEM_ID, DE.VER_NR,   
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
          DE.CREAT_USR_ID,
           DE.LST_UPD_USR_ID,
           DE.FLD_DELETE,
           DE.LST_DEL_DT,
           DE.S2P_TRN_DT,
           DE.LST_UPD_DT,
           DE.CREAT_DT,
           DE_CONC.OBJ_CLS_ITEM_ID,
           DE_CONC.OBJ_CLS_VER_NR,
           DE_CONC.PROP_ITEM_ID,
           DE_CONC.PROP_VER_NR,
          alt.altnm,
	      refdoc.refdesc,
	  pvvm.pv,
	  pvvm.vm,
	  pvvm.vm_cncpt,
	  frm.frm_nm,
	  frm.frm_item_ver_nr,
	  prot.prot_nm,
	  prot.prot_id
	  FROM --ADMIN_ITEM,
           DE,
           DE_CONC,
          (select distinct item_id, ver_nr, substr(LISTAGG(nm_desc, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as altnm from alt_nms group by item_id, ver_nr)  alt,
	      (select  item_id, ver_nr, substr(LISTAGG(ref_desc, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as refdesc from ref group by item_id, ver_nr) refdoc,
		(select  de_item_id,de_ver_nr, substr(LISTAGG(PERM_VAL_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as PV,
	   substr( LISTAGG(ITEM_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as VM ,
	  substr(LISTAGG(CNCPT_CONCAT, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as VM_CNCPT  from VW_NCI_DE_PV group by de_item_id, de_ver_nr) PVVM,
	(select  de_item_id,de_ver_nr, substr(LISTAGG(FRM_ITEM_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as FRM_NM,
	   substr( LISTAGG(FRM_ITEM_VER_NR, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by de_ITEM_ID),1,16000) as FRM_ITEM_VER_NR
	    from VW_NCI_MODULE_DE_SHORT group by de_item_id, de_ver_nr) FRM,
    (select  item_id,ver_nr, substr(LISTAGG(PROT_NM, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as PROT_NM,
	   substr( LISTAGG(PROTCL_ID, ',' ON OVERFLOW TRUNCATE) WITHIN GROUP (ORDER by ITEM_ID),1,16000) as PROT_ID
	    from VW_NCI_PROT_DE_REL_SHORT group by item_id, ver_nr) PROT
     WHERE   DE.DE_CONC_ITEM_ID = DE_CONC.ITEM_ID
            AND DE.DE_CONC_VER_NR = DE_CONC.VER_NR
	  and de.item_id = alt.item_id (+)
	  and de.ver_nr = alt.ver_nr (+)
	    and de.item_id = refdoc.item_id (+)
	  and de.ver_nr = refdoc.ver_nr (+)
	    and de.item_id = pvvm.de_item_id (+)
	  and de.ver_nr = pvvm.de_ver_nr (+)
		    and de.item_id = frm.de_item_id (+)
	  and de.ver_nr = frm.de_ver_nr (+)
	     and de.item_id = prot.item_id (+)
	  and de.ver_nr = prot.ver_nr (+)
;
