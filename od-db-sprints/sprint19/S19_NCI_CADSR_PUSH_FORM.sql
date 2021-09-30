create or replace PACKAGE nci_caDSR_push_form AS
procedure sp_create_form_vv (    vDays   IN INTEGER);
procedure PushModule (vDays in integer);
procedure PushQuestion(vDays in integer);
PROCEDURE            PushQuestValidValue (vDays in integer);

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

procedure pushModule (vDays in integer)
as
v_cnt integer;
vActionType char(1);
v_id number;
vidseq char(36);
v_idseq char(36);
begin



for cur in (select ai.nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item ai, nci_admin_item_rel r where  greatest(ai.lst_upd_dt,r.lst_upd_dt) >= sysdate -vDays
and ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and r.rel_typ_id = 61 and ai.admin_item_typ_id = 52 and r.p_item_id <> r.c_item_id order by ai.creat_dt) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;
if (v_cnt = 0) then vActionType := 'I';
else vActionType := 'U';
end if;

if vActionType = 'I' then


-- Module
for curmod in (select  ai.NCI_IDSEQ MOD_IDSEQ, frm.nci_idseq FRM_IDSEQ,  rel.disp_ord,rel.rep_no,ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq CNTXT_IDSEQ,ai.UNTL_DT,
decode(ai.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND, rel.instr,
            ai.ITEM_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes') FLD_DELETE from admin_item ai, admin_item c, NCI_ADMIN_ITEM_REL rel, admin_item frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ai.item_id and rel.c_item_ver_nr = ai.ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and ai.nci_idseq= cur.nci_idseq) loop
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

end loop;
end if;



if vActionType = 'U' then

-- Module
update sbrext.quest_contents_ext set (display_order, repeat_no,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,
            date_modified, modified_by, deleted_ind)=
(select   rel.disp_ord,rel.rep_no,ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,
            rel.LST_UPD_DT,rel.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, NCI_ADMIN_ITEM_REL rel, admin_item frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ai.item_id and rel.c_item_ver_nr = ai.ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and ai.nci_idseq= cur.nci_idseq)
        where qc_idseq = cur.nci_idseq;

update sbrext.quest_contents_ext set (preferred_definition,
            date_modified, modified_by, deleted_ind) =
(select  nvl(rel.instr, ' '),
           rel.LST_UPD_DT,rel.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai,  nci_admin_item_rel rel
        where  rel.rel_typ_id = 61
        and rel.c_item_id  = ai.item_id and rel.c_item_ver_nr = ai.ver_nr
             and ai.nci_idseq= cur.nci_idseq)
             where qc_idseq = cur.nci_idseq and qtl_name = 'MODULE_INSTR';
      --      and frm.hdr_instr is not null;


end if;

end loop;
commit;
end;



procedure pushQuestion (vDays in integer)
as
v_cnt integer;
vActionType char(1);
v_id number;
v_idseq  char(36);
begin

for cur in (select * from nci_admin_item_rel_alt_key where lst_upd_dt >= sysdate -vDays ) loop
select count(*) into v_cnt  from sbrext.quest_contents_ext where qc_idseq = cur.nci_idseq;
if (v_cnt = 0) then vActionType := 'I';
else vActionType := 'U';
end if;

if vActionType = 'I' then
--vidseq := cur.nci_idseq;
--raise_application_error(-20000,cur.nci_idseq);

for curqst in (select  ak.NCI_IDSEQ QST_IDSEQ, mod.nci_idseq MOD_IDSEQ,  frm.nci_idseq FRM_IDSEQ, de.nci_idseq DE_IDSEQ,
ak.disp_ord,frm.ADMIN_STUS_NM_DN, frm.EFF_DT, frm.ADMIN_NOTES, c.nci_idseq CNTXT_IDSEQ,frm.UNTL_DT,
decode(frm.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND, ak.instr, ak.EDIT_IND, ak.req_ind, ak.DEFLT_VAL,
            ak.ITEM_LONG_NM, frm.ORIGIN,substr(de.ITEM_DESC,1,2000) ITEM_DESC,ak.ITEM_Nm,ak.NCI_PUB_ID, ak.NCI_VER_NR,
            ak.CREAT_USR_ID, ak.CREAT_DT, ak.LST_UPD_DT,ak.LST_UPD_USR_ID ,decode(nvl(ak.fld_delete,0),0,'No',1,'Yes') FLD_DELETE
        from nci_admin_item_rel_alt_key ak, admin_item c, admin_item mod, admin_item frm, admin_item de, nci_admin_item_rel rel
        where frm.cntxt_item_id = c.item_id and frm.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ak.p_item_id and rel.c_item_ver_nr = ak.p_item_ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and rel.c_item_id = mod.item_id and rel.c_item_ver_nr = mod.ver_nr
        and ak.nci_idseq= cur.nci_idseq
        and ak.c_item_id = de.item_id (+)
        and ak.c_item_ver_nr = de.ver_nr(+)) loop

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
            curqst.ITEM_LONG_NM, curqst.ORIGIN,curqst.ITEM_DESC,
            nci_11179_2.getStdShortName(curqst.NCI_PUB_ID, curqst.NCI_VER_NR),
            curqst.NCI_PUB_ID, curqst.NCI_VER_NR,
         curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete);

-- Question Instruction
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
            curqst.ITEM_LONG_NM, curqst.ORIGIN,curqst.item_desc,
                      nci_11179_2.getStdShortName(v_id, curqst.NCI_VER_NR),
            v_id, curqst.NCI_VER_NR,
              curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID ,curqst.fld_delete);



insert into sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq, quest_idseq , editable_ind,mandatory_ind,DEFAULT_VALUE,
            created_by, date_created,date_modified, modified_by)
values (curqst.qst_idseq, curqst.qst_idseq, decode(nvl(curqst.EDIT_IND,0), 1, 'Yes', 'No'), decode(nvl(curqst.REQ_IND,0), 1, 'Yes', 'No'), curqst.DEFLT_VAL,
curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID );


insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curqst.mod_idseq, curqst.qst_idseq, curqst.disp_ord ,'MODULE_ELEMENT', curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID from dual;

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curqst.qst_idseq, v_idseq, curqst.disp_ord ,'ELEMENT_INSTRUCTION', curqst.CREAT_USR_ID, curqst.CREAT_DT, curqst.LST_UPD_DT,curqst.LST_UPD_USR_ID from dual;
end loop;
end if;

if vActionType = 'U' then
update sbrext.quest_contents_ext set ( display_order, latest_version_ind,
            long_name,
            date_modified, modified_by, deleted_ind)=
(select  ak.disp_ord,
decode(frm.CURRNT_VER_IND,1,'Yes',0,'No'),
            ak.ITEM_LONG_NM,
           ak.LST_UPD_DT,ak.LST_UPD_USR_ID ,decode(nvl(ak.fld_delete,0),0,'No',1,'Yes')
        from nci_admin_item_rel_alt_key ak, admin_item c, admin_item mod, admin_item frm, admin_item de, nci_admin_item_rel rel
        where frm.cntxt_item_id = c.item_id and frm.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ak.p_item_id and rel.c_item_ver_nr = ak.p_item_ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and rel.c_item_id = mod.item_id and rel.c_item_ver_nr = mod.ver_nr
        and ak.nci_idseq= cur.nci_idseq
        and ak.c_item_id = de.item_id (+)
        and ak.c_item_ver_nr = de.ver_nr(+))
        where qc_idseq = cur.nci_idseq;


end if;
end loop;
commit;
end;

PROCEDURE            PushQuestValidValue (vDays in integer)
 AS
    v_cnt   INTEGER;
    v_id number;
    v_idseq char(36);
BEGIN
    FOR cur IN (SELECT nci_idseq
                  FROM NCI_QUEST_VALID_VALUE
                 WHERE lst_upd_dt >= sysdate - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                      -- new

            for curvv in (SELECT vv.NCI_IDSEQ,      q.p_mod_idseq,
                       q.dn_crf_idseq,
                       q.qc_idseq,--rel.disp_ord,
                       q.asl_Name,
                       q.begin_date,
                       q.change_note,
                       q.conte_idseq ,
                       q.end_date,
                       q.latest_version_ind,
                       vv.VALUE,
                       vv.VM_DEF,
                       vv.desc_txt,
                       vv.mean_txt,
                       vv.NCI_PUB_ID,
                       vv.NCI_VER_NR,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID,
                       vv.instr,
                       decode(nvl(vv.fld_delete,0),0,'No',1,'Yes') FLD_DELETE,  vv.disp_ord
                  FROM sbrext.quest_contents_ext q,
                  nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = q.qc_ID
                 and   vv.q_ver_nr = q.version
                       AND vv.nci_idseq = cur.nci_idseq) loop

            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   p_qst_idseq,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
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
                values ( curvv.NCI_IDSEQ,
                       curvv.p_mod_idseq,
                       'VALID_VALUE',
                       curvv.dn_crf_idseq,
                       curvv.qc_idseq,--rel.disp_ord,
                       curvv.asl_Name,
                       curvv.begin_date,
                       curvv.change_note,
                       curvv.conte_idseq,
                       curvv.end_date,
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
                       curvv.fld_delete, 'Yes',curvv.disp_ord);

   INSERT INTO sbr.administered_components (ac_idseq,actl_name,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
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
                       curvv.asl_Name,
                       curvv.begin_date,
                       curvv.change_note,
                       curvv.conte_idseq,
                       curvv.end_date,
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

   INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   p_qst_idseq,
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
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
                values ( v_idseq,
                       curvv.p_mod_idseq,
                       'VALUE_INSTR',
                       curvv.dn_crf_idseq,
                       curvv.qc_idseq,
                       curvv.asl_Name,
                       curvv.begin_date,
                       curvv.change_note,
                       curvv.conte_idseq,
                       curvv.end_date,
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
                                                   asl_name,
                                                   begin_date,
                                                   change_note,
                                                   conte_idseq,
                                                   end_date,
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
               values ( v_IDSEQ,
                       'QUEST_CONTENT',
                       curvv.asl_Name,
                       curvv.begin_date,
                       curvv.change_note,
                       curvv.conte_idseq,
                       curvv.end_date,
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
                       curvv.fld_delete);

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

-- Instructions


insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curvv.qc_idseq, curvv.nci_idseq, curvv.disp_ord ,'ELEMENT_VALUE', curvv.CREAT_USR_ID, curvv.CREAT_DT, curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID from dual;

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,CREATED_BY,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curvv.nci_idseq, v_idseq, curvv.disp_ord ,'VALUE_INSTRUCTION',  curvv.CREAT_USR_ID, curvv.CREAT_DT, curvv.LST_UPD_DT,curvv.LST_UPD_USR_ID from dual;
end loop;
        END IF;
        if (v_cnt = 1) then
            update sbrext.quest_contents_ext set ( latest_version_ind,
                                                   long_name,
                                                   preferred_definition,display_order,
                                                   date_modified,
                                                   modified_by, deleted_ind)=
               ( SELECT q.latest_version_ind,
                       vv.VALUE,
                       vv.VM_DEF,
                       vv.disp_ord,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID,
                       decode(nvl(vv.fld_delete,0),0,'No',1,'Yes')
                  FROM sbrext.quest_contents_ext q,
                  nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = q.qc_ID
                 and   vv.q_ver_nr = q.version
                       AND vv.nci_idseq = cur.nci_idseq)
                       where qc_idseq = cur.nci_idseq;


            update sbrext.valid_values_att_ext set ( description_text,
                                                     meaning_text,
                                                     date_modified,
                                                     modified_by) =
                (SELECT
                       desc_txt,
                       mean_txt,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM nci_quest_valid_value vv
                 WHERE nci_idseq = cur.nci_idseq)
                 where qc_idseq = cur.nci_idseq;
        end if;

    END LOOP;
/*
  INSERT INTO NCI_QUEST_VALID_VALUE (NCI_PUB_ID,
                                       Q_PUB_ID,
                                       Q_VER_NR,
                                       VM_NM,
                                       VM_DEF,
                                       VALUE,
                                       NCI_IDSEQ,
                                       DESC_TXT,
                                       MEAN_TXT,
                                       VAL_MEAN_ITEM_ID,
                                       VAL_MEAN_VER_NR,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID, DISP_ORD)
        SELECT qc.qc_id,
               qc1.qc_id,
               qc1.VERSION,
               qc.preferred_name,
               qc.preferred_definition,
               qc.long_name,
               qc.qc_idseq,
               vv.description_text,
               vv.meaning_text,
               vm.vm_id,
               vm.version,
          nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr), qc.DISPLAY_ORDER
                       FROM sbrext_m.quest_contents_ext    qc,
               sbrext_m.quest_contents_ext    qc1,
               sbrext_m.valid_values_att_ext  vv,
               sbrext_m.vd_pvs  vp,
                sbrext_m.permissible_Values pv,
                sbrext_m.value_meanings vm
         WHERE     qc.qtl_name = 'VALID_VALUE'
               AND qc1.qtl_name = 'QUESTION'
               AND qc1.qc_idseq = qc.p_qst_idseq
               AND qc.qc_idseq = vv.qc_idseq(+)
                and vp.pv_idseq = pv.pv_idseq (+) and pv.vm_idseq = vm.vm_idseq (+)
                and qc.vp_idseq = vp.vp_idseq (+);

    COMMIT;
*/
    COMMIT;
/*


insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
qc.date_modified, qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
( QUEST_PUB_ID ,  QUEST_VER_NR ,
 VV_PUB_ID, VV_VER_NR,
 VAL,EDIT_IND , REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
qvv.date_modified, qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;
*/

END;

procedure sp_create_form_vv (    vDays   IN INTEGER)
as
v_cnt integer;
begin

delete from NCI_QUEST_VALID_VALUE;
commit;

insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, Q_VER_NR, VM_NM, VM_DEF, VALUE, NCI_IDSEQ, DESC_TXT, MEAN_TXT,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select qc.qc_id, qc1.qc_id, qc1.VERSION, qc.preferred_name, qc.preferred_definition ,qc.long_name, qc.qc_idseq, vv.description_text, vv.meaning_text,
qc.created_by, qc.date_created,
qc.date_modified, qc.modified_by
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1, sbrext.valid_values_att_ext vv
where qc.qtl_name = 'VALID_VALUE' and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq and qc.qc_idseq = vv.qc_idseq (+);

commit;

delete from NCI_QUEST_VV_REP;
commit;

insert into NCI_QUEST_VV_REP
(	QUEST_PUB_ID , 	QUEST_VER_NR ,
	VV_PUB_ID,	VV_VER_NR,
	VAL,EDIT_IND ,	REP_SEQ,
   CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID )
select q.NCI_PUB_ID, q.NCI_VER_NR, vv.NCI_PUB_ID, vv.NCI_VER_NR,
qvv.value, decode(editable_ind,'Yes',1,'No',0), repeat_sequence,
qvv.created_by, qvv.date_created,
qvv.date_modified, qvv.modified_by
from sbrext.quest_vv_ext qvv, NCI_ADMIN_ITEM_REL_ALT_KEY q, NCI_QUEST_VALID_VALUE vv
where qvv.quest_idseq = q.NCI_IDSEQ and qvv.vv_idseq = vv.NCI_IDSEQ (+);
commit;
end;
END;
/
