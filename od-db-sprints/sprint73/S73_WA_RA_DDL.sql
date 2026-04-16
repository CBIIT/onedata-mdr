alter table nci_ds_rslt add (src_mtch_engn varchar2(100) default 'CDE Match');


alter table  NCI_DS_PRMTR add (THRESHOLD_1 int, THRESHOLD_2 int, VARIANT_1 int, VARIANT_2 int);
/*
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (64, 'CDE Model Variant (CDE AI Matching)');
insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (65, 'PV/VM Model Variant (CDE AI Matching)');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (250,64,'CDE Long Name', 'CDE Long Name');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (251,64,'CDE Alternate Name', 'CDE Alternate Name');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (252,64,'CDE Question Text', 'CDE Question Text');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (253,64,'CDE Definition', 'CDE Definition');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (254,65,'PV Code', 'PV Code');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (255,65,'Value Meaning Long Name', 'Value Meaning Long Name');
Insert into OBJ_KEY (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values (267,'REDCap DD CDE Zipfile',31,'REDCap DD CDE Zipfile');
Insert into OBJ_KEY (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF) values (268,'REDCap DD Form ZipFile',31,'REDCap DD Form Zipfile');
commit;
*/

alter table nci_ds_hdr modify (ENTTY_NM varchar2(4000), ENTTY_NM_USR varchar2(4000));

alter table  nci_ds_prmtr modify (ENTTY_NM varchar2(4000), ENTTY_NM_USR varchar2(4000));

insert into obj_typ (obj_typ_id, obj_typ_desc) values (65, 'AI Model Variant - CDE');
insert into obj_typ (obj_typ_id , obj_typ_desc) values (66, 'AI Model Variant - PV');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-mpnet-base-v2-FT', 252);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-MiniLM-L6-v2-FT',253);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'SapBERT-FT',254);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'PubMedBERT-FT',255);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-mpnet-base-v2',256);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'All-MiniLM-L6-v2',257);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'SapBERT',258);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'LongName-sapBERT',259);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'LongName-MiniLM-L6-v2',260);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (65, 'Definition-MiniLM-L6-v2',262);

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-MiniLM-L6-v2',263);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-Expanded-MiniLM-L6-v2',264);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-sapBERT',265);
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, 'PV-Expanded-sapBERT',266);
--insert into obj_key (obj_typ_id, obj_key_desc, obj_key_id) values (66, '(None: CDE_Only)',267);
commit;

alter table nci_ds_prmtr add VARIANT_1_NM varchar2(255);
alter table nci_ds_prmtr add VARIANT_2_NM varchar2(255);

--jira 9273
insert into obj_typ (obj_typ_id, obj_typ_desc) values (64, 'Access Level');
commit;

insert into obj_key (obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (250, 'Public', 64, 'Indicates the item is accessible to the public.');
insert into obj_key (obj_key_id, obj_key_desc, obj_typ_id, obj_key_def) values (251, 'Internal', 64, 'Indicates the item is marked for internal usage.');
commit;

alter table CLSFCTN_SCHM add ACCESS_LVL number default 250;
alter table CLSFCTN_SCHM disable all triggers;
update CLSFCTN_SCHM set ACCESS_LVL = 250;
commit;
alter table CLSFCTN_SCHM enable all triggers;

drop materialized view mvw_csi_tree_cde;
set escape off;
set define off;

CREATE MATERIALIZED VIEW MVW_CSI_TREE_CDE ("LVL", "P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "ITEM_DEEP_LINK", "ITEM_RPT_URL", "ITEM_RPT_EXCEL", "ITEM_RPT_PRIOR_EXCEL", "ITEM_RPT_CDE_JSON", "CHNG_NOTES", "TYP_ID", "P_ITEM_VER")
  SEGMENT CREATION IMMEDIATE
  ORGANIZATION HEAP PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" 
  BUILD IMMEDIATE
  USING INDEX 
  REFRESH FORCE ON DEMAND
  USING DEFAULT LOCAL ROLLBACK SEGMENT
  USING ENFORCED CONSTRAINTS DISABLE ON QUERY COMPUTATION DISABLE QUERY REWRITE
  AS select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM,  
  ITEM_NM || ' (' || ITEM_DESC  || ') (' || nvl(y.cnt,'0') || ')'  ITEM_NM , ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID_VER=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=104&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=103&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=114&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ver_nr || '&formatid=226&type=csi\CDE_JSON_Download' ITEM_RPT_CDE_JSON,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    0 TYP_ID,
null  P_ITEM_VER
from 
ADMIN_ITEM ai, (select x.p_item_id, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='Context' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id , 
x.p_item_ver_nr) y , nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 8 and item_id = y.p_item_id (+) and ver_nr = y.p_item_ver_nr (+) and upper(cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 union
select 99 LVL, CNTXT_ITEM_ID P_ITEM_ID, CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID,ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, 
ITEM_NM || ' (' || nvl(y.cnt,'0') || ')', ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID_VER=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=104&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=103&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=114&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=226&type=csi\CDE_JSON_Download' ITEM_RPT_CDE_JSON,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
      cs.CLSFCTN_SCHM_TYP_ID,
CNTXT_ITEM_ID || 'v'|| CNTXT_VER_NR P_ITEM_VER
 from 
ADMIN_ITEM ai, clsfctn_schm cs,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CS' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ADMIN_ITEM_TYP_ID = 9 and ai.item_id =cs.item_id and ai.ver_nr = cs.ver_nr and  ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and admin_stus_nm_dn ='RELEASED' and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK' and cs.ACCESS_LVL = 250 --public
 union
  select 100 LVL, csi.CS_ITEM_ID P_ITEM_ID, csi.CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID_VER=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
 c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=104&type=csi\Legacy_CDE_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=103&type=csi\Legacy_CDE_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=114&type=csi\Prior_Legacy_CDE_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=226&type=csi\CDE_JSON_Download' ITEM_RPT_CDE_JSON,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********'  CHNG_NOTES,
    csi.csi_typ_id,
csi.CS_ITEM_ID || 'v'|| csi.CS_ITEM_VER_NR P_ITEM_VER 
from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
  and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn ='RELEASED'
 union
 select 100 LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ai.ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ai.ITEM_LONG_NM, 
   ai.ITEM_NM ||  ' (' || nvl(y.cnt,'0') || ')' , 
ai.ADMIN_STUS_ID, ai.REGSTR_STUS_ID, ai.REGISTRR_CNTCT_ID, ai.SUBMT_CNTCT_ID,
ai.STEWRD_CNTCT_ID, ai.SUBMT_ORG_ID, ai.STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 ai.REGSTR_AUTH_ID,  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN, ai.CNTXT_NM_DN, ai.REGSTR_STUS_NM_DN, ai.ORIGIN_ID, ai.ORIGIN_ID_DN,  ai.CREAT_USR_ID_X, ai.LST_UPD_USR_ID_X ,
c1.PARAM_VAL || '/CO/CDEDD?filter=Administered%20Item%20%28Data%20Element%20CO%29.CDEDD%20Classification.P_ITEM_ID_VER=' || ai.item_id || 'v' || ai.ver_Nr ITEM_DEEP_LINK ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=104&type=csi\Legacy_XML' ITEM_RPT_URL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=103&type=csi\Legacy_Excel' ITEM_RPT_EXCEL ,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=114&type=csi\Prior_Legacy_Excel' ITEM_RPT_PRIOR_EXCEL,
c.PARAM_VAL || '/Downloads/cdedirect.dsp?p_item_id=' || ai.item_id || '&p_item_ver_nr=' || ai.ver_nr || '&formatid=226&type=csi\CDE_JSON_Download' ITEM_RPT_CDE_JSON,
'******** TO SEE THIS NODE''s CDEs SWITCH "Details" TO  "View Associated CDEs". ********' CHNG_NOTES,
    csi.CSI_TYP_ID,
csi.P_ITEM_ID || 'v'|| csi.P_ITEM_VER_NR P_ITEM_VER 
 from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi,  (select x.P_ITEM_ID, x.p_item_ver_nr, count(*) cnt from MVW_CSI_NODE_DE_REL x where lvl='CSI' and x.ADMIN_STUS_NM_DN not like '%RETIRED%' group by x.p_item_id , 
x.p_item_ver_nr) y, nci_mdr_cntrl c,nci_mdr_cntrl c1
 where ai.ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and csi.CS_ITEM_ID is not null and
 ai.item_id = y.p_item_id (+) and ai.ver_nr = y.p_item_ver_nr (+) and upper(ai.cntxt_nm_dn) not in ('TEST', 'TRAINING') and c.param_nm='DOWNLOAD_HOST'
 and c1.param_nm='DEEP_LINK'
 and ai.admin_stus_nm_dn ='RELEASED';

 --updated vw_csi_tree
CREATE OR REPLACE FORCE EDITIONABLE VIEW VW_CSI_TREE ("LVL", "P_ITEM_ID", "P_ITEM_VER_NR", "ITEM_ID", "VER_NR", "ITEM_DESC", "CNTXT_ITEM_ID", "CNTXT_VER_NR", "ITEM_LONG_NM", "ITEM_NM", "ADMIN_STUS_ID", "REGSTR_STUS_ID", "REGISTRR_CNTCT_ID", "SUBMT_CNTCT_ID", "STEWRD_CNTCT_ID", "SUBMT_ORG_ID", "STEWRD_ORG_ID", "CREAT_DT", "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "REGSTR_AUTH_ID", "NCI_IDSEQ", "ADMIN_STUS_NM_DN", "CNTXT_NM_DN", "REGSTR_STUS_NM_DN", "ORIGIN_ID", "ORIGIN_ID_DN", "CREAT_USR_ID_X", "LST_UPD_USR_ID_X", "CS_TYP_ID", "CSI_TYP_ID", "COMB_TYP_ID", "ACCESS_LVL") AS 
  select 98 LVL, null P_ITEM_ID, null P_ITEM_VER_NR, ITEM_ID, VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, FLD_DELETE, LST_DEL_DT, S2P_TRN_DT, LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X , 0 CS_TYP_ID, 0 CSI_TYP_ID, 0 COMB_TYP_ID, null ACCESS_LVL from ADMIN_ITEM
 where ADMIN_ITEM_TYP_ID = 8
 union
select 99 LVL, ai.CNTXT_ITEM_ID P_ITEM_ID, ai.CNTXT_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, ai.CNTXT_ITEM_ID, ai.CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  ai.CREAT_USR_ID CREAT_USR_ID_X, ai.LST_UPD_USR_ID LST_UPD_USR_ID_X, 
 CLSFCTN_SCHM_TYP_ID CS_TYP_ID, 0 CSI_TYP_ID, CLSFCTN_SCHM_TYP_ID COMB_TYP_ID, cs.ACCESS_LVL from ADMIN_ITEM ai, CLSFCTN_SCHM cs
 where ai.admin_item_typ_id = 9 and ai.item_id = cs.item_id and ai.ver_nr = cs.ver_nr
 union
 select 100 LVL, CS_ITEM_ID P_ITEM_ID, CS_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X , 0 CS_TYP_ID, CSI_TYP_ID CSI_TYP_ID, CSI_TYP_ID COMB_TYP_ID, cs.ACCESS_LVL from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, CLSFCTN_SCHM cs
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is null and csi.CS_ITEM_ID is not null and CS_ITEM_ID = cs.item_id and CS_ITEM_VER_NR = cs.ver_nr
 --and ai.admin_stus_nm_dn not like '%RETIRED%'
 union
 select 100  LVL, csi.P_ITEM_ID P_ITEM_ID, csi.P_ITEM_VER_NR P_ITEM_VER_NR, ai.ITEM_ID, ai.VER_NR, ITEM_DESC, CNTXT_ITEM_ID, CNTXT_VER_NR, ITEM_LONG_NM, ITEM_NM, ADMIN_STUS_ID, REGSTR_STUS_ID, REGISTRR_CNTCT_ID, SUBMT_CNTCT_ID,
STEWRD_CNTCT_ID, SUBMT_ORG_ID, STEWRD_ORG_ID, ai.CREAT_DT, ai.CREAT_USR_ID, ai.LST_UPD_USR_ID, ai.FLD_DELETE, ai.LST_DEL_DT, ai.S2P_TRN_DT, ai.LST_UPD_DT,
 REGSTR_AUTH_ID,  NCI_IDSEQ, ADMIN_STUS_NM_DN, CNTXT_NM_DN, REGSTR_STUS_NM_DN, ORIGIN_ID, ORIGIN_ID_DN,  CREAT_USR_ID_X, LST_UPD_USR_ID_X, 0 CS_TYP_ID, CSI_TYP_ID CSI_TYP_ID, CSI_TYP_ID COMB_TYP_ID, cs.ACCESS_LVL from ADMIN_ITEM ai, NCI_CLSFCTN_SCHM_ITEM csi, CLSFCTN_SCHM cs
 where ADMIN_ITEM_TYP_ID = 51 and ai.item_id = csi.item_id and ai.ver_nr = csi.ver_nr and csi.p_item_id is not null and CS_ITEM_ID = cs.item_id and CS_ITEM_VER_NR = cs.ver_nr;


set escape off;
set define off;
 
  CREATE OR REPLACE VIEW VW_LIST_USR_CART_NM_FORM ("CART_NM", "CART_NM_SPEC", "CNTCT_SECU_ID", "GUEST_USR_NM", "CART_USR_NM", "RETAIN_IND", 
  "FORMAT_105_EXCEL", "FORMAT_115_EXCEL_REVIEW", "FORMAT_102_LEGACY_EXCEL", 
  "FORMAT_113_PRINTER", "FORMAT_110_RAVE", "FORMAT_109_REDCAP", 
  "CREAT_USR_ID", "LST_UPD_USR_ID", "FLD_DELETE", "LST_DEL_DT", "S2P_TRN_DT", "LST_UPD_DT", "CREAT_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT CART_NM, CART_NM CART_NM_SPEC, CNTCT_SECU_ID, GUEST_USR_NM, CART_NM || ' : ' || CNTCT_SECU_ID CART_USR_NM, max(nvl(retain_ind,0)) RETAIN_IND, 
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' || trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=105&type=usr\Form_Excel' FORMAT_105_EXCEL ,
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=115&type=usr\Form_Review_Excel' FORMAT_115_EXCEL_REVIEW,--Form Review Excel -formatid of 115
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=102&type=usr\Form_Legacy_Excel' FORMAT_102_LEGACY_EXCEL,
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=113&type=usr\Form_Printer_Friendly' FORMAT_113_PRINTER,
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=110&type=usr\Form_RAVE_ALS' FORMAT_110_RAVE,
  c.PARAM_VAL || '/Downloads/frmdirect.dsp?p_cntct_secu_id=' || trim(replace(CNTCT_SECU_ID,' ' ,'%20')) || '&p_guest_usr_nm=' ||  trim(replace(GUEST_USR_NM,' ' ,'%20')) ||'&p_cart_nm=' || trim(replace(CART_NM,' ' ,'%20')) || '&formatid=109&type=usr\Form_RedCAP' FORMAT_109_REDCAP,
           user CREAT_USR_ID,
            user LST_UPD_USR_ID,
            0 FLD_DELETE,
           sysdate LST_DEL_DT,
           sysdate S2P_TRN_DT,
           sysdate LST_UPD_DT,
           sysdate CREAT_DT
           from NCI_USR_CART , NCI_MDR_CNTRL c where nvl(fld_delete,0)  =0  and  c.param_nm='DOWNLOAD_HOST' group by CART_NM, CNTCT_SECU_ID, GUEST_USR_NM , c.param_val;


  CREATE OR REPLACE  VIEW VW_NCI_DS_RSLT as
  select "HDR_ID","ITEM_ID","VER_NR","RULE_ID","SCORE","RULE_DESC","USR_CMNTS","NUM_PV_IN_SRC","NUM_PV_IN_CDE","NUM_PV_MTCH","NM_MTCH_PRCNT",
  "NUM_PV_MTCH_FUZZY","CREAT_DT","CREAT_USR_ID","LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT","MTCH_DESC_TXT",
  "MTCH_TYP","CDE_PREF_IND","SRC_MTCH_ENGN" from nci_ds_rslt
  union
  select hdr_id, null, null, null, null, null, null, null, null, null, null, 
  null, h.creat_dt,h.creat_usr_id,"LST_UPD_USR_ID","FLD_DELETE","LST_DEL_DT","S2P_TRN_DT","LST_UPD_DT",null,
  null, null, null from nci_ds_hdr h where hdr_id not in (select hdr_id from nci_ds_rslt) and MTCH_TYP_NM = 'CDE';


  CREATE TABLE NCI_DS_PRMTR_TEMP
   (	"BTCH_USR_NM" VARCHAR2(100 BYTE) COLLATE "USING_NLS_COMP", 
	"CREAT_DT" DATE DEFAULT sysdate, 
	"CREAT_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"LST_UPD_USR_ID" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP" DEFAULT user, 
	"FLD_DELETE" NUMBER(1,0) DEFAULT 0, 
	"LST_DEL_DT" DATE DEFAULT sysdate, 
	"S2P_TRN_DT" DATE DEFAULT sysdate, 
	"LST_UPD_DT" DATE DEFAULT sysdate, 
	"CREATED_DT" DATE DEFAULT sysdate, 
	"CREATED_BY" VARCHAR2(50 BYTE) COLLATE "USING_NLS_COMP", 
	"REG_STUS_ID" NUMBER, 
	"ADMIN_STUS_ID" NUMBER, 
	"SRC_VAL_ID" NUMBER, 
	"CS_ID" NUMBER, 
	"CS_VER_NR" NUMBER(4,2), 
	"CNTXT_ID" NUMBER, 
	"CNTXT_VER_NR" NUMBER, 
	"VAL_DOM_TYP_ID" NUMBER, 
	"PRMTR_ID" NUMBER PRIMARY KEY, 
	"HDR_ID" NUMBER, 
	"NUM_CDE_MTCH" NUMBER, 
	"NUM_PV" NUMBER, 
	"DT_SORT" TIMESTAMP (9), 
	"DT_LST_MODIFIED" VARCHAR2(32 BYTE) COLLATE "USING_NLS_COMP", 
	"MTCH_TYP" VARCHAR2(32 BYTE) COLLATE "USING_NLS_COMP", 
	"MTCH_LMT" NUMBER, 
	"ENTTY_NM" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"ENTTY_NM_USR" VARCHAR2(4000 BYTE) COLLATE "USING_NLS_COMP", 
	"THRESHOLD_1" NUMBER(*,0), 
	"THRESHOLD_2" NUMBER(*,0), 
	"VARIANT_1" NUMBER(*,0), 
	"VARIANT_2" NUMBER(*,0), 
	"VARIANT_1_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP", 
	"VARIANT_2_NM" VARCHAR2(255 BYTE) COLLATE "USING_NLS_COMP"
   )  ;




