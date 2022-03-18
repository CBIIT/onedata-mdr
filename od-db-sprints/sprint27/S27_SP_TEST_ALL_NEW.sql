CREATE OR REPLACE procedure ONEDATA_WA.sp_test_all_NEW 
as
v_cnt integer;
begin

delete from OD_CADSR_TABLES_TEST_RESULTS;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'DE', 
(select count(*) from onedata_wa.de) WA_CNT,
((select count(*) from onedata_Wa.de)-(select count(*) from sbr.data_elements) ) DIFF_CNT,
(select count(*) from sbr.data_elements) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'DE Concept', 
(select count(*) from onedata_wa.de_conc) WA_CNT,
((select count(*) from onedata_wa.de_conc)- (select count(*) from sbr.data_element_concepts))DIFF_CNT,
(select count(*) from sbr.data_element_concepts) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Format', 
(select count(*) from onedata_wa.fmt) WA_CNT,
((select count(*) from onedata_wa.fmt)-(select count(*) from sbr.formats_lov)) DIFF_CNT,
(select count(*) from sbr.formats_lov) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Data type', 
(select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1) WA_CNT,
((select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1)- (select count(*) from sbr.datatypes_lov))DIFF_CNT,
(select count(*) from sbr.datatypes_lov) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Registration Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1 and FLD_DELETE=0) WA_CNT,
((select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1 and FLD_DELETE=0)-(select count(*) from sbr.reg_status_lov)) DIFF_CNT,
(select count(*) from sbr.reg_status_lov) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Workflow Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2 and FLD_DELETE=0) WA_CNT,
((select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2 and FLD_DELETE=0)-(select count(*) from sbr.ac_status_lov)) DIFF_CNT,
(select count(*) from sbr.ac_status_lov) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'UOM', 
(select count(*) from onedata_wa.UOM) WA_CNT,
((select count(*) from onedata_wa.UOM)-(select count(*) from sbr.unit_of_measures_lov)) DIFF_CNT,
(select count(*) from sbr.unit_of_measures_lov) caDSR_CNT,NULL
from dual;
commit;




insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'VV Repetition', 
(select count(*) from onedata_wa.NCI_QUEST_VV_REP) WA_CNT,
((select count(*) from onedata_wa.NCI_QUEST_VV_REP)-(select count(*) from sbrext.quest_vv_ext )) DIFF_CNT,
(select count(*) from sbrext.quest_vv_ext ) caDSR_CNT,NULL
from dual;
commit;





insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Conceptual Domain', 
(select count(*) from onedata_wa.conc_dom) WA_CNT,
((select count(*) from onedata_wa.conc_dom)-(select count(*) from sbr.conceptual_domains)) DIFF_CNT,
(select count(*) from sbr.conceptual_domains) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Object Class', 
(select count(*) from onedata_wa.obj_cls) WA_CNT,
((select count(*) from onedata_wa.obj_cls)-(select count(*) from sbrext.object_classes_ext)) DIFF_CNT,
(select count(*) from sbrext.object_classes_ext) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Property', 
(select count(*) from onedata_wa.prop) WA_CNT,
((select count(*) from onedata_wa.prop)-(select count(*) from sbrext.properties_ext)) DIFF_CNT,
(select count(*) from sbrext.properties_ext) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Value Domain', 
(select count(*) from onedata_wa.value_dom) WA_CNT,
((select count(*) from onedata_wa.value_dom)-(select count(*) from sbr.value_domains)) DIFF_CNT,
(select count(*) from sbr.value_domains) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Concept', 
(select count(*) from onedata_wa.CNCPT) WA_CNT,
((select count(*) from onedata_wa.CNCPT)-(select count(*) from sbrext.concepts_ext)) DIFF_CNT,
(select count(*) from sbrext.concepts_ext) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM)-(select count(*) from sbr.cs_items)) DIFF_CNT,
(select count(*) from sbr.cs_items) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Classification Scheme', 
(select count(*) from onedata_wa.CLSFCTN_SCHM) WA_CNT,
((select count(*) from onedata_wa.CLSFCTN_SCHM)-(select count(*) from sbr.classification_schemes)) DIFF_CNT,
(select count(*) from sbr.classification_schemes) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Representation Class', 
(select count(*) from onedata_wa.REP_CLS) WA_CNT,
((select count(*) from onedata_wa.REP_CLS)-(select count(*) from sbrext.representations_ext)) DIFF_CNT,
(select count(*) from sbrext.representations_ext) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Value Meaning', 
(select count(*) from onedata_wa.NCI_VAL_MEAN) WA_CNT,
((select count(*) from onedata_wa.NCI_VAL_MEAN)-(select count(*) from sbr.value_meanings)) DIFF_CNT,
(select count(*) from sbr.value_meanings) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Protocol', 
(select count(*) from onedata_wa.NCI_PROTCL) WA_CNT,
((select count(*) from onedata_wa.NCI_PROTCL)-(select count(*) from sbrext.protocols_ext)) DIFF_CNT,
(select count(*) from sbrext.protocols_ext) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'OC Recs', 
(select count(*) from onedata_wa.NCI_OC_RECS) WA_CNT,
((select count(*) from onedata_wa.NCI_OC_RECS)-(select count(*) from sbrext.oc_recs_ext)) DIFF_CNT,
(select count(*) from sbrext.oc_recs_ext) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Context', 
(select count(*) from onedata_wa.CNTXT) WA_CNT,
((select count(*) from onedata_wa.CNTXT)-(select count(*) from sbr.contexts)) DIFF_CNT,
(select count(*) from sbr.contexts) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean) WA_CNT,
((select count(*) from onedata_wa.conc_dom_val_mean)-(select count(*) from sbr.cd_vms)) DIFF_CNT,
(select count(*) from sbr.cd_vms) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'PV', 
(select count(*) from onedata_wa.PERM_VAL) WA_CNT,
((select count(*) from onedata_wa.PERM_VAL)-(select count(*) from sbr.vd_pvs)) DIFF_CNT,
(select count(*) from sbr.vd_pvs) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Concept - AI', 
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM) WA_CNT,
((select count(*) from onedata_wa.CNCPT_ADMIN_ITEM)-(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT)) DIFF_CNT,
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Designations', 
(select count(*) from onedata_wa.ALT_NMS) WA_CNT,
((select count(*) from onedata_wa.ALT_NMS)-(select count(*) from sbr.designations)) DIFF_CNT,
(select count(*) from sbr.designations) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Definitions', 
(select count(*) from onedata_wa.ALT_DEF) WA_CNT,
((select count(*) from onedata_wa.ALT_DEF)-(select count(*) from sbr.definitions)) DIFF_CNT,
(select count(*) from sbr.definitions) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Reference Documents', 
(select count(*) from onedata_wa.REF) WA_CNT,
((select count(*) from onedata_wa.REF)-(select count(*) from sbr.reference_documents)) DIFF_CNT,
(select count(*) from sbr.reference_documents) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Trigger Actions', 
(select count(*) from onedata_wa.NCI_FORM_TA) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA)-(select count(*) from sbrext.triggered_actions_ext)) DIFF_CNT,
(select count(*) from sbrext.triggered_actions_ext) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_wa.NCI_FORM_TA_REL) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA_REL)-(select count(*) from sbrext.ta_proto_csi_ext)) DIFF_CNT,
(select count(*) from sbrext.ta_proto_csi_ext) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Organization', 
(select count(*) from onedata_wa.NCI_ORG) WA_CNT,
((select count(*) from onedata_wa.NCI_ORG)-(select count(*) from sbr.ORGANIZATIONS)) DIFF_CNT,
(select count(*) from sbr.ORGANIZATIONS) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Person', 
(select count(*) from onedata_wa.NCI_PRSN) WA_CNT,
((select count(*) from onedata_wa.NCI_PRSN)-(select count(*) from sbr.persons)) DIFF_CNT,
(select count(*) from sbr.persons) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Addresses', 
(select count(*) from onedata_wa.NCI_ENTTY_ADDR) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_ADDR)-(select count(*) from sbr.contact_addresses)) DIFF_CNT,
(select count(*) from sbr.contact_addresses) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Communications', 
(select count(*) from onedata_wa.NCI_ENTTY_COMM) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_COMM)-(select count(*) from sbr.contact_comms) )DIFF_CNT,
(select count(*) from sbr.contact_comms) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Form', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54) WA_CNT,
((select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54)-(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE')) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Module', 
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52) WA_CNT,
((select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52)-(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE')) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE') caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63)-(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION')) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question VV', 
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE ) WA_CNT,
((select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE )-(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE')) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE') caDSR_CNT,NULL
from dual;
commit;

/****added NCI_INSTR****/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'From HDR Instruction', 
(select count(*) from onedata_wa.NCI_FORM where (HDR_INSTR is not null )) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null )-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'From FOOTER Instruction', 
(select count(*) from onedata_wa.NCI_FORM where ( FTR_INSTR is not NULL)) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Module Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null ) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' group by p_mod_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' group by p_mod_idseq))
 caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63 and INSTR is not null ) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63 and INSTR is not null)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' group by p_qst_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' group by p_qst_idseq))
 caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'VV Instruction', 
(select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null) WA_CNT,
((select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' group by P_VAL_IDSEQ)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' group by P_VAL_IDSEQ))
 caDSR_CNT,NULL
from dual;
commit;

 /***table NCI_ALT_KEY_ADMIN_ITEM_REL is replaced  by NCI_CLSFCTN_SCHM_ITEM*/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CS CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM ) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM )-(select count(*) from sbr.cs_csi) ) DIFF_CNT,
(select count(*) from sbr.cs_csi) caDSR_CNT,NULL
from dual;
commit;

/***table NCI_ALT_KEY_ADMIN_ITEM_REL is replaced by NCI_ADMIN_ITEM_REL***/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CS CSI DE Relationship', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65)- (select count(*) from sbr.ac_csi)) DIFF_CNT,
(select count(*) from sbr.ac_csi) caDSR_CNT,NULL
from dual;
commit;


/********  ADDED**********/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'COMPLEX DE Relationship', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66)- (select count(*) from sbr.complex_de_relationships)) DIFF_CNT,
(select count(*) from sbr.complex_de_relationships) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Program Area', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14 )-(select count(*) from sbr.PROGRAM_AREAS_LOV)) DIFF_CNT,
(select count(*) from sbr.PROGRAM_AREAS_LOV) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Designation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11 )-(select count(*) from sbr.DESIGNATION_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.DESIGNATION_TYPES_LOV) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Address Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25 )-(select count(*) from sbr.ADDR_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.ADDR_TYPES_LOV) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Communication Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26 )-(select count(*) from sbr.COMM_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.COMM_TYPES_LOV) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Status-Admin Type Relationship', 
(select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS ) WA_CNT,
((select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS)-(select count(*) from sbrext.ASL_ACTL_EXT) ) DIFF_CNT,
(select count(*) from sbrext.ASL_ACTL_EXT) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Derivation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21 )-(select count(*) from sbr.complex_rep_type_lov)) DIFF_CNT,
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Document Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1)-(select count(*) from sbr.document_TYPES_LOV) ) DIFF_CNT,
(select count(*) from sbr.document_TYPES_LOV) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Classification Scheme Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3 )-(select count(*) from sbr.CS_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.CS_TYPES_LOV) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CSI Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20 )-(select count(*) from sbr.CSI_TYPES_LOV )) DIFF_CNT,
(select count(*) from sbr.CSI_TYPES_LOV ) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Definition Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15 )-(select count(*) from sbrext.definition_types_lov_ext)) DIFF_CNT,
(select count(*) from sbrext.definition_types_lov_ext) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Origin', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18 )-(select count(*) from sbrext.sources_ext)) DIFF_CNT,
(select count(*) from sbrext.sources_ext) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Protocol Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 19) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 19 )-(select count(*) from (select distinct 19, TYPE, TYPE 
from sbrext.protocols_ext where type is not null ))) DIFF_CNT,
(select count(*) from (select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null )) caDSR_CNT,NULL
from dual;
commit;
-- Form Category where obj_typ_id = 22;
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Form Category', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 22) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 22 )-(select count(*) from sbrext.QC_DISPLAY_LOV_EXT)) DIFF_CNT,
(select count(*) from sbrext.QC_DISPLAY_LOV_EXT) caDSR_CNT,NULL
from dual;
commit;

Update OD_CADSR_TABLES_TEST_RESULTS set comments =
CASE 
    WHEN DIFF_CNT>0
    THEN 'The table '||TABLE_NAME||' has for '||DIFF_CNT||' recors more in OD'
    WHEN DIFF_CNT<0
    THEN 'The table '||TABLE_NAME||' has for '||-1*(DIFF_CNT)||' recors more in caDSR'
    END 
    where DIFF_CNT<>0;
    commit;
end;
/
