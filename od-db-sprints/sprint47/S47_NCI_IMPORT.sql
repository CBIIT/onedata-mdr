create or replace PACKAGE            nci_import AS
procedure spCreateValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_op in varchar2);
procedure spValCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
--procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostPVVMImportEdit (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPVVMValidate (row_ori in out t_row);
procedure spCreateValDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValDesigImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateValRefDocImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure ConceptParse(v_str in varchar2, idx in integer, row_ori in out t_row);
procedure ConceptParseDEC(v_str in varchar2, idx in integer, row_ori in out t_row);
procedure selectFoundID(v_data_in in clob, v_data_out out clob, v_usr_id in varchar2,v_item_typ in integer);
function ParseGaps (row_ori in t_row, idx in number) return integer;
procedure spLoadConceptRel;
procedure spDeleteProcImports;
END;
/
create or replace PACKAGE BODY            nci_import AS

procedure spDeleteProcImports
as
 v_days integer;
begin
v_days := 1;
delete from NCI_STG_ALT_NMS where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days );
commit;
delete from onedata_ra.nci_stg_alt_nms where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days );
commit;
delete from NCI_STG_CDE_CREAT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
delete from onedata_ra.NCI_STG_CDE_CREAT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
delete from NCI_STG_PV_VM_IMPORT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
delete from onedata_ra.NCI_STG_PV_VM_IMPORT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
delete from NCI_STG_FORM_IMPORT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
delete from onedata_ra.NCI_STG_FORM_IMPORT where CTL_VAL_STUS = 'PROCESSED' and LST_UPD_DT < TRUNC ( SYSDATE - v_days);
commit;
end;

procedure spLoadConceptRel 
as
v_parents varchar2(4000);
i integer;
cnt integer;
v_code varchar2(100);
v_c_item_id number;
v_c_ver_nr number(4,2);
begin

delete from NCI_CNCPT_REL where rel_typ_id = 68;
commit;
delete from onedata_ra.NCI_CNCPT_REL where rel_typ_id = 68;
commit;

insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID)
select p.item_id, p.ver_nr, c.item_id, c.ver_nr, 68
from vw_cncpt p, vw_cncpt c, SAG_LOAD_CONCEPTS_EVS s
where s.parents is not null and s.parents not like '%|%' 
and s.parents = p.item_long_nm and s.code = c.item_long_nm;
commit;

for cur in (select code, parents from SAG_LOAD_CONCEPTS_EVS  where parents like '%|%' ) loop
v_parents := replace(cur.parents,'|',' ');
cnt := nci_11179.getwordcount(v_parents);
for cur1 in (select item_id, ver_nr  from admin_item where admin_item_typ_id = 49 and item_long_nm = cur.code) loop
 v_c_item_id := cur1.item_id;
 v_c_ver_nr := cur1.ver_nr;
for i in 1..cnt loop
v_code := nci_11179.getWord(v_parents, i,cnt);
insert into NCI_CNCPT_REL (P_ITEM_ID, P_ITEM_VER_NR, C_ITEM_ID, C_ITEM_VER_NR, REL_TYP_ID, REL_CATGRY_NM)
select p.item_id, p.ver_nr, v_c_item_id, v_c_ver_nr, 68, 'Default'
from admin_item p
where p.item_long_nm= v_code and p.admin_item_typ_id = 49;
commit;
end loop;
end loop;
end loop;

end;



procedure spCreateValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_op in varchar2)
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
 action t_actionRowset;
 row_to_comp  t_row;
 v_val_ind  boolean;
 v_batch_nbr integer;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
for i in 1..hookinput.originalRowset.rowset.count loop
   v_val_ind := true;
    row_ori := hookInput.originalRowset.rowset(i);
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
   --    raise_application_error(-20000,i);
        for k in i+1..hookinput.originalrowset.rowset.count loop
             row_to_comp := hookinput.originalrowset.rowset(k);
    
      --     raise_application_error(-20000,k);
    if ((nvl(ihook.getColumnValue(row_to_comp, 'DE_CONC_ITEM_ID'),ihook.getColumnValue(row_to_comp,'ITEM_1_ID')) = nvl(ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID'), ihook.getColumnValue(row_ori, 'ITEM_1_ID'))
    and nvl(ihook.getColumnValue(row_to_comp, 'DE_CONC_VER_NR'),ihook.getColumnValue(row_to_comp,'ITEM_1_VER_NR')) = nvl(ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'),ihook.getColumnValue(row_ori,'ITEM_1_VER_NR'))
    and nvl(ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID'),ihook.getColumnValue(row_to_comp,'ITEM_2_ID')) = nvl(ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') ,ihook.getColumnValue(row_ori,'ITEM_2_ID'))
    and nvl(ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR'),ihook.getColumnValue(row_to_comp,'ITEM_2_VER_NR')) = nvl(ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'),ihook.getColumnValue(row_ori,'ITEM_2_VER_NR'))
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') ) or
    (ihook.getColumnValue(row_to_comp, 'CDE_ITEM_LONG_NM') = ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')) ) 
     then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );  
    end if;
  end loop;
 
       if (v_val_ind = true) then 

              nci_chng_mgmt.spDEValCreateImport(row_ori, v_op, actions, v_val_ind);
        end if;
   --   raise_application_error(-20000, 'Import');
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
        if v_op = 'V' then 
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
        elsif v_op = 'C' then 
                     ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
   
        end if;
    end if; 
    rows.extend; rows(rows.last) := row_ori;
   end if; -- only if not processed     
end loop;
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;


procedure spCreateValRefDocImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    rowins  t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
 v_temp integer;
 v_val_ind  boolean;
   actions t_actions := t_actions();
   row_to_comp t_row;
   v_batch_nbr number;
    nw_cntxt varchar2(64);
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  rowins := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','' );                      
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then

-- Copy source attributes to validated attributes
        if (ihook.getColumnValue(row_ori, 'SRC_ITEM_ID')  is null or ihook.getColumnValue(row_ori, 'SRC_VER_NR')  is null) then
                v_val_ind := false;   
                    if (ihook.getColumnValue(row_ori, 'SRC_ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID is missing.' || chr(13) );           
                end if;
                       if (ihook.getColumnValue(row_ori, 'SRC_VER_NR')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Version is missing.' || chr(13) );           
                end if;
        else
        for curx in (select * from admin_item where ITEM_ID = ihook.getColumnValue(row_ori, 'SRC_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'SRC_VER_NR'))  loop
        ihook.setColumnValue(row_ori,'ITEM_ID', ihook.getColumnValue(row_ori, 'SRC_ITEM_ID'));
        ihook.setColumnValue(row_ori,'VER_NR', ihook.getColumnValue(row_ori, 'SRC_VER_NR'));
        
        end loop;
        if ( ihook.getColumnValue(row_ori,'ITEM_ID') is null) then -- invalid ID
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR:' || ' No Administered Item found with the Item_id/Ver_nr.'|| chr(13) );                      
                  v_val_ind := false;   
        end if;
       
        end if;
        
        -- Copy Admin Item Type
            if (ihook.getColumnValue(row_ori, 'SRC_AI_TYP')  is null ) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Type is not provided.' || chr(13) );                      
                v_val_ind := false;   
        else
        for curx in (select * from vw_obj_key_4 where upper(obj_key_desc) = upper(ihook.getColumnValue(row_ori, 'SRC_AI_TYP')))  loop
        ihook.setColumnValue(row_ori,'ADMIN_ITEM_TYP_ID',curx.obj_key_id);
        
        end loop;
        if ( ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID') is null) then -- invalid ID
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Type is not a valid type in LOV.'|| chr(13) );                      
                  v_val_ind := false;   
        end if;
       
        end if;
    
        if (ihook.getColumnValue(row_ori, 'NM_DESC')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: No Doc Name provided.' || chr(13) );                      
                v_val_ind := false;   
        end if;
        
        if (ihook.getColumnValue(row_ori, 'NM_TYP_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Doc Type is missing or invalid.' || chr(13) );                      
                v_val_ind := false;   
        end if;

   if (ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Long Name is missing.' || chr(13) );                      
                v_val_ind := false;   
        end if;

        for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
        and Item_nm <> ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')) loop
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Public ID Does not match Imported Name: ' || ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') || chr(13) );                      
                v_val_ind := false;   
        end loop;
              if (ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Context is missing or invalid.' || chr(13) );                      
                v_val_ind := false;   
        end if;
         -- raise_application_error(-20000,ihook.getColumnValue(row_ori, 'LANG_ID') );
             if (ihook.getColumnValue(row_ori, 'LANG_ID') is null OR (ihook.getColumnValue(row_ori, 'LANG_ID') != 1007 AND ihook.getColumnValue(row_ori, 'LANG_ID') != 1004 AND ihook.getColumnValue(row_ori, 'LANG_ID') != 1000)) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'WARNING: Doc Lang missing or invalid. ENGLISH will be used.' || chr(13) );                      
                ihook.setColumnValue(row_ori, 'LANG_ID',1000);
          --      v_val_ind := false;   
        end if;
                -- Jira 1924
--        if (ihook.getColumnValue(row_ori, 'NM_TYP_ID')= 1038) then --1038 is internal id for USED_BY
--            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') || 'WARNING: Alternate Name will be set to Context Name for Used By.' || chr(13) );
--            select item_nm into nw_cntxt from vw_cntxt where item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID');
--            ihook.setColumnValue(row_ori, 'NM_DESC', nw_cntxt);
--        end if;
        -- end Jira 1924

if (v_val_ind = true) then
      select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
      and admin_item_typ_id = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') ;
      if (v_temp = 0) then
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID/Type do not match.' || chr(13) );                      
                v_val_ind := false;   
        end if;
end if;
	

/*
      select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
      and item_nm = ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') ;
      if (v_temp = 0) then
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID/Name do not match.' || chr(13) );                      
                v_val_ind := false;   
        end if;*/
-- duplicate in the database     
  if (v_val_ind = true) then
          select count(*) into v_temp from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr =      ihook.getColumnValue(row_ori, 'VER_NR')  
         and nm_desc = ihook.getColumnValue(row_ori, 'NM_DESC') and nm_typ_id = ihook.getColumnValue(row_ori, 'NM_TYP_ID') and cntxt_item_id  = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
         and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')  ;
         if (v_temp > 0) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'DUPLICATE');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Reference doc already exists.');                      
              v_val_ind := false;
        end if;
 end if;
 if (v_val_ind = true) then
      for k in i+1..hookinput.originalrowset.rowset.count loop
             row_to_comp := hookinput.originalrowset.rowset(k);
      if (ihook.getColumnValue(row_to_comp, 'ITEM_ID') = ihook.getColumnValue(row_ori, 'ITEM_ID')
      and ihook.getColumnValue(row_to_comp, 'VER_NR') = ihook.getColumnValue(row_ori, 'VER_NR') 
      and ihook.getColumnValue(row_to_comp, 'NM_TYP_ID') = ihook.getColumnValue(row_ori, 'NM_TYP_ID') 
      and ihook.getColumnValue(row_to_comp, 'NM_DESC') = ihook.getColumnValue(row_ori, 'NM_DESC') 
      and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
      and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') 
     -- and ihook.getColumnValue(row_to_comp, 'ADMIN_ITEM_TYP_ID') = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') 
      and ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') != ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR')) then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
   ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );                
   end if;
   end loop;
    ihook.setColumnValue(row_ori,'REF_TYP_ID', ihook.getColumnValue(row_ori,'NM_TYP_ID'));
    ihook.setColumnValue(row_ori,'NCI_CNTXT_ITEM_ID', ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
    ihook.setColumnValue(row_ori,'NCI_CNTXT_VER_NR', ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
    ihook.setColumnValue(row_ori,'REF_NM', ihook.getColumnValue(row_ori,'NM_DESC'));
    ihook.setColumnValue(row_ori,'REF_DESC', ihook.getColumnValue(row_ori,'DOC_TXT'));
    ihook.setColumnValue(row_ori,'DISP_ORD', ihook.getColumnValue(row_ori,'RD_DO'));
    ihook.setColumnValue(row_ori,'URL', ihook.getColumnValue(row_ori,'RD_URL'));

 end if;
 
   --   raise_application_error(-20000, 'Import');
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
             ihook.setColumnValue(row_ori, 'NM_ID', -1);
              ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
               rowins.extend; rowins(rowins.last) := row_ori;
        end if;
    rows.extend; rows(rows.last) := row_ori;
  end if; 

end loop;
    action := t_actionrowset(rows, 'Reference Document Import', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
        action := t_actionrowset(rowins, 'References (for hook insert)', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure selectFoundID(v_data_in in clob, v_data_out out clob, v_usr_id in varchar2,v_item_typ in integer)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
 question    t_question;
answer     t_answer;
answers     t_answers;
    rows      t_rows;
   row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_id number;
    v_ver number(4,2);
 action t_actionRowset;
 v_temp integer;
 v_val_ind  boolean;
   actions t_actions := t_actions();
   row_to_comp t_row;
 v_found boolean;
 v_str varchar2(4000);
 v_item_typ_id integer;
 v_obj_nm varchar2(100);
 idx integer;
 row_sel t_row;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  
    row_ori := hookInput.originalRowset.rowset(1);
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <>'VALIDATED') then
       hookoutput.message := 'Import entry should be validated before triggering this command.';
       V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   return;
   end if;
       --     nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
   --    ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_1', nci_11179_2.getCncptStrFromForm (row_ori, 5,1));
   --        ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_2', nci_11179_2.getCncptStrFromForm (row_ori, 6,2));
     v_found:= false;
     if (v_item_typ ='5') then 
     v_str := nvl(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),'XXXXXX');
     v_item_typ_id := 5;
     v_obj_nm :='Object Classes';
     idx := 1;
     else
     v_str := nvl(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2'),'XXXXXX');
     v_item_typ_id := 6;
      v_obj_nm :='Properties';
      idx := 2;
    end if; 
    if (hookinput.invocationnumber = 0) then -- first invocation
     for cur in (select e.item_id, e.ver_nr from  admin_item ai , nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and
     ai.admin_item_typ_id = v_item_typ_id and e.cncpt_concat = v_str) loop
     row := t_row();
     ihook.setColumnValue(row,'ITEM_ID', cur.item_id);
     ihook.setColumnValue(row,'VER_NR', cur.ver_nr);
     rows.extend; rows(rows.last) := row;
    v_found := true;
     end loop;
     ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Select Alternate');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
  
    

	  if (v_found) then
       	 showrowset := t_showablerowset (rows, v_obj_nm, 2, 'single');
       	 hookoutput.showrowset := showrowset;
           QUESTION               := T_QUESTION('Qualifying Administered Items', ANSWERS);
    HOOKOUTPUT.QUESTION    := QUESTION;

     else
     hookoutput.message := 'No qualifying items found';
     end if;
     end if; -- first invocation
     if (hookinput.invocationnumber = 1 and hookinput.selectedRowset is not null) then

            row_sel := hookinput.selectedRowset.rowset(1);
            v_id := ihook.getColumnValue(row_sel, 'ITEM_ID');
            v_ver:= ihook.getColumnValue(row_sel,'VER_NR');
            
            for cur in (select * from nci_admin_item_ext where item_id = v_id and ver_nr = v_ver) loop
  ihook.setColumnValue(row_ori,'ITEM_' || idx || '_LONG_NM', cur.cncpt_concat);
        ihook.setColumnValue(row_ori,'ITEM_' || idx || '_DEF',cur.cncpt_concat_def);
        ihook.setColumnValue(row_ori,'ITEM_' || idx || '_NM', cur.cncpt_concat_nm);
        ihook.setColumnValue(row_ori, 'ITEM_' || idx || '_ID', v_id);
         ihook.setColumnValue(row_ori, 'ITEM_' || idx || '_VER_NR', v_ver);
         rows:= t_rows();
         rows.extend; rows(rows.last) := row_ori;
           action := t_actionrowset(rows, 'Core Import (No FK)', 2,11,'update');
        actions.extend;
        actions(actions.last) := action;
   
        hookoutput.actions := actions; 
end loop;
     end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;


    
    


procedure spCreateValDesigImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    rowins  t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
 v_temp integer;
 v_val_ind  boolean;
   actions t_actions := t_actions();
   row_to_comp t_row;
   v_batch_nbr number;
    nw_cntxt varchar2(64);
    v_long_nm varchar2(128);
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  rowins := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','' );                      
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then

-- Copy source attributes to validated attributes
        if (ihook.getColumnValue(row_ori, 'SRC_ITEM_ID')  is null or ihook.getColumnValue(row_ori, 'SRC_VER_NR')  is null) then
                v_val_ind := false;   
                    if (ihook.getColumnValue(row_ori, 'SRC_ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID is missing.' || chr(13) );           
                end if;
                       if (ihook.getColumnValue(row_ori, 'SRC_VER_NR')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Version is missing.' || chr(13) );           
                end if;
        else
        for curx in (select * from admin_item where ITEM_ID = ihook.getColumnValue(row_ori, 'SRC_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'SRC_VER_NR'))  loop
        ihook.setColumnValue(row_ori,'ITEM_ID', ihook.getColumnValue(row_ori, 'SRC_ITEM_ID'));
        ihook.setColumnValue(row_ori,'VER_NR', ihook.getColumnValue(row_ori, 'SRC_VER_NR'));
        
        end loop;
        if ( ihook.getColumnValue(row_ori,'ITEM_ID') is null) then -- invalid ID
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR:' || ' No Administered Item found with the Item_id/Ver_nr.'|| chr(13) );                      
                  v_val_ind := false;   
        end if;
       
        end if;
        
        -- Copy Admin Item Type
            if (ihook.getColumnValue(row_ori, 'SRC_AI_TYP')  is null ) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Type is not provided.' || chr(13) );                      
                v_val_ind := false;   
        else
        for curx in (select * from vw_obj_key_4 where upper(obj_key_desc) = upper(ihook.getColumnValue(row_ori, 'SRC_AI_TYP')))  loop
        ihook.setColumnValue(row_ori,'ADMIN_ITEM_TYP_ID',curx.obj_key_id);
        
        end loop;
        if ( ihook.getColumnValue(row_ori,'ADMIN_ITEM_TYP_ID') is null) then -- invalid ID
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Type is not a valid type in LOV.'|| chr(13) );                      
                  v_val_ind := false;   
        end if;
       
        end if;


    
    
        if (ihook.getColumnValue(row_ori, 'NM_DESC')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: No alternate name provided.' || chr(13) );                      
                v_val_ind := false;   
        end if;
        
        if (ihook.getColumnValue(row_ori, 'NM_TYP_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alt Name Type is missing or invalid.' || chr(13) );                      
                v_val_ind := false;   
        end if;

  
  --jira 2440 -autopopulate AI long name if not imported
if (ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') is null OR ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') = '') then
    select ITEM_NM into v_long_nm from admin_item ai where ai.item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ai.ver_nr = ihook.getColumnValue(row_ori, 'VER_NR');
    ihook.setColumnValue(row_ori, 'SPEC_LONG_NM', v_long_nm);
end if;
--   if (ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')  is null) then
--                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Long Name is missing.' || chr(13) );                      
--                v_val_ind := false;   
--        end if;

        for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
        and Item_nm <> ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')) loop
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Public ID Does not match Imported Name: ' || ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') || chr(13) );                      
                v_val_ind := false;   
        end loop;
              if (ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Context is missing or invalid.' || chr(13) );                      
                v_val_ind := false;   
        end if;
         -- raise_application_error(-20000,ihook.getColumnValue(row_ori, 'LANG_ID') );
             if (ihook.getColumnValue(row_ori, 'LANG_ID') is null OR (ihook.getColumnValue(row_ori, 'LANG_ID') != 1007 AND ihook.getColumnValue(row_ori, 'LANG_ID') != 1004 AND ihook.getColumnValue(row_ori, 'LANG_ID') != 1000)) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'WARNING: Alt Name Lang missing or invalid. ENGLISH will be used.' || chr(13) );                      
                ihook.setColumnValue(row_ori, 'LANG_ID',1000);
          --      v_val_ind := false;   
        end if;
                -- Jira 1924
        if (ihook.getColumnValue(row_ori, 'NM_TYP_ID')= 1038) then --1038 is internal id for USED_BY
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') || 'WARNING: Alternate Name will be set to Context Name for Used By.' || chr(13) );
            select item_nm into nw_cntxt from vw_cntxt where item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID');
            ihook.setColumnValue(row_ori, 'NM_DESC', nw_cntxt);
        end if;
        -- end Jira 1924

if (v_val_ind = true) then
      select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
      and admin_item_typ_id = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') ;
      if (v_temp = 0) then
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID/Type do not match.' || chr(13) );                      
                v_val_ind := false;   
        end if;
end if;
	

/*
      select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
      and item_nm = ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') ;
      if (v_temp = 0) then
           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID/Name do not match.' || chr(13) );                      
                v_val_ind := false;   
        end if;*/
-- duplicate in the database     
  if (v_val_ind = true) then
          select count(*) into v_temp from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr =      ihook.getColumnValue(row_ori, 'VER_NR')  
         and nm_desc = ihook.getColumnValue(row_ori, 'NM_DESC') and nm_typ_id = ihook.getColumnValue(row_ori, 'NM_TYP_ID') and cntxt_item_id  = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
         and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')  ;
         if (v_temp > 0) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'DUPLICATE');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Alternate name already exists.');                      
              v_val_ind := false;
        end if;
 end if;
 if (v_val_ind = true) then
      for k in i+1..hookinput.originalrowset.rowset.count loop
             row_to_comp := hookinput.originalrowset.rowset(k);
      if (ihook.getColumnValue(row_to_comp, 'ITEM_ID') = ihook.getColumnValue(row_ori, 'ITEM_ID')
      and ihook.getColumnValue(row_to_comp, 'VER_NR') = ihook.getColumnValue(row_ori, 'VER_NR') 
      and ihook.getColumnValue(row_to_comp, 'NM_TYP_ID') = ihook.getColumnValue(row_ori, 'NM_TYP_ID') 
      and ihook.getColumnValue(row_to_comp, 'NM_DESC') = ihook.getColumnValue(row_ori, 'NM_DESC') 
      and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
      and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') 
     -- and ihook.getColumnValue(row_to_comp, 'ADMIN_ITEM_TYP_ID') = ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') 
      and ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') != ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR')) then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
   ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );                
   end if;
   end loop;
 end if;
 
   --   raise_application_error(-20000, 'Import');
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
             ihook.setColumnValue(row_ori, 'NM_ID', -1);
              ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
               rowins.extend; rowins(rowins.last) := row_ori;
        end if;
    rows.extend; rows(rows.last) := row_ori;
  end if; 
 
end loop;
    action := t_actionrowset(rows, 'Designation Import', 2,11,'update');
        actions.extend;
        actions(actions.last) := action;
         action := t_actionrowset(rowins, 'Alternate Names (All Types for Hook)', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure spValCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
 action t_actionRowset;
 v_val_ind  boolean;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'DROP-DOWN', actions) ;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'DROP-DOWN', actions) ;
        nci_vd.createValAIWithConcept(row_ori, 3,7,'V', 'DROP-DOWN', actions) ;

        nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
        nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
        nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);

   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      

        end if;
    rows.extend; rows(rows.last) := row_ori;
   end if; -- only if not processed     
end loop;
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure spCreateValDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
 action t_actionRowset;
 v_val_ind  boolean;
 v_dup_ind boolean;
 v_gap_ind boolean;
 v_batch_nbr number;
   actions t_actions := t_actions();
   row_to_comp t_row;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;

-- Parsefirst
        if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
          ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),1, row_ori);
    end if;
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then  
          ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2'),2, row_ori);
        end if;
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'ERRORS') then
            v_val_ind:= false;
        
    end if;
    --jira 2183 - created new import validation message column. report post import errors there and do not remove. do not allow validate/create
      if (   ihook.getColumnValue(row_ori, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(row_ori, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: OC or PROP missing.' || chr(13));
                      ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');

                  v_val_ind:= false;
        end if;

            if (   ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') is null ) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: DEC Conceptual Domain is missing.' || chr(13));
                                  ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');
                 v_val_ind:= false;
        end if;
     ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
 --   nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);

     if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null  and v_mode='V' and v_Val_ind = true)    then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'DROP-DOWN', actions) ;
        nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'DROP-DOWN', actions) ;

        --nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
        if (ParseGaps (row_ori , 1) > 0) then
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') ||  'ERROR: Gaps in OC concept drop-downs.' || chr(13));                      
        v_val_ind := false;
       end if;
         if (ParseGaps (row_ori , 2) > 0) then
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') ||  'ERROR: Gaps in Prop concept drop-downs.' || chr(13));                      
        v_val_ind := false;
       end if;
               nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
       ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_1', nci_11179_2.getCncptStrFromForm (row_ori, 5,1));
           ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_2', nci_11179_2.getCncptStrFromForm (row_ori, 6,2));
     
        if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',nvl( ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'), 'No Errors'));                      
        end if;
    end if;
    --    if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null and ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID') is null and  ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_FND') is null
   --     and v_mode = 'C') then
   -- jira 2183 - only run Create if DEC has been validated
        if (ihook.getColumnValue(row_ori,'DE_CONC_ITEM_ID_CREAT') is null and v_mode = 'C' and v_val_ind = true) then

        --and v_val_ind = true)    then
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        v_val_ind := true;

-- Validate to see if the same row is not already selected
    for k in i+1..hookinput.originalrowset.rowset.count loop
             row_to_comp := hookinput.originalrowset.rowset(k);
        if (ihook.getColumnValue(row_to_comp, 'ITEM_1_NM') = ihook.getColumnValue(row_ori, 'ITEM_1_NM') and ihook.getColumnValue(row_to_comp, 'ITEM_2_NM') = ihook.getColumnValue(row_ori, 'ITEM_2_NM')) then
    v_val_ind := false;
    v_dup_ind := true;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   end if;
   end loop;
        if (ParseGaps (row_ori , 1) > 0) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') ||  'ERROR: Gaps in OC concept drop-downs.' || chr(13));                      
            v_val_ind := false;
            v_gap_ind := true;
       end if;
        if (ParseGaps (row_ori , 2) > 0) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') ||  'ERROR: Gaps in Prop concept drop-downs.' || chr(13));                      
            v_val_ind := false;
            v_gap_ind := true;
    end if;
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            if (v_dup_ind = true) then
              ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );           
            end if;
        else
        nci_dec_mgmt.spDECValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;
      end if;
    rows.extend; rows(rows.last) := row_ori;
 --  end if; -- only if not processed     
end loop;
--raise_application_error(-20000,'heddddrereffffrter');

    action := t_actionrowset(rows, 'Core Import (No FK)', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_val_ind := true;
    if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null) then
      nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'STRING', actions) ;
    nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'STRING', actions) ;
    end if;

    if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null) then

    nci_vd.createValAIWithConcept(row_ori, 3,7,'V', 'STRING', actions) ;
    end if;

    -- Added to combine decompose and validation in one step
    nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);
    nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
    nci_chng_mgmt.spDEValCreateImport(row_ori, 'V', actions, v_val_ind);

   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
    if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
    else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      

    end if;
   -- end of validation

    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


procedure spPostDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_val_ind := true;
 if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
    if ihook.getColumnValue(row_ori, 'MOD_NM') = 'I' then
        ihook.setColumnValue(row_ori,'CTL_VAL_MSG','');
        ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');

    end if;
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
          ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),1, row_ori);
          
     -- nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'STRING', actions) ;
    end if;
    if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then  
          ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2'),2, row_ori);
          if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'ERRORS') then
            v_val_ind:= false;
          end if;

 
 --   nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'STRING', actions) ;
    end if;
    --jira 2183 - created new import validation message column. report post import errors there and do not remove. do not allow validate/create
      if (   ihook.getColumnValue(row_ori, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(row_ori, 'CNCPT_2_ITEM_ID_1') is null) then
                  ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: OC or PROP missing.' || chr(13));
                      ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');

                  v_val_ind:= false;
        end if;

            if (   ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') is null ) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: DEC Conceptual Domain is missing.' || chr(13));
                                  ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');

    
                 v_val_ind:= false;
        end if;
     ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
 --   nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind);

   --    raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR_FND'));
  /*  if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
    else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No Errors');                      

    end if;
   -- end of validation
*/
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'DEC Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


procedure spPostVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
    idx int;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_val_ind := true;
    
    idx := 1;
    
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
 
     ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','');
     ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', '');

-- jira 2190 add new columns for qualifier and primary rep term
  --  ihook.setColumnValue(row_ori, 'CNCPT_CONCat_STR_3', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_3' || ihook.getColumnValue(row_ori, 'REP_TERM_QUAL_CONC') || ' ' || ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM');
    if (ihook.getColumnValue(row_ori, 'REP_TERM_QUAL_CONC') is not null and ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
        ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_3', ihook.getColumnValue(row_ori, 'REP_TERM_QUAL_CONC') || ' ' || ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM'));
        --ConceptParseDEC(ihook.getColumnValue(row_ori,'CNCPT_CONCAT_STR_3'), idx, row_ori);
        nci_vd.VDImportPost(row_ori, 3,7,'V', 'STRING', actions);
    elsif (ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
        ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_3', ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM'));
        nci_vd.VDImportPost(row_ori, 3,7,'V', 'STRING', actions);
    end if;
      -- below is original if statement before 2190
  --  if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_3') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
   --   nci_vd.VDImportPost(row_ori, 3,7,'V', 'STRING', actions) ;
   --nci_vd.createValAIWithConcept (row_ori, 3,7,'V', 'STRING', actions);
   --   raise_application_error(-20000, 'here');
  --  end if;
    ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'VD Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
 end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;

procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    v_val_ind  boolean;
    cnt integer;
 action t_actionRowset;
   actions t_actions := t_actions();
   rowais t_rows ;
   rowiucs t_rows;
   rowcdvms  t_rows;
   rowpvs  t_rows;
   rowaltnms  t_rows;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
      rows := t_rows();
 rowais := t_rows();
 rowiucs := t_rows();
 rowcdvms := t_rows();
   rowpvs :=  t_rows();
   rowaltnms := t_rows();
 cnt := least(hookinput.originalRowset.rowset.count,1000);
--raise_application_error(-20000,cnt);

for i in 1..cnt loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
   if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'VALIDATED') then
       nci_pv_vm.spPVVMImport ( row_ori,actions ,rowais, rowiucs,rowcdvms, rowpvs, rowaltnms);
       row := t_row();
       
       ihook.setColumnValue(row,'CTL_VAL_MSG', 'PV/VM created successfully.');
       ihook.setColumnValue(row,'CTL_VAL_STUS', 'PROCESSED');
       ihook.setColumnValue(row,'STG_AI_ID',  ihook.getColumnValue(row_ori,'STG_AI_ID'));
       
    rows.extend; rows(rows.last) := row;
       
  /*       update NCI_STG_PV_VM_IMPORT set
CTL_VAL_STUS= 'PROCESSED',
CTL_VAL_MSG='PV/VM created successfully.'
        where STG_AI_ID= ihook.getColumnValue(row_ori,'STG_AI_ID');
        commit;*/
    -- Jira 1920: add logic to catch if the selection has not been validated yet or run validate procedure and then import
    --   else raise_application_error(-20000, 'Please validate selection first.');
     end if;
end loop;

  action := t_actionrowset(rowais, 'Administered Item (No FK)', 2,1,'insert');
        actions.extend;
        actions(actions.last) := action;

      action := t_actionrowset(rowais, 'NCI AI Extension (Hook)', 2,3,'insert');
        actions.extend;
        actions(actions.last) := action;
    
      action := t_actionrowset(rowais, 'Value Meaning', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;
    
    action := t_actionrowset(rowiucs, 'Items under Concept (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        
        action := t_actionrowset(rowcdvms, 'Value Meanings (No FK)', 2,10,'insert');
          actions.extend;
          actions(actions.last) := action;

          action := t_actionrowset(rowpvs, 'Permissible Values (No FK)', 2,19,'insert');
           actions.extend;
           actions(actions.last) := action;
      action := t_actionrowset(rowaltnms, 'Alternate Names', 2,23,'insert');
           actions.extend;
           actions(actions.last) := action;

   action := t_actionrowset(rows, 'PV VM Import (No FK)', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
      hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
nci_util.debugHook('GENERAL',v_data_out);
end;

--  PV/VM


procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
 action t_actionRowset;
 v_val_ind  boolean;
  v_batch_nbr number;
   actions t_actions := t_actions();
   row_to_comp t_row;
   v_str varchar2(4000);
   v_val_dom_id number;
   v_val_dom_Ver number(4,2);
   vd_status varchar2(1000);
   cd_status varchar2(1000);
   vd_valdom_id number;
   v_conc_dom_id number;
   v_conc_dom_ver number(4,2);
   v_ctl_val_msg  varchar2(4000);
   v_ctl_val_stus varchar2(100);
   v_ctl_val_ind boolean;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    rows := t_rows();
  
  -- Set initial Value Domain
    row_ori := hookInput.originalRowset.rowset(1);
    v_val_dom_id :=  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
    v_val_dom_ver := ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');

    for i in 1..hookinput.originalRowset.rowset.count loop

        row_ori := hookInput.originalRowset.rowset(i);
        if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
        --jira 1875
            v_val_ind :=true;
        
        -- Parse if not already parsed
            if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'CONCEPTS' and nvl(ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),'XX') ='IMPORTED') then
                v_str := trim(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
                ConceptParseDEC(v_str,1, row_ori);
                ihook.setColumnValue(row_ori,'CTL_VAL_STUS','VALIDATED');   
                
            end if;           
            
            if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VM Type missing or invalid.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                v_val_ind := false;
            end if;
  --- Check for Value domain once
        /*    if (( ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') <> v_val_dom_id or  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') <> v_val_dom_ver or i = 1)
            and v_val_ind = true) then
                v_val_dom_id :=  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
                v_val_dom_ver := ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
                vd_valdom_id := 0;
                
                for cur_vd in (select vd.item_id, vd.admin_stus_nm_dn, cd.admin_stus_nm_dn cd_admin_stus_nm_dn, cd.item_id cd_item_id, cd.ver_nr cd_ver_nr from admin_item vd, value_dom , vw_conc_dom cd
                where vd.admin_item_typ_id = 3 and vd.item_id = v_val_dom_id and vd.ver_nr = v_val_dom_ver and vd.item_id = value_dom.item_id and vd.ver_nr = value_dom.ver_nr
                and nvl(ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID'),value_dom.conc_dom_item_id)=cd.item_id and nvl(ihook.getColumnValue(row_ori, 'CONC_DOM_VER_NR'),value_dom.conc_dom_ver_nr) = cd.ver_nr and value_dom.VAL_DOM_TYP_ID= 17) loop
                    vd_valdom_id := cur_vd.item_id;
                    vd_status := cur_vd.admin_stus_nm_dn;
                    cd_status := cur_vd.cd_admin_stus_nm_dn;
                    v_conc_dom_id := cur_vd.cd_item_id;
                    v_conc_dom_ver := cur_vd.cd_ver_nr;
                end loop;

                if (vd_status = 'RETIRED ARCHIVED' ) then
           --raise_application_error(-20000, 'in Retired Archived condition');
                    v_ctl_val_msg := 'ERROR: VD is Retired.' || chr(13);
                    v_ctl_val_stus := 'ERRORS';
                    v_ctl_val_ind := false;
                end if;

   -- select ASL_NAME into vd_asl_name from value_domains_view where vd_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
                if (vd_valdom_id is null) then
                    v_ctl_val_msg := 'ERROR: VD is either invalid or non-enum.' || chr(13) || v_ctl_val_msg;
                    v_ctl_val_stus := 'ERRORS';
                    v_ctl_val_ind := false;
                end if;
    
            -- jira 1981
                if (cd_status = 'RETIRED ARCHIVED' ) then
                    v_ctl_val_msg := 'WARNING: Value Domain CD is Retired.' || chr(13) || v_ctl_val_msg;
                end if;
                if (cd_status = 'DRAFT NEW' ) then
                    v_ctl_val_msg := 'WARNING: Value Domain CD has not been released.'|| chr(13) || v_ctl_val_msg;
                end if;
        end if;
        -- Check for VD once
        
        ihook.setColumnValue(row_ori, 'CONC_DOM_ITEM_ID', nvl(ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID'),v_conc_dom_id));
        ihook.setColumnValue(row_ori, 'CONC_DOM_VER_NR', nvl(ihook.getColumnValue(row_ori, 'CONC_DOM_VER_NR'),v_conc_dom_Ver));
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', v_ctl_val_msg || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', v_ctl_val_stus);
        if (v_ctl_val_ind = false) then
            v_val_ind := false;
        end if;
        */
       -- if ( ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') = v_val_dom_id and  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')= v_val_dom_ver  and v_val_ind = true) then
            for k in i+1..hookinput.originalrowset.rowset.count loop
                row_to_comp := hookinput.originalrowset.rowset(k);
                if (ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
                and ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') 
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                    v_val_ind := false;
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') = ihook.getColumnValue(row_ori, 'PERM_VAL_NM') ) then
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr ); 
                    else
    -- jira 1962
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: PV shares VM with Batch Number: ' || v_batch_nbr || chr(13) || 'Run Create PV/VM for Seq ' || ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') || ', then Validate again.'  );       
                    end if;
                end if;
            end loop;
     --   end if;
  
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else 
         rows.extend; rows(rows.last) := row_ori;
         spPVVMValidate(row_ori);
        end if;
        rows.extend; rows(rows.last) := row_ori;
        
        -- replace actions with update
        update NCI_STG_PV_VM_IMPORT set
        CNCPT_1_ITEM_ID_1= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_1'),
        CNCPT_1_VER_NR_1= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_1'),
      CNCPT_1_ITEM_ID_2= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_2'),
        CNCPT_1_VER_NR_2= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_2'),
              CNCPT_1_ITEM_ID_3= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_3'),
        CNCPT_1_VER_NR_3= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_3'),
      CNCPT_1_ITEM_ID_4= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_4'),
        CNCPT_1_VER_NR_4= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_4'),
      CNCPT_1_ITEM_ID_5= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_5'),
        CNCPT_1_VER_NR_5= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_5'),
      CNCPT_1_ITEM_ID_6= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_6'),
        CNCPT_1_VER_NR_6= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_6'),
      CNCPT_1_ITEM_ID_7= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_7'),
        CNCPT_1_VER_NR_7= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_7'),
      CNCPT_1_ITEM_ID_8= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_8'),
        CNCPT_1_VER_NR_8= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_8'),
      CNCPT_1_ITEM_ID_9= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_9'),
        CNCPT_1_VER_NR_9= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_9'),
      CNCPT_1_ITEM_ID_10= ihook.getColumnValue(row_ori,'CNCPT_1_ITEM_ID_10'),
        CNCPT_1_VER_NR_10= ihook.getColumnValue(row_ori,'CNCPT_1_VER_NR_10'),
CTL_IMPORT_VAL_MSG= ihook.getColumnValue(row_ori,'CTL_IMPORT_VAL_MSG'),
DT_LAST_MODIFIED= ihook.getColumnValue(row_ori,'DT_LAST_MODIFIED'),
ITEM_1_ID= ihook.getColumnValue(row_ori,'ITEM_1_ID'),
ITEM_1_NM= ihook.getColumnValue(row_ori,'ITEM_1_NM'),
ITEM_1_DEF= ihook.getColumnValue(row_ori,'ITEM_1_DEF'),
VW_SPEC_DEF= ihook.getColumnValue(row_ori,'VW_SPEC_DEF'),
	VM_ALT_NM_LANG= ihook.getColumnValue(row_ori,'VM_ALT_NM_LANG'),
    	VM_ALT_NM= ihook.getColumnValue(row_ori,'VM_ALT_NM'),
        	VM_ALT_NM_TYP_ID= ihook.getColumnValue(row_ori,'VM_ALT_NM_TYP_ID'),
            VM_ALT_NM_CNTXT_ITEM_ID= ihook.getColumnValue(row_ori,'VM_ALT_NM_CNTXT_ITEM_ID'),
            VM_ALT_NM_CNTXT_VER_NR= ihook.getColumnValue(row_ori,'VM_ALT_NM_CNTXT_VER_NR'),
            CONC_DOM_ITEM_ID= ihook.getColumnValue(row_ori,'CONC_DOM_ITEM_ID'),
            CONC_DOM_VER_NR= ihook.getColumnValue(row_ori,'CONC_DOM_VER_NR'),
            CMNTS_DESC_TXT= ihook.getColumnValue(row_ori,'CMNTS_DESC_TXT'),
CTL_VAL_STUS= ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),
CTL_VAL_MSG=ihook.getColumnValue(row_ori,'CTL_VAL_MSG')
        where STG_AI_ID= ihook.getColumnValue(row_ori,'STG_AI_ID');
        commit;
   end if; -- only if not processed 
end loop;
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
      --  hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;

procedure ConceptParse(v_str in varchar2, idx in integer, row_ori in out t_row)
as
i integer;
cnt integer;
v_cncpt_nm varchar2(255);
v_count integer;
v_str1 varchar2(4000);
begin

   cnt := nci_11179.getwordcount(v_str);
  -- raise_application_error(-20000, v_str);
  for i in 1..10 loop
                           ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, ''); 
                   
  end loop;
   v_str1 := replace(v_str,chr(9),'');
                for i in  1..cnt loop
                        v_cncpt_nm := trim(nci_11179.getWord(v_str1, i, cnt));
                        -- jira 1939- make sure the query returns something- if not, return the invalid concept in the validation message
                        select count(*) into v_count from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm));
                          -- and admin_stus_nm_dn = 'RELEASED';
                        if (v_count = 0) then
                            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Invalid or No Concepts: ' || v_cncpt_nm || chr(13));

                        end if; 
                           for cur in(select item_id, ver_nr, item_nm , item_long_nm, item_desc, admin_stus_nm_dn 
                           from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                      --     and admin_stus_nm_dn = 'RELEASED') loop
                    -- raise_application_error(-20000, cur.item_id);
                            if (cur.admin_stus_nm_dn = 'RELEASED') then
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,cur.item_id);
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, cur.ver_nr); 
                            end if;
                            if (cur.admin_stus_nm_dn like '%RETIRED%') then
                                          ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Retired Concept: ' || v_cncpt_nm 
                                          || ' ' || cur.item_nm  || chr(13));
                            end if;
                            end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
end ;

procedure ConceptParseDEC(v_str in varchar2, idx in integer, row_ori in out t_row)
as
i integer;
cnt integer;
v_cncpt_nm varchar2(255);
v_count integer;
v_str1 varchar2(4000);
begin

   cnt := nci_11179.getwordcount(v_str);
  -- raise_application_error(-20000, v_str);
  for i in 1..10 loop
                           ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, ''); 
                   
  end loop;
   v_str1 := replace(v_str,chr(9),'');
                for i in  1..cnt loop
                        v_cncpt_nm := trim(nci_11179.getWord(v_str1, i, cnt));
                        -- jira 1939- make sure the query returns something- if not, return the invalid concept in the validation message
                        select count(*) into v_count from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm));
                          -- and admin_stus_nm_dn = 'RELEASED';
                        if (v_count = 0) then
                            ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: Invalid or No Concepts: ' || v_cncpt_nm || chr(13));
                            ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');
                        end if; 
                           for cur in(select item_id, ver_nr, item_nm , item_long_nm, item_desc, admin_stus_nm_dn 
                           from admin_item where admin_item_typ_id = 49 and upper(item_long_nm) = upper(trim(v_cncpt_nm))) loop
                      --     and admin_stus_nm_dn = 'RELEASED') loop
                    -- raise_application_error(-20000, cur.item_id);
                            if (cur.admin_stus_nm_dn = 'RELEASED') then
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,cur.item_id);
                            ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, cur.ver_nr); 
                            end if;
                            if (cur.admin_stus_nm_dn like '%RETIRED%') then
                                          ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: Retired Concept: ' || v_cncpt_nm 
                                          || ' ' || cur.item_nm  || chr(13));
                                        ihook.setColumnValue(row_ori,'CTL_VAL_STUS','ERRORS');
                            end if;
                            end loop;
                end loop;
                for i in  cnt+1..10 loop
                        ihook.setColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i,'');
                        ihook.setColumnValue(row_ori, 'CNCPT_' || idx || '_VER_NR_' || i, '');
                end loop;
end ;

procedure spPostPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();

    rows      t_rows;
    row          t_row;
    row_ori t_row;
i integer;
cnt integer;
idx integer;
v_cncpt_nm varchar2(255);
v_str varchar2(255);
  action t_actionRowset;
   actions t_actions := t_actions();
v_count integer;
begin

-- ITEM_2_ID : Value Domain public Id; ITEM_2_VER_NR: Value Domain Version; ITEM_2_LONG_NM: Used to see if Concept or String - VM String Type

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
   idx := 1;
              ihook.setColumnValue(row_ori,'CTL_VAL_MSG',''); 
              ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', '');
      
  if (ihook.getColumnValue (row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then 
         if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'CONCEPTS' and nvl(ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),'XX') ='IMPORTED') then
                v_str := trim(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_'|| idx));
                ConceptParseDEC(v_str,idx, row_ori);
             
         ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');                

        
          rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
    if (upper(nvl(ihook.getColumnValue(row_ori, 'VM_STR_TYP'),'XX')) <> 'CONCEPTS' and nvl(ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),'XX') ='IMPORTED') then
             ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');
          rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    
    end if;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


procedure spPostPVVMImportEdit (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();

    rows      t_rows;
    row          t_row;
    row_ori t_row;
i integer;
cnt integer;
idx integer;
v_cncpt_nm varchar2(255);
v_str varchar2(255);
  action t_actionRowset;
   actions t_actions := t_actions();
v_count integer;
begin

-- ITEM_2_ID : Value Domain public Id; ITEM_2_VER_NR: Value Domain Version; ITEM_2_LONG_NM: Used to see if Concept or String - VM String Type

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
   idx := 1;
              ihook.setColumnValue(row_ori,'CTL_VAL_MSG',''); 
              ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', '');
      
  if (ihook.getColumnValue (row_ori, 'CTL_VAL_STUS') <> 'PROCESSED' and ihook.getColumnValue (row_ori, 'CTL_VAL_STUS') <> 'IMPORTED') then 
   
    spPVVMValidate(row_ori);      
          rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;


function ParseGaps (row_ori in t_row, idx in number) return integer
is
v_temp integer :=0;
i integer;
j integer;
begin
--raise_application_error(-20000,'TEt');
for i in 1..10 loop
j := i+1;
 if (ihook.getColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || j) is not null and
 ihook.getColumnValue(row_ori, 'CNCPT_' || idx  ||'_ITEM_ID_' || i) is null) then
 return i;
 end if;
                   
end loop;
return 0;
end;

procedure spPVVMValidate (row_ori in out t_row)
as
  actions t_actions := t_actions();

    rows      t_rows;
    row          t_row;
    v_val_ind boolean;
    v_item_id number;
    v_ver_nr number(4,2);
    v_temp integer;
    vd_status string(64);
    vd_valdom_id number;
    cd_status string(64);
    cd_id number;
    cd_ver_nr number(4,2);
    row_to_comp t_row;
    v_batch_nbr number;
 begin
 
  
-- ITEM_2_ID : Value Domain public Id; ITEM_2_VER_NR: Value Domain Version; ITEM_2_LONG_NM: Used to see if Concept or String - VM String Type
    v_val_ind := true;
      
   for cur_vd in (select item_id, admin_stus_nm_dn from admin_item 
   where admin_item_typ_id = 3 and ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') = ver_nr and ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') = item_id) loop
   vd_valdom_id := cur_vd.item_id;
   vd_status := cur_vd.admin_stus_nm_dn;
   end loop;

   if (vd_status = 'RETIRED ARCHIVED' ) then
           --raise_application_error(-20000, 'in Retired Archived condition');
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VD is Retired.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
        end if;

   -- select ASL_NAME into vd_asl_name from value_domains_view where vd_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID');
         if (vd_valdom_id is null) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VD is either invalid or non-enum.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
      end if;
    
    if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') is null) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VM Type missing or invalid.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
      end if;
      if (v_val_ind = true) then
            for cur_cd in (select vd.conc_dom_item_id, vd.conc_dom_ver_nr, admin_stus_nm_dn from admin_item ai, Value_dom vd where ai.admin_item_typ_id = 1 and ai.item_id = vd.conc_dom_item_id
            and ai.ver_nr = vd.conc_dom_ver_nr and vd.item_id =  ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and vd.ver_nr =  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')) loop
            -- jira 1981
                if (cur_cd.admin_stus_nm_dn = 'RETIRED ARCHIVED' ) then
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Value Domain CD is Retired.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                end if;
                if (cur_cd.admin_stus_nm_dn = 'DRAFT NEW' ) then
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Value Domain CD has not been released.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                end if;
                if (ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') is null) then 
                    ihook.setColumnValue(row_ori, 'CONC_DOM_ITEM_ID', cur_cd.CONC_DOM_ITEM_ID);
                    ihook.setColumnValue(row_ori, 'CONC_DOM_VER_NR', cur_Cd.CONC_DOM_VER_NR);
                end if;
            end loop;
        end if; 

if (v_val_ind = true) then
--raise_application_error(-20000,'HErer');
   if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'CONCEPTS') then
       nci_dec_mgmt.createValAIWithConcept(row_ori, 1,53,'V', 'DROP-DOWN', actions) ;
       if (ParseGaps (row_ori , 1) > 0) then
         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',   'ERROR: Gaps in concept drop-downs.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') );                      
        v_val_ind := false;
       end if;
       

       if (ihook.getColumnValue(row_ori, 'CNCPT_1_ITEM_ID_1') is null and v_val_ind = true) then
             ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',   'ERROR: No valid concepts specified for Value Meaning.' || chr(13));                      
        v_val_ind := false;
       end if;
    end if;

    -- If string type is ID, make sure ID is valid.
    if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP')) = 'ID') then
    -- check if it is really a number.
    if VALIDATE_CONVERSION(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') as number)!=1 then
              ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Specified VM ID is not a number.' || chr(13));                      
            v_val_ind := false;
   else
        select count(*) into v_temp from admin_item where item_id = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') and currnt_ver_ind = 1 and admin_item_typ_id = 53;
        if (v_temp = 0) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Specified VM ID is not found.' || chr(13));                      
            v_val_ind := false;
        else
            ihook.setColumnValue(row_ori, 'ITEM_1_ID', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
            ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', 1);
            for curtemp in (Select item_nm from admin_item where  item_id = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') and currnt_ver_ind = 1 and admin_item_typ_id = 53) loop
            	 ihook.setColumnValue(row_ori, 'ITEM_1_NM',curtemp.item_nm);
           end loop;
        end if;
    end if;
    end if;
    if (upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP'))  = 'TEXT') then
        nci_dec_mgmt.createAIWithoutConcept(row_ori , 1, 53, ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),nvl(ihook.getColumnValue(row_ori, 'ITEM_1_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')),'V',
        actions);
        v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
        v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
        ihook.setColumnValue(row_ori, 'GEN_STR', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
 ihook.setColumnValue(row_ori, 'ITEM_1_NM',ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
    end if;
end if;
    
    -- Alternate name validation
    if (ihook.getColumnValue(row_ori,'VM_ALT_NM') is not null) then
      if (ihook.getColumnValue(row_ori,'VM_ALT_NM_TYP_ID') is  null) then
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alt Name Type is missing.' || chr(13));                      
            v_val_ind := false;
    end if;
      if (ihook.getColumnValue(row_ori,'VM_ALT_NM_CNTXT_ITEM_ID') is  null) then
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alt Name Context missing.' || chr(13));                      
            v_val_ind := false;
    end if;
    end if;
    
      if (ihook.getColumnValue(row_ori,'VM_ALT_NM_LANG') is not null) then
      select count(*) into v_temp from LANG where upper(LANG_DESC) = upper(ihook.getColumnValue(row_ori,'VM_ALT_NM_LANG'));
      if (v_temp = 0) then
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alt Name Language is invalid.' || chr(13));                      
            v_val_ind := false;
            end if;
    end if;
    
       if ((ihook.getColumnValue(row_ori,'VM_ALT_NM') is  null) and
      (ihook.getColumnValue(row_ori,'VM_ALT_NM_TYP_ID') is not  null or ihook.getColumnValue(row_ori,'VM_ALT_NM_CNTXT_ITEM_ID') is  not null 
      or ihook.getColumnValue(row_ori,'VM_ALT_NM_LANG') is  not null)) then
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'WARNING: Missing Alt Name, Alt Name will not be created.' || chr(13));                      
      --      v_val_ind := false;
    end if;
     
     /*
   if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            --check if VD is retired. set message
        end if;
     
       */ 
    -- check if value already exists for the VD, Jira 1953- if pv exists, check if associated with same vm
    -- Only check if all other conditions are valid
    if (v_val_ind = true and  ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null) then
    for cur in (select * from perm_val where val_dom_item_id= ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID')
    and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and upper(perm_val_nm) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM')) 
    and ihook.getColumnValue(row_ori, 'ITEM_1_ID') = nci_val_mean_item_id and ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') = nci_val_mean_ver_nr) loop
       ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'ERROR: PV/VM combination already exists in the VD' || chr(13));                      
        v_val_ind := false;
    end loop;
    end if;

    
   -- nci_pv_vm.spValCreateImport(row_ori, 'V', actions, v_val_ind);
   
         if (ihook.getcolumnValue(row_ori, 'ITEM_1_ID') is not null) then
              -- Jira 1889 Do not remove values from ITEM_1_ID and ITEM_1_VER_NR - always have VM ID in that column  
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'INFO: Reusing Existing VM: ' || ihook.getcolumnValue(row_ori, 'ITEM_1_ID') || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') );
          end if;
          --jira 1964 - We don't even know if it is an existing VM. Need to check for existing VM
    
          
        if (v_val_ind = true) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
     --           ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') );
            else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
       --             ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') );
        
        end if;
           
        
   -- end of validation


 /*  for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR')) loop
        ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', cur.CNTXT_ITEM_ID);
        ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', cur.CNTXT_VER_NR);
   end loop;*/
      ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', 20000000024); -- NCIP
        ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', 1);
 

end;



procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    k integer;
    row_to_comp t_row;
    v_batch_nbr integer;
    v_val_ind  boolean;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
   rows := t_rows();
 
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
  if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        for k in i+1..rows.count loop
            row_to_comp := hookinput.originalrowset.rowset(k);
            
    if ((ihook.getColumnValue(row_to_comp, 'DE_CONC_ITEM_ID') = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'DE_CONC_VER_NR') = ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR')
    and ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') ) or
    (ihook.getColumnValue(row_to_comp, 'CDE_ITEM_LONG_NM') = ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_ITEM_ID') = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') 
    and ihook.getColumnValue(row_to_comp, 'CNTXT_VER_NR') = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')) ) 
     then
    v_val_ind := false;
    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
   end if;
   end loop;
    if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
              ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );  
    else
       nci_chng_mgmt.spDEValCreateImport(row_ori, 'C', actions, v_val_ind);
        if (v_val_ind = true) then
        iHook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
        -- jira 1888
      -- raise_application_error(-20000, ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID'));
     -- ihook.setColumnValue(row_ori, 'CREAT_CDE_ID', v_item_id);
        end if;
    end if;
    rows.extend; rows(rows.last) := row_ori;
    end if;
end loop;
  action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;


procedure spCreateCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    v_val_ind  boolean;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');

    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'VALIDATED') then
        if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null and ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID_FND') is null) then -- only go thru creating new if not specified and not existing
            nci_dec_mgmt.spDECValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;
        if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null) then -- only go thru creating new if not specified
            nci_vd.spVDValCreateImport(row_ori, 'C', actions, v_val_ind);
        end if;

       nci_chng_mgmt.spDEValCreateImport(row_ori, 'C', actions, v_val_ind);
        if (v_val_ind = true) then
        iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'PROCESSED');
        end if;
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    action := t_actionrowset(rows, 'CDE Import', 2,10,'update');
    end if;
end loop;

        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spCreateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
    v_val_ind  boolean;
 action t_actionRowset;
   actions t_actions := t_actions();
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
    if (ihook.getColumNValue(row_ori, 'CTL_VAL_STUS')<> 'PROCESSED') then
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
            nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
  
        if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null and v_val_ind = true and v_mode = 'C') then -- only go thru creating new if not specified
            nci_vd.spVDValCreateImport(row_ori, 'C', actions, v_val_ind);
            if (v_val_ind = true) then
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'PROCESSED');
            end if;
        end if;

      if ( v_val_ind = true and v_mode = 'V') then -- only go thru creating new if not specified
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'VALIDATED');
        end if;

      if ( v_val_ind = false and v_mode = 'V') then -- only go thru creating new if not specified
                iHook.setColumnValue (row_ori, 'CTL_VAL_STUS', 'ERRORS');
        end if;
    rows.extend; rows(rows.last) := row_ori;
   
end if;    
end loop;
 action := t_actionrowset(rows, 'VD Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);
end;

end;
/