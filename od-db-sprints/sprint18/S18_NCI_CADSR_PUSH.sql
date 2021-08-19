create or replace PACKAGE nci_caDSR_push AS
 procedure sp_migrate_lov (vDays in Integer);
  procedure sp_create_ai_children (vDays in integer);
  procedure sp_create_pv (vDays in integer);
  procedure sp_create_csi (vDays in integer);
END;
/
create or replace PACKAGE body nci_caDSR_push AS


 procedure sp_migrate_lov (vDays in Integer)
as
v_cnt integer;
begin

v_cnt := 1;

---- Registration Status


update sbr.reg_status_lov set (description, comments, display_order, date_modified, modified_by) = 
    (select stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id 
    from stus_mstr 
    where stus_typ_id = 1 
    and   lst_upd_dt >=  sysdate - vDays 
    and   upper(nci_stus) =upper(registration_status))
where upper(registration_status) in (select upper(nci_stus) from stus_mstr 
    where stus_typ_id =1 
    and   lst_upd_dt >=  sysdate - vDays );


insert into sbr.reg_status_lov (registration_status,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR 
from stus_mstr 
where stus_typ_id = 1 
and   upper(nci_stus) not in (select upper(registration_status) from sbr.reg_status_lov) 
and   creat_dt >= sysdate - vDays;

--- Administrative Status

update sbr.ac_status_lov set (description, comments, display_order, date_modified, modified_by) = 
    (select  stus_Desc, nci_cmnts, nci_disp_ordr, lst_upd_dt, lst_upd_usr_id from stus_mstr 
    where stus_typ_id = 1 
    and   lst_upd_dt >=  sysdate - vDays 
    and   upper(nci_stus)= upper(asl_name))
where upper(asl_name) in 
    (select upper(nci_stus) from stus_mstr 
    where stus_typ_id =2 
    and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.ac_status_lov (asl_name,description, comments,created_by, date_created, date_modified, modified_by, display_order)
select nci_stus, stus_desc, nci_cmnts,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, NCI_DISP_ORDR 
from stus_mstr 
where stus_typ_id = 2 
and upper(nci_stus) not in (select upper(asl_name) from sbr.ac_status_lov) 
and creat_dt >= sysdate - vDays;
commit;


--- Program Area 

update sbr.PROGRAM_AREAS_LOV  set (description, comments, date_modified, modified_by) = 
    (select  obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID
    from obj_key 
    where obj_typ_id = 14 
    and   lst_upd_dt >= sysdate - vDays 
    and   upper(nci_cd) = upper(pal_name))
where upper(pal_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 14 
    and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.PROGRAM_AREAS_LOV( pal_name, description, comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 14 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(pal_name) from sbr.PROGRAM_AREAS_LOV);


--- Name/Designation Type

update sbr.DESIGNATION_TYPES_LOV set (description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 11 
    and   lst_upd_dt > sysdate - vdays 
    and   upper(detl_name) = upper(nci_cd))
where upper(detl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 11 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.DESIGNATION_TYPES_LOV (detl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 11 
and creat_dt > sysdate - vdays 
and upper(nci_cd) not in (select upper(detl_name) from sbr.DESIGNATION_TYPES_LOV);

-- DOcument type - Type ID 1

update sbr.document_TYPES_LOV set ( description,comments, date_modified, modified_by) = 
    (select  obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 1 
    and lst_upd_dt > sysdate - vdays
    and upper(dctl_name) = upper(nci_cd))
    where upper(dctl_name) in 
        (select upper(nci_cd) 
        from obj_key 
        where obj_typ_id = 1 
        and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.document_TYPES_LOV (dctl_name, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 1 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(dctl_name) from sbr.document_TYPES_LOV);


-- Classification Scheme Type - Type Id 3

update sbr.CS_TYPES_LOV set ( description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 3 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CSTL_NAME) = upper(nci_cd))
    where upper(cstl_name) in 
        (select upper(nci_cd) 
        from obj_key 
        where obj_typ_id = 3 
        and   lst_upd_dt >=  sysdate - vDays );

insert into sbr.CS_TYPES_LOV (CSTL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 3 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(cstl_name) from sbr.CS_TYPES_LOV);


-- Classification Scheme Item Type - Type ID 20

update sbr.CSI_TYPES_LOV set (description,comments, date_modified, modified_by) = 
    (select obj_key_def, obj_key_cmnts,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 20 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CSITL_NAME) = upper(nci_cd))
where upper(csitl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 20 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.CSI_TYPES_LOV (CSITL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 20 
and creat_dt > sysdate - vdays 
and upper(nci_cd) not in (select upper(csitl_name) from sbr.CSI_TYPES_LOV);


-- Concept Source - Type ID 23

update sbrext.concept_sources_lov_ext set (description, date_modified, modified_by) = 
    (select obj_key_def,  LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 23 
    and lst_upd_dt > sysdate - vdays
    and upper(CONCEPT_SOURCE) = upper(nci_cd))
where upper(concept_source) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 23 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.concept_sources_lov_ext (CONCEPT_SOURCE, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 23 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(CONCEPT_SOURCE) from sbrext.concept_sources_lov_ext);


-- NCI Derivation Type - Type 21

update sbr.complex_rep_type_lov set (description, date_modified, modified_by) = 
    (select obj_key_def, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 21 
    and   lst_upd_dt > sysdate - vdays
    and   upper(CRTL_NAME) = upper(nci_cd))
where upper(crtl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 21 
    and   lst_upd_dt >=  sysdate - vDays );


insert into sbr.complex_rep_type_lov (CRTL_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 21 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(CRTL_NAME) from sbr.complex_rep_type_lov);


--- Data type

update sbr.datatypes_lov set (DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION) = 
    (select DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN 
    from data_typ 
    where lst_upd_Dt >= sysdate - vDays
    and   nci_dttype_typ_id = 1
    and   upper(dtl_name) = upper(NCI_CD))
where upper(dtl_name) in 
    (select upper(nci_cd) 
    from data_typ 
    where nci_dttype_typ_id=1 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbr.datatypes_lov (dtl_name, DESCRIPTION,COMMENTS, date_modified, modified_by, SCHEME_REFERENCE, ANNOTATION) 
select  NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS, LST_UPD_DT,LST_UPD_USR_ID, DTTYPE_SCHM_REF, DTTYPE_ANNTTN 
from data_typ 
where lst_upd_Dt >= sysdate - vDays
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
where creat_dt >= sysdate - vDays 
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
where creat_dt >= sysdate - vDays 
and upper(NCI_CD) not in (select upper(UOML_NAME) from sbr.unit_of_measures_lov);


-- Definition type - type id 15

update sbrext.definition_types_lov_ext set (DEFL_NAME, description,comments, date_modified, modified_by) = 
    (select nci_cd, obj_key_def, obj_key_cmnts, LST_UPD_DT,LST_UPD_USR_ID 
    from obj_key 
    where obj_typ_id = 15 
    and   lst_upd_dt > sysdate - vdays
    and   upper(DEFL_NAME) = upper(nci_cd))
where upper(defl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 15 
    and   lst_upd_dt >=  sysdate - vDays );



insert into sbrext.definition_types_lov_ext (DEFL_NAME, description,comments, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 15 
and   creat_dt > sysdate - vdays 
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
    and   lst_upd_dt > sysdate - vdays
    and   upper(SRC_NAME) = upper(nci_cd))
where upper(src_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 18 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.sources_ext (SRC_NAME, description, created_by, date_created, date_modified, modified_by)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID 
from obj_key 
where obj_typ_id = 18 
and creat_dt > sysdate - vdays 
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
    and   lst_upd_dt > sysdate - vdays
    and   upper(QCDL_NAME) = upper(nci_cd))
where upper(qcdl_name) in 
    (select upper(nci_cd) 
    from obj_key 
    where obj_typ_id = 22 
    and lst_upd_dt >=  sysdate - vDays );

insert into sbrext.QC_DISPLAY_LOV_EXT (QCDL_NAME, description, created_by, date_created, date_modified, modified_by, display_order)
select nci_cd, obj_key_def, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, 1 
from obj_key 
where obj_typ_id = 22 
and   creat_dt > sysdate - vdays 
and   upper(nci_cd) not in (select upper(QCDL_NAME) from sbrext.QC_DISPLAY_LOV_EXT);
commit;


end;

 procedure sp_create_ai_children (vDays in integer)
as
v_cnt integer;
begin

--  Definitions
insert into sbr.definitions (DEFIN_IDSEQ, AC_IDSEQ, DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME)
select ad.nci_idseq, ai.nci_idseq,  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_def ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.nci_def_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select defin_idseq from sbr.definitions)
and   ad.lst_upd_dt >= sysdate - vDays;

for cur in (select nci_idseq from alt_def where lst_upd_dt >= sysdate - vDays and nci_idseq in (select defin_idseq from sbr.definitions)) loop
update sbr.definitions d set (DEFINITION, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DEFL_NAME) =
    (select  def_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_def ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.nci_def_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.defin_idseq = cur.nci_idseq;
end loop; 
commit;

-- Designations
insert into sbr.designations (DEsig_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME)
select ad.nci_idseq, ai.nci_idseq,  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
from alt_nms ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.nm_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select desig_idseq from sbr.designations)
and   ad.lst_upd_dt >= sysdate - vDays;

for cur in (select nci_idseq from alt_nms where lst_upd_dt >= sysdate - vDays and nci_idseq in (select desig_idseq from sbr.designations)) loop
update sbr.designations d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DETL_NAME) =
    (select  nm_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd
    from alt_nms ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.nm_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.desig_idseq = cur.nci_idseq;
end loop;
commit;

-- Reference Documents
insert into sbr.reference_documents (RD_IDSEQ, AC_IDSEQ, NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text,URL)
select ad.nci_idseq, ai.nci_idseq,  ref_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
from ref ad, admin_item ai, admin_item c, obj_key ok
where ad.item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.ref_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_documents)
and   ad.lst_upd_dt >= sysdate - vDays;


for cur in (select nci_idseq from ref where lst_upd_dt >= sysdate - vDays and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
update sbr.reference_documents d set (NAME, CONTE_IDSEQ, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LAE_NAME, DcTL_NAME,display_order, doc_text, url) =
    (select  ref_desc, c.nci_idseq, ad.CREAT_DT,ad.CREAT_USR_ID,  ad.LST_UPD_DT,ad.LST_UPD_USR_ID,decode(lang_id, 1000,'ENGLISH', 1007, 'Icelandic', 1004, 'Spanish'), ok.nci_cd, ad.disp_ord, ad.ref_desc, ad.url
    from ref ad, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.ref_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq = cur.nci_idseq)
where d.rd_idseq = cur.nci_idseq;
end loop;

-- Reference Blobs
insert into sbr.reference_blobs (RD_IDSEQ, NAME, DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select ad.nci_idseq, file_nm, nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, ad.CREAT_DT, ad.CREAT_USR_ID, ad.LST_UPD_DT,ad.LST_UPD_USR_ID
from ref ad, ref_doc rd, admin_item ai, admin_item c, obj_key ok
where ad.item_id = ai.item_id 
and   ad.ver_nr = ai.ver_nr
and   ai.cntxt_item_id = c.item_id 
and   ai.cntxt_ver_nr = c.ver_nr 
and   ad.ref_typ_id = ok.obj_key_id (+) 
and   ad.nci_idseq not in (select rd_idseq from sbr.reference_blobs)
and ad.lst_upd_dt >= sysdate - vDays;


for cur in (select nci_idseq from ref where lst_upd_dt >= sysdate - vDays and nci_idseq in (select rd_idseq from sbr.reference_documents)) loop
update sbr.reference_blobs d set(RD_IDSEQ, NAME, DOC_SIZE, DAD_CHARSET, LAST_UPDATED, BLOB_CONTENT, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select ad.nci_idseq, file_nm, nci_doc_size, nci_charset, nci_doc_lst_upd_dt, blob_col, ad.CREAT_DT, ad.CREAT_USR_ID, ad.LST_UPD_DT,ad.LST_UPD_USR_ID
    from ref ad, ref_doc rd, admin_item ai, admin_item c, obj_key ok
    where ad.item_id = ai.item_id 
    and   ad.ver_nr = ai.ver_nr
    and   ai.cntxt_item_id = c.item_id 
    and   ai.cntxt_ver_nr = c.ver_nr 
    and   ad.ref_typ_id = ok.obj_key_id (+) 
    and   ad.nci_idseq not in (select rd_idseq from sbr.reference_blobs)
    and   ad.lst_upd_dt >= sysdate - vDays);
end loop;

commit;
    
end;

procedure sp_create_pv (vDays in integer)
as
v_cnt integer;
begin

--- CD-VM relationship

update sbr.cd_vms set (CD_IDSEQ, VM_IDSEQ,  SHORT_MEANING, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =  --- Check what needs to go into short-meaning
    (select cd.nci_idseq, vm.nci_idseq, vm.item_long_nm, cdvm.CREAT_DT,cdvm.CREAT_USR_ID, cdvm.LST_UPD_DT,cdvm.LST_UPD_USR_ID
    from conc_dom_val_mean cdvm, admin_item cd, admin_item vm
    where cdvm.conc_dom_item_id = cd.item_id 
    and   cdvm.conc_dom_ver_nr = cd.ver_nr
    and   cdvm.nci_val_mean_item_id = vm.item_id 
    and   cdvm.nci_val_mean_ver_nr = vm.ver_nr
    and   cdvm.lst_upd_dt >= sysdate - vDays
    and   (cd.nci_idseq, vm.nci_idseq) in (select cd_idseq, vm_idseq from sbr.cd_vms));


insert into sbr.cd_vms (CD_IDSEQ, VM_IDSEQ,  SHORT_MEANING, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)  --- Check what needs to go into short-meaning
select cd.nci_idseq, vm.nci_idseq, vm.item_long_nm, cdvm.CREAT_DT,cdvm.CREAT_USR_ID,  cdvm.LST_UPD_DT,cdvm.LST_UPD_USR_ID
from conc_dom_val_mean cdvm, admin_item cd, admin_item vm
where cdvm.conc_dom_item_id = cd.item_id 
and   cdvm.conc_dom_ver_nr = cd.ver_nr
and   cdvm.nci_val_mean_item_id = vm.item_id and cdvm.nci_val_mean_ver_nr = vm.ver_nr 
and   (cd.nci_idseq, vm.nci_idseq) not in (select cd_idseq, vm_idseq from sbr.cd_vms)
and   cdvm.lst_upd_dt >= sysdate - vDays;
commit;

-- Permissible Values

update sbr.permissible_Values set (BEGIN_DATE, END_DATE, VALUE, SHORT_MEANING, pv_idseq, vm_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,pv.nci_idseq, vm.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID,pv.LST_UPD_DT,pv.LST_UPD_USR_ID
    from perm_val pv, admin_item vm
    where pv.nci_val_mean_item_id = vm.item_id 
    and   pv.nci_val_mean_ver_nr = vm.ver_nr
    and   pv.lst_upd_dt >= sysdate - vDays
    and pv.nci_idseq in (select pv_idseq from sbr.permissible_Values));

insert into sbr.permissible_Values(BEGIN_DATE, END_DATE, VALUE, SHORT_MEANING, pv_idseq, vm_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select PERM_VAL_BEG_DT, PERM_VAL_END_DT, PERM_VAL_NM, PERM_VAL_DESC_TXT,pv.nci_idseq, vm.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID,pv.LST_UPD_DT,pv.LST_UPD_USR_ID
from perm_val pv, admin_item vm
where pv.nci_val_mean_item_id = vm.item_id 
and   pv.nci_val_mean_ver_nr = vm.ver_nr
and   pv.lst_upd_dt >= sysdate - vDays 
and   pv.nci_idseq not in (select pv_idseq from sbr.permissible_Values);
commit;

update sbr.vd_pvs set (BEGIN_DATE, END_DATE, pv_idseq, vd_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY) =
    (select PERM_VAL_BEG_DT, PERM_VAL_END_DT, pv.nci_idseq, vd.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID, pv.LST_UPD_DT,pv.LST_UPD_USR_ID
    from perm_val pv, admin_item vd
    where pv.val_dom_item_id = vd.item_id 
    and   pv.val_dom_ver_nr = vd.ver_nr
    and   pv.lst_upd_dt >= sysdate - vDays 
    and   pv.nci_idseq in (select pv_idseq from sbr.vd_pvs));

insert into sbr.vd_pvs(BEGIN_DATE, END_DATE, pv_idseq, vd_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY)
select PERM_VAL_BEG_DT, PERM_VAL_END_DT, pv.nci_idseq, vd.nci_idseq, pv.CREAT_DT,pv.CREAT_USR_ID, pv.LST_UPD_DT,pv.LST_UPD_USR_ID
from perm_val pv, admin_item vd
where pv.val_dom_item_id = vd.item_id 
and   pv.val_dom_ver_nr = vd.ver_nr
and   pv.lst_upd_dt >= sysdate - vDays 
and   pv.nci_idseq not in (select pv_idseq from sbr.vd_pvs);
commit;


end;

procedure sp_create_csi (vDays in integer)
as
v_cnt integer;
begin

-- Classification Scheme Items 

update sbr.cs_csi set (cs_idseq, cs_csi_idseq, p_cs_csi_idseq, date_created,created_by,date_modified, modified_by, display_order, label) =
    (select cs.nci_idseq, csi.nci_idseq, pcsi.nci_idseq, rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID, disp_ord, disp_lbl
    from admin_item cs, admin_item csi, admin_item pcsi, nci_admin_item_rel_alt_key rel
    where rel.lst_upd_dt >= sysdate - vDays 
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
    where rel.lst_upd_dt >= sysdate - vDays 
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
    where rel.lst_upd_dt >= sysdate - vDays 
    and   rel.c_item_id = ai.item_id 
    and   rel.c_item_ver_nr = ai.ver_nr
    and   rel.nci_pub_id = csi.nci_pub_id 
    and   rel.nci_ver_nr = csi.nci_ver_nr
    and   rel.rel_typ_id = 65
    and   (csi.nci_idseq, ai.nci_idseq) in (select cs_csi_idseq, ac_idseq from sbr.ac_csi));

insert into sbr.ac_csi (CS_CSI_IDSEQ,  AC_IDSEQ,  date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, ai.nci_idseq , rel.creat_dt, rel.CREAT_USR_ID, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
    from nci_alt_key_admin_item_rel rel, nci_admin_item_rel_alt_key csi, admin_item ai
    where rel.lst_upd_dt >= sysdate - vDays 
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
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));


insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DESIGNATION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_nms an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and   csi.nci_ver_nr = csian.nci_ver_nr 
    and   an.nm_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;

-- Classification Scheme Items - Alternate Definitions

update sbrext.AC_ATT_CSCSI_EXT set (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by) =
    (select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and csi.nci_ver_nr = csian.nci_ver_nr 
    and an.def_id = nmdef_id
    and csian.lst_upd_dt >= sysdate - vDays
    and (csi.nci_idseq, an.nci_idseq) in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext));

insert into sbrext.AC_ATT_CSCSI_EXT (CS_CSI_IDSEQ,ATT_IDSEQ,ATL_NAME,date_created,created_by,date_modified, modified_by)
    select csi.nci_idseq, an.nci_idseq, 'DEFINITION',  csian.CREAT_DT, csian.CREAT_USR_ID, csian.LST_UPD_DT,csian.LST_UPD_USR_ID
    from nci_admin_item_rel_alt_key csi, alt_def an, nci_csi_alt_defnms csian
    where csi.nci_pub_id = csian.nci_pub_id 
    and   csi.nci_ver_nr = csian.nci_ver_nr 
    and   an.def_id = nmdef_id
    and   csian.lst_upd_dt >= sysdate - vDays
    and   (csi.nci_idseq, an.nci_idseq) not in (select CS_CSI_IDSEQ,ATT_IDSEQ from sbr.ac_att_cscsi_ext);
commit;


end;

END;
/
