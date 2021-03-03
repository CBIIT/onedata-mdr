DROP PACKAGE ONEDATA_WA.NCI_CADSR_PUSH;

CREATE OR REPLACE PACKAGE ONEDATA_WA.nci_caDSR_push AS

procedure pushOC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushProp (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushDE (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushDEC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushConcept (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushVD (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushRC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushCD (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushForm (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushProt (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushVM (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushOCRecs (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushCS (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushContext (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushCSI (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushModule (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushCondr (vCondrIdseq in char, vItemId in number, vVerNr in number, vActionType in char);

END;
/

DROP PACKAGE BODY ONEDATA_WA.NCI_CADSR_PUSH;

CREATE OR REPLACE PACKAGE body ONEDATA_WA.nci_caDSR_push AS

procedure pushOC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then

update sbrext.object_classes_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq, ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,  
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and ai.nci_idseq = vIdseq)
where oc_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.object_classes_ext (oc_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,oc_id,CONDR_IDSEQ,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.NCI_IDSEQ,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and ai.nci_idseq= vIdseq;
end if;
end;

procedure pushProp (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char) 
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then
update sbrext.properties_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, 
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.origin,ai.ITEM_DESC,ai.ITEM_Nm, 
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and ai.nci_idseq = vIdseq)
where prop_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.properties_Ext (prop_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,prop_id,CONDR_IDSEQ, version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.nci_idseq, ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq;

end if;
end;


procedure pushDE (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbr.data_elements set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name, dec_idseq, vd_idseq,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM,   dec.nci_idseq, vd.nci_idseq,
            ai.LST_UPD_DT,ai.LST_UPD_USR_Id 
    from admin_item ai, admin_item c, de de, admin_item vd,  admin_item dec
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq 
            and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.val_dom_item_id = vd.item_id and de.val_dom_ver_nr = vd.ver_nr
            and de.de_conc_item_id = dec.item_id and de.de_conc_ver_nr = dec.ver_nr)
where de_idseq = vIdseq;


--- Update Complex_data_elements
for cur2 in (select DERV_MTHD	, DERV_RUL , DERV_TYP_ID, CONCAT_CHAR, DERV_DE_IND from de where item_id = vItemId and ver_nr = vVerNr and derv_de_ind = 1) loop
update sbr.complex_data_elements set (METHODS,RULE, CRTL_NAME, CONCAT_CHAR) =
(select DERV_MTHD, DERV_RUL , ok.nci_cd, CONCAT_CHAR
        from de, obj_key ok 
        where item_id = vItemId and ver_nr = vVerNr and de.DERV_TYP_ID = ok.obj_key_id (+))
where p_de_idseq = vIdseq;
end loop;

-- Derivation components update
for cur3 in (select vIdseq, c.nci_idseq c_de_idseq, disp_ord,rel.CREAT_USR_ID, rel.CREAT_DT, rel.LST_UPD_DT,rel.LST_UPD_USR_ID  
from nci_admin_item_rel rel, admin_item c where rel_typ_id = 65 and rel.p_item_id = vItemId and p_item_ver_nr = vVerNr and 
c.item_id = rel.c_item_id and c.ver_nr = rel.c_item_ver_nr and (vIdseq, c.nci_idseq) in (select p_de_idseq, c_de_idseq from sbr.COMPLEX_DE_RELATIONSHIPS) )loop
update sbr.complex_de_relationships set (DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY) = 
(select cur3.disp_ord, cur3.lst_upd_dt, cur3.lst_upd_usr_id from dual)
where p_de_idseq = vIdseq and c_de_idseq = cur3.c_de_idseq;
end loop;

for cur4 in (select vIdseq, c.nci_idseq c_de_idseq, disp_ord,rel.CREAT_USR_ID, rel.CREAT_DT, rel.LST_UPD_DT,rel.LST_UPD_USR_ID  
from nci_admin_item_rel rel, admin_item c where rel_typ_id = 65 and rel.p_item_id = vItemId and p_item_ver_nr = vVerNr and 
c.item_id = rel.c_item_id and c.ver_nr = rel.c_item_ver_nr and (vIdseq, c.nci_idseq) not in (select p_de_idseq, c_de_idseq from sbr.COMPLEX_DE_RELATIONSHIPS)) loop
insert into sbr.complex_de_relationships (p_de_idseq, c_de_idseq, DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY,DATE_CREATED, CREATED_BY ) 
select vIdseq, cur4.c_de_idseq, cur4.disp_ord, cur4.lst_upd_dt, cur4.lst_upd_usr_id, cur4.creat_dt, cur4.creat_usr_id from dual;
end loop;
end if;

if vActionType = 'I' then

insert into sbr.data_elements (de_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name,cde_id,version, dec_idseq, vd_idseq,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM,ai.ITEM_ID, ai.VER_NR, dec.nci_idseq, vd.nci_idseq,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, de de, admin_item vd,  admin_item dec
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq 
            and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.val_dom_item_id = vd.item_id and de.val_dom_ver_nr = vd.ver_nr
            and de.de_conc_item_id = dec.item_id and de.de_conc_ver_nr = dec.ver_nr
            and ai.nci_idseq= vIdseq;


for cur2 in (select DERV_MTHD	, DERV_RUL , DERV_TYP_ID, CONCAT_CHAR, DERV_DE_IND from de where item_id = vItemId and ver_nr = vVerNr and derv_de_ind = 1) loop
insert into sbr.complex_data_elements (p_de_idseq, METHODS,RULE, CRTL_NAME, CONCAT_CHAR)
select vIdseq, DERV_MTHD, DERV_RUL , ok.nci_cd, CONCAT_CHAR
from de, obj_key ok where item_id = vItemId and ver_nr = vVerNr and de.DERV_TYP_ID = ok.obj_key_id (+);
end loop;

for cur4 in (select vIdseq, c.nci_idseq c_de_idseq, disp_ord,rel.CREAT_USR_ID, rel.CREAT_DT, rel.LST_UPD_DT,rel.LST_UPD_USR_ID  
from nci_admin_item_rel rel, admin_item c where rel_typ_id = 65 and rel.p_item_id = vItemId and p_item_ver_nr = vVerNr and 
C.item_id = rel.c_item_id and c.ver_nr = rel.c_item_ver_nr ) loop
insert into sbr.complex_de_relationships (p_de_idseq, c_de_idseq, DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY,DATE_CREATED, CREATED_BY ) 
select vIdseq, cur4.c_de_idseq, cur4.disp_ord, cur4.lst_upd_dt, cur4.lst_upd_usr_id, cur4.creat_dt, cur4.creat_usr_id from dual
commit;
end loop;

end if;
end;

procedure pushDEC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update  sbr.data_element_concepts  set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name, oc_idseq, prop_idseq, cd_idseq, 
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM, oc.nci_idseq, prop.nci_idseq, cd.nci_idseq ,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID
    from admin_item ai, admin_item c, de_conc dec, admin_item oc, admin_item prop, admin_item cd
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq 
            and ai.item_id = dec.item_id and ai.ver_nr = dec.ver_nr
            and dec.obj_cls_item_id = oc.item_id and dec.obj_cls_ver_nr = oc.ver_nr
            and dec.prop_item_id = prop.item_id and dec.prop_ver_nr = prop.ver_nr
            and dec.conc_dom_item_id = cd.item_id and dec.conc_dom_ver_nr = cd.ver_nr)
where dec_idseq = vIdseq;
end if;

if vActionType = 'I' then

insert into sbr.data_element_concepts (dec_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name,dec_id,oc_idseq, prop_idseq, cd_idseq,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM,ai.ITEM_ID, oc.nci_idseq, prop.nci_idseq, cd.nci_idseq,ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, de_conc dec, admin_item oc, admin_item prop, admin_item cd
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq 
            and ai.item_id = dec.item_id and ai.ver_nr = dec.ver_nr
            and dec.obj_cls_item_id = oc.item_id and dec.obj_cls_ver_nr = oc.ver_nr
            and dec.prop_item_id = prop.item_id and dec.prop_ver_nr = prop.ver_nr
            and dec.conc_dom_item_id = cd.item_id and dec.conc_dom_ver_nr = cd.ver_nr
            and ai.nci_idseq= vIdseq;
end if;
end;

procedure pushConcept (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbrext.concepts_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, evs_source, definition_source,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, ok.NCI_CD,  ai.def_src,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, obj_key ok, cncpt con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr
            and con.evs_src_id = ok.obj_key_id (+))
where con_idseq = vIdseq;

end if;

if vActionType = 'I' then
insert into sbr.concepts_ext (con_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,con_id, evs_source,definition_source,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ok.nci_cd, ai.def_src,ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, cncpt con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.evs_src_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushVD (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin


pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then

update sbr.value_domains set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
                long_name,ORIGIN,preferred_definition,preferred_name, high_value_num,low_value_num, max_length_num, min_length_num,
                decimal_place,rep_idseq, cd_idseq,uoml_name, dtl_name, forml_name,vd_type_flag,
                date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
                ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM,  VAL_DOM_HIGH_VAL_NUM,VAL_DOM_LOW_VAL_NUM,VAL_DOM_MAX_CHAR,VAL_DOM_MIN_CHAR,
                NCI_DEC_PREC, rc.nci_idseq, cd.nci_idseq, uom.nci_cd, dt.nci_cd, fmt.nci_cd,decode(VAL_DOM_TYP_ID, 17,'E' ,18, 'N'),
                ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
            from admin_item ai, admin_item c, value_dom vd, admin_item rc,  admin_item cd, fmt, uom, data_typ dt
            where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
                and ai.nci_idseq = vIdseq 
                and ai.item_id = vd.item_id and ai.ver_nr = vd.ver_nr
                and vd.conc_dom_item_id = cd.item_id and Vd.conc_dom_ver_nr = cd.ver_nr
                and vd.rep_cls_item_id = rc.item_id (+) and vd.rep_cls_ver_nr = rc.ver_nr (+)
                and vd.val_dom_fmt_id = fmt.fmt_id (+)
                and vd.uom_id = uom.uom_id (+)
                and vd.dttype_id = dt.dttype_id (+))
where vd_idseq = vIdseq;
end if;
if vActionType = 'I' then

insert into sbr.value_domains (vd_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name,vd_id,
            high_value_num,low_value_num, max_length_num, min_length_num,
            decimal_place,rep_idseq, cd_idseq,uoml_name, dtl_name, forml_name,vd_type_flag,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_NM,ai.ITEM_ID, 
            VAL_DOM_HIGH_VAL_NUM,VAL_DOM_LOW_VAL_NUM,VAL_DOM_MAX_CHAR,VAL_DOM_MIN_CHAR,
            NCI_DEC_PREC, rc.nci_idseq, cd.nci_idseq, uom.nci_cd, dt.nci_cd, fmt.nci_cd,decode(Val_dom_typ_id, 17,'E' ,18, 'N')ai,ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, value_dom vd, admin_item rc,  admin_item cd,  fmt, uom, data_typ dt
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq 
            and ai.item_id = vd.item_id and ai.ver_nr = vd.ver_nr
            and vd.conc_dom_item_id = cd.item_id and Vd.conc_dom_ver_nr = cd.ver_nr
            and vd.rep_cls_item_id = rc.item_id (+) and vd.rep_cls_ver_nr = rc.ver_nr (+)
            and vd.val_dom_fmt_id = fmt.fmt_id (+)
            and vd.uom_id = uom.uom_id (+)
            and vd.dttype_id = dt.dttype_id (+) 
            and ai.nci_idseq= vIdseq;

end if;
end;
procedure pushRC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then
update sbrext.representations_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, 
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, 
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq)
where rep_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.representations_ext (rep_idseq,asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,rep_id,CONDR_IDSEQ,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.nci_idseq,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushCD (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin


pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then
update sbr.conceptual_domains set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, dimensionality,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, DIMNSNLTY, 
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, conc_dom cd
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = cd.item_id and ai.ver_nr = cd.ver_nr
            and ai.nci_idseq = vIdseq)
where cd_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.conceptual_domains (cd_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,cd_id,version,dimensionality,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.VER_NR,DIMNSNLTY, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, conc_dom cd
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and cd.item_id = ai.item_id and cd.ver_nr = ai.ver_nr
        and ai.nci_idseq= vIdseq;

end if;
end;


procedure pushModule (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'I' then
insert into sbrext.quest_contents_ext (qc_idseq,p_mod_idseq, qtl_name, dn_crf_idseq,display_order, repeat_no,
            asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ,ai.nci_idseq, 'MODULE',  frm.nci_idseq, rel.disp_ord,rel.rep_no,ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, NCI_ADMIN_ITEM_REL rel, admin_item frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and rel.rel_typ_id = 61
        and rel.c_item_id  = ai.item_id and rel.c_item_ver_nr = ai.ver_nr
        and rel.p_item_id = frm.item_id and rel.p_item_ver_nr = frm.ver_nr
        and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushForm (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
--if vActionType = 'U' then
--end if;
if vActionType = 'I' then
insert into sbrext.quest_contents_ext (qc_idseq,dn_crf_idseq, qtl_name,  qcdl_name,asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ,ai.nci_idseq, decode(frm.form_typ_id,70, 'CRF', 71, 'TEMPLATE') , ok.nci_cd, ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c,  nci_form frm, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and frm.catgry_id = ok.obj_key_id (+)
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushProt (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbrext.protocols_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, CHANGE_TYPE,CHANGE_NUMBER,REVIEWED_DATE,REVIEWED_BY,APPROVED_DATE, APPROVED_BY, type,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'YES',0,'NO'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, CHNG_TYP,	CHNG_NBR,	RVWD_DT,	RVWD_USR_ID, APPRVD_DT,	APPRVD_USR_ID, ok.nci_cd,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, obj_key ok, nci_protcl con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr
            and con.protcl_typ_id = ok.obj_key_id (+)
            and proto_idseq = ai.nci_idseq);

end if;
if vActionType = 'I' then

insert into sbrext.protocols_ext (proto_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,proto_id, type, CHANGE_TYPE,CHANGE_NUMBER,REVIEWED_DATE,REVIEWED_BY,APPROVED_DATE, APPROVED_BY,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ok.nci_cd, 	CHNG_TYP,	CHNG_NBR,	RVWD_DT,	RVWD_USR_ID, APPRVD_DT,	APPRVD_USR_ID,ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, nci_protcl con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.protcl_typ_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushVM (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then
update sbrext.value_meanings set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,description, comments,CONDR_IDSEQ,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, vm_desc_txt, vm_cmnts,ai.nci_idseq,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c,   nci_val_mean con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr)
where vm_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.value_meanings (vm_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,vm_id, description, comments,version,condr_idseq,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, vm_desc_txt, vm_cmnts ,ai.VER_NR, ai.nci_idseq,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, NCI_val_mean con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq;


end if;
end;

procedure pushOCRecs (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbrext.oc_recs_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,date_modified, modified_by,
            t_oc_idseq, s_oc_idseq, rl_name, source_role, target_role, direction, source_low_multiplicity,
            source_high_multiplicity,target_low_multiplicity,target_high_multiplicity,display_order,dimensionality,array_ind ) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, ai.LST_UPD_DT,ai.LST_UPD_USR_ID,
            toc.nci_idseq, soc.nci_idseq, REL_TYP_NM,SRC_ROLE,TRGT_ROLE,DRCTN,SRC_LOW_MULT,SRC_HIGH_MULT,
            TRGT_LOW_MULT,TRGT_HIGH_MULT,DISP_ORD,DIMNSNLTY,ARRAY_IND
        from admin_item ai, admin_item c,   admin_item toc, admin_item soc, nci_oc_recs ocr
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = ocr.item_id and ai.ver_nr = ocr.ver_nr 
            and ocr.trgt_obj_cls_item_id = toc.item_id and ocr.trgt_obj_cls_ver_nr = toc.ver_nr
            and ocr.src_obj_cls_item_id = soc.item_id and ocr.src_obj_cls_ver_nr = soc.ver_nr)
where ocr_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.oc_recs_ext (ocr_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,ocr_id, version,
            created_by, date_created,date_modified, modified_by,
            t_oc_idseq, s_oc_idseq, rl_name, source_role, target_role, direction, source_low_multiplicity,
            source_high_multiplicity,target_low_multiplicity,target_high_multiplicity,display_order,dimensionality,array_ind ) 
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID,
            toc.nci_idseq, soc.nci_idseq, REL_TYP_NM,SRC_ROLE,TRGT_ROLE,DRCTN,SRC_LOW_MULT,SRC_HIGH_MULT,
            TRGT_LOW_MULT,TRGT_HIGH_MULT,DISP_ORD,DIMNSNLTY,ARRAY_IND
        from admin_item ai, admin_item c,   admin_item toc, admin_item soc, nci_oc_recs ocr
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = ocr.item_id and ai.ver_nr = ocr.ver_nr 
            and ocr.trgt_obj_cls_item_id = toc.item_id and ocr.trgt_obj_cls_ver_nr = toc.ver_nr
            and ocr.src_obj_cls_item_id = soc.item_id and ocr.src_obj_cls_ver_nr = soc.ver_nr;

end if;
end;

procedure pushCSI (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbr.cs_items set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,csitl_name, description, comments,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm, ok.NCI_CD,  csi_desc_txt, csi_cmnts,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, obj_key ok, nci_clsfctn_schm_item con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr
            and con.csi_typ_id = ok.obj_key_id (+))
            where csi_idseq = vIdseq;
end if;
if vActionType = 'I' then
insert into sbr.cs_items (csi_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,csi_id, csitl_name, description, comments,version,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ok.nci_cd, csi_desc_txt, csi_cmnts,ai.VER_NR, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, NCI_CLSFCTN_SCHM_ITEM con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.csi_typ_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushContext (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
--if vActionType = 'U' then
--end if;
if vActionType = 'I' then

insert into sbr.contexts (conte_idseq, description, name, version, pal_name, LL_Name) 
select ai.nci_idseq,  ai.ITEM_DESC, ai.ITEM_Nm, ai.VER_NR, ok.nci_cd, 'UNASSIGNED'
from admin_item ai, cntxt c, obj_key ok
where ai.admin_item_typ_id = 8 and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and c.NCI_PRG_AREA_ID = ok.obj_key_id
and ai.item_id = vItemId and ai.ver_nr = vVerNr;
end if;
end;

procedure pushCS (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbr.classification_schemes set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, cstl_name, label_type_flag,
            date_modified, modified_by) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,  ok.nci_cd, nci_label_typ_flg, 
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, clsfctn_schm cs, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq and ai.item_id = cs.item_id and ai.ver_nr = cs.ver_nr
            and ok.obj_key_id = cs.clsfctn_schm_typ_id)
where cs_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.classification_schemes (cs_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,cs_id,version, cstl_name, label_type_flag,
            created_by, date_created,date_modified, modified_by)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.ADMIN_NOTES, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_LONG_NM, ai.ORIGIN,ai.ITEM_DESC,ai.ITEM_Nm,ai.ITEM_ID, ai.VER_NR, ok.nci_cd, nci_label_typ_flg, 
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID 
        from admin_item ai, admin_item c, clsfctn_schm cs, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and ai.item_id = cs.item_id and ai.ver_nr = cs.ver_nr
        and ok.obj_key_id = cs.clsfctn_schm_typ_id
        and ai.nci_idseq= vIdseq;

end if;
end;

procedure pushCondr (vCondrIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
v_cnt integer;
vExist integer;
--v_condr_idseq char(36);

begin
select count(*) into v_cnt from cncpt_admin_item cai where cai.item_id = vItemId and cai.ver_nr = vVerNr;

if (vActionType = 'I') then

insert into sbrext.CON_DERIVATION_RULES_EXT (condr_idseq, crtl_name, name)
select vCondrIdseq, decode(v_cnt,0, 'Simple Concept',1, 'Simple Concept','CONCATENATION') ,  nvl(listagg(con.item_nm,':') within group (order by cai.NCI_ORD),'No concepts')
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr;

insert into sbrext.COMPONENT_CONCEPTS_EXT (CONDR_IDSEQ, CON_IDSEQ, DISPLAY_ORDER, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY, PRIMARY_FLAG_IND, CONCEPT_VALUE)
select vCondrIdseq, con.nci_idseq, nvl(nci_ord,1), cai.CREAT_DT, cai.LST_UPD_DT,cai.LST_UPD_USR_ID,cai.CREAT_USR_ID, decode(nci_prmry_ind, 1, 'Yes',0,'No'), nci_cncpt_val
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr;
end if;

if (vActionType = 'U') then
update sbrext.CON_DERIVATION_RULES_EXT set (condr_idseq, crtl_name, name)=
(select vCondrIdseq, decode(v_cnt,0, 'Simple Concept',1, 'Simple Concept','CONCATENATION') ,  nvl(listagg(con.item_nm,':') within group (order by cai.NCI_ORD),'No concepts')
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr)
where condr_idseq = vCondrIdseq;

delete from sbrext.COMPONENT_CONCEPTS_EXT where condr_idseq = vCondrIdseq;

insert into sbrext.COMPONENT_CONCEPTS_EXT (CONDR_IDSEQ, CON_IDSEQ, DISPLAY_ORDER, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY, PRIMARY_FLAG_IND, CONCEPT_VALUE)
select vCondrIdseq, con.nci_idseq, nci_ord, cai.CREAT_DT, cai.LST_UPD_DT,cai.LST_UPD_USR_ID,cai.CREAT_USR_ID, decode(nci_prmry_ind, 1, 'Yes',0,'No'), nci_cncpt_val
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr;
end if;



end;

END;
/
