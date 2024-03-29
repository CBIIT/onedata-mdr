-- Monthly Orphan and Released CDE with retired and draft AI Metric Queries
-- Orphan DEC
--
select * from ONEDATA_WA.data_element_concepts_view 
where dec_idseq not in (select distinct dec_idseq from ONEDATA_WA.data_elements_view)
;
-- Orphan VD
--
select * from ONEDATA_WA.value_domains_view 
where vd_idseq not in (select distinct vd_idseq from ONEDATA_WA.data_elements_view)
;

--
-- Released CDE with Retired VD
--
SELECT de.CONTEXTS_NAME,DE.REGISTRATION_STATUS,DE.CDE_ID ,DE.VERSION DE_VERSION,
DE.PREFERRED_NAME DE_PREFERRED_NAME,DE.LONG_NAME DE_LONG_NAME,
DE.ASL_NAME DE_ASL_NAME,DE.BEGIN_DATE DE_BEGIN_DATE,DE.END_DATE DE_END_DATE,
DE.CHANGE_NOTE DE_CHANGE_NOTE,DE.DATE_CREATED DE_DATE_CREATED, DE.CREATED_BY DE_CREATED_BY,
DE.DATE_MODIFIED DE_DATE_MODIFIED, DE.MODIFIED_BY DE_MODIFIED_BY,
VD.VD_ID,VD.VERSION VD_VERSION,VD.LONG_NAME VD_LONG_NAME,VD.PREFERRED_NAME VD_PREFERRED_NAME,
VD.ASL_NAME VD_ASL_NAME,VD.BEGIN_DATE VD_BEGIN_DATE,VD.END_DATE VD_END_DATE,VD.CHANGE_NOTE VD_CHANGE_NOTE,
VD.LATEST_VERSION_IND VD_LATEST_VERSION_IND,VD.DATE_CREATED VD_DATE_CREATED,VD.CREATED_BY VD_CREATED_BY,
VD.DATE_MODIFIED VD_DATE_MODIFIED, VD.MODIFIED_BY VD_MODIFIED_BY
FROM ONEDATA_WA.VALUE_DOMAINS_VIEW VD ,onedata_WA.DATA_ELEMENTS_VIEW DE
WHERE DE.VD_IDSEQ=VD.VD_IDSEQ
AND DE.ASL_NAME='RELEASED' 
AND UPPER(VD.ASL_NAME) like 'RETIRED%'
ORDER BY de.CONTEXTS_NAME,DE.LONG_NAME;
--
-- Released CDE with Draft VD
--
SELECT de.CONTEXTS_NAME,DE.REGISTRATION_STATUS,DE.CDE_ID ,DE.VERSION DE_VERSION,
DE.PREFERRED_NAME DE_PREFERRED_NAME,DE.LONG_NAME DE_LONG_NAME,
DE.ASL_NAME DE_ASL_NAME,DE.BEGIN_DATE DE_BEGIN_DATE,DE.END_DATE DE_END_DATE,
DE.CHANGE_NOTE DE_CHANGE_NOTE,DE.DATE_CREATED DE_DATE_CREATED, DE.CREATED_BY DE_CREATED_BY,
DE.DATE_MODIFIED DE_DATE_MODIFIED, DE.MODIFIED_BY DE_MODIFIED_BY,
VD.VD_ID,VD.VERSION VD_VERSION,VD.LONG_NAME VD_LONG_NAME,VD.PREFERRED_NAME VD_PREFERRED_NAME,
VD.ASL_NAME VD_ASL_NAME,VD.BEGIN_DATE VD_BEGIN_DATE,VD.END_DATE VD_END_DATE,VD.CHANGE_NOTE VD_CHANGE_NOTE,
VD.LATEST_VERSION_IND VD_LATEST_VERSION_IND,VD.DATE_CREATED VD_DATE_CREATED,VD.CREATED_BY VD_CREATED_BY,
VD.DATE_MODIFIED VD_DATE_MODIFIED, VD.MODIFIED_BY VD_MODIFIED_BY
FROM ONEDATA_WA.VALUE_DOMAINS_VIEW VD ,onedata_WA.DATA_ELEMENTS_VIEW DE
WHERE DE.VD_IDSEQ=VD.VD_IDSEQ
AND DE.ASL_NAME='RELEASED' 
AND UPPER(VD.ASL_NAME) like 'DRAFT%'
ORDER BY de.CONTEXTS_NAME,DE.LONG_NAME;

--
-- Released CDE with Retired DEC
--
SELECT DE.CONTEXTS_NAME,DE.REGISTRATION_STATUS,DE.CDE_ID ,DE.VERSION DE_VERSION,
DE.PREFERRED_NAME DE_PREFERRED_NAME,DE.LONG_NAME DE_LONG_NAME,
DE.ASL_NAME DE_ASL_NAME,DE.BEGIN_DATE DE_BEGIN_DATE,DE.END_DATE DE_END_DATE,
DE.CHANGE_NOTE DE_CHANGE_NOTE,DE.DATE_CREATED DE_DATE_CREATED, DE.CREATED_BY DE_CREATED_BY,
DE.DATE_MODIFIED DE_DATE_MODIFIED,DE.MODIFIED_BY DE_MODIFIED_BY,DC.DEC_ID,DC.version DEC_VERSION,
DC.LONG_NAME DEC_LONG_NAME,DC.PREFERRED_NAME DEC_PREFERRED_NAME,DC.ASL_NAME DEC_ASL_NAME,
DC.BEGIN_DATE DEC_BEGIN_DATE,DC.END_DATE DEC_END_DATE,DC.CHANGE_NOTE DEC_CHANGE_NOTE,
DC.LATEST_VERSION_IND DEC_LATEST_VERSION_IND,DC.DATE_CREATED DEC_DATE_CREATED,DC.CREATED_BY DEC_CREATED_BY,
DC.DATE_MODIFIED DEC_DATE_MODIFIED, DC.MODIFIED_BY DEC_MODIFIED_BY
FROM ONEDATA_WA.DATA_ELEMENT_CONCEPTS_VIEW DC ,onedata_WA.DATA_ELEMENTS_VIEW DE
WHERE  DE.DEC_IDSEQ=DC.DEC_IDSEQ
AND DE.ASL_NAME='RELEASED' 
AND UPPER(DC.ASL_NAME) like 'RETIRED%'
ORDER BY de.CONTEXTS_NAME,DE.LONG_NAME;
--
-- Released CDE with Retired DEC
--
SELECT de.CONTEXTS_NAME,DE.REGISTRATION_STATUS,DE.CDE_ID ,DE.VERSION DE_VERSION,
DE.PREFERRED_NAME DE_PREFERRED_NAME,DE.LONG_NAME DE_LONG_NAME,
DE.ASL_NAME DE_ASL_NAME,DE.BEGIN_DATE DE_BEGIN_DATE,DE.END_DATE DE_END_DATE,
DE.CHANGE_NOTE DE_CHANGE_NOTE,DE.DATE_CREATED DE_DATE_CREATED, DE.CREATED_BY DE_CREATED_BY,
DE.DATE_MODIFIED DE_DATE_MODIFIED,DE.MODIFIED_BY DE_MODIFIED_BY,DC.DEC_ID,DC.version DEC_VERSION,
DC.LONG_NAME DEC_LONG_NAME,DC.PREFERRED_NAME DEC_PREFERRED_NAME,DC.ASL_NAME DEC_ASL_NAME,
DC.BEGIN_DATE DEC_BEGIN_DATE,DC.END_DATE DEC_END_DATE,DC.CHANGE_NOTE DEC_CHANGE_NOTE,
DC.LATEST_VERSION_IND DEC_LATEST_VERSION_IND,DC.DATE_CREATED DEC_DATE_CREATED,DC.CREATED_BY DEC_CREATED_BY,
DC.DATE_MODIFIED DEC_DATE_MODIFIED, DC.MODIFIED_BY DEC_MODIFIED_BY
FROM ONEDATA_WA.DATA_ELEMENT_CONCEPTS_VIEW DC,onedata_WA.DATA_ELEMENTS_VIEW DE
WHERE DE.DEC_IDSEQ=DC.DEC_IDSEQ
AND DE.ASL_NAME='RELEASED' 
AND UPPER(DC.ASL_NAME) like 'DRAFT%'
ORDER BY de.CONTEXTS_NAME,DE.LONG_NAME;

-- List of Contexts
SELECT CONTEXTS_VIEW.CONTE_IDSEQ, CONTEXTS_VIEW.NAME,  CONTEXTS_VIEW.PAL_NAME, CONTEXTS_VIEW.DESCRIPTION, CONTEXTS_VIEW.LANGUAGE, CONTEXTS_VIEW.CREATED_BY, CONTEXTS_VIEW.DATE_CREATED, CONTEXTS_VIEW.MODIFIED_BY, CONTEXTS_VIEW.DATE_MODIFIED, SUM(CONTEXTS_VIEW.VERSION)
FROM ONEDATA_WA.CONTEXTS_VIEW
GROUP BY CONTEXTS_VIEW.CONTE_IDSEQ, CONTEXTS_VIEW.NAME, CONTEXTS_VIEW.PAL_NAME, CONTEXTS_VIEW.DESCRIPTION, CONTEXTS_VIEW.LANGUAGE, CONTEXTS_VIEW.CREATED_BY, CONTEXTS_VIEW.DATE_CREATED, CONTEXTS_VIEW.MODIFIED_BY, CONTEXTS_VIEW.DATE_MODIFIED
;