--12/6/22
select 'DE' Table_Name, 
(select count(*) from sbr.data_elements where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'DE Concept', 
(select count(*) from sbr.data_element_concepts  where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Format', 
(select count(*) from sbr.formats_lov) caDSR_CNT
from dual
UNION
select 'Data type', 
(select count(*) from sbr.datatypes_lov) caDSR_CNT
from dual
UNION
select 'Registration Status', 
(select count(*) from sbr.reg_status_lov) caDSR_CNT
from dual
UNION
select 'Workflow Status', 
(select count(*) from sbr.ac_status_lov) caDSR_CNT
from dual
UNION
select 'UOM', 
(select count(*) from sbr.unit_of_measures_lov) caDSR_CNT
from dual
UNION
select 'Conceptual Domain', 
(select count(*) from sbr.conceptual_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Object Class', 
(select count(*) from sbrext.object_classes_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Property', 
(select count(*) from sbrext.properties_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Value Domain', 

(select count(*) from sbr.value_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Concept', 

(select count(*) from sbrext.concepts_ext  where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'CSI', 

(select count(*) from sbr.cs_items where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Classification Scheme', 
(select count(*) from sbr.classification_schemes where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Representation Class', 
(select count(*) from sbrext.representations_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Value Meaning', 
(select count(*) from sbr.value_meanings where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Protocol', 
(select count(*) from sbrext.protocols_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'OC Recs', 
(select count(*) from sbrext.oc_recs_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Context', 
(select count(*) from sbr.contexts ) caDSR_CNT
from dual
UNION
select 'CD-VM', 
(select count(*) from sbr.cd_vms ) caDSR_CNT
from dual
UNION
select 'PV', 
(select count(*) from sbr.vd_pvs) caDSR_CNT
from dual
UNION
select 'Concept - AI',  
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
         and ai.condr_idseq= cc.CONDR_IDSEQ) caDSR_CNT 
from dual
UNION
select 'Designations', 
(select count(*) from sbr.designations ) caDSR_CNT
from dual
UNION
select 'Definitions', 
(select count(*) from sbr.definitions ) caDSR_CNT
from dual
UNION
select 'Derivation Type', 
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT
from dual
UNION
select 'Reference Documents', 
(select count(*) from sbr.reference_documents ) caDSR_CNT
from dual
UNION
select 'Trigger Actions', 
(select count(*) from sbrext.triggered_actions_ext ) caDSR_CNT
from dual
UNION
select 'Trigger Actions Protocol/CSI', 
(select count(*) from sbrext.ta_proto_csi_ext ) caDSR_CNT
from dual
UNION
select 'Organization', 
(select count(*) from sbr.ORGANIZATIONS ) caDSR_CNT
from dual
UNION
select 'Person', 
(select count(*) from sbr.persons ) caDSR_CNT
from dual
UNION
select 'Addresses', 
(select count(*) from sbr.contact_addresses ) caDSR_CNT
from dual
UNION
select 'Communications', 
(select count(*) from sbr.contact_comms ) caDSR_CNT
from dual
UNION
select 'Form', 
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE') ) caDSR_CNT
from dual
UNION
select 'Module', 
(select count(*) from sbrext.quest_contents_ext m where qtl_name = 'MODULE' and nvl(deleted_ind,'No') ='No'
and m.DN_CRF_IDSEQ is not null) caDSR_CNT
from dual
UNION
select 'Question', 
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,
SBREXT.QUEST_CONTENTS_EXT F WHERE Q.QTL_NAME = 'QUESTION'
AND NVL(Q.DELETED_IND,'No') ='No'AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ) caDSR_CNT
from dual
UNION
select 'Question VV', 
--SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT VV ,SBREXT.QUEST_CONTENTS_EXT Q ,
--SBREXT.QUEST_CONTENTS_EXT M,SBREXT.QUEST_CONTENTS_EXT F
--WHERE VV.P_QST_IDSEQ =Q.QC_IDSEQ AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
--AND M.DN_CRF_IDSEQ=F.QC_IDSEQ  AND Q.QTL_NAME = 'QUESTION' AND NVL(Q.DELETED_IND,'No') ='No'
--AND VV.QTL_NAME = 'VALID_VALUE' AND NVL(VV.DELETED_IND,'No') ='No'  

(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT VV ,SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,SBREXT.QUEST_CONTENTS_EXT F
WHERE VV.P_QST_IDSEQ =Q.QC_IDSEQ AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ  AND Q.QTL_NAME = 'QUESTION' AND NVL(Q.DELETED_IND,'No') ='No'
AND VV.QTL_NAME = 'VALID_VALUE' AND NVL(VV.DELETED_IND,'No') ='No') caDSR_CNT
  from dual
UNION
select 'From HDR Instruction', 
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT
from dual
UNION
select 'From FOOTER Instruction', 
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT
from dual
UNION
select 'Module Instruction', 
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_mod_idseq))
 caDSR_CNT
from dual
UNION
select 'Question Instruction', 
--(select count(*) from(
--select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
--where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))
 caDSR_CNT
from dual
UNION
select 'VV Instruction', 
/*select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by P_VAL_IDSEQ))

*/
(select count(*) from(
 select min(i.qc_id) qc_id,min(i.version) version ,i.P_VAL_IDSEQ from sbrext.quest_contents_ext i,sbrext.quest_contents_ext v
where i.qtl_name = 'VALUE_INSTR'and i.preferred_definition !=' ' and nvl(i.deleted_ind,'No') ='No' 
and v.QC_IDSEQ=i.P_VAL_IDSEQ group by i.P_VAL_IDSEQ))--55311
 caDSR_CNT
from dual
UNION
select 'CS CSI', 
(select count(*) from sbr.cs_csi r,SBR.CLASSIFICATION_SCHEMES cl,SBR.CS_ITEMS csi
where r.cs_idseq=cl.CS_IDSEQ
and r.csi_idseq=csi.csi_idseq
and csi.ASL_NAME not like'%RETIRED ARCHIVED%') cnt 
from dual
UNION
select 'CS CSI DE Relationship', 
(select count(*) from sbr.ac_csi ) caDSR_CNT
from dual
UNION
select 'COMPLEX DE Relationship', 
(select count(*) from sbr.complex_de_relationships) caDSR_CNT
from dual
UNION
select 'Program Area', 
(select count(*) from sbr.PROGRAM_AREAS_LOV ) caDSR_CNT
from dual
UNION
select 'Designation Type', 

(select count(*) from sbr.DESIGNATION_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Address Type', 
(select count(*) from sbr.ADDR_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Communication Type', 
(select count(*) from sbr.COMM_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Status-Admin Type Relationship', 
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT
from dual
UNION
select 'Document Type', 
(select count(*) from sbr.document_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Classification Scheme Type', 
(select count(*) from sbr.CS_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'CSI Type', 
(select count(*) from sbr.CSI_TYPES_LOV ) caDSR_CNT
from dual
UNION
select 'Definition Type', 
(select count(*) from sbrext.definition_types_lov_ext) caDSR_CNT
from dual
UNION
select 'Origin', 
(select count(*) from sbrext.sources_ext) caDSR_CNT
from dual
UNION
select 'Protocol Type', 
(select count(*) from (select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null and nvl(deleted_ind,'No') ='No') ) caDSR_CNT
from dual
UNION
select 'Form Category', 
(select count(*) from sbrext.QC_DISPLAY_LOV_EXT) caDSR_CNT
from dual;