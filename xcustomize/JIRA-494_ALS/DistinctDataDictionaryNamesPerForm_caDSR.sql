select md.DN_CRF_IDSEQ, VD.VD_ID,vd.version ,VV_NAME,min(qc.qc_id) qc_id, min(qc.VERSION)QC_VER
from quest_contents_ext vv , quest_contents_ext qc, quest_contents_ext md,
sbr.data_elements de, sbr.value_domains vd,

(select P_QST_IDSEQ, DN_CRF_IDSEQ,
       listagg(long_name, '||') within group (order  by display_ORDER) VV_NAME
from  quest_contents_ext
where   QTL_NAME='VALID_VALUE'
and DN_CRF_IDSEQ in--('97467C90-ECEE-262A-E053-F662850A018B',
('9F7F98FC-C590-3211-E053-F662850A1ECB') 

group  by P_QST_IDSEQ, DN_CRF_IDSEQ
)IND
where de.vd_idseq=vd.vd_idseq
and md.qc_idseq=qc.P_mod_idseq
and qc.de_idseq=de.de_idseq
and vv.P_QST_IDSEQ = qc.QC_IDSEQ
and IND.P_QST_IDSEQ =qc.P_QST_IDSEQ

and md.DN_CRF_IDSEQ  in--('97467C90-ECEE-262A-E053-F662850A018B',
('9F7F98FC-C590-3211-E053-F662850A1ECB') 
and qc.QTL_NAME='QUESTION'
and vv.QTL_NAME='VALID_VALUE'
and md.QTL_NAME='MODULE'
group by md.DN_CRF_IDSEQ, VD.VD_ID,vd.version ,VV_NAME
--and vd.VD_ID=2598190
--and VD.VD_ID=2598190--5676955
--and vd.VERSION=1

order by VD.VD_ID,vd.version ,VV_NAME;