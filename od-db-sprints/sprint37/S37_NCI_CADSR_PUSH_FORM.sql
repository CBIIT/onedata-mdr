create or replace PACKAGE nci_caDSR_push_form AS
procedure PushModule (vHours in integer);
procedure PushQuestion(vHours in integer);
PROCEDURE            PushQuestValidValue (vHours in integer);
procedure DeleteFormHierarchy (vHours in integer);

END;
/
create or replace PACKAGE body nci_caDSR_push_form AS

/* ELEMENT_INSTRUCTION
MODULE_ELEMENT
VALUE_INSTRUCTION
ELEMENT_VALUE
FORM_MODULE
FORM_INSTRUCTION
MODULE_INSTRUCTION
*/

procedure pushModule (vHours in integer)
as
v_cnt integer;
vActionType char(1);
v_id number;
vidseq char(36);
v_idseq char(36);
begin


-- Undeleted rows
for cur in (select ai.nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item ai, nci_admin_item_rel r where  greatest(ai.lst_upd_dt,r.lst_upd_dt) >= sysdate -vHours/24
and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61 and ai.admin_item_typ_id = 52 and r.p_item_id <> r.c_item_id  and nvl(r.fld_delete,0) = 0 order by ai.lst_upd_dt) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;
if (v_cnt = 0) then vActionType := 'I';
else vActionType := 'U';
end if;


-- Module
for curmod in (select  ai.NCI_IDSEQ MOD_IDSEQ, frm.nci_idseq FRM_IDSEQ, 
rel.disp_ord,nvl(rel.rep_no,0) rep_no,ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq CNTXT_IDSEQ,ai.UNTL_DT,
decode(ai.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND, nci_cadsr_push.getShortDef(rel.instr) INSTR,
            ai.ITEM_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR,
            rel.CREAT_USR_ID, rel.CREAT_DT, rel.LST_UPD_DT,rel.LST_UPD_USR_ID ,
            decode(nvl(rel.fld_delete,0),0,'No',1,'Yes') FLD_DELETE from admin_item ai, admin_item c, NCI_ADMIN_ITEM_REL rel, admin_item frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ai.item_id and rel.c_item_ver_nr = ai.ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and ai.nci_idseq= cur.nci_idseq) loop

if vActionType = 'I' then

insert into sbrext.quest_contents_ext (qc_idseq,p_mod_idseq, qtl_name, dn_crf_idseq,display_order, repeat_no,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind, display_ind)
values ( curmod.MOD_IDSEQ,curmod.MOD_IDSEQ, 'MODULE',  curmod.FRM_idseq, curmod.disp_ord,curmod.rep_no,curmod.ADMIN_STUS_NM_DN,curmod.EFF_DT,
curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,nci_cadsr_push.getShortDef(curmod.ITEM_DESC),curmod.ITEM_LONG_Nm,curmod.ITEM_ID, curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete, 'Yes');


insert into sbr.administered_components (ac_idseq,actl_name,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind) values
( curmod.MOD_IDSEQ, 'QUEST_CONTENT', curmod.ADMIN_STUS_NM_DN,curmod.EFF_DT, curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,curmod.ITEM_DESC,curmod.ITEM_LONG_Nm,curmod.ITEM_ID, curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete);


--Module Instruction
v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;

--raise_application_error(-20000, 'HEre');
insert into sbrext.quest_contents_ext (qc_idseq, p_mod_idseq, dn_crf_idseq, qtl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,qc_id,
            version,
            created_by, date_created,date_modified, modified_by,deleted_ind, display_ind) values
( v_idseq,  curmod.mod_idseq, curmod.frm_idseq, 'MODULE_INSTR' , curmod.ADMIN_STUS_NM_DN, curmod.EFF_DT, curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,
            nvl(curmod.instr, ' '),
            v_id,v_id,
            curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete, 'Yes');

insert into sbr.administered_components (ac_idseq,actl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,public_id,
            version,
            created_by, date_created,date_modified, modified_by,deleted_ind) values
    ( v_idseq,  'QUEST_CONTENT', curmod.ADMIN_STUS_NM_DN, curmod.EFF_DT, curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,nvl(curmod.instr, ' '),
            v_id,v_id,
            curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete);

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curmod.frm_idseq, curmod.mod_idseq, curmod.disp_ord ,'FORM_MODULE', curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID from dual;

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curmod.mod_idseq, v_idseq, curmod.disp_ord ,'MODULE_INSTRUCTION', curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID from dual;
end if;

if vActionType = 'U' then

-- Module
update sbrext.quest_contents_ext set (display_order, repeat_no,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,
            date_modified, modified_by, deleted_ind)=
(select curmod.disp_ord,curmod.rep_no,curmod.ADMIN_STUS_NM_DN,curmod.EFF_DT,
curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,nci_cadsr_push.getShortDef(curmod.ITEM_DESC),curmod.ITEM_LONG_Nm,
            curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete from dual)
            where qc_idseq = curmod.mod_idseq;
            commit;

update sbr.administered_components set (
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,
            date_modified, modified_by, deleted_ind)=
(select curmod.ADMIN_STUS_NM_DN,curmod.EFF_DT,
curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,nci_cadsr_push.getShortDef(curmod.ITEM_DESC),curmod.ITEM_LONG_Nm,
            curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete from dual)
            where ac_idseq = curmod.mod_idseq;
            commit;
            
update sbrext.qc_recs_ext set (DISPLAY_ORDER)=
(select  curmod.disp_ord  from dual)
where p_qc_idseq = curmod.frm_idseq and c_qc_idseq  = curmod.mod_idseq;
commit;


select count(*) into v_cnt from sbrext.quest_contents_ext  where p_mod_idseq = curmod.mod_idseq and qtl_name = 'MODULE_INSTR';

if (v_cnt > 0 ) then
--raise_application_error(-20000, 'Here');
--for curtemp in (
update sbrext.quest_contents_ext set ( preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(curmod.instr, ' '),
            curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete from dual)
            where  p_mod_idseq = curmod.mod_idseq and qtl_name = 'MODULE_INSTR';
            commit;

update sbr.administered_components set ( long_name, preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select curmod.item_nm,  nvl(curmod.instr, ' '),
            curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete from dual)
            where  ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_mod_idseq = curmod.mod_idseq and qtl_name = 'MODULE_INSTR');
            commit;
      --      and frm.hdr_instr is not null;
else
--Module Instruction
v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;
insert into sbrext.quest_contents_ext (qc_idseq, p_mod_idseq, dn_crf_idseq, qtl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,qc_id,
            version,
            created_by, date_created,date_modified, modified_by,deleted_ind, display_ind) values
( v_idseq,  curmod.mod_idseq, curmod.frm_idseq, 'MODULE_INSTR' , curmod.ADMIN_STUS_NM_DN, curmod.EFF_DT, curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,
            nvl(curmod.instr, ' '),
            v_id,v_id,
            curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete, 'Yes');

commit;

insert into sbr.administered_components (ac_idseq,actl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,public_id,
            version,
            created_by, date_created,date_modified, modified_by,deleted_ind) values
    ( v_idseq,  'QUEST_CONTENT', curmod.ADMIN_STUS_NM_DN, curmod.EFF_DT, curmod.ADMIN_NOTES, curmod.CNTXT_idseq,curmod.UNTL_DT, curmod.CURRNT_VER_IND,
            curmod.ITEM_NM, curmod.ORIGIN,nvl(curmod.instr, ' '),
            v_id,v_id,
            curmod.VER_NR,
            curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID ,curmod.fld_delete);
commit;
insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curmod.mod_idseq, v_idseq, curmod.disp_ord ,'MODULE_INSTRUCTION', curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID from dual;
commit;
end if;

end if;


-- delete repetitions 
delete from sbrext.quest_vv_ext  where quest_idseq  in (select nci_idseq from nci_admin_item_rel_alt_key where p_item_id = cur.item_id and p_item_ver_nr = cur.ver_nr)
and repeat_sequence > curmod.rep_no;
commit;

end loop;


end loop;
commit;

for cur in (select ai.nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item ai, nci_admin_item_rel r where  greatest(ai.lst_upd_dt,r.lst_upd_dt) >= sysdate -vHours/24
and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61 and ai.admin_item_typ_id = 52 and r.p_item_id <> r.c_item_id  and nvl(r.fld_delete,0) = 1 order by ai.lst_upd_dt) loop

delete from sbrext.triggered_actions_ext where S_QC_IDSEQ = cur.nci_idseq or
T_QC_IDSEQ = cur.nci_idseq or
S_QR_IDSEQ = cur.nci_idseq or
T_QR_IDSEQ = cur.nci_idseq;
commit;

delete from sbrext.qc_recs_ext where c_qc_idseq = cur.nci_idseq ;
commit;
delete from sbr.quest_attributes_ext where qc_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_mod_idseq = cur.nci_idseq) ;
commit;
delete from sbrext.qc_recs_ext where p_qc_idseq = cur.nci_idseq;
commit;
delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_mod_idseq = cur.nci_idseq) or
ac_idseq = cur.nci_idseq;
commit;

delete from quest_contents_ext where p_mod_idseq = cur.nci_idseq;
commit;
delete from quest_contents_ext where qc_idseq = cur.nci_idseq;
commit;

end loop;

end;



procedure pushQuestion (vHours in integer)
as
v_cnt integer;
vActionType char(1);
v_id number;
v_idseq  char(36);
v_vv_idseq char(36);
begin

for cur in (select * from nci_admin_item_rel_alt_key where lst_upd_dt >= sysdate -vHours/24  and nvl(fld_delete,0) = 0 order by lst_upd_dt ) loop
select count(*) into v_cnt  from sbrext.quest_contents_ext where qc_idseq = cur.nci_idseq;
if (v_cnt = 0) then vActionType := 'I';
else vActionType := 'U';
end if;

--vidseq := cur.nci_idseq;
--raise_application_error(-20000,cur.nci_idseq);

for curqst in (select  ak.NCI_IDSEQ QST_IDSEQ, mod.nci_idseq MOD_IDSEQ,  nvl(rel.rep_no,0) mod_rep_no, frm.nci_idseq FRM_IDSEQ, de.nci_idseq DE_IDSEQ,
ak.disp_ord,frm.ADMIN_STUS_NM_DN, frm.EFF_DT, frm.ADMIN_NOTES, c.nci_idseq CNTXT_IDSEQ,frm.UNTL_DT,
decode(frm.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND, nci_cadsr_push.getShortDef(ak.instr) INSTR, nvl(ak.EDIT_IND,0) EDIT_IND, nvl(ak.req_ind,0) REQ_IND, ak.DEFLT_VAL,ak.deflt_val_id,
            ak.ITEM_LONG_NM, frm.ORIGIN,substr(de.ITEM_DESC,1,2000) ITEM_DESC,ak.ITEM_Nm,ak.NCI_PUB_ID, ak.NCI_VER_NR,
            ak.CREAT_USR_ID, ak.CREAT_DT, ak.LST_UPD_DT,ak.LST_UPD_USR_ID ,decode(nvl(ak.fld_delete,0),0,'No',1,'Yes') FLD_DELETE
        from nci_admin_item_rel_alt_key ak, admin_item c, admin_item mod, admin_item frm, admin_item de, nci_admin_item_rel rel
        where frm.cntxt_item_id = c.item_id and frm.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and nvl(ak.fld_delete,0) = 0
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ak.p_item_id and rel.c_item_ver_nr = ak.p_item_ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and rel.c_item_id = mod.item_id and rel.c_item_ver_nr = mod.ver_nr
        and ak.nci_idseq= cur.nci_idseq
        and ak.c_item_id = de.item_id (+)
        and ak.c_item_ver_nr = de.ver_nr(+)) loop

if (curqst.deflt_val_id is not null) then
select vv.nci_idseq into v_vv_idseq from nci_quest_valid_value vv where vv.nci_pub_id = curqst.deflt_val_id;
end if;

if vActionType = 'I' then
insert into sbrext.quest_contents_ext (qc_idseq , p_qst_idseq, p_mod_idseq, qtl_name, dn_crf_idseq, De_idseq, display_order,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind,  display_ind)
values ( curqst.QST_IDSEQ, curqst.QST_IDSEQ,curqst.mod_idseq, 'QUESTION',  curqst.FRM_idseq, curqst.de_idseq, curqst.disp_ord,curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT,
curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            curqst.ITEM_LONG_NM, curqst.ORIGIN,
            nci_cadsr_push.getShortDef (curqst.ITEM_DESC),
            --curqst.ITEM_Nm,
            curqst.nci_pub_id,
            curqst.NCI_PUB_ID, curqst.NCI_VER_NR,
            curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete, 'Yes');



insert into sbr.administered_components (ac_idseq , actl_name,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
values ( curqst.QST_IDSEQ,'QUEST_CONTENT', curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT, curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            nci_cadsr_push.getLongName(curqst.ITEM_LONG_NM), curqst.ORIGIN, nci_cadsr_push.getShortDef (curqst.ITEM_DESC),
            nci_11179_2.getStdShortName(curqst.NCI_PUB_ID, curqst.NCI_VER_NR),
            curqst.NCI_PUB_ID, curqst.NCI_VER_NR,
         curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete);

-- Question Instruction  only insert if not null
if (curqst.instr is not null) then
v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;
insert into sbrext.quest_contents_ext (qc_idseq , p_qst_idseq, p_mod_idseq, qtl_name, dn_crf_idseq, De_idseq, display_order,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind,  display_ind)
values(  v_idseq, curqst.qst_idseq, curqst.mod_idseq, 'QUESTION_INSTR',  curqst.frm_idseq, curqst.de_idseq, curqst.disp_ord,
curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT, curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            curqst.ITEM_LONG_NM, curqst.ORIGIN,nvl(curqst.instr, ' ' ),v_id, v_id, curqst.NCI_VER_NR,
              curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete, 'Yes');


insert into sbr.administered_components (ac_idseq , actl_name,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
values (  v_idseq,'QUEST_CONTENT', curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT, curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            nci_cadsr_push.getLongName(curqst.ITEM_LONG_NM), curqst.ORIGIN,nvl(curqst.instr, ' ' ),
                      nci_11179_2.getStdShortName(v_id, curqst.NCI_VER_NR),
            v_id, curqst.NCI_VER_NR,
              curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete);


insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curqst.qst_idseq, v_idseq, curqst.disp_ord ,'ELEMENT_INSTRUCTION', curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID from dual;

end if;


insert into sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq, quest_idseq , editable_ind,mandatory_ind,DEFAULT_VALUE,
            created_by, date_created,date_modified, modified_by, vv_idseq)
select curqst.qst_idseq, curqst.qst_idseq, decode(curqst.EDIT_IND, 1, 'Yes', 'No'), decode(curqst.REQ_IND, 1, 'Yes', 'No'), curqst.DEFLT_VAL,
curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID, v_vv_idseq  from dual;
commit;



insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curqst.mod_idseq, curqst.qst_idseq, curqst.disp_ord ,'MODULE_ELEMENT', curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID from dual;

-- insert repetitions

end if;


if vActionType = 'U' then
update sbrext.quest_contents_ext set ( display_order, latest_version_ind,
            long_name,
            date_modified, modified_by, deleted_ind, de_idseq)=
(select  curqst.disp_ord,curqst.CURRNT_VER_IND,curqst.ITEM_LONG_NM,  curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete, curqst.de_idseq from dual)  where qc_idseq = cur.nci_idseq;


update sbr.administered_components set (
            long_name,
            date_modified, modified_by, deleted_ind)=
(select
            nci_cadsr_push.getLongName(curqst.ITEM_LONG_NM),  curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete from dual)
         where ac_idseq = curqst.qst_idseq;
         commit;

--raise_application_error (-20000, curqst.gst_idseq, curqst.deflt_val_id
select count(*) into v_cnt from sbrext.QUEST_ATTRIBUTES_EXT where qc_idseq = curqst.qst_idseq;
if (v_cnt = 1) then
update sbrext.QUEST_ATTRIBUTES_EXT set ( editable_ind,mandatory_ind,DEFAULT_VALUE
            ,date_modified, modified_by, vv_idseq)=
(select  decode(curqst.EDIT_IND, 1, 'Yes', 'No'), decode(curqst.REQ_IND, 1, 'Yes', 'No'), curqst.DEFLT_VAL,
 curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID, v_vv_idseq from dual 
) where qc_idseq = curqst.qst_idseq;
commit;
else


insert into sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq, quest_idseq , editable_ind,mandatory_ind,DEFAULT_VALUE,
            created_by, date_created,date_modified, modified_by, vv_idseq)
select curqst.qst_idseq, curqst.qst_idseq, decode(curqst.EDIT_IND, 1, 'Yes', 'No'), decode(curqst.REQ_IND, 1, 'Yes', 'No'), curqst.DEFLT_VAL,
curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID, v_vv_idseq  from dual;
commit;
end if;


-- Update display order
update sbrext.qc_recs_ext set (DISPLAY_ORDER)=
(select  curqst.disp_ord  from dual)
where p_qc_idseq = curqst.mod_idseq and c_qc_idseq  = curqst.qst_idseq;
commit;

-- Question Instruction
select count(*) into v_cnt from sbrext.quest_contents_ext  where p_qst_idseq = curqst.qst_idseq and qtl_name = 'QUESTION_INSTR';
if (v_cnt = 0) then
if (curqst.instr is not null) then
v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;
insert into sbrext.quest_contents_ext (qc_idseq , p_qst_idseq, p_mod_idseq, qtl_name, dn_crf_idseq, De_idseq, display_order,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind,  display_ind)
values(  v_idseq, curqst.qst_idseq, curqst.mod_idseq, 'QUESTION_INSTR',  curqst.frm_idseq, curqst.de_idseq, curqst.disp_ord,
curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT, curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            curqst.ITEM_LONG_NM, curqst.ORIGIN,nvl(curqst.instr, ' ' ),v_id, v_id, curqst.NCI_VER_NR,
              curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete, 'Yes');


insert into sbr.administered_components (ac_idseq , actl_name,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
values (  v_idseq,'QUEST_CONTENT', curqst.ADMIN_STUS_NM_DN, curqst.EFF_DT, curqst.ADMIN_NOTES, curqst.cntxt_idseq,curqst.UNTL_DT,
curqst.CURRNT_VER_IND,
            nci_cadsr_push.getLongName(curqst.ITEM_LONG_NM), curqst.ORIGIN,nvl(curqst.instr, ' ' ),
                      nci_11179_2.getStdShortName(v_id, curqst.NCI_VER_NR),
            v_id, curqst.NCI_VER_NR,
              curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete);
              
insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curqst.qst_idseq, v_idseq, curqst.disp_ord ,'ELEMENT_INSTRUCTION', curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID from dual;
end if;

else
-- update instruction

if (curqst.instr is null) then -- delete row

delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_qst_idseq =  curqst.qst_idseq and qtl_name = 'QUESTION_INSTR');
commit;
delete from sbrext.qc_recs_ext where p_qc_idseq = curqst.qst_idseq and rl_name = 'ELEMENT_INSTRUCTION';
commit;

delete from sbrext.quest_contents_ext where p_qst_idseq =  curqst.qst_idseq and qtl_name = 'QUESTION_INSTR';
commit;
else
update sbrext.quest_contents_ext set ( preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(curqst.instr, ' '),
            curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete from dual)
            where  p_qst_idseq = curqst.qst_idseq and qtl_name = 'QUESTION_INSTR';
            commit;
            
            
update sbr.administered_components set ( preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(curqst.instr, ' '),
            curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete from dual)
            where  ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_qst_idseq =  curqst.qst_idseq and qtl_name = 'QUESTION_INSTR');
            commit;
end if;
end if;
-- update display order


end if;


end loop;


end loop;


-- Repetitions

for currep in (select * from nci_quest_vv_rep where lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete,0) = 0 order by lst_upd_dt) loop
for cur in (select * from nci_admin_item_rel_alt_key where nci_pub_id = currep.quest_pub_id and nci_ver_nr = currep.quest_ver_nr) loop
select count(*) into v_cnt from sbrext.quest_vv_ext where QUEST_IDSEQ = cur.nci_idseq and repeat_sequence = currep.REP_SEQ;
if (nvl(currep.fld_delete,0) = 1) then -- deleted row
delete from sbrext.quest_vv_ext where QUEST_IDSEQ = cur.nci_idseq and repeat_sequence = currep.REP_SEQ;
commit;
else

v_vv_idseq := null;
if (currep.deflt_val_id is not null) then
select vv.nci_idseq into v_vv_idseq from nci_quest_valid_value vv where vv.nci_pub_id = currep.deflt_val_id;
end if;

if (v_cnt = 0 ) then
insert into sbrext.quest_vv_ext (QV_IDSEQ,QUEST_IDSEQ,VV_IDSEQ,VALUE,EDITABLE_IND,REPEAT_SEQUENCE, DATE_CREATED,DATE_MODIFIED,MODIFIED_BY,CREATED_BY)
select nci_11179.cmr_guid, cur.nci_idseq, v_vv_idseq, currep.VAL, decode(nvl(currep.EDIT_IND,0), 1, 'Yes', 'No'), currep.REP_SEQ,
currep.creat_dt , currep.lst_upd_dt, currep.lst_upd_usr_id, currep.creat_usr_id from dual;
else
update sbrext.quest_vv_ext set (VV_IDSEQ,VALUE,EDITABLE_IND,DATE_MODIFIED, MODIFIED_BY) = 
(select  v_vv_idseq, currep.VAL, decode(nvl(currep.EDIT_IND,0), 1, 'Yes', 'No'), 
currep.lst_upd_dt, currep.lst_upd_usr_id from dual) where QUEST_IDSEQ = cur.nci_idseq and repeat_sequence = currep.REP_SEQ;
end if;
commit;
end if; -- not deleted


end loop;
end loop;

-- deleted questions

    
for cur in (select  ak.* from nci_admin_item_rel_alt_key ak, nci_admin_item_rel r where ak.lst_upd_dt >= sysdate -vHours/24 and nvl(ak.fld_delete,0) = 1 
and ak.p_item_id = r.c_item_id and ak.p_item_ver_nr = r.c_item_ver_nr and nvl(r.fld_delete,0) = 0 and r.reL_typ_id = 61
order by ak.lst_upd_dt  ) loop

delete from sbrext.triggered_actions_ext where S_QC_IDSEQ = cur.nci_idseq or
T_QC_IDSEQ = cur.nci_idseq or
S_QR_IDSEQ = cur.nci_idseq or 
T_QR_IDSEQ = cur.nci_idseq;
commit;

delete from sbrext.qc_recs_ext where c_qc_idseq = cur.nci_idseq ;
commit;


delete from sbrext.qc_recs_ext where  p_qc_idseq = cur.nci_idseq;
commit;

delete from sbrext.QUEST_ATTRIBUTES_EXT where  qc_idseq = cur.nci_idseq;
commit;

delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_qst_idseq = cur.nci_idseq) or
ac_idseq = cur.nci_idseq;
commit;
delete from quest_contents_ext where p_qst_idseq = cur.nci_idseq;
commit;
delete from quest_contents_ext where qc_idseq= cur.nci_idseq;
commit;
        end loop;
end;

PROCEDURE            PushQuestValidValue (vHours in integer)
 AS
    v_cnt   INTEGER;
    v_id number;
    v_idseq char(36);
    v_vp_idseq char(36);
    v_temp integer;
BEGIN

      
            for curvv in (SELECT vv.NCI_IDSEQ,      q.p_mod_idseq,
                       q.dn_crf_idseq,
                       q.qc_idseq,--rel.disp_ord,
                       q.conte_idseq ,
                       q.latest_version_ind,
                       q.asl_name,
                       vv.VALUE,
                       substr(vv.VM_DEF,1,2000) VM_DEF,
                       vv.desc_txt,
                       vv.mean_txt,
                       vv.NCI_PUB_ID,
                       vv.NCI_VER_NR,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID,
                       nci_cadsr_push.getShortDef(vv.instr) INSTR,
                       vv.q_pub_id, vv.q_ver_nr,vv.val_mean_item_id, vv.val_mean_ver_nr,
                       decode(nvl(vv.fld_delete,0),0,'No',1,'Yes') FLD_DELETE,  vv.disp_ord
                  FROM sbrext.quest_contents_ext q,
                  nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = q.qc_ID
                 and   vv.q_ver_nr = q.version
                  and nvl(vv.fld_delete,0) = 0
                       AND vv.lst_upd_dt >= sysdate - vHours/24 order by vv.lst_upd_dt) loop

        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = curvv.nci_idseq;

-- Find vp_idseq
v_vp_idseq := null;

for curvpidseq in (select pv.nci_idseq  from perm_val pv, de, nci_admin_item_rel_alt_key ak where pv.val_dom_item_id = de.val_dom_item_id and pv.val_dom_ver_nr = de.val_dom_ver_nr
and pv.nci_Val_mean_item_id = curvv.val_mean_item_id  and pv.nci_val_mean_ver_nr = curvv.val_mean_ver_nr 
and ak.c_item_id = de.item_id and ak.c_item_Ver_nr = de.ver_nr and ak.nci_pub_id = curvv.q_pub_id and ak.nci_ver_nr = curvv.q_ver_nr) loop
v_vp_idseq := curvpidseq.nci_idseq;
end loop;
  IF (v_cnt = 0)
        THEN                      -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   asl_name,
                                                   dn_crf_idseq,
                                                   p_qst_idseq,
                                                conte_idseq,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind, display_ind, display_order, vp_idseq)
                values ( curvv.NCI_IDSEQ,
                       curvv.p_mod_idseq,
                       'VALID_VALUE',
                       curvv.asl_name,
                       curvv.dn_crf_idseq,
                       curvv.qc_idseq,--rel.disp_ord,
                    curvv.conte_idseq,
                       curvv.latest_version_ind,
                       curvv.VALUE,
                       curvv.VM_DEF,
                       curvv.nci_pub_id,
                       curvv.NCI_PUB_ID,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete, 'Yes',curvv.disp_ord, v_vp_idseq);

   INSERT INTO sbr.administered_components (ac_idseq,actl_name,
                                                  conte_idseq,
                                                  asl_name,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   public_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind)
               values ( curvv.NCI_IDSEQ,
                       'QUEST_CONTENT',
                     curvv.conte_idseq,
                     curvv.asl_name,
                       curvv.latest_version_ind,
                       curvv.VALUE,
                       curvv.VM_DEF,
                       curvv.nci_pub_id,
                       curvv.NCI_PUB_ID,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete);

--- Valid Values Instructions

v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;

   INSERT INTO sbrext.quest_contents_ext (qc_idseq,p_val_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   asl_name,
                                                   dn_crf_idseq,
                                                   p_qst_idseq,
                                                  conte_idseq,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind, display_ind, display_order)
                values ( v_idseq, curvv.nci_idseq,
                       curvv.p_mod_idseq,
                       'VALUE_INSTR',
                       curvv.asl_name,
                       curvv.dn_crf_idseq,
                       curvv.qc_idseq,
                      curvv.conte_idseq,
                      curvv.latest_version_ind,
                       curvv.VALUE,
                       nvl(curvv.instr, ' '),
                      v_id,
                       v_id,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete, 'Yes',curvv.disp_ord);


   INSERT INTO sbr.administered_components (ac_idseq,actl_name,
                                                  conte_idseq,
                                                  latest_version_ind,
                                                   long_name,
                                                   asl_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   public_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind)
               values ( v_IDSEQ,
                       'QUEST_CONTENT',
                       curvv.conte_idseq,
                       curvv.latest_version_ind,
                       curvv.VALUE,
                       'DRAFT NEW',
                           nvl(curvv.instr, ' '),
                     v_id,
                       v_id,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete); 

select count(*) into v_temp from sbrext.valid_values_att_ext where qc_idseq = curvv.nci_idseq;
if (v_temp =0) then
            INSERT INTO sbrext.valid_values_att_ext (qc_idseq,
                                                     description_text,
                                                     meaning_text,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                values ( curvv.nci_idseq,
                       curvv.desc_txt,
                       curvv.mean_txt,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID);
end if;
-- Instructions


insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curvv.qc_idseq, curvv.nci_idseq, curvv.disp_ord ,'ELEMENT_VALUE', curvv.CREAT_USR_ID, curvv.CREAT_DT, curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID from dual;

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curvv.nci_idseq, v_idseq, curvv.disp_ord ,'VALUE_INSTRUCTION',  curvv.CREAT_USR_ID, curvv.CREAT_DT, curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID from dual;
        END IF;
        if (v_cnt = 1) then
            update sbrext.quest_contents_ext set ( 
                                                   long_name,
                                                   preferred_definition,display_order,
                                                   date_modified,
                                                   modified_by, deleted_ind, vp_idseq)=
               ( SELECT
                       curvv.VALUE,
                       curvv.VM_DEF,
                       curvv.disp_ord,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete, v_vp_idseq
                                        FROM dual)
                                        where qc_idseq = curvv.nci_idseq;



update sbr.administered_components set (
            long_name,
            date_modified, modified_by, deleted_ind)=
(select
            curvv.VALUE,  curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID ,curvv.fld_delete from dual)
         where ac_idseq = curvv.nci_idseq;
         commit;
         
            update sbrext.valid_values_att_ext set ( description_text,
                                                     meaning_text,
                                                     date_modified,
                                                     modified_by) =
                (SELECT
                       curvv.desc_txt,
                       curvv.mean_txt,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID
                  FROM  dual)
                 where qc_idseq = curvv.nci_idseq;
                 
                 

-- Update display order
update sbrext.qc_recs_ext set (DISPLAY_ORDER)=
(select  curvv.disp_ord  from dual)
where c_qc_idseq  = curvv.nci_idseq;
commit;


--- Valid Value instructions


--- Valid Values Instructions

select count(*) into v_cnt from sbrext.quest_contents_ext  where p_val_idseq = curvv.nci_idseq and qtl_name = 'VALUE_INSTR';



    if (v_cnt = 0) then
    
v_id := nci_11179.getItemid;
v_idseq := nci_11179.cmr_guid;
   INSERT INTO sbrext.quest_contents_ext (qc_idseq,p_val_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   asl_name,
                                                   dn_crf_idseq,
                                                   p_qst_idseq,
                                                   conte_idseq,
                                                   latest_version_ind,
                                                   long_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   qc_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind, display_ind, display_order)
                values ( v_idseq, curvv.nci_idseq,
                       curvv.p_mod_idseq,
                       'VALUE_INSTR',
                       curvv.asl_name,
                       curvv.dn_crf_idseq,
                       curvv.qc_idseq,
                         curvv.conte_idseq,
                       curvv.latest_version_ind,
                       curvv.VALUE,
                       nvl(curvv.instr, ' '),
                      v_id,
                       v_id,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete, 'Yes',curvv.disp_ord);
                       
                       
   INSERT INTO sbr.administered_components (ac_idseq,actl_name,
                                                  conte_idseq,
                                                  latest_version_ind,
                                                   long_name,
                                                                     asl_name,
                                                   preferred_definition,
                                                   preferred_name,
                                                   public_id,
                                                   version,
                                                   created_by,
                                                   date_created,
                                                   date_modified,
                                                   modified_by, deleted_ind)
               values ( v_IDSEQ,
                       'QUEST_CONTENT',
                       curvv.conte_idseq,
                       curvv.latest_version_ind,
                       curvv.VALUE,
                       'DRAFT NEW',
                           nvl(curvv.instr, ' '),
                     v_id,
                       v_id,
                       curvv.NCI_VER_NR,
                       curvv.CREAT_USR_ID,
                       curvv.CREAT_DT,
                       curvv.LST_UPD_DT,
                       curvv.LST_UPD_USR_ID,
                       curvv.fld_delete); 
                       
select count(*) into v_temp from sbrext.qc_recs_ext where p_qc_idseq = curvv.nci_idseq and rl_name = 'VALUE_INSTRUCTION';
if (v_temp=0) then
insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curvv.nci_idseq, v_idseq, curvv.disp_ord ,'VALUE_INSTRUCTION',  curvv.CREAT_USR_ID, curvv.CREAT_DT, curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID from dual;
        end if;
            else
            -- update
            

update sbrext.quest_contents_ext set ( preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(curvv.instr, ' '),
            curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID ,curvv.fld_delete from dual)
            where  p_val_idseq = curvv.nci_idseq and qtl_name = 'VALUE_INSTR';
            commit;
            
            
update sbr.administered_components set ( preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(curvv.instr, ' '),
            curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID ,curvv.fld_delete from dual)
            where  ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_val_idseq = curvv.nci_idseq and qtl_name = 'VALUE_INSTR');
            commit;
            end if;

        end if;
end loop;
    COMMIT;

/*
-- Deleted valid values
   for cur in (
SELECT vv.NCI_IDSEQ
                  FROM 
                  nci_quest_valid_value       vv
                 WHERE      nvl(vv.fld_delete,0) = 1
                       AND vv.lst_upd_dt >= sysdate - 1/24 order by vv.lst_upd_dt) loop

delete from sbrext.triggered_actions_ext where S_QC_IDSEQ = cur.nci_idseq or
T_QC_IDSEQ = cur.nci_idseq or
S_QR_IDSEQ = cur.nci_idseq or 
T_QR_IDSEQ = cur.nci_idseq;
commit;

delete from sbrext.qc_recs_ext where c_qc_idseq = cur.nci_idseq ;
commit;

delete from sbrext.qc_recs_ext where  p_qc_idseq = cur.nci_idseq;
commit;

delete from sbrext.valid_values_att_ext where  qc_idseq = cur.nci_idseq;
commit;

delete from sbr.administered_components where ac_idseq in (select qc_idseq from sbrext.quest_contents_ext where p_val_idseq = cur.nci_idseq) or
ac_idseq = cur.nci_idseq;
commit;
delete from quest_contents_ext where p_val_idseq = cur.nci_idseq;
commit;
delete from quest_contents_ext where qc_idseq= cur.nci_idseq;
commit;
end loop;
*/
END;

procedure DeleteFormHierarchy (vHours in integer)
as
v_cnt integer;
begin

delete from sbr.administered_components where date_modified >= sysdate - vHours/24 and deleted_ind = 'Yes';
commit;

end;

END;
/
