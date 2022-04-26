create or replace procedure spTestReverseRange (vHours in integer)
as
v_cnt integer;
begin

delete from TEST_RESULTS;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - DE', 
(select count(*) from onedata_wa.admin_item where admin_item_typ_id = 4 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.data_elements where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'DATAELEMENT') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - DE Concept', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 2 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.data_element_concepts where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'DE_CONCEPT') RA_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - VV Repetition', 
(select count(*) from onedata_wa.NCI_QUEST_VV_REP where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_vv_ext where date_modified >= sysdate - vHours/24 ) caDSR_CNT
from dual;
commit;





insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Conceptual Domain', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 1 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.conceptual_domains where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'DE_CONCEPT') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Object Class', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 5 and nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.object_classes_ext where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'OBJECTCLASS') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Property', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 6 and   nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.properties_ext where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'PROPERTY') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Value Domain', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 3 and   nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.value_domains where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'VALUEDOMAIN') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Concept', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 49 and nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.concepts_ext where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'DE_CONCEPT') RA_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - CSI', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 51 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.cs_items where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'CS_ITEM') RA_CNT
from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Classification Scheme', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 9 and   nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.classification_schemes where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'CLASSIFICATION') RA_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Representation Class', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 7 and   nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.representations_ext where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'REPRESENTATION') RA_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Value Meaning', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 53 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.value_meanings where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'VALUEMEANING') RA_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Protocol', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 50 and nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.protocols_ext where date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name = 'PROTOCOL') RA_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT)
select 'Administered Item - Context', 
(select count(*) from onedata_wa.admin_item where  admin_item_typ_id = 8 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.contexts where date_modified >= sysdate - vHours/24) caDSR_CNT from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Administered Item Specific - CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.cd_vms where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Administered Item Specific - PV', 
(select count(*) from onedata_wa.PERM_VAL where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.vd_pvs where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Administered Item Specific - Component Concepts', 
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Common - Designations', 
(select count(*) from onedata_wa.ALT_NMS where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.designations where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Common - Definitions', 
(select count(*) from onedata_wa.ALT_DEF where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.definitions where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Common - Reference Documents', 
(select count(*) from onedata_wa.REF where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.reference_documents where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT, RA_CNT)
select 'Administered Item - Form', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE') and date_modified >= sysdate - vHours/24) caDSR_CNT,
(select count(*) from sbr.administered_components where date_modified >= sysdate - vHours/24 and actl_name in ('CRF','TEMPLATE')) RA_CNT
from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT, caDSR_CNT)
select 'Administered Item - Module', 
(select count(*) cnt1 from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE' and date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;



insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Question', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Question VV', 
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24 ) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE' and date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;

/****added NCI_INSTR****/
insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Form Header', 
(select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null  and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ('FORM_INSTR') and date_modified >= sysdate - vHours/24)
 caDSR_CNT
from dual;
commit;

/****added NCI_INSTR****/
insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Form Footer', 
(select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL and  nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ('FOOTER') and date_modified >= sysdate - vHours/24)
 caDSR_CNT
from dual;
commit;

insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Module Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and   nvl(fld_delete,0) = 0 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ('MODULE_INSTR') and date_modified >= sysdate - vHours/24)
 caDSR_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - Question Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63   and lst_upd_dt >= sysdate - vHours/24 ) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ('QUESTION_INSTR') and date_modified >= sysdate - vHours/24)
 caDSR_CNT
from dual;
commit;


insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Form - VV Instruction', 
(select count(*) from onedata_wa.nci_quest_valid_value where  lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ('VALUE_INSTR') and date_modified >= sysdate - vHours/24)
 caDSR_CNT
from dual;
commit;


/***table NCI_ALT_KEY_ADMIN_ITEM_REL is replaced by NCI_ADMIN_ITEM_REL***/
insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Common - Classifications', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65  and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.ac_csi where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;


/********  ADDED**********/
insert into TEST_RESULTS (TABLE_NAME, WA_CNT,  caDSR_CNT)
select 'Administered Item Specific - DDE', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and lst_upd_dt >= sysdate - vHours/24) WA_CNT,
(select count(*) from sbr.complex_de_relationships where date_modified >= sysdate - vHours/24) caDSR_CNT
from dual;
commit;


end;
/
