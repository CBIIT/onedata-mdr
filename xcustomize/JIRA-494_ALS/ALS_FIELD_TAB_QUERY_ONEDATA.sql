select Form_Long_Name,CDE_SORT_NAME,VD_LONG_NAME,DE_PUB_ID,DE_VERSION,
 module, Q_DISP_ORD,QUESTION_VERSION,QUESTION_ID ,QUESTION_VERSION,GR_QVV_VALUE, QVV.max_DISP_ORD,
  VD_DISPLAY_FORMAT, VAL_DOM_MAX_CHAR, VAL_DOM_TYP_ID,
 VD_ID, VD_Version, QUESTION_Long_Name, QUESTION_ID  
 from VW_ALS_FIELD_RAW_DATA  VW,
 (select Q_PUB_ID,Q_VER_NR, 
       listagg(DISP_ORD||'.'||VALUE, '||') within group (order  by DISP_ORD) GR_QVV_VALUE,max(DISP_ORD) max_DISP_ORD
from  NCI_QUEST_VALID_VALUE 
group  by Q_PUB_ID,Q_VER_NR) QVV
 where QUESTION_ID=QVV.Q_PUB_ID(+)
 and QUESTION_VERSION=QVV.Q_VER_NR(+)
 and FORM_ID||'v'||Form_Version in 7185328||'v'||1
--and VD_ID=5676955 and VD_Version=1
 order by Form_ID, VD_ID,module NULLS FIRST,CDE_SORT_NAME NULLS FIRST;--,DISP_ORD; 
 

 select VALUE CodedData,VM_DEF UserDataString, Q_PUB_ID,Q_VER_NR 
 from NCI_QUEST_VALID_VALUE where Q_PUB_ID= 7190507 and Q_VER_NR=1;


select Form_Long_Name,CDE_SORT_NAME,VD_LONG_NAME,DE_PUB_ID,DE_VERSION,
 module,VD_ID, VD_Version, GR_QVV_VALUE, QVV.max_vv,QUESTION_ID ,QUESTION_VERSION ,
 VAL_DOM_TYP_ID, VD_DISPLAY_FORMAT, VAL_DOM_MAX_CHAR, 
 Q_DISP_ORD
 from VW_ALS_FIELD_RAW_DATA  VW,
 (select Q_PUB_ID,Q_VER_NR, 
       listagg(DISP_ORD||'.'||VALUE, '||') within group (order  by DISP_ORD) GR_QVV_VALUE,count(DISP_ORD) max_VV
from  NCI_QUEST_VALID_VALUE 
group  by Q_PUB_ID,Q_VER_NR) QVV
 where QUESTION_ID=QVV.Q_PUB_ID(+)
 and QUESTION_VERSION=QVV.Q_VER_NR(+)
 and FORM_ID||'v'||Form_Version in 7185328||'v'||1
--and VD_ID=5676955 and VD_Version=1
 order by Form_ID, module NULLS FIRST,VD_ID,GR_QVV_VALUE NULLS FIRST;