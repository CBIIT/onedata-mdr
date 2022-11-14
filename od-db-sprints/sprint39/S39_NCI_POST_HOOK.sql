create or replace PACKAGE nci_post_hook AS

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);

procedure spRefDocBlobIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAISTUpd ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAICDEUpd ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAIVDUpd ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAIDel ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAINmDef ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spPostDesAINmDef ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAISTIns ( v_data_in in clob, v_data_out out clob);
procedure spDervCompIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spModRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spQuestRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spQuestUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spQuestRepUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spQuestVVRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spAIIns ( v_data_in in clob, v_data_out out clob);
procedure spCSFormIns ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spPVUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spCSIUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure            sp_postprocess ( v_data_in in clob, v_data_out out clob);
procedure spProtocolUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spOrgUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spPostTypeDetails ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);

END;
/
create or replace PACKAGE BODY NCI_POST_HOOK AS

PROCEDURE            spDEPrefQuestPost (
    row_ori   IN     t_row,
    actions   IN OUT t_actions)
AS
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    long_nm          VARCHAR(200);
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    msg              VARCHAR2 (4000);
BEGIN
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');
    rows := t_rows ();

    IF (ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT') IS NOT NULL)
    THEN
        SELECT cntxt_item_id, cntxt_ver_nr
          INTO v_cntxt_id, v_cntxt_ver_nr
          FROM admin_item
         WHERE item_id = v_item_id AND ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
        ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
        ihook.setColumnValue (            row,
            'REF_NM',
            'PQT');
        ihook.setColumnValue (
            row,
            'REF_DESC',
            ihook.getColumnValue (row_ori, 'PREF_QUEST_TXT'));
        ihook.setColumnValue (row, 'LANG_ID', 1000);
        ihook.setColumnValue (row, 'NCI_CNTXT_ITEM_ID', v_cntxt_id);
        ihook.setColumnValue (row, 'NCI_CNTXT_VER_NR', v_cntxt_ver_nr);
        ihook.setColumnValue (row, 'REF_TYP_ID', 80);

        ihook.setColumnValue (row, 'REF_ID', -1);
        v_action_typ := 'insert';

        FOR cur
            IN (SELECT REF_ID
                  FROM REF
                 WHERE     item_id = v_item_id
                       AND ver_nr = v_ver_nr
                       AND ref_typ_id = 80)
        LOOP
            ihook.setColumnValue (row, 'REF_ID', cur.ref_id);
            v_action_typ := 'update';
        END LOOP;

        rows.EXTEND;
        rows (rows.LAST) := row;
        action :=
            t_actionrowset (rows,
                            'References (for Edit)',
                            2,
                            0,
                            v_action_typ);
        actions.EXTEND;
        actions (actions.LAST) := action;
        /*DSRMWS-455 PREF_QUEST_TXT IS NULL Start 01/08/2021 AT*/
        ELSE
        
        SELECT SUBSTR(ITEM_NM,1,195)
          INTO LONG_NM
          FROM admin_item
         WHERE item_id = v_item_id AND ver_nr = v_ver_nr;

        row := t_row ();
        ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
        ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
        ihook.setColumnValue (row, 'REF_NM', 'PQT');
        
        ihook.setColumnValue (
            row,
            'REF_DESC',
            'Data Element ' || LONG_NM || ' does not have Preferred Question Text');
        
        FOR cur
            IN (SELECT REF_ID
                  FROM REF
                 WHERE     item_id = v_item_id
                       AND ver_nr = v_ver_nr
                       AND ref_typ_id = 80)
        LOOP
            ihook.setColumnValue (row, 'REF_ID', cur.ref_id);
            v_action_typ := 'update';
        END LOOP;

        rows.EXTEND;
        rows (rows.LAST) := row;
        action :=
            t_actionrowset (rows,
                            'References (for Edit)',
                            2,
                            0,
                            v_action_typ);
        actions.EXTEND;
        actions (actions.LAST) := action;
        /*DSRMWS-455 PREF_QUEST_TXT IS NULL END 01/08/2021 AT*/
        END IF;
END;

procedure            sp_postprocess ( v_data_in in clob, v_data_out out clob)
as
 hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
  v_temp integer;
  actions t_actions := t_actions();
    action t_actionRowset;
    rows  t_rows;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

execute immediate 'truncate table NCI_ADMIN_ITEM_EXT';
--commit;

--execute immediate 'truncate table onedata_ra.NCI_ADMIN_ITEM_EXT';

delete from onedata_ra.NCI_ADMIN_ITEM_EXT;
commit;

--- Data Element
insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR, USED_BY)
select ai.item_id, ai.ver_nr, a.used_by
from  admin_item ai,
(SELECT item_id, ver_nr, LISTAGG(item_nm, ',') WITHIN GROUP (ORDER by ITEM_ID) AS USED_BY
FROM (select distinct ub.item_id,ub.ver_nr, c.item_nm from vw_nci_used_by ub, vw_cntxt c where ub.cntxt_item_id = c.item_id and ub.cntxt_ver_nr = c.ver_nr and ub.owned_by=0 )
GROUP BY item_id, ver_nr) a
where ai.item_id = a.item_id (+) and ai.ver_nr = a.ver_nr(+)
and ai.admin_item_typ_id = 4;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def, CNCPT_CONCAT_WITH_INT)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def, b.cncpt_cd_int
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_nm, ai.item_nm || '::' || cai.NCI_CNCPT_VAL),ai.item_nm), ' ')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_desc, ai.item_desc || '::' || cai.NCI_CNCPT_VAL),ai.item_desc),1, 750), '_')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF,
 LISTAGG(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_long_nm, ai.item_long_nm || '::' || cai.NCI_CNCPT_VAL),ai.item_long_nm), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD_INT
from cncpt_admin_item cai, admin_item ai where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.admin_item_typ_id in (1,2,3,5,6,7);
commit;



insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def, CNCPT_CONCAT_WITH_INT, CNCPT_CONCAT_SRC_TYP)
select ai.item_id, ai.ver_nr, b.cncpt_cd, b.CNCPT_nm, b.cncpt_def, b.cncpt_cd_int, b.cncpt_src_typ
from  admin_item ai,
(SELECT cai.item_id, cai.ver_nr, LISTAGG(ai.item_long_nm, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD ,
LISTAGG(ok.obj_key_desc, ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_SRC_TYP,
LISTAGG(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_nm, ai.item_nm || '::' || cai.NCI_CNCPT_VAL),ai.item_nm), ' ')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_NM ,
 LISTAGG(substr(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_desc, ai.item_desc || '::' || cai.NCI_CNCPT_VAL),ai.item_desc),1, 750), '_')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_DEF,
 LISTAGG(decode(ai.item_long_nm, 'C45255',decode( cai.nci_cncpt_val,null, ai.item_long_nm, ai.item_long_nm || '::' || cai.NCI_CNCPT_VAL),ai.item_long_nm), ':')WITHIN GROUP (ORDER by cai.nci_ord desc) as CNCPT_CD_INT
from cncpt_admin_item cai, admin_item ai, cncpt c, obj_key ok where ai.item_id = cai.cncpt_item_id and ai.ver_nr = cai.cncpt_ver_nr and cai.cncpt_item_id = c.item_id
and cai.cncpt_ver_nr = c.ver_nr and c.evs_src_id = ok.obj_key_id (+)
group by cai.item_id, cai.ver_nr) b
where ai.item_id = b.item_id (+) and ai.ver_nr = b.ver_nr (+)
and ai.admin_item_typ_id = 53;
commit;

insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR,  CNCPT_CONCAT, CNCPT_CONCAT_NM, cncpt_concat_def)
select ai.item_id, ai.ver_nr, ai.item_long_nm, ai.item_nm, ai.item_desc
from admin_item ai where ai.admin_item_typ_id = 49;
commit;


insert into NCI_ADMIN_ITEM_EXT (ITEM_ID, VER_NR)
select ai.item_id, ai.ver_nr from  admin_item ai
where ai.admin_item_typ_id in (8,9,50,51,52,54,56);
commit;


update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm, cncpt_concat_with_int) = (select item_nm, item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;

insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;

delete from nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

-- rolling 7 day user cart

delete from nci_usr_cart where creat_dt < sysdate - 7 and Cart_nm ='Default';
commit;

delete from onedata_ra.nci_usr_cart where creat_dt < sysdate - 7 and cart_nm = 'Default';
commit;

-- rolling 30 day delete of download collection
-- Tracker 1724 - Added condition for Retain_ind = 0

delete from nci_dload_dtl where hdr_id in (select hdr_id from nci_dload_hdr where creat_dt < sysdate - 7 and nvl(RETAIN_IND,0) = 0);
commit;

delete from onedata_ra.nci_dload_dtl where hdr_id in (select hdr_id from nci_dload_hdr where creat_dt < sysdate - 7 and nvl(RETAIN_IND,0) = 0);
commit;

delete from nci_dload_hdr where creat_dt < sysdate - 7 and nvl(RETAIN_IND,0) = 0;
commit;

delete from onedata_ra.nci_dload_hdr where creat_dt < sysdate - 7 and nvl(RETAIN_IND,0) = 0;
commit;

/*
delete from nci_dload_dtl where hdr_id in (select hdr_id from nci_dload_hdr where creat_dt < sysdate - 7 );
commit;

delete from onedata_ra.nci_dload_dtl where hdr_id in (select hdr_id from nci_dload_hdr where creat_dt < sysdate - 30 );
commit;

delete from nci_dload_hdr where creat_dt < sysdate - 30 ;
commit;

delete from onedata_ra.nci_dload_hdr where creat_dt < sysdate - 30 ;
commit;
*/

-- Insert DE-CSI relationship if Form-CSI is created. Tracker 1449
/*
for cur in (Select r.* from admin_item ai, nci_admin_item_rel r where ai.item_id = r.c_item_id and ai.ver_nr = r.c_item_ver_nr and
r.rel_typ_id = 65 and r.creat_dt > sysdate - 1 and ai.admin_item_typ_id = 54) loop
 insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, creat_usr_id, lst_upd_usr_id)
 select distinct cur.p_item_id, cur.p_item_ver_nr ,v.de_item_id, v.de_ver_nr, 65, cur.creat_usr_id, cur.creat_usr_id
 from VW_NCI_MODULE_DE v where v.frm_item_id = cur.c_item_id and v.frm_ver_nr = cur.c_item_ver_nr 
 and (cur.p_item_id, cur.p_item_ver_nr, v.de_item_id, v.de_ver_nr) not in (select p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr from
 nci_admin_item_rel where rel_typ_id = 65);
 commit;
end loop;
*/

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;

procedure spModRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2)
as
 hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
  v_temp integer;
  actions t_actions := t_actions();
    action t_actionRowset;
    rows  t_rows;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

  if (v_mode ='M') then

    row_ori := hookInput.originalRowset.rowset (1);
    select nvl(max(disp_ord),-1) into v_temp from nci_admin_item_rel where rel_typ_id = 61 and p_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID')
    and p_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and nvl(fld_delete,0) = 0;
 --    raise_application_error(-20000, v_temp);

 update nci_admin_item_rel set disp_ord = v_temp+1 where p_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID')
    and p_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and rel_typ_id = 61 and C_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID')
    and C_item_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR');
    commit;
 --ihook.setColumnValue(row_ori, 'DISP_ORD', v_temp+1);
  --  rows := t_rows();
   -- rows.extend;
     --       rows(rows.last) := row_ori;

 --action := t_actionRowset(rows, 'Generic AI Relationship', 2, 1, 'restore');
  --  actions.extend; actions(actions.last) := action;
  --hookoutput.actions:= actions;

end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spQuestRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2)
as
 hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
  v_temp integer;
  actions t_actions := t_actions();
    action t_actionRowset;
    rows  t_rows;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

  if (v_mode ='Q') then

    row_ori := hookInput.originalRowset.rowset (1);
    select nvl(max(disp_ord),-1) into v_temp from nci_admin_item_rel_alt_key where rel_typ_id = 63 and p_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID')
    and p_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR') and nvl(fld_delete,0) = 0;
 --    raise_application_error(-20000, v_temp);


 update nci_admin_item_rel_alt_key set disp_ord = v_temp+1 where NCI_PUB_ID = ihook.getColumnValue(row_ori, 'NCI_PUB_ID')
    and NCI_VER_NR = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
    commit;
 --ihook.setColumnValue(row_ori, 'DISP_ORD', v_temp+1);
  --  rows := t_rows();
   -- rows.extend;
     --       rows(rows.last) := row_ori;

 --action := t_actionRowset(rows, 'Generic AI Relationship', 2, 1, 'restore');
  --  actions.extend; actions(actions.last) := action;
  --hookoutput.actions:= actions;

end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spQuestVVRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2)
as
 hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
  v_temp integer;
  actions t_actions := t_actions();
    action t_actionRowset;
    rows  t_rows;
  BEGIN
   hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

  if (v_mode ='V') then

    row_ori := hookInput.originalRowset.rowset (1);
    select nvl(max(disp_ord),-1) into v_temp from nci_quest_valid_value where  q_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID')
    and q_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR') and nvl(fld_delete,0) = 0;
 --    raise_application_error(-20000, v_temp);


 update NCI_QUEST_VALID_VALUE set disp_ord = v_temp+1 where NCI_PUB_ID = ihook.getColumnValue(row_ori, 'NCI_PUB_ID')
    and NCI_VER_NR = ihook.getColumnValue(row_ori, 'NCI_VER_NR');
    commit;

end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_temp integer :=0;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   -- raise_application_error(-20000, ihook.getColumnValue(row_ori,'REF_TYP_ID'));
  if (ihook.getColumnValue(row_ori,'REF_TYP_ID') = 80 or ihook.getColumnOldValue(row_ori,'REF_TYP_ID') = 80) then
    raise_application_error(-20000,'You cannot insert or update Preferred Question Text from Reference Documents. Please use Section 4 - Relational/Representation Attributes.');
 end if;

select count(*) into v_temp from obj_key  where obj_key_id = ihook.getColumnValue(row_ori,'REF_TYP_ID') and upper(obj_key_desc) like '%QUESTION TEXT%';

 if (ihook.getColumnValue(row_ori,'REF_DESC') is null and v_temp > 0 ) then
    raise_application_error(-20000,'Please specify Reference Document Text for this document type.');
 end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spRefDocBlobIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_temp integer :=0;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
          select nci_cntxt_item_id, nci_cntxt_ver_nr into v_item_id, v_ver_nr from ref where
        ref_id = ihook.getColumnValue(row_ori, 'NCI_REF_ID');
 if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
    -- raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ' || v_item_id || ' ' || v_user_id);
    raise_application_error(-20000, 'You are not authorized to insert/update or delete in this Context. ' );
        return;
    end if;
select count(*) into v_temp from obj_key ok, ref r  where obj_key_id = r.REF_TYP_ID and upper(obj_key_desc) like '%QUESTION TEXT%' and r.ref_id = ihook.getColumnValue(row_ori,'NCI_REF_ID');

 if ( v_temp > 0 ) then
    raise_application_error(-20000,'Blobs cannot be added for this type of document.');
 end if;

if (ihook.getColumnValue(row_ori,'FILE_NM') is null) then
    raise_application_error(-20000,'An attached file is required. Select/Change to update the file. To delete this Reference Document Blob, return to the grid view of the Blobs and select the Blob and the Delete icon.');
end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spCSFormIns ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2 )
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_csi_item_id number;
    v_csi_ver_nr number(4,2);
  
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
  
    v_csi_item_id := ihook.getColumnValue(row_ori ,'P_ITEM_ID');
    v_csi_ver_nr := ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
 
-- Insert DE-CSI relationship if Form-CSI is created. Tracker 1449

--raise_application_error(-20000, v_csi_item_id);

 insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, CREAT_USR_ID, LST_UPD_USR_ID )
 select distinct v_csi_item_id ,v_csi_ver_nr,v.de_item_id, v.de_ver_nr, 65, v_user_id, v_user_id
 from VW_NCI_MODULE_DE v where v.frm_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and v.frm_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') 
 and ( v.de_item_id, v.de_ver_nr) not in (select  c_item_id, c_item_ver_nr from
 nci_admin_item_rel where rel_typ_id = 65 and p_item_id = v_csi_item_id and p_item_ver_nr = v_csi_ver_nr);
-- raise_application_error (-20000, v_user_id);
 commit;
 


/*
 insert into nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id )
 select distinct v_csi_item_id ,v_csi_ver_nr,v.de_item_id, v.de_ver_nr, 65
 from VW_NCI_MODULE_DE v where v.frm_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and v.frm_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') 
 and ( v.de_item_id, v.de_ver_nr) not in (select  c_item_id, c_item_ver_nr from
 nci_admin_item_rel where rel_typ_id = 65 and p_item_id = v_csi_item_id and p_item_ver_nr = v_csi_ver_nr);
 commit;
*/

 insert into onedata_ra.nci_admin_item_rel (p_item_id, p_item_ver_nr, c_item_id, c_item_ver_nr, rel_typ_id, CREAT_USR_ID, LST_UPD_USR_ID)
 select distinct v_csi_item_id ,v_csi_ver_nr,v.de_item_id, v.de_ver_nr, 65, v_user_id, v_user_id
 from VW_NCI_MODULE_DE v where v.frm_item_id = ihook.getColumnValue(row_ori, 'C_ITEM_ID') and v.frm_ver_nr = ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR') 
 and ( v.de_item_id, v.de_ver_nr) not in (select  c_item_id, c_item_ver_nr from
 onedata_ra.nci_admin_item_rel where rel_typ_id = 65 and p_item_id = v_csi_item_id and p_item_ver_nr = v_csi_ver_nr);
 commit;
  
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spAINmDef ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
 
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
     if (nci_11179_2.isUserAuth(ihook.getColumnValue(row_ori, 'ITEM_ID') ,ihook.getColumnValue(row_ori, 'VER_NR'), v_usr_id) = false) then
    -- raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ' || v_item_id || ' ' || v_user_id);
    raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ' );
        return;
    end if;
  if (ihook.getColumnValue(row_ori,'NM_TYP_ID') = 83 and hookinput.originalRowset.tablename like '%NMS%') then
  for cur in (select * from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and nm_id <> ihook.getColumnValue(row_ori, 'NM_ID')
  and nm_typ_id = 83) loop
    raise_application_error(-20000,'Only one manually curated name can be specified.');
    return;
    end loop;
 end if;
  if (ihook.getColumnValue(row_ori,'NCI_DEF_TYP_ID') = 82 and hookinput.originalRowset.tablename  like '%DEF%') then
  for cur in (select * from alt_def where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and def_id <> ihook.getColumnValue(row_ori, 'DEF_ID')
  and nci_def_typ_id = 82) loop
    raise_application_error(-20000,'Only one manually curated definition can be specified.');
    return;
    end loop;
 end if;
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

--Jira 1924
procedure spPostDesAINmDef ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    nw_cntxt varchar2(64);
action t_actionRowset;
   actions t_actions := t_actions();
      rows      t_rows;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
    --raise_application_error(-20000,'NM_TYP_ID: ' || ihook.getColumnValue(row_ori, 'NM_TYP_ID'));
   
 if (nvl(ihook.getColumnValue(row_ori, 'NM_TYP_ID'),0) = 1038) then
 --for cur in (select * from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR') and nm_id <> ihook.getColumnValue(row_ori, 'NM_ID') and nm_typ_id = 1038) loop
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Alternate Name will be set to Context Name for Used By.' || chr(13) );
    --raise_application_error(-20000,'WARNING: Alternate Name will be set to Context Name for Used By.');
    --return;
    --end loop;
 end if;
 
  rows := t_rows();
  
rows.EXTEND;
            rows (rows.LAST) := row_ori;
            action :=
                t_actionrowset (rows,
                                'Designation Import',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
    
 
    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;
  
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

--end Jira1924


procedure spPVUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   v_item_id := ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');

     if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
     raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

for cur in (select * from vw_admin_stus where ihook.getColumnValue(row_ori, 'PERM_VAL_END_DT') is not null and ihook.getColumnValue(row_ori, 'PERM_VAL_END_DT') < nvl(ihook.getColumnValue(row_ori, 'PERM_VAL_BEG_DT'), sysdate) ) loop
      raise_application_error(-20000, 'Expiration date has to be the same or greater than Effective date.');
    return;
end loop;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spProtocolUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if (ihook.getColumnValue(row_ori, 'LEAD_ORG_ID') is not null ) then
   --and ihook.getcolumnValue(row_ori,'LEAD_ORG_ID') <> ihook.getColumnOldValue(row_ori, 'LEAD_ORG_ID')) then
   -- Check if the org name is less than 30
    for cur in (select org_nm from   nci_org where entty_id = ihook.getColumnValue(row_ori, 'LEAD_ORG_ID') and length(org_nm) > 30) loop
      raise_application_error(-20000, 'Please choose a lead org that has a name less than or equal to 30.');
    return;
end loop;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spQuestUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if (ihook.getColumnValue(row_ori, 'DEFLT_VAL') is not null ) then
   -- Check if valid values
    for cur in (select * from   nci_quest_valid_value where q_pub_id = ihook.getColumnValue(row_ori, 'NCI_PUB_ID') 
    and q_ver_nr = ihook.getColumnValue(row_ori, 'NCI_VER_NR')) loop
      raise_application_error(-20000, 'Cannot set non-enumerated default for question with valid values.');
    return;
end loop;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spQuestRepUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if (ihook.getColumnValue(row_ori, 'VAL') is not null ) then
   -- Check if valid values
    for cur in (select * from   nci_quest_valid_value where q_pub_id = ihook.getColumnValue(row_ori, 'QUEST_PUB_ID') 
    and q_ver_nr = ihook.getColumnValue(row_ori, 'QUEST_VER_NR')) loop
      raise_application_error(-20000, 'Cannot set non-enumerated default for question with valid values.');
    return;
end loop;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spOrgUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   if ( ihook.getcolumnValue(row_ori,'ORG_NM') <> ihook.getColumnOldValue(row_ori, 'ORG_NM') and length(ihook.getcolumnvalue(row_ori,'ORG_NM'))>30) then
   -- Check if the org name is less than 30
    for cur in (select * from   nci_protcl where lead_org_id = ihook.getColumnValue(row_ori, 'ENTTY_ID')) loop
      raise_application_error(-20000, 'Organization used as lead org in protocol. Restriction on organization name to be 30 characters or less.');
    return;
end loop;
end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spAIDel ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    v_item_id number;
    v_ver_nr number(4,2);
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

     if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
     raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

for cur in (select * from admin_item where item_id = v_item_id and ver_nr = v_ver_nr and nvl(currnt_ver_ind,0) = 1 ) loop
      raise_application_error(-20000, 'Cannot delete the latest version. Please set another version to latest and then delete.');
    return;
end loop;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

procedure spCSIUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;
    row t_row;
    rows  t_rows;
    v_item_id number;
    v_ver_nr number(4,2);
       actions          t_actions := t_actions ();
       v_ful_path varchar2(4000) := '';
    action           t_actionRowset;
  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
  if (nci_11179_2.isCSParentCSIValid(row_ori) = false) then
      raise_application_error(-20000, 'Parent CSI should belong to the same Classification Scheme as specified.');
      V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
      return;
  end if;

rows := t_rows();

/*
if ihook.getColumnValue(row_ori, 'P_ITEM_ID') is not null then
    select ful_path into v_ful_path from nci_clsfctn_schm_item where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
end if;


if (ihook.getColumnValue(row_ori, 'CS_ITEM_ID') <> ihook.getColumnOldValue(row_ori, 'CS_ITEM_ID')) then -- cs has changed, chnge cs for all children

nci_11179_2.updCSIHier (row_ori,actions);
if (actions.count > 0) then
            hookoutput.actions := actions;
    end if;
end if;

*/


    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;


-- Can only add Components if Derivation Rule is set
procedure spDervCompIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
    for cur in (select * from de where item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR')
    and DERV_RUL is null) loop
    raise_application_error(-20000,'Please set the Derivation Rule first.');
 end loop;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


-- Can only add Components if Derivation Rule is set
procedure spPostTypeDetails ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
    if (ihook.getColumnValue(row_ori, 'OBJ_TYP_ID') in (11,15) and length(ihook.getColumnValue(row_ori,'NCI_CD')) > 20) then 
    raise_application_error(-20000,'caDSR Legacy code has to be less than or equal to 20 characters.');
    end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

-- AI Insert
procedure spAIIns ( v_data_in in clob, v_data_out out clob)
as
hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    row_ori          t_row;

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);

    for cur in (select * from vw_admin_stus where stus_id = nvl(ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID'),-1) and upper(stus_nm) like '%RETIRED%'
    and ihook.getColumnValue(row_ori, 'UNTL_DT') is null) loop
    raise_application_error(-20000,'Cannot retire an Administered Item without expiration date.');
    return;
    end loop;

for cur in (select * from vw_admin_stus where stus_id = nvl(ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID'),-1) and upper(stus_nm) like '%RETIRED%'
and ihook.getColumnValue(row_ori, 'UNTL_DT') is not null and ihook.getColumnValue(row_ori, 'UNTL_DT') < nvl(ihook.getColumnValue(row_ori, 'EFF_DT'), sysdate) ) loop
 raise_application_error(-20000, 'Expiration date has to be the same or greater than Effective date.');
    return;
end loop;

for cur in (select ai.item_id item_id from admin_item ai
            where
            trim(ai.ITEM_LONG_NM)=trim(ihook.getColumnValue(row_ori,'ITEM_LONG_NM'))
        --    and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')
            and ai.item_id <>  nvl(ihook.getColumnValue(row_ori, 'ITEM_ID'),0)
            and ai.admin_item_typ_id = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') )
            loop
               raise_application_error(-20000, 'Duplicate found based on context/short name: ' || cur.item_id || chr(13));
                return;
            end loop;


 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;



PROCEDURE            spAISTUpd (
    v_data_in    IN     CLOB,
    v_data_out      OUT CLOB,
    v_usr_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           VARCHAR2 (255);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    v_item_desc       VARCHAR2 (4000);
    v_admin_item_typ    number;
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

  if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;


    -- Tracker 554
  -- raise_application_error(-20000, hookinput.originalRowset.tablename);

  if (hookinput.originalRowset.tablename = 'ADMIN_ITEM') then
    if (ihook.getColumnValue (row_ori, 'ITEM_DESC') <>  ihook.getColumnOldValue (row_ori, 'ITEM_DESC')
    --   and ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID') in (2,5,6,7,49,53)) then
       and ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID') in (2,5,6,7,53)) then
        raise_application_error(-20000, 'Definition for this Administered Item cannot be updated. ');
        return;
    end if;

    for cur in (select * from vw_admin_stus where stus_id = nvl(ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID'),-1) and upper(stus_nm) like '%RETIRED%'
    and ihook.getColumnValue(row_ori, 'UNTL_DT') is null) loop
    raise_application_error(-20000,'Cannot retire an Administered Item without expiration date.');
    return;
    end loop;



    if (ihook.getColumnValue(row_ori, 'UNTL_DT') is not null and ihook.getColumnValue(row_ori, 'UNTL_DT') < nvl(ihook.getColumnValue(row_ori, 'EFF_DT'), sysdate) ) then
        raise_application_error(-20000, 'Expiration date has to be the same or greater than Effective date.');

         return;
    end if;


-- if form context is changed, then change context for all modules. 

    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 8 and ihook.getColumnValue(row_ori,'ITEM_NM') <> ihook.getColumnOldValue(row_ori,'ITEM_NM')) then
    -- if context name has changed
    -- disable all triggers on admin_item and alt_nms
        execute immediate 'ALTER TABLE ADMIN_ITEM DISABLE ALL TRIGGERS';
        execute immediate 'ALTER TABLE ALT_NMS DISABLE ALL TRIGGERS';
        update admin_item set CNTXT_NM_DN = ihook.getColumnValue(row_ori,'ITEM_NM') where CNTXT_ITEM_ID = ihook.getColumnValue(row_ori,'ITEM_ID')
        and CNTXT_VER_NR = ihook.getColumnValue(row_ori,'VER_NR');
        update alt_nms set CNTXT_NM_DN = ihook.getColumnValue(row_ori,'ITEM_NM') where CNTXT_ITEM_ID = ihook.getColumnValue(row_ori,'ITEM_ID')
        and CNTXT_VER_NR = ihook.getColumnValue(row_ori,'VER_NR');
        commit;
        execute immediate 'ALTER TABLE ADMIN_ITEM ENABLE ALL TRIGGERS';
        execute immediate 'ALTER TABLE ALT_NMS ENABLE ALL TRIGGERS';
         DBMS_MVIEW.REFRESH('VW_CNCPT');
         DBMS_MVIEW.REFRESH('VW_CLSFCTN_SCHM_ITEM');
        
    end if;
        for cur in (select ai.item_id item_id , ai.ver_nr from admin_item ai
            where
            trim(ai.ITEM_LONG_NM)=trim(ihook.getColumnValue(row_ori,'ITEM_LONG_NM'))
        --    and  ai.ver_nr =  ihook.getColumnValue(rowai, 'VER_NR')
            and ai.cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')
            and ai.item_id <>  nvl(ihook.getColumnValue(row_ori, 'ITEM_ID'),0)
            and ai.admin_item_typ_id = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') )
            loop
               raise_application_error(-20000, 'Duplicate found based on context/short name: ' || cur.item_id || 'v' || cur.ver_nr || ' for ' || nvl(ihook.getColumnValue(row_ori, 'ITEM_ID'),0)
               || 'v' || nvl(ihook.getColumnValue(row_ori, 'VER_NR'),0) || chr(13));
                return;
            end loop;

    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 4) then -- Data Element
 --   raise_application_error (-20000, 'here');
           for cur     IN (SELECT ai.item_id, ai.ver_nr
                  FROM admin_item ai, de de
                 WHERE     ai.item_id = de.item_id
                       AND ai.ver_nr = de.ver_nr
                       AND (de.de_conc_item_id ,de.de_conc_ver_nr ,de.val_dom_item_id ,de.val_dom_ver_nr ) in
                       (select de_conc_item_id ,de_conc_ver_nr ,val_dom_item_id ,val_dom_ver_nr from de where item_id = v_item_id and ver_nr = v_ver_nr)
                       AND ai.item_id <> v_item_id
                       AND ai.cntxt_item_id =   ihook.getColumnValue (row_ori, 'CNTXT_ITEM_ID')
                       and ai.cntxt_ver_nr =   ihook.getColumnValue (row_ori, 'CNTXT_VER_NR')
                       and ai.item_long_nm =  ihook.getColumnValue (row_ori, 'ITEM_LONG_NM'))
                    --    and     ai.item_id = v_item_id
                     --                  AND ai.ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id || 'v' || cur.ver_nr || ' for ' || v_item_id || 'v' || v_ver_nr);
            RETURN;
        END LOOP;
        
     

    end if;



    if (ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID')= 3 and ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID') = 75) then
    for cur in (select item_id, ver_nr from value_dom where item_id = v_item_id and ver_nr = v_ver_nr and VAL_DOM_TYP_ID = 17) loop
      select count(*) into v_temp from perm_val where val_dom_item_id = v_item_id and val_dom_Ver_nr = v_ver_nr and nvl(fld_delete,0) = 0;
            if v_temp = 0 then
                raise_application_error(-20000, 'An Enumerated VD WFS cannot be Released if there are no permissible values.');
                return;
            end if;
    end loop;
    end if;
    
  
  end if;
  
  -- Cannot release a DDE without components
      IF (hookinput.originalRowset.tablename = 'ADMIN_ITEM' and ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID')= 4
      and ihook.getColumnOldValue(row_ori, 'ADMIN_STUS_ID') <> ihook.getColumnValue (row_ori, 'ADMIN_STUS_ID') and ihook.getColumnValue (row_ori, 'ADMIN_STUS_ID')=75) then
        for cur in (select * from de where nvl(derv_de_ind,0) = 1 and item_id = v_item_id and ver_nr = v_ver_nr) loop
            select count(*) into v_temp from nci_admin_item_rel where p_item_id = v_item_id and p_item_ver_nr = v_ver_nr and rel_typ_id = 66 and nvl(fld_delete,0) = 0;
            if (v_temp = 0) then
                raise_application_error(-20000, 'Cannot release a DDE without Components.');
                return;
            
            end if;
        end loop;
        
  
  end if;
  
-- Released DE cannot have a  DEC and VD

  
      IF (hookinput.originalRowset.tablename = 'ADMIN_ITEM' and ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID')= 4) then
  
   if (ihook.getColumnValue (row_ori, 'ADMIN_STUS_ID') = 75) then
  --     raise_application_error(-20000,'Here');
     for curdec in (select de.item_id from admin_item dec , de where de.item_id =  ihook.getColumnValue (row_ori, 'ITEM_ID') and de.ver_nr =  ihook.getColumnValue (row_ori, 'VER_NR')
    and de.de_conc_item_id = dec.item_id  
    and de.de_conc_ver_nr  = dec.ver_nr and upper(dec.admin_stus_nm_dn) like '%RETIRED%' union
    select vd.item_id from admin_item vd, de where de.val_dom_item_id = vd.item_id and de.item_id =  ihook.getColumnValue (row_ori, 'ITEM_ID') and de.ver_nr =  ihook.getColumnValue (row_ori, 'VER_NR')
    and de.val_dom_Ver_nr = vd.ver_nr and  upper(vd.admin_stus_nm_dn) like '%RETIRED%' ) loop
    
            raise_application_error (-20000,
                                     'Entry not saved. Cannot associated Retired DEC or VD with a Released CDE. ' );
            RETURN;
        END LOOP;
           for curdec in (select de.item_id from admin_item dec , de where de.item_id =  ihook.getColumnValue (row_ori, 'ITEM_ID') and de.ver_nr =  ihook.getColumnValue (row_ori, 'VER_NR')
    and de.de_conc_item_id = dec.item_id  
    and de.de_conc_ver_nr  = dec.ver_nr and upper(dec.admin_stus_nm_dn) like '%DRAFT NEW%' union
    select vd.item_id from admin_item vd, de where de.val_dom_item_id = vd.item_id and de.item_id =  ihook.getColumnValue (row_ori, 'ITEM_ID') and de.ver_nr =  ihook.getColumnValue (row_ori, 'VER_NR')
    and de.val_dom_Ver_nr = vd.ver_nr and  upper(vd.admin_stus_nm_dn) like '%DRAFT NEW%' ) loop
         hookoutput.message :=  '  Associated DEC and VD should be Released, Released Non-Compliant, or Draft Mod.' ;
           
        END LOOP;
   end if;
   end if;
   
   
 
    IF (hookinput.originalRowset.tablename = 'DE_CONC')
    THEN
        FOR cur
            IN (SELECT ai.item_id
                  FROM admin_item ai, de_conc dec
                 WHERE     ai.item_id = dec.item_id
                       AND ai.ver_nr = dec.ver_nr
                       AND dec.obj_cls_item_id =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                       AND dec.obj_cls_ver_nr =
                           ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                       AND dec.prop_item_id =
                           ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                       AND dec.prop_ver_nr =
                           ihook.getColumnValue (row_ori, 'PROP_VER_NR')
                       AND dec.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DEC found. ' || cur.item_id);
            RETURN;
        END LOOP;

        IF (   ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'OBJ_CLS_VER_NR')
            OR ihook.getColumnValue (row_ori, 'PROP_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'PROP_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'PROP_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'PROP_VER_NR'))
        THEN
            SELECT SUBSTR (oc.item_nm || ' ' || prop.item_nm, 1, 255),
                   SUBSTR (oc.item_desc || ':' || prop.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item oc, admin_item prop
             WHERE     oc.item_id =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_ITEM_ID')
                   AND oc.ver_nr =
                       ihook.getColumnValue (row_ori, 'OBJ_CLS_VER_NR')
                   AND prop.item_id =
                       ihook.getColumnValue (row_ori, 'PROP_ITEM_ID')
                   AND prop.ver_nr =
                       ihook.getColumnValue (row_ori, 'PROP_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;
    END IF;
 
 -- Tracker 1679
    if (ihook.getColumnValue (row_ori, 'ADMIN_ITEM_TYP_ID')= 54 and 
    (ihook.getColumnValue (row_ori, 'CNTXT_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'CNTXT_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'CNTXT_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'CNTXT_VER_NR'))) then -- Form context change change module context
               rows := t_rows();
               for curmod in (select c_item_id, c_item_ver_nr from nci_admin_item_rel where rel_typ_id = 61 and p_item_id= v_item_id
               and p_item_ver_nr = v_ver_nr and nvl(fld_delete,0) =0) loop
               
       row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', curmod.c_item_id);
            ihook.setColumnValue (row, 'VER_NR', curmod.c_item_ver_nr);
            ihook.setColumnValue (row, 'CNTXT_ITEM_ID', ihook.getColumnValue (row_ori, 'CNTXT_ITEM_ID'));
            ihook.setColumnValue (row, 'CNTXT_VER_NR', ihook.getColumnValue (row_ori, 'CNTXT_VER_NR') );
            rows.EXTEND;
            rows (rows.LAST) := row;
            end loop;
            if (rows.count > 0) then
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
            end if;
    end if;
               
    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;
  -- hookoutput.message := 'Test';
    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE            spAICDEUpd (
    v_data_in    IN     CLOB,
    v_data_out      OUT CLOB,
    v_usr_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           VARCHAR2 (255);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    v_item_desc       VARCHAR2 (4000);
    v_long_nm       varchar2(30);
    v_admin_item_typ    number;
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

  if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;

   
   
  for cur in (select * from admin_item where item_id = ihook.getColumnValue (row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue (row_ori, 'VER_NR')
  and admin_stus_id = 75) loop
  --     raise_application_error(-20000,'Here');
     for curdec in (select dec.item_id from admin_item dec  where dec.item_id =  ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
    and upper(dec.admin_stus_nm_dn) like '%RETIRED%' union
        select vd.item_id from admin_item vd where vd.item_id =  ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID') and vd.ver_nr =  ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR')
    and  upper(vd.admin_stus_nm_dn) like '%RETIRED%' ) loop
                raise_application_error (-20000,
                                     'CDE not saved. Cannot associated Retired DEC or VD with a Released CDE. ' );
            RETURN;
        END LOOP;
   end loop;
    
    for cur in (select * from admin_item where item_id = ihook.getColumnValue (row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue (row_ori, 'VER_NR')
  and admin_stus_id = 75) loop
  --     raise_application_error(-20000,'Here');
     for curdec in (select dec.item_id from admin_item dec  where dec.item_id =  ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID') and dec.ver_nr =  ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
  and upper(dec.admin_stus_nm_dn) like '%DRAFT NEW%' union
    select vd.item_id from admin_item vd where vd.item_id =  ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID') and vd.ver_nr =  ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR')
   and  upper(vd.admin_stus_nm_dn) like '%DRAFT NEW%' ) loop
    
           hookoutput.message :=   '   Associated DEC and VD should be Released, Released Non-Compliant, or Draft Mod.' ;
                                     
        END LOOP;
   end loop;

        FOR cur
            IN (SELECT ai.item_id, ai.ver_nr
                  FROM admin_item ai, de de
                 WHERE     ai.item_id = de.item_id
                       AND ai.ver_nr = de.ver_nr
                       AND de.de_conc_item_id =
                           ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                       AND de.de_conc_ver_nr =
                           ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                       AND de.val_dom_item_id =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                       AND de.val_dom_ver_nr =
                           ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR')
                       --    and ai.item_long_nm = 
                       AND de.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr, ai.item_long_nm) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr, ai.item_long_nm
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id || 'v' || cur.ver_nr || ' for ' || v_item_id || 'v' || v_ver_nr);
            RETURN;
        END LOOP;


        IF (   ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'DE_CONC_VER_NR')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_ITEM_ID')
            OR ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR') <>
               ihook.getColumnOldValue (row_ori, 'VAL_DOM_VER_NR'))
        THEN



            SELECT SUBSTR (dec.item_nm || ' ' || vd.item_nm, 1, 255),
                   SUBSTR (dec.item_desc || ':' || vd.item_desc, 1, 4000)
              INTO v_item_nm, v_item_def
              FROM admin_item dec, admin_item vd
             WHERE     dec.item_id =
                       ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
                   AND dec.ver_nr =
                       ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR')
                   AND vd.item_id =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
                   AND vd.ver_nr =
                       ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR');

            row := t_row ();
            ihook.setColumnValue (row, 'ITEM_ID', v_item_id);
            ihook.setColumnValue (row, 'VER_NR', v_ver_nr);
            ihook.setColumnValue (row, 'ITEM_NM', v_item_nm);
            select item_long_nm into v_long_nm from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
         --   raise_application_Error(-20000, 'Here' || instr(v_long_nm,ihook.getColumnOldValue(row_ori, 'DE_CONC_ITEM_ID')));
            if (instr(v_long_nm,ihook.getColumnOldValue(row_ori, 'DE_CONC_ITEM_ID')) > 0 and
             instr(v_long_nm,ihook.getColumnOldValue(row_ori, 'VAL_DOM_ITEM_ID')) > 0) then
        
            ihook.setColumnValue (row, 'ITEM_LONG_NM', ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') || 'v'
        || trim(to_char(ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'), '9999.99')) || ':' || ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') || 'v' ||
        trim(to_char(ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'), '9999.99')));
        end if;
            ihook.setColumnValue (row, 'ITEM_DESC', v_item_def);
            rows.EXTEND;
            rows (rows.LAST) := row;
            action :=
                t_actionrowset (rows,
                                'Administered Item',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
        END IF;

        spDEPrefQuestPost (row_ori, actions);

        -- Tracker 818 - if Derivation Rule is set, then

        if ((ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is not null and ihook.getColumnValue (row_ori, 'DERV_RUL') is null) or
        (ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is null and ihook.getColumnValue (row_ori, 'DERV_RUL') is not null)) then
            raise_application_error(-20000, 'DDE requires Derivation Type and Derivation Rule.');
            return;
        end if;

-- if the user tries to change a released CDE to a DDE, do not allow.   
     if (ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is not null and ihook.getColumnOldValue (row_ori, 'DERV_TYP_ID') is  null 
    and ihook.getColumnValue (row_ori, 'DERV_RUL') is not null and ihook.getColumnOldValue (row_ori, 'DERV_TYP_ID') is  null ) then
    for cur in (Select * from admin_item where item_id = v_item_id and ver_nr = v_ver_nr and admin_stus_nm_dn like '%RELEASED%') loop
                raise_application_error(-20000, 'Cannot change a Released CDE to a DDE.');
                return;
            
            end loop;
        end if;
        
    if (ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is  null and ihook.getColumnOldValue (row_ori, 'DERV_TYP_ID') is not null 
    and ihook.getColumnValue (row_ori, 'DERV_RUL') is null and ihook.getColumnOldValue (row_ori, 'DERV_TYP_ID') is not  null ) then
    for cur in (select * from nci_admin_item_rel where p_item_id = v_item_id and p_item_ver_nr = v_ver_nr and rel_typ_id = 66 and nvl(fld_delete,0) = 0) loop 
    
                raise_application_error(-20000, 'Cannot change a DDE to CDE as there are Components. Please delete components.');
                return;
            
            end loop;
        end if;


    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;
  -- hookoutput.message := 'Test';
    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


PROCEDURE            spAIVDUpd (
    v_data_in    IN     CLOB,
    v_data_out      OUT CLOB,
    v_usr_id in varchar2)
AS
    hookInput        t_hookInput;
    hookOutput       t_hookOutput := t_hookOutput ();
    actions          t_actions := t_actions ();
    action           t_actionRowset;
    row              t_row;
    rows             t_rows;
    row_ori          t_row;
    action_rows      t_rows := t_rows ();
    action_row       t_row;
    rowset           t_rowset;
    v_add            INTEGER := 0;
    v_action_typ     VARCHAR2 (30);
    v_temp           VARCHAR2 (255);
    v_item_id        NUMBER;
    v_ver_nr         NUMBER (4, 2);
    v_nm_id          NUMBER;
    v_cntxt_id       NUMBER;
    v_cntxt_ver_nr   NUMBER (4, 2);
    i                INTEGER := 0;
    column           t_column;
    v_item_nm        VARCHAR2 (255);
    v_item_def       VARCHAR2 (4000);
    v_item_desc       VARCHAR2 (4000);
    v_admin_item_typ    number;
    msg              VARCHAR2 (4000);
BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;
    rows := t_rows ();

    row_ori := hookInput.originalRowset.rowset (1);
    v_item_id := ihook.getColumnValue (row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue (row_ori, 'VER_NR');

  if (nci_11179_2.isUserAuth(v_item_id, v_ver_nr, v_usr_id) = false) then
        raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;


    -- Tracker 554
  -- raise_application_error(-20000, hookinput.originalRowset.tablename);


 if (hookinput.originalRowset.tablename = 'VALUE_DOM') then


    if ( ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') is not null and
         ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') <>  ihook.getColumnOldValue(row_ori, 'REP_CLS_ITEM_ID')) then

            select item_nm into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID')
            and ver_nr = ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR');
            --if ((trim(substr(v_item_nm, length(v_item_nm)-length(trim(v_temp)))) != v_temp) or
            --length(v_item_nm) < length(v_temp))then
            IF instr(v_item_nm,v_temp)=0 then
                select substr(v_item_nm || ' ' || rc.item_nm,1,255) ,
                substr(v_item_desc || ' ' || rc.item_desc,1,3999)
                into v_item_nm , v_item_desc
                from  admin_item rc
                where  rc.ver_nr =  ihook.getColumnValue(row_ori, 'REP_CLS_VER_NR')
                and rc.item_id =  ihook.getColumnValue(row_ori, 'REP_CLS_ITEM_ID') ;
            end if;
        row := t_row ();
        ihook.setColumnValue(row,'ITEM_ID',v_item_id );
        ihook.setColumnValue(row,'VER_NR',v_ver_nr );
        ihook.setColumnValue(row,'ITEM_NM',v_item_nm );
        ihook.setColumnValue(row,'ITEM_DESC', v_item_desc);
        rows.extend;
        rows(rows.last) := row;
        action := t_actionrowset(rows, 'Administered Item', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;

        end if;
             --  raise_application_error (-20000,     ' VD error ' || v_item_id ||','||v_item_nm );

-- if enumerated is switched to non-enumerated, remove permissible values
    if  (ihook.getColumnValue(row_ori, 'VAL_DOM_TYP_ID') <>  ihook.getColumnOldValue(row_ori, 'VAL_DOM_TYP_ID') and
    ihook.getColumnValue(row_ori, 'VAL_DOM_TYP_ID') = 18) then
        rows := t_rows();
        for cur in (select * from perm_val where val_dom_item_id = v_item_id and val_dom_Ver_nr = v_ver_nr) loop
            row := t_row();
            ihook.setColumnValue(row, 'VAL_ID', cur.val_id);
            rows.extend;
            rows(rows.last) := row;
        end loop;
        if (rows.count >0) then
            action := t_actionrowset(rows, 'Permissible Values (Edit AI)', 2,1,'delete');
            actions.extend;
            actions(actions.last) := action;
            action := t_actionrowset(rows, 'Permissible Values (Edit AI)', 2,2,'purge');
            actions.extend;
            actions(actions.last) := action;
        end if;
    end if;

   -- if caDSR data type changed, change standard data type
    if  (ihook.getColumnValue(row_ori, 'DTTYPE_ID') <>  ihook.getColumnOldValue(row_ori, 'DTTYPE_ID')) then
      row := row_ori;
      rows := t_rows();
    --  raise_application_error(-20000, nci_11179_2.getStdDataType(ihook.getColumnValue(row_ori, 'DTTYPE_ID')));
      ihook.setColumnValue(row, 'NCI_STD_DTTYPE_ID', nci_11179_2.getStdDataType(ihook.getColumnValue(row_ori, 'DTTYPE_ID')));
            rows.extend;
            rows(rows.last) := row;
      action := t_actionrowset(rows, 'Value Domain', 2,0,'update');
        actions.extend;
        actions(actions.last) := action;

    end if;

   -- if olf Val dom type is non-enumerated and status is released. and new value dom type is enumerated, then
     if  (ihook.getColumnValue(row_ori, 'VAL_DOM_TYP_ID') <>  ihook.getColumnOldValue(row_ori, 'VAL_DOM_TYP_ID') and
       ihook.getColumnValue(row_ori, 'VAL_DOM_TYP_ID') = 17) then
       -- check if value domain is released. If it is, then raise error
        for a in (select * from admin_item where item_id = v_item_id and ver_nr = v_ver_nr and ADMIN_STUS_ID = 75) loop
            raise_application_error(-20000, 'A Released VD cannot be enumerated if there are no permissible values.');
        end loop;
       end if;
   END IF;

    IF actions.COUNT > 0
    THEN
        hookoutput.actions := actions;
    END IF;
  -- hookoutput.message := 'Test';
    -- end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

 PROCEDURE spAISTIns
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
  v_temp int;
  v_dtype_id integer;
  v_item_id  number;
  v_ver_nr  number(4,2);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    rows := t_rows();

    row_ori := hookInput.originalRowset.rowset(1);
    v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
    v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');

    rows := t_rows();


 if (ihook.getColumnValue(row_ori, 'UNTL_DT') is not null and ihook.getColumnValue(row_ori, 'UNTL_DT') < nvl(ihook.getColumnValue(row_ori, 'EFF_DT'), sysdate) ) then
 raise_application_error(-20000, 'Expiration date has to be the same or greater than Effective date.');
    return;
end if;

   -- end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

END;
/
