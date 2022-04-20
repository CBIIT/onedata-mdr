CREATE OR REPLACE PACKAGE nci_caDSR_push AS
 procedure spPushLov (vHours in Integer);
  procedure spPushAIChildren (vHours in integer);
  procedure spPushAISpecific (vHours in integer);
  procedure sp_create_csi (vHours in integer);
  function getShortDef(v_def in varchar2) return varchar;
  function getLongName(v_nm in varchar2) return varchar;
  procedure spRevInitiate (vHours in Integer, v_usr_id in varchar2);
  procedure spRevGetHours ( v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
  procedure spPushInitial;
END;
/

CREATE OR REPLACE PACKAGE body nci_caDSR_push AS


 function getShortDef(v_def in varchar2) return varchar
 is
 begin
    if length(v_def) > 2000 then
        return substr(v_def,1,1996) || ' ...';
    else
        return v_def;
    end if;
 end;


function getLongName(v_nm in varchar2) return varchar
 is
 begin
    if length(v_nm) > 255 then
        return substr(v_nm,1,250) || ' ...';
    else
        return v_nm;
    end if;
 end;

 procedure spPushInitial
 as
 v_cnt integer;
 begin

 nci_cadsr_push_core.spPushAIType(500, 9);

 insert into sbr.concepts_ext (con_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,con_id, evs_source,definition_source,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, ai.def_src,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID
        from admin_item ai, admin_item c, cncpt con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.evs_src_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq not in (select con_idseq from sbrext.concepts_ext);
commit;
insert into sbr.administered_components (ac_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id, version,
            created_by, date_created,date_modified, modified_by, actl_name, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID,  ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID, 'CONCEPT', decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.admin_item_typ_id = 49
            and ai.nci_idseq not in (select ac_idseq from sbr.administered_components);
    commit;

insert into sbr.cs_items (csi_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,csi_id, csitl_name, description, comments,version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, csi_desc_txt, csi_cmnts,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, NCI_CLSFCTN_SCHM_ITEM con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.csi_typ_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq not in (select csi_idseq from sbr.cs_items);
commit;


insert into sbr.administered_components (ac_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id, version,
            created_by, date_created,date_modified, modified_by, actl_name, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID,  ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID, 'CS_ITEM', decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.admin_item_typ_id = 51
            and ai.nci_idseq not in (select ac_idseq from sbr.administered_components);
    commit;

-- Alternate names - Synonyms
insert into sbr.designations (DEsig_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME)
select ad.nci_idseq, ai.nci_idseq,  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_nms ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id
and   ad.ver_nr = ai.ver_nr
and   ad.cntxt_item_id = c.item_id
and   ad.cntxt_ver_nr = c.ver_nr
and nvl(ad.fld_delete, 0) = 0
and   ad.nm_typ_id = ok.obj_key_id (+)
and   ad.nci_idseq not in (select desig_idseq from sbr.designations);
commit;

-- Reference Documents - Preferred question text
insert into sbr.reference_documents (RD_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text,URL)
select ad.nci_idseq, ai.nci_idseq,  ad.ref_nm, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
from ref ad, admin_item ai, admin_item c, obj_key ok
where  ad.item_id = ai.item_id
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id
    and   ai.cntxt_ver_nr = c.ver_nr
    and nvl(ad.fld_delete, 0) = 0
and   ad.ref_typ_id = ok.obj_key_id (+)
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_documents);

commit;

-- Reorder module

-- CSI update


update sbr.cs_csi cscsi set csi_idseq = (Select  nci_idseq from admin_item ai, nci_clsfctn_schm_item csi where ai.item_id = csi.item_id
and ai.ver_nr = csi.ver_nr and csi.cs_csi_idseq = cscsi.cs_csi_idseq)
where (cs_csi_idseq, csi_idseq) not in 
(Select cs_csi_idseq, nci_idseq from admin_item ai, nci_clsfctn_schm_item csi where ai.item_id = csi.item_id
and ai.ver_nr = csi.ver_nr);
commit;


insert into  sbr.cs_csi (CS_CSI_IDSEQ, CS_IDSEQ,csi_idseq, P_CS_CSI_IDSEQ,  DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LABEL)
select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq, nvl(pcsi.cs_csi_idseq, pcsiai.nci_idseq) p_cs_csi_idseq,
csi.creat_dt, csi.lst_upd_dt, csi.creat_usr_id, csi.lst_upd_usr_id, '1'
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs, admin_item pcsiai, nci_clsfctn_schm_item pcsi where
 csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and csi.p_item_id = pcsiai.item_id and csi.p_item_ver_nr = pcsiai.ver_nr and csi.p_item_id = pcsi.item_id and csi.p_item_ver_nr = pcsi.ver_nr
and csi.p_item_id is not null and csi.item_id = csiai.item_id and csi.ver_nr = csiai.ver_nr 
and nvl(csi.cs_csi_idseq, csiai.nci_idseq) not in (Select cs_csi_idseq from sbr.cs_csi);

commit;

insert into  sbr.cs_csi (CS_CSI_IDSEQ, CS_IDSEQ, csi_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LABEL)
select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq,
csi.creat_dt, csi.creat_usr_id, csi.lst_upd_dt, csi.lst_upd_usr_id, 1
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs where
 csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
 and csi.item_id = csiai.item_id and csi.ver_nr = csiai.ver_nr
and csi.p_item_id is null  and nvl(csi.cs_csi_idseq, csiai.nci_idseq) not in (Select cs_csi_idseq from sbr.cs_csi);

commit;
-- Module name

-- Ref blobs

-- Registration Status


 end;


 procedure spRevGetHours ( v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
 as

 hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    forms t_forms;
    form1 t_form;
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;

    rows  t_rows;
     question t_question;
  answer t_answer;
  answers t_answers;

 begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

    if (hookinput.invocationnumber = 0) then -- show create form
        rows := t_rows();
        row := t_row();

         ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Start');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Please specify hours.', ANSWERS);
HOOKOUTPUT.QUESTION    := question;
  forms                  := t_forms();
    form1                  := t_form('Reverse Hours (Hook)', 2,1);
    forms.extend;    forms(forms.last) := form1;

           hookOutput.forms := forms;

    else --- Second invocation
         forms              := hookInput.forms;

           form1              := forms(1);
      row := form1.rowset.rowset(1);
      spRevInitiate(ihook.getColumnValue(row,'ITEM_ID'), v_usr_id);
      end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);     
end;

 procedure spPushLov (vHours in Integer)
as
v_cnt integer;
begin

v_cnt := 1;

---- Registration Status


update sbr.reg_status_lov set (description, comments, display_order, date_modified, modified_by) =
    (select stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id
    from stus_mstr
    where stus_typ_id = 1
    and   lst_upd_dt >=  sysdate - vHours/24
    and   upper(nci_stus) =upper(registration_status))
where upper(registration_status) in (select upper(nci_stus) from stus_mstr
    where stus_typ_id =1
    and   lst_upd_dt >=  sysdate - vHours/24 );


insert into sbr.reg_status_lov (registration_status,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR
from stus_mstr
where stus_typ_id = 1
and   upper(nci_stus) not in (select upper(registration_status) from sbr.reg_status_lov)
and   creat_dt >= sysdate - vHours/24;

--- Administrative Status

update sbr.ac_status_lov set (description, comments, display_order, date_modified, modified_by) =
    (select  stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id from stus_mstr
    where stus_typ_id = 2
    and   lst_upd_dt >=  sysdate - vHours/24
    and   upper(nci_stus)= upper(asl_name))
where upper(asl_name) in
    (select upper(nci_stus) from stus_mstr
    where stus_typ_id =2
    and   lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.ac_status_lov (asl_name,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR
from stus_mstr
where stus_typ_id = 2
and upper(nci_stus) not in (select upper(asl_name) from sbr.ac_status_lov)
and creat_dt >= sysdate - vHours/24;
commit;


--- Program Area

update sbr.PROGRAM_AREAS_LOV  set (description, comments, date_modified, modified_by) =
    (select  obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 14
    and   lst_upd_dt >= sysdate - vHours/24
    and   upper(nci_cd) = upper(pal_name))
where upper(pal_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 14
    and   lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.PROGRAM_AREAS_LOV( pal_name, description, comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 14
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(pal_name) from sbr.PROGRAM_AREAS_LOV);


--- Name/Designation Type

update sbr.DESIGNATION_TYPES_LOV set (description,comments, date_modified, modified_by) =
    (select obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 11
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(detl_name) = upper(nci_cd))
where upper(detl_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 11
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.DESIGNATION_TYPES_LOV (detl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 11
and creat_dt > sysdate - vHours/24
and upper(nci_cd) not in (select upper(detl_name) from sbr.DESIGNATION_TYPES_LOV);

-- DOcument type - Type ID 1

update sbr.document_TYPES_LOV set ( description,comments, date_modified, modified_by) =
    (select  obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 1
    and lst_upd_dt > sysdate - vHours/24
    and upper(dctl_name) = upper(nci_cd))
    where upper(dctl_name) in
        (select upper(nci_cd)
        from obj_key
        where obj_typ_id = 1
        and   lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.document_TYPES_LOV (dctl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 1
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(dctl_name) from sbr.document_TYPES_LOV);


-- Classification Scheme Type - Type Id 3

update sbr.CS_TYPES_LOV set ( description,comments, date_modified, modified_by) =
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 3
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(CSTL_NAME) = upper(nci_cd))
    where upper(cstl_name) in
        (select upper(nci_cd)
        from obj_key
        where obj_typ_id = 3
        and   lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.CS_TYPES_LOV (CSTL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 3
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(cstl_name) from sbr.CS_TYPES_LOV);


-- Classification Scheme Item Type - Type ID 20

update sbr.CSI_TYPES_LOV set (description,comments, date_modified, modified_by) =
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 20
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(CSITL_NAME) = upper(nci_cd))
where upper(csitl_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 20
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.CSI_TYPES_LOV (CSITL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 20
and creat_dt > sysdate - vHours/24
and upper(nci_cd) not in (select upper(csitl_name) from sbr.CSI_TYPES_LOV);


-- Concept Source - Type ID 23

update sbrext.concept_sources_lov_ext set (description, date_modified, modified_by) =
    (select obj_key_def,  LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 23
    and lst_upd_dt > sysdate - vHours/24
    and upper(CONCEPT_SOURCE) = upper(nci_cd))
where upper(concept_source) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 23
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbrext.concept_sources_lov_ext (CONCEPT_SOURCE, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 23
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(CONCEPT_SOURCE) from sbrext.concept_sources_lov_ext);


-- NCI Derivation Type - Type 21

update sbr.complex_rep_type_lov set (description, date_modified, modified_by) =
    (select obj_key_def, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 21
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(CRTL_NAME) = upper(nci_cd))
where upper(crtl_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 21
    and   lst_upd_dt >=  sysdate - vHours/24 );


insert into sbr.complex_rep_type_lov (CRTL_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 21
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(CRTL_NAME) from sbr.complex_rep_type_lov);


--- Data type

update sbr.datatypes_lov set (DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION) =
    (select DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN
    from data_typ
    where lst_upd_Dt >= sysdate - vHours/24
    and   nci_dttype_typ_id = 1
    and   upper(dtl_name) = upper(NCI_CD))
where upper(dtl_name) in
    (select upper(nci_cd)
    from data_typ
    where nci_dttype_typ_id=1
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.datatypes_lov (dtl_name, DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION)
select  NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN
from data_typ
where lst_upd_Dt >= sysdate - vHours/24
and   nci_dttype_typ_id = 1
and   upper(nci_cd) not in (select upper(dtl_name) from sbr.datatypes_lov);


/*insert into data_typ ( DTTYPE_NM, NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DTTYPE_SCHM_REF, DTTYPE_ANNTTN)
select DTL_NAME, DTL_NAME, DESCRIPTION,COMMENTS,
created_by, date_created,date_modified, modified_by,
SCHEME_REFERENCE, ANNOTATION from sbr.datatypes_lov;
*/
-- Format


insert into sbr.formats_lov (FORML_NAME,DESCRIPTION,COMMENTS, created_by, date_created,date_modified, modified_by)
select NCI_CD,FMT_DESC,FMT_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from fmt
where creat_dt >= sysdate - vHours/24
and upper(nci_cd) not in (select upper(forml_name) from sbr.formats_lov);

/*insert into FMT ( FMT_NM, NCI_CD,FMT_DESC,FMT_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select FORML_NAME, FORML_NAME,DESCRIPTION,COMMENTS,
created_by, date_created,date_modified, modified_by from sbr.formats_lov;
*/

-- UOM

insert into sbr.unit_of_measures_lov (UOML_NAME,PRECISION, DESCRIPTION,COMMENTS, created_by, date_created,date_modified, modified_by)
select NCI_CD, UOM_PREC,UOM_DESC,UOM_CMNTS, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from UOM
where creat_dt >= sysdate - vHours/24
and upper(NCI_CD) not in (select upper(UOML_NAME) from sbr.unit_of_measures_lov);


-- Definition type - type id 15

update sbrext.definition_types_lov_ext set (DEFL_NAME, description,comments, date_modified, modified_by) =
    (select nci_cd, obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 15
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(DEFL_NAME) = upper(nci_cd))
where upper(defl_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 15
    and   lst_upd_dt >=  sysdate - vHours/24 );



insert into sbrext.definition_types_lov_ext (DEFL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 15
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(DEFL_NAME) from sbrext.definition_types_lov_ext);


/*insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 15, DEFL_NAME, description, DEFL_NAME, comments, created_by, date_created,
                    date_modified, modified_by from sbrext.definition_types_lov_ext;
*/

-- Origin - Type id 18

update sbrext.sources_ext set (SRC_NAME, description, date_modified, modified_by) =
    (select nci_cd, obj_key_def, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 18
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(SRC_NAME) = upper(nci_cd))
where upper(src_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 18
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbrext.sources_ext (SRC_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 18
and creat_dt > sysdate - vHours/24
and upper(nci_cd) not in (select upper(SRC_NAME) from sbrext.sources_ext);


/*insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select 18, SRC_NAME, description, SRC_NAME,  created_by, date_created,
                    date_modified, modified_by from sbrext.sources_ext;

*/


-- Form Category - Type id 22

update sbrext.QC_DISPLAY_LOV_EXT set (QCDL_NAME, description, date_modified, modified_by) =
    (select nci_cd, obj_key_def, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 22
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(QCDL_NAME) = upper(nci_cd))
where upper(qcdl_name) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 22
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbrext.QC_DISPLAY_LOV_EXT (QCDL_NAME, description, created_by, date_created, date_modified, modified_by, display_order)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, 1
from obj_key
where obj_typ_id = 22
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(QCDL_NAME) from sbrext.QC_DISPLAY_LOV_EXT);
commit;


-- Address Type id 25

update sbr.ADDR_TYPES_LOV set (ATL_NAME, description, comments, date_modified, modified_by) =
    (select nci_cd, obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 25
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(ATL_NAME) = upper(nci_cd))
where upper(ATL_NAME) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 25
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.COMM_TYPES_LOV (CTL_NAME, description, comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 25
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(CTL_NAME) from sbr.COMM_TYPES_LOV);
commit;

-- Communication Type id 26

update sbr.COMM_TYPES_LOV set (CTL_NAME, description, comments, date_modified, modified_by) =
    (select nci_cd, obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key
    where obj_typ_id = 26
    and   lst_upd_dt > sysdate - vHours/24
    and   upper(CTL_NAME) = upper(nci_cd))
where upper(CTL_NAME) in
    (select upper(nci_cd)
    from obj_key
    where obj_typ_id = 26
    and lst_upd_dt >=  sysdate - vHours/24 );

insert into sbr.COMM_TYPES_LOV (CTL_NAME, description, comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID
from obj_key
where obj_typ_id = 26
and   creat_dt > sysdate - vHours/24
and   upper(nci_cd) not in (select upper(CTL_NAME) from  sbr.COMM_TYPES_LOV);
commit;

-- Language - added 2/16/2022

insert into sbr.LANGUAGES_LOV (NAME,DATE_CREATED,DATE_MODIFIED,MODIFIED_BY,CREATED_BY,DESCRIPTION)
select LANG_NM,CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,CREAT_USR_ID, LANG_DESC from LANG
where upper(lang_nm) not in (select upper(name) from sbr.LANGUAGES_LOV);
commit;


end;

 procedure spPushAIChildren (vHours in integer)
as
v_cnt integer;
begin

--  Definitions
insert into sbr.definitions (DEFIN_IDSEQ, AC_IDSEQ, DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME)
select ad.nci_idseq, ai.nci_idseq,  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_def ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id
and   ad.ver_nr = ai.ver_nr
and   ad.cntxt_item_id = c.item_id
and   ad.cntxt_ver_nr = c.ver_nr
and nvl(ad.fld_delete,0) = 0
and   ad.nci_def_typ_id = ok.obj_key_id (+)
and   ad.nci_idseq not in (select defin_idseq from sbr.definitions)
and   ad.lst_upd_dt >= sysdate - vHours/24;

for cur in (select nci_idseq from alt_def where lst_upd_dt > creat_dt and lst_upd_dt >= sysdate - vHours/24 and  nvl(fld_delete,0) = 0 and nci_idseq in (select defin_idseq from sbr.definitions)) loop
update sbr.definitions d set (DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME) =
    (select  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_def ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id
    and   ad.ver_nr = ai.ver_nr
    and   ad.cntxt_item_id = c.item_id
    and   ad.cntxt_ver_nr = c.ver_nr
    and   ad.nci_def_typ_id = ok.obj_key_id (+)
    and   ad.nci_idseq = cur.nci_idseq)
where d.defin_idseq = cur.nci_idseq;
end loop;

for cur in (select nci_idseq from alt_def where lst_upd_dt > creat_dt and lst_upd_dt >= sysdate - vHours/24 and  nvl(fld_delete,0) = 1 and nci_idseq in (select defin_idseq from sbr.definitions)) loop
delete from sbr.definitions where  defin_idseq = cur.nci_idseq;
end loop;

commit;

-- Designations
insert into sbr.designations (DEsig_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME)
select ad.nci_idseq, ai.nci_idseq,  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_nms ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id
and   ad.ver_nr = ai.ver_nr
and   ad.cntxt_item_id = c.item_id
and   ad.cntxt_ver_nr = c.ver_nr
and nvl(ad.fld_delete, 0) = 0
and   ad.nm_typ_id = ok.obj_key_id (+)
and   ad.nci_idseq not in (select desig_idseq from sbr.designations)
and   ad.lst_upd_dt >= sysdate - vHours/24;

for cur in (select nci_idseq from alt_nms where lst_upd_dt > creat_dt and lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete, 0) = 0 and nci_idseq in (select desig_idseq from sbr.designations)) loop
update sbr.designations d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME) =
    (select  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_nms ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id
    and   ad.ver_nr = ai.ver_nr
    and   ad.cntxt_item_id = c.item_id
    and   ad.cntxt_ver_nr = c.ver_nr
    and   ad.nm_typ_id = ok.obj_key_id (+)
    and   ad.nci_idseq = cur.nci_idseq)
where d.desig_idseq = cur.nci_idseq;
end loop;


for cur in (select nci_idseq from alt_nms where lst_upd_dt > creat_dt and lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete, 0) = 1 and nci_idseq in (select desig_idseq from sbr.designations)) loop
delete from sbr.designations d where d.desig_idseq = cur.nci_idseq;
end loop;
commit;

-- Reference Documents
insert into sbr.reference_documents (RD_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text,URL)
select ad.nci_idseq, ai.nci_idseq,  ad.ref_nm, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
from ref ad, admin_item ai, admin_item c, obj_key ok
where  ad.item_id = ai.item_id
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id
    and   ai.cntxt_ver_nr = c.ver_nr
    and nvl(ad.fld_delete, 0) = 0
and   ad.ref_typ_id = ok.obj_key_id (+)
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_documents)
and   ad.lst_upd_dt >= sysdate - vHours/24;


for cur in (select nci_idseq from ref where lst_upd_dt > creat_dt and  lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete, 0) = 0 and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
update sbr.reference_documents d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text, url) =
    (select  ref_nm, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
    from ref ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id
    and   ai.cntxt_ver_nr = c.ver_nr
    and   ad.ref_typ_id = ok.obj_key_id (+)
    and   ad.nci_idseq = cur.nci_idseq)
where d.rd_idseq = cur.nci_idseq;
end loop;


for cur in (select r.nci_idseq from ref r, ref_doc rd where   rd.lst_upd_dt >= sysdate - vHours/24 and nvl(rd.fld_delete, 0) = 1 and r.nci_idseq in (select rd_idseq from sbr.reference_blobs)
and r.ref_id = rd.nci_ref_id) loop
delete from sbr.reference_blobs where rd_idseq = cur.nci_idseq;
end loop;

for cur in (select nci_idseq from ref where lst_upd_dt > creat_dt and  lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete, 0) = 1 and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
delete from sbr.reference_blobs where rd_idseq = cur.nci_idseq;
delete from sbr.reference_documents d  where d.rd_idseq = cur.nci_idseq;
end loop;

commit;

-- Classifications
insert into sbr.ac_csi (ac_csi_idseq, CS_CSI_IDSEQ, AC_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select nci_11179.cmr_guid, nvl(csi.cs_csi_idseq, csiai.nci_idseq),ai.nci_idseq , ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID
from nci_admin_item_rel ad, admin_item csiai, nci_clsfctn_schm_item csi, admin_item ai
where  ad.p_item_id = csiai.item_id
    and   ad.p_item_ver_nr = csiai.ver_nr
    and   csiai.item_id = csi.item_id
    and   csiai.ver_nr = csi.ver_nr
    and nvl(ad.fld_delete, 0) = 0
and   ad.rel_typ_id = 65
and ad.c_item_id = ai.item_id
and ad.c_item_ver_nr = ai.ver_nr
and   (nvl(csi.cs_csi_idseq, csiai.nci_idseq),ai.nci_idseq)  not in (select cs_csi_idseq, ac_idseq from sbr.ac_csi)
and   ad.lst_upd_dt >= sysdate - vHours/24;

-- no update for classifications. only insert and delete.
for cur in (select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq,ai.nci_idseq
from nci_admin_item_rel ad, admin_item csiai, nci_clsfctn_schm_item csi, admin_item ai
where  ad.p_item_id = csiai.item_id
    and   ad.p_item_ver_nr = csiai.ver_nr
    and   csiai.item_id = csi.item_id
    and   csiai.ver_nr = csi.ver_nr
    and nvl(ad.fld_delete, 0) = 1
and   ad.rel_typ_id = 65
and ad.c_item_id = ai.item_id
and ad.lst_upd_dt > ad.creat_dt
and ad.c_item_ver_nr = ai.ver_nr
and   (nvl(csi.cs_csi_idseq, csiai.nci_idseq),ai.nci_idseq)  in (select cs_csi_idseq, ac_idseq from sbr.ac_csi)
and   ad.lst_upd_dt >= sysdate - vHours/24) loop
delete from sbr.ac_csi where cs_csi_idseq = cur.cs_csi_idseq and ac_idseq = cur.nci_idseq;
end loop;
commit;

-- Alt names classification

for cur in (select  nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, am.nci_idseq att_idseq, nvl(x.fld_delete,0) fld_delete, x.creat_dt, x.lst_upd_dt, x.creat_usr_id, 
x.lst_upd_usr_id
from alt_nms am, admin_item csiai, nci_clsfctn_schm_item csi, NCI_CSI_ALT_DEFNMS  x
where x.typ_nm = 'DESIGNATION'
and x.lst_upd_dt >= sysdate - vHours/24
and x.nci_pub_id = csiai.item_id
and x.nci_ver_nr = csiai.ver_nr
and csiai.item_id = csi.item_id
and csiai.ver_nr = csi.ver_nr
and am.nm_id = x.nmdef_id) loop

insert into sbrext.AC_ATT_CSCSI_EXT (aca_idseq, cs_csi_idseq, att_idseq,atl_name, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
(select nci_11179.cmr_guid, cur.cs_csi_idseq, cur.att_idseq, 'DESIGNATION', cur.CREAT_DT, cur.CREAT_USR_ID, cur.LST_UPD_DT,cur.LST_UPD_USR_ID
from dual where cur.fld_delete = 0 and 
 (cur.cs_csi_idseq, cur.att_idseq) not in (select cs_csi_idseq, att_idseq from sbrext.AC_ATT_CSCSI_EXT));
commit;

-- Delete

delete from sbrext.AC_ATT_CSCSI_EXT e where 
( cs_csi_idseq, att_idseq ) in 
(select  cur.cs_csi_idseq, cur.att_idseq from dual where cur.fld_delete = 1);
commit;
end loop;
-- Alt def classification

for cur in (
select  nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, am.nci_idseq att_idseq, nvl(x.fld_delete,0) fld_delete,x.creat_dt, x.lst_upd_dt, x.creat_usr_id, 
x.lst_upd_usr_id
from alt_def am, admin_item csiai, nci_clsfctn_schm_item csi, NCI_CSI_ALT_DEFNMS  x
where x.typ_nm = 'DEFINITION'
and x.lst_upd_dt >= sysdate - vHours/24
and x.nci_pub_id = csiai.item_id
and x.nci_ver_nr = csiai.ver_nr
and csiai.item_id = csi.item_id
and csiai.ver_nr = csi.ver_nr
and am.def_id = x.nmdef_id) loop

insert into sbrext.AC_ATT_CSCSI_EXT (aca_idseq, cs_csi_idseq, att_idseq, atl_name, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
(select nci_11179.cmr_guid, cur.cs_csi_idseq, cur.att_idseq , 'DEFINITION', cur.CREAT_DT, cur.CREAT_USR_ID, cur.LST_UPD_DT,cur.LST_UPD_USR_ID from dual
where cur.fld_Delete = 0 and (cur.cs_csi_idseq, cur.att_idseq) not in (select cs_csi_idseq, att_idseq from sbrext.AC_ATT_CSCSI_EXT));
commit;

-- Delete

delete from sbrext.AC_ATT_CSCSI_EXT e where 
( cs_csi_idseq, att_idseq ) in 
(select  cur.cs_csi_idseq, cur.att_idseq from dual where cur.fld_delete = 1);
commit;
end loop;

-- Reference Blobs

insert into sbr.reference_blobs (RD_IDSEQ, NAME, DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select ad.nci_idseq, file_nm, nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, rd.CREAT_DT, rd.CREAT_USR_ID, rd.LST_UPD_DT,rd.LST_UPD_USR_ID
from ref ad, ref_doc rd
where ad.ref_id = rd.nci_ref_id
and   rd.file_nm not in (select name from sbr.reference_blobs)
and nvl(rd.fld_delete,0) = 0
and rd.lst_upd_dt >= sysdate - 1/24;
commit;

for cur in (select r.nci_idseq, file_nm from ref_doc rd, ref r where rd.lst_upd_dt > rd.creat_dt and rd.lst_upd_dt >= sysdate - vHours/24 and r.ref_id = rd.nci_ref_id and 
r.nci_idseq in (select rd_idseq from sbr.reference_documents) and nvl(rd.fld_Delete,0) = 0) loop
update sbr.reference_blobs d set( DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT,DATE_MODIFIED, MODIFIED_BY) =
    (select  nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, rd.LST_UPD_DT,rd.LST_UPD_USR_ID
    from ref ad, ref_doc rd where
     ad.ref_id = rd.nci_ref_id
    and   ad.nci_idseq = cur.nci_idseq
    and rd.file_nm = cur.file_nm
    )
    where d.name = cur.file_nm ;
end loop;

commit;


-- DE Derivation Components

for cur in (select * from nci_admin_item_rel where rel_typ_id = 66 and lst_upd_dt >= sysdate - vHours/24) loop

for curdtl in (Select p.nci_idseq p_de_idseq, c.nci_idseq c_de_idseq from admin_item p, admin_item c where p.item_id = cur.p_item_id and p.ver_nr = cur.p_item_ver_nr
and c.item_id = cur.c_item_id and c.ver_nr = cur.c_item_ver_nr) loop

select count(*) into v_cnt from sbr.complex_de_relationships where p_de_idseq = curdtl.p_de_idseq and c_de_idseq = curdtl.c_de_idseq;

if (v_cnt = 0 and nvl(cur.fld_delete,0) = 0) then  -- Insert
insert into sbr.complex_de_relationships (cdr_idseq, p_de_idseq, c_de_idseq, DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY,DATE_CREATED, CREATED_BY )
select nci_11179.cmr_guid(), curdtl.p_de_idseq, curdtl.c_de_idseq, cur.disp_ord, cur.lst_upd_dt, cur.lst_upd_usr_id, cur.creat_dt, cur.creat_usr_id from dual;
end if;
if (v_cnt = 1 and nvl(cur.fld_delete,0) = 0) then -- Update
update sbr.complex_de_relationships set ( DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY ) = 
(select  cur.disp_ord, cur.lst_upd_dt, cur.lst_upd_usr_id from dual)
where p_de_idseq = curdtl.p_de_idseq and c_de_idseq = curdtl.c_de_idseq;
end if;
if (v_cnt = 1 and nvl(cur.fld_delete,0) = 1) then -- Delete
delete from sbr.complex_de_relationships 
where p_de_idseq = curdtl.p_de_idseq and c_de_idseq = curdtl.c_de_idseq;
end if;
commit;

end loop;
end loop;


-- update sbr.complex_de_relationships  set (display_order  ,date_modified, modified_by) = (select disp_ord,

/*
Protocol Form Relationshio
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
    */

    /*
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
*/
end;


procedure spRevInitiate (vHours in Integer, v_usr_id in varchar2)
as
v_batch number;
v_log_id number;
v_cmp_log_id number;
begin

select nvl(max(log_id),0) into v_log_id from nci_job_log where end_dt is not null;
select nvl(max(log_id),0) into v_cmp_log_id from nci_job_log where end_dt is null;

if (v_log_id = v_cmp_log_id or v_cmp_log_id = 0) then
select od_seq_nci_job_Log.nextval    into v_batch  from  dual ; 

insert into nci_job_log (log_id,start_dt, job_step_desc, run_param, exec_by)
select v_batch, sysdate, 'Job started.', vHours, v_usr_id from dual;
commit;

nci_cadsr_push.spPushLov(vHours);

update nci_job_log set job_step_desc = 'Step 1: LOV Migration completed. ' where log_id = v_batch;
commit;

insert into sbr.concepts_ext (con_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,con_id, evs_source,definition_source,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, ai.def_src,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID
        from admin_item ai, admin_item c, cncpt con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.evs_src_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq not in (select con_idseq from sbrext.concepts_ext);
commit;
insert into sbr.administered_components (ac_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id, version,
            created_by, date_created,date_modified, modified_by, actl_name, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID,  ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID, 'CONCEPT', decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.admin_item_typ_id = 49
            and ai.nci_idseq not in (select ac_idseq from sbr.administered_components);
    commit;
--nci_cadsr_push_core.spPushAIType(100, 49);
nci_cadsr_push_core.spPushContext (vHours );
nci_cadsr_push_core.spPushAI(vHours);

update nci_job_log set job_step_desc = 'Step 2: AI Migration completed. ' where log_id = v_batch;
commit;

nci_cadsr_push_form.PushModule(vHours);

commit;



nci_cadsr_push_form.PushQuestion(vHours);

nci_cadsr_push_form.PushQuestValidValue(vHours);
--nci_cadsr_push_form.DeleteFormHierarchy(vHours);

update nci_job_log set job_step_desc = 'Step 3: Form Migration completed. ' where log_id = v_batch;
commit;

nci_cadsr_push.spPushAISpecific(vHours);
nci_cadsr_push.spPushAIChildren(vHours);

update nci_job_log set job_step_desc = 'Step 4: Common Children Migration completed. ' where log_id = v_batch;
commit;

nci_cadsr_push_core.spPushFormDelete (vHours);

update nci_job_log set job_step_desc = 'Job Completed', end_dt = sysdate where log_id = v_batch;
commit;
end if;
end;

procedure spPushAISpecific (vHours in integer)
as
v_temp integer;
v_nci_idseq char(36);
v_vd_idseq char(36);
v_pv_idseq char(36);
begin

--- CD-VM relationship


insert into sbr.cd_vms (cv_idseq, CD_IDSEQ, VM_IDSEQ,  SHORT_MEANING, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)  --- Check what needs to go into short-meaning
select nci_11179.cmr_guid, cd.nci_idseq, vm.nci_idseq, vm.item_long_nm, cdvm.CREAT_DT,cdvm.CREAT_USR_ID,  cdvm.LST_UPD_DT,cdvm.LST_UPD_USR_ID
from conc_dom_val_mean cdvm, admin_item cd, admin_item vm
where cdvm.conc_dom_item_id = cd.item_id
and   cdvm.conc_dom_ver_nr = cd.ver_nr
and   cdvm.nci_val_mean_item_id = vm.item_id and cdvm.nci_val_mean_ver_nr = vm.ver_nr
and   (cd.nci_idseq, vm.nci_idseq) not in (select cd_idseq, vm_idseq from sbr.cd_vms)
and   cdvm.lst_upd_dt >= sysdate - vHours/24;
commit;

-- Permissible Values




insert into sbr.permissible_Values(pv_idseq,  BEGIN_DATE, END_DATE, VALUE, SHORT_MEANING, vm_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select nci_11179.cmr_guid, min(PERM_VAL_BEG_DT), max(PERM_VAL_END_DT), PERM_VAL_NM, max(vm.item_nm), vm.nci_idseq, min(pv.CREAT_DT),min(pv.CREAT_USR_ID),min(pv.LST_UPD_DT),min(pv.LST_UPD_USR_ID)
from perm_val pv, admin_item vm
where pv.nci_val_mean_item_id = vm.item_id
and   pv.nci_val_mean_ver_nr = vm.ver_nr
and   pv.lst_upd_dt >= sysdate - vHours/24
and nvl(pv.fld_delete,0) = 0
and   (perm_val_nm, vm.nci_idseq) not in (select value, vm_idseq  from sbr.permissible_Values)
group by perm_val_nm, vm.nci_idseq;
commit;




for cur in (select * from perm_val where  lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete,0) = 0) loop
select pv_idseq into v_pv_idseq from admin_item ai, sbr.permissible_values pv where ai.item_id = cur.nci_val_mean_item_id and ai.ver_nr = cur.nci_val_mean_ver_nr
and ai.nci_idseq = pv.vm_idseq and pv.value = cur.perm_val_nm;
select nci_idseq into v_vd_idseq from admin_item where item_id = cur.val_dom_item_id and ver_nr = cur.val_dom_ver_nr;

--select count(*) into v_temp from sbr.vd_pvs where pv_idseq = v_pv_idseq and vd_idseq = v_vd_idseq;
select count(*) into v_temp from sbr.vd_pvs where vp_idseq = cur.nci_idseq;

--or (vd_idseq, pv_idseq) in (select v_vd_idseq, v_pv_idseq from dual) ;

if (v_temp = 0) then
insert into sbr.vd_pvs (vp_idseq, BEGIN_DATE, END_DATE, pv_idseq, vd_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select cur.nci_idseq, cur.PERM_VAL_BEG_DT, cur.PERM_VAL_END_DT, v_pv_idseq, v_vd_idseq, cur.CREAT_DT, cur.CREAT_USR_ID, cur.LST_UPD_DT,cur.LST_UPD_USR_ID from dual;
commit;
if (cur.nci_origin_id is not null) then
insert into sbrext.vd_pvs_sources_ext (VPS_IDSEQ,VP_IDSEQ,SRC_NAME,DATE_CREATED,CREATED_BY)
select nci_11179.cmr_guid, cur.nci_idseq, ok.obj_key_desc, cur.creat_dt, cur.creat_usr_id from obj_key ok where ok.obj_key_id = cur.nci_origin_id  ;
end if;
commit;
elsif v_temp = 1 then
update sbr.vd_pvs set (BEGIN_DATE, END_DATE, pv_idseq, DATE_MODIFIED, MODIFIED_BY)  =  (select cur.PERM_VAL_BEG_DT, cur.PERM_VAL_END_DT, v_pv_idseq,cur.LST_UPD_DT,cur.LST_UPD_USR_ID from dual )
where vp_idseq = cur.nci_idseq;
if (cur.nci_origin_id is not null) then
select count(*) into v_temp from sbrext.vd_pvs_sources_ext where vp_idseq = cur.nci_idseq;
if (v_temp = 0) then
insert into sbrext.vd_pvs_sources_ext (VPS_IDSEQ,VP_IDSEQ,SRC_NAME,DATE_CREATED,CREATED_BY)
select nci_11179.cmr_guid, cur.nci_idseq, ok.obj_key_desc, cur.creat_dt, cur.creat_usr_id from obj_key ok where ok.obj_key_id = cur.nci_origin_id  ;
else
update sbrext.vd_pvs_sources_ext set src_name = (select obj_key_desc from obj_key where obj_key_id = cur.nci_origin_id)
where vp_idseq = cur.nci_idseq;
commit;
end if;


end if;

end if;
end loop;
commit;

-- Deleted PV/VM
for cur in (select * from perm_val where  lst_upd_dt >= sysdate - vHours/24 and nvl(fld_delete,0) = 1) loop
select pv_idseq into v_pv_idseq from admin_item ai, sbr.permissible_values pv where ai.item_id = cur.nci_val_mean_item_id and ai.ver_nr = cur.nci_val_mean_ver_nr
and ai.nci_idseq = pv.vm_idseq and pv.value = cur.perm_val_nm;
select nci_idseq into v_vd_idseq from admin_item where item_id = cur.val_dom_item_id and ver_nr = cur.val_dom_ver_nr;

delete from sbrext.VD_PVS_SOURCES_EXT where vp_idseq = cur.nci_idseq;
commit;

delete from sbr.vd_pvs where vp_idseq = cur.nci_idseq;
commit;
end loop;
commit;
end;

procedure sp_create_csi (vHours in integer)
as
v_cnt integer;
begin

-- Classification Scheme Items

update sbr.cs_csi set (cs_idseq, cs_csi_idseq, p_cs_csi_idseq, date_created,created_by,date_modified, modified_by, display_order, label) =
    (select cs.nci_idseq, csi.nci_idseq, pcsi.nci_idseq, rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID, disp_ord, disp_lbl
    from admin_item cs, admin_item csi, admin_item pcsi, nci_admin_item_rel_alt_key rel
    where rel.lst_upd_dt >= sysdate - vHours/24
    and   rel.cntxt_cs_item_id = cs.item_id
    and   cntxt_cs_ver_nr = cs.ver_nr
    and   rel.c_item_ver_nr = csi.ver_nr
    and   rel.c_item_id = csi.item_id
    and   rel.p_item_ver_nr = pcsi.ver_nr (+)
    and   rel.p_item_id = pcsi.item_id (+)
    and   rel.rel_typ_id = 64
    and   rel.nci_idseq in (select CS_CSI_IDSEQ from sbr.cs_csi));

insert into sbr.cs_csi (cs_idseq, cs_csi_idseq, p_cs_csi_idseq, date_created,created_by,date_modified, modified_by, display_order, label)
    select cs.nci_idseq, csi.nci_idseq, pcsi.nci_idseq, rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID, disp_ord, disp_lbl
    from admin_item cs, admin_item csi, admin_item pcsi, nci_admin_item_rel_alt_key rel
    where rel.lst_upd_dt >= sysdate - vHours/24
    and   rel.cntxt_cs_item_id = cs.item_id
    and   cntxt_cs_ver_nr = cs.ver_nr
    and   rel.c_item_ver_nr = csi.ver_nr
    and   rel.c_item_id = csi.item_id
    and   rel.p_item_ver_nr = pcsi.ver_nr (+)
    and   rel.p_item_id = pcsi.item_id (+)
    and   rel.rel_typ_id = 64
    and   rel.nci_idseq not in (select CS_CSI_IDSEQ from sbr.cs_csi);
commit;

-- Classification Scheme Items

update sbr.ac_csi set (CS_CSI_IDSEQ,  AC_IDSEQ,  date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, ai.nci_idseq , rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    from nci_alt_key_admin_item_rel rel, nci_admin_item_rel_alt_key csi, admin_item ai
    where rel.lst_upd_dt >= sysdate - vHours/24
    and   rel.c_item_id = ai.item_id
    and   rel.c_item_ver_nr = ai.ver_nr
    and   rel.nci_pub_id = csi.nci_pub_id
    and   rel.nci_ver_nr = csi.nci_ver_nr
    and   rel.rel_typ_id = 65
    and   (csi.nci_idseq, ai.nci_idseq) in (select cs_csi_idseq, ac_idseq from sbr.ac_csi));

insert into sbr.ac_csi (ac_csi_idseq, CS_CSI_IDSEQ,  AC_IDSEQ,  date_created,created_by,date_modified, modified_by)
    select nci_11179.cmr_guid, csi.nci_idseq, ai.nci_idseq , rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    from nci_alt_key_admin_item_rel rel, nci_admin_item_rel_alt_key csi, admin_item ai
    where rel.lst_upd_dt >= sysdate - vHours/24
    and   rel.c_item_id = ai.item_id
    and   rel.c_item_ver_nr = ai.ver_nr
    and   rel.nci_pub_id = csi.nci_pub_id
    and   rel.nci_ver_nr = csi.nci_ver_nr
    and   rel.rel_typ_id = 65
    and   (csi.nci_idseq, ai.nci_idseq) not in (select cs_csi_idseq, ac_idseq from sbr.ac_csi);
commit;

-- Classification Scheme Items - Alternate Designations

update sbrext.AC_ATT_CSCSI_EXT set (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, an.nci_idseq, 'DESIGNATION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_nms an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id
    and   csi.nci_ver_nr = csian.nci_ver_nr
    and   an.nm_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vHours/24
    and   (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));


insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DESIGNATION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_nms an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id
    and   csi.nci_ver_nr = csian.nci_ver_nr
    and   an.nm_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vHours/24
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;

-- Classification Scheme Items - Alternate Definitions

update sbrext.AC_ATT_CSCSI_EXT set (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id
    and csi.nci_ver_nr = csian.nci_ver_nr
    and an.def_id = nmdef_id
    and csian.lst_upd_dt >= sysdate - vHours/24
    and (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));

insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id
    and   csi.nci_ver_nr = csian.nci_ver_nr
    and   an.def_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vHours/24
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;

end;

END;
/
