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
m.PROV_RVW_DT, m.PROV_APRV_DT
from admin_item ai, nci_mdl_map m
where ai.item_id = m.item_id and ai.ver_nr = m.ver_nr and ai.admin_item_typ_id = 58;

