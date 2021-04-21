create or replace view VW_ALS_FIELD_RAW_DATA as

select distinct FR.ITEM_NM Form_Long_Name, --rownum Ordinal,-- 
FR.ITEM_ID FORM_ID, FR.VER_NR Form_Version,
null Module,null QUESTION_Version,null QUESTION_ID,
'FORM_OID' QUESTION_Long_Name,null Q_Instruction,
null DE_PUB_ID,NULL DE_VERSION,'FORM_OID' CDE_Sort_Name,
null CDE_Long_Name,
null VD_Sort_Name,null VD_Long_Name,null VAL_DOM_MAX_CHAR , null VAL_DOM_TYP_ID,
null VD_Max_Length,
null VD_Display_Format,
FR.ITEM_id VD_ID,FR.VER_NR VD_Version,null UOM_ID from ADMIN_ITEM FR where FR.ADMIN_ITEM_TYP_ID=54
UNION
select distinct FR.ITEM_NM Form_Long_Name, --rownum Ordinal,-- 
FR.ITEM_ID FORM_ID, FR.VER_NR Form_Version,
module.DISP_ORD Module,QUESTION.NCI_VER_NR QUESTION_Version,QUESTION.NCI_PUB_ID QUESTION_ID,
QUESTION.ITEM_LONG_NM QUESTION_Long_Name,INST.INSTR_LNG Q_Instruction,
DE.ITEM_ID DE_PUB_ID,DE.VER_NR DE_VERSION,DE.ITEM_LONG_NM CDE_Sort_Name,
DE.ITEM_NM CDE_Long_Name,
VD.ITEM_LONG_NM VD_Sort_Name,VD.ITEM_NM VD_Long_Name,VALUE_DOM.VAL_DOM_MAX_CHAR ,DECODE (VAL_DOM_TYP_ID,  17, 'E', 18,  'N') VAL_DOM_TYP_ID,
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

where 
DE.ADMIN_ITEM_TYP_ID=4-- (DE)
AND VD.ADMIN_ITEM_TYP_ID=3 --(VD)
AND FR.ADMIN_ITEM_TYP_ID=54 

AND FORM.ITEM_ID=module.P_ITEM_ID
and FORM.VER_NR=module.P_ITEM_VER_NR and module.REL_TYP_ID =61
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
order by 2,3,4;
select Form_ID,Form_Version,Form_Long_Name,CDE_SORT_NAME,DE_PUB_ID,DE_VERSION,
 CDE_LONG_NAME ,module,VD_DISPLAY_FORMAT,VAL_DOM_MAX_CHAR,VAL_DOM_TYP_ID,
 VD_LONG_NAME,VD_ID,VD_Version ,QUESTION_Long_Name  , QUESTION_ID  
 from VW_ALS_FIELD_RAW_DATA  where FORM_ID||'v'||Form_Version in (7185328||'v'||1, 7055820||'v'||1)
 order by Form_ID,DE_PUB_ID NULLS FIRST,DE_VERSION;
          
          
select*from value_dom;
--and FORM.ITEM_ID =7037180 and FR.VER_NR=1--in (38681702076012,3931472,7185328 )
--select*from admin_item where ITEM_ID =7037180   7604620  2018
select FormOID,Form_Long_Name,substr(CDE_SORT_NAME,1,17) FIELDOID,DE_PUB_ID,DE_VERSION,
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
          END DataDictionaryName,VD_ID||'v'||VD_Version,CDE_LONG_NAME,VD_LONG_NAME ,Q_Long_Name PreText,CASE 
    WHEN Module in(-1) THEN 'PID'||Form_ID||'v'||Form_Version
          ELSE NULL
          END DefaultValue ,module from VW_ALS_FIELD where FORM_ID in (7185328, 7055820)
          and CDE_SORT_NAME in ('ELIG_NOT_PREG_CONF','ELIG_NOT_BRFEED_CONF')
        --  and VD_ID=5676955 and VD_Version=2 and Form_Version=1
          order by Form_ID,DE_PUB_ID NULLS FIRST,DE_VERSION  ;
         -- PID7185328_V1_0,PID7055820_V1_0
          
select * from VW_ALS_FIELD where FORM_ID in (7185328, 7055820) and Form_Version=1;
select*from admin_item where item_id=5676955 and ver_nr=2
select  FR.ITEM_NM DraftFormName, ALS_LONG_NAME(FR.ITEM_NM) FormOID,ITEM_ID,rownum Ordinal,-- 
FR.ITEM_ID FORM_ID , Ver_nr from admin_item FR where ITEM_ID in (7185328, 7055820) and Ver_nr=1
order by ITEM_ID , Ver_nr;

select DataDictionaryName from(
select FormOID,Form_Long_Name,substr(CDE_SORT_NAME,1,17) FIELDOID,DE_PUB_ID,DE_VERSION,
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
          END DefaultValue,VD_LONG_NAM,VD_ID||'v'||VD_Version,Form_ID,Form_Version from VW_ALS_FIELD )
           where FORM_ID in (7185328, 7055820)and Form_Version=1 and DataDictionaryName is not null
          order by DataDictionaryName  ;

select*from NCI_ADMIN_ITEM_REL_ALT_KEY where C_ITEM_ID=7171875 

select *from admin_item where item_id in (7171875,5676955,7185329)

select*from obj_key where obj_key_id in (62,61,52,66)--Module,

select*from NCI_ADMIN_ITEM_REL where REL_TYP_ID=61

7171844