select FR.ITEM_NM "from Long Name", ALS_LONG_NAME(FR.ITEM_NM) FormOID,--rownum Ordinal,-- 
FR.ITEM_ID "Form  Public ID", FR.VER_NR "Form Version",
--module.C_ITEM_ID "Module ID",module.C_ITEM_VER_NR "Module Version",module.Rep_no "Module Repititions",
module.DISP_ORD "Module Display Order",QUESTION.NCI_PUB_ID "Question Public ID",
QUESTION.NCI_VER_NR "Question Version",QUESTION.DISP_ORD "Question Display Order",
QUESTION.ITEM_LONG_NM "Question long Name",INST.INSTR_LNG "Question Instruction",
--QVV.VALUE "Valid Value",QVV.MEAN_TXT "Valid Value Meaning" ,
--QVV.DISP_ORD "Valid Value DisplayOrder"  ,
DE.ITEM_ID DE_PUB_ID,DE.VER_NR DE_VERSION,DE.ITEM_LONG_NM "CDE Sort Name",
DE.ITEM_NM "CDE Long Name",--REF.REF_DESC  "Preferred Question  Text",
VD.ITEM_NM "VD Long Name",VALUE_DOM.VAL_DOM_MAX_CHAR ,
VALUE_DOM.VAL_DOM_HIGH_VAL_NUM "VD Maximum Length",
FMT.FMT_NM "VD Display Format",
VD.ITEM_id "VD ID",VD.VER_NR "VD Version",VALUE_DOM.UMO_ID
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
--,NCI_QUEST_VALID_VALUE  QVV

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
--AND QUESTION.NCI_PUB_ID  =QVV.Q_PUB_ID(+)
--AND QUESTION.NCI_VER_NR =QVV.Q_VER_NR(+)
and FORM.ITEM_ID =7185328 --and FR.VER_NR=2.1--in (38681702076012,3931472)
order by FR.ITEM_ID,module.DISP_ORD,QUESTION.DISP_ORD--,QVV.DISP_ORD