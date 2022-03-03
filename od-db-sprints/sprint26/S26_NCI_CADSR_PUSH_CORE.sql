create or replace PACKAGE nci_caDSR_push_core AS

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
procedure spPushContext (vHours in integer);
procedure pushCSI (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure pushCondr (vCondrIdseq in char, vItemId in number, vVerNr in number, vActionType in char);
procedure spPushAI (vHours in integer);
procedure spPushAIType (vHours in integer, v_typ in integer);
procedure spPushAIID (vItemId in number, vVerNr in number);
procedure pushAC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char);

END;
/
create or replace PACKAGE body nci_caDSR_push_core AS

procedure spPushAI (vHours in integer)
as
--    1 - Conceptual Domain
--    2 - Data Element Concept
--    3 - Value Domain
--    4 - Data Element
--    5 - Object Class
--    6 - Property
--    7 - Representation Class
--    8 - Context
--    9 - Classification Scheme
--    49 - Concept
--    52 - Module
--    54 - Form
--    53 - Value Meaning
--    51 - Classification Scheme Item
--    50 - Protocol
--    56 - OCRecs
v_cnt integer;
v_test integer;
ActionType char(1);
begin


for cur in (select nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item ai, obj_key ok where admin_item_typ_id <> 52 and ai.admin_item_typ_id = ok.obj_key_id and ok.obj_typ_id = 4
and ai.lst_upd_dt >= sysdate -vHours/24 and admin_item_typ_id <> 8 order by ok.disp_ord, ai.creat_dt) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;
if (v_cnt = 0) then ActionType := 'I';
else ActionType := 'U';
end if;
begin
dbms_output.put_line(cur.item_id || ActionType);
end;
case cur.admin_item_typ_id
when 1 then --- Conceptual Domain
nci_cadsr_push_core.pushCD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 2 then --- Data Element Concept
nci_cadsr_push_core.pushDEC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 3 then --- Value Domain
nci_cadsr_push_core.pushVD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 4 then ---- Data Element
nci_cadsr_push_core.pushDE(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 5 then --- Object Class
nci_cadsr_push_core.pushOC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 6 then --- Property
nci_cadsr_push_core.pushProp(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 7 then ---Representation Class
nci_cadsr_push_core.pushRC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

--when 8 then --- Context
--nci_cadsr_push_core.pushContext(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 9 then --- Classification Scheme
nci_cadsr_push_core.pushCS(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 49 then ---Concept
--v_test := 1;
nci_cadsr_push_core.pushConcept(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 54 then --- Form
nci_cadsr_push_core.pushForm(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 53 then --- Value Meaning
nci_cadsr_push_core.pushVM(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 51 then  --- Classification Scheme Item
nci_cadsr_push_core.pushCSI(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 50 then --- Protocol
nci_cadsr_push_core.pushProt(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 56 then --- Protocol
nci_cadsr_push_core.pushOCRecs(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

end case;
nci_cadsr_push_core.pushAC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);
commit;
end loop;

end;


procedure spPushAIType (vHours in integer, v_typ in integer)
as
--    1 - Conceptual Domain
--    2 - Data Element Concept
--    3 - Value Domain
--    4 - Data Element
--    5 - Object Class
--    6 - Property
--    7 - Representation Class
--    8 - Context
--    9 - Classification Scheme
--    49 - Concept
--    52 - Module
--    54 - Form
--    53 - Value Meaning
--    51 - Classification Scheme Item
--    50 - Protocol
--    56 - OCRecs
v_cnt integer;
v_test integer;
ActionType char(1);
begin


for cur in (select nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item where  lst_upd_dt >= sysdate -vHours/24 and admin_item_typ_id = v_typ order by creat_dt) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;

--raise_application_error(-20000, cur.item_id);

if (v_cnt = 0) then ActionType := 'I';
else ActionType := 'U';
end if;

case v_typ
when 1 then --- Conceptual Domain
nci_cadsr_push_core.pushCD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 2 then --- Data Element Concept
nci_cadsr_push_core.pushDEC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 3 then --- Value Domain
nci_cadsr_push_core.pushVD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 4 then ---- Data Element
nci_cadsr_push_core.pushDE(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 5 then --- Object Class
nci_cadsr_push_core.pushOC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 6 then --- Property
nci_cadsr_push_core.pushProp(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 7 then ---Representation Class
nci_cadsr_push_core.pushRC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

--when 8 then --- Context
--nci_cadsr_push_core.pushContext(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 9 then --- Classification Scheme
nci_cadsr_push_core.pushCS(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 49 then ---Concept
v_test := 1;
--nci_cadsr_push_core.pushConcept(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 54 then --- Form
nci_cadsr_push_core.pushForm(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 53 then --- Value Meaning
nci_cadsr_push_core.pushVM(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 51 then  --- Classification Scheme Item
nci_cadsr_push_core.pushCSI(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 50 then --- Protocol
nci_cadsr_push_core.pushProt(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 56 then --- Protocol
nci_cadsr_push_core.pushOCRecs(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

end case;
nci_cadsr_push_core.pushAC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);
commit;
end loop;

end;


procedure spPushAIID (vItemId in number, vVerNr in number)
as
--    1 - Conceptual Domain
--    2 - Data Element Concept
--    3 - Value Domain
--    4 - Data Element
--    5 - Object Class
--    6 - Property
--    7 - Representation Class
--    8 - Context
--    9 - Classification Scheme
--    49 - Concept
--    52 - Module
--    54 - Form
--    53 - Value Meaning
--    51 - Classification Scheme Item
--    50 - Protocol
--    56 - OCRecs
v_cnt integer;
v_test integer;
ActionType char(1);
begin


for cur in (select nci_idseq, item_id, ver_nr, admin_item_typ_id from admin_item where  item_id =vItemId and ver_nr=vVerNr) loop
select count(*) into v_cnt  from sbr.administered_components where ac_idseq = cur.nci_idseq;

--raise_application_error(-20000, cur.item_id);

if (v_cnt = 0) then ActionType := 'I';
else ActionType := 'U';
end if;

case cur.admin_item_typ_id
when 1 then --- Conceptual Domain
nci_cadsr_push_core.pushCD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 2 then --- Data Element Concept
nci_cadsr_push_core.pushDEC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 3 then --- Value Domain
nci_cadsr_push_core.pushVD(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 4 then ---- Data Element
nci_cadsr_push_core.pushDE(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 5 then --- Object Class
nci_cadsr_push_core.pushOC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 6 then --- Property
nci_cadsr_push_core.pushProp(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 7 then ---Representation Class
nci_cadsr_push_core.pushRC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

--when 8 then --- Context
--nci_cadsr_push_core.pushContext(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 9 then --- Classification Scheme
nci_cadsr_push_core.pushCS(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 49 then ---Concept
v_test := 1;
--nci_cadsr_push_core.pushConcept(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 54 then --- Form
nci_cadsr_push_core.pushForm(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 53 then --- Value Meaning
nci_cadsr_push_core.pushVM(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 51 then  --- Classification Scheme Item
nci_cadsr_push_core.pushCSI(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

when 50 then --- Protocol
nci_cadsr_push_core.pushProt(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);


when 56 then --- Protocol
nci_cadsr_push_core.pushOCRecs(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);

end case;
nci_cadsr_push_core.pushAC(cur.nci_idseq, cur.item_id, cur.ver_nr, ActionType);
commit;
end loop;

end;

procedure pushOC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then

update sbrext.object_classes_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,definition_source,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq, ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,  ai.def_src,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and ai.nci_idseq = vIdseq)
where oc_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.object_classes_ext (oc_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,oc_id,CONDR_IDSEQ,version,definition_source,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.NCI_IDSEQ,ai.VER_NR,ai.def_src,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
            long_name,origin,preferred_definition,preferred_name, definition_source,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.origin,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM, ai.def_src,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and ai.nci_idseq = vIdseq)
where prop_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.properties_Ext (prop_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,prop_id,CONDR_IDSEQ, version,definition_source,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID, ai.nci_idseq, ai.VER_NR,ai.def_src,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq;

end if;
end;



procedure pushAC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
v_cnt integer;
begin

if vActionType = 'U' then
update sbr.administered_components set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.origin,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_NM,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID, decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and ai.nci_idseq = vIdseq)
where AC_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.administered_components (ac_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,public_id, version,
            created_by, date_created,date_modified, modified_by, actl_name, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID,  ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID, decode(ai.admin_item_typ_id, 52, 'QUEST_CONTENT', 54, 'QUEST_CONTENT', ok.NCI_CD), decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
    from admin_item ai, admin_item c, obj_key ok
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq
            and ai.admin_item_typ_id = ok.obj_key_id
            and ok.obj_typ_id = 4;

end if;

select count(*) into v_cnt from sbr.ac_registrations where ac_idseq = vIdSeq;

if (v_cnt = 1) then
update sbr.ac_registrations a set (REGISTRATION_STATUS) =
(select nci_stus from stus_mstr, admin_item ai where stus_typ_id = 1 and stus_id = ai.regstr_stus_id
and ai.nci_idseq = vIdSeq )
where a.ac_idseq = vIdSeq;

else
--raise_application_error(-20000, 'Here');

insert into sbr.ac_registrations (ar_idseq, ac_idseq, registration_status, date_created, created_by)
select nci_11179.cmr_guid, vIdSeq, nci_stus, ai.creat_dt, ai.creat_usr_id from stus_mstr, admin_item ai where stus_typ_id = 1 and stus_id = ai.regstr_stus_id
and ai.nci_idseq = vIdSeq and ai.regstr_stus_id is not null ;

end if;
commit;
end;


procedure pushDE (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
v_cnt integer;
begin
if vActionType = 'U' then
update sbr.data_elements set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name, dec_idseq, vd_idseq,
            date_modified, modified_by, deleted_ind, question) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,   dec.nci_idseq, vd.nci_idseq,
            ai.LST_UPD_DT,ai.LST_UPD_USR_Id ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes'), de.pref_quest_txt
    from admin_item ai, admin_item c, de de, admin_item vd,  admin_item dec
    where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.val_dom_item_id = vd.item_id and de.val_dom_ver_nr = vd.ver_nr
            and de.de_conc_item_id = dec.item_id and de.de_conc_ver_nr = dec.ver_nr)
where de_idseq = vIdseq;


end if;

if vActionType = 'I' then

insert into sbr.data_elements (de_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name,cde_id,version, dec_idseq, vd_idseq,
            created_by, date_created,date_modified, modified_by, deleted_ind, question)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID, ai.VER_NR, dec.nci_idseq, vd.nci_idseq,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes'), de.pref_quest_txt
        from admin_item ai, admin_item c, de de, admin_item vd,  admin_item dec
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.val_dom_item_id = vd.item_id and de.val_dom_ver_nr = vd.ver_nr
            and de.de_conc_item_id = dec.item_id and de.de_conc_ver_nr = dec.ver_nr
            and ai.nci_idseq= vIdseq;



/*
for cur4 in (select vIdseq, c.nci_idseq c_de_idseq, disp_ord,rel.CREAT_USR_ID, rel.CREAT_DT, rel.LST_UPD_DT,rel.LST_UPD_USR_ID
from nci_admin_item_rel rel, admin_item c where rel_typ_id = 65 and rel.p_item_id = vItemId and p_item_ver_nr = vVerNr and
C.item_id = rel.c_item_id and c.ver_nr = rel.c_item_ver_nr ) loop
insert into sbr.complex_de_relationships (p_de_idseq, c_de_idseq, DISPLAY_ORDER,DATE_MODIFIED,MODIFIED_BY,DATE_CREATED, CREATED_BY )
select vIdseq, cur4.c_de_idseq, cur4.disp_ord, cur4.lst_upd_dt, cur4.lst_upd_usr_id, cur4.creat_dt, cur4.creat_usr_id from dual;

end loop;
*/
end if;

select count(*) into v_cnt from sbr.complex_data_elements where p_de_idseq = vIdSeq;

if (v_cnt = 0) then
for cur2 in (select DERV_MTHD	, DERV_RUL , DERV_TYP_ID, CONCAT_CHAR, DERV_DE_IND from de where item_id = vItemId and ver_nr = vVerNr and derv_de_ind = 1) loop
insert into sbr.complex_data_elements (p_de_idseq, METHODS,RULE, CRTL_NAME, CONCAT_CHAR,DATE_MODIFIED,MODIFIED_BY,DATE_CREATED, CREATED_BY  )
select vIdseq, DERV_MTHD, DERV_RUL , ok.nci_cd, CONCAT_CHAR, de.lst_upd_dt, de.lst_upd_usr_id, De.creat_dt, de.creat_usr_id
from de, obj_key ok where item_id = vItemId and ver_nr = vVerNr and de.DERV_TYP_ID = ok.obj_key_id (+);
end loop;
end if;


--- Update Complex_data_elements
if v_cnt = 1 then
for cur2 in (select DERV_MTHD	, DERV_RUL , DERV_TYP_ID, CONCAT_CHAR, DERV_DE_IND from de where item_id = vItemId and ver_nr = vVerNr and derv_de_ind = 1) loop
update sbr.complex_data_elements set (METHODS,RULE, CRTL_NAME, CONCAT_CHAR,DATE_MODIFIED,MODIFIED_BY) =
(select DERV_MTHD, DERV_RUL , ok.nci_cd, CONCAT_CHAR, de.lst_upd_dt, de.lst_upd_usr_id
        from de, obj_key ok
        where item_id = vItemId and ver_nr = vVerNr and de.DERV_TYP_ID = ok.obj_key_id (+))
where p_de_idseq = vIdseq;
end loop; 
end if;

end;

procedure pushDEC (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update  sbr.data_element_concepts  set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,ORIGIN,preferred_definition,preferred_name, oc_idseq, prop_idseq, cd_idseq,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM, oc.nci_idseq, prop.nci_idseq, cd.nci_idseq ,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID, oc.nci_idseq, prop.nci_idseq, cd.nci_idseq,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, ok.NCI_CD,  ai.def_src,
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
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, ai.def_src,ai.VER_NR,
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
                date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
                ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,  VAL_DOM_HIGH_VAL_NUM,VAL_DOM_LOW_VAL_NUM,VAL_DOM_MAX_CHAR,VAL_DOM_MIN_CHAR,
                NCI_DEC_PREC, rc.nci_idseq, cd.nci_idseq, uom.nci_cd, dt.nci_cd, fmt.nci_cd,decode(VAL_DOM_TYP_ID, 17,'E' ,18, 'N'),
                ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_NM,ai.ITEM_ID,
            VAL_DOM_HIGH_VAL_NUM,VAL_DOM_LOW_VAL_NUM,VAL_DOM_MAX_CHAR,VAL_DOM_MIN_CHAR,
            NCI_DEC_PREC, rc.nci_idseq, cd.nci_idseq, uom.nci_cd, dt.nci_cd, fmt.nci_cd,decode(Val_dom_typ_id, 17,'E' ,18, 'N')ai,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
            long_name,origin,preferred_definition,preferred_name, definition_source,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, ai.def_src,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq)
where rep_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbrext.representations_ext (rep_idseq,asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,rep_id,CONDR_IDSEQ,version,definition_source,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.nci_idseq,ai.VER_NR,ai.def_src,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef (ai.ITEM_DESC),ai.ITEM_LONG_Nm, DIMNSNLTY,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, conc_dom cd
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = cd.item_id and ai.ver_nr = cd.ver_nr
            and ai.nci_idseq = vIdseq)
where cd_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.conceptual_domains (cd_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,cd_id,version,dimensionality,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR,DIMNSNLTY,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, conc_dom cd
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
        and c.admin_item_typ_id = 8
        and cd.item_id = ai.item_id and cd.ver_nr = ai.ver_nr
        and ai.nci_idseq= vIdseq;

end if;
end;


procedure pushForm (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
v_id number;
v_cnt integer;
v_hdridseq  char(36);
v_ftridseq  char(36);
begin
if vActionType = 'U' then
--raise_application_error(-20000, vItemId);
update sbrext.quest_contents_ext set ( qtl_name,  qcdl_name,asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,
            created_by, date_created,date_modified, modified_by, deleted_ind) =
(select   decode(frm.form_typ_id,70, 'CRF', 71, 'TEMPLATE') , ok.nci_cd, ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c,  nci_form frm, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and frm.catgry_id = ok.obj_key_id (+)
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq)
            where qc_idseq = vIdseq;

end if;
if vActionType = 'I' then
--raise_application_error(-20000, vItemId);
for curfrm in (select  ai.NCI_IDSEQ, decode(frm.form_typ_id,70, 'CRF', 71, 'TEMPLATE') FORM_TYP_ID ,
ok.nci_cd, ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq cntxt_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND ,
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC) ITEM_DESC,ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR, frm.ftr_instr, frm.hdr_instr,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes') FLD_DELETE, 'Yes',1
        from admin_item ai, admin_item c,  nci_form frm, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and frm.catgry_id = ok.obj_key_id (+)
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq) loop

 insert into sbrext.quest_contents_ext (qc_idseq,dn_crf_idseq, qtl_name,  qcdl_name,asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,qc_id,version,
            created_by, date_created,date_modified, modified_by, deleted_ind, display_ind, display_order)
values ( curfrm.NCI_IDSEQ,curfrm.nci_idseq, curfrm.form_typ_id, curfrm.nci_cd, curfrm.ADMIN_STUS_NM_DN, curfrm.EFF_DT, curfrm.chng_desc_txt, curfrm.cntxt_idseq,
curfrm.UNTL_DT, curfrm.CURRNT_VER_IND,
            curfrm.ITEM_NM, curfrm.ORIGIN,substr(curfrm.ITEM_DESC,1,2000),curfrm.ITEM_LONG_Nm,curfrm.ITEM_ID, curfrm.VER_NR,
            curfrm.CREAT_USR_ID, curfrm.CREAT_DT, curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID ,curfrm.fld_delete, 'Yes',1);
          end loop;
end if;




select count(*) into v_cnt from sbrext.quest_contents_ext where dn_crf_idseq = vIdSeq and qtl_name = 'FORM_INSTR';
if (v_cnt = 0) then
v_id := nci_11179.getItemid;
v_hdridseq := nci_11179.cmr_guid;
for curfrm in (select  ai.NCI_IDSEQ,
 ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq cntxt_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND ,
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC) ITEM_DESC,ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR, frm.ftr_instr, frm.hdr_instr,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes') FLD_DELETE, 'Yes',1
        from admin_item ai, admin_item c, nci_form frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq) loop
insert into sbrext.quest_contents_ext (qc_idseq, dn_crf_idseq, qtl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,qc_id,
            version,
            created_by, date_created,date_modified, modified_by, deleted_ind,display_ind, display_order)
values (v_hdridseq, curfrm.nci_idseq, 'FORM_INSTR' , curfrm.ADMIN_STUS_NM_DN, curfrm.EFF_DT, curfrm.chng_desc_txt, curfrm.cntxt_idseq,
curfrm.UNTL_DT, curfrm.CURRNT_VER_IND,
            curfrm.ITEM_NM, curfrm.ORIGIN,nvl(curfrm.hdr_instr, ' '),
            v_id,v_id,
            curfrm.VER_NR,
            curfrm.CREAT_USR_ID, curfrm.CREAT_DT, curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID ,curfrm.fld_delete, 'Yes', 1);

       insert into sbr.administered_components (ac_idseq, actl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,public_id,
            version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
values ( v_hdridseq, 'QUEST_CONTENT' , curfrm.ADMIN_STUS_NM_DN, curfrm.EFF_DT, curfrm.chng_desc_txt, curfrm.cntxt_idseq,curfrm.UNTL_DT, curfrm.CURRNT_VER_IND,
            curfrm.ITEM_NM, curfrm.ORIGIN,nvl(curfrm.hdr_instr, ' '),
            v_id,v_id,
            curfrm.VER_NR,
            curfrm.CREAT_USR_ID, curfrm.CREAT_DT, curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID ,curfrm.fld_delete);

insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,DATE_CREATED,CREATED_BY,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curfrm.nci_idseq, v_hdridseq, 1 ,'FORM_INSTRUCTION',curfrm.CREAT_DT, curfrm.CREAT_USR_ID,  curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID from dual;
end loop;
else
            update sbrext.quest_contents_ext set ( preferred_definition,
            date_modified, modified_by) =
(select  nvl(frm.hdr_instr, ' ' ), frm.LST_UPD_DT,frm.LST_UPD_USR_ID
        from admin_item ai,  nci_form frm
        where ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and ai.nci_idseq= vIdseq)
            where dn_crf_idseq = vIdseq and qtl_name ='FORM_INSTR';
    end if;
                  --      and frm.hdr_instr is not null;



         select count(*) into v_cnt from sbrext.quest_contents_ext where dn_crf_idseq = vIdSeq and qtl_name = 'FOOTER';

         if (v_cnt = 0) then
v_id := nci_11179.getItemid;
v_ftridseq := nci_11179.cmr_guid;
for curfrm in (select  ai.NCI_IDSEQ,
 ai.ADMIN_STUS_NM_DN, ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq cntxt_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No') CURRNT_VER_IND ,
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC) ITEM_DESC,ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR, frm.ftr_instr, frm.hdr_instr,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes') FLD_DELETE, 'Yes',1
        from admin_item ai, admin_item c, nci_form frm
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and c.admin_item_typ_id = 8
            and ai.nci_idseq= vIdseq) loop
insert into sbrext.quest_contents_ext (qc_idseq, dn_crf_idseq, qtl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,qc_id,
            version,
            created_by, date_created,date_modified, modified_by, deleted_ind,display_ind, display_order)
values (  v_ftridseq, curfrm.nci_idseq, 'FOOTER' , curfrm.ADMIN_STUS_NM_DN, curfrm.EFF_DT, curfrm.chng_desc_txt,curfrm.cntxt_idseq,
         curfrm.UNTL_DT, curfrm.CURRNT_VER_IND,
            curfrm.ITEM_NM, curfrm.ORIGIN,nvl(curfrm.ftr_instr, ' '),
            v_id,v_id,
            curfrm.VER_NR,
            curfrm.CREAT_USR_ID, curfrm.CREAT_DT, curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID ,curfrm.fld_delete, 'Yes', 1);

            --and frm.ftr_instr is not null;


         insert into sbr.administered_components (ac_idseq, actl_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,
            preferred_name,public_id,
            version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
            values (  v_ftridseq,  'QUEST_CONTENT' , curfrm.ADMIN_STUS_NM_DN, curfrm.EFF_DT, curfrm.chng_desc_txt,curfrm.cntxt_idseq,curfrm.UNTL_DT, curfrm.CURRNT_VER_IND,
            curfrm.ITEM_NM, curfrm.ORIGIN,nvl(curfrm.ftr_instr, ' ' ),
            v_id,v_id,
            curfrm.VER_NR,
            curfrm.CREAT_USR_ID, curfrm.CREAT_DT, curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID,curfrm.fld_delete);


insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,DATE_CREATED,CREATED_BY,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curfrm.nci_idseq, v_ftridseq, 2 ,'FORM_INSTRUCTION',curfrm.CREAT_DT, curfrm.CREAT_USR_ID,  curfrm.LST_UPD_DT,curfrm.LST_UPD_USR_ID from dual;

            end loop;
      else
               update sbrext.quest_contents_ext set ( preferred_definition,
            date_modified, modified_by) =
(select  nvl(frm.ftr_instr, ' ' ), frm.LST_UPD_DT,frm.LST_UPD_USR_ID
        from admin_item ai,  nci_form frm
        where ai.item_id = frm.item_id and ai.ver_nr = frm.ver_nr
            and ai.nci_idseq= vIdseq)
            where dn_crf_idseq = vIdseq and qtl_name ='FOOTER';

      end if;


/*
insert into sbrext.qc_recs_ext (QR_IDSEQ,P_QC_IDSEQ,C_QC_IDSEQ,DISPLAY_ORDER,RL_NAME,DATE_CREATED,CREATED_BY,DATE_MODIFIED,MODIFIED_BY)
select nci_11179.cmr_guid,curmod.mod_idseq, v_idseq, curmod.disp_ord ,'MODULE_INSTRUCTION', curmod.CREAT_USR_ID, curmod.CREAT_DT, curmod.LST_UPD_DT,curmod.LST_UPD_USR_ID from dual;
*/



insert into sbrext.protocol_qc_ext (pq_idseq, proto_idseq, qc_idseq, date_created, created_by)
select nci_11179.cmr_guid, pr.nci_idseq, vIdseq, r.creat_dt, r.creat_usr_id from admin_item pr, nci_admin_item_rel r where r.p_item_id = pr.item_id and r.p_item_ver_nr = pr.ver_nr 
and r.c_item_id = vItemId and r.c_item_ver_nr = vVerNr and r.rel_typ_id = 60 and nvl(r.fld_delete,0) = 0 and (pr.nci_idseq, vIdSeq) not in (select proto_idseq, qc_idseq from sbrext.protocol_qc_ext);
commit;

-- Delete if Protocol deleted
delete from sbrext.protocol_qc_ext where (proto_idseq, qc_idseq) in 
(select  pr.nci_idseq, vIdseq from admin_item pr, nci_admin_item_rel r where r.p_item_id = pr.item_id and r.p_item_ver_nr = pr.ver_nr 
and r.c_item_id = vItemId and r.c_item_ver_nr = vVerNr and r.rel_typ_id = 60 and nvl(r.fld_delete,0) = 1) ;
commit;
/*
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
          FROM admin_item pro, admin_item frm, sbrext_m.protocol_qc_ext qc
         WHERE     pro.nci_idseq = qc.proto_idseq
               AND frm.nci_idseq = qc.qc_idseq
               AND pro.admin_item_typ_id = 50
               AND frm.admin_item_typ_id = 54;

    COMMIT;
*/

end;

procedure pushProt (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

--raise_application_error(-20000, vItemid || vActionType);

if vActionType = 'U' then
update sbrext.protocols_ext set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, CHANGE_TYPE,CHANGE_NUMBER,REVIEWED_DATE,REVIEWED_BY,APPROVED_DATE, APPROVED_BY, type,
            protocol_id,     LEAD_ORG,               PHASE,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, CHNG_TYP,	CHNG_NBR,	RVWD_DT,	RVWD_USR_ID, APPRVD_DT,	APPRVD_USR_ID, ok.nci_cd,
            PROTCL_ID,    org.ORG_NM,                     PROTCL_PHASE,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, obj_key ok, nci_protcl con, nci_org org
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr
            and con.protcl_typ_id = ok.obj_key_id (+)
            and proto_idseq = ai.nci_idseq
            and con.LEAD_ORG_ID =org.ENTTY_ID(+))
            where proto_idseq = vIdSeq ;

end if;
if vActionType = 'I' then

insert into sbrext.protocols_ext (proto_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,proto_id, type, CHANGE_TYPE,CHANGE_NUMBER,REVIEWED_DATE,REVIEWED_BY,APPROVED_DATE, APPROVED_BY,version,
                     protocol_id,     LEAD_ORG,               PHASE,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, 	CHNG_TYP,	CHNG_NBR,	RVWD_DT,	RVWD_USR_ID, APPRVD_DT,	APPRVD_USR_ID,ai.VER_NR,
           PROTCL_ID,  org.ORG_NM,  PROTCL_PHASE,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, nci_protcl con, obj_key ok, nci_org org
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.protcl_typ_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq
             and con.LEAD_ORG_ID =org.ENTTY_ID(+);

end if;
end;

procedure pushVM (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin

pushCondr (vIdseq, vItemId, vVerNr, vActionType);

if vActionType = 'U' then
update sbrext.value_meanings set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,description, comments,CONDR_IDSEQ,definition_source,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, vm_desc_txt, vm_cmnts,ai.nci_idseq,ai.DEF_SRC,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c,   nci_val_mean con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr)
where vm_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.value_meanings (vm_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,vm_id, description, comments,version,condr_idseq,definition_source,
            created_by, date_created,date_modified, modified_by, deleted_ind, short_meaning)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, vm_desc_txt, vm_cmnts ,ai.VER_NR, ai.nci_idseq,ai.DEF_SRC,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes'), ai.item_nm
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
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, ai.LST_UPD_DT,ai.LST_UPD_USR_ID,
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
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR,
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
v_prnt_null integer;
begin

select decode(p_item_id, null, 1, 0) into v_prnt_null from nci_clsfctn_schm_item where item_id = vItemId and ver_nr =vVerNr;

if vActionType = 'U' then
update sbr.cs_items set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,csitl_name, description, comments,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm, ok.NCI_CD,  csi_desc_txt, csi_cmnts,
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, obj_key ok, nci_clsfctn_schm_item con
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq
            and ai.item_id = con.item_id and ai.ver_nr = con.ver_nr
            and con.csi_typ_id = ok.obj_key_id (+))
            where csi_idseq = vIdseq;

-- if parent is not null
if (v_prnt_null = 0) then
for cur in (select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq, nvl(pcsi.cs_csi_idseq, pcsiai.nci_idseq) p_cs_csi_idseq
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs, admin_item pcsiai, nci_clsfctn_schm_item pcsi where
csiai.nci_idseq = vIdSeq and csi.item_id = vItemid and csi.ver_nr = vVerNr and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and csi.p_item_id = pcsiai.item_id and csi.p_item_ver_nr = pcsiai.ver_nr and csi.p_item_id = pcsi.item_id and csi.p_item_ver_nr = pcsi.ver_nr
and csi.p_item_id is not null) loop
update sbr.cs_csi set cs_idseq = cur.cs_idseq, p_cs_csi_idseq  = cur.p_cs_csi_idseq where cs_csi_idseq = cur.cs_csi_idseq;
end loop;
else
-- if parent is null
for cur in (select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs where
csiai.nci_idseq = vIdSeq and csi.item_id = vItemid and csi.ver_nr = vVerNr and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and csi.p_item_id is null) loop
update sbr.cs_csi set cs_idseq = cur.cs_idseq, p_cs_csi_idseq  = null where cs_csi_idseq = cur.cs_csi_idseq;
end loop;
end if;
end if;
if vActionType = 'I' then
--raise_application_error(-20000, vIdseq);

insert into sbr.cs_items (csi_idseq, csi_name, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,csi_id, csitl_name, description, comments,version,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ITEM_NM, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ok.nci_cd, csi_desc_txt, csi_cmnts,ai.VER_NR,
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, NCI_CLSFCTN_SCHM_ITEM con, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and c.admin_item_typ_id = 8
            and con.csi_typ_id = ok.obj_key_id (+)
            and con.item_id = ai.item_id and con.ver_nr = ai.ver_nr
            and ai.nci_idseq= vIdseq;

-- if parent is not null
if (v_prnt_null = 0) then
for cur in (select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq, nvl(pcsi.cs_csi_idseq, pcsiai.nci_idseq) p_cs_csi_idseq,
csi.creat_dt, csi.lst_upd_dt, csi.creat_usr_id, csi.lst_upd_usr_id
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs, admin_item pcsiai, nci_clsfctn_schm_item pcsi where
csiai.nci_idseq = vIdSeq and csi.item_id = vItemid and csi.ver_nr = vVerNr and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and csi.p_item_id = pcsiai.item_id and csi.p_item_ver_nr = pcsiai.ver_nr and csi.p_item_id = pcsi.item_id and csi.p_item_ver_nr = pcsi.ver_nr
and csi.p_item_id is not null) loop
insert into  sbr.cs_csi (CS_CSI_IDSEQ, CS_IDSEQ,csi_idseq, P_CS_CSI_IDSEQ,  DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY, LABEL)
select  cur.cs_csi_idseq, cur.cs_idseq, cur.csi_idseq, cur.p_cs_csi_idseq, cur.creat_dt,
cur.creat_usr_id, cur.lst_upd_dt, cur.lst_upd_usr_id,'1' from dual
where cur.cs_csi_idseq not in (Select cs_csi_idseq from sbr.cs_csi);


end loop;
else
-- if parent is null
for cur in (select nvl(csi.cs_csi_idseq, csiai.nci_idseq) cs_csi_idseq, cs.nci_idseq cs_idseq, csiai.nci_idseq csi_idseq,
csi.creat_dt, csi.lst_upd_dt, csi.creat_usr_id, csi.lst_upd_usr_id
from admin_item csiai, nci_clsfctn_schm_item csi, admin_item cs where
csiai.nci_idseq = vIdSeq and csi.item_id = vItemid and csi.ver_nr = vVerNr and csi.cs_item_id = cs.item_id and csi.cs_item_ver_nr = cs.ver_nr
and csi.p_item_id is null) loop
insert into  sbr.cs_csi (CS_CSI_IDSEQ, CS_IDSEQ, csi_idseq, DATE_CREATED, CREATED_BY, DATE_MODIFIED, MODIFIED_BY,LABEL)
select cur.cs_csi_idseq, cur.cs_idseq, cur.csi_idseq, cur.creat_dt,
cur.creat_usr_id, cur.lst_upd_dt, cur.lst_upd_usr_id,'1' from dual
where cur.cs_csi_idseq not in (Select cs_csi_idseq from sbr.cs_csi);

end loop;
end if;
end if;

end;

procedure spPushContext (vHours in Integer)
as
v_cnt integer;
begin

for cur in (select * from admin_item where admin_item_typ_id = 8 and lst_upd_dt >= sysdate -vHours/24 ) loop

select count(*) into v_cnt from sbr.contexts where conte_idseq = cur.nci_idseq;

if (v_cnt = 1) then -- update
update sbr.contexts set (description, name, pal_name, MODIFIED_BY, DATE_MODIFIED) = 
( select  nci_cadsr_push.getShortDef(ai.ITEM_DESC), ai.ITEM_Nm,  ok.nci_cd,  ai.lst_upd_usr_id, ai.lst_upd_dt
from admin_item ai, cntxt c, obj_key ok
where ai.admin_item_typ_id = 8 and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and c.NCI_PRG_AREA_ID = ok.obj_key_id
and ai.item_id = cur.item_id and ai.ver_nr = cur.ver_nr)
where conte_idseq = cur.nci_idseq;

end if;
--raise_application_error(-20000, 'Test' || vItemId);

if v_cnt = 0 then

insert into sbr.contexts (conte_idseq, description, name, version, pal_name, LL_Name, LANGUAGE, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED)
select ai.nci_idseq,  nci_cadsr_push.getShortDef(ai.ITEM_DESC), ai.ITEM_Nm, ai.VER_NR, ok.nci_cd, 'UNASSIGNED', 'ENGLISH', ai.creat_usr_id, ai.creat_dt, ai.lst_upd_usr_id, ai.lst_upd_dt
from admin_item ai, cntxt c, obj_key ok
where ai.admin_item_typ_id = 8 and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and c.NCI_PRG_AREA_ID = ok.obj_key_id
and ai.item_id = cur.item_id and ai.ver_nr = cur.ver_nr;
end if;
commit;
end loop;
end;

procedure pushCS (vIdseq in char, vItemId in number, vVerNr in number, vActionType in char)
as
begin
if vActionType = 'U' then
update sbr.classification_schemes set ( asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name, cstl_name, label_type_flag,
            date_modified, modified_by, deleted_ind) =
(select  ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,  ok.nci_cd, nvl(nci_label_typ_flg, 'A'),
            ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
        from admin_item ai, admin_item c, clsfctn_schm cs, obj_key ok
        where ai.cntxt_item_id = c.item_id and ai.cntxt_ver_nr = c.ver_nr
            and ai.nci_idseq = vIdseq and ai.item_id = cs.item_id and ai.ver_nr = cs.ver_nr
            and ok.obj_key_id = cs.clsfctn_schm_typ_id)
where cs_idseq = vIdseq;

end if;
if vActionType = 'I' then
insert into sbr.classification_schemes (cs_idseq, asl_name,begin_date,change_note,conte_idseq,end_date,latest_version_ind,
            long_name,origin,preferred_definition,preferred_name,cs_id,version, cstl_name, label_type_flag,
            created_by, date_created,date_modified, modified_by, deleted_ind)
select  ai.NCI_IDSEQ, ai.ADMIN_STUS_NM_DN,ai.EFF_DT, ai.chng_desc_txt, c.nci_idseq,ai.UNTL_DT, decode(ai.CURRNT_VER_IND,1,'Yes',0,'No'),
            ai.ITEM_NM, ai.ORIGIN,nci_cadsr_push.getShortDef(ai.ITEM_DESC),ai.ITEM_LONG_Nm,ai.ITEM_ID, ai.VER_NR, ok.nci_cd, nvl(cs.nci_label_typ_flg, 'A'),
            ai.CREAT_USR_ID, ai.CREAT_DT, ai.LST_UPD_DT,ai.LST_UPD_USR_ID ,decode(nvl(ai.fld_delete,0),0,'No',1,'Yes')
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
--raise_application_error(-20000, vItemID);
select count(*) into v_cnt from sbrext.CON_DERIVATION_RULES_EXT where condr_idseq = vCondrIdseq;

if (v_cnt = 0) then

insert into sbrext.CON_DERIVATION_RULES_EXT (condr_idseq, date_created, created_by, crtl_name, name)
select vCondrIdseq, nvl(max(cai.creat_dt), sysdate),nvl(max(cai.creat_usr_id), 'ONEDATA'), decode(v_cnt,0, 'Simple Concept',1, 'Simple Concept','CONCATENATION') ,  nvl(listagg(con.item_long_nm,':') within group (order by cai.NCI_ORD),'No concepts')
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr ;
else
update sbrext.CON_DERIVATION_RULES_EXT set (condr_idseq, crtl_name, name)=
(select vCondrIdseq, decode(v_cnt,0, 'Simple Concept',1, 'Simple Concept','CONCATENATION') ,  nvl(listagg(con.item_long_nm,':') within group (order by cai.NCI_ORD),'No concepts')
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr)
where condr_idseq = vCondrIdseq;

end if;

delete from sbrext.COMPONENT_CONCEPTS_EXT where condr_idseq = vCondrIdseq;

insert into sbrext.COMPONENT_CONCEPTS_EXT (cc_idseq, CONDR_IDSEQ, CON_IDSEQ, DISPLAY_ORDER, DATE_CREATED, DATE_MODIFIED, MODIFIED_BY, CREATED_BY, PRIMARY_FLAG_IND, CONCEPT_VALUE)
select nci_11179.cmr_guid, vCondrIdseq, con.nci_idseq, nvl(nci_ord,1), cai.CREAT_DT, cai.LST_UPD_DT,cai.LST_UPD_USR_ID,cai.CREAT_USR_ID, decode(nci_prmry_ind, 1, 'Yes',0,'No'), nci_cncpt_val
from cncpt_admin_item cai, admin_item con where cai.item_id = vItemId and cai.ver_nr = vVerNr and cai.cncpt_item_id = con.item_id and cai.cncpt_ver_nr = con.ver_nr;


end;

END;
/
