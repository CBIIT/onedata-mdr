create or replace procedure sp_postprocess
as
v_cnt integer;
begin

delete from NCI_ADMIN_ITEM_EXT;
commit;

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

--- Data Element
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY)
select ai.item_id, ai.ver_nr, a.used_by
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct an.item_id,an.ver_nr, ai.item_nm from alt_nms an, admin_item ai, obj_key ok where an.cntxt_item_id = ai.item_id and an.cntxt_ver_nr = ai.ver_nr and an.NM_TYP_ID = ok.obj_key_id and ok.obj_typ_id = 11
and ok.nci_cd = 'USED_BY' and an.NM_DESC=ai.item_nm) 
GROUP BY item_id, ver_nr) a
where ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+)
and ai.admin_item_typ_id = 4;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ai.item_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(ai.item_desc,1, 750), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF 
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.admin_item_typ_id in (1,2,3,5,6,7,49,53);
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select ai.item_id, ai.ver_nr from  admin_item ai
where ai.admin_item_typ_id in (8,9,50,51,52,54,56);
commit;

update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm) = (select item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and 
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;
insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;
/*
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
*/

delete from nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;
end;
/
create or replace PROCEDURE spDEPrefQuestPost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_add integer :=0;
  v_action_typ varchar2(30);
  v_item_id  number;
  v_ver_nr  number(4,2);
  v_nm_id number;
  v_cntxt_id number;
  v_cntxt_ver_nr number(4,2);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
    if (ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT') is not null) then
    select cntxt_item_id, cntxt_ver_nr into v_cntxt_id, v_cntxt_ver_nr from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
    
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
     ihook.setColumnValue(row,'REF_NM', substr(ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'),1,255));
     ihook.setColumnValue(row,'REF_DESC', ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'));
     ihook.setColumnValue(row,'LANG_ID', 1000);
     ihook.setColumnValue(row,'NCI_CNTXT_ITEM_ID',v_cntxt_id );
     ihook.setColumnValue(row,'NCI_CNTXT_VER_NR', v_cntxt_ver_nr );
     ihook.setColumnValue(row,'REF_TYP_ID', 80);
     
     ihook.setColumnValue(row,'REF_ID', -1);
     v_action_typ := 'insert';
     for cur in (select REF_id from  REF where item_id = v_item_id and ver_nr = v_ver_nr and ref_typ_id = 80) loop
     ihook.setColumnValue(row,'REF_ID', cur.ref_id);
     v_action_typ := 'update';
     
     end loop;
     
     rows.extend;
    rows(rows.last) := row;
    action := t_actionrowset(rows, 'References (for Edit)', 2,0,v_action_typ);
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

    end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/

create or replace PACKAGE nci_caDSR_PULL AS
procedure sp_create_ai_1;
procedure sp_create_ai_2;
procedure sp_create_ai_3;
procedure sp_create_ai_4;
procedure sp_create_ai_children;
PROCEDURE            sp_create_ai_cncpt;
PROCEDURE            sp_create_csi;
procedure sp_create_csi_2;
procedure sp_migrate_lov ;
PROCEDURE            sp_create_form_ext;
PROCEDURE            sp_create_form_question_rel;
PROCEDURE            sp_create_form_rel;
 PROCEDURE            sp_create_form_ta;
  PROCEDURE            sp_create_form_vv_inst;
   procedure            sp_create_form_vv_inst_2;
   PROCEDURE            sp_create_pv;
    PROCEDURE            sp_create_pv_2;
     procedure            sp_migrate_change_log;
      procedure sp_org_contact;
END;
/

create or replace PACKAGE BODY nci_caDSR_PULL AS


v_dflt_usr  varchar2(30) := 'ONEDATA';

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
v_dflt_date date := to_date('8/18/2020','mm/dd/yyyy');

PROCEDURE            sp_create_ai_1
AS
    v_cnt   INTEGER;
BEGIN
    -- Context creation
    DELETE FROM cntxt;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 8;

    COMMIT;

v_cnt := 20000000000;

for cur in ( SELECT TRIM (conte_idseq) conte_idseq,
               description,
               name,
               version,
               nvl(created_by,v_dflt_usr) created_by,
               nvl(date_created,v_dflt_date) date_created,
   nvl(NVL (date_modified, date_created), v_dflt_date) date_modified,
            nvl(modified_by,v_dflt_usr) modified_by
          FROM sbr.contexts order by name) loop
    INSERT INTO admin_item (item_id, admin_item_typ_id,
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
        values( v_cnt, 8, cur.conte_idseq,
               cur.description,
               cur.name,
               cur.name,
               cur.version,
               cur.name,
               cur.created_by,
               cur.date_created,
   cur.date_modified,
            cur.modified_by);
          v_cnt := v_cnt + 1;
end loop;
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
                            nvl(c.created_by,v_dflt_usr),
               nvl(c.date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(c.modified_by,v_dflt_usr)
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
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
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
             nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
                  nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
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
             nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
                    nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr),
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
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
                   nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr),
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
               nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
                              nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
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
             nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
                 nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
          FROM sbrext.properties_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.PROP_IDSEQ;

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
              nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
  nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
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
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr),
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
               nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
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
               nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
          FROM sbrext.representations_ext cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.REP_IDSEQ;

    COMMIT;

END;
PROCEDURE            sp_create_ai_2
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM de;

    COMMIT;

    DELETE FROM value_dom;

    COMMIT;

    DELETE FROM de_conc;

    COMMIT;

    -- Creation of Value DOmain, DEC and DE

    DELETE FROM admin_item
          WHERE admin_item_typ_id IN (2, 3, 4);

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
                            LST_UPD_USR_ID)
        SELECT ac.dec_idseq,
               2,
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
               ac.dec_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
        nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
                 FROM sbr.data_element_concepts ac, admin_item cntxt, stus_mstr s
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
                            LST_UPD_USR_ID)
        SELECT ac.vd_idseq,
               3,
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
               ac.vd_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
          FROM sbr.value_domains ac, admin_item cntxt, stus_mstr s
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
                            LST_UPD_USR_ID)
        SELECT ac.de_idseq,
               4,
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
               ac.cde_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
          FROM sbr.data_elements ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;
END;

 PROCEDURE            sp_create_ai_3
AS
    v_cnt   INTEGER;
    un_oc number;
    un_prop number;
BEGIN
    DELETE FROM de;

    COMMIT;

    DELETE FROM value_dom;

    COMMIT;

    DELETE FROM de_conc;

    COMMIT;

   un_oc := 7318107;
   un_prop := 7318108;

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
        nvl(dec.created_by,v_dflt_usr),
               nvl(dec.date_created,v_dflt_date) ,
               nvl(NVL (dec.date_modified, dec.date_created), v_dflt_date),
               nvl(dec.modified_by,v_dflt_usr)
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
               un_prop,
               1,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
        nvl(dec.created_by,v_dflt_usr),
               nvl(dec.date_created,v_dflt_date) ,
               nvl(NVL (dec.date_modified, dec.date_created), v_dflt_date),
               nvl(dec.modified_by,v_dflt_usr)
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
               un_oc,
               1,
               prop.ITEM_ID,
               prop.VER_NR,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
        nvl(dec.created_by,v_dflt_usr),
               nvl(dec.date_created,v_dflt_date) ,
               nvl(NVL (dec.date_modified, dec.date_created), v_dflt_date),
               nvl(dec.modified_by,v_dflt_usr)
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
               un_oc,
               1,
               un_prop,
               1,
               dec.OBJ_CLASS_QUALIFIER,
               dec.PROPERTY_QUALIFIER,
        nvl(dec.created_by,v_dflt_usr),
               nvl(dec.date_created,v_dflt_date) ,
               nvl(NVL (dec.date_modified, dec.date_created), v_dflt_date),
               nvl(dec.modified_by,v_dflt_usr)
          FROM sbr.data_element_concepts dec, admin_item ai, admin_item cd
         WHERE     ai.NCI_IDSEQ = dec.dec_IDSEQ
               AND cd.admin_item_typ_id = 1
               AND dec.cd_idseq = cd.NCI_IDSEQ
               AND dec.oc_idseq IS NULL
               AND dec.prop_idseq IS NULL;

    COMMIT;


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
nvl(vd.created_by,v_dflt_usr),
               nvl(vd.date_created,v_dflt_date) ,
               nvl(NVL (vd.date_modified, vd.date_created), v_dflt_date),
               nvl(vd.modified_by,v_dflt_usr),
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
      nvl(de.created_by,v_dflt_usr),
               nvl(de.date_created,v_dflt_date) ,
               nvl(NVL (de.date_modified, de.date_created), v_dflt_date),
               nvl(de.modified_by,v_dflt_usr)
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
               nvl(cdr.created_by,v_dflt_usr),
               nvl(cdr.date_created,v_dflt_date) ,
               nvl(NVL (cdr.date_modified, cdr.date_created), v_dflt_date),
               nvl(cdr.modified_by,v_dflt_usr)
          --, qc.DISPLAY_ORDER
          --, qc.DATE_CREATED,qc.CREATED_BY,qc.MODIFIED_BY,DATE_MODIFIED
          FROM admin_item                    prnt,
               admin_item                    child,
               sbr.complex_de_relationships  cdr
         WHERE     prnt.nci_idseq = cdr.p_de_idseq
               AND child.nci_idseq = cdr.c_de_idseq;

    COMMIT;
END;

PROCEDURE            sp_create_ai_4
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_oc_recs;

    COMMIT;

    DELETE FROM admin_item
          WHERE admin_item_typ_id = 56;

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
        SELECT ac.ocr_idseq,
               56,
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
               ac.ocr_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               --ac.unresolved_issue,
               ac.version,
               nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
          FROM sbrext.oc_recs_ext ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is not null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO NCI_OC_RECS (ITEM_ID,
                             VER_NR,
                             TRGT_OBJ_CLS_ITEM_ID,
                             TRGT_OBJ_CLS_VER_NR,
                             SRC_OBJ_CLS_ITEM_ID,
                             SRC_OBJ_CLS_VER_NR,
                             REL_TYP_NM,
                             SRC_ROLE,
                             TRGT_ROLE,
                             DRCTN,
                             SRC_LOW_MULT,
                             SRC_HIGH_MULT,
                             TRGT_LOW_MULT,
                             TRGT_HIGH_MULT,
                             DISP_ORD,
                             DIMNSNLTY,
                             ARRAY_IND)
        SELECT ocr.ocr_id,
               ocr.version,
               toc.item_id,
               toc.ver_nr,
               soc.item_id,
               soc.ver_nr,
               rl_name,
               source_role,
               target_role,
               direction,
               source_low_multiplicity,
               source_high_multiplicity,
               target_low_multiplicity,
               target_high_multiplicity,
               display_order,
               dimensionality,
               array_ind
          FROM sbrext.oc_recs_ext ocr, admin_item soc, admin_item toc
         WHERE     soc.admin_item_typ_id = 5
               AND toc.admin_item_typ_id = 5
               AND ocr.t_oc_idseq = toc.nci_idseq
               AND ocr.s_oc_idseq = soc.nci_idseq;

    COMMIT;
END;

PROCEDURE            sp_create_ai_children
AS
    v_cnt   INTEGER;
BEGIN
    -- Alternate Definitions
    DELETE FROM alt_def;

    COMMIT;

    INSERT INTO alt_def (ITEM_ID,
                         VER_NR,
                         CNTXT_ITEM_ID,
                         CNTXT_VER_NR,
                         DEF_DESC,
                         NCI_DEF_TYP_ID,
                         LANG_ID,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID,
                         NCI_IDSEQ)
        SELECT ai.item_id,
               ai.ver_nr,
               cntxt.item_id,
               cntxt.ver_nr,
               definition,
               ok.obj_key_id,
               DECODE (UPPER (lae_name),
                       'ENGLISH', 1000,
                       'ICELANDIC', 1007,
                       'SPANISH', 1004),
      nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr),
               def.defin_idseq
          FROM admin_item       ai,
               sbr.definitions  def,
               admin_item       cntxt,
               obj_key          ok
         WHERE     ai.nci_idseq = def.ac_idseq
               AND def.conte_idseq = cntxt.nci_idseq
               AND cntxt.admin_item_typ_id = 8
               AND def.defl_name = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 15;

    -- Alternate Names
    DELETE FROM alt_nms;

    COMMIT;

    INSERT INTO alt_nms (ITEM_ID,
                         VER_NR,
                         CNTXT_ITEM_ID,
                         CNTXT_VER_NR,
                         NM_DESC,
                         NM_TYP_ID,
                         LANG_ID,
                         CREAT_USR_ID,
                         CREAT_DT,
                         LST_UPD_DT,
                         LST_UPD_USR_ID,
                         CNTXT_NM_DN,
                         NCI_IDSEQ)
        SELECT ai.item_id,
               ai.ver_nr,
               cntxt.item_id,
               cntxt.ver_nr,
               name,
               ok.obj_key_id,
               DECODE (UPPER (lae_name),
                       'ENGLISH', 1000,
                       'ICELANDIC', 1007,
                       'SPANISH', 1004),
      nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr),
               cntxt.ITEM_NM,
               def.desig_idseq
          FROM admin_item        ai,
               sbr.designations  def,
               admin_item        cntxt,
               obj_key           ok
         WHERE     ai.nci_idseq = def.ac_idseq
               AND def.conte_idseq = cntxt.nci_idseq
               AND cntxt.admin_item_typ_id = 8
               AND def.detl_name = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 11;

    COMMIT;

    -- Reference Documents
    DELETE FROM REF;

    COMMIT;

    INSERT INTO REF (ITEM_ID,
                     VER_NR,
                     NCI_CNTXT_ITEM_ID,
                     NCI_CNTXT_VER_NR,
                     REF_TYP_ID,
                     DISP_ORD,
                     REF_DESC,
                     REF_NM,
                     LANG_ID,
                     URL,
                     CREAT_USR_ID,
                     CREAT_DT,
                     LST_UPD_DT,
                     LST_UPD_USR_ID,
                     NCI_IDSEQ)
        SELECT ai.item_id,
               ai.ver_nr,
               cntxt.item_id,
               cntxt.ver_nr,
               ok.obj_key_id,
               display_order,
               doc_text,
               name,
               DECODE (UPPER (lae_name),
                       'ENGLISH', 1000,
                       'ICELANDIC', 1007,
                       'SPANISH', 1004),
               URL,
      nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr),
               rd_idseq
          FROM admin_item               ai,
               sbr.reference_documents  def,
               admin_item               cntxt,
               obj_key                  ok
         WHERE     ai.nci_idseq = def.ac_idseq
               AND def.conte_idseq = cntxt.nci_idseq
               AND cntxt.admin_item_typ_id = 8
               AND def.dctl_name = ok.nci_cd(+)
               AND ok.obj_typ_id(+) = 1;

    COMMIT;


    DELETE FROM NCI_CSI_ALT_DEFNMS;

    COMMIT;



    INSERT INTO NCI_CSI_ALT_DEFNMS (NCI_PUB_ID,
                                    NCI_VER_NR,
                                    NMDEF_ID,
                                    TYP_NM)
        --,
        --CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
        SELECT DISTINCT ak.NCI_PUB_ID,
                        ak.NCI_VER_NR,
                        NM_ID,
                        atl_name
          --att.created_by, att.date_created,
          --att.date_modified, att.modified_by
          FROM nci_admin_item_rel_alt_key  ak,
               sbrext.AC_ATT_CSCSI_EXT     att,
               alt_nms                     am
         WHERE     ak.nci_idseq = att.cs_csi_idseq
               AND am.nci_idseq = att.att_idseq
               AND atl_name = 'DESIGNATION'
               AND ak.nci_idseq IS NOT NULL;

    COMMIT;



    INSERT INTO NCI_CSI_ALT_DEFNMS (NCI_PUB_ID,
                                    NCI_VER_NR,
                                    NMDEF_ID,
                                    TYP_NM)
        --CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
        SELECT DISTINCT ak.NCI_PUB_ID,
                        ak.NCI_VER_NR,
                        DEF_ID,
                        atl_name
          --att.created_by, att.date_created,
          --att.date_modified, att.modified_by
          FROM nci_admin_item_rel_alt_key  ak,
               sbrext.AC_ATT_CSCSI_EXT     att,
               alt_def                     am
         WHERE     ak.nci_idseq = att.cs_csi_idseq
               AND am.nci_idseq = att.att_idseq
               AND atl_name = 'DEFINITION';

    COMMIT;
END;

PROCEDURE            sp_create_ai_cncpt
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM cncpt_admin_item;

    COMMIT;

    DELETE FROM cncpt;

    COMMIT;

    -- Concept and concept relationships
    DELETE FROM admin_item
          WHERE admin_item_typ_id = 49;

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
        SELECT ac.con_idseq,
               49,
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
               ac.con_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
           nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr),
             ac.DEFINITION_SOURCE
          FROM sbrext.concepts_ext ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO cncpt (item_id,
                       ver_nr,
                       evs_src_id,
                       CREAT_USR_ID,
                       CREAT_DT,
                       LST_UPD_DT,
                       LST_UPD_USR_ID)
        SELECT con_id,
               version,
               ok.obj_key_id,
        nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
          FROM sbrext.concepts_ext c, obj_key ok
         WHERE c.evs_source = ok.obj_key_desc(+) AND ok.obj_typ_id(+) = 23;

    COMMIT;


    -- Object class-Concept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               oc.item_id,
               oc.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
           FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbrext.object_classes_ext      oce,
               admin_item                     con,
               admin_item                     oc
         WHERE     cc.CONDR_IDSEQ = oce.CONDR_IDSEQ
               AND oce.oc_idseq = oc.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;



    -- Property- Concept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               prop.item_id,
               prop.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbrext.properties_ext          prope,
               admin_item                     con,
               admin_item                     prop
         WHERE     cc.CONDR_IDSEQ = prope.CONDR_IDSEQ
               AND prope.prop_idseq = prop.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;


    -- Representation CLass - COncept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               rep.item_id,
               rep.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbrext.representations_ext     repe,
               admin_item                     con,
               admin_item                     rep
         WHERE     cc.CONDR_IDSEQ = repe.CONDR_IDSEQ
               AND Repe.rep_idseq = rep.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;


    -- Value Meaning  - COncept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               rep.item_id,
               rep.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbr.value_meanings             vm,
               admin_item                     con,
               admin_item                     rep
         WHERE     cc.CONDR_IDSEQ = vm.CONDR_IDSEQ
               AND vm.vm_idseq = rep.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;


    -- Value Domain  - COncept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               vd.item_id,
               vd.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbr.value_domains              vde,
               admin_item                     con,
               admin_item                     vd
         WHERE     cc.CONDR_IDSEQ = vde.CONDR_IDSEQ
               AND vde.vd_idseq = vd.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;


    -- Conceptual Domain  - COncept relationship

    INSERT INTO cncpt_admin_item (cncpt_item_id,
                                  cncpt_ver_nr,
                                  item_id,
                                  ver_nr,
                                  nci_ord,
                                  nci_prmry_ind,
                                  nci_cncpt_val,
                                  CREAT_USR_ID,
                                  CREAT_DT,
                                  LST_UPD_DT,
                                  LST_UPD_USR_ID)
        SELECT con.item_id,
               con.ver_nr,
               cd.item_id,
               cd.ver_nr,
               cc.DISPLAY_ORDER,
               DECODE (cc.primary_flag_ind,  'Yes', 1,  'No', 0),
               concept_value,
        nvl(cc.created_by,v_dflt_usr),
               nvl(cc.date_created,v_dflt_date) ,
               nvl(NVL (cc.date_modified, cc.date_created), v_dflt_date),
               nvl(cc.modified_by,v_dflt_usr)
          FROM sbrext.COMPONENT_CONCEPTS_EXT  cc,
               sbr.conceptual_domains         cde,
               admin_item                     con,
               admin_item                     cd
         WHERE     cc.CONDR_IDSEQ = cde.CONDR_IDSEQ
               AND cde.cd_idseq = cd.nci_idseq
               AND cc.con_idseq = con.nci_idseq;

    COMMIT;
END;

PROCEDURE            sp_create_csi
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM admin_item
          WHERE admin_item_typ_id = 51;

    COMMIT;

    DELETE FROM nci_clsfctn_schm_item;

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
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID)
        SELECT ac.csi_idseq,
               51,
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
               ac.csi_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
      nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr)
            FROM sbr.cs_items ac, admin_item cntxt, stus_mstr s
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is not null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;

/*
    INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID,
                                       CS_ITEM_ID, CS_VER_NR, P_CSI_ITEM_ID, P_CSI_VER_NR)
        SELECT cd.CSI_id,
               cd.version,
               ok.obj_key_id,
               description,
               comments,
      nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr),
               cs.ITEM_ID, CS.VER_NR, pcsi.ITEM_ID, pcsi.VER_NR
          FROM sbr.cs_items cd, obj_key ok, sbr.cs_csi cscsi, vw_CLSFCTN_SCHM cs, vw_clsfctn_schm_item pcsi
         WHERE     TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20 and 
               cd.csi_idseq = cscsi.csi_idseq and 
               cscsi.cs_idseq = cs.nci_idseq and 
               cscsi.p_cs_csi_idseq = pcsi.nci_idseq (+);

    COMMIT;
*/

 INSERT INTO NCI_CLSFCTN_SCHM_ITEM (item_id,
                                       ver_nr,
                                       CSI_TYP_ID,
                                       CSI_DESC_TXT,
                                       CSI_CMNTS,
                                       CREAT_USR_ID,
                                       CREAT_DT,
                                       LST_UPD_DT,
                                       LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               ok.obj_key_id,
               description,
               comments,
       nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created, v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
          FROM sbr.cs_items cd, admin_item ai, obj_key ok
         WHERE     ai.NCI_IDSEQ = cd.CSI_IDSEQ
               AND TRIM (csitl_name) = ok.nci_cd
               AND ok.obj_typ_id = 20;

    COMMIT;

    -- cs_csi - give it an alternate key.
    DELETE FROM nci_admin_item_rel_alt_key
          WHERE rel_typ_id = 64;

    COMMIT;

    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            P_ITEM_ID,
                                            P_ITEM_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               pcsi.item_id,
               pcsi.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
            FROM admin_item  cs,
               admin_item  pcsi,
               admin_item  ccsi,
               sbr.cs_csi  cscsi,
               sbr.cs_csi  pcscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NOT NULL
               AND pcscsi.cs_csi_idseq = cscsi.p_cs_csi_idseq
               AND pcscsi.csi_idseq = pcsi.nci_idseq
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;


    INSERT INTO nci_admin_item_rel_alt_key (CNTXT_CS_ITEM_ID,
                                            CNTXT_CS_VER_NR,
                                            C_ITEM_ID,
                                            C_ITEM_VER_NR,
                                            DISP_ORD,
                                            DISP_LBL,
                                            NCI_VER_NR,
                                            REL_TYP_ID,
                                            NCI_IDSEQ,
                                            CREAT_USR_ID,
                                            CREAT_DT,
                                            LST_UPD_DT,
                                            LST_UPD_USR_ID)
        SELECT cs.item_id,
               cs.ver_nr,
               ccsi.item_id,
               ccsi.ver_nr,
               cscsi.DISPLAY_ORDER,
               cscsi.label,
               1,
               64,
               cscsi.CS_CSI_IDSEQ,
      nvl(cscsi.created_by,v_dflt_usr),
               nvl(cscsi.date_created,v_dflt_date) ,
               nvl(NVL (cscsi.date_modified, cscsi.date_created), v_dflt_date),
               nvl(cscsi.modified_by,v_dflt_usr)
          FROM admin_item cs, admin_item ccsi, sbr.cs_csi cscsi
         WHERE     cscsi.cs_idseq = cs.nci_idseq
               AND cscsi.p_cs_csi_idseq IS NULL
               AND cscsi.csi_idseq = ccsi.nci_idseq;

    COMMIT;
END;

procedure sp_create_csi_2
as
v_cnt integer;
begin

delete from NCI_ALT_KEY_ADMIN_ITEM_REL where rel_typ_id = 65;
commit;

insert into NCI_ALT_KEY_ADMIN_ITEM_REL (NCI_PUB_ID  ,  NCI_VER_NR  , C_ITEM_ID ,  C_ITEM_VER_NR ,  REL_TYP_ID,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ak.nci_pub_id, ak.nci_ver_nr, ai.item_id, ai.ver_nr, 65,
     nvl(accsi.created_by,v_dflt_usr),
               nvl(accsi.date_created,v_dflt_date) ,
               nvl(NVL (accsi.date_modified, accsi.date_created), v_dflt_date),
               nvl(accsi.modified_by,v_dflt_usr)
 from  sbr.ac_csi accsi, nci_admin_item_rel_alt_key ak, admin_item ai
where accsi.ac_idseq = ai.nci_idseq and
 accsi.cs_csi_idseq = ak.nci_idseq and ak.rel_typ_id = 64;
commit;


end;


procedure sp_migrate_lov 
as
v_cnt integer;
begin
delete from stus_mstr;
commit;

v_cnt := 1;

for cur in (select registration_status,description,
                    comments,created_by, date_created,
                    nvl(date_modified, date_created) date_modified, modified_by,
                    display_order from sbr.reg_status_lov order by display_order) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.registration_status, cur.registration_status, cur.description, cur.comments, nvl(cur.created_by, v_dflt_usr), nvl(cur.date_created,v_dflt_date),
nvl(nvl(cur.date_modified,cur.date_created), v_dflt_date), nvl(cur.modified_by, v_dflt_usr), cur.display_order, 1);
v_cnt := v_cnt + 1;

end loop;

v_cnt := 50;

for cur in (select asl_name,description,
                    comments,created_by, date_created,
                    nvl(date_modified, date_created) date_modified, modified_by,
                    display_order from sbr.ac_status_lov order by asl_name) loop
insert into stus_mstr (STUS_ID, NCI_STUS,STUS_NM, STUS_DESC,
                        NCI_CMNTS,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
                        NCI_DISP_ORDR,STUS_TYP_ID )
values (v_cnt, cur.asl_name, cur.asl_name, cur.description, cur.comments, nvl(cur.created_by, v_dflt_usr), nvl(cur.date_created,v_dflt_date),
nvl(nvl(cur.date_modified,cur.date_created), v_dflt_date), nvl(cur.modified_by, v_dflt_usr), cur.display_order, 2);
v_cnt := v_cnt + 1;
end loop;
commit;



delete from obj_key where obj_typ_id = 14;  -- Program Area
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 14, pal_name, description, pal_name, comments,               nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
 from sbr.PROGRAM_AREAS_LOV;
commit;


delete from obj_key where obj_typ_id = 11;  -- Name/designation
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 11, detl_name, description, detl_name, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.DESIGNATION_TYPES_LOV;
commit;

-- DOcument type
delete from obj_key where obj_typ_id = 1;  -- 
commit;

-- Preferred Question Text ID needs to be static. Used in views.
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, NCI_CD) values (80,1,'Preferred Question Text', 'Preferred Question Text for Data Element','Preferred Question Text');
commit;

insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 1, DCTL_NAME, description, DCTL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.document_TYPES_LOV where DCTL_NAME not like 'Preferred Question Text';
commit;


-- Classification Scheme Type
delete from obj_key where obj_typ_id = 3;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 3, CSTL_NAME, description, CSTL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.CS_TYPES_LOV;
commit;

-- Classification Scheme Item Type
delete from obj_key where obj_typ_id = 20;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 20, CSITL_NAME, description, CSITL_NAME, comments,  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.CSI_TYPES_LOV;
commit;

-- Protocol Type
delete from obj_key where obj_typ_id = 19;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd) 
select distinct 19, TYPE, TYPE from sbrext.protocols_ext where type is not null ;
commit;



-- Concept Source
delete from obj_key where obj_typ_id = 23;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select  23, CONCEPT_SOURCE,DESCRIPTION, CONCEPT_SOURCE,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbrext.concept_sources_lov_ext ;
commit;



-- NCI Derivation Type
delete from obj_key where obj_typ_id = 21;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc,  nci_cd, obj_key_def,  CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 21, CRTL_NAME,CRTL_NAME, DESCRIPTION ,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.complex_rep_type_lov ;
commit;



--- Data type

delete from data_typ;
commit;
insert into data_typ ( DTTYPE_NM, NCI_CD, DTTYPE_DESC, NCI_DTTYPE_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID,
DTTYPE_SCHM_REF, DTTYPE_ANNTTN)
select DTL_NAME, DTL_NAME, DESCRIPTION,COMMENTS,
  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr), SCHEME_REFERENCE, ANNOTATION from sbr.datatypes_lov;
commit;

-- Format
delete from FMT;
commit;
insert into FMT ( FMT_NM, NCI_CD,FMT_DESC,FMT_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select FORML_NAME, FORML_NAME,DESCRIPTION,COMMENTS,
  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.formats_lov;
commit;

-- UOM
delete from UOM;
commit;
insert into UOM ( UOM_NM,NCI_CD, UOM_PREC,UOM_DESC,UOM_CMNTS,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select UOML_NAME,UOML_NAME,PRECISION,
DESCRIPTION,COMMENTS,
  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.unit_of_measures_lov;
commit;




-- Definition type
delete from obj_key where obj_typ_id = 15;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 15, DEFL_NAME, description, DEFL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbrext.definition_types_lov_ext;


commit;





-- Origin
delete from obj_key where obj_typ_id = 18;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 18, SRC_NAME, description, SRC_NAME,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbrext.sources_ext;


commit;

-- Form Category
delete from obj_key where obj_typ_id = 22;  -- 
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID, DISP_ORD) 
select 22, QCDL_NAME, description, QCDL_NAME,    nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr), DISPLAY_ORDER from sbrext.QC_DISPLAY_LOV_EXT;


commit;


-- GEt standard data types from Excel spreadsheet

update data_typ set nci_dttype_typ_id = 1;
commit;
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ALPHANUMERIC';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'anyClass';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'binary';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'BOOLEAN';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CHARACTER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'CLOB';
update data_typ set NCI_DTTYPE_MAP = 'Date' where DTTYPE_NM = 'DATE';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Date Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'DATE/TIME';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'DATETIME';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'Derived';
update data_typ set NCI_DTTYPE_MAP = 'Class' where DTTYPE_NM = 'HL7CDv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7EDv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'HL7INTv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7PNv3';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'HL7REALv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7STv3';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'HL7TELv3';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'HL7TSv3';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'Integer';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADPartv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCNTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPCTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPDALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPSTAv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ADXPZIPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ANYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090BAGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'ISO21090BLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090CDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090DSETv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDTEXTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090EDv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENONv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENPNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENTNv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090ENXPv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTNTNEGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTPOSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090INTv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090IVLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090PQTIMEv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090PQv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090QTYv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090REALv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090RTOv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STSIMv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090STv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELURLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'ISO21090TELv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDATFLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'ISO21090TSDTTIv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'ISO21090TSv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'ISO21090Tv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'ISO21090URGv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'java.lang.Boolean';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Byte';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.Character';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'java.lang.Double';
update data_typ set NCI_DTTYPE_MAP = 'Floating-point' where DTTYPE_NM = 'java.lang.Float';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Integer[]';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Long';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'java.lang.Object';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'java.lang.Short';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.lang.String[]';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.sql.Timestamp';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Collection';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'java.util.Date';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'java.util.Map';
update data_typ set NCI_DTTYPE_MAP = 'Real' where DTTYPE_NM = 'NUMBER';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'Numeric Alpha DVG';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'OBJECT';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Date';
update data_typ set NCI_DTTYPE_MAP = 'Integer' where DTTYPE_NM = 'SAS Time';
update data_typ set NCI_DTTYPE_MAP = 'Time' where DTTYPE_NM = 'TIME';
update data_typ set NCI_DTTYPE_MAP = 'Bit String' where DTTYPE_NM = 'UMLBinaryv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLCodev1.0';
update data_typ set NCI_DTTYPE_MAP = 'Octet' where DTTYPE_NM = 'UMLOctetv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUidv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLUriv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'UMLXMLv1.0';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'varchar';
update data_typ set NCI_DTTYPE_MAP = 'Boolean' where DTTYPE_NM = 'xsd:boolean';
update data_typ set NCI_DTTYPE_MAP = 'Date-and-Time' where DTTYPE_NM = 'xsd:dateTime';
update data_typ set NCI_DTTYPE_MAP = 'Character' where DTTYPE_NM = 'xsd:string';
commit;

update data_typ set NCI_DTTYPE_MAP = 'Character' where NCI_DTTYPE_MAP is null;
commit;

-- insert standard datatypes
insert into data_typ(dttype_nm, nci_dttype_typ_id)
select distinct NCI_DTTYPE_MAP, 2 from data_typ where NCI_DTTYPE_MAP is not null;
commit;



delete from lang;
commit;

INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1007, 'ICELANDIC', 'Icelandic'); 
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1000, 'ENGLISH', 'English'); 
commit;
INSERT INTO LANG ( CNTRY_ISO_CD, LANG_ISO_CD, LANG_ID, LANG_NM,
LANG_DESC ) VALUES ( 
NULL, NULL, 1004, 'SPANISH', 'Spanish'); 
commit;
commit;



delete from obj_key where obj_typ_id = 25;  -- Address Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 25, ATL_NAME, description, ATL_NAME, comments,   nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.ADDR_TYPES_LOV	;
commit;

delete from obj_key where obj_typ_id = 26;  -- Communication Type
commit;
insert into obj_key (obj_typ_id, obj_key_desc, obj_key_def, nci_cd,obj_key_cmnts, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID) 
select 26, CTL_NAME, description, CTL_NAME, comments,  nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr) from sbr.COMM_TYPES_LOV;
	
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, obj_key_id, 
              nvl(e.date_created,v_dflt_date) ,
  nvl(e.created_by,v_dflt_usr),
                nvl(NVL (e.date_modified, e.date_created), v_dflt_date),
               nvl(e.modified_by,v_dflt_usr)
from sbrext.ASL_ACTL_EXT e, stus_mstr s, obj_key o
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and o.nci_cd = e.ACTL_NAME and o.obj_typ_id = 4;
commit;


insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 53,               nvl(e.date_created,v_dflt_date) ,
  nvl(e.created_by,v_dflt_usr),
                nvl(NVL (e.date_modified, e.date_created), v_dflt_date),
               nvl(e.modified_by,v_dflt_usr)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'VALUE_MEANING';
commit;

--Form
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 54,               nvl(e.date_created,v_dflt_date) ,
  nvl(e.created_by,v_dflt_usr),
                nvl(NVL (e.date_modified, e.date_created), v_dflt_date),
               nvl(e.modified_by,v_dflt_usr)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';
commit;

--Module
insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select stus_id, 52,              nvl(e.date_created,v_dflt_date) ,
  nvl(e.created_by,v_dflt_usr),
                nvl(NVL (e.date_modified, e.date_created), v_dflt_date),
               nvl(e.modified_by,v_dflt_usr)
from sbrext.ASL_ACTL_EXT e, stus_mstr s
where e.ASL_NAME = s.nci_stus and s.stus_typ_id = 2 and e.ACTL_NAME = 'QUEST_CONTENT';
commit;

-- Adding DRAFT-new for all Admin_item_types

insert into NCI_AI_TYP_VALID_STUS (STUS_ID,ADMIN_ITEM_TYP_ID)
select 66, obj_key_id from 
(select obj_key_id from vw_obj_key_4 
minus
select admin_item_typ_id from NCI_AI_TYP_VALID_STUS where stus_id = 66);
commit;

end;

PROCEDURE            sp_create_form_ext
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
     nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
               nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
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
     nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
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
     nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
               nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
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
     nvl(p.created_by,v_dflt_usr),
               nvl(p.date_created,v_dflt_date) ,
               nvl(NVL (p.date_modified, p.date_created), v_dflt_date),
               nvl(p.modified_by,v_dflt_usr)
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
nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr),
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


PROCEDURE            sp_create_form_question_rel
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
                                            ITEM_LONG_NM,
        DISP_ORD,
        CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
        SELECT  MOD.item_id,
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
          , qc.DISPLAY_ORDER,
               nvl(qc.date_created,v_dflt_date) ,
          nvl(qc.created_by,v_dflt_usr),
               nvl(qc.modified_by,v_dflt_usr),
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date)
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
                                            ITEM_LONG_NM,
                                            ITEM_NM,
        DISP_LBL,
        CREAT_DT, CREAT_USR_ID, LST_UPD_USR_ID, LST_UPD_DT)
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
          , qc.PREFERRED_NAME
          , qc.DISPLAY_ORDER
          , nvl(qc.date_created,v_dflt_date) ,
          nvl(qc.created_by,v_dflt_usr),
               nvl(qc.modified_by,v_dflt_usr),
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date)
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

PROCEDURE            sp_create_form_rel
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

 PROCEDURE            sp_create_form_ta
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_form_ta_rel;

    COMMIT;

    DELETE FROM nci_form_ta;

    COMMIT;


    --MODULE MODULE

    INSERT INTO NCI_FORM_TA (SRC_PUB_ID,
                             SRC_VER_NR,
                             TRGT_PUB_ID,
                             TRGT_VER_NR,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT)
        SELECT mod1.item_id,
               mod1.ver_nr,
               mod2.item_id,
               mod2.ver_nr,
               TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
               nvl(ta.date_created,v_dflt_date) ,
          nvl(ta.created_by,v_dflt_usr),
               nvl(ta.modified_by,v_dflt_usr),
             nvl(NVL (ta.date_modified, ta.date_created), v_dflt_date)
          FROM sbrext.triggered_actions_ext  ta,
               admin_item                    mod1,
               admin_item                    mod2
         WHERE     mod1.admin_item_typ_id = 52
               AND mod2.admin_item_typ_id = 52
               AND ta.s_qc_idseq = mod1.nci_idseq
               AND ta.t_qc_idseq = mod2.nci_idseq;

    COMMIT;

    --MODULE QUESTION

    INSERT INTO NCI_FORM_TA (SRC_PUB_ID,
                             SRC_VER_NR,
                             TRGT_PUB_ID,
                             TRGT_VER_NR,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT)
        SELECT mod1.item_id,
               mod1.ver_nr,
               quest.nci_pub_id,
               quest.nci_ver_nr,
               TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
               nvl(ta.date_created,v_dflt_date) ,
          nvl(ta.created_by,v_dflt_usr),
               nvl(ta.modified_by,v_dflt_usr),
             nvl(NVL (ta.date_modified, ta.date_created), v_dflt_date)
          FROM sbrext.triggered_actions_ext  ta,
               admin_item                    mod1,
               nci_admin_item_rel_alt_key    quest
         WHERE     mod1.admin_item_typ_id = 52
               AND quest.rel_typ_id = 63
               AND ta.s_qc_idseq = mod1.nci_idseq
               AND ta.t_qc_idseq = quest.nci_idseq;

    COMMIT;


    -- QUESTION QUESTION


    INSERT INTO NCI_FORM_TA (SRC_PUB_ID,
                             SRC_VER_NR,
                             TRGT_PUB_ID,
                             TRGT_VER_NR,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT)
        SELECT quest1.nci_pub_id,
               quest1.nci_ver_nr,
               quest2.nci_pub_id,
               quest2.nci_ver_nr,
               TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
               nvl(ta.date_created,v_dflt_date) ,
          nvl(ta.created_by,v_dflt_usr),
               nvl(ta.modified_by,v_dflt_usr),
             nvl(NVL (ta.date_modified, ta.date_created), v_dflt_date)
          FROM sbrext.triggered_actions_ext  ta,
               nci_admin_item_rel_alt_key    quest1,
               nci_admin_item_rel_alt_key    quest2
         WHERE     --quest1.rel_typ_id = 63
                   --and quest2.rel_typ_id = 63 and
                   ta.s_qc_idseq = quest1.nci_idseq
               AND ta.t_qc_idseq = quest2.nci_idseq;

    COMMIT;

    --VALID_VALUE QUESTION


    INSERT INTO NCI_FORM_TA (SRC_PUB_ID,
                             SRC_VER_NR,
                             TRGT_PUB_ID,
                             TRGT_VER_NR,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT)
        SELECT vv.nci_pub_id,
               vv.nci_ver_nr,
               quest.nci_pub_id,
               quest.nci_ver_nr,
               TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
nvl(ta.date_created,v_dflt_date) ,
          nvl(ta.created_by,v_dflt_usr),
               nvl(ta.modified_by,v_dflt_usr),
             nvl(NVL (ta.date_modified, ta.date_created), v_dflt_date)
             FROM sbrext.triggered_actions_ext  ta,
               nci_quest_Valid_value         vv,
               nci_admin_item_rel_alt_key    quest
         WHERE     quest.rel_typ_id = 63
               AND ta.s_qc_idseq = vv.nci_idseq
               AND ta.t_qc_idseq = quest.nci_idseq;

    COMMIT;

    --VALID_VALUE MODULE


    INSERT INTO NCI_FORM_TA (SRC_PUB_ID,
                             SRC_VER_NR,
                             TRGT_PUB_ID,
                             TRGT_VER_NR,
                             TA_INSTR,
                             SRC_TYP_NM,
                             TRGT_TYP_NM,
                             TA_IDSEQ,
                             CREAT_DT,
                             CREAT_USR_ID,
                             LST_UPD_USR_ID,
                             LST_UPD_DT)
        SELECT vv.nci_pub_id,
               vv.nci_ver_nr,
               MOD.item_id,
               MOD.ver_nr,
               TA_INSTRUCTION,
               S_QTL_NAME,
               T_QTL_NAME,
               TA_IDSEQ,
               nvl(ta.date_created,v_dflt_date) ,
          nvl(ta.created_by,v_dflt_usr),
               nvl(ta.modified_by,v_dflt_usr),
             nvl(NVL (ta.date_modified, ta.date_created), v_dflt_date)
          FROM sbrext.triggered_actions_ext  ta,
               nci_quest_Valid_value         vv,
               admin_item                    MOD
         WHERE     MOD.admin_item_typ_id = 52
               AND ta.s_qc_idseq = vv.nci_idseq
               AND ta.t_qc_idseq = MOD.nci_idseq;

    COMMIT;

    INSERT INTO NCI_FORM_TA_REL (TA_ID,
                                 NCI_PUB_ID,
                                 NCI_VER_NR,
                                 CREAT_DT,
                                 CREAT_USR_ID,
                                 LST_UPD_USR_ID,
                                 LST_UPD_DT)
        SELECT ta.ta_id,
               ai.item_id,
               ai.ver_nr,
               nvl(t.date_created,v_dflt_date) ,
          nvl(t.created_by,v_dflt_usr),
               nvl(t.modified_by,v_dflt_usr),
             nvl(NVL (t.date_modified, t.date_created), v_dflt_date)
          FROM nci_form_ta ta, sbrext.ta_proto_csi_ext t, admin_item ai
         WHERE     ta.ta_idseq = t.ta_idseq
               AND t.proto_idseq = ai.nci_idseq
               AND t.proto_idseq IS NOT NULL;

    COMMIT;
END;

 PROCEDURE            sp_create_form_vv_inst
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
          nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr), qc.DISPLAY_ORDER
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
          nvl(qvv.created_by,v_dflt_usr),
               nvl(qvv.date_created,v_dflt_date) ,
             nvl(NVL (qvv.date_modified, qvv.date_created), v_dflt_date),
               nvl(qvv.modified_by,v_dflt_usr)
          FROM sbrext.quest_vv_ext         qvv,
               NCI_ADMIN_ITEM_REL_ALT_KEY  q,
               NCI_QUEST_VALID_VALUE       vv
         WHERE     qvv.quest_idseq = q.NCI_IDSEQ
               AND qvv.vv_idseq = vv.NCI_IDSEQ(+);

    COMMIT;
END;

 procedure            sp_create_form_vv_inst_2
as
v_cnt integer;
begin

delete from nci_instr;
commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FORM_INSTR' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'FORM', 'FOOTER',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'FOOTER' and 
qc.dn_crf_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.item_id, 'MODULE', 'INSTRUCTION',ai.VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, admin_item ai where qc.qtl_name = 'MODULE_INSTR' and 
qc.p_mod_idseq = ai.nci_idseq;

commit;

insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, NCI_TYP, NCI_VER_NR, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF,
CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'QUESTION', 'INSTRUCTION',ai.NCI_VER_NR, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition,
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
        from sbrext.quest_contents_ext qc, Nci_admin_item_rel_alt_key ai where qc.qtl_name = 'QUESTION_INSTR' and ai.rel_typ_id = 63 and
qc.p_qst_idseq = ai.nci_idseq;

commit;


insert into NCI_INSTR
(NCI_PUB_ID, NCI_LVL, nci_ver_nr, SEQ_NR,INSTR_LNG, INSTR_SHRT, INSTR_DEF, NCI_TYP, CREAT_USR_ID, CREAT_DT, LST_UPD_DT,LST_UPD_USR_ID)
select ai.nci_pub_id, 'VALUE',1, display_order, qc.LONG_NAME,qc.preferred_name, qc.preferred_definition, 'INSTRUCTION',
    nvl(qc.created_by,v_dflt_usr),
               nvl(qc.date_created,v_dflt_date) ,
             nvl(NVL (qc.date_modified, qc.date_created), v_dflt_date),
               nvl(qc.modified_by,v_dflt_usr)
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

PROCEDURE            sp_create_pv
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM nci_val_mean;

    COMMIT;

    -- Value Meaning
    DELETE FROM admin_item
          WHERE admin_item_typ_id = 53;

    COMMIT;


    -- Value Meaning as AI
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
                            VER_NR,
                            CREAT_USR_ID,
                            CREAT_DT,
                            LST_UPD_DT,
                            LST_UPD_USR_ID,
                            DEF_SRC)
        SELECT ac.vm_idseq,
               53,
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
               ac.vm_id,
               NVL (ac.long_name, ac.preferred_name),
               --stewa_idseq,
               ac.version,
                  nvl(ac.created_by,v_dflt_usr),
               nvl(ac.date_created,v_dflt_date) ,
               nvl(NVL (ac.date_modified, ac.date_created), v_dflt_date),
               nvl(ac.modified_by,v_dflt_usr),
               ac.definition_source
          FROM admin_item cntxt, stus_mstr s, sbr.value_meanings ac
         WHERE     ac.conte_idseq = cntxt.nci_idseq
               AND TRIM (ac.asl_name) = TRIM (s.nci_STUS)
               AND --ac.end_date is null and
                   cntxt.admin_item_typ_id = 8;

    COMMIT;


    INSERT INTO NCI_VAL_MEAN (item_id,
                              ver_nr,
                              VM_DESC_TXT,
                              VM_CMNTS,
                              CREAT_USR_ID,
                              CREAT_DT,
                              LST_UPD_DT,
                              LST_UPD_USR_ID)
        SELECT ai.item_id,
               ai.ver_nr,
               description,
               comments,
                nvl(cd.created_by,v_dflt_usr),
               nvl(cd.date_created,v_dflt_date) ,
               nvl(NVL (cd.date_modified, cd.date_created), v_dflt_date),
               nvl(cd.modified_by,v_dflt_usr)
        FROM sbr.value_meanings cd, admin_item ai
         WHERE ai.NCI_IDSEQ = cd.VM_IDSEQ;

    COMMIT;
END;

 PROCEDURE            sp_create_pv_2
AS
    v_cnt   INTEGER;
BEGIN
    DELETE FROM perm_val;

    COMMIT;

    DELETE FROM conc_dom_val_mean;

    COMMIT;

    -- Value Meaning - Conceptual Domain relationship
    INSERT INTO conc_dom_val_mean (conc_dom_item_id,
                                   conc_dom_ver_nr,
                                   nci_val_mean_item_id,
                                   nci_val_mean_ver_nr,
                                   CREAT_USR_ID,
                                   CREAT_DT,
                                   LST_UPD_DT,
                                   LST_UPD_USR_ID)
        SELECT cd.item_id,
               cd.ver_nr,
               vm.item_id,
               vm.ver_nr,
                          nvl(cvm.created_by,v_dflt_usr),
               nvl(cvm.date_created,v_dflt_date) ,
               nvl(NVL (cvm.date_modified, cvm.date_created), v_dflt_date),
               nvl(cvm.modified_by,v_dflt_usr)
          FROM admin_item cd, admin_item vm, sbr.cd_vms cvm
         WHERE cvm.cd_idseq = cd.nci_idseq AND cvm.vm_idseq = vm.nci_idseq;

    COMMIT;

    -- Permissible Values

    INSERT INTO perm_val (PERM_VAL_BEG_DT,
                          PERM_VAL_END_DT,
                          PERM_VAL_NM,
                          PERM_VAL_DESC_TXT,
                          VAL_DOM_ITEM_ID,
                          VAL_DOM_VER_NR,
                          CREAT_DT,
                          CREAT_USR_ID,
                          LST_UPD_DT,
                          LST_UPD_USR_ID,
                          NCI_VAL_MEAN_ITEM_ID,
                          NCI_VAL_MEAN_VER_NR,
                          NCI_IDSEQ)
        SELECT pvs.BEGIN_DATE,
               pvs.END_DATE,
               VALUE,
               SHORT_MEANING,
               vd.item_id,
               vd.ver_nr,
               --MEANING_DESCRIPTION,  HIGH_VALUE_NUM, LOW_VALUE_NUM,
               nvl(pvs.date_created,v_dflt_date) ,
                             nvl(pvs.created_by,v_dflt_usr),
               nvl(NVL (pvs.date_modified, pvs.date_created), v_dflt_date),
               nvl(pvs.modified_by,v_dflt_usr),
               vm.item_id,
               vm.ver_nr,
               pv.pv_idseq
          FROM sbr.permissible_Values  pv,
               admin_item              vm,
               admin_item              vd,
               sbr.vd_pvs              pvs
         WHERE     pv.pv_idseq = pvs.pv_idseq
               AND pvs.vd_idseq = vd.nci_idseq
               AND pv.vm_idseq = vm.nci_idseq;

    COMMIT;
END;

 procedure            sp_migrate_change_log
as
v_cnt integer;
begin

for cur in (select ac_idseq from sbr.administered_components) loop
insert /*+ APPEND */ into nci_change_history (ACCH_IDSEQ,
AC_IDSEQ,CHANGE_DATETIMESTAMP,CHANGE_ACTION,CHANGED_BY,
CHANGED_TABLE,CHANGED_TABLE_IDSEQ,CHANGED_COLUMN,OLD_VALUE,NEW_VALUE)
select ACCH_IDSEQ,
AC_IDSEQ,CHANGE_DATETIMESTAMP,CHANGE_ACTION,CHANGED_BY,
CHANGED_TABLE,CHANGED_TABLE_IDSEQ,CHANGED_COLUMN,OLD_VALUE,NEW_VALUE
from sbrext.AC_CHANGE_HISTORY_EXT
where ac_idseq = cur.ac_idseq;
commit;
end loop;
end;

 procedure sp_org_contact
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
 select org_idseq, 72,
 nvl(created_by,v_dflt_usr),
                nvl(date_created,v_dflt_date) ,
               nvl(modified_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date)
from sbr.organizations;
commit;

insert into nci_org (ENTTY_ID, RAI,ORG_NM,RA_IND,MAIL_ADDR,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
select e.ENTTY_ID, RAI,NAME,RA_IND,MAIL_ADDRESS,
nvl(created_by,v_dflt_usr),
                nvl(date_created,v_dflt_date) ,
               nvl(modified_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date)
from sbr.organizations o, nci_entty e where e.nci_idseq = o.org_idseq;
commit;

insert into nci_entty(NCI_IDSEQ, ENTTY_TYP_ID,CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select per_idseq, 73,
 nvl(created_by,v_dflt_usr),
                nvl(date_created,v_dflt_date) ,
               nvl(modified_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date)
from sbr.persons;
commit;


insert into nci_prsn(ENTTY_ID,LAST_NM,FIRST_NM,RNK_ORD,PRNT_ORG_ID,MI,POS,
 CREAT_USR_ID,CREAT_DT,LST_UPD_USR_ID,LST_UPD_DT)
 select e.entty_id, LNAME,FNAME,RANK_ORDER,o.entty_id,MI,POSITION,
nvl(created_by,v_dflt_usr),
                nvl(date_created,v_dflt_date) ,
               nvl(modified_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date)
 from sbr.persons p, nci_entty e, nci_entty o where e.entty_typ_id = 73 and o.entty_typ_id (+)= 72 and e.nci_idseq = p.per_idseq and p.org_idseq = o.nci_idseq (+)  ;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,
               nvl(date_created,v_dflt_date) ,
nvl(created_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26;
commit;

insert into nci_entty_comm (ENTTY_ID,COMM_TYP_ID,RNK_ORD,CYB_ADDR,CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,CYBER_ADDRESS,
               nvl(date_created,v_dflt_date) ,
nvl(created_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
from sbr.CONTACT_COMMS c, obj_key ok, nci_entty o where
per_IDSEQ is not null and c.per_idseq = o.nci_idseq and ok.nci_cd = CTL_NAME and ok.obj_typ_id = 26 ;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
               nvl(date_created,v_dflt_date) ,
nvl(created_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
from sbr.CONTACT_ADDRESSES c, obj_key ok, nci_entty o where
ORG_IDSEQ is not null and c.org_idseq = o.nci_idseq and ok.nci_cd = ATL_NAME and ok.obj_typ_id = 25;
commit;


insert into nci_entty_addr (ENTTY_ID,ADDR_TYP_ID,RNK_ORD,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CD,CNTRY,
CREAT_DT,CREAT_USR_ID,LST_UPD_DT,LST_UPD_USR_ID)
select o.entty_id, ok.obj_key_id, RANK_ORDER,ADDR_LINE1,ADDR_LINE2,CITY,STATE_PROV,POSTAL_CODE,COUNTRY,
               nvl(date_created,v_dflt_date) ,
nvl(created_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date),
               nvl(modified_by,v_dflt_usr)
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
    nvl(created_by,v_dflt_usr),
               nvl(date_created,v_dflt_date) ,
               nvl(modified_by,v_dflt_usr),
             nvl(NVL (date_modified, date_created), v_dflt_date)
        from ref r, sbr.reference_blobs rb where r.nci_idseq = rb.rd_idseq;
commit;

update admin_item set creat_usr_id_x = creat_usr_id where creat_usr_id in (select cntct_secu_id from cntct);
update admin_item set lst_upd_usr_id_x = lst_upd_usr_id where lst_upd_usr_id in (select cntct_secu_id from cntct);
 
commit;



end;

END;
/

create or replace PACKAGE nci_11179 AS
function getWordCount(v_nm in varchar2) return integer;
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2;
FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2;
 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 ;
 function cmr_guid return varchar2;
FUNCTION getPrimaryConceptName(v_nm in varchar2) return varchar2;
procedure spAddToCart ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spRemoveFromCart (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAddConceptRel (v_data_in in clob, v_data_out out clob);
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2);
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number);

function getItemId return integer;
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2);
function replaceChar(v_str in varchar2) return varchar2;

END;
/
create or replace PACKAGE BODY nci_11179 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;

/***********************************************/
FUNCTION CMR_GUID RETURN VARCHAR2 IS
  /*
  ** Name: CMR_GUID
  ** Parameters: None
  ** Description: Wrapper function to format output from
  **              built-in function sys.standard.sys_guid
  ** Change History:
  ** SAlred   4/25/2000   Initial Version; final format is TBD
  ** SAlred   4/28/2000   Added formatting according to standard
  **                      referenced on Microsoft web site.
  */
    V_GUID  CHAR(32);
    V_OUT   VARCHAR2(36);
  BEGIN
    V_GUID := RAWTOHEX(SYS.STANDARD.SYS_GUID);
    V_OUT := SUBSTR(V_GUID,1,8)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,9,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,13,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,17,4)||'-';
    V_OUT := V_OUT||SUBSTR(V_GUID,21);
    RETURN V_OUT;
  END CMR_GUID;

FUNCTION getPrimaryConceptName(v_nm in varchar2) return varchar2 is
v_out number;
v_temp varchar2(255);
i integer;
begin
i := getWordCount(v_nm);
v_temp := getWord(v_nm, i+1,i+1);
return v_temp;
end;

function getItemId return integer is
v_out integer;
begin
select od_seq_ADMIN_ITEM.nextval  into v_out from dual;
return v_out;
end;

FUNCTION getWordCount (v_nm IN varchar2) RETURN integer IS
    V_OUT   Integer;
  BEGIN
  v_out := REGEXP_COUNT( v_nm, '\s');
  
    RETURN V_OUT+1;
  END;

function replaceChar(v_str in varchar2) return varchar2 IS
    V_OUT  varchar2(255);
  BEGIN
  v_out := replace(v_str, '''','`');
  v_out := replace(v_out, '"','`');
    RETURN V_OUT;
  END;


procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2)
as
v_out integer;
begin

for cur in (select ext.* from nci_admin_item_ext ext,admin_item a where nvl(a.fld_delete,0) = 0 and a.item_id = ext.item_id and a.ver_nr = ext.ver_nr and cncpt_concat = v_nm and a.admin_item_typ_id = v_item_typ) loop
 v_item_id := cur.item_id;
 v_item_ver_nr := cur.ver_nr;
v_long_nm := cur.cncpt_concat_nm;
v_def := cur.cncpt_concat_def;
  end loop;


end;


function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2 is
   v_word  varchar2(100);
  BEGIN
  
  if (v_idx = 1 and v_idx = v_max)then
  v_word := v_nm;
  elsif  (v_idx = 1 and v_idx < v_max)then
   v_word := substr(v_nm, 1, instr(v_nm, ' ',1,1)-1);
  elsif (v_idx = v_max) then
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1);
  else
     v_word := substr(v_nm, instr(v_nm, ' ',1,v_idx-1)+1,instr(v_nm, ' ',1,v_idx)-instr(v_nm, ' ',1,v_idx-1));

  end if;
  
    RETURN trim(upper(v_word));
  END;


procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2) as
begin
for cur in (select cncpt_concat , cncpt_concat_nm , cncpt_concat_def  from nci_admin_item_ext where item_id = v_item_id and ver_nr = v_ver_nr and fld_delete = 0) loop
v_nm := cur.cncpt_concat;
v_long_nm := cur.cncpt_concat_nm;
v_def := cur.cncpt_concat_def;
end loop;
end;


FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select c.item_nm, cai.NCI_CNCPT_VAL
from cncpt_admin_item cai, admin_item c
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr 
and cai.cncpt_item_id = c.item_id and cai.cncpt_ver_nr = c.ver_nr and c.admin_item_typ_id = 49
order by  nci_ord desc;

v_name varchar2(255);

begin

for c_rec in con loop

if v_name is null then
  v_name := c_rec.item_nm;

  /* Check if Integer Concept */
    if c_rec.item_nm = 'C45255' then
        v_name := v_name||'::'||c_rec.nci_cncpt_val;
    end if;
else
   v_name := v_name||','||c_rec.item_nm;

  /* Check if Integer Concept */
  if c_rec.item_nm = 'C45255' then
        v_name := v_name||'::'||c_rec.nci_cncpt_val;
    end if;
end if;

end loop;

return v_name;

end;


 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 is

cursor con is
select nci_ord
from cncpt_admin_item cai
where cai.item_id = v_item_id and cai.ver_nr = v_ver_nr 
order by  nci_ord desc;

v_order_sq varchar2(4000):= null;

begin

for c_rec in con loop

if v_order_sq is null then
  v_order_sq := c_rec.nci_ord;

else
   v_order_sq := v_order_sq||','||c_rec.nci_ord;

end if;

end loop;

return v_order_sq;

end get_concept_order;

/*FUNCTION get_concept_origin(v_item_id in number, v_ver_nr in number) return varchar2 is
cursor con is
select origin,display_order
from sbrext.component_Concepts_ext m, sbrext.concepts_ext c
where condr_idseq = p_condr_idseq
and m.con_idseq = c.con_idseq
order by display_order desc;

v_origin varchar2(2000):=null;

begin


for c_rec in con loop

if c_rec.display_order>0 then
  v_origin := v_origin||c_rec.origin||',';
else
  v_origin := v_origin||c_rec.origin;
end if;

end loop;

return v_origin;
end;
*/


PROCEDURE spAddToCart
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_item_id varchar2(50);
  v_ver_nr varchar2(50);
  v_add integer :=0;
  v_already integer :=0;
  i integer := 0;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    select count(*) into v_temp from nci_usr_cart where item_id  = v_item_id and ver_nr = v_ver_nr and cntct_secu_id = v_user_id;
 --   raise_application_error(-20000, v_temp);

    if (v_temp = 0) then
    row := t_row();
    v_add := v_add + 1;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
     ihook.setColumnValue(row,'CNTCT_SECU_ID', v_user_id);
     ihook.setColumnValue(row,'GUEST_USR_NM', 'NONE');
    rows.extend;
    rows(rows.last) := row;
    else v_already := v_already + 1;
    end if;
 end loop;
  if (v_add > 0) then 
    action := t_actionrowset(rows, 'NCI_USR_CART', 1,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
    else
    hookoutput.message := v_already || ' item(s) selected already in yout cart';
    end if;




  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

PROCEDURE spRemoveFromCart
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id  varchar2)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_item_id varchar2(50);
  v_ver_nr varchar2(50);

  i integer := 0;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  rows := t_rows();

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);

    if (v_user_id <> ihook.getColumnValue(row_ori,'CNTCT_SECU_ID')) then
    raise_application_error(-20000, 'You are not authorized to delete from another user cart');
    end if;

    rows.extend;
    rows(rows.last) := row_ori;


end loop;
    action := t_actionrowset(rows, 'NCI_USR_CART', 1,0,'delete');
    actions.extend;
    actions(actions.last) := action;

    action := t_actionrowset(rows, 'NCI_USR_CART', 1,1,'purge');
    actions.extend;
    actions(actions.last) := action;

    hookoutput.actions := actions;
hookoutput.message := 'Item(s) successfully deleted from cart';    




  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE spAddConceptRel
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_item_id varchar2(50);
  v_ver_nr varchar2(50);
  v_add integer :=0;
  v_already integer :=0;
  i integer := 0;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    
    row := t_row();
    v_add := v_add + 1;
    ihook.setColumnValue(row,'ITEM_ID', v_item_id);
    ihook.setColumnValue(row,'VER_NR', v_ver_nr);
    rows.extend;
    rows(rows.last) := row;
 end loop;
  if (v_add > 0) then 
    action := t_actionrowset(rows, 'NCI_USR_CART', 1,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    hookoutput.message := v_add || ' item(s) added successfully to cart. ' || v_already || ' item(s) selected already in yout cart';
    else
    hookoutput.message := v_already || ' item(s) selected already in yout cart';
    end if;




  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spCopyQuestion (actions in out t_actions, v_from_module_id in integer, v_from_module_ver in integer, v_to_module_id in integer, v_to_module_ver in integer) as
v_id integer;
v_found boolean;
v_itemid integer;
row  t_row;
rows t_rows;
rowsvv t_rows;
action t_actionRowset;
  
begin

    
 rowsvv:= t_rows();

 rows:= t_rows();
for cur in (select * from nci_admin_item_rel_alt_key where p_item_id = v_from_module_id and
        p_item_ver_nr = v_from_module_ver and rel_typ_id = 63) loop
    row := t_row();
       
  v_id := nci_11179.getItemId;
ihook.setColumnValue (row, 'NCI_PUB_ID', v_id);
ihook.setColumnValue (row, 'NCI_VER_NR', v_to_module_ver);
ihook.setColumnValue (row, 'P_ITEM_ID', v_to_module_id);
ihook.setColumnValue (row, 'P_ITEM_VER_NR', v_to_module_ver);
ihook.setColumnValue (row, 'C_ITEM_ID', cur.c_item_id);
ihook.setColumnValue (row, 'C_ITEM_VER_NR', cur.c_item_ver_nr);
ihook.setColumnValue (row, 'CNTXT_CS_ITEM_ID', cur.cntxt_cs_item_id);
ihook.setColumnValue (row, 'CNTXT_CS_VER_NR', cur.cntxt_cs_ver_nr);
ihook.setColumnValue (row, 'ITEM_LONG_NM', cur.ITEM_LONG_NM );
ihook.setColumnValue (row, 'REL_TYP_ID', 63);
ihook.setColumnValue (row, 'DISP_ORD', 1);


     rows.extend;
    rows(rows.last) := row;
    
    
    for cur1 in (select * from  NCI_QUEST_VALID_VALUE where q_pub_id = cur.nci_pub_id and q_ver_nr = cur.nci_ver_nr) loop
      row := t_row();
    ihook.setColumnValue (row, 'Q_PUB_ID', v_id);
    ihook.setColumnValue (row, 'Q_VER_NR', v_to_module_ver);
    ihook.setColumnValue (row, 'VM_NM', cur1.vm_nm);
    ihook.setColumnValue (row, 'VM_LNM', cur1.vm_lnm);
    ihook.setColumnValue (row, 'VM_DEF', cur1.vm_def);
    ihook.setColumnValue (row, 'VALUE', cur1.value);
    ihook.setColumnValue (row, 'MEAN_TXT', cur1.mean_txt);
    v_itemid := nci_11179.getItemId;
    ihook.setColumnValue (row, 'NCI_PUB_ID', v_itemid);
    ihook.setColumnValue (row, 'NCI_VER_NR', 1);
    
     rowsvv.extend;
    rowsvv(rowsvv.last) := row;
    v_found := true;
  --  raise_application_error(-20000, 'Inside');
    end loop;   
--DESC_TXT
  --  raise_application_error(-20000, rows.count);
   end loop;
    action := t_actionrowset(rows, 'Questions (Edit)', 2,14,'insert');
    actions.extend;
    actions(actions.last) := action;

    if (v_found) then 
    action := t_actionrowset(rowsvv, 'NCI_QUEST_VALID_VALUE', 1,16,'insert');
   -- actions.extend;
   -- actions(actions.last) := action;
  end if;
   
end;


procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number) as


action           t_actionRowset;
action_rows              t_rows := t_rows();
action_rows_csi              t_rows := t_rows();
row          t_row;
v_table_name varchar2(30);
v_sql        varchar2(4000);
v_to_module_id number;

v_cur        number;
v_temp        number;

v_col_val       varchar2(4000);

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin


-- Module
-- Module Rel
--Questions
-- Question VV
-- Question Repetition


v_table_name := 'ADMIN_ITEM';

 v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);
 v_to_module_id := nci_11179.getItemId;
        
    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

 v_cur := dbms_sql.open_cursor;
 dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
 dbms_sql.bind_variable(v_cur, ':item_id', v_from_module_id);
 dbms_sql.bind_variable(v_cur, ':ver_nr', v_from_module_ver);

 
 for i in 1..v_meta_col_cnt loop
     dbms_sql.define_column(v_cur, i, '', 4000);
 end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

    row := t_row();

 for i in 1..v_meta_col_cnt loop
  dbms_sql.column_value(v_cur, i, v_col_val);
  ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
 end loop;

 dbms_sql.close_cursor(v_cur);
  
    ihook.setColumnValue(row, 'VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'ITEM_ID',v_to_module_id);
    ihook.setColumnValue(row, 'ITEM_NM',v_to_module_id);
    action_rows := t_rows();
    
    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Administered Item (No Sequence)',2, 10, 'insert');
    actions.extend; actions(actions.last) := action;


    row := t_row();

    ihook.setColumnValue(row, 'P_item_VER_NR',v_to_form_ver);
    ihook.setColumnValue(row, 'p_ITEM_ID',v_to_form_id);
    ihook.setColumnValue(row, 'c_ITEM_ID',v_to_module_id);
    ihook.setColumnValue(row, 'c_ITEM_ver_nr',v_to_form_ver);
    ihook.setColumnValue(row, 'rel_typ_id',61);
    ihook.setColumnValue(row, 'disp_ord',0);

     action_rows := t_rows();
    
    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, 'Form-Module Relationship', 2, 12, 'insert');
    actions.extend; actions(actions.last) := action;


-- Questions
  spCopyQuestion(actions, v_from_module_id, v_from_module_ver, v_to_module_id, v_to_form_ver);
 
--raise_application_error(-20000,'Here'|| v_from_module_id || '   ' || v_to_module_id || '  ' || actions.count);



end;
/***********************************************/

procedure spCreateCommonChildrenNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number) as


action           t_actionRowset;
action_rows              t_rows := t_rows();
action_rows_csi              t_rows := t_rows();
row          t_row;
v_table_name varchar2(30);
v_sql        varchar2(4000);

v_cur        number;
v_temp        number;

v_col_val       varchar2(4000);

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin


--Alt names

 action_rows := t_rows();
 action_rows_csi := t_rows();
  v_table_name := 'ALT_NMS';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for an_cur in
  (select nm_id from alt_nms where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where nm_id = :nm_id';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':nm_id', an_cur.nm_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;
   dbms_sql.close_cursor(v_cur);

     select od_seq_ALT_NMS.nextval into v_temp from dual;
      ihook.setColumnValue(row, 'nm_ID',v_temp);
      ihook.setColumnValue(row, 'VER_NR', v_version);
      ihook.setColumnValue(row, 'NCI_IDSEQ', '');

      action_rows.extend; action_rows(action_rows.last) := row;
          for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = an_cur.nm_id) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nmdef_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
           ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
           action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;


  end loop;
  
  action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     actions.extend; actions(actions.last) := action;

-- Alternate Definitions

 action_rows := t_rows();

  v_table_name := 'ALT_DEF';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ad_cur in
  (select def_id from alt_def where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where def_id = :def_id';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':def_id', ad_cur.def_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);
   select od_seq_ALT_DEF.nextval into v_temp from dual;
      ihook.setColumnValue(row, 'def_ID', v_temp);
      ihook.setColumnValue(row, 'VER_NR', v_version);
      ihook.setColumnValue(row, 'NCI_IDSEQ', '');
   action_rows.extend; action_rows(action_rows.last) := row;

        for csi_cur in (select nci_pub_id, nci_ver_nr, typ_nm from NCI_CSI_ALT_DEFNMS where nmdef_id = ad_cur.def_id) loop
            row:= t_row();
            ihook.setColumnValue(row, 'nmdef_ID',v_temp);
            ihook.setColumnValue(row, 'NCI_PUB_ID', csi_cur.NCI_PUB_ID);
            ihook.setColumnValue(row, 'NCI_VER_NR', csi_cur.NCI_VER_NR);
           ihook.setColumnValue(row, 'TYP_NM', csi_cur.TYP_NM);
           action_rows_csi.extend; action_rows_csi(action_rows_Csi.last) := row;
         end loop;

  end loop;
  
  action := t_actionRowset(action_rows, v_table_name, 13, 'insert');
     actions.extend; actions(actions.last) := action;


  action := t_actionRowset(action_rows_csi, 'Classification level Name/Definition 2',2, 25, 'insert');
     actions.extend; actions(actions.last) := action;

--- Reference Documents

 action_rows := t_rows();

  v_table_name := 'REF';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select ref_id from ref where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where ref_id = :ref_id';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':ref_id', ref_cur.ref_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

      ihook.setColumnValue(row, 'ref_ID', -1);
    ihook.setColumnValue(row, 'NCI_IDSEQ', '');
      ihook.setColumnValue(row, 'VER_NR', v_version);
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
     actions.extend; actions(actions.last) := action;


 action_rows := t_rows();

-- Concepts

  v_table_name := 'CNCPT_ADMIN_ITEM';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select CNCPT_AI_ID from CNCPT_ADMIN_ITEM where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where CNCPT_AI_ID = :CNCPT_AI_ID';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':CNCPT_AI_ID', ref_cur.CNCPT_AI_ID);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

      ihook.setColumnValue(row, 'CNCPT_AI_ID', -1);
      ihook.setColumnValue(row, 'VER_NR', v_version);
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
     actions.extend; actions(actions.last) := action;



--- Classifications

 action_rows := t_rows();

  v_table_name := 'NCI_ALT_KEY_ADMIN_ITEM_REL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

  for ref_cur in
  (select NCI_PUB_ID,NCI_VER_NR, REL_TYP_ID from NCI_ALT_KEY_ADMIN_ITEM_REL where 
  c_item_id = v_admin_item.item_id and c_item_ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where NCI_PUB_ID = :NCI_PUB_ID and NCI_VER_NR = :NCI_VER_NR and c_item_id = :c_item_id and c_item_ver_nr = :c_item_ver_nr and rel_typ_id = :rel_typ_id';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':nci_pub_id', ref_cur.nci_pub_id);
    dbms_sql.bind_variable(v_cur, ':nci_ver_nr', ref_cur.nci_ver_nr);
    dbms_sql.bind_variable(v_cur, ':c_item_id', v_admin_item.item_id);
    dbms_sql.bind_variable(v_cur, ':c_item_ver_nr', v_admin_item.ver_nr);
    dbms_sql.bind_variable(v_cur, ':rel_typ_id', ref_cur.rel_typ_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

       ihook.setColumnValue(row, 'c_item_VER_NR', v_version);
      ihook.setColumnValue(row, 'NCI_IDSEQ', '');
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, 'NCI CSI - DE Relationship',2, 15, 'insert');
    actions.extend; actions(actions.last) := action;

end;
/***********************************************/


procedure spCreateSubtypeVerNCI (actions in out t_actions, v_admin_item admin_item%rowtype, v_version number) as

/*

creates version for subtype - called from spCreateVer

*/

action           t_actionRowset;
action_rows              t_rows := t_rows();
row          t_row;

v_table_name      varchar2(30);
v_sql        varchar2(4000);

v_cur        number;
v_temp        number;

v_col_val       varchar2(4000);

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin

    if v_admin_item.admin_item_typ_id = 1 then
     v_table_name := 'CONC_DOM';
    elsif v_admin_item.admin_item_typ_id = 2 then
     v_table_name := 'DE_CONC';
    elsif v_admin_item.admin_item_typ_id = 3 then
     v_table_name := 'VALUE_DOM';
    elsif v_admin_item.admin_item_typ_id = 4 then
     v_table_name := 'DE';
    elsif v_admin_item.admin_item_typ_id = 5 then
     v_table_name := 'OBJ_CLS';
    elsif v_admin_item.admin_item_typ_id = 6 then
     v_table_name := 'PROP';
    elsif v_admin_item.admin_item_typ_id = 7 then
     v_table_name := 'REP_CLS';
    elsif v_admin_item.admin_item_typ_id = 8 then
     v_table_name := 'CNTXT';
    elsif v_admin_item.admin_item_typ_id = 9 then
     v_table_name := 'CLSFCTN_SCHM';
    elsif v_admin_item.admin_item_typ_id = 10 then
     v_table_name := 'DERV_RUL';
    elsif v_admin_item.admin_item_typ_id = 49 then
     v_table_name := 'CNCPT';
    elsif v_admin_item.admin_item_typ_id = 54 then
     v_table_name := 'NCI_FORM';
    end if;

 v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

    v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

 v_cur := dbms_sql.open_cursor;
 dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
 dbms_sql.bind_variable(v_cur, ':item_id', v_admin_item.item_id);
 dbms_sql.bind_variable(v_cur, ':ver_nr', v_admin_item.ver_nr);

 for i in 1..v_meta_col_cnt loop
     dbms_sql.define_column(v_cur, i, '', 4000);
 end loop;

    v_temp := dbms_sql.execute_and_fetch(v_cur);
    dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

    row := t_row();

 for i in 1..v_meta_col_cnt loop
  dbms_sql.column_value(v_cur, i, v_col_val);
  ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
 end loop;

 dbms_sql.close_cursor(v_cur);

    ihook.setColumnValue(row, 'VER_NR',v_version);
    ihook.setColumnValue(row, 'LST_UPD_DT',sysdate);

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, v_table_name, 10, 'insert');
    actions.extend; actions(actions.last) := action;



 if v_admin_item.admin_item_typ_id = 3 then -- Add Perm Val

  action_rows := t_rows();

  v_table_name := 'PERM_VAL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for pv_cur in
  (select val_id from perm_val where 
  val_dom_item_id = v_admin_item.item_id and val_dom_ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where val_id = :val_id';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':val_id', pv_cur.val_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

      ihook.setColumnValue(row, 'VAL_ID', -1);
      ihook.setColumnValue(row, 'VAL_DOM_VER_NR', v_version);
      ihook.setColumnValue(row, 'NCI_IDSEQ', '');
action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 11, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;

 
 
 if v_admin_item.admin_item_typ_id = 1 then -- Conceptual Domain then add CD-VM relationship

  action_rows := t_rows();

  v_table_name := 'CONC_DOM_VAL_MEAN';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for cdvm_cur in
  (select CONC_DOM_VER_NR, CONC_DOM_ITEM_ID, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from conc_dom_val_mean where 
  conc_dom_item_id = v_admin_item.item_id and conc_dom_ver_nr = v_admin_item.ver_nr) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where CONC_DOM_VER_NR = :conc_dom_ver_nr and CONC_DOM_ITEM_ID = :conc_dom_item_id and NCI_VAL_MEAN_ITEM_ID = :nci_val_mean_item_id and NCI_VAL_MEAN_VER_NR = :nci_val_mean_ver_nr';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':conc_dom_ver_nr', cdvm_cur.conc_dom_ver_nr);
   dbms_sql.bind_variable(v_cur, ':conc_dom_item_id', cdvm_cur.conc_dom_item_id);
   dbms_sql.bind_variable(v_cur, ':nci_val_mean_ver_nr', cdvm_cur.nci_val_mean_ver_nr);
   dbms_sql.bind_variable(v_cur, ':nci_val_mean_item_id', cdvm_cur.nci_val_mean_item_id);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

      ihook.setColumnValue(row, 'CONC_DOM_VER_NR', v_version);
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;
 

if v_admin_item.admin_item_typ_id = 4 then -- DE then add Derived DE components

  action_rows := t_rows();

  v_table_name := 'NCI_ADMIN_ITEM_REL';
  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

   for de_cur in
  (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where 
  P_item_id = v_admin_item.item_id and p_ITEM_ver_nr = v_admin_item.ver_nr and rel_typ_id = 65) loop

      v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where P_ITEM_ID = :P_ITEM_ID and P_ITEM_VER_NR = :P_ITEM_VER_NR and C_ITEM_ID = :C_ITEM_ID and C_ITEM_VER_NR = :C_ITEM_VER_NR and REL_TYP_ID=65';

      v_cur := dbms_sql.open_cursor;
   dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
   dbms_sql.bind_variable(v_cur, ':P_ITEM_ID', de_cur.P_ITEM_ID);
   dbms_sql.bind_variable(v_cur, ':P_ITEM_VER_NR', de_cur.P_ITEM_VER_NR);
   dbms_sql.bind_variable(v_cur, ':C_ITEM_ID', de_cur.C_ITEM_ID);
   dbms_sql.bind_variable(v_cur, ':C_ITEM_VER_NR', de_cur.C_ITEM_VER_NR);

   for i in 1..v_meta_col_cnt loop
       dbms_sql.define_column(v_cur, i, '', 4000);
   end loop;

      v_temp := dbms_sql.execute_and_fetch(v_cur);
      dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

      row := t_row();

   for i in 1..v_meta_col_cnt loop
    dbms_sql.column_value(v_cur, i, v_col_val);
    ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
   end loop;

   dbms_sql.close_cursor(v_cur);

      ihook.setColumnValue(row, 'P_ITEM_VER_NR', v_version);
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;

 if v_admin_item.admin_item_typ_id = 54 then -- Add Modules
     for cur2 in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where p_item_id = v_admin_item.item_id and p_item_ver_nr = v_admin_item.item_id) loop
        nci_11179.spCopyModuleNCI(actions, cur2.c_item_id, cur2.c_item_ver_nr, v_admin_item.item_id, v_admin_item.item_id, v_admin_item.item_id, v_version);   
     end loop;
     
end if;
end;

procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2) as

/*

1. if latest_ver is 0 then "Cannot create version if the Administered Item is not the latest version."
2. if registration is not "Standardized" then "Cannot create version for non-standard Administered Item."
3. create a new admin_item with ver_nr=ver_nr+1, registration status = RECORDED (2), and same values for other columns
4. update current admin_item to latest_version=0 and retire it

testing:

begin
spchangestatus('<ITEM_ID><![CDATA[1]]></ITEM_ID><VER_NR><![CDATA[1]]></VER_NR>');
end;

*/

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
actions           t_actions := t_actions();
action           t_actionRowset;
ai_insert_action_rows  t_rows := t_rows();
ai_update_action_rows  t_rows := t_rows();
ai_audit_action_rows     t_rows := t_rows();
row          t_row;

v_admin_item     admin_item%rowtype;
v_tab_admin_item   tab_admin_item_pk;

v_creat_ver     number;
v_stus_nm     varchar2(100);

v_table_name      varchar2(30);
v_sql        varchar2(4000);

v_cur        number;
v_temp        number;

v_version  number(4,2);

v_col_val       varchar2(4000);
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
  forms t_forms;
  form1 t_form;
  rowform t_row;

row_ori t_row;

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 
 v_tab_admin_item := template_11179.getParsedAdminItemsData(hookInput.originalRowset);

        select * into v_admin_item from admin_item
        where item_id=v_tab_admin_item(1).item_id and ver_nr=v_tab_admin_item(1).ver_nr
  for update nowait;

     if v_admin_item.currnt_ver_ind = 0 then
            hookOutput.message := 'Cannot create version if the Administered Item is not the latest version.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
     end if;

      /*  if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
   
     end if;
     */
    if hookInput.invocationNumber = 0 then
    if (v_admin_item.admin_item_typ_id in (50,51,52,53,56)) then
     raise_application_error(-20000, 'Administered Item of this type cannot be versioned.');
    end if;
    
            ANSWERS                    := T_ANSWERS();
            ANSWER                     := T_ANSWER(1, 1, 'Create Version.' );
            ANSWERS.EXTEND;
            ANSWERS(ANSWERS.LAST) := ANSWER;
            QUESTION               := T_QUESTION('Specify Version. Current version is:' || ihook.getColumnValue(row_ori,'VER_NR' ) , ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;
    --start
    --action_row := t_row();
    --ihook.setColumnValue(action_row, 'ITEM_TYP', 5);
    --ihook.setColumnValue(action_row, 'NAME', 'Name_5');
    --ihook.setColumnValue(action_row, 'ADDRESS', 'ADDRESS_5');
    --action_rows.extend; action_rows(action_rows.last) := action_row;  
    --rowset := t_rowset(action_rows, hookInput.originalRowset.objectName, 1, hookInput.originalRowset.tableName);
    
    --end
    forms                  := t_forms();
    form1                  := t_form('Version Creation', 2,1);
    --form1.rowset :=rowset;
    forms.extend;
    forms(forms.last) := form1;
    hookOutput.forms := forms;	   
	elsif hookInput.invocationNumber = 1 then
		  if hookInput.answerId = 1 then 
            forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
     v_version := ihook.getColumnValue(rowform,'VER_NR');
     
  v_table_name := 'ADMIN_ITEM';

  v_meta_col_cnt := TEMPLATE_11179.getColumnCount(v_table_name);

     v_sql := TEMPLATE_11179.getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

  v_cur := dbms_sql.open_cursor;
  dbms_sql.parse(v_cur, v_sql, dbms_sql.native);
  dbms_sql.bind_variable(v_cur, ':item_id', v_admin_item.item_id);
  dbms_sql.bind_variable(v_cur, ':ver_nr', v_admin_item.ver_nr);

  for i in 1..v_meta_col_cnt loop
      dbms_sql.define_column(v_cur, i, '', 4000);
  end loop;

     v_temp := dbms_sql.execute_and_fetch(v_cur);
     dbms_sql.describe_columns(v_cur, v_meta_col_cnt, v_meta_desc_tab);

     row := t_row();

  for i in 1..v_meta_col_cnt loop
   dbms_sql.column_value(v_cur, i, v_col_val);
   ihook.setColumnValue(row, v_meta_desc_tab(i).col_name, v_col_val);
  end loop;

  dbms_sql.close_cursor(v_cur);

     ihook.setColumnValue(row, 'VER_NR', v_version);
  ihook.setColumnValue(row, 'CREAT_USR_ID', hookInput.userId);
  ihook.setColumnValue(row, 'LST_UPD_USR_ID', hookInput.userId);
  ihook.setColumnValue(row, 'ADMIN_STUS_ID', 65 );
  ihook.setColumnValue(row, 'REGSTR_STUS_ID','' );
ihook.setColumnValue(row, 'NCI_IDSEQ', '');

        ai_insert_action_rows.extend; ai_insert_action_rows(ai_insert_action_rows.last) := row;

     row := t_row();
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
--     ihook.setColumnValue(row, 'REGSTR_STUS_ID', 5); -- removed for FAA
     ihook.setColumnValue(row, 'CURRNT_VER_IND', 0);
        ai_update_action_rows.extend; ai_update_action_rows(ai_update_action_rows.last) := row;

        row := t_row();
     ihook.setColumnValue(row, 'LOG_ID', -1); -- sequence column
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
     ihook.setColumnValue(row, 'CHNG_TYP_ID', 48);
     ihook.setColumnValue(row, 'CHNG_DESC', 'Version ' || v_version || ' created.');
     ihook.setColumnValue(row, 'LST_UPD_USR_ID', v_user_id);
        ai_audit_action_rows.extend; ai_audit_action_rows(ai_audit_action_rows.last) := row;

  spCreateSubtypeVerNCI(actions, v_admin_item, v_version);
  spCreateCommonChildrenNCI(actions, v_admin_item, v_version);

 action := t_actionRowset(ai_insert_action_rows, 'ADMIN_ITEM', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 action := t_actionRowset(ai_update_action_rows, 'ADMIN_ITEM', 0, 'update');
    actions.extend; actions(actions.last) := action;

   -- action := t_actionRowset(ai_audit_action_rows, 'ADMIN_ITEM_AUDIT', 0, 'insert');
   -- actions.extend; actions(actions.last) := action;

 hookOutput.actions := actions;

    hookOutput.message := 'Version created successfully.';
    end if;
end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


END;
/
create or replace PROCEDURE spCreateDEC
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user in varchar,
    v_mode in char)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  question t_question;
  answer t_answer;
  answers t_answers;
  forms t_forms;
  form1 t_form;
  showRowset t_showableRowset;
  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  v_oc_item_id number;
  v_oc_ver_nr number;
  v_oc_long_nm varchar2(255);
  v_oc_def  varchar2(2000);
  v_prop_item_id number;
  v_prop_ver_nr number;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
  v_oc_nm  varchar2(175);
  v_prop_nm  varchar2(175);
  
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
  
    rows := t_rows();
 
   --for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(1);
    v_msg := '';
    v_err := 0;
 
   if (ihook.getColumnValue(row_ori, 'CTL_USR_ID')<> v_user) then
       raise_application_error(-20000, 'You are not authorized to create or validate this record.');
   end if;

   if (ihook.getColumnValue(row_ori, 'CTL_REC_STUS') = 'SUCCESSFUL') then
       raise_application_error(-20000, 'DEC already created. Delete the record');
   end if;
    
    
  if (  ihook.getColumnValue(row_ori, 'OBJ_CLS_ITEM_ID') is null) then -- create OC
    
        select LISTAGG(cncpt.item_long_nm, ':')WITHIN GROUP (ORDER by stg.nci_ord desc) into v_oc_nm 
        from admin_item cncpt, nci_stg_ai_cncpt stg where stg.cncpt_item_id = cncpt.item_id and stg.cncpt_ver_nr = cncpt.ver_nr and 
        STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='OC' and stg.fld_delete <> 1;
    
        if (v_oc_nm is null) then 
            v_msg := v_msg || 'Need at least one concept for OC; ' ; v_err := v_err + 1; 
        else
            nci_11179.CncptCombExists(v_oc_nm,5,v_oc_item_id, v_oc_ver_nr,v_oc_long_nm, v_oc_def);
            
            if (v_oc_item_id is not null) then 
                v_msg := v_msg || 'OC concept combination exists.' || chr(10);
            else
                   v_msg := v_msg || 'Creating new OC.' || chr(10);
                        for cur in ( select LISTAGG(cncpt.item_nm, ' ')WITHIN GROUP (ORDER by stg.nci_ord desc) CNCPT_CONCAT_NM,
                                LISTAGG(cncpt.item_desc, ':')WITHIN GROUP (ORDER by stg.nci_ord desc) CNCPT_CONCAT_DEF
                                from admin_item cncpt, nci_stg_ai_cncpt stg where stg.cncpt_item_id = cncpt.item_id and stg.cncpt_ver_nr = cncpt.ver_nr and 
                                STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='OC' and stg.fld_delete <> 1) loop
                                        v_oc_long_nm := cur.cncpt_concat_nm;
                                        v_oc_def := cur.cncpt_concat_def;
                        end loop;   

            end if;
        end if;
  else -- OC specified
        v_msg := v_msg || 'OC Specified.' || chr(10);
    
        v_oc_item_id := ihook.getColumnValue(row_ori,'OBJ_CLS_ITEM_ID');
        v_oc_ver_nr := ihook.getColumnValue(row_ori,'OBJ_CLS_VER_NR');
        nci_11179.getConcatNmDef(v_oc_item_id, v_oc_ver_nr, v_oc_nm, v_oc_long_nm,v_oc_def);
   --     raise_application_error (-20000, 'OC' || v_oc_nm || v_oc_long_nm);
        
        
        
  end if;   
  
     
     
  if (  ihook.getColumnValue(row_ori, 'PROP_ITEM_ID') is null) then -- create Prop
    
        select LISTAGG(cncpt.item_long_nm, ':')WITHIN GROUP (ORDER by stg.nci_ORD desc) into v_prop_nm 
        from admin_item cncpt, nci_stg_ai_cncpt stg where stg.cncpt_item_id = cncpt.item_id and stg.cncpt_ver_nr = cncpt.ver_nr and 
        STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='PROP' and stg.fld_delete <> 1;
        if (v_prop_nm is null) then 
            v_msg := v_msg || 'Need at least one concept for Prop; ' ; v_err := v_err + 1; 
        else
            nci_11179.CncptCombExists(v_prop_nm,6,v_prop_item_id, v_prop_ver_nr, v_prop_long_nm, v_prop_def);
          --raise_application_error(-20000, v_prop_nm || v_prop_item_id );
            if (v_prop_item_id is not null) then 
                v_msg := v_msg || 'Property concept combination exists.' || chr(10);
            else
                   v_msg := v_msg || 'Creating new Property.' || chr(10);
                   for cur in ( select LISTAGG(cncpt.item_nm, ' ')WITHIN GROUP (ORDER by stg.nci_ord desc) CNCPT_CONCAT_NM,
                                LISTAGG(cncpt.item_desc, ':')WITHIN GROUP (ORDER by stg.nci_ord desc) CNCPT_CONCAT_DEF
                                from admin_item cncpt, nci_stg_ai_cncpt stg where stg.cncpt_item_id = cncpt.item_id and stg.cncpt_ver_nr = cncpt.ver_nr and 
                                STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='PROP' and stg.fld_delete <> 1) loop
                                        v_prop_long_nm := cur.cncpt_concat_nm;
                                        v_prop_def := substr(cur.cncpt_concat_def,1,2000);
                        end loop;
            end if;
        end if;
    else
        v_prop_item_id := ihook.getColumnValue(row_ori,'PROP_ITEM_ID');
        v_prop_ver_nr := ihook.getColumnValue(row_ori,'PROP_VER_NR');
        v_msg := v_msg || 'Property Specified.' || chr(10);
        nci_11179.getConcatNmDef(v_prop_item_id, v_prop_ver_nr, v_prop_nm, v_prop_long_nm,v_prop_def);
    
    
  end if;   
 
  
  if v_err = 0 and v_mode = 'C' and v_oc_item_id is null then --- no errors found, create mode, no OC found
       row := t_row();
       rows := t_rows();
       
        v_oc_item_id := nci_11179.getItemId;
        v_oc_ver_nr := 1;
        ihook.setColumnValue(row,'ITEM_ID', v_oc_item_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 5);
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_oc_nm);
        ihook.setColumnValue(row,'ITEM_DESC', v_oc_def);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(row_ori,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'ITEM_NM', v_oc_long_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
             
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
    
        action := t_actionrowset(rows, 'Object Class', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      
       rows := t_rows();
   --     raise_application_error(-20000,'OC');
       
        for cur in (select cncpt_item_id, cncpt_ver_nr, nci_ord, decode(nci_ord, 0, 1,0) NCI_PRMRY_IND from nci_stg_ai_cncpt stg where stg.STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='OC' and fld_delete <> 1) loop
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_oc_item_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
            ihook.setColumnValue(row,'NCI_PRMRY_IND', cur.nci_prmry_ind);
            rows.extend;
            rows(rows.last) := row;
        end loop;
       action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    
        
    end if;
    rows := t_rows();
    
if v_err = 0 and v_mode = 'C' and v_prop_item_id is null then --- no errors found, create mode, no OC found
       row := t_row();
        v_prop_item_id := nci_11179.getItemId;
        v_prop_ver_nr := 1;
        ihook.setColumnValue(row,'ITEM_ID', v_prop_item_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 6);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(row_ori,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_prop_nm);
        ihook.setColumnValue(row,'ITEM_DESC', v_prop_def);
        ihook.setColumnValue(row,'ITEM_NM', v_prop_long_nm);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
             
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,3,'insert');
        actions.extend;
        actions(actions.last) := action;
    
        action := t_actionrowset(rows, 'Property', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;
      --   raise_application_error(-20000,'Property');
       
 
        
       rows := t_rows();
        
        for cur in (select cncpt_item_id, cncpt_ver_nr, nci_ord,decode(nci_ord, 0, 1,0) NCI_PRMRY_IND from nci_stg_ai_cncpt stg where stg.STG_AI_ID = ihook.getColumnValue(row_ori,'STG_AI_ID') and lvl_nm ='PROP' and fld_delete <> 1) loop
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_prop_item_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
            ihook.setColumnValue(row,'NCI_PRMRY_IND', cur.nci_prmry_ind);
            rows.extend;
            rows(rows.last) := row;
        end loop;
        action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,5,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
  
  --raise_application_error(-20000,v_mode);
       
  rows := t_rows();
    if v_err = 0 and v_mode = 'C' then  
       row := t_row();
   --    raise_application_error(-20000,'Inside');
        v_dec_item_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_dec_item_id);
     
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
        ihook.setColumnValue(row,'ITEM_LONG_NM', v_oc_nm || ':' || v_prop_nm);
        ihook.setColumnValue(row,'ITEM_NM',  v_oc_long_nm || ':' || v_prop_long_nm);
        ihook.setColumnValue(row,'ITEM_DESC', v_oc_def || ':' || v_prop_def);
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(row_ori,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',ihook.getColumnValue(row_ori,'CONC_DOM_ITEM_ID') );
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',ihook.getColumnValue(row_ori,'CONC_DOM_VER_NR') );
        ihook.setColumnValue(row,'OBJ_CLS_ITEM_ID',v_oc_item_id );
        ihook.setColumnValue(row,'OBJ_CLS_VER_NR',v_oc_ver_nr );
        ihook.setColumnValue(row,'PROP_ITEM_ID',v_prop_item_id );
        ihook.setColumnValue(row,'PROP_VER_NR',v_prop_ver_nr );
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));
             
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;
    
      action := t_actionrowset(rows, 'Data Element Concept', 2,8,'insert');
        actions.extend;
        actions(actions.last) := action;
  
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row, 'ITEM_NM') || 'ggg'||  ihook.getColumnValue(row,'ITEM_LONG_NM') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID')|| 'FFF' || v_prop_item_id || 'hhh' || v_dec_item_id);
   
       ihook.setColumnValue(row_ori, 'CTL_REC_STUS', 'SUCCESSFUL');
       ihook.setColumnValue(row_ori, 'DEC_ITEM_LONG_NM',  v_oc_nm || ':' || v_prop_nm);
       ihook.setColumnValue(row_ori, 'DEC_ITEM_NM',  v_oc_long_nm || ':' || v_prop_long_nm);
       
       rows := t_rows();
        rows.extend;
        rows(rows.last) := row_ori;
      action := t_actionrowset(rows, 'DEC Creation', 2,9,'update');
        actions.extend;
        actions(actions.last) := action;
--raise_application_error(-20000, actions.count || 'FFF' || v_oc_ver_nr || 'ggg'||  v_prop_ver_nr || 'GGGG' || v_oc_item_id || 'FFF' || v_prop_item_id || 'hhh' || v_dec_item_id);
  
       hookoutput.actions := actions;
     v_msg := 'DEC Created. Item ID: ' || v_dec_item_id;  
     end if;
    if (v_mode <> 'C' and v_err = 0) then -- validation mode
    
       ihook.setColumnValue(row_ori, 'CTL_REC_STUS', 'VALIDATED');
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', v_msg);
      ihook.setColumnValue(row_ori, 'DEC_ITEM_LONG_NM',  v_oc_nm || ':' || v_prop_nm);
       ihook.setColumnValue(row_ori, 'DEC_ITEM_NM',  v_oc_long_nm || ':' || v_prop_long_nm);
        
       rows := t_rows();
        rows.extend;
        rows(rows.last) := row_ori;
      action := t_actionrowset(rows, 'DEC Creation', 2,7,'update');
       actions.extend;
        actions(actions.last) := action;
-- raise_application_error(-20000,'Here');
 --   raise_application_error (-20000, actions.count);
   
    hookoutput.actions := actions;
     v_msg := 'AI Validated';  
     end if;
     
     if (v_err > 0) then
        v_msg := to_char(v_err) || ' validation errors found. ' || chr(10) || v_msg;
    
    end if;
    
    
  hookoutput.message := v_msg;
--  raise_application_error(-20000,actions.count || ' ' ||  ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') || ' ' || ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
 -- || ' ' ||ihook.getColumnValue(row_ori,'CONC_DOM_ITEM_ID') || ' ' || v_oc_item_id );

--end if;

--end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
create or replace PROCEDURE spDECConceptFromTemplate
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_stg_ai_id number;
  v_nm  varchar2(255);
  v_oc_id number;
  v_oc_ver_nr number(4,2);
  v_prop_id  number;
  v_prop_ver_nr number(4,2);
  v_dec_id  number;
  v_dec_ver_nr  number(4,2);
  v_oc_nm   varchar2(255);
  v_prop_nm  varchar2(255);
  v_add integer :=0;
  v_word_cnt integer :=0;
  v_word  varchar2(100);
  i integer := 0;
  v_prmry_cncpt_nm varchar2(255);
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_oc_id := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_ITEM_ID');
    v_oc_ver_nr := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_VER_NR');
    v_prop_id := ihook.getColumnValue(row_ori, 'STRT_PROP_ITEM_ID');
    v_prop_ver_nr := ihook.getColumnValue(row_ori, 'STRT_PROP_VER_NR');
    v_dec_id := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_ITEM_ID');
    v_dec_ver_nr := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_VER_NR');
       v_oc_nm := ihook.getColumnValue(row_ori, 'OBJ_CLS_LONG_NM');
    v_prop_nm := ihook.getColumnValue(row_ori, 'PROP_LONG_NM');
 
    delete from nci_stg_ai_cncpt where stg_ai_id = v_stg_ai_id;
    commit;
    
    
    delete from onedata_ra.nci_stg_ai_cncpt where stg_ai_id = v_stg_ai_id;
    commit;
    
    if v_dec_id is not null then
       select obj_cls_item_id, obj_cls_ver_nr into v_oc_id, v_oc_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       select prop_item_id, prop_ver_nr into v_prop_id, v_prop_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       
    end if;
     
    if v_oc_id is not null then
 --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_oc_id and ver_nr = v_oc_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'OC');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     
  if v_oc_id is null and v_oc_nm is not null then -- No template selected but OC name specified. 
  v_prmry_cncpt_nm := nci_11179.getPrimaryConceptName (v_oc_nm);
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'OC', item_id, ver_nr from admin_item  where admin_item_typ_id = 5 and upper(item_nm) like '%' || upper(v_prmry_cncpt_nm) and nvl(currnt_ver_ind,0) = 1 and nvl(fld_delete,0) = 0;
        commit;
  end if;
    if v_prop_id is not null then
    for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_prop_id and ver_nr = v_prop_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'PROP');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     
  if v_prop_id is null and v_prop_nm is not null then -- No template selected but OC name specified. 
  v_prmry_cncpt_nm := nci_11179.getPrimaryConceptName (v_prop_nm);
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'PROP';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'PROP', item_id, ver_nr from admin_item  where admin_item_typ_id = 6 and upper(item_nm) like '%' || upper(v_prmry_cncpt_nm) and nvl(currnt_ver_ind,0) = 1 and nvl(fld_delete,0) = 0;
        commit;
  end if;
     end loop;
     
  if (v_add > 0) then 
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
    action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
    end if;
    
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/

create or replace PROCEDURE spDECConceptFromTemplatePost
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_cnt integer;
  v_stg_ai_id number;
  v_oc_id number;
  v_oc_ver_nr number(4,2);
  v_prop_id  number;
  v_prop_ver_nr number(4,2);
  v_dec_id  number;
  v_dec_ver_nr  number(4,2);
  v_add integer :=0;
  v_dec_nm   varchar2(255);
  v_temp_nm  varchar2(255);
  v_prmry_cncpt_id number;
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

   for i in 1..hookinput.originalrowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_oc_id := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_ITEM_ID');
    v_oc_ver_nr := ihook.getColumnValue(row_ori, 'STRT_OBJ_CLS_VER_NR');
    v_prop_id := ihook.getColumnValue(row_ori, 'STRT_PROP_ITEM_ID');
    v_prop_ver_nr := ihook.getColumnValue(row_ori, 'STRT_PROP_VER_NR');
    v_dec_id := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_ITEM_ID');
    v_dec_ver_nr := ihook.getColumnValue(row_ori, 'STRT_DE_CONC_VER_NR');
    v_oc_nm := ihook.getColumnValue(row_ori, 'OBJ_CLS_LONG_NM');
    v_prop_nm := ihook.getColumnValue(row_ori, 'PROP_LONG_NM');
   --- raise_application_error(-20000,'Test' || v_dec_id || v_dec_ver_nr);
    
    if v_dec_id is not null then
       select obj_cls_item_id, obj_cls_ver_nr into v_oc_id, v_oc_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
       select prop_item_id, prop_ver_nr into v_prop_id, v_prop_Ver_nr from de_conc where item_id = v_dec_id and ver_nr = v_dec_ver_nr;
    end if;
    
    select count(*) into v_cnt from  NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';

    if v_oc_id is not null and v_cnt = 0 then
 --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_oc_id and ver_nr = v_oc_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'OC');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
  
  if v_oc_id is null and v_oc_nm is not null and v_cnt = 0 then -- No template selected but OC name specified. 
    v_prmry_cncpt_id := nci_11179.getPrimaryConceptID (v_oc_nm);
    if v_prmry_cncpt_id is not null then
       delete from NCI_STG_AI_REL where stg_ai_id = v_stg_ai_id and lvl_nm = 'OC';
       commit;
        insert into NCI_STG_AI_REL (stg_ai_id, lvl_nm, ITEM_ID, VER_NR) select 
        v_stg_ai_id, 'OC', cai.item_id, cai.ver_nr from admin_item ai, cncpt_admin_item cai where cai.nci_ord = 0 and 
        ai.item_id = cai.item_id and ai.ver_nr = cai.ver_nr and ai.admin_item_typ_id = 5 and cai.cncpt_item_id = v_prmry_cncpt_id;
        commit;
    end if;
  end if;
    select count(*) into v_cnt from  NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = 'PROP';

    if v_prop_id is not null and v_cnt = 0 then
    for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_prop_id and ver_nr =v_prop_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM', 'PROP');
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     end if;
     end loop;
     
     
  if (v_add > 0) then 
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
     action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
    end if;

--- DEC name generation


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/

create or replace PROCEDURE spDECCreateUseAsIS
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_stg_ai_id number;
  v_item_id number;
  v_ver_nr number(4,2);
  v_lvl_nm  varchar2(10);
  v_nm  varchar2(255);
  v_add integer :=0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_lvl_nm := ihook.getColumnValue(row_ori, 'LVL_NM');
   
       row := t_row();
       ihook.setColumnValue(row, 'STG_AI_ID', v_stg_ai_id);
       if (v_lvl_nm = 'OC') then
       ihook.setColumnValue(row, 'OBJ_CLS_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'OBJ_CLS_VER_NR',  v_ver_nr);
       else
       ihook.setColumnValue(row, 'PROP_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'PROP_VER_NR',  v_ver_nr);
      end if;   
       rows := t_rows();
        rows.extend;
        rows(rows.last) := row;
      action := t_actionrowset(rows, 'DEC Creation', 2,9,'update');
        actions.extend;
        actions(actions.last) := action;
    hookoutput.actions := actions;
    
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/

create or replace PROCEDURE spDECCreateUseAsTemplate
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  rowde t_row;
  rowvd  t_row;
  rowdec  t_row;
  v_temp integer;
  v_stg_ai_id number;
  v_item_id number;
  v_ver_nr number(4,2);
  v_lvl_nm  varchar2(10);
  v_nm  varchar2(255);
  v_add integer :=0;
  column  t_column;
  msg varchar2(4000);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();  

    row_ori := hookInput.originalRowset.rowset(1);
    v_stg_ai_id := ihook.getColumnValue(row_ori, 'STG_AI_ID');
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    v_lvl_nm := ihook.getColumnValue(row_ori, 'LVL_NM');
   --  raise_application_error(-20000, 'here');
     for cur in (select cncpt_item_id, cncpt_ver_nr,NCI_ORD from cncpt_admin_item where item_id = v_item_id and ver_nr = v_ver_nr) loop
        row := t_row ();
        ihook.setColumnValue(row,'CNCPT_ITEM_ID', cur.cncpt_item_id);
    ihook.setColumnValue(row,'CNCPT_VER_NR', cur.cncpt_ver_nr);
     ihook.setColumnValue(row,'STG_AI_ID', v_stg_ai_id);
     ihook.setColumnValue(row,'NCI_ORD', cur.nci_ord);
     ihook.setColumnValue(row,'LVL_NM',v_lvl_nm );
     rows.extend;
    rows(rows.last) := row;
    v_add := v_add +1;
     end loop;
     
     
  if (v_add > 0) then 
     delete from NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = v_lvl_nm;
     commit;
     delete from onedata_ra.NCI_STG_AI_CNCPT where stg_ai_id = v_stg_ai_id and lvl_nm = v_lvl_nm;
     commit;
    --action := t_actionrowset(rows, 'NCI_STG_AI_CNCPT (Hook)', 2,0,'insert');
    action := t_actionrowset(rows, 'Stage Associated Concepts', 2,0,'insert');
    actions.extend;
    actions(actions.last) := action;
   
       row := t_row();
       ihook.setColumnValue(row, 'STG_AI_ID', v_stg_ai_id);
       if (v_lvl_nm = 'OC') then
       ihook.setColumnValue(row, 'STRT_OBJ_CLS_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'STRT_OBJ_CLS_VER_NR',  v_ver_nr);
       else
       ihook.setColumnValue(row, 'STRT_PROP_ITEM_ID',  v_item_id);
       ihook.setColumnValue(row, 'STRT_PROP_VER_NR',  v_ver_nr);
      end if;   
       rows := t_rows();
        rows.extend;
        rows(rows.last) := row;
      action := t_actionrowset(rows, 'DEC Creation', 2,9,'update');
        actions.extend;
        actions(actions.last) := action;
    hookoutput.actions := actions;

   hookoutput.message := v_add || ' concepts added.';
   hookoutput.message := msg;
   
    end if;
    
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/

create or replace PACKAGE nci_chng_mgmt AS
function getDECCreateQuestion return t_question;
function getDECCreateForm (v_rowset in t_rowset) return t_forms;
procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions);
procedure createDEC (rowform in t_row, actions in out t_actions, v_id out number);
END;
/

create or replace PACKAGE BODY nci_CHNG_MGMT AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;
type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();

  
function getDECCreateQuestion return t_question is
  question t_question;
  answer t_answer;
  answers t_answers;
begin

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Validate DEC');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  --  ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(2, 2, 'Create DEC');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add new DEC.', ANSWERS);
   
return question;
end;

function getDECCreateForm (v_rowset in t_rowset) return t_forms is
  forms t_forms;
  form1 t_form;
begin
    forms                  := t_forms();
    form1                  := t_form('AI Creation With Concepts', 2,1);
    form1.rowset :=v_rowset;
    forms.extend;    forms(forms.last) := form1;
  return forms;
end;

procedure createAIWithConcept(rowform in out t_row, idx in integer,v_item_typ_id in integer, actions in out t_actions) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 v_cncpt_id  number;
 v_cncpt_ver_nr number(4,2);
 v_id integer;
 j integer;
i integer;
v_obj_nm  varchar2(100);
v_temp varchar2(4000);
begin
        v_id := nci_11179.getItemId;
        
       rows := t_rows();
   --     raise_application_error(-20000,'OC');
       v_nm := '';
       v_long_nm := '';
       v_def := '';
          j := 0;
          for i in reverse 0..5 loop
      
     --  raise_application_error(-20000, 'Test'  ||ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || 4));
          
          v_cncpt_id := ihook.getColumnValue(rowform, 'CNCPT_' || idx  ||'_ITEM_ID_' || i);
             v_cncpt_ver_nr :=  ihook.getColumnValue(rowform, 'CNCPT_' || idx || '_VER_NR_' || i);
          if( v_cncpt_id is not null) then
    --   raise_application_error(-20000, 'Test'  || i || v_cncpt_id);
           for cur in (select item_nm, item_long_nm, item_desc from admin_item where item_id = v_cncpt_id and ver_nr = v_cncpt_ver_nr) loop
            row := t_row();
            ihook.setColumnValue(row,'ITEM_ID', v_id);
            ihook.setColumnValue(row,'VER_NR', 1);
            ihook.setColumnValue(row,'CNCPT_ITEM_ID',v_cncpt_id);
            ihook.setColumnValue(row,'CNCPT_VER_NR', v_cncpt_ver_nr);
            ihook.setColumnValue(row,'NCI_ORD', j);
            v_temp := v_temp || i || ':' ||  v_cncpt_id;
            if j = 0 then 
            ihook.setColumnValue(row,'NCI_PRMRY_IND', 1);
            else ihook.setColumnValue(row,'NCI_PRMRY_IND', 0);
            end if;
            rows.extend;
            rows(rows.last) := row;
            v_nm := v_nm || ' ' || cur.item_nm;
            v_long_nm := v_long_nm || ':' || cur.item_long_nm;
            v_def := substr(v_def || ' ' || cur.item_desc,1,4000);
            
            j := j+ 1;
        end loop;
        end if;
        end loop;
       action := t_actionrowset(rows, 'CNCPT_ADMIN_ITEM', 1,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        
        rows := t_rows();
        row := t_row();
            
        ihook.setColumnValue(row,'ITEM_ID', v_id);
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', v_item_typ_id);
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(rowform,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'ITEM_LONG_NM', substr(v_long_nm,2));
        ihook.setColumnValue(row,'ITEM_DESC', v_def);
        ihook.setColumnValue(row,'ITEM_NM', trim(v_nm));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        rows.extend;
        rows(rows.last) := row;
    -- raise_application_error(-20000, 'HEre ' || v_nm || v_long_nm || v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_LONG_NM', substr(v_long_nm,2));
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_DEF', v_def);
        ihook.setColumnValue(rowform,'ITEM_' || idx || '_NM', trim(v_nm));
        ihook.setColumnValue(rowform, 'ITEM_' || idx || '_ID', v_id);
         ihook.setColumnValue(rowform, 'ITEM_' || idx || '_VER_NR', 1);
  
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;
    
       case v_item_typ_id
       when 5 then v_obj_nm := 'Object Class';
       when 6 then v_obj_nm := 'Property';
        end case;
        action := t_actionrowset(rows, v_obj_nm, 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      
   
end;
procedure createDEC (rowform in t_row, actions in out t_actions, v_id out  number) as
v_nm  varchar2(255);
v_long_nm varchar2(255);
v_def  varchar2(4000);
row t_row;
rows t_rows;
 action t_actionRowset;
 --v_id number;
begin
   rows := t_rows();
   row := t_row();
     v_id := nci_11179.getItemId;
        ihook.setColumnValue(row,'ITEM_ID', v_id);
      --  raise_application_error (-20000, ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID')  || ihook.getColumnValue(rowform, 'ITEM_1_ID') || ihook.getColumnValue(rowform, 'ITEM_2_ID'));
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'CURRNT_VER_IND', 1);
        ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 2);
        ihook.setColumnValue(row,'ITEM_LONG_NM', ihook.getColumnValue(rowform, 'ITEM_1_LONG_NM')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_LONG_NM'));
        ihook.setColumnValue(row,'ITEM_NM',  ihook.getColumnValue(rowform, 'ITEM_1_NM')  || ' ' || ihook.getColumnValue(rowform, 'ITEM_2_NM'));
        ihook.setColumnValue(row,'ITEM_DESC',substr(ihook.getColumnValue(rowform, 'ITEM_1_DEF')  || ':' || ihook.getColumnValue(rowform, 'ITEM_2_DEF'),1,4000));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID', ihook.getColumnValue(rowform,'CNTXT_ITEM_ID'));
        ihook.setColumnValue(row,'CNTXT_VER_NR', ihook.getColumnValue(rowform,'CNTXT_VER_NR'));
        ihook.setColumnValue(row,'ADMIN_STUS_ID',ihook.getColumnValue(rowform,'ADMIN_STUS_ID') );
        ihook.setColumnValue(row,'CONC_DOM_ITEM_ID',nvl(ihook.getColumnValue(rowform,'CONC_DOM_ITEM_ID'),1) );
        ihook.setColumnValue(row,'CONC_DOM_VER_NR',nvl(ihook.getColumnValue(rowform,'CONC_DOM_VER_NR'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_1_ID'),1) );
        ihook.setColumnValue(row,'OBJ_CLS_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_1_VER_NR'),1) );
        ihook.setColumnValue(row,'PROP_ITEM_ID',nvl(ihook.getColumnValue(rowform, 'ITEM_2_ID'),1));
        ihook.setColumnValue(row,'PROP_VER_NR',nvl(ihook.getColumnValue(rowform, 'ITEM_2_VER_NR'),1));
        ihook.setColumnValue(row,'LST_UPD_DT',sysdate );
        rows.extend;
        rows(rows.last) := row;
--raise_application_error(-20000, 'Deep' || ihook.getColumnValue(row,'CNTXT_ITEM_ID') || 'ggg'|| ihook.getColumnValue(row,'ADMIN_STUS_ID') || 'GGGG' || ihook.getColumnValue(row,'ITEM_ID'));
             
        action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,7,'insert');
        actions.extend;
        actions(actions.last) := action;
    
      action := t_actionrowset(rows, 'Data Element Concept', 2,8,'insert');
       actions.extend;
        actions(actions.last) := action;
  
--r
end;


END;
/
create or replace PROCEDURE spCreateDECSimple
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB)
AS
  hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
  showRowset t_showableRowset;
  rowform t_row;
    forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  row_ori t_row;
  rowset            t_rowset;
  v_oc_item_id number;
  v_oc_ver_nr number;
  v_oc_long_nm varchar2(255);
  v_oc_nm varchar2(255);
  v_prop_nm varchar2(255);
  v_oc_def  varchar2(2000);
  type t_cncpt_id is table of admin_item.item_id%type;
v_t_cncpt_id  t_cncpt_id := t_cncpt_id();

  v_prop_item_id number;
  v_prop_ver_nr number;
  v_prop_long_nm varchar2(255);
  v_prop_def  varchar2(2000);
  v_dec_item_id number;
 v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
  
    actions t_actions := t_actions();
  action t_actionRowset;
  v_msg varchar2(1000);
  i integer := 0;
  v_err  integer;
  column  t_column;
  v_dec_nm varchar2(255);
  v_cncpt_nm varchar2(255);
  v_long_nm varchar2(255);
  v_def varchar2(4000);
  v_oc_id number;
  v_prop_id number;
 bEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    if hookInput.invocationNumber = 0 then
          HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
          row := t_row();      
          rows := t_rows();
          ihook.setColumnValue(row, 'STG_AI_ID',1);
          ihook.setColumnValue(row, 'ADMIN_STUS_ID',66);
          rows.extend;
          rows(rows.last) := row;
          rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
          hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
  ELSE
   
    IF HOOKINPUT.ANSWERID = 1 THEN  -- Validate
      forms              := hookInput.forms;
      form1              := forms(1);
      rowform := form1.rowset.rowset(1);
       row := t_row();
      rows := t_rows();
  -- raise_application_error(-20000, 'here');
    for k in 1..2 loop
       if (ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_' || k) is not null) then
       v_str := trim(ihook.getColumnValue(rowform, 'CNCPT_CONCAT_STR_'|| k));
       cnt := nci_11179.getwordcount(v_str);
       v_nm := '';
       for i in  1..cnt loop
          v_cncpt_nm := nci_11179.getWord(v_str, i, cnt);
           for cur in(select item_id, item_nm , item_long_nm from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
              ihook.setColumnValue(rowform, 'CNCPT_' || k  ||'_ITEM_ID_' || i,cur.item_id);
              ihook.setColumnValue(rowform, 'CNCPT_' || k || '_VER_NR_' || i, 1);
              v_dec_nm := trim(cur.item_nm || ' ' || v_dec_nm);
                  v_nm := trim(cur.item_long_nm || ':' || v_nm);
            end loop;
              
     end loop;
               nci_11179.CncptCombExists(substr(v_nm,1, length(v_nm)-1),4+k,v_item_id, v_ver_nr,v_long_nm, v_def);
              ihook.setColumnValue(rowform, 'ITEM_' || k  ||'_ID',v_item_id);
              ihook.setColumnValue(rowform, 'ITEM_' || k || '_VER_NR', v_ver_nr);
       end if;
       end loop;
              ihook.setColumnValue(rowform, 'GEN_STR',v_dec_nm ) ;
              ihook.setColumnValue(rowform, 'ADMIN_STUS_ID',66);
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'VALIDATED');
              if (   ihook.getColumnValue(rowform, 'ITEM_1_ID') is not null and ihook.getColumnValue(rowform, 'ITEM_2_ID') is not null) then
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'DUPLICATE DEC');
              end if;
              if (   ihook.getColumnValue(rowform, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(rowform, 'CNCPT_2_ITEM_ID_1') is null) then
              ihook.setColumnValue(rowform, 'CTL_VAL_MSG', 'OC or PROP missing.');
              end if;
        rows.extend;
      rows(rows.last) := rowform;
     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
     HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
  end if;
   
   
    IF HOOKINPUT.ANSWERID = 2 THEN  -- Create
      forms              := hookInput.forms;
      form1              := forms(1);
    
      rowform := form1.rowset.rowset(1);
    
    if (ihook.getColumnValue(rowform, 'CTL_VAL_MSG') <> 'VALIDATED') then
      rows := t_rows();
      rows.extend;
    rows(rows.last) := rowform;
     rowset := t_rowset(rows, 'AI Creation With Concepts', 1, 'NCI_STG_AI_CNCPT_CREAT');
     
    hookOutput.forms := nci_chng_mgmt.getDECCreateForm(rowset);
    HOOKOUTPUT.QUESTION    := nci_chng_mgmt.getDECCreateQuestion();
    else -- Validated
  -- Create OC if new
     v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
     v_oc_ver_nr := ihook.getColumnValue(rowform, 'ITEM_1_VER_NR');
     if v_oc_id is null then
      nci_chng_mgmt.createAIWithConcept(rowform, 1,5, actions);
          v_oc_id := ihook.getColumnValue(rowform, 'ITEM_1_ID');
     end if;
     v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
     v_prop_ver_nr := ihook.getColumnValue(rowform, 'ITEM_2_VER_NR');
     if v_prop_id is null then
      nci_chng_mgmt.createAIWithConcept(rowform, 2,6,  actions);
     v_prop_id := ihook.getColumnValue(rowform, 'ITEM_2_ID');
    end if;
--    raise_application_error(-20000, v_oc_id || 'Test' || v_prop_id);
      nci_chng_mgmt.createDEC(rowform, actions, v_item_id);
     hookoutput.message := 'DEC Created Successfully with ID ' || v_item_id ;
       hookoutput.actions := actions;
    
  -- Create DEC
  
  end if;
  
   end if;
   end if;
   


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
/
