CREATE OR REPLACE procedure sp_test_all_NEW
as
v_cnt integer;
begin

delete from OD_CADSR_TABLES_TEST_RESULTS;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'DE', 
(select count(*) from onedata_wa.de where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_Wa.de  where nvl(fld_delete,0)=0)-(select count(*) from sbr.data_elements where nvl(deleted_ind,'No') ='No') ) DIFF_CNT,
(select count(*) from sbr.data_elements where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'DE Concept', 
(select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0)=0)- (select count(*) from sbr.data_element_concepts  where nvl(deleted_ind,'No') ='No'))DIFF_CNT,
(select count(*) from sbr.data_element_concepts  where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
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

--insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
--select 'VV Repetition', 
--(select count(*) from onedata_wa.NCI_QUEST_VV_REP) WA_CNT,
--((select count(*) from onedata_wa.NCI_QUEST_VV_REP)-(select count(*) from sbrext.quest_vv_ext )) DIFF_CNT,
--(select count(*) from sbrext.quest_vv_ext ) caDSR_CNT,NULL
--from dual;
--commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Conceptual Domain', 
(select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0)=0)-(select count(*) from sbr.conceptual_domains  where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.conceptual_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Object Class', 
(select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.object_classes_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.object_classes_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Property', 
(select count(*) from onedata_wa.prop  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.prop where nvl(fld_delete,0)=0)-(select count(*) from sbrext.properties_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.properties_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Value Domain', 
(select count(*) from onedata_wa.value_dom where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.value_dom where nvl(fld_delete,0)=0)-(select count(*) from sbr.value_domains where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.value_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Concept', 
(select count(*) from onedata_wa.CNCPT where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CNCPT  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.concepts_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.concepts_ext  where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where nvl(fld_delete,0)=0)-(select count(*) from sbr.cs_items where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.cs_items where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Classification Scheme', 
(select count(*) from onedata_wa.CLSFCTN_SCHM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CLSFCTN_SCHM  where nvl(fld_delete,0)=0)-(select count(*) from sbr.classification_schemes where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.classification_schemes where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Representation Class', 
(select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0)=0)-(select count(*) from sbrext.representations_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.representations_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Value Meaning', 
(select count(*) from onedata_wa.NCI_VAL_MEAN where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_VAL_MEAN  where nvl(fld_delete,0)=0)-(select count(*) from sbr.value_meanings where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.value_meanings where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Protocol', 
(select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.protocols_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.protocols_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'OC Recs', 
(select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.oc_recs_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.oc_recs_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Context', 
(select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0)=0)-(select count(*) from sbr.contexts )) DIFF_CNT,
(select count(*) from sbr.contexts ) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.conc_dom_val_mean )-(select count(*) from sbr.cd_vms )) DIFF_CNT,
(select count(*) from sbr.cd_vms ) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'PV', 
(select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0)=0)-
(select count(*) from sbr.vd_pvs )) DIFF_CNT,
(select count(*) from sbr.vd_pvs) caDSR_CNT,NULL
from dual;
commit;

--insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
--select 'Concept - AI',  
--(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0)  WA_CNT,
--((select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0) -
--(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT ) ) DIFF_CNT,
--(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT ) caDSR_CNT,NULL
--from dual;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Concept - AI',  
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0)=0)  WA_CNT,
(SELECT count(*) from onedata_wa.CNCPT_ADMIN_ITEM c where nvl(c.fld_delete,0)=0 )-         
(select count(*)
FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               SBR.concepts_ext con ,
               (select OC_IDSEQ NCI_IDSEQ,condr_idseq from sbrext.object_classes_ext
               union 
               select PROP_IDSEQ,condr_idseq from sbrext.properties_ext 
                union 
               select rep_IDSEQ,condr_idseq from SBREXT.REPRESENTATIONS_EXT
               union
               select VD_IDSEQ,condr_idseq from SBR.VALUE_DOMAINS
               union
               select VM_IDSEQ,condr_idseq from SBR.VALUE_MEANINGS
               UNION 
               select CD_IDSEQ,condr_idseq from sbr.conceptual_domains 
               )ai
         WHERE    cc.con_idseq = con.con_idseq
         and ai.condr_idseq= cc.CONDR_IDSEQ)  DIFF_CNT,
( select count(*)
FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               SBR.concepts_ext con ,
               (select OC_IDSEQ NCI_IDSEQ,condr_idseq from sbrext.object_classes_ext
               union 
               select PROP_IDSEQ,condr_idseq from sbrext.properties_ext 
                union 
               select rep_IDSEQ,condr_idseq from SBREXT.REPRESENTATIONS_EXT
               union
               select VD_IDSEQ,condr_idseq from SBR.VALUE_DOMAINS
               union
               select VM_IDSEQ,condr_idseq from SBR.VALUE_MEANINGS
               UNION 
               select CD_IDSEQ,condr_idseq from sbr.conceptual_domains 
               )ai
         WHERE    cc.con_idseq = con.con_idseq
         and ai.condr_idseq= cc.CONDR_IDSEQ) caDSR_CNT,NULL 
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Designations', 
(select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0)=0)-(select count(*) from sbr.designations )) DIFF_CNT,
(select count(*) from sbr.designations ) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Definitions', 
(select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0)=0)-
(select count(*) from sbr.definitions )) DIFF_CNT,
(select count(*) from sbr.definitions ) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Reference Documents', 
(select count(*) from onedata_wa.REF where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.REF where nvl(fld_delete,0)=0)-(select count(*) from sbr.reference_documents )) DIFF_CNT,
(select count(*) from sbr.reference_documents ) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Trigger Actions', 
(select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0)=0)-(select count(*) from sbrext.triggered_actions_ext 
)) DIFF_CNT,
(select count(*) from sbrext.triggered_actions_ext ) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0)=0)-(select count(*) from sbrext.ta_proto_csi_ext )) DIFF_CNT,
(select count(*) from sbrext.ta_proto_csi_ext ) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Organization', 
(select count(*) from onedata_wa.NCI_ORG where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ORG where nvl(fld_delete,0)=0)-(select count(*) from sbr.ORGANIZATIONS )) DIFF_CNT,
(select count(*) from sbr.ORGANIZATIONS ) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Person', 
(select count(*) from onedata_wa.NCI_PRSN where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_PRSN where nvl(fld_delete,0)=0)-
(select count(*) from sbr.persons )) DIFF_CNT,
(select count(*) from sbr.persons ) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Addresses', 
(select count(*) from onedata_wa.NCI_ENTTY_ADDR  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_ADDR  where nvl(fld_delete,0)=0)-(select count(*) from sbr.contact_addresses)) DIFF_CNT,
(select count(*) from sbr.contact_addresses ) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Communications', 
(select count(*) from onedata_wa.NCI_ENTTY_COMM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_COMM where nvl(fld_delete,0)=0)-(select count(*) from sbr.contact_comms ) )DIFF_CNT,
(select count(*) from sbr.contact_comms ) caDSR_CNT,NULL
from dual;
commit;



insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Form', 
(select count(*) from onedata_wa.NCI_FORM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where nvl(fld_delete,0)=0)-
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE') ) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Module', 
(select count(*) from NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from NCI_ADMIN_ITEM_REL where REL_TYP_ID=61 and nvl(fld_delete,0)=0)-(select count(*) from sbrext.quest_contents_ext 
where qtl_name = 'MODULE' and nvl(deleted_ind,'No') ='No' and DN_CRF_IDSEQ is not null)) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext m where qtl_name = 'MODULE' and nvl(deleted_ind,'No') ='No'
and m.DN_CRF_IDSEQ is not null) caDSR_CNT,null
from dual
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0)=0)-(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No'and P_MOD_IDSEQ is not null)) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No' and P_MOD_IDSEQ is not null) caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question VV', 
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0)=0)-
(select count(*) from sbrext.quest_contents_ext vv ,sbrext.quest_contents_ext q 
where vv.P_QST_IDSEQ =q.QC_IDSEQ and q.qtl_name = 'QUESTION' and nvl(q.deleted_ind,'No') ='No'
and vv.qtl_name = 'VALID_VALUE' and nvl(vv.deleted_ind,'No') ='No' )) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext vv ,sbrext.quest_contents_ext q 
where vv.P_QST_IDSEQ =q.QC_IDSEQ and q.qtl_name = 'QUESTION' and nvl(q.deleted_ind,'No') ='No'
and vv.qtl_name = 'VALID_VALUE' and nvl(vv.deleted_ind,'No') ='No' ) caDSR_CNT, null 
from dual
commit;

/****added NCI_INSTR****/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'From HDR Instruction', 
(select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null  and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'From FOOTER Instruction', 
(select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL  and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual;
commit;

insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Module Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null  and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_mod_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_mod_idseq))
 caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Question Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63 and INSTR is not null  and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63 and INSTR is not null  and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))
 caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'VV Instruction', 
(select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null and nvl(fld_delete,0) = 0) WA_CNT,
((select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null and nvl(fld_delete,0) = 0))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by P_VAL_IDSEQ)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by P_VAL_IDSEQ))
 caDSR_CNT,NULL
from dual;
commit;

 /***table NCI_ALT_KEY_ADMIN_ITEM_REL is replaced  by NCI_CLSFCTN_SCHM_ITEM*/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CS CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where CS_CSI_IDSEQ is not null and nvl(fld_delete,0) = 0) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where CS_CSI_IDSEQ is not null and nvl(fld_delete,0) = 0)-(select count(*) from sbr.cs_csi ) ) DIFF_CNT,
(select count(*) from sbr.cs_csi ) caDSR_CNT,NULL
from dual;

/***table NCI_ALT_KEY_ADMIN_ITEM_REL is replaced by NCI_ADMIN_ITEM_REL***/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'CS CSI DE Relationship', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65 and nvl(fld_delete,0) = 0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65 and nvl(fld_delete,0) = 0)- (select count(*) from sbr.ac_csi )) DIFF_CNT,
(select count(*) from sbr.ac_csi ) caDSR_CNT,NULL
from dual;
commit;


/********  ADDED**********/
insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'COMPLEX DE Relationship', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0)- 
(select count(*) from sbr.complex_de_relationships)) DIFF_CNT,
(select count(*) from sbr.complex_de_relationships) caDSR_CNT,NULL
from dual;
commit;


insert into OD_CADSR_TABLES_TEST_RESULTS (TABLE_NAME, WA_CNT, DIFF_CNT, caDSR_CNT,COMMENTS)
select 'Program Area', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14 )-
(select count(*) from sbr.PROGRAM_AREAS_LOV )) DIFF_CNT,
(select count(*) from sbr.PROGRAM_AREAS_LOV ) caDSR_CNT,NULL
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
((select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS)-
(select count(*) from sbrext.ASL_ACTL_EXT)) DIFF_CNT,
(select count(*) from sbrext.ASL_ACTL_EXT)caDSR_CNT,NULL
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
from sbrext.protocols_ext where type is not null and nvl(deleted_ind,'No') ='No'))) DIFF_CNT,
(select count(*) from (select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null and nvl(deleted_ind,'No') ='No') ) caDSR_CNT,NULL
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

