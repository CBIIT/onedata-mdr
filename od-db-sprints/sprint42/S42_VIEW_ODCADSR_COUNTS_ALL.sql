CREATE OR REPLACE FORCE VIEW ONEDATA_WA.ODCADSR_COUNTS_ALL
(TABLE_NAME, WA_CNT, DIFF_CNT, CADSR_CNT)
BEQUEATH DEFINER
AS 
select 'DE' Table_Name, 
(select count(*) from onedata_wa.de where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_Wa.de  where nvl(fld_delete,0)=0)-(select count(*) from sbr.data_elements where nvl(deleted_ind,'No') ='No') ) DIFF_CNT,
(select count(*) from sbr.data_elements where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'DE Concept', 
(select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0)=0)- (select count(*) from sbr.data_element_concepts  where nvl(deleted_ind,'No') ='No'))DIFF_CNT,
(select count(*) from sbr.data_element_concepts  where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Format', 
(select count(*) from onedata_wa.fmt) WA_CNT,
((select count(*) from onedata_wa.fmt)-(select count(*) from sbr.formats_lov)) DIFF_CNT,
(select count(*) from sbr.formats_lov) caDSR_CNT
from dual
UNION
select 'Data type', 
(select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1) WA_CNT,
((select count(*) from onedata_wa.data_typ where nci_dttype_typ_id = 1)- (select count(*) from sbr.datatypes_lov))DIFF_CNT,
(select count(*) from sbr.datatypes_lov) caDSR_CNT
from dual
UNION
select 'Registration Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1 and FLD_DELETE=0) WA_CNT,
((select count(*) from onedata_wa.stus_mstr where stus_typ_id = 1 and FLD_DELETE=0)-(select count(*) from sbr.reg_status_lov)) DIFF_CNT,
(select count(*) from sbr.reg_status_lov) caDSR_CNT
from dual
UNION
select 'Workflow Status', 
(select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2 and FLD_DELETE=0) WA_CNT,
((select count(*) from onedata_wa.stus_mstr where stus_typ_id = 2 and FLD_DELETE=0)-(select count(*) from sbr.ac_status_lov)) DIFF_CNT,
(select count(*) from sbr.ac_status_lov) caDSR_CNT
from dual
UNION
select 'UOM', 
(select count(*) from onedata_wa.UOM) WA_CNT,
((select count(*) from onedata_wa.UOM)-(select count(*) from sbr.unit_of_measures_lov)) DIFF_CNT,
(select count(*) from sbr.unit_of_measures_lov) caDSR_CNT
from dual
UNION
select 'Conceptual Domain', 
(select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0)=0)-(select count(*) from sbr.conceptual_domains  where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.conceptual_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Object Class', 
(select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.object_classes_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.object_classes_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Property', 
(select count(*) from onedata_wa.prop  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.prop where nvl(fld_delete,0)=0)-(select count(*) from sbrext.properties_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.properties_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Value Domain', 
(select count(*) from onedata_wa.value_dom where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.value_dom where nvl(fld_delete,0)=0)-(select count(*) from sbr.value_domains where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.value_domains where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Concept', 
(select count(*) from onedata_wa.CNCPT where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CNCPT  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.concepts_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.concepts_ext  where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'CSI', 
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where nvl(fld_delete,0)=0)-(select count(*) from sbr.cs_items where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.cs_items where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Classification Scheme', 
(select count(*) from onedata_wa.CLSFCTN_SCHM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CLSFCTN_SCHM  where nvl(fld_delete,0)=0)-(select count(*) from sbr.classification_schemes where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.classification_schemes where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Representation Class', 
(select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0)=0)-(select count(*) from sbrext.representations_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.representations_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Value Meaning', 
(select count(*) from onedata_wa.NCI_VAL_MEAN where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_VAL_MEAN  where nvl(fld_delete,0)=0)-(select count(*) from sbr.value_meanings where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbr.value_meanings where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Protocol', 
(select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.protocols_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.protocols_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'OC Recs', 
(select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0)=0)-(select count(*) from sbrext.oc_recs_ext where nvl(deleted_ind,'No') ='No')) DIFF_CNT,
(select count(*) from sbrext.oc_recs_ext where nvl(deleted_ind,'No') ='No') caDSR_CNT
from dual
UNION
select 'Context', 
(select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0)=0)-(select count(*) from sbr.contexts )) DIFF_CNT,
(select count(*) from sbr.contexts ) caDSR_CNT
from dual
UNION
select 'CD-VM', 
(select count(*) from onedata_wa.conc_dom_val_mean where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.conc_dom_val_mean )-(select count(*) from sbr.cd_vms )) DIFF_CNT,
(select count(*) from sbr.cd_vms ) caDSR_CNT
from dual
UNION
select 'PV', 
(select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0)=0)-
(select count(*) from sbr.vd_pvs )) DIFF_CNT,
(select count(*) from sbr.vd_pvs) caDSR_CNT
from dual
UNION
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
         and ai.condr_idseq= cc.CONDR_IDSEQ) caDSR_CNT 
from dual
UNION
select 'Designations', 
(select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0)=0)-(select count(*) from sbr.designations )) DIFF_CNT,
(select count(*) from sbr.designations ) caDSR_CNT
from dual
UNION
select 'Definitions', 
(select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0)=0)-
(select count(*) from sbr.definitions )) DIFF_CNT,
(select count(*) from sbr.definitions ) caDSR_CNT
from dual
UNION
select 'Reference Documents', 
(select count(*) from onedata_wa.REF where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.REF where nvl(fld_delete,0)=0)-(select count(*) from sbr.reference_documents )) DIFF_CNT,
(select count(*) from sbr.reference_documents ) caDSR_CNT
from dual
UNION
select 'Trigger Actions', 
(select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0)=0)-(select count(*) from sbrext.triggered_actions_ext 
)) DIFF_CNT,
(select count(*) from sbrext.triggered_actions_ext ) caDSR_CNT
from dual
UNION
select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0)=0)-(select count(*) from sbrext.ta_proto_csi_ext )) DIFF_CNT,
(select count(*) from sbrext.ta_proto_csi_ext ) caDSR_CNT
from dual
UNION
select 'Organization', 
(select count(*) from onedata_wa.NCI_ORG where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ORG where nvl(fld_delete,0)=0)-(select count(*) from sbr.ORGANIZATIONS )) DIFF_CNT,
(select count(*) from sbr.ORGANIZATIONS ) caDSR_CNT
from dual
UNION
select 'Person', 
(select count(*) from onedata_wa.NCI_PRSN where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_PRSN where nvl(fld_delete,0)=0)-
(select count(*) from sbr.persons )) DIFF_CNT,
(select count(*) from sbr.persons ) caDSR_CNT
from dual
UNION
select 'Addresses', 
(select count(*) from onedata_wa.NCI_ENTTY_ADDR  where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_ADDR  where nvl(fld_delete,0)=0)-(select count(*) from sbr.contact_addresses)) DIFF_CNT,
(select count(*) from sbr.contact_addresses ) caDSR_CNT
from dual
UNION
select 'Communications', 
(select count(*) from onedata_wa.NCI_ENTTY_COMM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ENTTY_COMM where nvl(fld_delete,0)=0)-(select count(*) from sbr.contact_comms ) )DIFF_CNT,
(select count(*) from sbr.contact_comms ) caDSR_CNT
from dual
UNION
select 'Form', 
(select count(*) from onedata_wa.NCI_FORM where nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where nvl(fld_delete,0)=0)-
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE') ) caDSR_CNT
from dual
UNION
--select 'Module', 
--(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and nvl(fld_delete,0)=0 and NVL(P_ITEM_ID,0)>0) WA_CNT,
--((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where REL_TYP_ID=61 and nvl(fld_delete,0)=0 and NVL(P_ITEM_ID,0)>0)-(select count(*) from sbrext.quest_contents_ext 
--where qtl_name = 'MODULE' and nvl(deleted_ind,'No') ='No' and DN_CRF_IDSEQ is not null)) DIFF_CNT,
--(select count(*) from sbrext.quest_contents_ext m where qtl_name = 'MODULE' and nvl(deleted_ind,'No') ='No'
--and m.DN_CRF_IDSEQ is not null) caDSR_CNT
--from dual
--UNION
--select 'Question', 
--(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0)=0) WA_CNT,
--((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0)=0)-(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No'and P_MOD_IDSEQ is not null)) DIFF_CNT,
--(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No' and P_MOD_IDSEQ is not null) caDSR_CNT
--from dual
--UNION
--select 'Question VV', 
--(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0)=0) WA_CNT,
--((select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0)=0)-
--(select count(*) from sbrext.quest_contents_ext vv ,sbrext.quest_contents_ext q ,sbrext.quest_contents_ext m
--where vv.P_QST_IDSEQ =q.QC_IDSEQ and m.QC_IDSEQ=q.P_MOD_IDSEQ
--and q.qtl_name = 'QUESTION' and nvl(q.deleted_ind,'No') ='No' and  nvl(m.deleted_ind,'No') ='No'
--and vv.qtl_name = 'VALID_VALUE' and nvl(vv.deleted_ind,'No') ='No' )) DIFF_CNT,
--(select count(*) from sbrext.quest_contents_ext vv ,sbrext.quest_contents_ext q ,sbrext.quest_contents_ext m
--where vv.P_QST_IDSEQ =q.QC_IDSEQ and m.QC_IDSEQ=q.P_MOD_IDSEQ
--and q.qtl_name = 'QUESTION' and nvl(q.deleted_ind,'No') ='No' and  nvl(m.deleted_ind,'No') ='No'
--and vv.qtl_name = 'VALID_VALUE' and nvl(vv.deleted_ind,'No') ='No' ) caDSR_CNT
--from dual
SELECT 'Module',
(SELECT COUNT(*) FROM ONEDATA_WA.ADMIN_ITEM AI, ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR
AND ADMIN_ITEM_TYP_ID = 52 AND  NVL(AI.FLD_DELETE,0) = 0 AND AI.ITEM_ID = R.C_ITEM_ID
AND NVL(R.FLD_DELETE,0) = 0 AND AI.VER_NR = R.C_ITEM_VER_NR
AND R.REL_TYP_ID = 61 ) WA_CNT,
((SELECT COUNT(*) FROM ONEDATA_WA.ADMIN_ITEM AI, ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR
AND ADMIN_ITEM_TYP_ID = 52 AND  NVL(AI.FLD_DELETE,0) = 0 AND AI.ITEM_ID = R.C_ITEM_ID
AND NVL(R.FLD_DELETE,0) = 0 AND AI.VER_NR = R.C_ITEM_VER_NR
AND R.REL_TYP_ID = 61  )-
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT m,SBREXT.QUEST_CONTENTS_EXT f
WHERE m.QTL_NAME = 'MODULE' AND NVL(m.DELETED_IND,'No' )='No' AND NVL(f.DELETED_IND,'No' )='No' AND m.DN_CRF_IDSEQ =f.QC_IDSEQ )) DIFF_CNT,
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT m,SBREXT.QUEST_CONTENTS_EXT f
WHERE m.QTL_NAME = 'MODULE' AND NVL(m.DELETED_IND,'No' )='No' AND NVL(f.DELETED_IND,'No' )='No' AND m.DN_CRF_IDSEQ =f.QC_IDSEQ ) CADSR_CNT
FROM DUAL
UNION
SELECT 'Question',
(SELECT COUNT(*) FROM ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR) WA_CNT,
((SELECT COUNT(*) FROM ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR)-
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,
SBREXT.QUEST_CONTENTS_EXT F WHERE Q.QTL_NAME = 'QUESTION'
AND NVL(Q.DELETED_IND,'No') ='No'AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ)) DIFF_CNT,
(SELECT COUNT(*) FROM  SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,
SBREXT.QUEST_CONTENTS_EXT F WHERE Q.QTL_NAME = 'QUESTION'
AND NVL(Q.DELETED_IND,'No') ='No'AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ) CADSR_CNT
FROM DUAL
UNION
SELECT 'Question VV',
(SELECT COUNT(*) FROM ONEDATA_WA.NCI_QUEST_VALID_VALUE V ,ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND R.REL_TYP_ID = 61
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND V.Q_PUB_ID=A.NCI_PUB_ID
AND V.Q_VER_NR=A.NCI_VER_NR
AND NVL(V.FLD_DELETE,0)=0) WA_CNT,
((SELECT COUNT(*) FROM ONEDATA_WA.NCI_QUEST_VALID_VALUE V ,ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR 
AND R.REL_TYP_ID = 61
AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND V.Q_PUB_ID=A.NCI_PUB_ID
AND V.Q_VER_NR=A.NCI_VER_NR
AND NVL(V.FLD_DELETE,0)=0)-
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT VV ,SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,SBREXT.QUEST_CONTENTS_EXT F
WHERE VV.P_QST_IDSEQ =Q.QC_IDSEQ AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ  AND Q.QTL_NAME = 'QUESTION' AND NVL(Q.DELETED_IND,'No') ='No'
AND VV.QTL_NAME = 'VALID_VALUE' AND NVL(VV.DELETED_IND,'No') ='No' )) DIFF_CNT,
(SELECT COUNT(*) FROM SBREXT.QUEST_CONTENTS_EXT VV ,SBREXT.QUEST_CONTENTS_EXT Q ,
SBREXT.QUEST_CONTENTS_EXT M,SBREXT.QUEST_CONTENTS_EXT F
WHERE VV.P_QST_IDSEQ =Q.QC_IDSEQ AND Q.P_MOD_IDSEQ =M.QC_IDSEQ
AND M.DN_CRF_IDSEQ=F.QC_IDSEQ  AND Q.QTL_NAME = 'QUESTION' AND NVL(Q.DELETED_IND,'No') ='No'
AND VV.QTL_NAME = 'VALID_VALUE' AND NVL(VV.DELETED_IND,'No') ='No'  ) CADSR_CNT
FROM DUAL
UNION
select 'From HDR Instruction', 
(select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null  and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT
from dual
UNION
select 'From FOOTER Instruction', 
(select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL  and nvl(fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL and nvl(fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by dn_crf_idseq))
 caDSR_CNT
from dual
UNION
select 'Module Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID AND f.VER_NR=R.P_ITEM_VER_NR  AND R.REL_TYP_ID=61 and R.INSTR is not null and nvl(R.fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID AND f.VER_NR=R.P_ITEM_VER_NR AND R.REL_TYP_ID=61 and R.INSTR is not null  and nvl(R.fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_mod_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_mod_idseq))
 caDSR_CNT
from dual
UNION
select 'Question Instruction', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY A,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND R.REL_TYP_ID = 61
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND A.REL_TYP_ID=63 and A.INSTR is not null  and nvl(A.fld_delete,0)=0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY A,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND R.REL_TYP_ID = 61
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND A.REL_TYP_ID=63 and A.INSTR is not null  and nvl(A.fld_delete,0)=0)-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' group by p_qst_idseq))
 caDSR_CNT
from dual
UNION
select 'VV Instruction', 
(select count(*) from ONEDATA_WA.NCI_QUEST_VALID_VALUE V ,ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND R.REL_TYP_ID = 61
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND V.Q_PUB_ID=A.NCI_PUB_ID
AND V.Q_VER_NR=A.NCI_VER_NR
AND NVL(V.FLD_DELETE,0)=0 AND V.INSTR is not NULL) WA_CNT,
((select count(*) from ONEDATA_WA.NCI_QUEST_VALID_VALUE V ,ONEDATA_WA.NCI_ADMIN_ITEM_REL_ALT_KEY A ,ONEDATA_WA.NCI_ADMIN_ITEM_REL R,ONEDATA_WA.NCI_FORM f
WHERE  F.ITEM_ID=R.P_ITEM_ID 
AND f.VER_NR=R.P_ITEM_VER_NR AND A.REL_TYP_ID = 63 AND NVL(A.FLD_DELETE,0)=0
AND NVL(R.FLD_DELETE,0)=0 AND A.P_ITEM_ID=R.C_ITEM_ID
AND R.REL_TYP_ID = 61
AND A.P_ITEM_VER_NR= R.C_ITEM_VER_NR
AND V.Q_PUB_ID=A.NCI_PUB_ID
AND V.Q_VER_NR=A.NCI_VER_NR
AND NVL(V.FLD_DELETE,0)=0 AND V.INSTR is not NULL))-
(select count(*) from(
 select min(i.qc_id) qc_id,min(i.version) version ,i.P_VAL_IDSEQ from sbrext.quest_contents_ext i,sbrext.quest_contents_ext v
where i.qtl_name = 'VALUE_INSTR'and i.preferred_definition !=' ' and nvl(i.deleted_ind,'No') ='No' 
and v.QC_IDSEQ=i.P_VAL_IDSEQ group by i.P_VAL_IDSEQ)) DIFF_CNT,
(select count(*) from(
 select min(i.qc_id) qc_id,min(i.version) version ,i.P_VAL_IDSEQ from sbrext.quest_contents_ext i,sbrext.quest_contents_ext v
where i.qtl_name = 'VALUE_INSTR'and i.preferred_definition !=' ' and nvl(i.deleted_ind,'No') ='No' 
and v.QC_IDSEQ=i.P_VAL_IDSEQ group by i.P_VAL_IDSEQ))
 caDSR_CNT
from dual
UNION
select 'CS CSI', 
(select count(*)
from onedata_wa.NCI_CLSFCTN_SCHM_ITEM r, onedata_wa.ADMIN_ITEM A, onedata_wa.admin_item csi
where CS_ITEM_ID=a.item_id and r.CS_ITEM_VER_NR=a.ver_nr
and CS_ITEM_ID is not null 
and nvl(r.fld_delete,0) = 0
and csi.item_id=r.ITEM_ID
and csi.VER_NR = r.VER_NR
and csi.ADMIN_STUS_NM_DN not like'%RETIRED ARCHIVED%' )  WA_CNT,
((select count(*)
from onedata_wa.NCI_CLSFCTN_SCHM_ITEM r, onedata_wa.ADMIN_ITEM A, onedata_wa.admin_item csi
where CS_ITEM_ID=a.item_id and r.CS_ITEM_VER_NR=a.ver_nr
and CS_ITEM_ID is not null 
and nvl(r.fld_delete,0) = 0
and csi.item_id=r.ITEM_ID
and csi.VER_NR = r.VER_NR
and csi.ADMIN_STUS_NM_DN not like'%RETIRED ARCHIVED%')-
(select count(*) from sbr.cs_csi r,SBR.CLASSIFICATION_SCHEMES cl,SBR.CS_ITEMS csi
where r.cs_idseq=cl.CS_IDSEQ
and r.csi_idseq=csi.csi_idseq
and csi.ASL_NAME not like'%RETIRED ARCHIVED%' ) ) DIFF_CNT,
(select count(*) from sbr.cs_csi r,SBR.CLASSIFICATION_SCHEMES cl,SBR.CS_ITEMS csi
where r.cs_idseq=cl.CS_IDSEQ
and r.csi_idseq=csi.csi_idseq
and csi.ASL_NAME not like'%RETIRED ARCHIVED%' ) caDSR_CNT
from dual
UNION
select 'COMPLEX DE Relationship', 
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0)- 
(select count(*) from sbr.complex_de_relationships)) DIFF_CNT,
(select count(*) from sbr.complex_de_relationships) caDSR_CNT
from dual
UNION
select 'Program Area', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 14 )-
(select count(*) from sbr.PROGRAM_AREAS_LOV )) DIFF_CNT,
(select count(*) from sbr.PROGRAM_AREAS_LOV ) caDSR_CNT
from dual
UNION
select 'Designation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 11 )-(select count(*) from sbr.DESIGNATION_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.DESIGNATION_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Address Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 25 )-(select count(*) from sbr.ADDR_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.ADDR_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Communication Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 26 )-(select count(*) from sbr.COMM_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.COMM_TYPES_LOV) caDSR_CNT
from dual
--UNION
--select 'Status-Admin Type Relationship', 
--(select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS ) WA_CNT,
--((select count(*) from onedata_wa.NCI_AI_TYP_VALID_STUS)-
--(select count(*) from sbrext.ASL_ACTL_EXT)) DIFF_CNT,
--(select count(*) from sbrext.ASL_ACTL_EXT)caDSR_CNT
--from dual
UNION
select 'Derivation Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 21 )-(select count(*) from sbr.complex_rep_type_lov)) DIFF_CNT,
(select count(*) from sbr.complex_rep_type_lov) caDSR_CNT
from dual
UNION
select 'Document Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 1)-(select count(*) from sbr.document_TYPES_LOV) ) DIFF_CNT,
(select count(*) from sbr.document_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'Classification Scheme Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 3 )-(select count(*) from sbr.CS_TYPES_LOV)) DIFF_CNT,
(select count(*) from sbr.CS_TYPES_LOV) caDSR_CNT
from dual
UNION
select 'CSI Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 20 )-(select count(*) from sbr.CSI_TYPES_LOV )) DIFF_CNT,
(select count(*) from sbr.CSI_TYPES_LOV ) caDSR_CNT
from dual
UNION
select 'Definition Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 15 )-(select count(*) from sbrext.definition_types_lov_ext)) DIFF_CNT,
(select count(*) from sbrext.definition_types_lov_ext) caDSR_CNT
from dual
UNION
select 'Origin', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 18 )-(select count(*) from sbrext.sources_ext)) DIFF_CNT,
(select count(*) from sbrext.sources_ext) caDSR_CNT
from dual
UNION
select 'Protocol Type', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 19) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 19 )-(select count(*) from (select distinct 19, TYPE, TYPE 
from sbrext.protocols_ext where type is not null and nvl(deleted_ind,'No') ='No'))) DIFF_CNT,
(select count(*) from (select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null and nvl(deleted_ind,'No') ='No') ) caDSR_CNT
from dual
UNION
select 'Form Category', 
(select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 22) WA_CNT,
((select count(*) from onedata_wa.OBJ_KEY where obj_typ_id = 22 )-(select count(*) from sbrext.QC_DISPLAY_LOV_EXT)) DIFF_CNT,
(select count(*) from sbrext.QC_DISPLAY_LOV_EXT) caDSR_CNT
from dual;
