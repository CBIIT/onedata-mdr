CREATE OR REPLACE PACKAGE ONEDATA_WA.nci_11179_2 AS
procedure spNCICompareDE (v_data_in in clob, v_data_out out clob);
procedure spNCIShowVMDependency (v_data_in in clob, v_data_out out clob);
procedure spNCIShowVMDependencyDE (v_data_in in clob, v_data_out out clob);
function isUserAuth(v_item_id in number, v_ver_nr in number,v_user_id in varchar2) return boolean;
procedure spCheckUserAuth (v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

END;
/

CREATE OR REPLACE PACKAGE BODY ONEDATA_WA.nci_11179_2 AS

v_err_str      varchar2(1000) := '';
DEFAULT_TS_FORMAT    varchar2(50) := 'YYYY-MM-DD HH24:MI:SS';
type       t_orgs is table of org_cntct.org_id%type;



function isUserAuth(v_item_id in number, v_ver_nr in number,v_user_id in varchar2) return boolean  iS
v_auth boolean := false;
v_temp integer;
v_temp1 integer;
begin
select count(*) into v_temp from  onedata_md.vw_usr_row_filter  v, admin_item ai 
        where ( ( v.CNTXT_ITEM_ID = ai.CNTXT_ITEM_ID and v.cntxt_VER_NR  = ai.CNTXT_VER_NR) or v.CNTXT_ITEM_ID = 100) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I'
        and ai.item_id =v_item_id and ai.ver_nr = v_ver_nr;

-- If the item id sent are context item id and version number
select count(*) into v_temp1 from  onedata_md.vw_usr_row_filter  v 
        where  ( v.CNTXT_ITEM_ID = v_item_id and v.cntxt_VER_NR  = v_ver_nr) and upper(v.USR_ID) = upper(v_user_id) and v.ACTION_TYP = 'I';
        
if (v_temp = 0 and v_temp1 = 0) then return false; else return true; end if;
end;


procedure spCheckUserAuth (v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    
    if (hookinput.originalRowset.tablename = 'ALT_DEF') then 
        v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
    elsif (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 60) then   ---  protocol
        v_item_id := ihook.getColumnValue(row_ori, 'C_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'C_ITEM_VER_NR');
    elsif hookinput.originalRowset.tablename = 'PERM_VAL' then
        v_item_id := ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
    elsif hookinput.originalRowset.tablename = 'REF_DOC' then
        select nci_cntxt_item_id, nci_cntxt_ver_nr into v_item_id, v_ver_nr from ref where  
        ref_id = ihook.getColumnValue(row_ori, 'NCI_REF_ID');
    elsif   (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 61 ) then   --- Module
        v_item_id := ihook.getColumnValue(row_ori,'P_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'P_ITEM_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL_ALT_KEY') then -- Question
        select p_item_id, p_item_ver_nr into v_item_id, v_ver_nr from nci_admin_item_rel where rel_typ_id = 61 and 
        c_item_id = ihook.getColumnValue(row_ori, 'P_ITEM_ID') and c_item_ver_nr = ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_QUEST_VV_REP') then -- Question Repetision
        select frm_item_id, frm_ver_nr into v_item_id, v_ver_nr from vw_nci_module_de where 
        nci_pub_id = ihook.getColumnValue(row_ori, 'QUEST_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'QUEST_VER_NR');
    elsif   (hookinput.originalRowset.tablename = 'NCI_QUEST_VALID_VALUE') then -- Question Repetision
        select frm_item_id, frm_ver_nr into v_item_id, v_ver_nr from vw_nci_module_de where 
        nci_pub_id = ihook.getColumnValue(row_ori, 'Q_PUB_ID') and nci_ver_nr = ihook.getColumnValue(row_ori, 'Q_VER_NR');
 
 end if;
  
     if (isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
     raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
        return;
    end if;
    
    if (hookinput.originalRowset.tablename = 'NCI_ADMIN_ITEM_REL' and ihook.getColumnValue(row_ori,'REL_TYP_ID') = 60) then   ---  checked form before. Now check Protocol
        v_item_id := ihook.getColumnValue(row_ori, 'P_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'P_ITEM_VER_NR');
    
        if (isUserAuth(v_item_id, v_ver_nr, v_user_id) = false) then
            raise_application_error(-20000, 'You are not authorized to insert/update or delete in this context. ');
            return;
        end if;
    end if;
    
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   
end;

/*  Pop-up compare DE for selected rows */
procedure spNCICompareDE (v_data_in in clob, v_data_out out clob)
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

    /* Iterate through all the selected Data Elements */
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

/* PV Dependency called from NCI Data Elements */
procedure spNCIShowVMDependency (v_data_in in clob, v_data_out out clob)
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

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
    vd_id_nm     varchar2(300);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext
        where val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
        and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and pv.fld_delete=0 and 
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop
            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;

            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
            end if;
    end loop;
  
     v_tab_admin_item_nm.extend();
     select ai.item_id || '-' || ai.item_nm into  vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
      and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');
  
      v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'ITEM_NM') || chr(13) || 'VD:' ||  vd_id_nm ;
    end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop
        row := t_row();
        ihook.setColumnValue(row, 'Concept Code', v_tab_val_mean_cd(i));
        ihook.setColumnValue(row, 'Concept Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));

        for j in 1 .. hookInput.originalRowset.Rowset.count loop
            row_cur := hookInput.originalRowset.Rowset(j);
            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and val_dom_item_id=ihook.getColumnValue(row_cur,'VAL_DOM_ITEM_ID')
            and val_dom_ver_nr=ihook.getColumnValue(row_cur,'VAL_DOM_VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm := rec.perm_val_nm;
            end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(j), nci_11179.replaceChar(v_perm_val_nm));
        end loop;
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    v_data_out := ihook.getHookOutput(hookOutput);

end;

/*  Show PV comparison from ADministereds Item */

procedure spNCIShowVMDependencyDE (v_data_in in clob, v_data_out out clob)
as

    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_cur t_row;
    row_ori  t_row;
    
    v_admin_item                admin_item%rowtype;
    v_tab_admin_item            tab_admin_item_pk;

    v_found      boolean;

    type t_val_mean_cd is table of nci_admin_item_ext.cncpt_concat%type;
    type t_val_mean_nm is table of nci_admin_item_ext.cncpt_concat_nm%type;

    v_tab_val_mean_cd  t_val_mean_cd := t_val_mean_cd();
    v_tab_val_mean_nm  t_val_mean_nm := t_val_mean_nm();

    v_tab_val_dom    tab_admin_item_pk := tab_admin_item_pk();

    type      t_admin_item_nm is table of admin_item.item_nm%type;
    v_tab_admin_item_nm   t_admin_item_nm := t_admin_item_nm();

    v_val_mean_desc    val_mean.val_mean_desc%type;
    v_perm_val_nm    perm_val.perm_val_nm%type;
    v_item_id		 number;
    v_ver_nr		 number;
    vd_id_nm    varchar2(300);
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

 row_ori := hookInput.originalRowset.rowset (1);
-- saving all unique val_mean_ids from submitted admin items into v_tab_val_mean_id
  
    if (ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID') <> 4) then
        raise_application_error(-20000,'!!!! This functionality is only applicable for CDE !!!!');
    return;
    end if;
    for i in 1 .. hookInput.originalRowset.Rowset.count loop
        row_cur := hookInput.originalRowset.Rowset(i);

        for rec in (  select nci_val_mean_item_id, nci_val_mean_ver_nr, cncpt_concat, cncpt_concat_nm from perm_val pv, nci_admin_item_ext ext, de
        where pv.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
        and pv.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and pv.fld_delete=0 and 
        pv.nci_val_mean_item_id = ext.item_id and pv.nci_val_mean_ver_nr = ext.ver_nr) loop
    
            v_found := false;
            for j in 1..v_tab_val_mean_cd.count loop
                    v_found := v_found or v_tab_val_mean_cd(j)=rec.cncpt_concat;
            end loop;
            if not v_found then
                v_tab_val_mean_cd.extend();
                v_tab_val_mean_nm.extend();
                v_tab_val_mean_cd(v_tab_val_mean_cd.count) := rec.cncpt_concat;
                v_tab_val_mean_nm(v_tab_val_mean_nm.count) := rec.cncpt_concat_nm;
            end if;
        end loop;
    
        v_tab_admin_item_nm.extend();
        select ai.item_id || '-' || ai.item_nm into  vd_id_nm from admin_item ai, de where ai.item_id = de.val_dom_item_id and ai.ver_nr = de.val_dom_ver_nr and de.item_id =ihook.getColumnValue(row_cur,'ITEM_ID')
        and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR');
  
        v_tab_admin_item_nm(v_tab_admin_item_nm.count) := 'CDE:' || ihook.getColumnValue(row_cur,'ITEM_ID') || '-' || ihook.getColumnValue(row_cur,'ITEM_NM') || chr(13) || 'VD:' ||  vd_id_nm ;
    end loop;

    -- populating val means/perm vals
    rows := t_rows();
    for i in 1 .. v_tab_val_mean_cd.count loop

        row := t_row();
        ihook.setColumnValue(row, 'Concept Code', v_tab_val_mean_cd(i));
        ihook.setColumnValue(row, 'Concept Name', nci_11179.replaceChar(v_tab_val_mean_nm(i)));

        for j in 1 .. hookInput.originalRowset.Rowset.count loop
           row_cur := hookInput.originalRowset.Rowset(j);

            v_perm_val_nm := '';
            for rec in   (select perm_val_nm   from perm_val a, nci_admin_item_Ext ext, de
            where nci_val_mean_item_id=ext.item_id  and nci_val_mean_ver_nr = ext.ver_nr and ext.cncpt_concat = v_tab_val_mean_cd(i)
            and a.val_dom_item_id=de.val_dom_item_id and de.item_id = ihook.getColumnValue(row_cur,'ITEM_ID')
            and a.val_dom_ver_nr=de.val_dom_ver_nr and de.ver_nr = ihook.getColumnValue(row_cur,'VER_NR') and a.fld_delete=0) loop
                v_perm_val_nm := rec.perm_val_nm;
            end loop;
            ihook.setColumnValue(row, v_tab_admin_item_nm(j), nci_11179.replaceChar(v_perm_val_nm));
        end loop;
        rows.extend; rows(rows.last) := row;
    end loop;

    showRowset := t_showableRowset(rows, 'Permissible Value Comparison',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    v_data_out := ihook.getHookOutput(hookOutput);
end;
end;
/
