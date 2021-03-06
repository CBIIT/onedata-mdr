create or replace view VW_ALS_FIELD as

select distinct FR.ITEM_NM Form_Long_Name, ALS_LONG_NAME(FR.ITEM_NM) FormOID,--rownum Ordinal,-- 
FR.ITEM_ID FORM_ID, FR.VER_NR Form_Version,
-1 Module,FR.VER_NR Q_Version,FR.ITEM_ID Q_ID,
'FORM_OID' Q_Long_Name,null Q_Instruction,
null DE_PUB_ID,NULL DE_VERSION,'FORM_OID' CDE_Sort_Name,
null CDE_Long_Name,-1 VV_CNT,
null VD_Sort_Name,null VD_Long_Name,200 VAL_DOM_MAX_CHAR ,
null VD_Max_Length,
'$200'VD_Display_Format,
FR.ITEM_id VD_ID,FR.VER_NR VD_Version,null UOM_ID from ADMIN_ITEM FR where FR.ADMIN_ITEM_TYP_ID=54
UNION
select distinct FR.ITEM_NM Form_Long_Name, ALS_LONG_NAME(FR.ITEM_NM) FormOID,--rownum Ordinal,-- 
FR.ITEM_ID FORM_ID, FR.VER_NR Form_Version,
module.DISP_ORD Module,QUESTION.NCI_VER_NR Q_Version,QUESTION.NCI_PUB_ID Q_ID,
QUESTION.ITEM_LONG_NM Q_Long_Name,INST.INSTR_LNG Q_Instruction,
DE.ITEM_ID DE_PUB_ID,DE.VER_NR DE_VERSION,DE.ITEM_LONG_NM CDE_Sort_Name,
DE.ITEM_NM CDE_Long_Name,count(*) VV_CNT,
VD.ITEM_LONG_NM VD_Sort_Name,VD.ITEM_NM VD_Long_Name,VALUE_DOM.VAL_DOM_MAX_CHAR ,
VALUE_DOM.VAL_DOM_HIGH_VAL_NUM VD_Max_Length,
FMT.FMT_NM VD_Display_Format,
VD.ITEM_id VD_ID,VD.VER_NR VD_Version,VALUE_DOM.UOM_ID
from ADMIN_ITEM de, de de2,
NCI_FORM FORM,ADMIN_ITEM FR, NCI_ADMIN_ITEM_REL MODULE,
NCI_ADMIN_ITEM_REL_ALT_KEY QUESTION,ADMIN_ITEM VD,VALUE_DOM, FMT 
,(SELECT REF.REF_DESC ,  REF.ITEM_ID ,REF.VER_NR   FROM  REF, OBJ_KEY
 WHERE  REF.REF_TYP_ID = OBJ_KEY.OBJ_KEY_ID  AND OBJ_KEY.OBJ_KEY_DESC = 'Preferred Question Text') REF
,(select NCI_INSTR.INSTR_ID,NCI_INSTR.INSTR_LNG ,INSTR.NCI_PUB_ID,INSTR.NCI_VER_NR from  NCI_INSTR ,
(select min(INSTR_ID)INSTR_ID ,NCI_VER_NR,NCI_PUB_ID from NCI_INSTR where NCI_LVL ='QUESTION' 
 group by NCI_VER_NR,NCI_PUB_ID)INSTR
 WHERE NCI_INSTR.NCI_LVL ='QUESTION'
AND NCI_INSTR.INSTR_ID=INSTR.INSTR_ID)INST
,NCI_QUEST_VALID_VALUE  QVV

where 
DE.ADMIN_ITEM_TYP_ID=4-- (DE)
AND VD.ADMIN_ITEM_TYP_ID=3 --(VD)
AND FR.ADMIN_ITEM_TYP_ID=54 
--AND FORM.ITEM_ID=PROTOCOL.FORM_ITEM_ID(+)
--AND FORM.VER_NR=PROTOCOL.FORM_VER_NR(+)
AND FORM.ITEM_ID=module.P_ITEM_ID
and FORM.VER_NR=module.P_ITEM_VER_NR and module.REL_TYP_ID in (62,61)
and QUESTION.REL_TYP_ID=63 AND QUESTION.P_ITEM_ID=module.C_ITEM_ID
and QUESTION.P_ITEM_VER_NR=module.C_ITEM_VER_NR AND QUESTION.C_ITEM_ID=de.ITEM_ID
and de.ITEM_ID=de2.ITEM_ID and de.ver_nr=de2.VER_NR
and QUESTION.C_ITEM_VER_NR=de.VER_NR 
AND DE.ITEM_ID = REF.ITEM_ID(+)
AND DE.VER_NR = REF.VER_NR(+) /**/
AND VALUE_DOM.VAL_DOM_FMT_ID=FMT.FMT_ID(+)
and de2.VAL_DOM_ITEM_ID=VALUE_DOM.ITEM_ID and de2.VAL_DOM_VER_NR =VALUE_DOM.VER_NR
and VD.ITEM_ID=VALUE_DOM.ITEM_ID and VD.VER_NR =VALUE_DOM.VER_NR
and FORM.ITEM_ID=FR.ITEM_ID and FORM.VER_NR=FR.VER_NR
and QUESTION.NCI_VER_NR=INST.NCI_VER_NR(+)
AND QUESTION.NCI_PUB_ID=INST.NCI_PUB_ID(+)
AND QUESTION.NCI_PUB_ID  =QVV.Q_PUB_ID(+)
AND QUESTION.NCI_VER_NR =QVV.Q_VER_NR(+)
group by FR.ITEM_NM , ALS_LONG_NAME(FR.ITEM_NM) , 
FR.ITEM_ID , FR.VER_NR ,
module.DISP_ORD ,QUESTION.NCI_VER_NR ,QUESTION.NCI_PUB_ID ,
QUESTION.ITEM_LONG_NM ,INST.INSTR_LNG ,
DE.ITEM_ID ,DE.VER_NR ,DE.ITEM_LONG_NM ,
DE.ITEM_NM ,VD.ITEM_LONG_NM ,VD.ITEM_NM ,VALUE_DOM.VAL_DOM_MAX_CHAR ,
VALUE_DOM.VAL_DOM_HIGH_VAL_NUM ,FMT.FMT_NM ,
VD.ITEM_id ,VD.VER_NR ,VALUE_DOM.UOM_ID

order by 3,4,14,5;


--and FORM.ITEM_ID =7037180 and FR.VER_NR=1--in (38681702076012,3931472,7185328 )
--select*from admin_item where ITEM_ID =7037180   7604620  2018731


select FormOID,substr(CDE_SORT_NAME,1,17) FIELDOID,DE_PUB_ID,DE_VERSION,
CASE 
  WHEN CDE_LONG_NAME is null Then 'PID'||Form_ID||'v'||Form_Version
ELSE substr(CDE_LONG_NAME,1,180)||' PID'||DE_PUB_ID||'v'||DE_VERSION 
 end DraftFieldName,module,
CDE_SORT_NAME VariableOID,
   CASE 
    WHEN VD_DISPLAY_FORMAT='MM/DD/YYYY' THEN 'dd MMM yyyy'
          ELSE '$'||VAL_DOM_MAX_CHAR
          END DataFormat ,
             CASE 
    WHEN VV_CNT in(1,-1) THEN NULL
          ELSE substr(VD_LONG_NAME,1,31)||' PID'||VD_ID||'v'||VD_Version
          END DataDictionaryName,Q_Long_Name PreText,CASE 
    WHEN Module in(-1) THEN 'PID'||Form_ID||'v'||Form_Version
          ELSE NULL
          END DefaultValue from VW_ALS_FIELD where FORM_ID=7037180 and Form_Version=1
          order by DE_PUB_ID NULLS FIRST,DE_VERSION  ;
          
          
select * from VW_ALS_FIELD where FORM_ID=7037180 and Form_Version=1

