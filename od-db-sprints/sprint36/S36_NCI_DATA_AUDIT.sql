create or replace PACKAGE nci_data_audit AS
procedure spTriggerDataAudit(v_data_in in clob, v_data_out out clob);
 procedure spLoadDataAudit (v_start_dt in date, v_end_dt in date);
function getStdColNm (v_attr_nm in varchar2) return varchar2;
END;
/
create or replace PACKAGE BODY nci_data_audit AS

procedure spTriggerDataAudit (v_data_in in clob, v_data_out out clob) as
begin
spLoadDataAudit(sysdate -1, sysdate);
raise_application_error(-20000, 'Data Audit Load completed.');
end;


 procedure spLoadDataAudit (v_start_dt in date, v_end_dt in date)
as
v_cnt integer;
v_delimit varchar2(255) := 'OD_AUDIT_COLUMN_DELIMITER_OD';

begin

delete from nci_data_audt where creat_dt_audt >= v_start_dt and creat_dt_audt <= v_end_dt;
commit;

-- Admin Item and all sub-types
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, obj_id, tbl_nm)
select substr(PK_REF,9, instr(pk_ref,'OD_AUDIT_COLUMN_DELIMITER_OD')-10), substr(substr(pk_ref,instr(pk_ref,'OD_AUDIT_COLUMN_DELIMITER_OD')+36),1,
instr(substr(pk_ref,instr(pk_ref,'OD_AUDIT_COLUMN_DELIMITER_OD')+36),'#')-1), TRNS_TYP, 'Administered Item', PK_REF, UPD_COL_NM, UPD_COL_OLD_VAL, UPD_COL_NEW_VAL,  
CREAT_USR_ID, CREAT_USR_ID, CREAT_DT , CREAT_DT, obj_id, tbl_nm
from onedata_md.OD_MD_DATA_AUDT where 
TBL_NM in ('ADMIN_ITEM', 'DE', 'DE_CONC', 'NCI_FORM,''OBJ_CLS', 'PROP','VALUE_DOM', 'REP_CLS', 'NCI_PROTCL','CLSFCTN_SCHM','CONC_DOM','NCI_VAL_MEAN','CNTXT','CNCPT',
'NCI_MODULE','NCI_CLSFC3TN_SCHM_ITEM')
and creat_dt >= v_start_dt and creat_dt <= v_end_dt;
commit;


-- Alternate Names
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT,obj_id, tbl_nm)
select an.item_id,an.ver_nr, TRNS_TYP, 'Alternate Designations', PK_REF, UPD_COL_NM, UPD_COL_OLD_VAL, 
UPD_COL_NEW_VAL,  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,obj_id, tbl_nm
from onedata_md.OD_MD_DATA_AUDT a, ALT_NMS an where 
TBL_NM in ('ALT_NMS')
and substr(PK_REF,7, instr(pk_ref,'#')-7) = an.nm_id
and a.creat_dt >= v_start_dt and a.creat_dt <= v_end_dt;
commit;



-- Alternate Def
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT,obj_id, tbl_nm)
select an.item_id,an.ver_nr, TRNS_TYP, 'Alternate Definitions', PK_REF,  UPD_COL_NM, UPD_COL_OLD_VAL, 
 UPD_COL_NEW_VAL,  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,obj_id, tbl_nm
from onedata_md.OD_MD_DATA_AUDT a, ALT_DEF an where 
TBL_NM in ('ALT_DEF')
and substr(PK_REF,8, instr(pk_ref,'#')-8) = an.def_id
and a.creat_dt >= v_start_dt and a.creat_dt <= v_end_dt;
commit;


-- Reference Document
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT,obj_id, tbl_nm)
select an.item_id,an.ver_nr, TRNS_TYP, 'Reference Documents', PK_REF, decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), UPD_COL_OLD_VAL,
decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM),  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,obj_id, tbl_nm
from onedata_md.OD_MD_DATA_AUDT a, REF an where 
TBL_NM in ('REF')
and substr(PK_REF,8, instr(pk_ref,'#')-8) = an.ref_id
and a.creat_dt >= v_start_dt and a.creat_dt <= v_end_dt;
commit;

-- Perm val
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT,obj_id, tbl_nm)
select pv.val_dom_item_id, pv.val_dom_ver_nr, TRNS_TYP, 'Permissible Value', PK_REF, UPD_COL_NM, UPD_COL_OLD_VAL, UPD_COL_NEW_VAL,  
a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,obj_id, tbl_nm
from onedata_md.OD_MD_DATA_AUDT a, PERM_VAL pv where 
TBL_NM = 'PERM_VAL'
and pv.VAL_ID = substr(PK_REF,8, instr(pk_ref,'#')-8)
and a.creat_dt >= v_start_dt and a.creat_dt <= v_end_dt;
commit;



execute immediate 'Truncate table tmp_data_audt';


  insert into  TMP_DATA_AUDT
  (OBJ_ID,CHNGREQ_NR,UPD_COL_NM,UPD_COL_OLD_VAL,UPD_COL_NEW_VAL,TRNS_TYP,CREAT_DT,CREAT_USR_ID,AUDT_DESC,AUDT_DETL,PK_REF,TBL_NM, AUDT_CMNTS,
   	C_ITEM_ID,   	C_ITEM_VER_NR,   	P_ITEM_ID ,        P_ITEM_VER_NR,        REL_TYP_ID)
    select OBJ_ID,CHNGREQ_NR,UPD_COL_NM,UPD_COL_OLD_VAL,UPD_COL_NEW_VAL,TRNS_TYP,CREAT_DT,CREAT_USR_ID,AUDT_DESC,AUDT_DETL,PK_REF,TBL_NM, AUDT_CMNTS,
	 substr(PK_REF, instr(pk_ref,'C_ITEM_ID')+10,instr(substr(pk_ref,instr(pk_ref,'C_ITEM_ID')+10), '#')-1) ,
substr(PK_REF, instr(pk_ref,'C_ITEM_VER_NR')+14,instr(substr(pk_ref,instr(pk_ref,'C_ITEM_VER_NR')+14), '#')-1),
substr(PK_REF, instr(pk_ref,'P_ITEM_ID')+10,instr(substr(pk_ref,instr(pk_ref,'P_ITEM_ID')+10), '#')-1) ,
substr(PK_REF, instr(pk_ref,'P_ITEM_VER_NR')+14,instr(substr(pk_ref,instr(pk_ref,'P_ITEM_VER_NR')+14), '#')-1),
substr(PK_REF, instr(pk_ref,'REL_TYP_ID')+11,instr(substr(pk_ref,instr(pk_ref,'REL_TYP_ID')+11), '#')-1)
from onedata_md.od_md_data_audt where tbl_nm = 'NCI_ADMIN_ITEM_REL' and 
creat_dt >= v_start_dt and creat_dt <= v_end_dt;
commit;



-- Classifications
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS, obj_id)
select an.c_item_id,an.c_item_ver_nr, TRNS_TYP, 'Classifications', PK_REF, 
UPD_COL_NM,
--decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), 
UPD_COL_OLD_VAL,
UPD_COL_NEW_VAL,
--decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM), 
a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
a.p_item_id, obj_id
from TMP_DATA_AUDT a, NCI_ADMIN_ITEM_REL an where 
a.REL_TYP_ID = 61 and a.c_item_id = an.c_item_id and a.c_item_ver_nr = an.c_item_ver_nr and a.p_item_id = an.p_item_id and a.p_item_ver_nr = an.p_item_ver_nr
and a.rel_typ_id = an.rel_typ_id;
commit;

-- Form Protocol
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS, obj_id)
select an.c_item_id,an.c_item_ver_nr, TRNS_TYP, 'Form-Protocol', PK_REF, 
UPD_COL_NM,
--decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), 
UPD_COL_OLD_VAL,
UPD_COL_NEW_VAL,
--decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM), 
a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
a.p_item_id, obj_id
from TMP_DATA_AUDT a, NCI_ADMIN_ITEM_REL an where 
a.REL_TYP_ID = 60 and a.c_item_id = an.c_item_id and a.c_item_ver_nr = an.c_item_ver_nr and a.p_item_id = an.p_item_id and a.p_item_ver_nr = an.p_item_ver_nr
and a.rel_typ_id = an.rel_typ_id;
commit;


-- Form Module
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS,
LVL_1_ITEM_ID,LVL_1_VER_NR,LVL_1_ITEM_NM, LVL_1_DISP_ORD, obj_id)
select an.p_item_id,an.p_item_ver_nr, TRNS_TYP, 'Form-Module', PK_REF, 
UPD_COL_NM,
--decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), 
UPD_COL_OLD_VAL,
UPD_COL_NEW_VAL,
--decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM), 
a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
a.c_item_id, a.c_item_id, a.c_item_ver_nr, ai.item_nm, an.DISP_ORD, obj_id
from TMP_DATA_AUDT a, NCI_ADMIN_ITEM_REL an, ADMIN_ITEM ai where 
a.REL_TYP_ID = 61 and a.c_item_id = an.c_item_id and a.c_item_ver_nr = an.c_item_ver_nr and a.p_item_id = an.p_item_id and a.p_item_ver_nr = an.p_item_ver_nr
and a.rel_typ_id = an.rel_typ_id and an.c_item_id = ai.item_id and an.c_item_ver_nr = ai.ver_nr;
commit;


--DDE
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS, obj_id)
select an.p_item_id,an.p_item_ver_nr, TRNS_TYP, 'DDE Components', PK_REF, 
UPD_COL_NM,
--decode(TRNS_TYP, 'U', UPD_COL_NM, 'REF_NM'), 
UPD_COL_OLD_VAL,
UPD_COL_NEW_VAL,
--decode(TRNS_TYP, 'U', UPD_COL_NEW_VAL,REF_NM), 
a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
a.c_item_id, obj_id
from TMP_DATA_AUDT a, NCI_ADMIN_ITEM_REL an where 
a.REL_TYP_ID = 66 and a.c_item_id = an.c_item_id and a.c_item_ver_nr = an.c_item_ver_nr and a.p_item_id = an.p_item_id and a.p_item_ver_nr = an.p_item_ver_nr
and a.rel_typ_id = an.rel_typ_id;
commit;


-- Concept AI
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, obj_id)
select an.item_id,an.ver_nr, TRNS_TYP, 'Concept Relationship', PK_REF,UPD_COL_NM, UPD_COL_OLD_VAL,
 UPD_COL_NEW_VAL,  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT, obj_id
from onedata_md.OD_MD_DATA_AUDT a, CNCPT_ADMIN_ITEM an where 
TBL_NM in ('CNCPT_ADMIN_ITEM')
and substr(PK_REF,13, instr(pk_ref,'#')-13) = an.CNCPT_AI_ID
and a.creat_dt >= v_start_dt and a.creat_dt <= v_end_dt;
commit;


execute immediate 'Truncate table tmp_data_audt';


  insert into  TMP_DATA_AUDT
  (OBJ_ID,CHNGREQ_NR,UPD_COL_NM,UPD_COL_OLD_VAL,UPD_COL_NEW_VAL,TRNS_TYP,CREAT_DT,CREAT_USR_ID,AUDT_DESC,AUDT_DETL,PK_REF,TBL_NM, AUDT_CMNTS,
   	ITEM_ID,   VER_NR)
    select OBJ_ID,CHNGREQ_NR,UPD_COL_NM,UPD_COL_OLD_VAL,UPD_COL_NEW_VAL,TRNS_TYP,CREAT_DT,CREAT_USR_ID,AUDT_DESC,AUDT_DETL,PK_REF,TBL_NM, AUDT_CMNTS,
	 substr(PK_REF, instr(pk_ref,'NCI_PUB_ID')+11,instr(substr(pk_ref,instr(pk_ref,'NCI_PUB_ID')+11), '#')-1) ,
substr(PK_REF, instr(pk_ref,'NCI_VER_NR')+11,instr(substr(pk_ref,instr(pk_ref,'NCI_VER_NR')+11), '#')-1) 
from onedata_md.od_md_data_audt where tbl_nm in ( 'NCI_ADMIN_ITEM_REL_ALT_KEY','NCI_QUEST_VALID_VALUE') and 
creat_dt >= v_start_dt and creat_dt <= v_end_dt;
commit;

-- Questions
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS,
LVL_1_ITEM_ID, LVL_1_VER_NR, LVL_1_ITEM_NM, LVL_1_DISP_ORD,
LVL_2_ITEM_ID, LVL_2_VER_NR, LVL_2_ITEM_NM, LVL_2_DISP_ORD, obj_id)
select m.p_item_id,m.p_item_ver_nr, TRNS_TYP, 'Form Question', PK_REF,UPD_COL_NM, UPD_COL_OLD_VAL,
 UPD_COL_NEW_VAL,  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
 q.c_item_id,
 m.c_item_id, m.c_item_ver_nr, ai.item_nm,m.DISP_ORD,
 q.c_item_id, q.c_item_ver_nr, q.item_long_nm, q.DISP_ORD, obj_id
from TMP_DATA_AUDT a, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_ADMIN_ITEM_REL m, admin_item ai where 
 a.item_id = q.NCI_PUB_ID and a.ver_nr = q.NCI_VER_NR and q.P_ITEM_ID = m.c_item_id and q.p_item_ver_nr = m.c_item_ver_nr
 and a.tbl_nm = 'NCI_ADMIN_ITEM_REL_ALT_KEY' and m.c_item_id = ai.item_id and m.c_item_ver_nr = ai.ver_nr; 
commit;

-- Questions Valid Value
insert into nci_data_audt (item_id, ver_nr, --ADMIN_ITEM_TYP_ID, 
ACTION_TYP, LVL, LVL_PK, ATTR_NM, FROM_VAL, TO_VAL, CREAT_USR_ID_AUDT,
LST_UPD_USR_ID_AUDT, CREAT_DT_AUDT, LST_UPD_DT_AUDT, AUDT_CMNTS,
LVL_1_ITEM_ID, LVL_1_VER_NR, LVL_1_ITEM_NM, LVL_1_DISP_ORD,
LVL_2_ITEM_ID, LVL_2_VER_NR, LVL_2_ITEM_NM, LVL_2_DISP_ORD,
LVL_3_ITEM_ID, LVL_3_VER_NR, LVL_3_ITEM_NM, LVL_3_DISP_ORD, obj_id
)
select m.p_item_id,m.p_item_ver_nr, TRNS_TYP, 'Form Question Valid Values', PK_REF,UPD_COL_NM, UPD_COL_OLD_VAL,
 UPD_COL_NEW_VAL,  a.CREAT_USR_ID, a.CREAT_USR_ID, a.CREAT_DT , a.CREAT_DT,
 q.c_item_id,
 m.c_item_id, m.c_item_ver_nr, ai.item_nm,m.DISP_ORD,
 q.c_item_id, q.c_item_ver_nr, q.item_long_nm,q.DISP_ORD,
 vv.nci_pub_id, vv.nci_ver_nr, vv.value, vv.DISP_ORD, obj_id
from TMP_DATA_AUDT a, NCI_QUEST_VALID_VALUE vv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_ADMIN_ITEM_REL m , admin_item ai where 
 a.item_id = vv.NCI_PUB_ID and a.ver_nr = vv.NCI_VER_NR and q.P_ITEM_ID = m.c_item_id and q.p_item_ver_nr = m.c_item_ver_nr
 and vv.Q_PUB_ID = q.NCI_PUB_ID and vv.q_VER_NR = q.NCI_VER_NR and m.c_item_id = ai.item_id and m.c_item_ver_nr = ai.ver_nr
 and a.tbl_nm = 'NCI_QUEST_VALID_VALUE'; 
commit;

-- Column names
update nci_data_audt a set ATTR_NM_STD = (Select col_hdr from onedata_md.od_mdv_objcolhort h
where col_nm = a.attr_nm and h.obj_id = a.obj_id and a.attr_nm is not null)
where a.creat_dt_audt >= v_start_dt and a.creat_dt_audt <= v_end_dt;
commit;

update nci_data_audt a set ATTR_NM_STD = getStdColNm(ATTR_NM)
where a.creat_dt_audt >= v_start_dt and a.creat_dt_audt <= v_end_dt
and a.ATTR_NM_STD is null and a.ATTR_NM is not null;
commit;

/*

NCI_QUEST_VV_REP
REF_DOC
NCI_CSI_ALT_DEFNMS
*/


end;

function getStdColNm (v_attr_nm in varchar2) return varchar2 is
v_str varchar2(255);
begin
case v_attr_nm
when 'CNTXT_ITEM_ID,CNTXT_VER_NR' then v_str := 'Context';
when 'NCI_CNTXT_ITEM_ID,NCI_CNTXT_VER_NR' then v_str := 'Context';
when 'DE_CONC_ITEM_ID,DE_CONC_VER_NR' then v_str := 'DEC';
when 'REP_CLS_ITEM_ID,REP_CLS_VER_NR' then v_str := 'Rep Term';
when 'VAL_DOM_ITEM_ID,VAL_DOM_VER_NR' then v_str := 'Value Domain';
when 'NCI_VAL_MEAN_ITEM_ID,NCI_VAL_MEAN_VER_NR' then v_str := 'Value Meaning';
when 'CS_ITEM_ID,CS_ITEM_VER_NR' then v_str := 'Classification Scheme';
when 'OBJ_CLS_ITEM_ID,OBJ_CLS_VER_NR' then v_str := 'Object Class';
when 'CONC_DOM_ITEM_ID,CONC_DOM_VER_NR' then v_str := 'Conceptual Domain';
when 'PROP_ITEM_ID,PROP_VER_NR' then v_str := 'Property';
else v_str := v_attr_nm;
end case;
return v_str;
end;
end;
/
