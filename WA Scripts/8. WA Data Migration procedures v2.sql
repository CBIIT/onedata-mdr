Data Migration Stored Procedures

create or replace procedure sp_create_ai_1 
as
v_cnt integer;
begin

-- Context creation
delete from cntxt;
commit;
delete from admin_item where admin_item_typ_id = 8;
commit;

-- Default version applied to context
insert into admin_item (admin_item_typ_id, NCI_iDSEQ, ITEM_DESC, ITEM_NM, ITEM_LONG_NM, NCI_ITEM_NM, VER_NR, CNTXT_NM_DN,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 8, trim(conte_idseq), description, name,name,name,version, name,
created_by, date_created,
nvl(date_modified, date_created), modified_by
from sbr.contexts;
commit;
-- Language is not used in context
insert into cntxt (ITEM_ID, VER_NR, LANG_ID, NCI_PRG_AREA_ID,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.ITEM_ID, ai.VER_NR, 1000, ok.OBJ_KEY_ID,
c.created_by, c.date_created,
nvl(c.date_modified, c.date_created), c.modified_by
from sbr.contexts c, admin_item ai, obj_key ok
where trim(ai.NCI_IDSEQ) = trim(c.conte_idseq)
and trim(c.pal_name) = trim(ok.NCI_CD)
and ok.obj_typ_id = 14
and ai.admin_item_typ_id = 8;
commit;

-- Conceptual Domain Creation
delete from conc_dom;
commit;
delete from admin_item where admin_item_typ_id = 1;
commit;


insert into admin_item (  NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN,
EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, 
CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID, 
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'CONCEPTUALDOMAIN' and
cntxt.admin_item_typ_id = 8;
commit;

insert into conc_dom (item_id, ver_nr, DIMNSNLTY, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr, cd.dimensionality, cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbr.conceptual_domains cd, admin_item ai where ai.NCI_IDSEQ = cd.CD_IDSEQ;
commit;

-- Object class and Property creation. Need to confirm the OC and Property specific attributes
delete from obj_cls;
commit;
delete from prop;
commit;
delete from admin_item where admin_item_typ_id in ( 5, 6);
commit;

insert into admin_item (  NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN,
EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, 
CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DEF_SRC)
select ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by,
oc.definition_source
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s, sbrext.object_classes_ext oc
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name in( 'OBJECTCLASS') and
cntxt.admin_item_typ_id = 8
and ac.ac_idseq = oc.oc_idseq;
commit;


insert into admin_item (  NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN,
EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, 
CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DEF_SRC)
select ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt_ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by,
prop.definition_source
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s, sbrext.properties_ext prop
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name in( 'PROPERTY') and
cntxt.admin_item_typ_id = 8
and ac.ac_idseq = prop.prop_idseq;
commit;


insert into obj_cls (item_id, ver_nr,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,  cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbrext.object_classes_ext cd, admin_item ai where ai.NCI_IDSEQ = cd.OC_IDSEQ;
commit;


insert into prop (item_id, ver_nr,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,  cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbrext.properties_ext cd, admin_item ai where ai.NCI_IDSEQ = cd.PROP_IDSEQ;
commit;

-- Default OC and Property for DECs that do not have OC or Property
insert into admin_item(item_id, ver_nr, nci_idseq, admin_item_typ_id, ITEM_LONG_NM,ITEM_DESC,ITEM_NM, NCI_ITEM_NM)
values (-20000, 1,'1',5,'Default Object Class','Default Object Class', 'Default Object Class','Default Object Class');
commit;
insert into admin_item(item_id, ver_nr, nci_idseq, admin_item_typ_id, ITEM_LONG_NM,ITEM_DESC,ITEM_NM, NCI_ITEM_NM)
values (-20001, 1,'2', 6,'Default Property','Default Property', 'Default Property','Default Property');
commit;
insert into obj_cls (item_id, ver_nr) values (-20000,1);
insert into prop (item_id, ver_nr) values (-20001,1);
commit;

-- Classification Scheme and Representation Class creation
delete from CLSFCTN_SCHM;
commit;
delete from REP_CLS;
commit;
delete from admin_item where admin_item_typ_id in ( 7,9);
commit;

insert into admin_item ( NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, 
CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name in( 'CLASSIFICATION') and
cntxt.admin_item_typ_id = 8;
commit;

insert into admin_item ( NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, 
CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID, 
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DEF_SRC)
select  ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by,
rep.definition_source
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s, sbrext.representations_ext rep
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name in( 'REPRESENTATION') and
cntxt.admin_item_typ_id = 8 and
ac.ac_idseq = rep.rep_idseq;
commit;

insert into clsfctn_schm (item_id, ver_nr, CLSFCTN_SCHM_TYP_ID, NCI_LABEL_TYP_FLG, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr, ok.obj_key_id, label_type_flag, cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbr.classification_schemes cd, admin_item ai, obj_key ok where ai.NCI_IDSEQ = cd.CS_IDSEQ and
trim(cstl_name) = ok.nci_cd and ok.obj_typ_id = 3;

commit;




insert into rep_cls (item_id, ver_nr,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,  cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbrext.representations_ext cd, admin_item ai where ai.NCI_IDSEQ = cd.REP_IDSEQ;
commit;


insert into admin_item (item_id, ver_nr, admin_item_typ_id, item_nm, nci_item_nm, ITEM_LONG_NM,ITEM_DESC)
values (-20002,1,5,'Default CD', 'Default CD', 'Default CD', 'Default CD');
commit;
insert into conc_dom (item_id, ver_nr) values (-20002,1);
commit;

end;
/

create or replace procedure sp_create_ai_2 
as
v_cnt integer;
begin


delete from de;
commit;

delete from value_dom;
commit;
delete from de_conc;
commit;

-- Creation of Value DOmain, DEC and DE

delete from admin_item where admin_item_typ_id in (2,3,4);
commit;

insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID,
ADMIN_STUS_NM_DN, 
EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
ait.obj_key_id,
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'DE_CONCEPT' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8 ;

commit;


insert into admin_item ( NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID,
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
ait.obj_key_id, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'VALUEDOMAIN' and
cntxt.admin_item_typ_id = 8;
commit;



insert into admin_item (
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM, ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 
ac.ac_idseq,
ait.obj_key_id, 
s.stus_id,
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name,ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'DATAELEMENT' and
cntxt.admin_item_typ_id = 8;
commit;

end;
/

create or replace procedure sp_create_ai_3 
as
v_cnt integer;
begin

delete from de;
commit;
delete from value_dom;
commit;
delete from de_conc;
commit;



insert into de_conc (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID,  PROP_VER_NR,  OBJ_CLS_QUAL, PROP_QUAL, 
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,cd.ITEM_ID, cd.VER_NR, oc.ITEM_ID, oc.VER_NR, prop.ITEM_ID, prop.VER_NR, dec.OBJ_CLASS_QUALIFIER, dec.PROPERTY_QUALIFIER,
 dec.created_by, dec.date_created,
nvl(dec.date_modified, dec.date_created), dec.modified_by from sbr.data_element_concepts dec, admin_item ai, admin_item oc, admin_item prop, admin_item cd where ai.NCI_IDSEQ = dec.dec_IDSEQ
and oc.admin_item_typ_id = 5
and prop.admin_item_typ_id =6 
and cd.admin_item_typ_id = 1
and  dec.oc_idseq = oc.NCI_IDSEQ
and  dec.prop_idseq= prop.NCI_IDSEQ 
and  dec.cd_idseq= cd.NCI_IDSEQ and
dec.oc_idseq  is not null
and dec.prop_idseq is not null;
commit;



insert into de_conc (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID,  PROP_VER_NR,  OBJ_CLS_QUAL, PROP_QUAL, 
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,cd.ITEM_ID, cd.VER_NR, oc.ITEM_ID, oc.VER_NR, -20001,1, dec.OBJ_CLASS_QUALIFIER, dec.PROPERTY_QUALIFIER,
 dec.created_by, dec.date_created,
nvl(dec.date_modified, dec.date_created), dec.modified_by from sbr.data_element_concepts dec, admin_item ai, admin_item oc,  admin_item cd where ai.NCI_IDSEQ = dec.dec_IDSEQ
and oc.admin_item_typ_id = 5
and cd.admin_item_typ_id = 1
and  dec.oc_idseq = oc.NCI_IDSEQ
and  dec.cd_idseq= cd.NCI_IDSEQ and
dec.oc_idseq  is not null
and dec.prop_idseq is  null;
commit;

insert into de_conc (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID,  PROP_VER_NR,  OBJ_CLS_QUAL, PROP_QUAL, 
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,cd.ITEM_ID, cd.VER_NR, -20000,1, prop.ITEM_ID, prop.VER_NR, dec.OBJ_CLASS_QUALIFIER, dec.PROPERTY_QUALIFIER,
 dec.created_by, dec.date_created,
nvl(dec.date_modified, dec.date_created), dec.modified_by from sbr.data_element_concepts dec, admin_item ai, admin_item prop, admin_item cd where ai.NCI_IDSEQ = dec.dec_IDSEQ
and prop.admin_item_typ_id =6 
and cd.admin_item_typ_id = 1
and  dec.prop_idseq= prop.NCI_IDSEQ 
and  dec.cd_idseq= cd.NCI_IDSEQ and
dec.oc_idseq is null and dec.prop_idseq is not null;
commit;

insert into de_conc (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID,  PROP_VER_NR,  OBJ_CLS_QUAL, PROP_QUAL, 
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,cd.ITEM_ID, cd.VER_NR, -20000,1, -20001,1, dec.OBJ_CLASS_QUALIFIER, dec.PROPERTY_QUALIFIER,
 dec.created_by, dec.date_created,
nvl(dec.date_modified, dec.date_created), dec.modified_by from sbr.data_element_concepts dec, admin_item ai,admin_item cd where ai.NCI_IDSEQ = dec.dec_IDSEQ
and cd.admin_item_typ_id = 1
and  dec.cd_idseq= cd.NCI_IDSEQ and
dec.oc_idseq is null and dec.prop_idseq is null;
commit;



insert into admin_item (item_id, ver_nr, admin_item_typ_id, item_nm, NCI_ITEM_NM)
values (-20003,1,2,'Unspecified DEC','Unspecified DEC');
commit;


insert into de_conc (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, OBJ_CLS_ITEM_ID, OBJ_CLS_VER_NR,PROP_ITEM_ID,  PROP_VER_NR)
select -20003, 1,-20002, 1, -20000,1, -20001,1 from dual;
commit;


insert into value_dom (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR, NCI_DEC_PREC,
DTTYPE_ID, VAL_DOM_FMT_ID,UOM_ID,VAL_DOM_HIGH_VAL_NUM,VAL_DOM_LOW_VAL_NUM,
VAL_DOM_MAX_CHAR,VAL_DOM_MIN_CHAR,REP_CLS_ITEM_ID,REP_CLS_VER_NR,
 CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
 VAL_DOM_TYP_ID)
select ai.item_id, ai.ver_nr,cd.ITEM_ID, cd.VER_NR, vd.decimal_place,
data_typ.DTTYPE_ID, fmt.fmt_id, uom.uom_id, vd.high_value_num,
vd.low_value_num, vd.max_length_num, vd.min_length_num, rc.item_id, rc.ver_nr,
 vd.created_by, vd.date_created,
nvl(vd.date_modified, vd.date_created), vd.modified_by,
decode(VD_TYPE_FLAG,'E' ,17, 'N', 18) from sbr.value_domains vd, admin_item ai, admin_item cd, admin_item rc,
uom, fmt, data_typ where ai.NCI_IDSEQ = vd.vd_IDSEQ
and cd.admin_item_typ_id = 1
and  vd.cd_idseq= cd.NCI_IDSEQ 
and vd.rep_idseq =  rc.nci_idseq (+) 
and vd.uoml_name = uom.nci_cd (+)
and vd.dtl_name = data_typ.nci_cd
and vd.forml_name =  fmt.nci_cd (+);
commit;

-- Update Standard data type based on mapping in OBJ_KEY table

update value_dom v set nci_std_dttype_id = (select  dt1.dttype_id
from data_typ dt, data_typ dt1 where dt.nci_dttype_map = dt1.dttype_nm and v.dttype_id = dt.dttype_id
and dt.nci_dttype_typ_id = 1 and dt1.nci_dttype_typ_id = 2);
commit;



insert into de (item_id, ver_nr,DE_CONC_ITEM_ID,DE_CONC_VER_NR,
VAL_DOM_ITEM_ID,VAL_DOM_VER_NR,
 CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,dec.ITEM_ID, dec.VER_NR, vd.ITEM_ID, vd.VER_NR ,
 de.created_by, de.date_created,
nvl(de.date_modified, de.date_created), de.modified_by from sbr.data_elements de, admin_item ai, admin_item dec, admin_item vd 
where ai.NCI_IDSEQ = de.de_IDSEQ
and dec.admin_item_typ_id = 2
and vd.admin_item_typ_id = 3
and  de.dec_idseq= dec.NCI_IDSEQ 
and de.vd_idseq =  vd.nci_idseq;
commit;

update de set (DERV_MTHD	, DERV_RUL , DERV_TYP_ID, CONCAT_CHAR, DERV_DE_IND) = 
(select METHODS,RULE, o.obj_key_id, cdr.CONCAT_CHAR, 1
 from sbr.complex_data_elements cdr, obj_key o , admin_item ai 
 where cdr.CRTL_NAME =o.nci_cd (+) and o.obj_typ_id (+) = 21 and cdr.p_de_idseq = ai.nci_idseq 
 and de.item_id = ai.item_id and de.ver_nr = ai.ver_nr);

commit;



insert into admin_item (item_id, ver_nr, admin_item_typ_id, item_nm, NCI_ITEM_NM)
values (-20004,1,2,'Unspecified VD','Unspecified VD');
commit;

insert into admin_item (item_id, ver_nr, admin_item_typ_id, item_nm, NCI_ITEM_NM)
values (-20005,1,2,'Unspecified DE','Unspecified DE');
commit;

insert into value_dom (item_id, ver_nr, CONC_DOM_ITEM_ID,CONC_DOM_VER_NR)
select -20004, 1,-20002, 1 from dual;
commit;

insert into de (item_id, ver_nr, VAL_DOM_ITEM_ID,VAL_DOM_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR)
select -20005, 1,-20004, 1, -20003, 1 from dual;
commit;


delete from nci_admin_item_rel where rel_typ_id = 65;
commit;


insert into nci_admin_item_rel
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID, DISP_ORD,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
--DISP_LBL, 
--CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select  prnt.item_id, prnt.ver_nr, child.item_id, child.ver_nr, 
65, display_order,
cdr.created_by, cdr.date_created,
nvl(cdr.date_modified, cdr.date_created), cdr.modified_by 
--, qc.DISPLAY_ORDER
--, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
from admin_item prnt, admin_item child, sbr.complex_de_relationships cdr
where prnt.nci_idseq = cdr.p_de_idseq and child.nci_idseq= cdr.c_de_idseq;
commit;

end;
/

create or replace procedure sp_create_ai_4
as
v_cnt integer;
begin


delete from nci_oc_recs;
commit;

delete from admin_item where admin_item_typ_id = 56;
commit;

insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID,
ADMIN_STUS_NM_DN, 
EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
56,
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac,  admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'OBJECTRECS' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8 ;

commit;


insert into NCI_OC_RECS
(ITEM_ID,VER_NR,TRGT_OBJ_CLS_ITEM_ID,TRGT_OBJ_CLS_VER_NR,
SRC_OBJ_CLS_ITEM_ID,SRC_OBJ_CLS_VER_NR,REL_TYP_NM,
SRC_ROLE,TRGT_ROLE,DRCTN,SRC_LOW_MULT,SRC_HIGH_MULT,
TRGT_LOW_MULT,TRGT_HIGH_MULT,DISP_ORD,DIMNSNLTY,ARRAY_IND)
select ocr.ocr_id, ocr.version, toc.item_id, toc.ver_nr, soc.item_id, soc.ver_nr, 
rl_name, source_role, target_role, direction, source_low_multiplicity,
source_high_multiplicity,target_low_multiplicity,target_high_multiplicity,
display_order,dimensionality,array_ind from sbrext.oc_recs_ext ocr, admin_item soc, admin_item toc
where soc.admin_item_typ_id = 5 and toc.admin_item_typ_id = 5 and ocr.t_oc_idseq = toc.nci_idseq 
and ocr.s_oc_idseq = soc.nci_idseq;
commit;

end;
/

create or replace procedure sp_create_ai_children
as
v_cnt integer;
begin

-- Alternate Definitions
delete from alt_def;
commit;

insert into  alt_def ( ITEM_ID, VER_NR, 
CNTXT_ITEM_ID, CNTXT_VER_NR, DEF_DESC,
NCI_DEF_TYP_ID, LANG_ID,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_IDSEQ)
select ai.item_id, ai.ver_nr, cntxt.item_id, cntxt.ver_nr,
definition, ok.obj_key_id, decode(upper(lae_name), 'ENGLISH', 1000, 'ICELANDIC', 1007, 'SPANISH', 1004),
created_by, date_created,nvl(date_modified, date_created), modified_by, def.defin_idseq
from 
admin_item ai, sbr.definitions def, admin_item cntxt, obj_key ok
where ai.nci_idseq = def.ac_idseq
and def.conte_idseq = cntxt.nci_idseq
and cntxt.admin_item_typ_id = 8
and def.defl_name = ok.nci_cd (+)
and ok.obj_typ_id (+) = 15;

-- Alternate Names
delete from alt_nms;
commit;

insert into  alt_nms ( ITEM_ID, VER_NR, 
CNTXT_ITEM_ID, CNTXT_VER_NR, NM_DESC,
NM_TYP_ID, LANG_ID,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, CNTXT_NM_DN, NCI_IDSEQ)
select ai.item_id, ai.ver_nr, cntxt.item_id, cntxt.ver_nr,
name, ok.obj_key_id,  decode(upper(lae_name), 'ENGLISH', 1000, 'ICELANDIC', 1007, 'SPANISH', 1004),
created_by, date_created,nvl(date_modified, date_created), modified_by, cntxt.ITEM_NM, def.desig_idseq
from 
admin_item ai, sbr.designations def, admin_item cntxt, obj_key ok
where ai.nci_idseq = def.ac_idseq
and def.conte_idseq = cntxt.nci_idseq
and cntxt.admin_item_typ_id = 8
and def.detl_name = ok.nci_cd (+)
and ok.obj_typ_id (+)= 11;
commit;

-- Reference Documents
delete from ref;
commit;

insert into  ref ( ITEM_ID, VER_NR, 
NCI_CNTXT_ITEM_ID, NCI_CNTXT_VER_NR,REF_TYP_ID,DISP_ORD,
REF_DESC, REF_NM,LANG_ID, URL,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_IDSEQ)
select ai.item_id, ai.ver_nr, cntxt.item_id, cntxt.ver_nr,
ok.obj_key_id, display_order, doc_text, name,  decode(upper(lae_name), 'ENGLISH', 1000, 'ICELANDIC', 1007, 'SPANISH', 1004),URL,
created_by, date_created,nvl(date_modified, date_created), modified_by, rd_idseq
from 
admin_item ai, sbr.reference_documents def, admin_item cntxt, obj_key ok
where ai.nci_idseq = def.ac_idseq
and def.conte_idseq = cntxt.nci_idseq
and cntxt.admin_item_typ_id = 8
and def.dctl_name = ok.nci_cd (+)
and ok.obj_typ_id (+)= 1 ;
commit;


delete from NCI_CSI_ALT_DEFNMS;
commit;



insert into NCI_CSI_ALT_DEFNMS
(NCI_PUB_ID ,  NCI_VER_NR ,  NMDEF_ID ,  TYP_NM)
--,
--CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select distinct ak.NCI_PUB_ID, ak.NCI_VER_NR, NM_ID,atl_name
--att.created_by, att.date_created,
--att.date_modified, att.modified_by
from nci_admin_item_rel_alt_key ak, sbrext.AC_ATT_CSCSI_EXT att, alt_nms am
where ak.nci_idseq = att.cs_csi_idseq and am.nci_idseq = att.att_idseq and atl_name = 'DESIGNATION'
and ak.nci_idseq is not null;
commit;



insert into NCI_CSI_ALT_DEFNMS
(NCI_PUB_ID ,  NCI_VER_NR ,  NMDEF_ID ,  TYP_NM )
--CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select distinct ak.NCI_PUB_ID, ak.NCI_VER_NR, DEF_ID, atl_name
--att.created_by, att.date_created,
--att.date_modified, att.modified_by
from nci_admin_item_rel_alt_key ak, sbrext.AC_ATT_CSCSI_EXT att, alt_def am
where ak.nci_idseq = att.cs_csi_idseq and am.nci_idseq = att.att_idseq and atl_name = 'DEFINITION';
commit;
end;

/

create or replace procedure sp_create_ai_cncpt 
as
v_cnt integer;
begin
delete from cncpt_admin_item;
commit;
delete from cncpt;
commit;

-- Concept and concept relationships
delete from admin_item where admin_item_typ_id =49;
commit;



insert into admin_item ( NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
 EFF_DT, CHNG_DESC_TXT,
 UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DEF_SRC)
select ac.con_idseq,
49,
 ac.begin_date,ac.change_note,
--conte_idseq,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.con_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by,
ac.definition_source
from sbrext.concepts_ext ac;

commit;

insert into cncpt (item_id, ver_nr, evs_src_id, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con_id, version, ok.obj_key_id,
created_by, date_created,
nvl(date_modified, date_created), modified_by
from sbrext.concepts_ext c, obj_key ok where c.evs_source = ok.obj_key_desc (+) and ok.obj_typ_id (+)=23;
commit;


-- Object class-Concept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, oc.item_id, oc.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbrext.object_classes_ext oce, admin_item con ,admin_item oc
where cc.CONDR_IDSEQ = oce.CONDR_IDSEQ and oce.oc_idseq = oc.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;




-- Property- Concept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, prop.item_id, prop.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbrext.properties_ext prope, admin_item con ,admin_item prop
where cc.CONDR_IDSEQ = prope.CONDR_IDSEQ and prope.prop_idseq = prop.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;


-- Representation CLass - COncept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, rep.item_id, rep.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbrext.representations_ext repe, admin_item con ,admin_item rep
where cc.CONDR_IDSEQ = repe.CONDR_IDSEQ and Repe.rep_idseq = rep.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;


-- Value Meaning  - COncept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, rep.item_id, rep.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbr.value_meanings vm, admin_item con ,admin_item rep
where cc.CONDR_IDSEQ = vm.CONDR_IDSEQ and vm.vm_idseq = rep.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;


-- Value Domain  - COncept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, vd.item_id, vd.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbr.value_domains vde, admin_item con ,admin_item vd
where cc.CONDR_IDSEQ = vde.CONDR_IDSEQ and vde.vd_idseq = vd.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;


-- Conceptual Domain  - COncept relationship

insert into cncpt_admin_item (cncpt_item_id, cncpt_ver_nr, item_id, ver_nr, nci_ord, nci_prmry_ind, nci_cncpt_val,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select con.item_id, con.ver_nr, cd.item_id, cd.ver_nr, cc.DISPLAY_ORDER, decode(cc.primary_flag_ind, 'Yes',1,'No',0), concept_value,
cc.created_by, cc.date_created,
nvl(cc.date_modified, cc.date_created), cc.modified_by
from sbrext.COMPONENT_CONCEPTS_EXT cc, sbr.conceptual_domains cde, admin_item con ,admin_item cd
where cc.CONDR_IDSEQ = cde.CONDR_IDSEQ and cde.cd_idseq = cd.nci_idseq and cc.con_idseq = con.nci_idseq;
commit;
end;

/
create or replace procedure sp_create_csi
as
v_cnt integer;
begin

delete from NCI_ALT_KEY_ADMIN_ITEM_REL where rel_typ_id = 65;
commit;

delete from admin_item where admin_item_typ_id =51 ;
commit;

delete from nci_clsfctn_schm_item;
commit;


insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID,
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
51, 
s.stus_id,
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac, obj_key ait, admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ait.NCI_CD )= trim(actl_name) and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'CS_ITEM' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8 ;

commit;

insert into NCI_CLSFCTN_SCHM_ITEM  (item_id, ver_nr, CSI_TYP_ID, CSI_DESC_TXT, CSI_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr, ok.obj_key_id, description, comments, cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbr.cs_items cd, admin_item ai, obj_key ok where ai.NCI_IDSEQ = cd.CSI_IDSEQ and
trim(csitl_name) = ok.nci_cd and ok.obj_typ_id = 20;
commit;

-- cs_csi - give it an alternate key.
delete from nci_admin_item_rel_alt_key where rel_typ_id  = 64;
commit;

insert into nci_admin_item_rel_alt_key
(  CNTXT_CS_ITEM_ID,   CNTXT_CS_VER_NR, P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR,
DISP_ORD, DISP_LBL, NCI_VER_NR, REL_TYP_ID, NCI_IDSEQ,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select cs.item_id, cs.ver_nr, pcsi.item_id, pcsi.ver_nr, ccsi.item_id, ccsi.ver_nr,
cscsi.DISPLAY_ORDER, cscsi.label,  1, 64, cscsi.CS_CSI_IDSEQ,
cscsi.created_by, cscsi.date_created,
nvl(cscsi.date_modified,cscsi.date_created), cscsi.modified_by
from admin_item cs, admin_item pcsi, admin_item ccsi, sbr.cs_csi cscsi, sbr.cs_csi pcscsi
where cscsi.cs_idseq = cs.nci_idseq
and cscsi.p_cs_csi_idseq is not null
and pcscsi.cs_csi_idseq = cscsi.p_cs_csi_idseq 
and pcscsi.csi_idseq = pcsi.nci_idseq 
and cscsi.csi_idseq = ccsi.nci_idseq;
commit;


insert into nci_admin_item_rel_alt_key
(  CNTXT_CS_ITEM_ID,   CNTXT_CS_VER_NR,  C_ITEM_ID, C_ITEM_VER_NR,
DISP_ORD, DISP_LBL, NCI_VER_NR, REL_TYP_ID, NCI_IDSEQ,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select cs.item_id, cs.ver_nr,  ccsi.item_id, ccsi.ver_nr,
cscsi.DISPLAY_ORDER, cscsi.label,  1, 64, cscsi.CS_CSI_IDSEQ,
cscsi.created_by, cscsi.date_created,
nvl(cscsi.date_modified,cscsi.date_created), cscsi.modified_by
from admin_item cs, admin_item ccsi, sbr.cs_csi cscsi
where cscsi.cs_idseq = cs.nci_idseq
and cscsi.p_cs_csi_idseq is null
and cscsi.csi_idseq = ccsi.nci_idseq;
commit;

insert into NCI_ALT_KEY_ADMIN_ITEM_REL (NCI_PUB_ID  ,  NCI_VER_NR  , C_ITEM_ID ,  C_ITEM_VER_NR ,  REL_TYP_ID,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ak.nci_pub_id, ak.nci_ver_nr, ai.item_id, ai.ver_nr, 65,
accsi.created_by, accsi.date_created,
nvl(accsi.date_modified, accsi.date_created), accsi.modified_by
from  sbr.ac_csi accsi, nci_admin_item_rel_alt_key ak, admin_item ai
where accsi.ac_idseq = ai.nci_idseq and
 accsi.cs_csi_idseq = ak.nci_idseq and ak.rel_typ_id = 64;
commit;


end;
/

create or replace procedure sp_create_form_ext
as
v_cnt integer;
begin

-- Create AI for TEmplate, Form, Protocol, Module



delete from nci_form;
commit;

delete from nci_protcl;
commit;

delete from admin_item where admin_item_typ_id in (50,52,54,55) ;
commit;

insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
54, 
s.stus_id, 
s.nci_STUS, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
ac.date_modified, ac.modified_by
from sbr.administered_components ac,  admin_item cntxt, stus_mstr s, sbrext.quest_contents_ext qc
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'QUEST_CONTENT' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8 
and ac.ac_idseq = qc.qc_idseq
--and qc.qtl_name in ('CRF','TEMPLATE', 'MODULE');
and qc.qtl_name in ('TEMPLATE','CRF');
commit;

delete from nci_form;
commit;


insert into nci_form (item_id, ver_nr, catgry_id,form_typ_id, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc_id, version, ok.obj_key_id, decode(qc.qtl_name, 'CRF', 70, 'TEMPLATE', 71),
created_by, date_created,
date_modified, modified_by
from sbrext.quest_contents_ext qc, obj_key ok where qc.qcdl_name = ok.nci_cd (+) and
ok.obj_typ_id (+)=22 and qc.qtl_name in ('TEMPLATE','CRF');
commit;

insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID,
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM, ITEM_NM , ITEM_ID,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
decode(qc.qtl_name,  'CRF',54, 'MODULE', 52, 'TEMPLATE', 55), 
s.stus_id, 
s.NCI_STUS, ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name, ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
ac.date_modified, ac.modified_by
from sbr.administered_components ac,  admin_item cntxt, stus_mstr s, sbrext.quest_contents_ext qc
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'QUEST_CONTENT' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8 
and ac.ac_idseq = qc.qc_idseq
--and qc.qtl_name in ('CRF','TEMPLATE', 'MODULE');
and qc.qtl_name ='MODULE';
commit;

insert into admin_item (  
NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID,
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select  ac.ac_idseq,
50, 
s.stus_id, 
s.nci_stus, 
ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by
from sbr.administered_components ac,  admin_item cntxt, stus_mstr s
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'PROTOCOL' and
--ac.end_date is not null and
cntxt.admin_item_typ_id = 8;

commit;


insert into nci_protcl (item_id, ver_nr, PROTCL_TYP_ID, PROTCL_ID, LEAD_ORG, PROTCL_PHASE, creat_usr_id, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
 	CHNG_TYP,	CHNG_NBR,	RVWD_DT,	RVWD_USR_ID, APPRVD_DT,	APPRVD_USR_ID)
select ai.item_id, ai.ver_nr, ok.obj_key_id, protocol_id, LEAD_ORG,PHASE, cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by,
CHANGE_TYPE,CHANGE_NUMBER,REVIEWED_DATE,REVIEWED_BY,APPROVED_DATE, APPROVED_BY
from sbrext.protocols_ext cd, admin_item ai, obj_key ok where ai.NCI_IDSEQ = cd.proto_IDSEQ and
trim(type) = ok.nci_cd (+) and ok.obj_typ_id (+)= 19 and ai.admin_item_typ_id = 50;

commit;




end;

/

create or replace procedure sp_create_form_question_rel
as
v_cnt integer;
begin

delete from nci_admin_item_rel_alt_key where rel_typ_id = 63;
commit;

insert into nci_admin_item_rel_alt_key
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID, NCI_PUB_ID, NCI_IDSEQ, NCI_VER_NR,
EDIT_IND, REQ_IND, DEFLT_VAL, ITEM_LONG_NM)
--DISP_LBL, 
--CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select distinct mod.item_id, mod.ver_nr, de.item_id, de.ver_nr,
63, QC_ID,
qc.QC_IDSEQ, 
QC.VERSION,
decode(qa.editable_ind, 'Yes', 1,'No',0),
decode(qa.mandatory_ind, 'Yes',1, 'No', 0),
qa.default_value,
LONG_NAME
--, qc.DISPLAY_ORDER
--, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
from admin_item de, admin_item mod, sbrext.quest_contents_ext qc, sbrext.QUEST_ATTRIBUTES_EXT qa
where de.nci_idseq = qc.De_idseq and mod.nci_idseq= qc.p_mod_idseq
and qc.qtl_name = 'QUESTION' and de.admin_item_typ_id = 4
and mod.admin_item_typ_id = 52 and qc.de_idseq is not null and qc.qc_idseq = qa.qc_idseq (+);
commit;

insert into nci_admin_item_rel_alt_key
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID, NCI_PUB_ID, NCI_IDSEQ, NCI_VER_NR,
EDIT_IND, REQ_IND, DEFLT_VAL, ITEM_LONG_NM)
--DISP_LBL, 
--CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select distinct mod.item_id, mod.ver_nr, -10005, 1,
63, QC_ID,
qc.QC_IDSEQ, 
QC.VERSION,
decode(qa.editable_ind, 'Yes', 1,'No',0),
decode(qa.mandatory_ind, 'Yes',1, 'No', 0),
qa.default_value,
LONG_NAME
--, qc.DISPLAY_ORDER
--, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
from admin_item mod, sbrext.quest_contents_ext qc, sbrext.QUEST_ATTRIBUTES_EXT qa
where mod.nci_idseq= qc.p_mod_idseq
and qc.qtl_name = 'QUESTION' 
and mod.admin_item_typ_id = 52 and qc.de_idseq is null and qc.qc_idseq = qa.qc_idseq (+);
commit;


end;

/

create or replace procedure sp_create_form_rel
as
v_cnt integer;
begin

delete from nci_admin_item_rel where rel_typ_id in (61,62,60);
commit;


-- new table for Protocol-form relationship
-- Do not add audit columns

insert into nci_admin_item_rel
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID)
select  distinct pro.item_id, pro.ver_nr, frm.item_id, frm.ver_nr,
60
--, qc.DISPLAY_ORDER
from admin_item pro, admin_item frm, sbrext.protocol_qc_ext qc
where pro.nci_idseq = qc.proto_idseq and frm.nci_idseq= qc.qc_idseq
and pro.admin_item_typ_id = 50
and frm.admin_item_typ_id = 54;
commit;

-- Form-module relationship
insert into nci_admin_item_rel
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID, DISP_ORD, REP_NO,
--DISP_LBL, 
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select distinct  frm.item_id, frm.ver_nr,mod.item_id, mod.ver_nr,
61, qc.DISPLAY_ORDER, qc.REPEAT_NO
, qc.DATE_CREATED,qc.CREATED_BY,nvl(qc.MODIFIED_BY, qc.date_created),DATE_MODIFIED
from admin_item mod, admin_item frm, sbrext.quest_contents_ext qc
where mod.nci_idseq = qc.qc_idseq and frm.nci_idseq= qc.dn_crf_idseq
and qc.qtl_name = 'MODULE' and mod.admin_item_typ_id = 52
and frm.admin_item_typ_id = 54;
commit;

/*
-- Template-Module relationship
insert into nci_admin_item_rel
(P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, 
--CNTXT_ITEM_ID, CNTXT_VER_NR, 
REL_TYP_ID, DISP_ORD, REP_NO,
--DISP_LBL, 
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select distinct  frm.item_id, frm.ver_nr,mod.item_id, mod.ver_nr,
62
, qc.DISPLAY_ORDER,qc.REPEAT_NO
, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
--, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
from admin_item mod, admin_item frm, sbrext.quest_contents_ext qc
where mod.nci_idseq = qc.qc_idseq and frm.nci_idseq= qc.dn_crf_idseq
and qc.qtl_name = 'MODULE' and mod.admin_item_typ_id = 52
and frm.admin_item_typ_id = 55;
commit;
*/


end;

/

create or replace procedure sp_create_form_ta
as
v_cnt integer;
begin

delete from nci_form_ta_rel;
commit;

delete from nci_form_ta;
commit;


--MODULE	MODULE

insert into NCI_FORM_TA 
( SRC_PUB_ID, SRC_VER_NR, TRGT_PUB_ID, TRGT_VER_NR, TA_INSTR, SRC_TYP_NM, TRGT_TYP_NM, TA_IDSEQ,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select mod1.item_id, mod1.ver_nr, mod2.item_id, mod2.ver_nr, TA_INSTRUCTION, S_QTL_NAME, T_QTL_NAME, TA_IDSEQ,
ta.DATE_CREATED,ta.CREATED_BY,ta.MODIFIED_BY,nvl(ta.DATE_MODIFIED, ta.date_created)
from sbrext.triggered_actions_ext ta, admin_item mod1, admin_item mod2 where mod1.admin_item_typ_id = 52
and mod2.admin_item_typ_id = 52 and ta.s_qc_idseq = mod1.nci_idseq and ta.t_qc_idseq = mod2.nci_idseq;
commit;

--MODULE	QUESTION

insert into NCI_FORM_TA 
( SRC_PUB_ID, SRC_VER_NR, TRGT_PUB_ID, TRGT_VER_NR, TA_INSTR, SRC_TYP_NM, TRGT_TYP_NM, TA_IDSEQ,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select mod1.item_id, mod1.ver_nr, quest.nci_pub_id, quest.nci_ver_nr, TA_INSTRUCTION, S_QTL_NAME, T_QTL_NAME, TA_IDSEQ,
ta.DATE_CREATED,ta.CREATED_BY,ta.MODIFIED_BY,nvl(ta.DATE_MODIFIED, ta.date_created)
from sbrext.triggered_actions_ext ta, admin_item mod1, nci_admin_item_rel_alt_key quest where mod1.admin_item_typ_id = 52
and quest.rel_typ_id = 63 and ta.s_qc_idseq = mod1.nci_idseq and ta.t_qc_idseq = quest.nci_idseq;
commit;


-- QUESTION	QUESTION


insert into NCI_FORM_TA 
( SRC_PUB_ID, SRC_VER_NR, TRGT_PUB_ID, TRGT_VER_NR, TA_INSTR, SRC_TYP_NM, TRGT_TYP_NM, TA_IDSEQ,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select quest1.nci_pub_id, quest1.nci_ver_nr, quest2.nci_pub_id, quest2.nci_ver_nr, TA_INSTRUCTION, S_QTL_NAME, T_QTL_NAME,TA_IDSEQ,
ta.DATE_CREATED,ta.CREATED_BY,ta.MODIFIED_BY,nvl(ta.DATE_MODIFIED, ta.date_created)
from sbrext.triggered_actions_ext ta, nci_admin_item_rel_alt_key quest1, nci_admin_item_rel_alt_key quest2 where 
--quest1.rel_typ_id = 63
--and quest2.rel_typ_id = 63 and 
ta.s_qc_idseq = quest1.nci_idseq and ta.t_qc_idseq = quest2.nci_idseq;
commit;

--VALID_VALUE	QUESTION


insert into NCI_FORM_TA 
( SRC_PUB_ID, SRC_VER_NR, TRGT_PUB_ID, TRGT_VER_NR, TA_INSTR, SRC_TYP_NM, TRGT_TYP_NM, TA_IDSEQ,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select vv.nci_pub_id, vv.nci_ver_nr, quest.nci_pub_id, quest.nci_ver_nr, TA_INSTRUCTION, S_QTL_NAME, T_QTL_NAME, TA_IDSEQ,
ta.DATE_CREATED,ta.CREATED_BY,ta.MODIFIED_BY,nvl(ta.DATE_MODIFIED, ta.date_created)
from sbrext.triggered_actions_ext ta, nci_quest_Valid_value vv, nci_admin_item_rel_alt_key quest where quest.rel_typ_id = 63
 and ta.s_qc_idseq = vv.nci_idseq and ta.t_qc_idseq = quest.nci_idseq;
 commit;

--VALID_VALUE	MODULE


insert into NCI_FORM_TA 
( SRC_PUB_ID, SRC_VER_NR, TRGT_PUB_ID, TRGT_VER_NR, TA_INSTR, SRC_TYP_NM, TRGT_TYP_NM, TA_IDSEQ,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select vv.nci_pub_id, vv.nci_ver_nr, mod.item_id, mod.ver_nr, TA_INSTRUCTION, S_QTL_NAME, T_QTL_NAME, TA_IDSEQ,
ta.DATE_CREATED,ta.CREATED_BY,ta.MODIFIED_BY,nvl(ta.DATE_MODIFIED, ta.date_created)
from sbrext.triggered_actions_ext ta, nci_quest_Valid_value vv, admin_item mod where mod.admin_item_typ_id = 52
 and ta.s_qc_idseq = vv.nci_idseq and ta.t_qc_idseq = mod.nci_idseq;
 commit;

insert into NCI_FORM_TA_REL (TA_ID, NCI_PUB_ID, NCI_VER_NR,
CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
select ta.ta_id, ai.item_id, ai.ver_nr, 
t.DATE_CREATED,t.CREATED_BY,t.MODIFIED_BY,nvl(t.DATE_MODIFIED, t.date_created)
 from
nci_form_ta ta, sbrext.ta_proto_csi_ext t, admin_item ai
where ta.ta_idseq = t.ta_idseq and t.proto_idseq = ai.nci_idseq and t.proto_idseq is not null;
commit;
end;

/

create or replace procedure sp_create_form_vv_inst
as
v_cnt integer;
begin

delete from NCI_QUEST_VALID_VALUE;
commit;

insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
(	QUEST_PUB_ID , 	QUEST_VER_NR ,
	VV_PUB_ID,	VV_VER_NR,
	VAL,EDIT_IND ,	REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
nvl(qvv.date_modified, qvv.date_created), qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;

end;

/

create or replace procedure sp_create_form_vv_inst_2
as
v_cnt integer;
begin

delete from nci_instr;
commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'INSTRUCTION',ai.VER_NR, display_order, qc.preferred_name,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FORM_INSTR' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'FOOTER',ai.VER_NR, display_order, qc.preferred_name,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FOOTER' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'MODULE', 'INSTRUCTION',ai.VER_NR, display_order, qc.preferred_name,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
qc.p_mod_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'QUESTION', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.preferred_name,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'VALUES', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.preferred_name,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;

/*

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, ver_nr, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF)
select ai.nci_pub_id, 'VALUE',1, display_order, min(qc.preferred_name),min(qc.preferred_name), max(qc.preferred_definition)
from sbrext.quest_contents_ext qc, Nci_QUEST_VALID_VALUE ai where qc.qtl_name = 'VALUE_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq group by ai.nci_pub_id,1, display_order;

commit;
/*
insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, QVV_VM_NM, QVV_VM_LNM, QVV_VALUE, QVV_CMNTS, QVV_EDIT_IND, QVV_SEQ_NBR)
select qc.qc_id, qc1.qc_id, qc.preferred_name, qc.preferred_definition 
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1
where qc.qtl_name = 'VALID_VALUE' and and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq;

*/

end;
/


create or replace procedure sp_create_pv
as
v_cnt integer;
begin

delete from perm_val;
commit;
delete from conc_dom_val_mean;
commit;
delete from nci_val_mean;
commit;
-- Value Meaning
delete from admin_item where admin_item_typ_id = 53;
commit;


-- Value Meaning as AI
insert into admin_item ( NCI_IDSEQ, 
ADMIN_ITEM_TYP_ID, 
ADMIN_STUS_ID, 
ADMIN_STUS_NM_DN, EFF_DT, CHNG_DESC_TXT,
CNTXT_ITEM_ID, CNTXT_VER_NR, CNTXT_NM_DN, UNTL_DT, CURRNT_VER_IND, ITEM_LONG_NM, ORIGIN,
ITEM_DESC,NCI_ITEM_NM,ITEM_ID, 
ITEM_NM,
--STEWRD_ORG_ID
UNRSLVD_ISSUE,VER_NR,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DEF_SRC)
select ac.ac_idseq,
53,
s.stus_id, 
s.nci_stus, ac.begin_date,ac.change_note,
--conte_idseq,
cntxt.item_id,
cntxt.ver_nr,
cntxt.item_nm,
ac.end_date,
decode(upper(ac.latest_version_ind),'YES', 1,'NO',0),
ac.long_name,
ac.origin,
ac.preferred_definition,
ac.preferred_name,
ac.public_id,
nvl(ac.long_name, ac.preferred_name),
--stewa_idseq,
ac.unresolved_issue,
ac.version,
ac.created_by, ac.date_created,
nvl(ac.date_modified, ac.date_created), ac.modified_by,
vm.definition_source
from sbr.administered_components ac,  admin_item cntxt, stus_mstr s, sbr.value_meanings vm
where ac.conte_idseq = cntxt.nci_idseq and 
trim(ac.asl_name) = trim(s.nci_STUS) and
ac.actl_name = 'VALUEMEANING' and
--ac.end_date is null and
cntxt.admin_item_typ_id = 8 and
ac.ac_idseq = vm.vm_idseq;
commit;


insert into NCI_VAL_MEAN  (item_id, ver_nr, VM_DESC_TXT, VM_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, ai.ver_nr,  description, comments, cd.created_by, cd.date_created,
nvl(cd.date_modified, cd.date_created), cd.modified_by from sbr.value_meanings cd, admin_item ai where ai.NCI_IDSEQ = cd.VM_IDSEQ;
commit;

-- Value Meaning - Conceptual Domain relationship
insert into conc_dom_val_mean (conc_dom_item_id, conc_dom_ver_nr, nci_val_mean_item_id, nci_val_mean_ver_nr,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select cd.item_id, cd.ver_nr, vm.item_id, vm.ver_nr ,cvm.created_by, cvm.date_created,
nvl(cvm.date_modified, cvm.date_created), cvm.modified_by
from admin_item cd, admin_item vm, sbr.cd_vms cvm
where cvm.cd_idseq = cd.nci_idseq
and cvm.vm_idseq = vm.nci_idseq;
commit;

-- Permissible Values

insert into perm_val
(PERM_VAL_BEG_DT, PERM_VAL_END_DT,
PERM_VAL_NM, PERM_VAL_DESC_TXT, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, 
CREAT_DT, CREAT_USR_ID,  LST_UPD_DT,LST_UPD_USR_ID,
NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR, NCI_IDSEQ)
select pvs.BEGIN_DATE, 
pvs.END_DATE, VALUE, SHORT_MEANING, 
vd.item_id, vd.ver_nr,
--MEANING_DESCRIPTION,  HIGH_VALUE_NUM, LOW_VALUE_NUM, 
pvs.DATE_CREATED, pvs.CREATED_BY, nvl(pvs.DATE_MODIFIED, pvs.date_created), pvs.MODIFIED_BY,
vm.item_id, vm.ver_nr, pv.pv_idseq
from sbr.permissible_Values pv, admin_item vm, admin_item vd,
sbr.vd_pvs pvs where pv.pv_idseq = pvs.pv_idseq and pvs.vd_idseq = vd.nci_idseq
and pv.vm_idseq = vm.nci_idseq;
commit;

end;
/

create or replace procedure sp_migrate_lov 
as
v_cnt integer;
begin
delete from stus_mstr;
commit;

v_cnt := 1;

for cur in (select registration_status,description,
                    comments,created_by, date_created,
                    date_modified, modified_by,
                    display_order from sbr.reg_status_lov order by display_order) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.registration_status, cur.registration_status, cur.description, cur.comments, cur.created_by, cur.date_created,
cur.date_modified, cur.modified_by, cur.display_order, 1);
v_cnt := v_cnt + 1;

end loop;

v_cnt := 50;

for cur in (select asl_name,description,
                    comments,created_by, date_created,
                    date_modified, modified_by,
                    display_order from sbr.ac_status_lov order by asl_name) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.asl_name, cur.asl_name, cur.description, cur.comments, cur.created_by, cur.date_created,
cur.date_modified, cur.modified_by, cur.display_order, 2);
v_cnt := v_cnt + 1;
end loop;
commit;



delete from obj_key where obj_typ_id = 14;  -- Program Area
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 14, pal_name, description, pal_name, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.PROGRAM_AREAS_LOV;
commit;


delete from obj_key where obj_typ_id = 11;  -- Name/designation
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 11, detl_name, description, detl_name, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.DESIGNATION_TYPES_LOV;
commit;

-- DOcument type
delete from obj_key where obj_typ_id = 1;  -- 
commit;

-- Preferred Question Text ID needs to be static. Used in views.
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, NCI_CD) values (80,1,'Preferred Question Text', 'Preferred Question Text','Preferred Question Text');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 1, DCTL_NAME, description, DCTL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.document_TYPES_LOV where DCTL_NAME not like 'Preferred Question Text';
commit;


-- Classification Scheme Type
delete from obj_key where obj_typ_id = 3;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 3, CSTL_NAME, description, CSTL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.CS_TYPES_LOV;
commit;

-- Classification Scheme Item Type
delete from obj_key where obj_typ_id = 20;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 20, CSITL_NAME, description, CSITL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbr.CSI_TYPES_LOV;
commit;

-- Protocol Type
delete from obj_key where obj_typ_id = 19;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd) 
select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null ;
commit;



-- Concept Source
delete from obj_key where obj_typ_id = 23;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select  23, CONCEPT_SOURCE,DESCRIPTION, CONCEPT_SOURCE, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.concept_sources_lov_ext ;
commit;



-- NCI Derivation Type
delete from obj_key where obj_typ_id = 21;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 21, CRTL_NAME,CRTL_NAME, DESCRIPTION , created_by, date_created,
                    nvl(date_modified,date_created), modified_by  from sbr.complex_rep_type_lov ;
commit;



--- Data type

delete from data_typ;
commit;
insert into data_typ ( DTTYPE_NM, NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DTTYPE_SCHM_REF, DTTYPE_ANNTTN)
select DTL_NAME, DTL_NAME, DESCRIPTION,COMMENTS,
created_by, date_created,date_modified, modified_by,
SCHEME_REFERENCE, ANNOTATION from sbr.datatypes_lov;
commit;

-- Format
delete from FMT;
commit;
insert into FMT ( FMT_NM, NCI_CD,FMT_DESC,FMT_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select FORML_NAME, FORML_NAME,DESCRIPTION,COMMENTS,
created_by, date_created,nvl(date_modified,date_created), modified_by from sbr.formats_lov;
commit;

-- UOM
delete from UOM;
commit;
insert into UOM ( UOM_NM,NCI_CD, UOM_PREC,UOM_DESC,UOM_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select UOML_NAME,UOML_NAME,PRECISION,
DESCRIPTION,COMMENTS,
created_by, date_created,nvl(date_modified,date_created), modified_by from sbr.unit_of_measures_lov;
commit;




-- Definition type
delete from obj_key where obj_typ_id = 15;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 15, DEFL_NAME, description, DEFL_NAME, comments, created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.definition_types_lov_ext;
                   

commit;



-- Origin
delete from obj_key where obj_typ_id = 18;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 18, SRC_NAME, description, SRC_NAME,  created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.sources_ext;
                   

commit;


-- Origin
delete from obj_key where obj_typ_id = 18;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 18, SRC_NAME, description, SRC_NAME,  created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.sources_ext;
                   

commit;

-- Form Category
delete from obj_key where obj_typ_id = 22;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 22, QCDL_NAME, description, QCDL_NAME,  created_by, date_created,
                    nvl(date_modified,date_created), modified_by from sbrext.QC_DISPLAY_LOV_EXT;
                   

commit;


-- GEt standard data types from Excel spreadsheet

update data_typ set nci_dttype_typ_id = 1;
commit;
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ALPHANUMERIC';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'anyClass';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'binary';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'BOOLEAN';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CHARACTER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CLOB';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'DATE';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Date Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'DATE/TIME';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'DATETIME';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'Derived';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'HL7CDv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7EDv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'HL7INTv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7PNv3';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'HL7REALv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7STv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7TELv3';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'HL7TSv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'Integer';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADPartv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCNTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPDALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPSTAv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPZIPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ANYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090BAGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'ISO21090BLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090CDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090DSETv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDTEXTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENONv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENPNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENTNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTNTNEGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTPOSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IVLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090PQTIMEv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090PQv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090QTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090REALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090RTOv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STSIMv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELURLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDATFLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDTTIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090TSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090Tv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090URGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'java.lang.Boolean';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Byte';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Character';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'java.lang.Double';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'java.lang.Float';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer[]';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Long';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Object';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Short';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String[]';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.sql.Timestamp';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Collection';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.util.Date';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Map';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'NUMBER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Numeric Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'OBJECT';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Date';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Time';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'TIME';
update data_typ set NCI_DTTYPE_MAP = 'Octet' where DTTYPE_NM = 'UMLBinaryv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLCodev1.0';
update data_typ set NCI_DTTYPE_MAP = 'Octet' where DTTYPE_NM = 'UMLOctetv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUidv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUriv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLXMLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'varchar';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'xsd:boolean';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'xsd:dateTime';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'xsd:string';
commit;

-- insert standard datatypes
insert into data_typ(dttype_nm, nci_dttype_typ_id)
select distinct NCI_DTTYPE_MAP, 2 from data_typ where NCI_DTTYPE_MAP is not null;
commit;


delete from org;
commit;

insert into org (NCI_IDSEQ, ORG_NM, RA_IND,ORG_MAIL_ADR,CREAT_USR_ID,CREAT_DT,
LST_UPD_USR_ID, LST_UPD_DT)
select ORG_IDSEQ,NAME,
decode(RA_IND, 'No',0,'Yes',1),
MAIL_ADDRESS,CREATED_BY,
DATE_CREATED,
MODIFIED_BY,
nvl(date_modified,date_created)
from sbr.organizations;
commit;

delete from lang;
commit;

INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1007, 'ICELANDIC', 'Icelandic'); 
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1000, 'ENGLISH', 'English'); 
commit;
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1004, 'SPANISH', 'Spanish'); 
commit;
commit;

end;
/


create or replace procedure sp_org_contact
as
v_cnt integer;
begin
update admin_item set (REGSTR_STUS_ID, REGSTR_STUS_NM_DN) = 
(select s.stus_id, s.NCI_STUS
from sbr.ac_registrations ar, stus_mstr s where 
upper(ar.REGISTRATION_STATUS) = upper(s.stus_nm) and ar.ac_idseq = admin_item.nci_idseq
and ar.registration_status is not null);
commit;

--update admin_item set REGSTR_STUS_ID = 10, REGSTR_STUS_NM_DN = 'Historical' where REGSTR_STUS_ID is null; 
--commit;

update admin_item set (ORIGIN_ID, ORIGIN_ID_DN) = 
(Select obj_key_id, obj_key_desc from obj_key ok, sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and ac.origin = ok.obj_key_desc and ok.obj_typ_id = 18);
commit;

update admin_item set (ORIGIN) = 
(Select origin from sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and origin not in (select obj_key_desc from obj_key where obj_typ_id = 18));
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY, CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, a.used_by, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai where an.cntxt_item_id = ai.item_id ) 
GROUP BY item_id, ver_nr) a,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+);
commit;

end;
/


create or replace procedure sp_truncate_all
as
v_cnt integer;
begin

delete from NCI_CSI_ALT_DEFNMS;
commit;
delete from NCI_ALT_KEY_ADMIN_ITEM_REL;
commit;

delete from NCI_FORM_TA_REL;
commit;

delete from ADMIN_ITEM_AUDIT;
commit;
delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from NCI_FORM_TA;
commit;
delete from NCI_INSTR;
commit;
delete from NCI_CS_ITEM_REL;
commit;
delete from NCI_QUEST_VV_REP;
commit;
delete from NCI_ADMIN_ITEM_REL_ALT_KEY;
commit;
delete from NCI_QUEST_VALID_VALUE;
commit;
delete from NCI_ADMIN_ITEM_REL;
commit;

delete from NCI_CLSFCTN_SCHM_ITEM;
commit;
delete from NCI_OC_RECS;
commit;
delete from NCI_TEMPLATE;
commit;
delete from NCI_FORM;
commit;
delete from NCI_PROTCL;
commit;
delete from NCI_VAL_MEAN;
commit;


delete from perm_val;
commit;
delete from conc_dom_val_mean;
commit;
delete from cncpt_admin_item;
commit;

delete from nci_val_mean;
commit;

delete from de;
commit;
delete from de_conc;
commit;
delete from value_dom;
commit;
delete from conc_dom;
commit;
delete from rep_cls;
commit;
delete from clsfctn_schm;
commit;
delete from obj_cls;
commit;
delete from prop;
commit;
delete from alt_nms;
commit;
delete from alt_def;
commit;
delete from ref;
commit;
delete from cncpt;
commit;
delete from cntxt;
commit;
delete from admin_item;
commit;

end;
/

create or replace procedure sp_preprocess
as
v_cnt integer;
begin

update sbr.administered_components set version=2.99 where ac_idseq = 'AECD5F45-40DE-6F74-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = '99BA9DC8-2782-4E69-E034-080020C9C0E0';
update sbr.administered_components set version=3.99 where ac_idseq = 'B96A571D-FCFF-23B9-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'C2F74AAA-C66F-2D5B-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'BAD1CCE2-EEA3-09A9-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = '9B8825ED-D747-0817-E034-080020C9C0E0';
update sbr.administered_components set version=2.99 where ac_idseq = 'B2044F73-E974-68B8-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'BFF123A5-B223-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=1.99 where ac_idseq = 'BFF123A5-B1F2-1C5B-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'DB67CC4F-54E4-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=99.99 where ac_idseq = 'E063C484-B72A-4D2C-E034-0003BA12F5E7';
update sbr.administered_components set version=3.99 where ac_idseq = 'B30B7C1F-2DCF-1182-E034-0003BA12F5E7';
update sbr.administered_components set version=4.99 where ac_idseq = 'DDEAEB6E-32A1-3CD4-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-F1E1-675B-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DB67CC4F-5242-474F-E034-0003BA12F5E7';
update sbr.administered_components set version=2.99 where ac_idseq = 'DBF67698-EE6F-675B-E034-0003BA12F5E7';

commit;
end;

/
