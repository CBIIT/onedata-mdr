create or replace PACKAGE nci_caDSR_push_form AS
PROCEDURE sp_create_form_quest_rel (    vDays   IN INTEGER);
procedure sp_create_form_vv (    vDays   IN INTEGER);
END;
/
create or replace PACKAGE body nci_caDSR_push_form AS

PROCEDURE            sp_create_form_quest_rel (
    vDays   IN INTEGER)
AS
    v_cnt   INTEGER;
BEGIN
    FOR cur IN (SELECT nci_idseq
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                 WHERE lst_upd_dt >= SYSDATE - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                                                            -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   display_order,
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
                                                   modified_by)
                SELECT rel.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'QUESTION',
                       frm.nci_idseq,
                       rel.disp_ord,
                       ai.ADMIN_STUS_NM_DN,
                       ai.EFF_DT,
                       ai.ADMIN_NOTES,
                       c.nci_idseq,
                       ai.UNTL_DT,
                       DECODE (ai.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       ai.ITEM_LONG_NM,
                       ai.ITEM_DESC,
                       rel.nci_pub_id,
                       rel.NCI_PUB_ID,
                       rel.NCI_VER_NR,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM admin_item                  ai,
                       admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c
                 WHERE     ai.item_id = rel.c_item_id
                       AND ai.ver_nr = rel.c_item_ver_nr
                       AND ai.cntxt_item_id = c.item_id
                       AND ai.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id > 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq,
                                                   display_order,
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
                                                   modified_by)
                SELECT rel.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'QUESTION',
                       frm.nci_idseq,
                       rel.disp_ord,
                       frm.ADMIN_STUS_NM_DN,
                       frm.EFF_DT,
                       frm.ADMIN_NOTES,
                       c.nci_idseq,
                       frm.UNTL_DT,
                       DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       rel.ITEM_LONG_NM,
                       frm.ITEM_DESC,
                       rel.nci_pub_id,
                       rel.NCI_PUB_ID,
                       rel.NCI_VER_NR,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c
                 WHERE     frm.cntxt_item_id = c.item_id
                       AND frm.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id < 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq,
                                                     editable_ind,
                                                     mandatory_ind,
                                                     DEFAULT_VALUE,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT cur.nci_idseq,
                       DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                       DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                       DEFLT_VAL,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
                 WHERE nci_idseq = cur.nci_idseq;


            INSERT INTO sbrext.QUEST_ATTRIBUTES_EXT (qc_idseq,
                                                     editable_ind,
                                                     mandatory_ind,
                                                     DEFAULT_VALUE,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT cur.nci_idseq,
                       DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                       DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                       DEFLT_VAL,
                       rel.CREAT_USR_ID,
                       rel.CREAT_DT,
                       rel.LST_UPD_DT,
                       rel.LST_UPD_USR_ID
                  FROM NCI_ADMIN_ITEM_REL_ALT_KEY rel
                 WHERE nci_idseq = cur.nci_idseq;
        ELSE
            UPDATE sbrext.quest_contents_ext
               SET (long_name,
                    display_order,
                    date_modified,
                    modified_by) =
                       (SELECT item_long_nm,
                               disp_ord,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                         WHERE nci_idseq = cur.nci_idseq)
             WHERE qc_idseq = cur.nci_idseq;

            UPDATE sbrext.QUEST_ATTRIBUTES_EXT
               SET (editable_ind,
                    mandatory_ind,
                    DEFAULT_VALUE,
                    date_modified,
                    modified_by) =
                       (SELECT DECODE (EDIT_IND,  1, 'Yes',  0, 'No'),
                               DECODE (REQ_IND,  1, 'Yes',  0, 'No'),
                               DEFLT_VAL,
                               LST_UPD_DT,
                               LST_UPD_USR_ID
                          FROM NCI_ADMIN_ITEM_REL_ALT_KEY
                         WHERE nci_idseq = cur.nci_idseq)
             WHERE qc_idseq = cur.nci_idseq;
        END IF;
    END LOOP;

    COMMIT;

    FOR cur IN (SELECT nci_idseq
                  FROM NCI_QUEST_VALID_VALUE
                 WHERE lst_upd_dt >= SYSDATE - vDays)
    LOOP
        SELECT COUNT (*)
          INTO v_cnt
          FROM sbrext.quest_contents_ext
         WHERE qc_idseq = cur.nci_idseq;

        IF (v_cnt = 0)
        THEN                                                            -- new
            INSERT INTO sbrext.quest_contents_ext (qc_idseq,
                                                   p_mod_idseq,
                                                   qtl_name,
                                                   dn_crf_idseq, --display_order,
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
                                                   modified_by)
                SELECT vv.NCI_IDSEQ,
                       MOD.nci_idseq,
                       'VALID_VALUE',
                       frm.nci_idseq,                          --rel.disp_ord,
                       frm.ADMIN_STUS_NM_DN,
                       frm.EFF_DT,
                       frm.ADMIN_NOTES,
                       c.nci_idseq,
                       frm.UNTL_DT,
                       DECODE (frm.CURRNT_VER_IND,  1, 'Yes',  0, 'No'),
                       vv.VALUE,
                       vv.VM_DEF,
                       vv.nci_pub_id,
                       vv.NCI_PUB_ID,
                       vv.NCI_VER_NR,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM admin_item                  MOD,
                       admin_item                  frm,
                       NCI_ADMIN_ITEM_REL_ALT_KEY  rel,
                       nci_admin_item_rel          mf,
                       admin_item                  c,
                       nci_quest_valid_value       vv
                 WHERE     vv.Q_PUB_ID = rel.NCI_PUB_ID
                       AND vv.q_ver_nr = rel.nci_ver_nr
                       AND frm.cntxt_item_id = c.item_id
                       AND frm.cntxt_ver_nr = c.ver_nr
                       AND c.admin_item_typ_id = 8
                       AND rel.rel_typ_id = 63
                       AND rel.p_item_id = MOD.item_id
                       AND rel.p_item_ver_nr = MOD.ver_nr
                       AND MOD.item_id = mf.c_item_id
                       AND MOD.ver_nr = mf.c_item_ver_nr
                       AND mf.p_item_id = frm.item_id
                       AND mf.p_item_ver_nr = frm.ver_nr
                       AND rel.c_item_id > 0
                       AND rel.nci_idseq = cur.nci_idseq;

            INSERT INTO sbrext.valid_values_att_ext (qc_idseq,
                                                     description_text,
                                                     meaning_text,
                                                     created_by,
                                                     date_created,
                                                     date_modified,
                                                     modified_by)
                SELECT nci_idseq,
                       desc_txt,
                       mean_txt,
                       vv.CREAT_USR_ID,
                       vv.CREAT_DT,
                       vv.LST_UPD_DT,
                       vv.LST_UPD_USR_ID
                  FROM nci_quest_valid_value vv
                 WHERE nci_idseq = cur.nci_idseq;
        END IF;
    END LOOP;

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
