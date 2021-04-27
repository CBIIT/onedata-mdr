select DD.Form_ID,DD.Form_Version,DD.Form_Long_Name,DD.VD_ID,DD.VD_LONG_NAME,DD.VD_Version,DD.GR_QVV_VALUE,VALUE,VM_DEF, DD.QUESTION_ID, DD.QUESTION_VERSION
FROM
(select Form_ID,Form_Version,Form_Long_Name,VD_ID,VD_LONG_NAME,VD_Version,GR_QVV_VALUE,min(QUESTION_ID ) QUESTION_ID, min(QUESTION_VERSION) QUESTION_VERSION
from(
select Form_ID,Form_Version,Form_Long_Name,CDE_SORT_NAME,VD_LONG_NAME,DE_PUB_ID,DE_VERSION,
 module,VD_ID, VD_Version, GR_QVV_VALUE, QVV.max_vv,QUESTION_ID ,QUESTION_VERSION ,
 VAL_DOM_TYP_ID, VD_DISPLAY_FORMAT, VAL_DOM_MAX_CHAR, 
 Q_DISP_ORD
 from VW_ALS_FIELD_RAW_DATA  VW,
 (select Q_PUB_ID,Q_VER_NR, 
       listagg(DISP_ORD||'.'||VALUE, '||') within group (order  by DISP_ORD) GR_QVV_VALUE,count(DISP_ORD) max_VV
from  NCI_QUEST_VALID_VALUE 
group  by Q_PUB_ID,Q_VER_NR) QVV
 where QUESTION_ID=QVV.Q_PUB_ID
 and QUESTION_VERSION=QVV.Q_VER_NR)
 where  FORM_ID||'v'||Form_Version in (7185328||'v'||1,7055820||'v'||1)
--and VD_ID=5676955 and VD_Version=1
group by Form_ID,Form_Version,Form_Long_Name,VD_ID,VD_LONG_NAME,VD_Version,GR_QVV_VALUE)DD,
NCI_QUEST_VALID_VALUE  VV
Where DD.QUESTION_ID=VV.Q_PUB_ID
and DD.QUESTION_VERSION=VV.Q_VER_NR
order by Form_ID,Form_Version,VD_ID,DD.QUESTION_ID

 