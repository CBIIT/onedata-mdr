
select h.HDR_ID,Form_Long_Name,CDE_SORT_NAME,VD_LONG_NAME,DE_PUB_ID,DE_VERSION,
 module,VD_ID, VD_Version, GR_QVV_VALUE, QVV.max_vv VV_COUNT,QUESTION_ID ,QUESTION_VERSION ,
 VAL_DOM_TYP_ID, VD_DISPLAY_FORMAT, VAL_DOM_MAX_CHAR, 
 Q_DISP_ORD
 from VW_ALS_FIELD_RAW_DATA  VW,
 (select Q_PUB_ID,Q_VER_NR, 
       listagg(DISP_ORD||'.'||VALUE, '||') within group (order  by DISP_ORD) GR_QVV_VALUE,count(DISP_ORD) max_VV
from  NCI_QUEST_VALID_VALUE 
group  by Q_PUB_ID,Q_VER_NR) QVV,
 NCI_DLOAD_DTL ALS,
    NCI_DLOAD_HDR H
    where FORM_ID=ALS.ITEM_ID
    AND Form_Version=ALS.VER_NR
    and h.HDR_ID=ALS.HDR_ID
    and h.DLOAD_TYP_ID=92
 and QUESTION_ID=QVV.Q_PUB_ID(+)
 and QUESTION_VERSION=QVV.Q_VER_NR(+)
 --and FORM_ID||'v'||Form_Version in 7185328||'v'||1
--and h.HDR_ID='XXX'
 order by h.HDR_ID,Form_ID, module NULLS FIRST,VD_ID,GR_QVV_VALUE NULLS FIRST;