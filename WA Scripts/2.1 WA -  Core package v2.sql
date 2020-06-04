create or replace PACKAGE template_11179 AS

procedure spChangeStatus (v_stus_typ_id number, v_to_stus_id number, v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spCreateVer (v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_params in varchar2);
procedure spShowValueMeaningDependency (v_data_in in clob, v_data_out out clob);
procedure spShowVMDependencyLimit (v_data_in in clob, v_data_out out clob, v_Mode in number);
procedure spPreHookCheckDE (a_table_name in varchar2, a_transaction_type in varchar2, a_data in raw, a_user in varchar2);
function getParsedAdminItemsData (originalRowset in t_actionRowset) return tab_admin_item_pk;
function getColumnCount(v_table_name in varchar2) return number;
function getSelectSql(v_table_name in varchar2) return varchar2;


END;
/
		

create or replace PACKAGE nci_11179 AS
function getWordCount(v_nm in varchar2) return integer;
function getWord(v_nm in varchar2, v_idx in integer, v_max in integer) return varchar2;
FUNCTION get_concepts(v_item_id in number, v_ver_nr in number) return varchar2;
 Function get_concept_order(v_item_id in number, v_ver_nr in number) return varchar2 ;
 function cmr_guid return varchar2;
procedure spAddToCart ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spRemoveFromCart (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure spAddConceptRel (v_data_in in clob, v_data_out out clob);
procedure spCreateVerNCI (v_data_in in clob, v_data_out out clob, v_user_id varchar2);
procedure getConcatNmDef(v_item_id in number, v_ver_nr in number, v_nm out varchar2, v_long_nm out varchar2,v_def out varchar2);
procedure spCopyModuleNCI (actions in out t_actions, v_from_module_id in number,v_from_module_ver in number,  v_from_form_id in number, v_from_form_ver number, v_to_form_id number, v_to_form_ver number);

function getItemId return integer;
procedure CncptCombExists (v_nm in varchar2, v_item_typ in integer, v_item_id out number, v_item_ver_nr out number, v_long_nm out varchar2, v_def out varchar2);

END;
/
create or replace PACKAGE BODY template_11179 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;

/***********************************************/

function getColumnCount(v_table_name in varchar2) return number
as

v_meta_col_cnt      number;

begin

 select count(*) into v_meta_col_cnt
 from cols
 where table_name=v_table_name;

 return v_meta_col_cnt;

end;

/***********************************************/

function getSelectSql(v_table_name in varchar2) return varchar2
as

v_sql        varchar2(4000);

begin

    v_sql := 'select ';

 for rec in (select column_name, data_type
             from cols
                where table_name=v_table_name) loop
        if rec.data_type != 'DATE' then
      v_sql := v_sql || rec.column_name || ', ';
  else
      v_sql := v_sql || 'to_char(' || rec.column_name || ', ''' || DEFAULT_TS_FORMAT || ''') '
       || rec.column_name || ', ';
  end if;
 end loop;

 v_sql := substr (v_sql, 1, length(v_sql) - 2) || ' from ' || v_table_name;

 return v_sql;

end;

/***********************************************/

function getParsedAdminItemsData (originalRowset in t_actionRowset) return tab_admin_item_pk
as

v_admin_item    obj_admin_item_pk;
v_tab_admin_item   tab_admin_item_pk;

row       t_row;

begin

 v_tab_admin_item := tab_admin_item_pk();
 v_tab_admin_item.extend(originalRowset.rowset.count);

 for i in 1..originalRowset.rowset.count loop
        row := originalRowset.rowset(i);
  v_admin_item := obj_admin_item_pk(ihook.getColumnValue(row, 'ITEM_ID'), ihook.getColumnValue(row, 'VER_NR'));
  v_tab_admin_item(i) := v_admin_item;
 end loop;

 return v_tab_admin_item;

end;

/***********************************************/

function isStatusCertified
(v_to_stus_id number, v_admin_item admin_item%rowtype) return boolean as

v_no_of_columns_to_check  number := 0;
v_not_null_check_query    varchar2(32767) := 'select sum(a) from (select 0 a from dual';

type cv_type     is ref cursor;
cv           cv_type;
v_temp       number;

v_temp_str      varchar2(4000);
v_certified       boolean := true;

v_err_hdr       varchar2(100) := 'Certification conditions failed:';

/*

performs sequence of checks

*/

begin

    -- check #1
 -- some required columns are not filled in
    for rec in (
 select entty_nm, col_nm from regist_rul_req_colmns
 where to_stus_id=v_to_stus_id and nvl(admin_item_typ_id, 0) in (0, v_admin_item.admin_item_typ_id)
 and nvl(fld_delete, 0)=0)
 loop

        v_no_of_columns_to_check := v_no_of_columns_to_check + 1;
  v_not_null_check_query := v_not_null_check_query
      || ' union all select 1 a from ' || rec.entty_nm
   || ' where item_id=' || v_admin_item.item_id || ' and ver_nr=' || v_admin_item.ver_nr
   || ' and ' || rec.col_nm || ' is not null';

 end loop;
 v_not_null_check_query := v_not_null_check_query || ')';

 open cv for v_not_null_check_query;
    fetch cv into v_temp;
    v_certified := v_temp = v_no_of_columns_to_check;
    close cv;

 if not v_certified then
     v_err_str := v_err_str || '<br>Required columns not filled in.';
 end if;

    -- check #2
 -- if type is DE and row exists in DE_DERV(PRMRY_DE_...) and DE.DERV_DE_IND is not 1
    for x in (select count(*) cnt from dual
        where exists (
      select null from de_derv a, de b
   where v_admin_item.admin_item_typ_id=4 /* DE */
   and a.prmry_de_item_id=v_admin_item.item_id and a.prmry_de_ver_nr=v_admin_item.ver_nr
   and nvl(a.fld_delete, 0)=0
   and b.item_id=v_admin_item.item_id and b.ver_nr=v_admin_item.ver_nr
   and nvl(b.derv_de_ind, 0) != 1
  ))
    loop
        if (x.cnt = 1) then
         v_err_str := v_err_str || '<br>Derived indicator not set.';
   v_certified := false;
     end if;
    end loop;

    -- check #3
 -- if type is DE and row do not exist in DE_DERV(PRMRY_DE_...) and DE.DERV_DE_IND is 1
 if v_admin_item.admin_item_typ_id=4 then
     select nvl(derv_de_ind,0) into v_temp
  from de b
  where b.item_id=v_admin_item.item_id and b.ver_nr=v_admin_item.ver_nr;
  if v_temp = 1 then
      select count(*) into v_temp from de_derv a
      where a.prmry_de_item_id=v_admin_item.item_id and a.prmry_de_ver_nr=v_admin_item.ver_nr
      and nvl(a.fld_delete, 0)=0;
   if v_temp = 0 then
       v_err_str := v_err_str || '<br>Derived components are not defined.';
   end if;
   end if;
    end if;

    -- check #4
 -- if type is VALUE_DOM and VAL_DOM_TYP_ID is enumerated (17) and row do not exist in PERM_VAL(VAL_DOM_...)
 if v_admin_item.admin_item_typ_id=3 /* VALUE_DOM */ then
     select b.val_dom_typ_id, trim(b.NON_ENUM_VAL_DOM_DESC) into v_temp, v_temp_str
  from value_dom b
  where b.item_id=v_admin_item.item_id and b.ver_nr=v_admin_item.ver_nr;
     if v_temp = 17 then
         select count(*) into v_temp
   from perm_val a
      where a.val_dom_item_id=v_admin_item.item_id and a.val_dom_ver_nr=v_admin_item.ver_nr
   and nvl(fld_delete,0) = 0;
      if v_temp < 2 then
             v_err_str := v_err_str || '<br>At least 2 permissible values need to be defined for enumerated value domain.';
       v_certified := false;
         end if;
        elsif v_temp = 18 then
         select count(*) into v_temp
   from perm_val a
      where a.val_dom_item_id=v_admin_item.item_id and a.val_dom_ver_nr=v_admin_item.ver_nr
   and nvl(fld_delete,0) = 0;
      if v_temp > 0 then
             v_err_str := v_err_str || '<br>No permissible values can be defined for non-enumerated value domain.';
       v_certified := false;
         end if;

   if v_temp_str is null then
      v_err_str := v_err_str || '<br>Non-enumerated description needs to be filled in for non-enumerated value domains.';
       v_certified := false;
         end if;
  end if;
    end if;

    -- check #5
 -- if type is CONC_DOM and CONC_DOM_TYP_ID is enumerated (17) and row do not exist in VAL_MEAN(CONC_DOM_...)
 if v_admin_item.admin_item_typ_id=1 /* CONC_DOM */ then
     select b.conc_dom_typ_id into v_temp
  from conc_dom b
  where b.item_id=v_admin_item.item_id and b.ver_nr=v_admin_item.ver_nr;
     if v_temp = 17 then
         select count(*) into v_temp
   from conc_dom_val_mean a
      where a.conc_dom_item_id=v_admin_item.item_id and a.conc_dom_ver_nr=v_admin_item.ver_nr
   and nvl(fld_delete,0) = 0;
      if v_temp = 0 then
             v_err_str := v_err_str || '<br>No value meaning defined for enumerated conceptual domain.';
       v_certified := false;
         end if;
        end if;
    end if;

    -- check #6
 -- make sure all the parents are STANDARDIZED before the child is STANDARDIZED
 if v_to_stus_id = 4 then

    /* Value Domain */
     if v_admin_item.admin_item_typ_id=3 then

     for v_rec in (select conc_dom_item_id item_id, conc_dom_ver_nr ver_nr
      from value_dom
      where item_id=v_admin_item.item_id
      and ver_nr=v_admin_item.ver_nr and
   conc_dom_item_id is not null)
   loop
             select regstr_stus_id into v_temp from admin_item
       where item_id = v_rec.item_id and
       ver_nr = v_rec.ver_nr;


          if v_temp != 4 then
             v_err_str := v_err_str || '<br>Conceptual Domain is not in STANDARDIZED status.';
             v_certified := false;
          end if;
   end loop;
        end if;

    /* Data Element */
     if v_admin_item.admin_item_typ_id=4 then

     for v_rec in (select val_dom_item_id item_id, val_dom_ver_nr ver_nr
      from de
      where item_id=v_admin_item.item_id
      and ver_nr=v_admin_item.ver_nr and
   val_dom_item_id is not null)
   loop
             select regstr_stus_id into v_temp from admin_item
       where item_id = v_rec.item_id and
       ver_nr = v_rec.ver_nr;

          if v_temp != 4 or v_temp is not null then
             v_err_str := v_err_str || '<br>Value Domain is not in STANDARDIZED status.';
             v_certified := false;
          end if;
   end loop;

     for v_rec in (select de_conc_item_id item_id, de_conc_ver_nr ver_nr
      from de
      where item_id=v_admin_item.item_id
      and ver_nr=v_admin_item.ver_nr and
   de_conc_item_id is not null)
   loop
             select regstr_stus_id into v_temp from admin_item
       where item_id = v_rec.item_id and
       ver_nr = v_rec.ver_nr;

          if v_temp != 4 or v_temp is not null then
             v_err_str := v_err_str || '<br>Data Element Concept is not in STANDARDIZED status.';
             v_certified := false;
          end if;
   end loop;
     end if;

    /* Data Element Concept */
     if v_admin_item.admin_item_typ_id=2 then
     for v_rec in (select obj_cls_item_id item_id, obj_cls_ver_nr ver_nr
      from de_conc
      where item_id=v_admin_item.item_id
      and ver_nr=v_admin_item.ver_nr and
   obj_cls_item_id is not null)
   loop
             select regstr_stus_id into v_temp from admin_item
       where item_id = v_rec.item_id and
       ver_nr = v_rec.ver_nr;

          if v_temp != 4  then
             v_err_str := v_err_str || '<br>Object Class is not in STANDARDIZED status.';
             v_certified := false;
          end if;
   end loop;

     for v_rec in (select prop_item_id item_id, prop_ver_nr ver_nr
      from de_conc
      where item_id=v_admin_item.item_id
      and ver_nr=v_admin_item.ver_nr and
   prop_item_id is not null)
   loop
        select regstr_stus_id into v_temp from admin_item
       where item_id = v_rec.item_id and
       ver_nr = v_rec.ver_nr;


          if v_temp != 4 then
             v_err_str := v_err_str || '<br>Property is not in STANDARDIZED status.';
             v_certified := false;
          end if;
   end loop;
     end if;

 end if;

 if not v_certified then
     v_err_str := v_err_hdr || v_err_str;
 end if;

 return v_certified;

end;

/***********************************************/

function isPartOfOrgList
(v_member org_cntct.org_id%type, v_collection t_orgs) return boolean as

begin

    if v_collection.count = 0 then
     return false;
    end if;

    for i in v_collection.first..v_collection.last loop
     if (v_collection(i) = v_member) then
         return true;
  end if;
 end loop;

    return false;

end;

/***********************************************/

procedure spChangeStatus (v_stus_typ_id number, v_to_stus_id number, v_data_in in clob, v_data_out out clob, v_user_id varchar2)
as

/*

1. obtain user's org IDs
2. read the current admin item row
3. determine what are the registration authority/steward/submitter group IDs
4. confirm (using rules table) that the user has rights to update status
5. confirm that required columns condition is met
6. update admin item status
7. if current data_id_str is null and status being changed is 11 (recorded)
   or 14 (standard), then data_id_str column needs to
   be populated with concatenation of regstr_auth.org_prt_id + item_id + ver_nr
   exception for FAA: data_id_str is a sequential number

testing:

begin
spchangestatus(1,222,'<ITEM_ID><![CDATA[1]]></ITEM_ID><VER_NR><![CDATA[1]]></VER_NR>', 'SUBMIT1');
end;

*/

hookInput         t_hookInput;
hookOutput         t_hookOutput := t_hookOutput();
actions         t_actions := t_actions();
action         t_actionRowset;
ai_action_rows       t_rows := t_rows();
ai_audit_action_rows   t_rows := t_rows();
row        t_row;

v_admin_item      admin_item%rowtype;
v_data_id_str      admin_item.data_id_str%type;

v_tab_admin_item    tab_admin_item_pk;

v_orgs          t_orgs;

v_usr_grp_id1      number := 0;
v_usr_grp_id2      number := 0;
v_usr_grp_id3      number := 0;

v_temp         number;
v_found        boolean;

v_apply_cert     number;
v_creat_irdi     number;
v_to_stus_nm     varchar(100);

cursor c1
(v_from_stus_id regist_rul.from_stus_id%type,
v_to_stus_id regist_rul.to_stus_id%type,
v_stus_typ_id regist_rul.stus_typ_id%type)
is select 1 from regist_rul
where nvl(from_stus_id, 0)=nvl(v_from_stus_id, 0) and to_stus_id=v_to_stus_id
and stus_typ_id=v_stus_typ_id
and usr_grp_id in (v_usr_grp_id1, v_usr_grp_id2, v_usr_grp_id3)
and nvl(fld_delete, 0)=0;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;

 v_tab_admin_item := getParsedAdminItemsData(hookInput.originalRowset);

    select b.org_id bulk collect into v_orgs
 from cntct a, org_cntct b
    where a.cntct_secu_id=v_user_id and a.cntct_id=b.cntct_id;

 for i in 1..v_tab_admin_item.count loop

     select * into v_admin_item from admin_item
     where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr
  for update nowait;

     if isPartOfOrgList(v_admin_item.regstr_auth_id, v_orgs) then
      v_usr_grp_id3 := 3;
  end if;

     if isPartOfOrgList(v_admin_item.stewrd_org_id, v_orgs) then
      v_usr_grp_id2 := 2;
  end if;

     if isPartOfOrgList(v_admin_item.submt_org_id, v_orgs) then
      v_usr_grp_id1 := 1;
  end if;

  if (v_stus_typ_id = 1) then  -- Change made for Administrative Status - Mar 3 2008
     open c1(v_admin_item.regstr_stus_id, v_to_stus_id, v_stus_typ_id);
        fetch c1 into v_temp;
        v_found := c1%FOUND;
        close c1;
  else
   open c1(v_admin_item.admin_stus_id, v_to_stus_id, v_stus_typ_id);
      fetch c1 into v_temp;
      v_found := c1%FOUND;
      close c1;
  end if;

     if not v_found then
            hookOutput.message := 'You are not authorized to change status or rule transition is not allowed.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
  end if;

  select to_number(substr(stus_msk,4,1)), to_number(substr(stus_msk,5,1)), stus_nm
        into v_apply_cert, v_creat_irdi, v_to_stus_nm
  from stus_mstr
  where stus_id = v_to_stus_id;

  if (v_stus_typ_id = 2) then -- Administrative status - no certification rules apply.. Change made Mar 3 2008.
   v_apply_cert := 0;
   v_creat_irdi := 0;
  end if;

        if v_apply_cert = 1
  and not isStatusCertified(v_to_stus_id, v_admin_item) then
            hookOutput.message := v_err_str;
   v_data_out := ihook.getHookOutput(hookOutput);
   return;
  end if;

     row := t_row();
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);

  if (v_stus_typ_id = 1) then -- Administrative status change - Change Mar 3, 2008
       ihook.setColumnValue(row, 'REGSTR_STUS_ID', v_to_stus_id);
  else
       ihook.setColumnValue(row, 'ADMIN_STUS_ID', v_to_stus_id);
  end if;

        ai_action_rows.extend; ai_action_rows(ai_action_rows.last) := row;

  if v_admin_item.data_id_str is null and v_creat_irdi = 1 and v_admin_item.regstr_auth_id is not null then
/*
            -- standrd logic of generation
      select org_prt_id || ' - ' || v_admin_item.item_id || ' - ' || v_admin_item.ver_nr
   into v_data_id_str
   from regstr_auth where regstr_auth_id=v_admin_item.regstr_auth_id;

      update admin_item
   set data_id_str=v_data_id_str
   where item_id=v_admin_item.item_id and ver_nr=v_admin_item.ver_nr;
      update p_admin_item
   set data_id_str=v_data_id_str
   where item_id=v_admin_item.item_id and ver_nr=v_admin_item.ver_nr;
*/

      -- custom logic for FAA
--            select max(to_number(nvl(data_id_str, 0))) + 1 into v_data_id_str
--   from admin_item;

            select od_seq_data_id_str.nextval into v_data_id_str from dual;

            ihook.setColumnValue(ai_action_rows(ai_action_rows.last), 'DATA_ID_STR', v_data_id_str);

  end if;

     row := t_row();
     ihook.setColumnValue(row, 'LOG_ID', -1); -- sequence column
     ihook.setColumnValue(row, 'ITEM_ID', v_admin_item.item_id);
     ihook.setColumnValue(row, 'VER_NR', v_admin_item.ver_nr);
     ihook.setColumnValue(row, 'CHNG_TYP_ID', case when v_stus_typ_id=1 then 46 when v_stus_typ_id=2 then 47 end);
     ihook.setColumnValue(row, 'CHNG_DESC', 'Status changed to ' || v_to_stus_nm || '.');
     ihook.setColumnValue(row, 'LST_UPD_USR_ID', v_user_id);
        ai_audit_action_rows.extend; ai_audit_action_rows(ai_audit_action_rows.last) := row;

 end loop;

    action := t_actionRowset(ai_action_rows, 'ADMIN_ITEM', 0, 'update');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(ai_audit_action_rows, 'ADMIN_ITEM_AUDIT', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 hookOutput.actions := actions;

    hookOutput.message := 'Status changed successfully.';

    v_data_out := ihook.getHookOutput(hookOutput);

end;

/***********************************************/

function spGetNextVer (v_current_ver admin_item.ver_nr%type, v_major_ver boolean) return admin_item.ver_nr%type as

begin
    if v_major_ver then
     return trunc (v_current_ver + 1);
 else
     return v_current_ver + 0.1;
 end if;
end;

/***********************************************/

procedure spCreateSubtypeVer (actions in out t_actions, v_admin_item admin_item%rowtype, v_major_ver boolean) as

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
    end if;

 v_meta_col_cnt := getColumnCount(v_table_name);

    v_sql := getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

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

    ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));

    action_rows.extend; action_rows(action_rows.last) := row;
    action := t_actionRowset(action_rows, v_table_name, 10, 'insert');
    actions.extend; actions(actions.last) := action;



 if v_admin_item.admin_item_typ_id = 3 then -- Add Perm Val

  action_rows := t_rows();

  v_table_name := 'PERM_VAL';
  v_meta_col_cnt := getColumnCount(v_table_name);

   for pv_cur in
  (select val_id from perm_val where 
  val_dom_item_id = v_admin_item.item_id and val_dom_ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where val_id = :val_id';

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
      ihook.setColumnValue(row, 'VAL_DOM_VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 11, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;

 
 
 if v_admin_item.admin_item_typ_id = 1 then -- Conceptual Domain then add CD-VM relationship

  action_rows := t_rows();

  v_table_name := 'CONC_DOM_VAL_MEAN';
  v_meta_col_cnt := getColumnCount(v_table_name);

   for cdvm_cur in
  (select CONC_DOM_VER_NR, CONC_DOM_ITEM_ID, NCI_VAL_MEAN_ITEM_ID, NCI_VAL_MEAN_VER_NR from conc_dom_val_mean where 
  conc_dom_item_id = v_admin_item.item_id and conc_dom_ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where CONC_DOM_VER_NR = :conc_dom_ver_nr and CONC_DOM_ITEM_ID = :conc_dom_item_id and NCI_VAL_MEAN_ITEM_ID = :nci_val_mean_item_id and NCI_VAL_MEAN_VER_NR = :nci_val_mean_ver_nr';

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

      ihook.setColumnValue(row, 'CONC_DOM_VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;
 

if v_admin_item.admin_item_typ_id = 4 then -- DE then add Derived DE components

  action_rows := t_rows();

  v_table_name := 'NCI_ADMIN_ITEM_REL';
  v_meta_col_cnt := getColumnCount(v_table_name);

   for de_cur in
  (select P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID from NCI_ADMIN_ITEM_REL where 
  P_item_id = v_admin_item.item_id and p_ITEM_ver_nr = v_admin_item.ver_nr and rel_typ_id = 65) loop

      v_sql := getSelectSql(v_table_name) || ' where P_ITEM_ID = :P_ITEM_ID and P_ITEM_VER_NR = :P_ITEM_VER_NR and C_ITEM_ID = :C_ITEM_ID and C_ITEM_VER_NR = :C_ITEM_VER_NR and REL_TYP_ID=65';

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

      ihook.setColumnValue(row, 'P_ITEM_VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 12, 'insert');
     actions.extend; actions(actions.last) := action;

 end if;
 
end;



procedure spCreateCommonChildren (actions in out t_actions, v_admin_item admin_item%rowtype, v_major_ver boolean) as


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
  v_meta_col_cnt := getColumnCount(v_table_name);

  for an_cur in
  (select nm_id from alt_nms where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where nm_id = :nm_id';

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
      ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
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
  v_meta_col_cnt := getColumnCount(v_table_name);

  for ad_cur in
  (select def_id from alt_def where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where def_id = :def_id';

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
      ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
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
  v_meta_col_cnt := getColumnCount(v_table_name);

  for ref_cur in
  (select ref_id from ref where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where ref_id = :ref_id';

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
      ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
     actions.extend; actions(actions.last) := action;


 action_rows := t_rows();

-- Concepts

  v_table_name := 'CNCPT_ADMIN_ITEM';
  v_meta_col_cnt := getColumnCount(v_table_name);

  for ref_cur in
  (select CNCPT_AI_ID from CNCPT_ADMIN_ITEM where 
  item_id = v_admin_item.item_id and ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where CNCPT_AI_ID = :CNCPT_AI_ID';

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
      ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, v_table_name, 14, 'insert');
     actions.extend; actions(actions.last) := action;



--- Classifications

 action_rows := t_rows();

  v_table_name := 'NCI_ALT_KEY_ADMIN_ITEM_REL';
  v_meta_col_cnt := getColumnCount(v_table_name);

  for ref_cur in
  (select NCI_PUB_ID,NCI_VER_NR, REL_TYP_ID from NCI_ALT_KEY_ADMIN_ITEM_REL where 
  c_item_id = v_admin_item.item_id and c_item_ver_nr = v_admin_item.ver_nr) loop

      v_sql := getSelectSql(v_table_name) || ' where NCI_PUB_ID = :NCI_PUB_ID and NCI_VER_NR = :NCI_VER_NR and c_item_id = :c_item_id and c_item_ver_nr = :c_item_ver_nr and rel_typ_id = :rel_typ_id';

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

       ihook.setColumnValue(row, 'c_item_VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, 'NCI_ALT_KEY_ADMIN_ITEM_REL (Hook)',2, 15, 'insert');
    actions.extend; actions(actions.last) := action;

end;
/***********************************************/



procedure spCreateVer (v_data_in in clob, v_data_out out clob, v_user_id varchar2, v_params in varchar2) as

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

v_major_ver     boolean := upper(v_params)=upper('version=major');

v_table_name      varchar2(30);
v_sql        varchar2(4000);

v_cur        number;
v_temp        number;

v_col_val       varchar2(4000);

v_meta_col_cnt      integer;
v_meta_desc_tab      dbms_sql.desc_tab;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;


 v_tab_admin_item := getParsedAdminItemsData(hookInput.originalRowset);

 for i in 1..v_tab_admin_item.count loop

        select * into v_admin_item from admin_item
        where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr
  for update nowait;

     if v_admin_item.currnt_ver_ind = 0 then
            hookOutput.message := 'Cannot create version if the Administered Item is not the latest version.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
     end if;

        if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
     end if;

  select to_number(substr(stus_msk,6,1)), stus_nm
  into v_creat_ver, v_stus_nm
  from stus_mstr
  where stus_id = v_admin_item.regstr_stus_id;

     if v_creat_ver = 0 then
      hookOutput.message := 'Cannot create version for registration status: ' || v_stus_nm;
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
     end if;

  v_table_name := 'ADMIN_ITEM';

  v_meta_col_cnt := getColumnCount(v_table_name);

     v_sql := getSelectSql(v_table_name) || ' where item_id=:item_id and ver_nr=:ver_nr';

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

     ihook.setColumnValue(row, 'VER_NR', spGetNextVer (v_admin_item.ver_nr, v_major_ver));
  ihook.setColumnValue(row, 'CREAT_USR_ID', hookInput.userId);
  ihook.setColumnValue(row, 'LST_UPD_USR_ID', hookInput.userId);

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
     ihook.setColumnValue(row, 'CHNG_DESC', 'Version ' || spGetNextVer (v_admin_item.ver_nr, v_major_ver)
      || ' created.');
     ihook.setColumnValue(row, 'LST_UPD_USR_ID', v_user_id);
        ai_audit_action_rows.extend; ai_audit_action_rows(ai_audit_action_rows.last) := row;

  spCreateSubtypeVer(actions, v_admin_item, v_major_ver);
  spCreateCommonChildren(actions, v_admin_item, v_major_ver);

 end loop;

 action := t_actionRowset(ai_insert_action_rows, 'ADMIN_ITEM', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 action := t_actionRowset(ai_update_action_rows, 'ADMIN_ITEM', 0, 'update');
    actions.extend; actions(actions.last) := action;

    action := t_actionRowset(ai_audit_action_rows, 'ADMIN_ITEM_AUDIT', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 hookOutput.actions := actions;

    hookOutput.message := 'Version created successfully.';

    v_data_out := ihook.getHookOutput(hookOutput);

end;

/***********************************************/

/***********************************************/

procedure spShowValueMeaningDependency (v_data_in in clob, v_data_out out clob)
as

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;

v_admin_item                admin_item%rowtype;
v_tab_admin_item            tab_admin_item_pk;

v_found      boolean;

type      t_tab_val_mean_id is table of perm_val.val_mean_id%type;
v_tab_val_mean_id   t_tab_val_mean_id := t_tab_val_mean_id();

v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

type      t_admin_item_nm is table of admin_item.item_nm%type;
v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

v_val_mean_desc    val_mean.val_mean_desc%type;
v_perm_val_nm    perm_val.perm_val_nm%type;

begin

    hookInput := ihook.getHookInput(v_data_in);

 hookOutput.invocationNumber := hookInput.invocationNumber;
 hookOutput.originalRowset := hookInput.originalRowset;

 v_tab_admin_item := getParsedAdminItemsData(hookInput.originalRowset);

    -- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
    for i in 1 .. v_tab_admin_item.count loop

        select * into v_admin_item from admin_item
        where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr
  for update nowait;

  for rec in (
  select val_mean_id from perm_val
        where val_dom_item_id=v_admin_item.item_id
  and val_dom_ver_nr=v_admin_item.ver_nr and fld_delete=0) loop

         v_found := false;
      for j in 1..v_tab_val_mean_id.count loop
       v_found := v_found or v_tab_val_mean_id(j)=rec.val_mean_id;
         end loop;

   if not v_found then
       v_tab_val_mean_id.extend();
    v_tab_val_mean_id(v_tab_val_mean_id.count) := rec.val_mean_id;
   end if;

  end loop;

 end loop;

 -- extracting all unique val domains and saving them in v_tab_val_dom
    for i in 1 .. v_tab_val_mean_id.count loop

        for rec in
  (select distinct item_id, ver_nr from value_dom
        where (item_id, ver_nr) in
            (select val_dom_item_id, val_dom_ver_nr from perm_val
            where val_mean_id=v_tab_val_mean_id(i))) loop

            v_found := false;
         for j in 1..v_tab_val_dom.count loop
          v_found := v_found or (v_tab_val_dom(j).item_id=rec.item_id and v_tab_val_dom(j).ver_nr=rec.ver_nr);
            end loop;

      if not v_found then
          v_tab_val_dom.extend();
       v_tab_val_dom(v_tab_val_dom.count) := obj_admin_item_pk(rec.item_id, rec.ver_nr);
      end if;

     end loop;

 end loop;

 -- extracting all unique val domains and saving them in v_tab_val_dom
    for i in 1 .. v_tab_val_mean_id.count loop

        for rec in
  (select distinct item_id, ver_nr from value_dom
        where (item_id, ver_nr) in
            (select val_dom_item_id, val_dom_ver_nr from perm_val
            where val_mean_id=v_tab_val_mean_id(i))) loop

            v_found := false;
         for j in 1..v_tab_val_dom.count loop
          v_found := v_found or (v_tab_val_dom(j).item_id=rec.item_id and v_tab_val_dom(j).ver_nr=rec.ver_nr);
            end loop;

      if not v_found then
          v_tab_val_dom.extend();
       v_tab_val_dom(v_tab_val_dom.count) := obj_admin_item_pk(rec.item_id, rec.ver_nr);
      end if;

     end loop;

 end loop;

 -- buidling column headers from val dom names
    for i in 1 .. v_tab_val_dom.count loop

     v_tab_admin_item_nm.extend();

     select item_nm || ' (' || v_tab_val_dom(i).ver_nr || ')' into v_tab_admin_item_nm(v_tab_admin_item_nm.count)
  from admin_item
     where item_id=v_tab_val_dom(i).item_id and ver_nr=v_tab_val_dom(i).ver_nr;

 end loop;

    -- expanding value meanings within value domains
    for i in 1 .. v_tab_val_dom.count loop

        for rec in (
     select val_mean_id from perm_val
        where val_dom_item_id=v_tab_val_dom(i).item_id and val_dom_ver_nr=v_tab_val_dom(i).ver_nr
  and fld_delete=0
        ) loop

         v_found := false;
      for j in 1..v_tab_val_mean_id.count loop
       v_found := v_found or v_tab_val_mean_id(j)=rec.val_mean_id;
         end loop;

   if not v_found then
       v_tab_val_mean_id.extend();
    v_tab_val_mean_id(v_tab_val_mean_id.count) := rec.val_mean_id;
   end if;

     end loop;

 end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_id.count loop

     select val_mean_desc into v_val_mean_desc
  from val_mean
  where val_mean_id=v_tab_val_mean_id(i);

        row := t_row();
        ihook.setColumnValue(row, 'Value Meaning', v_val_mean_desc);

        for j in 1 .. v_tab_val_dom.count loop

      v_perm_val_nm := '';
   for rec in
   (select perm_val_nm
   from perm_val a
         where val_mean_id=v_tab_val_mean_id(i)
   and val_dom_item_id=v_tab_val_dom(j).item_id and val_dom_ver_nr=v_tab_val_dom(j).ver_nr
      and fld_delete=0) loop

                v_perm_val_nm := rec.perm_val_nm;

            end loop;

       ihook.setColumnValue(row, v_tab_admin_item_nm(j), v_perm_val_nm);

        end loop;

        rows.extend; rows(rows.last) := row;

 end loop;

    showRowset := t_showableRowset(rows, 'Value Meaning Dependency',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'The following Value Meaning dependencies found:';

    v_data_out := ihook.getHookOutput(hookOutput);

end;


procedure spShowVMDependencyLimit (v_data_in in clob, v_data_out out clob, v_Mode in number)
as

hookInput           t_hookInput;
hookOutput           t_hookOutput := t_hookOutput();
showRowset     t_showableRowset;

rows      t_rows;
row          t_row;

v_admin_item                admin_item%rowtype;
v_tab_admin_item            tab_admin_item_pk;

v_found      boolean;

type      t_tab_val_mean_id is table of perm_val.val_mean_id%type;
v_tab_val_mean_id   t_tab_val_mean_id := t_tab_val_mean_id();

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

 v_tab_admin_item := getParsedAdminItemsData(hookInput.originalRowset);

    -- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
if v_Mode = 1 then 
    for i in 1 .. v_tab_admin_item.count loop

        select * into v_admin_item from admin_item
        where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr
  for update nowait;

  for rec in (
  select val_mean_id from perm_val
        where val_dom_item_id=v_admin_item.item_id
  and val_dom_ver_nr=v_admin_item.ver_nr and fld_delete=0) loop

         v_found := false;
      for j in 1..v_tab_val_mean_id.count loop
       v_found := v_found or v_tab_val_mean_id(j)=rec.val_mean_id;
         end loop;

   if not v_found then
       v_tab_val_mean_id.extend();
    v_tab_val_mean_id(v_tab_val_mean_id.count) := rec.val_mean_id;
   end if;

  end loop;

 end loop;
 elsif v_mode = 2 then
    for i in 1 .. v_tab_admin_item.count loop

        select val_dom_item_id, val_dom_ver_nr into v_item_id, v_ver_nr from de
        where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr
  for update nowait;

  for rec in (
  select val_mean_id from perm_val
        where val_dom_item_id=v_item_id
  and val_dom_ver_nr=v_ver_nr and fld_delete=0) loop

         v_found := false;
      for j in 1..v_tab_val_mean_id.count loop
       v_found := v_found or v_tab_val_mean_id(j)=rec.val_mean_id;
         end loop;

   if not v_found then
       v_tab_val_mean_id.extend();
    v_tab_val_mean_id(v_tab_val_mean_id.count) := rec.val_mean_id;
   end if;

  end loop;

 end loop;

 end if;

 -- buidling column headers from val dom names
    for i in 1 .. v_tab_admin_item.count loop

     v_tab_admin_item_nm.extend();

     select item_nm || ' (' || v_tab_admin_item(i).ver_nr || ')' into v_tab_admin_item_nm(v_tab_admin_item_nm.count)
  from admin_item
     where item_id=v_tab_admin_item(i).item_id and ver_nr=v_tab_admin_item(i).ver_nr;

 end loop;

/*    -- expanding value meanings within value domains
    for i in 1 .. v_tab_val_dom.count loop

        for rec in (
     select val_mean_id from perm_val
        where val_dom_item_id=v_tab_val_dom(i).item_id and val_dom_ver_nr=v_tab_val_dom(i).ver_nr
  and fld_delete=0
        ) loop

         v_found := false;
      for j in 1..v_tab_val_mean_id.count loop
       v_found := v_found or v_tab_val_mean_id(j)=rec.val_mean_id;
         end loop;

   if not v_found then
       v_tab_val_mean_id.extend();
    v_tab_val_mean_id(v_tab_val_mean_id.count) := rec.val_mean_id;
   end if;

     end loop;

 end loop;
*/
    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_id.count loop

     select val_mean_desc into v_val_mean_desc
  from val_mean
  where val_mean_id=v_tab_val_mean_id(i);

        row := t_row();
        ihook.setColumnValue(row, 'Value Meaning', v_val_mean_desc);

        for j in 1 .. v_tab_admin_item.count loop

      v_perm_val_nm := '';
 if (v_Mode = 1) then
   for rec in
   (select perm_val_nm
   from perm_val a
         where val_mean_id=v_tab_val_mean_id(i)
   and val_dom_item_id=v_tab_admin_item(j).item_id and val_dom_ver_nr=v_tab_admin_item(j).ver_nr
      and fld_delete=0) loop

                v_perm_val_nm := rec.perm_val_nm;

            end loop;
 elsif v_Mode= 2 then
   for rec in
   (select perm_val_nm
   from perm_val a, de b
         where val_mean_id=v_tab_val_mean_id(i)
   and a.val_dom_item_id=b.val_dom_item_id and a.val_dom_ver_nr = b.val_dom_ver_nr
   and b.item_id = v_tab_admin_item(j).item_id and b.ver_nr=v_tab_admin_item(j).ver_nr
      and a.fld_delete=0) loop

                v_perm_val_nm := rec.perm_val_nm;

            end loop;

 end if;
       ihook.setColumnValue(row, v_tab_admin_item_nm(j), v_perm_val_nm);

        end loop;

        rows.extend; rows(rows.last) := row;

 end loop;

    showRowset := t_showableRowset(rows, 'Value Meaning Dependency',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    hookOutput.message := 'The following Value Meaning dependencies found:';

    v_data_out := ihook.getHookOutput(hookOutput);

end;

/***********************************************/

-- This hook checks to make sure that the DEC and VD belonging to a DE are from the same CD.
PROCEDURE spPreHookCheckDE
(a_table_name in varchar2, a_transaction_type in varchar2, a_data in raw, a_user in varchar2)
as

v_src_item_id  number;
v_to_map_item_id    number;
v_src_prg_id  number;
v_temp     number;
v_date     date;
v_len     number;
v_row    hook.t_row;

BEGIN

 v_row := hook.getEventHookRow(a_data);

 /*  Decompose DEC and Value Domain */

 select count(distinct CONC_DOM_ITEM_ID || CONC_DOM_VER_NR) into v_temp from
 (select CONC_DOM_ITEM_ID, CONC_DOM_VER_NR from VALUE_DOM where ITEM_ID = v_row('VAL_DOM_ITEM_ID') and
 VER_NR = v_row('VAL_DOM_VER_NR')
 union
    select CONC_DOM_ITEM_ID, CONC_DOM_VER_NR from DE_CONC where ITEM_ID = v_row('DE_CONC_ITEM_ID') and
 VER_NR = v_row('DE_CONC_VER_NR'));

 if v_temp > 1 then
    raise_application_error(-20001,
       '<br><br><b>Conceptual Domain of the Data Element Concept does not match Conceptual Domain of Value Domain. Please check assignment.</b><br><br>');
 end if;

END;

/***********************************************/

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
  
  if (v_idx = 1) then
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
for cur in (select cncpt_concat , cncpt_concat_nm , cncpt_concat_def  from nci_admin_item_ext where item_id = v_item_id and ver_nr = v_ver_nr and fld_delete <> 0) loop
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
      action_rows.extend; action_rows(action_rows.last) := row;

  end loop;

  action := t_actionRowset(action_rows, 'NCI_ALT_KEY_ADMIN_ITEM_REL (Hook)',2, 15, 'insert');
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

        if (v_admin_item.regstr_stus_id is null) then
      hookOutput.message := 'Cannot create version for Administered Items with no Registration Status assigned.';
            v_data_out := ihook.getHookOutput(hookOutput);
   return;
   
     end if;
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

    action := t_actionRowset(ai_audit_action_rows, 'ADMIN_ITEM_AUDIT', 0, 'insert');
    actions.extend; actions(actions.last) := action;

 hookOutput.actions := actions;

    hookOutput.message := 'Version created successfully.';
    end if;
end if;

    v_data_out := ihook.getHookOutput(hookOutput);
end;


END;
/

