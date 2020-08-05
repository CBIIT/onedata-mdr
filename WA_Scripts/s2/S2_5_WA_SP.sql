create or replace procedure sp_org_contact
as
v_cnt integer;
begin
update admin_item set (REGSTR_STUS_ID, REGSTR_STUS_NM_DN) = 
(select s.stus_id, s.NCI_STUS
from sbr.ac_registrations ar, stus_mstr s where 
upper(ar.REGISTRATION_STATUS) = upper(s.stus_nm) and ar.ac_idseq = admin_item.nci_idseq
and ar.registration_status is not null);
commit;

--update admin_item set REGSTR_STUS_ID = 10, REGSTR_STUS_NM_DN = 'Historical' where REGSTR_STUS_ID is null; 
--commit;

update admin_item set (ORIGIN_ID, ORIGIN_ID_DN) = 
(Select obj_key_id, obj_key_desc from obj_key ok, sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and ac.origin = ok.obj_key_desc and ok.obj_typ_id = 18);
commit;

update admin_item set (ORIGIN) = 
(Select origin from sbr.administered_components ac where ac.public_id = admin_item.item_id 
and admin_item.ver_nr = ac.version and origin not in (select obj_key_desc from obj_key where obj_typ_id = 18));
commit;

insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY, CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, a.used_by, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai where an.cntxt_item_id = ai.item_id ) 
GROUP BY item_id, ver_nr) a,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+);
commit;


update perm_val set (PRNT_CNCPT_ITEM_ID, PRNT_CNCPT_VER_NR) = (
select 
public_id, version from sbr.administered_components ac, sbr.vd_pvs pvs, admin_item vd where pvs.pv_idseq = perm_val.nci_idseq and ac.ac_idseq = pvs.con_idseq and 
pvs.con_idseq is not null and vd.nci_idseq = pvs.vd_idseq and vd.item_id = perm_val.val_dom_item_id and vd.ver_nr = perm_val.val_dom_ver_nr)
where nci_idseq in (select pv_idseq from sbr.vd_pvs where con_idseq is not null);
commit;


insert into nci_entty(NCI_IDSEQ, ENTTY_TYP_ID,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select org_idseq, 72,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
 from sbr.organizations;
commit;

insert into nci_org (ENTTY_ID, RAI,ORG_NM,RA_IND,MAIL_ADDR,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
select e.ENTTY_ID, RAI,NAME,RA_IND,MAIL_ADDRESS,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
from sbr.organizations o, nci_entty e where e.nci_idseq = o.org_idseq;
commit;

insert into nci_entty(NCI_IDSEQ, ENTTY_TYP_ID,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select per_idseq, 73,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
 from sbr.persons;
commit;


insert into nci_prsn(ENTTY_ID,LAST_NM,FIRST_NM,RNK_ORD,PRNT_ORG_ID,MI,POS,
 CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select e.entty_id, LNAME,FNAME,RANK_ORDER,o.entty_id,MI,POSITION
,CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED,date_created)
 from sbr.persons p, nci_entty e, nci_entty o where e.entty_typ_id = 73 and o.entty_typ_id (+)= 72 and e.nci_idseq = p.per_idseq and p.org_idseq = o.nci_idseq (+)  ;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED, date_created),MODIFIED_BY
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED, date_created),MODIFIED_BY
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
per_IDSEQ is not null and c.per_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26 ;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED,date_created), MODIFIED_BY
from sbr.CONTACT_ADDRESSES c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = ATL_NAME and ok.obj_typ_id = 25;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
DATE_CREATED,CREATED_BY,nvl(DATE_MODIFIED,date_created), MODIFIED_BY
from sbr.CONTACT_ADDRESSES c, obj_key ok, nci_entty o where
PER_IDSEQ is not null and c.per_idseq = o.nci_idseq and ok.nci_cd = ATL_NAME and ok.obj_typ_id = 25;
commit;

update admin_item ai set submt_org_id = (select distinct entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.org_idseq and a.org_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 1)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where org_idseq is not null and rank_order = 1);
commit;


update admin_item ai set stewrd_org_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.org_idseq and a.org_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 2)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where org_idseq is not null and rank_order = 2);
commit;

update admin_item ai set submt_cntct_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.per_idseq and a.per_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 2)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where per_idseq is not null and rank_order = 2);
commit;


update admin_item ai set stewrd_cntct_id = (select entty_id from nci_entty e, sbr.ac_contacts a where e.nci_idseq = a.per_idseq and a.per_idseq is not null
and ai.nci_idseq = a.ac_idseq and rank_order = 1)
where nci_idseq in (select ac_idseq from sbr.ac_contacts where per_idseq is not null and rank_order = 1);
commit;

insert into ref_doc (NCI_REF_ID,FILE_NM,NCI_MIME_TYPE,NCI_DOC_SIZE,
NCI_CHARSET,NCI_DOC_LST_UPD_DT,BLOB_COL,
CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
select r.ref_id, rb.NAME,MIME_TYPE,DOC_SIZE,
DAD_CHARSET,LAST_UPDATED,BLOB_CONTENT,
CREATED_BY,DATE_CREATED,MODIFIED_BY,nvl(DATE_MODIFIED, date_created)
from ref r, sbr.reference_blobs rb where r.nci_idseq = rb.rd_idseq;
commit;


update admin_item set creat_usr_id_x = creat_usr_id, lst_upd_usr_id_x = lst_upd_usr_id;
commit;

end;
/
create or replace PROCEDURE            sp_create_form_question_rel
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_admin_item_rel_alt_key
          WHERE rel_typ_id = 63;

    COMMIT;

    INSERT /*+ APPEND */
           INTO nci_admin_item_rel_alt_key (P_ITEM_ID,
                                            P_ITEM_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            --CNTXT_ITEM_ID, CNTXT_VER_NR,
                                            REL_TYP_ID,
                                            NCI_PUB_ID,
                                            NCI_IDSEQ,
                                            NCI_VER_NR,
                                            EDIT_IND,
                                            REQ_IND,
                                            DEFLT_VAL,
                                            ITEM_LONG_NM)
        --DISP_LBL,
        --CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
        SELECT DISTINCT MOD.item_id,
                        MOD.ver_nr,
                        de.item_id,
                        de.ver_nr,
                        63,
                        QC_ID,
                        qc.QC_IDSEQ,
                        QC.VERSION,
                        DECODE (qa.editable_ind,  'Yes', 1,  'No', 0),
                        DECODE (qa.mandatory_ind,  'Yes', 1,  'No', 0),
                        qa.DEFAULT_VALUE,
                        LONG_NAME
          --, qc.DISPLAY_ORDER
          --, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
          FROM admin_item                   de,
               admin_item                   MOD,
               sbrext.quest_contents_ext    qc,
               sbrext.QUEST_ATTRIBUTES_EXT  qa
         WHERE     de.nci_idseq = qc.De_idseq
               AND MOD.nci_idseq = qc.p_mod_idseq
               AND qc.qtl_name = 'QUESTION'
               AND de.admin_item_typ_id = 4
               AND MOD.admin_item_typ_id = 52
               AND qc.de_idseq IS NOT NULL
               AND qc.qc_idseq = qa.qc_idseq(+);

    COMMIT;

    INSERT /*+ APPEND */
           INTO nci_admin_item_rel_alt_key (P_ITEM_ID,
                                            P_ITEM_VER_NR,
                              --              C_ITEM_ID,
                               --             C_ITEM_VER_NR,
                                            --CNTXT_ITEM_ID, CNTXT_VER_NR,
                                            REL_TYP_ID,
                                            NCI_PUB_ID,
                                            NCI_IDSEQ,
                                            NCI_VER_NR,
                                            EDIT_IND,
                                            REQ_IND,
                                            DEFLT_VAL,
                                            ITEM_LONG_NM)
        --DISP_LBL,
        --CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
        SELECT DISTINCT MOD.item_id,
                        MOD.ver_nr,
                    --    -10005,
                      --  1,
                        63,
                        QC_ID,
                        qc.QC_IDSEQ,
                        QC.VERSION,
                        DECODE (qa.editable_ind,  'Yes', 1,  'No', 0),
                        DECODE (qa.mandatory_ind,  'Yes', 1,  'No', 0),
                        qa.DEFAULT_VALUE,
                        LONG_NAME
          --, qc.DISPLAY_ORDER
          --, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
          FROM admin_item                   MOD,
               sbrext.quest_contents_ext    qc,
               sbrext.QUEST_ATTRIBUTES_EXT  qa
         WHERE     MOD.nci_idseq = qc.p_mod_idseq
               AND qc.qtl_name = 'QUESTION'
               AND MOD.admin_item_typ_id = 52
               AND qc.de_idseq IS NULL
               AND qc.qc_idseq = qa.qc_idseq(+);

    COMMIT;
END;
/
create or replace PROCEDURE            sp_create_ai_3
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM de;

    COMMIT;

    DELETE FROM value_dom;

    COMMIT;

    DELETE FROM de_conc;

    COMMIT;



    INSERT INTO de_conc (item_id,
                         ver_nr,
                         CONC_DOM_ITEM_ID,
                         CONC_DOM_VER_NR,
                         OBJ_CLS_ITEM_ID,
                         OBJ_CLS_VER_NR,
                         PROP_ITEM_ID,
                         PROP_VER_NR,
                         OBJ_CLS_QUAL,
                         PROP_QUAL,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.ITEM_ID,
               cd.VER_NR,
               oc.ITEM_ID,
               oc.VER_NR,
               prop.ITEM_ID,
               prop.VER_NR,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
               dec.created_by,
               dec.date_created,
               NVL (dec.date_modified, dec.date_created),
               dec.modified_by
          FROM sbr.data_element_concepts  dec,
               admin_item                 ai,
               admin_item                 oc,
               admin_item                 prop,
               admin_item                 cd
         WHERE     ai.NCI_IDSEQ = dec.dec_IDSEQ
               AND oc.admin_item_typ_id = 5
               AND prop.admin_item_typ_id = 6
               AND cd.admin_item_typ_id = 1
               AND dec.oc_idseq = oc.NCI_IDSEQ
               AND dec.prop_idseq = prop.NCI_IDSEQ
               AND dec.cd_idseq = cd.NCI_IDSEQ
               AND dec.oc_idseq IS NOT NULL
               AND dec.prop_idseq IS NOT NULL;

    COMMIT;



    INSERT INTO de_conc (item_id,
                         ver_nr,
                         CONC_DOM_ITEM_ID,
                         CONC_DOM_VER_NR,
                         OBJ_CLS_ITEM_ID,
                         OBJ_CLS_VER_NR,
                         PROP_ITEM_ID,
                         PROP_VER_NR,
                         OBJ_CLS_QUAL,
                         PROP_QUAL,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.ITEM_ID,
               cd.VER_NR,
               oc.ITEM_ID,
               oc.VER_NR,
               -20001,
               1,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
               dec.created_by,
               dec.date_created,
               NVL (dec.date_modified, dec.date_created),
               dec.modified_by
          FROM sbr.data_element_concepts  dec,
               admin_item                 ai,
               admin_item                 oc,
               admin_item                 cd
         WHERE     ai.NCI_IDSEQ = dec.dec_IDSEQ
               AND oc.admin_item_typ_id = 5
               AND cd.admin_item_typ_id = 1
               AND dec.oc_idseq = oc.NCI_IDSEQ
               AND dec.cd_idseq = cd.NCI_IDSEQ
               AND dec.oc_idseq IS NOT NULL
               AND dec.prop_idseq IS NULL;

    COMMIT;

    INSERT INTO de_conc (item_id,
                         ver_nr,
                         CONC_DOM_ITEM_ID,
                         CONC_DOM_VER_NR,
                         OBJ_CLS_ITEM_ID,
                         OBJ_CLS_VER_NR,
                         PROP_ITEM_ID,
                         PROP_VER_NR,
                         OBJ_CLS_QUAL,
                         PROP_QUAL,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.ITEM_ID,
               cd.VER_NR,
               -20000,
               1,
               prop.ITEM_ID,
               prop.VER_NR,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
               dec.created_by,
               dec.date_created,
               NVL (dec.date_modified, dec.date_created),
               dec.modified_by
          FROM sbr.data_element_concepts  dec,
               admin_item                 ai,
               admin_item                 prop,
               admin_item                 cd
         WHERE     ai.NCI_IDSEQ = dec.dec_IDSEQ
               AND prop.admin_item_typ_id = 6
               AND cd.admin_item_typ_id = 1
               AND dec.prop_idseq = prop.NCI_IDSEQ
               AND dec.cd_idseq = cd.NCI_IDSEQ
               AND dec.oc_idseq IS NULL
               AND dec.prop_idseq IS NOT NULL;

    COMMIT;

    INSERT INTO de_conc (item_id,
                         ver_nr,
                         CONC_DOM_ITEM_ID,
                         CONC_DOM_VER_NR,
                         OBJ_CLS_ITEM_ID,
                         OBJ_CLS_VER_NR,
                         PROP_ITEM_ID,
                         PROP_VER_NR,
                         OBJ_CLS_QUAL,
                         PROP_QUAL,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.ITEM_ID,
               cd.VER_NR,
               -20000,
               1,
               -20001,
               1,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
               dec.created_by,
               dec.date_created,
               NVL (dec.date_modified, dec.date_created),
               dec.modified_by
          FROM sbr.data_element_concepts dec, admin_item ai, admin_item cd
         WHERE     ai.NCI_IDSEQ = dec.dec_IDSEQ
               AND cd.admin_item_typ_id = 1
               AND dec.cd_idseq = cd.NCI_IDSEQ
               AND dec.oc_idseq IS NULL
               AND dec.prop_idseq IS NULL;

    COMMIT;


/*
    INSERT INTO admin_item (item_id,
                            ver_nr,
                            admin_item_typ_id,
                            item_nm,
                            ITEM_LONG_NM)
         VALUES (-20003,
                 1,
                 2,
                 'Unspecified DEC',
                 'Unspecified DEC');

    COMMIT;


    INSERT INTO de_conc (item_id,
                         ver_nr,
                         CONC_DOM_ITEM_ID,
                         CONC_DOM_VER_NR,
                         OBJ_CLS_ITEM_ID,
                         OBJ_CLS_VER_NR,
                         PROP_ITEM_ID,
                         PROP_VER_NR,
                         LST_UPD_DT)
        SELECT -20003, 1, -20002, 1, -20000, 1, -20001, 1, SYSDATE FROM DUAL;

    COMMIT;
*/

    INSERT INTO value_dom (item_id,
                           ver_nr,
                           CONC_DOM_ITEM_ID,
                           CONC_DOM_VER_NR,
                           NCI_DEC_PREC,
                           DTTYPE_ID,
                           VAL_DOM_FMT_ID,
                           UOM_ID,
                           VAL_DOM_HIGH_VAL_NUM,
                           VAL_DOM_LOW_VAL_NUM,
                           VAL_DOM_MAX_CHAR,
                           VAL_DOM_MIN_CHAR,
                           REP_CLS_ITEM_ID,
                           REP_CLS_VER_NR,
                           CREAT_USR_ID,
                           CREAT_DT,
                           LST_UPD_DT,
                           LST_UPD_USR_ID,
                           VAL_DOM_TYP_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.ITEM_ID,
               cd.VER_NR,
               vd.decimal_place,
               data_typ.DTTYPE_ID,
               fmt.fmt_id,
               uom.uom_id,
               vd.high_value_num,
               vd.low_value_num,
               vd.max_length_num,
               vd.min_length_num,
               rc.item_id,
               rc.ver_nr,
               vd.created_by,
               vd.date_created,
               NVL (vd.date_modified, vd.date_created),
               vd.modified_by,
               DECODE (VD_TYPE_FLAG,  'E', 17,  'N', 18)
          FROM sbr.value_domains  vd,
               admin_item         ai,
               admin_item         cd,
               admin_item         rc,
               uom,
               fmt,
               data_typ
         WHERE     ai.NCI_IDSEQ = vd.vd_IDSEQ
               AND cd.admin_item_typ_id = 1
               AND vd.cd_idseq = cd.NCI_IDSEQ
               AND vd.rep_idseq = rc.nci_idseq(+)
               AND vd.uoml_name = uom.nci_cd(+)
               AND vd.dtl_name = data_typ.nci_cd
               AND vd.forml_name = fmt.nci_cd(+);

    COMMIT;

    -- Update Standard data type based on mapping in OBJ_KEY table

    UPDATE value_dom v
       SET nci_std_dttype_id =
               (SELECT dt1.dttype_id
                  FROM data_typ dt, data_typ dt1
                 WHERE     dt.nci_dttype_map = dt1.dttype_nm
                       AND v.dttype_id = dt.dttype_id
                       AND dt.nci_dttype_typ_id = 1
                       AND dt1.nci_dttype_typ_id = 2);

    COMMIT;



    INSERT INTO de (item_id,
                    ver_nr,
                    DE_CONC_ITEM_ID,
                    DE_CONC_VER_NR,
                    VAL_DOM_ITEM_ID,
                    VAL_DOM_VER_NR,
                    CREAT_USR_ID,
                    CREAT_DT,
                    LST_UPD_DT,
                    LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               dec.ITEM_ID,
               dec.VER_NR,
               vd.ITEM_ID,
               vd.VER_NR,
               de.created_by,
               de.date_created,
               NVL (de.date_modified, de.date_created),
               de.modified_by
          FROM sbr.data_elements  de,
               admin_item         ai,
               admin_item         dec,
               admin_item         vd
         WHERE     ai.NCI_IDSEQ = de.de_IDSEQ
               AND dec.admin_item_typ_id = 2
               AND vd.admin_item_typ_id = 3
               AND de.dec_idseq = dec.NCI_IDSEQ
               AND de.vd_idseq = vd.nci_idseq;

    COMMIT;

    UPDATE de
       SET (DERV_MTHD,
            DERV_RUL,
            DERV_TYP_ID,
            CONCAT_CHAR,
            DERV_DE_IND) =
               (SELECT METHODS,
                       RULE,
                       o.obj_key_id,
                       cdr.CONCAT_CHAR,
                       1
                  FROM sbr.complex_data_elements  cdr,
                       obj_key                    o,
                       admin_item                 ai
                 WHERE     cdr.CRTL_NAME = o.nci_cd(+)
                       AND o.obj_typ_id(+) = 21
                       AND cdr.p_de_idseq = ai.nci_idseq
                       AND de.item_id = ai.item_id
                       AND de.ver_nr = ai.ver_nr);

    COMMIT;

/*
    UPDATE de
       SET PREF_QUEST_TXT = ( select name     FROM sbr.reference_documents  d,
                       obj_key                    ok,
                       admin_item                 ai
                 WHERE             d.dctl_name = ok.nci_cd
                           AND ok.obj_typ_id = 1
               and ok.obj_key_desc = 'Preferred Question Text'
            AND d.ac_idseq = ai.nci_idseq
                       AND de.item_id = ai.item_id
                       AND de.ver_nr = ai.ver_nr);

    COMMIT;
/*

    INSERT INTO admin_item (item_id,
                            ver_nr,
                            admin_item_typ_id,
                            item_nm,
                            ITEM_LONG_NM)
         VALUES (-20004,
                 1,
                 2,
                 'Unspecified VD',
                 'Unspecified VD');

    COMMIT;

    INSERT INTO admin_item (item_id,
                            ver_nr,
                            admin_item_typ_id,
                            item_nm,
                            ITEM_LONG_NM)
         VALUES (-20005,
                 1,
                 2,
                 'Unspecified DE',
                 'Unspecified DE');

    COMMIT;

    INSERT INTO value_dom (item_id,
                           ver_nr,
                           CONC_DOM_ITEM_ID,
                           CONC_DOM_VER_NR,
                           LST_UPD_DT)
        SELECT -20004, 1, -20002, 1, SYSDATE FROM DUAL;

    COMMIT;

    INSERT INTO de (item_id,
                    ver_nr,
                    VAL_DOM_ITEM_ID,
                    VAL_DOM_VER_NR,
                    DE_CONC_ITEM_ID,
                    DE_CONC_VER_NR,
                    LST_UPD_DT)
        SELECT -20005, 1, -20004, 1, -20003, 1, SYSDATE FROM DUAL;

    COMMIT;
*/

    DELETE FROM nci_admin_item_rel
          WHERE rel_typ_id = 65;

    COMMIT;


    INSERT INTO nci_admin_item_rel (P_ITEM_ID,
                                    P_ITEM_VER_NR,
                                    C_ITEM_ID,
                                    C_ITEM_VER_NR,
                                    --CNTXT_ITEM_ID, CNTXT_VER_NR,
                                    REL_TYP_ID,
                                    DISP_ORD,
                                    CREAT_USR_ID,
                                    CREAT_DT,
                                    LST_UPD_DT,
                                    LST_UPD_USR_ID)
        --DISP_LBL,
        --CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
        SELECT prnt.item_id,
               prnt.ver_nr,
               child.item_id,
               child.ver_nr,
               65,
               display_order,
               cdr.created_by,
               cdr.date_created,
               NVL (cdr.date_modified, cdr.date_created),
               cdr.modified_by
          --, qc.DISPLAY_ORDER
          --, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
          FROM admin_item                    prnt,
               admin_item                    child,
               sbr.complex_de_relationships  cdr
         WHERE     prnt.nci_idseq = cdr.p_de_idseq
               AND child.nci_idseq = cdr.c_de_idseq;

    COMMIT;
END;
/
create or replace PROCEDURE            sp_create_ai_1
AS
    v_cnt   INTEGER;
BEGIN
    -- Context creation
    DELETE FROM cntxt;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 8;

    COMMIT;

    -- Default version applied to context
    INSERT INTO admin_item (admin_item_typ_id,
                            NCI_iDSEQ,
                            ITEM_DESC,
                            ITEM_NM,
                            ITEM_LONG_NM,
                            VER_NR,
                            CNTXT_NM_DN,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT 8,
               TRIM (conte_idseq),
               description,
               name,
               name,
               version,
               name,
               created_by,
               date_created,
               NVL (date_modified, date_created),
               modified_by
          FROM sbr.contexts;

    COMMIT;

    -- Language is not used in context
    INSERT INTO cntxt (ITEM_ID,
                       VER_NR,
                       LANG_ID,
                       NCI_PRG_AREA_ID,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID)
        SELECT ai.ITEM_ID,
               ai.VER_NR,
               1000,
               ok.OBJ_KEY_ID,
               c.created_by,
               c.date_created,
               NVL (c.date_modified, c.date_created),
               c.modified_by
          FROM sbr.contexts c, admin_item ai, obj_key ok
         WHERE     TRIM (ai.NCI_IDSEQ) = TRIM (c.conte_idseq)
               AND TRIM (c.pal_name) = TRIM (ok.NCI_CD)
               AND ok.obj_typ_id = 14
               AND ai.admin_item_typ_id = 8;

    COMMIT;

    -- Conceptual Domain Creation
    DELETE FROM conc_dom;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 1;

    COMMIT;


    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                 --           UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.cd_idseq,
               1,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.cd_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by
          FROM sbr.conceptual_domains  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;

    INSERT INTO conc_dom (item_id,
                          ver_nr,
                          DIMNSNLTY,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.dimensionality,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbr.conceptual_domains cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.CD_IDSEQ;

    COMMIT;

    -- Object class and Property creation. Need to confirm the OC and Property specific attributes
    DELETE FROM obj_cls;

    COMMIT;

    DELETE FROM prop;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (5, 6);

    COMMIT;

    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.oc_idseq,
               5,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.oc_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM admin_item cntxt, stus_mstr s, sbrext.object_classes_ext ac
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.prop_idseq,
               6,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt_ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.prop_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM admin_item cntxt, stus_mstr s, sbrext.properties_ext ac
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO obj_cls (item_id,
                         ver_nr,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.object_classes_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.OC_IDSEQ;

    COMMIT;


    INSERT INTO prop (item_id,
                      ver_nr,
                      CREAT_USR_ID,
                      CREAT_DT,
                      LST_UPD_DT,
                      LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.properties_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.PROP_IDSEQ;

    COMMIT;

    -- Default OC and Property for DECs that do not have OC or Property
    INSERT INTO admin_item (item_id,
                            ver_nr,
                            nci_idseq,
                            admin_item_typ_id,
                            ITEM_LONG_NM,
                            ITEM_DESC,
                            ITEM_NM)
         VALUES (-20000,
                 1,
                 '1',
                 5,
                 'Default Object Class',
                 'Default Object Class',
                 'Default Object Class');

    COMMIT;

    INSERT INTO admin_item (item_id,
                            ver_nr,
                            nci_idseq,
                            admin_item_typ_id,
                            ITEM_LONG_NM,
                            ITEM_DESC,
                            ITEM_NM)
         VALUES (-20001,
                 1,
                 '2',
                 6,
                 'Default Property',
                 'Default Property',
                 'Default Property');

    COMMIT;

    INSERT INTO obj_cls (item_id, ver_nr)
         VALUES (-20000, 1);

    INSERT INTO prop (item_id, ver_nr)
         VALUES (-20001, 1);

    COMMIT;

    -- Classification Scheme and Representation Class creation
    DELETE FROM CLSFCTN_SCHM;

    COMMIT;

    DELETE FROM REP_CLS;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (7, 9);

    COMMIT;

    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                   --         UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.cs_idseq,
              9,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.cs_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by
          FROM sbr.classification_schemes  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;

    INSERT INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            --STEWRD_ORG_ID
                            --UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.rep_idseq,
               7,
               s.stus_id,
               s.nci_stus,
               ac.begin_date,
               ac.change_note,
               --conte_idseq,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               ac.end_date,
               DECODE (UPPER (ac.latest_version_ind),  'YES', 1,  'NO', 0),
               ac.preferred_name,
               ac.origin,
               ac.preferred_definition,
               ac.rep_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               ac.created_by,
               ac.date_created,
               NVL (ac.date_modified, ac.date_created),
               ac.modified_by,
               ac.definition_source
          FROM sbrext.representations_ext  ac,
               admin_item                   cntxt,
               stus_mstr                    s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;
               
    COMMIT;

    INSERT INTO clsfctn_schm (item_id,
                              ver_nr,
                              CLSFCTN_SCHM_TYP_ID,
                              NCI_LABEL_TYP_FLG,
                              CREAT_USR_ID,
                              CREAT_DT,
                              LST_UPD_DT,
                              LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               label_type_flag,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbr.classification_schemes cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.CS_IDSEQ
               AND TRIM (cstl_name) = ok.nci_cd
               AND ok.obj_typ_id = 3;

    COMMIT;



    INSERT INTO rep_cls (item_id,
                         ver_nr,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by
          FROM sbrext.representations_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.REP_IDSEQ;

    COMMIT;

/*
    INSERT INTO admin_item (item_id,
                            ver_nr,
                            admin_item_typ_id,
                            item_nm,
                            ITEM_LONG_NM,
                            ITEM_DESC)
         VALUES (-20002,
                 1,
                 5,
                 'Default CD',
                 'Default CD',
                 'Default CD');

    COMMIT;

    INSERT INTO conc_dom (item_id, ver_nr)
         VALUES (-20002, 1);

    COMMIT;
    
    */
END;
/
create or replace procedure sp_postprocess
as
v_cnt integer;
begin

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY, CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, a.used_by, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai, obj_key ok where an.cntxt_item_id = ai.item_id and an.cntxt_ver_nr = ai.ver_nr and an.NM_TYP_ID = ok.obj_key_id and ok.obj_typ_id = 11
and ok.nci_cd = 'USED_BY' and an.NM_DESC=ai.item_nm) 
GROUP BY item_id, ver_nr) a,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+);
commit;

update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm) = (select item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and 
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;
insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;

delete from vw_cntxt;
commit;
insert into vw_cntxt
  SELECT ADMIN_ITEM.ITEM_ID, ADMIN_ITEM.VER_NR, ADMIN_ITEM.ITEM_NM, ADMIN_ITEM.ITEM_LONG_NM, ADMIN_ITEM.ITEM_DESC,
ADMIN_ITEM.CNTXT_NM_DN, ADMIN_ITEM.CURRNT_VER_IND, ADMIN_ITEM.REGSTR_STUS_NM_DN, ADMIN_ITEM.ADMIN_STUS_NM_DN, ADMIN_ITEM.CREAT_DT, 
ADMIN_ITEM.CREAT_USR_ID, ADMIN_ITEM.LST_UPD_USR_ID, ADMIN_ITEM.FLD_DELETE, ADMIN_ITEM.LST_DEL_DT, ADMIN_ITEM.S2P_TRN_DT, 
ADMIN_ITEM.LST_UPD_DT, C.NCI_PRG_AREA_ID
FROM ADMIN_ITEM, CNTXT C
       WHERE ADMIN_ITEM_TYP_ID = 8 and ADMIN_ITEM.ITEM_ID = C.ITEM_ID and ADMIN_ITEM.VER_NR = C.VER_NR;
commit;
delete from onedata_ra.vw_cntxt;
commit;
insert into onedata_ra.vw_cntxt select * from vw_cntxt;
commit;
end;
/

create or replace procedure            sp_create_form_vv_inst_2
as
v_cnt integer;
begin

delete from nci_instr;
commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FORM_INSTR' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'FOOTER',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FOOTER' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'MODULE', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
qc.p_mod_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'QUESTION', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, nci_ver_nr, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF, NCI_TYP, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'VALUE',1, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition, 'INSTRUCTION',
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_QUEST_VALID_VALUE ai where qc.qtl_name = 'VALUE_INSTR' and
qc.p_val_idseq = ai.nci_idseq ;
commit;

/*
insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, QVV_VM_NM, QVV_VM_LNM, QVV_VALUE, QVV_CMNTS, QVV_EDIT_IND, QVV_SEQ_NBR)
select qc.qc_id, qc1.qc_id, qc.preferred_name, qc.preferred_definition 
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1
where qc.qtl_name = 'VALID_VALUE' and and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq;

*/

end;
/
create or replace PROCEDURE            sp_create_form_vv_inst
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM NCI_QUEST_VALID_VALUE;

    COMMIT;

    INSERT INTO NCI_QUEST_VALID_VALUE (NCI_PUB_ID,
                                       Q_PUB_ID,
                                       Q_VER_NR,
                                       VM_NM,
                                       VM_DEF,
                                       VALUE,
                                       NCI_IDSEQ,
                                       DESC_TXT,
                                       MEAN_TXT,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID)
        SELECT qc.qc_id,
               qc1.qc_id,
               qc1.VERSION,
               qc.preferred_name,
               qc.preferred_definition,
               qc.long_name,
               qc.qc_idseq,
               vv.description_text,
               vv.meaning_text,
               qc.created_by,
               qc.date_created,
               NVL (qc.date_modified, qc.date_created),
               qc.modified_by
          FROM sbrext.quest_contents_ext    qc,
               sbrext.quest_contents_ext    qc1,
               sbrext.valid_values_att_ext  vv
         WHERE     qc.qtl_name = 'VALID_VALUE'
               AND qc1.qtl_name = 'QUESTION'
               AND qc1.qc_idseq = qc.p_qst_idseq
               AND qc.qc_idseq = vv.qc_idseq(+);

    COMMIT;

    DELETE FROM NCI_QUEST_VV_REP;

    COMMIT;

    INSERT INTO NCI_QUEST_VV_REP (QUEST_PUB_ID,
                                  QUEST_VER_NR,
                                  VV_PUB_ID,
                                  VV_VER_NR,
                                  VAL,
                                  EDIT_IND,
                                  REP_SEQ,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT q.NCI_PUB_ID,
               q.NCI_VER_NR,
               vv.NCI_PUB_ID,
               vv.NCI_VER_NR,
               qvv.VALUE,
               DECODE (editable_ind,  'Yes', 1,  'No', 0),
               repeat_sequence,
               qvv.created_by,
               qvv.date_created,
               NVL (qvv.date_modified, qvv.date_created),
               qvv.modified_by
          FROM sbrext.quest_vv_ext         qvv,
               NCI_ADMIN_ITEM_REL_ALT_KEY  q,
               NCI_QUEST_VALID_VALUE       vv
         WHERE     qvv.quest_idseq = q.NCI_IDSEQ
               AND qvv.vv_idseq = vv.NCI_IDSEQ(+);

    COMMIT;
END;
/
create or replace PROCEDURE            sp_create_form_ext
AS
    v_cnt   INTEGER;
BEGIN
    -- Create AI for TEmplate, Form, Protocol, Module



    DELETE FROM nci_form;

    COMMIT;

    DELETE FROM nci_protcl;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (50,
                                      52,
                                      54,
                                      55);

    COMMIT;


    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT qc.qc_idseq,
               54,
               s.stus_id,
               s.nci_STUS,
               qc.begin_date,
               qc.change_note,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               qc.end_date,
               DECODE (UPPER (qc.latest_version_ind),  'YES', 1,  'NO', 0),
               qc.preferred_name,
               qc.origin,
               qc.preferred_definition,
               qc.qc_id,
               NVL (qc.long_name, qc.preferred_name),
               ac.unresolved_issue,
               qc.version,
               qc.created_by,
               qc.date_created,
               NVL (qc.date_modified, qc.date_created),
               qc.modified_by
          FROM sbr.administered_components  ac,
               admin_item                   cntxt,
               stus_mstr                    s,
               sbrext.quest_contents_ext    qc
         WHERE     qc.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND ac.actl_name = 'QUEST_CONTENT'
               AND   cntxt.admin_item_typ_id = 8
               AND ac.ac_idseq = qc.qc_idseq
               AND qc.qtl_name IN ('TEMPLATE', 'CRF');

    COMMIT;

    DELETE FROM nci_form;

    COMMIT;


    INSERT INTO nci_form (item_id,
                          ver_nr,
                          catgry_id,
                          form_typ_id,
                          CREAT_USR_ID,
                          CREAT_DT,
                          LST_UPD_DT,
                          LST_UPD_USR_ID)
        SELECT qc_id,
               version,
               ok.obj_key_id,
               DECODE (qc.qtl_name,  'CRF', 70,  'TEMPLATE', 71),
               created_by,
               date_created,
               NVL (date_modified, date_created),
               modified_by
          FROM sbrext.quest_contents_ext qc, obj_key ok
         WHERE     qc.qcdl_name = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 22
               AND qc.qtl_name IN ('TEMPLATE', 'CRF');

    COMMIT;

INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_NM,
                            ITEM_ID,
                            UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT qc.qc_idseq,
               52,
               s.stus_id,
               s.NCI_STUS,
               qc.begin_date,
               qc.change_note,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               qc.end_date,
               DECODE (UPPER (qc.latest_version_ind),  'YES', 1,  'NO', 0),
               qc.preferred_name,
               qc.origin,
               qc.preferred_definition,
               substr(NVL (qc.long_name, qc.preferred_name),1,255),
               qc.qc_id,
               ac.unresolved_issue,
               qc.version,
               qc.created_by,
               qc.date_created,
               NVL (qc.date_modified, qc.date_created),
               qc.modified_by
          FROM sbr.administered_components  ac,
               admin_item                   cntxt,
               stus_mstr                    s,
               sbrext.quest_contents_ext    qc
         WHERE     qc.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND ac.actl_name = 'QUEST_CONTENT'
               AND cntxt.admin_item_typ_id = 8
               AND ac.ac_idseq = qc.qc_idseq
               AND qc.qtl_name = 'MODULE';


    COMMIT;

    INSERT /*+ APPEND */
           INTO admin_item (NCI_IDSEQ,
                            ADMIN_ITEM_TYP_ID,
                            ADMIN_STUS_ID,
                            ADMIN_STUS_NM_DN,
                            EFF_DT,
                            CHNG_DESC_TXT,
                            CNTXT_ITEM_ID,
                            CNTXT_VER_NR,
                            CNTXT_NM_DN,
                            UNTL_DT,
                            CURRNT_VER_IND,
                            ITEM_LONG_NM,
                            ORIGIN,
                            ITEM_DESC,
                            ITEM_ID,
                            ITEM_NM,
                            UNRSLVD_ISSUE,
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT p.proto_IDSEQ,
               50,
               s.stus_id,
               s.nci_stus,
               p.begin_date,
               p.change_note,
               cntxt.item_id,
               cntxt.ver_nr,
               cntxt.item_nm,
               p.end_date,
               DECODE (UPPER (p.latest_version_ind),  'YES', 1,  'NO', 0),
               p.preferred_name,
               p.origin,
               p.preferred_definition,
               p.proto_id,
               NVL (p.long_name, p.preferred_name),
               ac.unresolved_issue,
               p.version,
               p.created_by,
               p.date_created,
               NVL (p.date_modified, p.date_created),
               p.modified_by
          FROM sbr.administered_components ac, admin_item cntxt,
               stus_mstr s      ,sbrext.protocols_ext p
         WHERE     p.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND ac.actl_name = 'PROTOCOL'
               AND p.proto_IDSEQ = ac.ac_idseq
               AND cntxt.admin_item_typ_id = 8;


    COMMIT;


    INSERT INTO nci_protcl (item_id,
                            ver_nr,
                            PROTCL_TYP_ID,
                            PROTCL_ID,
                            LEAD_ORG,
                            PROTCL_PHASE,
                            creat_usr_id,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            CHNG_TYP,
                            CHNG_NBR,
                            RVWD_DT,
                            RVWD_USR_ID,
                            APPRVD_DT,
                            APPRVD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               protocol_id,
               LEAD_ORG,
               PHASE,
               cd.created_by,
               cd.date_created,
               NVL (cd.date_modified, cd.date_created),
               cd.modified_by,
               CHANGE_TYPE,
               CHANGE_NUMBER,
               REVIEWED_DATE,
               REVIEWED_BY,
               APPROVED_DATE,
               APPROVED_BY
          FROM sbrext.protocols_ext cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.proto_IDSEQ
               AND TRIM (TYPE) = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 19
               AND ai.admin_item_typ_id = 50;

    COMMIT;
END;
/

create or replace PROCEDURE            sp_create_form_rel
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_admin_item_rel
          WHERE rel_typ_id IN (61, 60);

    COMMIT;


    -- new table for Protocol-form relationship
    -- Do not add audit columns

    INSERT INTO nci_admin_item_rel (P_ITEM_ID,
                                    P_ITEM_VER_NR,
                                    C_ITEM_ID,
                                    C_ITEM_VER_NR,
                                    --CNTXT_ITEM_ID, CNTXT_VER_NR,
                                    REL_TYP_ID)
        SELECT DISTINCT pro.item_id,
                        pro.ver_nr,
                        frm.item_id,
                        frm.ver_nr,
                        60
          --, qc.DISPLAY_ORDER
          FROM admin_item pro, admin_item frm, sbrext.protocol_qc_ext qc
         WHERE     pro.nci_idseq = qc.proto_idseq
               AND frm.nci_idseq = qc.qc_idseq
               AND pro.admin_item_typ_id = 50
               AND frm.admin_item_typ_id = 54;

    COMMIT;

    -- Form-module relationship
    INSERT INTO nci_admin_item_rel (P_ITEM_ID,
                                    P_ITEM_VER_NR,
                                    C_ITEM_ID,
                                    C_ITEM_VER_NR,
                                    --CNTXT_ITEM_ID, CNTXT_VER_NR,
                                    REL_TYP_ID,
                                    DISP_ORD,
                                    REP_NO,
                                    --DISP_LBL,
                                    CREAT_DT,
                                    CREAT_USR_ID,
                                    LST_UPD_USR_ID,
                                    LST_UPD_DT)
        SELECT DISTINCT frm.item_id,
                        frm.ver_nr,
                        MOD.item_id,
                        MOD.ver_nr,
                        61,
                        qc.DISPLAY_ORDER,
                        qc.REPEAT_NO,
                        qc.DATE_CREATED,
                        qc.CREATED_BY,
                        NVL (qc.MODIFIED_BY, qc.date_created),
                        DATE_MODIFIED
          FROM admin_item MOD, admin_item frm, sbrext.quest_contents_ext qc
         WHERE     MOD.nci_idseq = qc.qc_idseq
               AND frm.nci_idseq = qc.dn_crf_idseq
               AND qc.qtl_name = 'MODULE'
               AND MOD.admin_item_typ_id = 52
               AND frm.admin_item_typ_id = 54;

    COMMIT;
END;
/
create or replace procedure            sp_create_form_vv_inst_2
as
v_cnt integer;
begin

delete from nci_instr;
commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FORM_INSTR' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'FOOTER',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FOOTER' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'MODULE', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
qc.p_mod_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'QUESTION', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, nci_ver_nr, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF, NCI_TYP, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'VALUE',1, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition, 'INSTRUCTION',
qc.created_by, qc.date_created,
nvl(qc.date_modified, qc.date_created), qc.modified_by
from sbrext.quest_contents_ext qc, Nci_QUEST_VALID_VALUE ai where qc.qtl_name = 'VALUE_INSTR' and
qc.p_val_idseq = ai.nci_idseq ;
commit;

/*
insert into NCI_QUEST_VALID_VALUE
(NCI_PUB_ID, Q_PUB_ID, QVV_VM_NM, QVV_VM_LNM, QVV_VALUE, QVV_CMNTS, QVV_EDIT_IND, QVV_SEQ_NBR)
select qc.qc_id, qc1.qc_id, qc.preferred_name, qc.preferred_definition 
from  sbrext.quest_contents_ext qc, sbrext.quest_contents_ext qc1
where qc.qtl_name = 'VALID_VALUE' and and qc1.qtl_name = 'QUESTION' and qc1.qc_idseq = qc.p_qst_idseq;

*/

end;
/
 
                                                      create or replace procedure spNCICompareDE (v_data_in in clob, v_data_out out clob)
as

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;
row_cur t_row;

v_admin_item                admin_item%rowtype;
v_tab_admin_item            tab_admin_item_pk;

v_found      boolean;


v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

type      t_admin_item_nm is table of admin_item.item_nm%type;
v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

v_val_mean_desc    val_mean.val_mean_desc%type;
v_perm_val_nm    perm_val.perm_val_nm%type;
v_item_id		 number;
v_ver_nr		 number;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;

rows := t_rows();


    for i in 1 .. hookInput.originalRowset.Rowset.count loop
row := t_row();
    row_cur := hookInput.originalRowset.Rowset(i);
    ihook.setColumnValue(row,'ITEM_ID', ihook.getColumnValue(row_cur,'ITEM_ID'));
    ihook.setColumnValue(row,'VER_NR', ihook.getColumnValue(row_cur,'VER_NR'));  
    rows.extend; rows(rows.last) := row;

 end loop;

    showRowset := t_showableRowset(rows, 'NCI Data Element Details (for Compare)',2, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'Data Element Compare';

    v_data_out := ihook.getHookOutput(hookOutput);

end;
/                                                      
                                                     


