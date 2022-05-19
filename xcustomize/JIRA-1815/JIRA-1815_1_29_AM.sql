select 'DE', 
(select count(*) from onedata_ra.de where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.de where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_Wa.de  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.data_elements where nvl(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) ) DIFF_CNT,
(select count(*) from sbr.data_elements where nvl(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'DE Concept', 
(select count(*) from onedata_ra.de_conc  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.de_conc  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))- (select count(*) from sbr.data_element_concepts  where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')))DIFF_CNT,
(select count(*) from sbr.data_element_concepts  where NVL(deleted_ind,'No' )='No'and 
to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Conceptual Domain', 
(select count(*) from onedata_ra.conc_dom  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.conc_dom  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.conceptual_domains  where NVL(deleted_ind,'No' )='No'
 and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
 and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.conceptual_domains where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and 
to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Object Class', 
(select count(*) from onedata_ra.obj_cls  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.obj_cls  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbrext.object_classes_ext where NVL(deleted_ind,'No' )='No' 
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.object_classes_ext where NVL(deleted_ind,'No' )='No' 
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Property', 
(select count(*) from onedata_ra.prop  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.prop  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.prop where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.properties_ext where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.properties_ext where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Value Domain', 
(select count(*) from onedata_ra.value_dom where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.value_dom where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.value_dom where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.value_domains where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.value_domains where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Concept', 
(select count(*) from onedata_ra.CNCPT where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))RA_CNT,
(select count(*) from onedata_wa.CNCPT where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.CNCPT  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.concepts_ext where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.concepts_ext  where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'CSI', 
(select count(*) from onedata_ra.NCI_CLSFCTN_SCHM_ITEM  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbr.cs_items where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.cs_items where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Classification Scheme',
(select count(*) from onedata_ra.CLSFCTN_SCHM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT, 
(select count(*) from onedata_wa.CLSFCTN_SCHM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.CLSFCTN_SCHM  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.classification_schemes where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.classification_schemes where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Representation Class', 
(select count(*) from onedata_ra.REP_CLS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.REP_CLS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.representations_ext where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.representations_ext where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Value Meaning', 
(select count(*) from onedata_ra.NCI_VAL_MEAN where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_VAL_MEAN where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_VAL_MEAN  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.value_meanings where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.value_meanings where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Protocol', 
(select count(*) from onedata_ra.NCI_PROTCL  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_PROTCL  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.protocols_ext where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.protocols_ext where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'OC Recs', 
(select count(*) from onedata_ra.NCI_OC_RECS  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_OC_RECS  where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.oc_recs_ext where NVL(deleted_ind,'No' )='No'
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.oc_recs_ext where NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Context', 
(select count(*) from onedata_ra.CNTXT where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.CNTXT where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.contexts
 where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
 and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.contexts ) caDSR_CNT,NULL
from dual
UNION

select 'CD-VM', 
(select count(*) from onedata_ra.conc_dom_val_mean where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.conc_dom_val_mean where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.conc_dom_val_mean )-(select count(*) from sbr.cd_vms  
where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.cd_vms 
 where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
 and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'PV', 
(select count(*) from onedata_ra.PERM_VAL where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.PERM_VAL where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbr.vd_pvs  where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.vd_pvs where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Concept - AI',  
(select count(*) from onedata_ra.CNCPT_ADMIN_ITEM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))  RA_CNT,
(select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))  WA_CNT,
((select count(*) from onedata_wa.CNCPT_ADMIN_ITEM where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) -
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.COMPONENT_CONCEPTS_EXT where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Designations', 
(select count(*) from onedata_ra.ALT_NMS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.ALT_NMS where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.designations where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.designations where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Definitions', 
(select count(*) from onedata_ra.ALT_DEF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.ALT_DEF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbr.definitions where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.definitions where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Reference Documents', 
(select count(*) from onedata_ra.REF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.REF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.REF where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbr.reference_documents where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbr.reference_documents where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Trigger Actions', 
(select count(*) from onedata_ra.NCI_FORM_TA where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.triggered_actions_ext where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')
)) DIFF_CNT,
(select count(*) from sbrext.triggered_actions_ext where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Trigger Actions Protocol/CSI', 
(select count(*) from onedata_RA.NCI_FORM_TA_REL where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM_TA_REL where nvl(fld_delete,0) = 0 
and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.ta_proto_csi_ext where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') )) DIFF_CNT,
(select count(*) from sbrext.ta_proto_csi_ext where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Form', 
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 54 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 54 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE')and NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name in ( 'CRF','TEMPLATE')and NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual

UNION

select 'Module', 
(select count(*) from onedata_ra.ADMIN_ITEM where admin_item_typ_id = 52 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.ADMIN_ITEM where admin_item_typ_id = 52 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-(select count(*) from sbrext.quest_contents_ext 
where qtl_name = 'MODULE' and NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'MODULE' and NVL(deleted_ind,'No' )='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'Question', 
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY where rel_typ_id = 63 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No'and P_MOD_IDSEQ is not null and 
to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and 
to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'QUESTION' and nvl(deleted_ind,'No') ='No' and P_MOD_IDSEQ is not null and 
to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and 
to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual;
UNION

select 'Question VV',
(select count(*) from onedata_ra.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_QUEST_VALID_VALUE where  nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE' and nvl(deleted_ind,'No') ='No' and P_QST_IDSEQ is not null 
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))) DIFF_CNT,
(select count(*) from sbrext.quest_contents_ext where qtl_name = 'VALID_VALUE' and nvl(deleted_ind,'No') ='No' and P_QST_IDSEQ is not null 
and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'From HDR Instruction', 
(select count(*) from onedata_ra.NCI_FORM where HDR_INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where HDR_INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'FORM_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual
UNION

select 'From FOOTER Instruction', 
(select count(*) from onedata_ra.NCI_FORM where FTR_INSTR is not NULL  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_FORM where FTR_INSTR is not NULL and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No'and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by dn_crf_idseq) f)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,dn_crf_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name like'FOOTER%'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by dn_crf_idseq))
 caDSR_CNT,NULL
from dual
UNION

select 'Module Instruction', 
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL  where REL_TYP_ID=61 and INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by p_mod_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_mod_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'MODULE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by p_mod_idseq))
 caDSR_CNT,NULL
from dual
UNION

select 'Question Instruction', 
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL_ALT_KEY  where REL_TYP_ID=63 and INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY  where REL_TYP_ID=63 and INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL_ALT_KEY
  where REL_TYP_ID=63 and INSTR is not null  and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by p_qst_idseq))) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,p_qst_idseq from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'QUESTION_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by p_qst_idseq))
 caDSR_CNT,NULL
from dual
UNION

select 'VV Instruction', 
(select count(*) from onedata_ra.nci_quest_valid_value where INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.nci_quest_valid_value where INSTR is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')))-
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by P_VAL_IDSEQ)) DIFF_CNT,
(select count(*) from(
select min(qc_id) qc_id,min(version) version ,P_VAL_IDSEQ from sbrext.quest_contents_ext qc1 
where qc1.qtl_name = 'VALUE_INSTR'and preferred_definition !=' ' and nvl(deleted_ind,'No') ='No' and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') group by P_VAL_IDSEQ))
 caDSR_CNT,NULL
from dual
UNION

select 'CS CSI', 
(select count(*) from onedata_ra.NCI_CLSFCTN_SCHM_ITEM where CS_CSI_IDSEQ is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where CS_CSI_IDSEQ is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_CLSFCTN_SCHM_ITEM where CS_CSI_IDSEQ is not null and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') )-(select count(*) from sbr.cs_csi where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) ) DIFF_CNT,
(select count(*) from sbr.cs_csi where  to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual
UNION

select 'CS CSI DE Relationship', 
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL where rel_typ_id = 65 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 65 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')
<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') )- (select count(*) from sbr.ac_csi where to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') )) DIFF_CNT,
(select count(*) from sbr.ac_csi where to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')and to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') ) caDSR_CNT,NULL
from dual
UNION

select 'COMPLEX DE Relationship', 
(select count(*) from onedata_ra.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) RA_CNT,
(select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) WA_CNT,
((select count(*) from onedata_wa.NCI_ADMIN_ITEM_REL where rel_typ_id = 66 and nvl(fld_delete,0) = 0 and to_date(to_char(NVL(LST_UPD_DT ,CREAT_DT),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') and to_date(to_char(CREAT_DT,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM'))- 
(select count(*) from sbr.complex_de_relationships where  to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) ) DIFF_CNT,
(select count(*) from sbr.complex_de_relationships where to_date(to_char(DATE_CREATED,'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM') 
and to_date(to_char(NVL(DATE_MODIFIED,DATE_CREATED),'MM/DD/YYYY HH:MI:SS AM'),'MM/DD/YYYY HH:MI:SS AM')<to_date('5/20/2022 01:29:00 AM','MM/DD/YYYY HH:MI:SS AM')) caDSR_CNT,NULL
from dual;
/

