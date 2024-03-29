create or replace PACKAGE            nci_post_hook AS

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAISTUpd ( v_data_in in clob, v_data_out out clob, v_usr_id varchar2);
procedure spAISTIns ( v_data_in in clob, v_data_out out clob);
procedure spDervCompIns ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spModRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spQuestRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spQuestVVRestore ( v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_mode in varchar2);
procedure spAIIns ( v_data_in in clob, v_data_out out clob);
procedure spPVUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spCSIUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure            sp_postprocess ( v_data_in in clob, v_data_out out clob);

END;
/
create or replace PACKAGE BODY            NCI_POST_HOOK AS


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

delete from NCI_ADMIN_ITEM_EXT;
commit;

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


update nci_admin_item_ext e set (cncpt_concat, cncpt_concat_nm) = (select item_nm, item_nm from admin_item ai where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and ai.admin_item_typ_id = 53)
where e.cncpt_concat is null and
(e.item_id, e.ver_nr) in (select item_id, ver_nr from admin_item where admin_item_typ_id= 53);

commit;

insert into onedata_ra.NCI_ADMIN_ITEM_EXT select * from NCI_ADMIN_ITEM_EXT;
commit;

delete from nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;

delete from onedata_ra.nci_usr_cart where CNTCT_SECU_ID = 'GUEST';
commit;
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

  BEGIN
    hookinput := Ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber := hookinput.invocationnumber;
    hookoutput.originalrowset := hookinput.originalrowset;

    row_ori := hookInput.originalRowset.rowset (1);
   -- raise_application_error(-20000, ihook.getColumnValue(row_ori,'REF_TYP_ID'));
  if (ihook.getColumnValue(row_ori,'REF_TYP_ID') = 80 or ihook.getColumnOldValue(row_ori,'REF_TYP_ID') = 80) then
    raise_application_error(-20000,'You cannot insert or update Preferred Question Text from Reference Documents. Please use Section 4 - Relational/Representation Attributes.');
 end if;

 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


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



procedure spCSIUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2)
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
  if (nci_11179_2.isCSParentCSIValid(row_ori) = false) then
      raise_application_error(-20000, 'Parent CSI should belong to the same Classification Scheme as specified.');
  end if;

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
  --  raise_application_error(-20000, hookinput.originalRowset.tablename);

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


    if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') = 4) then -- Data Element
   -- raise_application_error (-20000, 'here');
           for cur     IN (SELECT ai.item_id
                  FROM admin_item ai, de de
                 WHERE     ai.item_id = de.item_id
                       AND ai.ver_nr = de.ver_nr
                       AND (de.de_conc_item_id ,de.de_conc_ver_nr ,de.val_dom_item_id ,de.val_dom_ver_nr ) in
                       (select de_conc_item_id ,de_conc_ver_nr ,val_dom_item_id ,val_dom_ver_nr from de where item_id = v_item_id and ver_nr = v_ver_nr)
                       AND ai.item_id <> v_item_id
                       AND ai.cntxt_item_id =   ihook.getColumnValue (row_ori, 'CNTXT_ITEM_ID')
                       and ai.cntxt_ver_nr =   ihook.getColumnValue (row_ori, 'CNTXT_VER_NR')) 
                    --    and     ai.item_id = v_item_id
                     --                  AND ai.ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id);
            RETURN;
        END LOOP;

    end if; 
    
 if (ihook.getColumnValue(row_ori, 'UNTL_DT') is not null and ihook.getColumnValue(row_ori, 'UNTL_DT') < nvl(ihook.getColumnValue(row_ori, 'EFF_DT'), sysdate) ) then
 raise_application_error(-20000, 'Expiration date has to be the same or greater than Effective date.');

    return;
end if;

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


end if;

 if (hookinput.originalRowset.tablename = 'ADMIN_ITEM') then  -- Value domain/released without PV
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
    IF (hookinput.originalRowset.tablename = 'DE')
    THEN
        FOR cur
            IN (SELECT ai.item_id
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
                       AND de.item_id <> v_item_id
                       AND (ai.cntxt_item_id, ai.cntxt_ver_nr) IN
                               (SELECT ai1.cntxt_item_id, ai1.cntxt_ver_nr
                                  FROM admin_item ai1
                                 WHERE     item_id = v_item_id
                                       AND ver_nr = v_ver_nr))
        LOOP
            raise_application_error (-20000,
                                     'Duplicate DE found. ' || cur.item_id);
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

-- Released DE cannot have a retired DEC and VD

    for cur in (select ai.* from admin_item ai, admin_item dec, admin_item vd where ai.item_id = ihook.getColumnValue (row_ori, 'ITEM_ID') and
    ai.ver_nr = ihook.getColumnValue (row_ori, 'VER_NR') and dec.item_id = ihook.getColumnValue (row_ori, 'DE_CONC_ITEM_ID')
    and dec.ver_nr = ihook.getColumnValue (row_ori, 'DE_CONC_VER_NR') and vd.item_id =ihook.getColumnValue (row_ori, 'VAL_DOM_ITEM_ID')
    and vd.ver_nr = ihook.getColumnValue (row_ori, 'VAL_DOM_VER_NR') and ai.admin_stus_id = 75 and
    (upper(dec.admin_stus_nm_dn) like '%RETIRED%' or upper(vd.admin_stus_nm_dn) like '%RETIRED%')) loop
            raise_application_error (-20000,
                                     'Cannot associated Retired DEC or VD with a Released CDE. ' );
            RETURN;
        END LOOP;


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

        spDEPrefQuestPost2 (row_ori, actions);

        -- Tracker 818 - if Derivation Rule is set, then

        if ((ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is not null and ihook.getColumnValue (row_ori, 'DERV_RUL') is null) or
        (ihook.getColumnValue (row_ori, 'DERV_TYP_ID') is null and ihook.getColumnValue (row_ori, 'DERV_RUL') is not null)) then
            raise_application_error(-20000, 'DDE requires Derivation Type and Derivation Rule.');
            return;
        end if;
    END IF;

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
