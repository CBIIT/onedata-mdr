create or replace PACKAGE            nci_import AS
procedure spCreateValCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_op in varchar2);
--procedure spValCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
--procedure spCreateCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
--procedure spCreateCDEImportCons (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostCDEImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostModelImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);-- Not used 1/29/24
procedure spPostVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostRTImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPostPVVMImportEdit (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spPVVMValidate (row_ori in out t_row, v_mode in varchar2); 
procedure spCreateValDECImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spUpdateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spUpdValRTImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spCreateValDesigImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spCreateValRefDocImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
--procedure ConceptParse(v_str in varchar2, idx in integer, row_ori in out t_row);
procedure ConceptParseDEC(v_str in varchar2, idx in integer, row_ori in out t_row);
procedure selectFoundID(v_data_in in clob, v_data_out out clob, v_usr_id in varchar2,v_item_typ in integer);
function ParseGaps (row_ori in t_row, idx in number) return integer;
procedure spLoadConceptRel;
procedure spDeleteProcImports;
procedure spCreateValDefImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode varchar2);
procedure spPostDECUpdateImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spUpdateValCDEUpdate (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2);
procedure spPostCDEUpdateImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
--procedure spValPVVMImportOLD (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spValPVVMUpdate (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
procedure spUpdatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2);
function FormatConceptString (v_str in varchar2) return varchar2;
procedure spPVVMUpdate ( row_ori in out t_row, actions in out t_actions, rowais in out t_rows, rowiucs in out t_rows, rowcdvms in out t_rows, rowpvs in out t_rows, rowaltnms in out t_rows, row_pvvms in out t_rows);
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


procedure spCreateValRefDocImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
        -- Jira 3075 automate population of ai long name based on item id and ver
        ihook.setColumnValue(row_ori, 'SPEC_LONG_NM', curx.ITEM_NM);
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
        elsif (ihook.getColumnValue(row_ori, 'NM_TYP_ID') = 80) then --preferred question text jira 3452
            --check if pqt already exists
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Cannot import Preferred Question Text in Reference Document Import. Please change and re-validate.');
            v_val_ind := false;
           /* select count(*) into v_temp from onedata_wa.REF 
            where ref_typ_id = 80 --and ref_nm = ihook.getColumnValue(row_ori, 'DOC_NM') --and ref_desc = ihook.getColumnValue(row_ori, 'DOC_TXT')
            and item_id = ihook.getColumnValue(row_ori, 'SRC_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'SRC_VER_NR');
            if (v_temp > 0) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Preferred Question Text already exists for CDE.');
            end if;*/
        end if;

   if (ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Long Name is missing.' || chr(13) );                      
                v_val_ind := false;   
        end if;
-- Jira 3075 user no longer imports ai long name
--        for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
--        and Item_nm <> ihook.getColumnValue(row_ori, 'SPEC_LONG_NM')) loop
--                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: AI Public ID Does not match Imported Name: ' || ihook.getColumnValue(row_ori, 'SPEC_LONG_NM') || chr(13) );                      
--                v_val_ind := false;   
--        end loop;
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
--  if (v_val_ind = true) then
--          select count(*) into v_temp from alt_nms where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
--         and nm_desc = ihook.getColumnValue(row_ori, 'NM_DESC') and nm_typ_id = ihook.getColumnValue(row_ori, 'NM_TYP_ID') and cntxt_item_id  = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
--         and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')  ;
--         if (v_temp > 0) then
--                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'DUPLICATE');
--                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Reference Doc already exists.');                      
--              v_val_ind := false;
--        end if;
-- end if;
 -- duplicate in the database    jira 3075 
  if (v_val_ind = true) then
          select count(*) into v_temp from ref where item_id = ihook.getColumnValue(row_ori, 'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')  
         and ref_nm = ihook.getColumnValue(row_ori, 'NM_DESC') and ref_typ_id = ihook.getColumnValue(row_ori, 'NM_TYP_ID') and nci_cntxt_item_id  = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
         and nci_cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') and ref_desc = ihook.getColumnValue(row_ori, 'DOC_TXT')  ;
         if (v_temp > 0) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'DUPLICATE');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Reference Doc already exists.');                      
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
      and ihook.getColumnValue(row_to_comp, 'DOC_TXT') = ihook.getColumnValue(row_ori, 'DOC_TXT')
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
        elsif (v_val_ind = true) then
            if (v_mode = 'V') then
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');    
            elsif (v_mode = 'C') then
                ihook.setColumnValue(row_ori, 'NM_ID', -1);
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
                rowins.extend; rowins(rowins.last) := row_ori;
            end if;
        end if;
    rows.extend; rows(rows.last) := row_ori;
  end if; 

end loop;
    action := t_actionrowset(rows, 'Reference Document Import', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
        if (v_mode = 'C') then
            action := t_actionrowset(rowins, 'References (for hook insert)', 2,10,'insert');
            actions.extend;
            actions(actions.last) := action;
        end if;
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

/*
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
*/
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
   v_oc_str varchar2(4000);
v_prop_str varchar2(4000);
   actions t_actions := t_actions();
   row_to_comp t_row;
   v_stus varchar2(64);
   v_dec_fnd integer;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    rows := t_rows();

    for i in 1..hookinput.originalRowset.rowset.count loop

        row_ori := hookInput.originalRowset.rowset(i);
        if (ihook.getColumnValue (row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
            v_val_ind := true;
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', '');
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
            ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID_FND', '');
            ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR_FND', '' );

            if (v_mode <> 'V' and ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'VALIDATED') then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'Please validate before create/update' || chr(13));
                v_val_ind := false;
            end if;
        
            if (v_mode = 'C' and ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is not null) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'DEC specified. Please run Update DEC.' || chr(13));
                v_val_ind := false;
            end if;
            
            if (v_mode  in ('U','N') and ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'DEC ID/Ver not specified. Please check selection.' || chr(13));
                v_val_ind := false;
            end if;
         
            if (v_mode ='N' and ihook.getColumnValue(row_ori, 'NEW_VER_NR') is null) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'New version not specified. Please check selection.' || chr(13));
                v_val_ind := false;
            end if;
        
            if (v_mode ='U' and ihook.getColumnValue(row_ori, 'NEW_VER_NR') is not null) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'Cannot update DEC with new version specified.' || chr(13));
                v_val_ind := false;
            end if;
        
          if (v_mode ='N' and ihook.getColumnValue(row_ori, 'NEW_VER_NR') is not null and ihook.getColumnValue(row_ori, 'NEW_VER_NR') <= nvl(ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'),1)) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', 'New version should be greater than current version.' || chr(13));
                v_val_ind := false;
            end if;
        
            -- Specific DEC should be valid
            if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is not null and v_mode in ('U','N')) then --specifies intent to update/version
                select count(*) into v_dec_fnd from de_conc where ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') = de_conc.item_id and ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR') = de_conc.ver_nr;--jira 3149 execute update instead
                if (v_dec_fnd = 0) then
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Invalid DEC ID/Ver: ' || ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') || 'v' || ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'));
                    v_val_ind:= false;
                else
                    v_item_id := ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID');
                    v_ver_nr := ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR');
                    select admin_stus_nm_dn into v_stus from admin_item where ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') = item_id and ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR') = ver_nr;
                end if;
            end if;
        
            -- parse concepts
            if (v_val_ind = true and ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
                ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),1, row_ori);
            end if;
            if (v_val_ind = true and ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then 
                ConceptParseDEC(ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2'),2, row_ori);
            end if;
        
            if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'ERRORS') then
                v_val_ind:= false;
            end if;

            -- If no OC or Prop Concept 1 not found
            if (ihook.getColumnValue(row_ori, 'CNCPT_1_ITEM_ID_1') is null or ihook.getColumnValue(row_ori, 'CNCPT_2_ITEM_ID_1') is null) then
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: OC or PROP missing.' || chr(13));
                v_val_ind:= false;
            end if;
     
            if (ihook.getColumnValue(row_ori, 'IMP_ORIGIN') is not null and   ihook.getColumnValue(row_ori, 'ORIGIN_ID') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Specified Origin is invalid.' || chr(13));
                v_val_ind  := false;
            end if;
      
            if (   ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') is null and v_mode = 'C' ) then --dec id specifies update
                ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || 'ERROR: DEC Conceptual Domain is missing.' || chr(13));
                v_val_ind:= false;
            end if;
     
        ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
 
        if (v_val_ind = true)    then -- C
        --    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
            v_val_ind := true;
            nci_dec_mgmt.createValAIWithConcept(row_ori, 1,5,'V', 'DROP-DOWN', actions) ;
            nci_dec_mgmt.createValAIWithConcept(row_ori, 2,6,'V', 'DROP-DOWN', actions) ;

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
        --    nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind, v_usr_id);
            ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_1', nci_11179_2.getCncptStrFromForm (row_ori, 5,1));
            ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_2', nci_11179_2.getCncptStrFromForm (row_ori, 6,2));


            if (   ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null and ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null) then -- B
          
            select cncpt_concat into v_oc_str from nci_admin_item_ext where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and ver_nr= ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
            select cncpt_concat into v_prop_str from nci_admin_item_ext where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and ver_nr= ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR');
            for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
                for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
                    for cur in (select de_conc.* , ai.cntxt_nm_dn from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
                    prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and
                    cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR') and
                    de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr and ai.item_id <> nvl(ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID'),0)
                    ) loop
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue (row_ori, 'CTL_VAL_MSG') || 'ERROR: Duplicate DEC found in same context: ' || cur.item_id || 'v' || cur.ver_nr ||  ' '||  cur.cntxt_nm_dn || chr(13));
                    ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID_FND',  cur.item_id );
                    ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR_FND',  cur.ver_nr );
                   -- ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID',  cur.item_id );
                   -- ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR',  cur.ver_nr );
                     v_val_ind:= false;

                    end loop;
                end loop;
              end loop;
              -- warning if in another context
              if (v_val_ind = true) then --A
              for oc_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_oc_str and ai.admin_item_typ_id = 5) loop
                for prop_cur in (select ai.item_id, ai.ver_nr from admin_item ai, nci_admin_item_ext e where ai.item_id = e.item_id and ai.ver_nr = e.ver_nr and e.cncpt_concat = v_prop_str and ai.admin_item_typ_id = 6) loop
                    for cur in (select de_conc.*, ai.cntxt_nm_dn from de_conc, admin_item ai where obj_cls_item_id =  oc_cur.item_id and obj_cls_ver_nr =  oc_cur.ver_nr and
                    prop_item_id = prop_cur.item_id and prop_ver_nr =  prop_cur.ver_nr and             de_conc.item_id = ai.item_id and de_conc.ver_nr = ai.ver_nr 
                    and ai.item_id <> nvl(ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID'),0)
                    ) loop
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Duplicate DEC found in other Context: ' || cur.item_id || 'v' || cur.ver_nr || ' '||  cur.cntxt_nm_dn || chr(13));
                    ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID_FND',  cur.item_id );
                    ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR_FND',  cur.ver_nr );
                                     -- v_val_ind:= false;

              end loop;
              end loop;
              end loop;
              end if; -- A
            end if; -- B


            v_dup_ind := false;    
            for k in i+1..hookinput.originalrowset.rowset.count loop
                row_to_comp := hookinput.originalrowset.rowset(k);
                if (ihook.getColumnValue(row_to_comp, 'ITEM_1_NM') = ihook.getColumnValue(row_ori, 'ITEM_1_NM') and ihook.getColumnValue(row_to_comp, 'ITEM_2_NM') = ihook.getColumnValue(row_ori, 'ITEM_2_NM')) then
                    v_val_ind := false;
                    v_dup_ind := true;
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                end if;
            end loop;
        
            ihook.setColumnValue(row_ori, 'GEN_DE_CONC_NM',ihook.getColumnValue(row_ori,'ITEM_1_NM') ||  ' ' || ihook.getColumnValue(row_ori,'ITEM_2_NM') ) ;
            -- Check if DEC is a duplicate. Removed Context from the test as per Denise.
            if (v_dup_ind = true) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr );           
            end if;
        end if;     -- C
        
        if (v_val_ind = false) then 
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
         else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',nvl( ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'), 'No Errors'));                      
        end if;
    
        if (v_stus like '%RETIRED%') then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'WARNING: DEC is Retired.' || chr(13));
        elsif (v_stus like '%RELEASED%') then --jira 3284
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'WARNING: DEC is RELEASED.' || chr(13));
        end if;
    
        if  v_mode in ('C','U','N') and v_val_ind = true then -- X
   
            rows := t_rows();
            nci_dec_mgmt.createValAIWithConcept(row_ori , 1,5,'C','DROP-DOWN',actions); -- OC
            nci_dec_mgmt.createValAIWithConcept(row_ori , 2,6,'C','DROP-DOWN',actions); -- Property

            IF (v_val_ind = true and v_mode = 'C')  THEN  
                nci_dec_mgmt.createDECImport(row_ori, actions); 
            end if;
            if (v_val_ind = true and v_mode = 'U') THEN
                nci_dec_mgmt.updateDECImport(row_ori, actions, true, v_item_id, v_ver_nr); 
            end if;
            if (v_val_ind = true and v_mode = 'N') THEN
                nci_dec_mgmt.createVersionDECImport(row_ori, actions, v_item_id, v_ver_nr, v_usr_id); 
            end if;
        end if; --X
   else -- processed
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'Row already processed.');
   end if; -- only if not processed     
        rows.extend; rows(rows.last) := row_ori;
 
end loop;

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
    nci_dec_mgmt.spDECValCreateImport(row_ori, 'V', actions, v_val_ind, v_usr_id);
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

procedure spPostCDEUpdateImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    row          t_row;
    row_ori t_row;
    
action t_actionRowset;
v_item_id number;
v_ver_nr number(4,2);
v_de_conc_id number;
v_de_conc_ver_nr number;
v_cnt number;
v_sql varchar2(4000);
v_col varchar2(400);
v_var varchar2(400);
v_sql_de varchar2(4000);
v_col_de varchar2(400);
v_var_de varchar2(400);
v_desc varchar2(4000);
v_cntxt_id number;
v_cntxt_ver_nr number(4,2);
v_admin_notes varchar2(4000);
v_orig number;
v_pqt varchar2(4000);
v_vd_id number;
v_vd_ver_nr number(4,2);
v_cde_fnd number;
v_item_nm varchar2(400);
v_item_long_nm varchar2(64);
v_val_ind boolean;
v_derv_mthd varchar2(4000);
v_derv_typ number(38,0);
v_derv_rul varchar2(4000);
v_derv_rul_id number;
v_derv_rul_ver_nr number(4,2);
v_concat_char varchar2(20);
v_admin_stus number(38,0);
v_regstr_stus number(38,0);
v_chng_desc varchar2(4000);
v_de_nm varchar2(400);
v_de_def varchar2(4000);
v_vd_nm varchar2(400);
v_vd_def varchar2(4000);
sys_gen_ind boolean;
actions t_actions := t_actions();

begin
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    
    v_val_ind := true;
    sys_gen_ind := false;
    
if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
    if (ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
        ihook.setColumnValue(row_ori,'CTL_VAL_MSG','');
        ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');
    end if;
    if (ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') is not null and ihook.getColumnValue(row_ori, 'UOM_ID') is not null) then
        select count(*) into v_cnt from vw_de where item_id = ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') and ver_nr = ihook.getColumnValue(row_ori, 'UOM_ID');
        if (v_cnt < 1) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Invalid CDE ID/Version combo.');
        else
            ihook.setColumnValue(row_ori, 'IMP_UPD_DEC_ID', ihook.getColumnValue(row_ori, 'CREAT_CDE_ID'));
            ihook.setColumnValue(row_ori, 'IMP_UPD_DEC_VER', ihook.getColumnValue(row_ori, 'UOM_ID'));
        end if;
    end if;
    
    if (ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') is null or ihook.getColumnValue(row_ori, 'UOM_ID') is null or ihook.getColumnValue(row_ori, 'UOM_ID') = '') then
        if (ihook.getColumnValue(row_ori, 'UOM_ID') is null and ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') is not null) then
            select ver_nr into v_ver_nr from admin_item where admin_item_typ_id = 4 and item_id = ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') and CURRNT_VER_IND = 1;
            if (v_ver_nr is not null) then
                ihook.setColumnValue(row_ori, 'IMP_UPD_DEC_VER', v_ver_nr);
                ihook.setColumnValue(row_ori, 'IMP_UPD_DEC_ID', ihook.getColumnValue(row_ori, 'CREAT_CDE_ID'));
                ihook.setColumnValue(row_ori, 'UOM_ID', v_ver_nr);
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'IMPORTED');
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: CDE Version not specified. Set to latest version: ' || v_ver_nr);
            else
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'CDE ID or Version missing.');  
            end if;
        end if;   
    elsif (v_val_ind = true) then
        v_item_id := ihook.getColumnValue(row_ori, 'CREAT_CDE_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'UOM_ID');
        select count(*) into v_cde_fnd from de where item_id = v_item_id and ver_nr = v_ver_nr; 
        if (v_cde_fnd < 1) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Invalid CDE ID/Ver combination.');
        else --cde found, auto-populate null fields
        
            select ai.admin_notes, ai.item_desc, ai.item_nm, ai.origin_id, ai.item_long_nm, ai.admin_stus_id, ai.regstr_stus_id, ai.cntxt_item_id, ai.cntxt_ver_nr, ai.chng_desc_txt, de.de_conc_item_id, de.de_conc_ver_nr, de.pref_quest_txt, de.val_dom_item_id, de.val_dom_ver_nr, de.derv_mthd, de.derv_rul, de.derv_typ_id, de.derv_rul_item_id, de.derv_rul_ver_nr, de.concat_char
            into v_admin_notes, v_desc, v_item_nm, v_orig, v_item_long_nm, v_admin_stus, v_regstr_stus, v_cntxt_id, v_cntxt_ver_nr, v_chng_desc, v_de_conc_id, v_de_conc_ver_nr, v_pqt, v_vd_id, v_vd_ver_nr, v_derv_mthd, v_derv_rul, v_derv_typ, v_derv_rul_id, v_derv_rul_ver_nr, v_concat_char
            from admin_item ai, de 
            where ai.item_id = v_item_id and ai.ver_nr = v_ver_nr and de.item_id = v_item_id and de.ver_nr = v_ver_nr;

--            if (v_admin_stus = 75) then --released, don't allow update
--                v_val_ind := false;
--                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'CDE is RELEASED. Update cannot be performed.');
--            end if;
--            
--            if (v_regstr_stus = 11) then
--                v_val_ind := false;
--                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'CDE is RETIRED ARCHIVED. Update cannot be performed.');
--            end if;
     --   if (v_val_ind = true) then
            if (ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') is not null) then --admin notes
                v_admin_notes := ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG') || ' ' || v_admin_notes;
            end if;
            if (ihook.getColumnValue(row_ori, 'ITEM_1_DEF') is not null) then --change description
                v_chng_desc := v_chng_desc || ' ' || ihook.getColumnValue(row_ori, 'ITEM_1_DEF');
            end if;
            
            --dec and vd processing
            
            if (ihook.getColumnValue(row_ori, 'ITEM_1_ID') is null) then -- set found DEC to CDEs current DEC
                ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID', v_de_conc_id);
                ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR', v_de_conc_ver_nr);
            end if;
            if (ihook.getColumnValue(row_ori, 'ITEM_2_ID') is null) then -- set found VD to CDEs current VD
                ihook.setColumnValue(row_ori, 'VAL_DOM_ITEM_ID', v_vd_id);
                ihook.setColumnValue(row_ori, 'VAL_DOM_VER_NR', v_vd_ver_nr);
            end if;
            -- if one is specified, then update certain fields if not manually entered
-----------------------------------
--            if (ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null or ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null) then
--                if (ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null and ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') is not null) then
--                    select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
--                    if (v_cnt < 1) then
--                        v_val_ind := false;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid DEC ID/Ver combination.');
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                    else
--                        select item_id, ver_nr, item_nm, item_desc into v_de_conc_id, v_de_conc_ver_nr, v_de_nm, v_de_def from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
--                    end if;
--                    --code below sets the dec version to latest if not specified in import
--                elsif (ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null and ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') is null) then
--                    select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and admin_item_typ_id = 2;
--                    if (v_cnt < 1) then
--                        v_val_ind := false;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid DEC ID/Ver combination.');
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                    else
--                        select item_id, ver_nr, item_nm, item_desc into v_de_conc_id, v_de_conc_ver_nr, v_de_nm, v_de_def from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and CURRNT_VER_IND = 1;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'WARNING: DEC Version not specified. Set to latest version.');
--                    end if;
--                else
--                    select item_nm, item_desc into v_de_nm, v_de_def from admin_item where item_id = v_de_conc_id and ver_nr = v_de_conc_ver_nr;
--                end if;
--                if (ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null and ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR') is not null) then
--                    select count(*) into v_cnt from admin_item where item_id = ihook.getColumnVAlue(row_ori, 'ITEM_2_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR');
--                    if (v_cnt < 1) then
--                        v_val_ind := false;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid VD ID/Ver combination.');
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                    else
--                        select item_id, ver_nr, item_nm, item_desc into v_vd_id, v_vd_ver_nr, v_vd_nm, v_vd_def from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and ver_nr = ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR');
--                    end if;
--                elsif (ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null and ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR') is null) then
--                    select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and admin_item_typ_id = 3;
--                    if (v_cnt < 1) then
--                        v_val_ind := false;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid VD ID/Ver combination.');
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                    else
--                        select item_id, ver_nr, item_nm, item_desc into v_vd_id, v_vd_ver_nr, v_vd_nm, v_vd_def from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and CURRNT_VER_IND = 1;
--                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'WARNING: VD Version not specified. Set to latest version.');
--                    end if;
--                else
--                   select item_nm, item_desc into v_vd_nm, v_vd_def from admin_item where item_id = v_vd_id and ver_nr = v_vd_ver_nr; 
--                end if;
--                
--                if (ihook.getColumnValue(row_ori, 'CDE_ITEM_DESC') is null ) then
--                    v_desc := v_de_def || ':' || v_vd_def;
--                end if;
--                
--                if (ihook.getColumnValue(row_ori, 'CDE_ITEM_NM') is null) then
--                    v_item_nm := v_de_nm || ' ' || v_vd_nm;
--                end if;
--                
--                if (ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') is null and v_item_long_nm is not null) then
--                    if (sys_gen_ind = true) then
--                        v_item_long_nm := v_de_conc_id || 'v' || to_char(v_de_conc_ver_nr,'fm99D00') || ':' || v_vd_id || 'v' || to_char(v_vd_ver_nr,'fm99D00');
--                    end if;
--                end if;
--            end if;
----------------------------------
            
            --ihook.setColumnValue(row_ori, 'CDE_ITEM_NM', nvl(ihook.getColumnValue(row_ori, 'CDE_ITEM_NM'), v_item_nm));
            --ihook.setColumnValue(row_ori, 'CDE_ITEM_LONG_NM', nvl(ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM'), v_item_long_nm));
           -- ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', nvl(ihook.getColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG'), v_admin_notes));
            ihook.setColumnValue(row_ori, 'ITEM_1_DEF', v_chng_desc);
            ihook.setColumnValue(row_ori, 'CTL_IMPORT_VAL_MSG', v_admin_notes);
            --ihook.setColumnValue(row_ori, 'CDE_ITEM_DESC', nvl(ihook.getColumnValue(row_ori, 'CDE_ITEM_DESC'), v_desc));
            --ihook.setColumnValue(row_ori, 'ORIGIN_ID', nvl(ihook.getColumnValue(row_ori, 'ORIGIN_ID'), v_orig));
            --ihook.setColumnValue(row_ori, 'ITEM_1_ID', nvl(ihook.getColumnValue(row_ori, 'ITEM_1_ID'), v_de_conc_id));
            --ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', nvl(ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR'), v_de_conc_ver_nr));
            --ihook.setColumnValue(row_ori, 'PREF_QUEST_TXT', nvl(ihook.getColumnValue(row_ori, 'PREF_QUEST_TXT'), v_pqt));
            --ihook.setColumnValue(row_ori, 'ITEM_2_ID', nvl(ihook.getColumnValue(row_ori, 'ITEM_2_ID'), v_vd_id));
            --ihook.setColumnValue(row_ori, 'ITEM_2_VER_NR', nvl(ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR'), v_vd_ver_nr));
            --ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID', nvl(ihook.getColumnValue(row_ori, 'ITEM_1_ID'), v_de_conc_id));
            --ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR', nvl(ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR'), v_de_conc_ver_nr));
            --ihook.setColumnValue(row_ori, 'VAL_DOM_ITEM_ID', nvl(ihook.getColumnValue(row_ori, 'ITEM_2_ID'), v_vd_id));
            --ihook.setColumnValue(row_ori, 'VAL_DOM_VER_NR', nvl(ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR'), v_vd_ver_nr));
            --ihook.setColumnValue(row_ori, 'DTTYPE_ID', nvl(ihook.getColumnValue(row_ori, 'DTTYPE_ID'), v_derv_typ));
            --ihook.setColumnValue(row_ori, 'ITEM_3_ID', nvl(ihook.getColumnValue(row_ori, 'ITEM_3_ID'), v_derv_rul_id));
            --ihook.setColumnValue(row_ori, 'ITEM_3_VER_NR', nvl(ihook.getColumnValue(row_ori, 'ITEM_3_VER_NR'), v_derv_rul_ver_nr));
            --ihook.setColumnValue(row_ori, 'ITEM_2_DEF', nvl(ihook.getColumnValue(row_ori, 'ITEM_2_DEF'), v_derv_rul));
            --ihook.setColumnValue(row_ori, 'ITEM_3_DEF', nvl(ihook.getColumnValue(row_ori, 'ITEM_3_DEF'), v_derv_mthd));
            --ihook.setColumnValue(row_ori, 'ADMIN_STUS_ID', nvl(ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID'), v_admin_stus));
            --ihook.setColumnValue(row_ori, 'REGSTR_STUS_ID', nvl(ihook.getColumnValue(row_ori, 'REGSTR_STUS_ID'), v_regstr_stus));
            ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', nvl(ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID'), v_cntxt_id));
            ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', nvl(ihook.getColumnValue(row_ori, 'CNTXT_VER_NR'), v_cntxt_ver_nr));
        end if;
     --   end if;
        
    end if;


    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'CDE Update', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    --nci_util.debugHook('GENERAL',v_data_out);
    
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

procedure spPostDECUpdateImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    v_dec_fnd number;
    v_item_nm varchar2(255);
    v_item_long_nm varchar2(255);
    v_oc varchar2(255);
    v_prop varchar2(255);
    v_oc_ver number(4,2);
    v_prop_ver number(4,2);
    v_cntxt_id number;
    v_cntxt_ver number(4,2);
    action t_actionRowset;
    actions t_actions := t_actions();
begin

    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;

    row_ori := hookInput.originalRowset.rowset(1);
    v_val_ind := true;
    
    /*
    1. check that dec id/ver combo is valid
    2. check for null fields
        - if null, then retrieve and populate null fields
    */
 if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
    if (ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
        ihook.setColumnValue(row_ori,'CTL_VAL_MSG','');
        ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');
    end if;
    
    if (ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') is null or ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR') is null) then
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        v_val_ind := false;
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'DEC ID or Version missing.');   
    else
        v_item_id := ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR');
        select count(*) into v_dec_fnd from de_conc where item_id = v_item_id and ver_nr = v_ver_nr; 
        if (v_dec_fnd = 0) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Invalid DEC ID/Ver combination.');
        elsif (v_dec_fnd = 1) then --def found, auto-populate null fields
            select item_nm, item_long_nm into v_item_nm, v_item_long_nm from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
         /*   if (ihook.getColumnValue(row_ori, 'DEC_ITEM_NM') is null) then
                ihook.setColumnValue(row_ori, 'DEC_ITEM_NM', v_item_nm);
            end if;
            if (ihook.getColumnValue(row_ori, 'DEC_ITEM_LONG_NM') is null) then
                ihook.setColumnValue(row_ori, 'DEC_ITEM_LONG_NM', v_item_long_nm);
            end if;
            */
                        --if both OC/prop codes are blank, then pull back existing long/short name so that they don't get overwritten
            if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is null and ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is null) then 
                if (ihook.getColumnValue(row_ori, 'DEC_ITEM_NM') is null) then
                    ihook.setColumnValue(row_ori, 'DEC_ITEM_NM', v_item_nm);
                end if;
                if (ihook.getColumnValue(row_ori, 'DEC_ITEM_LONG_NM') is null) then
                    ihook.setColumnValue(row_ori, 'DEC_ITEM_LONG_NM', v_item_long_nm);
                end if;
            end if;
            if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') is null) then
                select cncpt_concat into v_oc from nci_admin_item_ext where item_id = (select obj_cls_item_id from de_conc where item_id = v_item_id and ver_nr = v_ver_nr);
                ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_1', REPLACE(v_oc, ':', ' '));
            end if;
            if (ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_2') is null) then
                select cncpt_concat into v_prop from nci_admin_item_ext where item_id = (select prop_item_id from de_conc where item_id = v_item_id and ver_nr = v_ver_nr);
                ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_2', REPLACE(v_prop, ':', ' '));
            end if;
            if (ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') is null) then
                select cntxt_item_id, cntxt_ver_nr into v_cntxt_id, v_cntxt_ver from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
                ihook.setColumnValue(row_ori, 'CNTXT_ITEM_ID', v_cntxt_id);
                ihook.setColumnValue(row_ori, 'CNTXT_VER_NR', v_cntxt_ver);
            end if;
            --raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'));
        end if;
       -- raise_application_error(-20000, ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'));
    
    end if;

    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;

    action := t_actionrowset(rows, 'DEC Update', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL',v_data_out);


end;

procedure spPostModelImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2) -- Not used anymore
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
/*
for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    idx := 1;
    
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
 
        if (ihook.getColumnValue(row_ori, 'CREATED_MDL_ITEM_ID') is not null or ihook.getColumnValue(row_ori, 'SRC_MDL_VER') is not null) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'WARNING: Record contains Model ID/Ver, the Update object should be used instead');
            --raise_application_error(-20000, 'Imported file contains Model ID/Ver, the Update object should be used instead.');
        end if;
        
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    end if;
end loop;

    action := t_actionrowset(rows, 'Model Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
*/
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
    
    -- enumerated by reference PV/VM indicator
    
     if (upper(ihook.getColumnValue(row_ori, 'IMP_CREAT_PV_VM') ) = 'YES') then
      ihook.setColumnValue(row_ori, 'CREAT_PV_VM', 1);
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



procedure spPostRTImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
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
    elsif (ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM') is not null and ihook.getColumnValue(row_ori, 'MOD_NM') = 'I') then
        ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_3', ihook.getColumnValue(row_ori, 'PRMRY_REP_TERM'));
    end if;
        nci_vd.RTImportPost(row_ori, 3,7,'V', 'STRING', actions);
    ihook.setColumnValue(row_ori, 'MOD_NM', 'F') ;
    rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
--raise_application_error(-20000,'Deepali ' || ihook.getColumNValue(row_ori,'STG_AI_ID'));
    action := t_actionrowset(rows, 'Rep Term Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
 end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--nci_util.debugHook('GENERAL',v_data_out);


end;

procedure spCreatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
    copyInput t_hookInput;

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
    copyInput := ihook.getHookInput(v_data_in);
    
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
       ihook.setColumnValue(row, 'ITEM_1_ID', ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
   --    if (ihook.getColumnValue(row_ori, 'REF_BTCH_NBR') is not null) then      raise_application_error(-20000, ihook.getColumnValue(row, 'ITEM_1_ID')); end if;
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
procedure spUpdatePVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
    copyInput t_hookInput;

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
   row_pvvms t_rows;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    copyInput := ihook.getHookInput(v_data_in);
    
      rows := t_rows();
 rowais := t_rows();
 rowiucs := t_rows();
 rowcdvms := t_rows();
   rowpvs :=  t_rows();
   rowaltnms := t_rows();
   row_pvvms := t_rows();
 cnt := least(hookinput.originalRowset.rowset.count,1000);
--raise_application_error(-20000,cnt);

for i in 1..cnt loop
    row_ori := hookInput.originalRowset.rowset(i);
    v_val_ind := true;
    ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
   if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'VALIDATED') then
       --nci_pv_vm.spPVVMImport ( row_ori,actions ,rowais, rowiucs,rowcdvms, rowpvs, rowaltnms);
       spPVVMUpdate(row_ori, actions,rowais,rowiucs,rowcdvms,rowpvs,rowaltnms,row_pvvms);
       row := t_row();
       ihook.setColumnValue(row, 'ITEM_1_ID', ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
   --    if (ihook.getColumnValue(row_ori, 'REF_BTCH_NBR') is not null) then      raise_application_error(-20000, ihook.getColumnValue(row, 'ITEM_1_ID')); end if;
       ihook.setColumnValue(row,'CTL_VAL_MSG', 'PV/VM updated successfully.');
       ihook.setColumnValue(row,'CTL_VAL_STUS', 'PROCESSED');
       ihook.setColumnValue(row,'STG_AI_ID',  ihook.getColumnValue(row_ori,'STG_AI_ID'));
    rows.extend; rows(rows.last) := row;
       
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
--    
--        action := t_actionrowset(rowcdvms, 'Value Meanings (No FK)', 2,10,'insert');
--          actions.extend;
--          actions(actions.last) := action;
--
--          action := t_actionrowset(rowpvs, 'Permissible Values (No FK)', 2,19,'insert');
--           actions.extend;
--           actions(actions.last) := action;
--
--      action := t_actionrowset(rowaltnms, 'Alternate Names', 2,23,'insert');
--           actions.extend;
--           actions(actions.last) := action;

          action := t_actionrowset(row_pvvms, 'Permissible Values (Edit AI)', 2,19,'update');
           actions.extend;
           actions(actions.last) := action;
   action := t_actionrowset(rows, 'PV VM Import (No FK)', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
      hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spPVVMUpdate ( row_ori in out t_row, actions in out t_actions, rowais in out t_rows, rowiucs in out t_rows, rowcdvms in out t_rows, rowpvs in out t_rows, rowaltnms in out t_rows, row_pvvms in out t_rows)
AS
 
  forms t_forms;
  form1 t_form;

  row t_row;
  rows  t_rows;
  rowset            t_rowset;
  row_pvvm t_row;
  --row_pvvms t_rows;
  rowset_pvvms t_rowset;
  row_vm_cd t_row;
  v_str  varchar2(255);
 v_nm  varchar2(255);
 v_item_id number;
 v_ver_nr number(4,2);
  cnt integer;
k integer;
  action t_actionRowset;
  i integer := 0;
  v_typ  varchar2(50);
  v_temp integer;
  is_valid boolean;
  v_item_typ_glb integer;
  v_pv  varchar2(255);
  v_vm_nm varchar2(255);
  v_cur_item_id number;
  --jira 3357:reuse vm if exists
  v_vm_txt varchar2(255);
  v_vm_cnt integer;
  v_vm_item_id number;
  v_vm_ver_nr number (4,2);
  v_cdvm_ind integer;
  v_tmp_vm_id number;
  v_pv_val_id number;
begin
    v_item_typ_glb := 53;
    v_cdvm_ind := 1;
        row := t_row();        rows := t_rows();
        row_pvvm := t_row();   row_pvvms := t_rows();
        row_vm_cd := t_row();
        k := 1;


    v_typ := upper(ihook.getColumnValue(row_ori, 'VM_STR_TYP'));
    v_ver_nr := 1; --default

    select max(item_id) into v_cur_item_id from admin_item where admin_item_typ_id <> 8;

    case
    when v_typ = 'CONCEPTS' then
        if (ihook.getColumnValue(row_ori, 'REF_BTCH_STR') is null) then --no reference in the batch, get new ID
--        nci_dec_mgmt.createValAIWithConcept(row_ori , 1,v_item_typ_glb ,'C','DROP-DOWN',actions); -- Vm
            nci_dec_mgmt.createValAIWithConceptRow(row_ori , 1,v_item_typ_glb ,'C','DROP-DOWN',rowais, rowiucs); -- Vm
       

            v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
            v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
            update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID'), ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            commit;
            
            --updated code
            --nci_dec_mgmt.createValAIWithConcept(row_ori , 1,v_item_typ_glb ,'O','DROP-DOWN',actions);
               --   raise_application_error(-20000, ihook.getColumnValue(rowform, 'ITEM_1_ID'));
            select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
            ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
            ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
            ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
            ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
        else
        --parse ref_btch_str for referenced seq ids, then iterate over each seq id and check if item_1_id is set
            --if item_1_id is not set, create the vm id
            --if item_1_id is set, reuse it
            v_vm_item_id := nci_pv_vm.parsePVVMRefStr(ihook.getColumnValue(row_ori, 'REF_BTCH_STR'), ',', row_ori);
          --  raise_application_error(-20000, v_vm_item_id);
            
            if (v_vm_item_id = 0) then
                nci_dec_mgmt.createValAIWithConceptRow(row_ori , 1,v_item_typ_glb ,'C','DROP-DOWN',rowais, rowiucs); -- Vm
                v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
                v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
                update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID'), ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                commit;
                select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
                ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
                ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
            else
                v_cdvm_ind := 0;
           -- raise_application_error(-20000, v_vm_item_id);
                v_item_id := v_vm_item_id;
                ihook.setColumnValue(row_ori, 'GEN_STR', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
                ihook.setColumnValue(row_ori,'ITEM_1_ID', v_item_id);
                ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', 1);
            update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            update nci_stg_pv_vm_import set ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            commit;
                select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', 1);
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
                ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
                ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
           -- raise_application_error(-20000, ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
           end if;

        end if;
     when v_typ = 'TEXT' then

   --     raise_application_error(-20000, v_vm_cnt);
   --  raise_application_error(-20000,'HEre' || nvl(ihook.getColumnValue(row_ori, 'VM_SPEC_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')));VW_SPEC_DEF
       -- nci_dec_mgmt.createAIWithoutConcept(row_ori , 1, 53, ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),nvl(ihook.getColumnValue(row_ori, 'VW_SPEC_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')),'C', actions);
        if (ihook.getColumnValue(row_ori, 'REF_BTCH_STR') is null) then
            nci_dec_mgmt.createAIWithoutConcept(row_ori , 1, 53, ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),nvl(ihook.getColumnValue(row_ori, 'VW_SPEC_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')),'C',
            actions);
            v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
            v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
            ihook.setColumnValue(row_ori, 'GEN_STR', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
            update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            update nci_stg_pv_vm_import set ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            commit;
                select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
                ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
                ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
        else --jira 3357; vm already exists, reuse id and ver, do not try to create a second vm/cd relationship
        --raise_application_error(-20000, ihook.getColumnValue(row_ori, 'REF_BTCH_STR'));
        v_vm_item_id := nci_pv_vm.parsePVVMRefStr(ihook.getColumnValue(row_ori, 'REF_BTCH_STR'), ',', row_ori);
        
        if (v_vm_item_id = 0) then
                nci_dec_mgmt.createAIWithoutConcept(row_ori , 1, 53, ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'),nvl(ihook.getColumnValue(row_ori, 'VW_SPEC_DEF'), ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1')),'C',
            actions);
                v_item_id := ihook.getColumnValue(row_ori,'ITEM_1_ID');
                v_ver_nr :=  ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR');
                update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID'), ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                commit;
            else
                v_cdvm_ind := 0;
           --raise_application_error(-20000, v_vm_item_id);
                v_item_id := v_vm_item_id;
                ihook.setColumnValue(row_ori, 'GEN_STR', ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1'));
                ihook.setColumnValue(row_ori,'ITEM_1_ID', v_item_id);
                ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', 1);
            update nci_stg_pv_vm_import set ITEM_1_ID = ihook.getColumnValue(row_ori,'ITEM_1_ID') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            update nci_stg_pv_vm_import set ITEM_1_VER_NR = ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
            commit;
                select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', 1);
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
                ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
                ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
                ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
                ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
           -- raise_application_error(-20000, ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
           end if;
        end if;
     when v_typ = 'ID' then
        for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') and currnt_ver_ind = 1 and admin_item_typ_id = v_item_typ_glb) loop
            v_item_id := cur.item_id;
            v_ver_nr :=  cur.ver_nr;
            v_cdvm_ind := 0;
        end loop;
        select max(val_id) into v_pv_val_id from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR') and perm_val_nm = ihook.getColumnValue(row_ori, 'PERM_VAL_NM');
            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
            ihook.setColumnValue(row_pvvm, 'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
            ihook.setColumnValue(row_pvvm, 'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
            ihook.setColumnValue(row_pvvm, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'PERM_VAL_NM'));
            ihook.setColumnValue(row_pvvm, 'VAL_ID', v_pv_val_id);
            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', v_item_id);
            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', v_ver_nr);
    end case;
      
--            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
--            ihook.setColumnValue(row_pvvm, 'NCI_VAL_MEAN_VER_NR', ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR'));
--            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_ITEM_ID', ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
--            ihook.setColumnValue(row_vm_cd, 'NCI_VAL_MEAN_VER_NR', ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR'));
      -- Create PV
       

        select count(*) into v_temp from CONC_DOM_VAL_MEAN where CONC_DOM_ITEM_ID = ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID') and
        CONC_DOM_VER_NR = ihook.getColumnValue(row_ori, 'CONC_DOM_VER_NR') and NCI_VAL_MEAN_ITEM_ID = v_item_id and NCI_VAL_MEAN_VER_NR = v_ver_nr;

        
--  If VM/CONC_DOM new
        if (v_temp = 0 and v_cdvm_ind = 1) then
            row := t_row();
            ihook.setColumnValue(row,'CONC_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'CONC_DOM_ITEM_ID'));
            ihook.setColumnValue(row,'CONC_DOM_VER_NR', ihook.getColumnValue(row_ori, 'CONC_DOM_VER_NR'));
            ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
            ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', v_ver_nr);

            rowcdvms.extend;
            rowcdvms(rowcdvms.last) := row;

        end if;
        --raise_application_error(-20000, 'here');
        row := t_row();
        ihook.setColumnValue(row,'PERM_VAL_NM', nvl(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'),ihook.getColumnValue(row_ori, 'ITEM_1_NM')) );
        ihook.setColumnValue(row,'VAL_DOM_ITEM_ID', ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'));
        ihook.setColumnValue(row,'VAL_DOM_VER_NR', ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'));
        ihook.setColumnValue(row,'NCI_VAL_MEAN_ITEM_ID',  v_item_id);
        ihook.setColumnValue(row,'NCI_VAL_MEAN_VER_NR', v_ver_nr);

        ihook.setColumnValue(row,'VAL_ID',-1);
            rowpvs.extend;
            rowpvs(rowpvs.last) := row;
            
    -- VM Alternate Name
        if (ihook.getColumnValue(row_ori, 'VM_ALT_NM') is not null and ihook.getColumnValue(row_ori, 'VM_ALT_NM_TYP_ID') is not null
        and ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_ITEM_ID') is not null and ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_VER_NR') is not null and ihook.getColumnValue(row_ori, 'REF_BTCH_NBR') is null) then
        --raise_application_error(-20000, 'here2');
        -- Check if alternate name exists
        select count(*) into v_temp from alt_nms where 
         item_id = v_item_id and ver_nr = v_ver_nr 
            and nm_desc = ihook.getColumnValue(row_ori, 'VM_ALT_NM') and nm_typ_id = ihook.getColumnValue(row_ori, 'VM_ALT_NM_TYP_ID') 
            and cntxt_item_id  = ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_ITEM_ID')
             and cntxt_ver_nr = ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_VER_NR')  ;
             if (v_temp =0) then -- no alternate name found
          
        row := t_row();
        ihook.setColumnValue(row,'ITEM_ID', v_item_id );
        ihook.setColumnValue(row,'VER_NR', 1);
        ihook.setColumnValue(row,'NM_TYP_ID', ihook.getColumnValue(row_ori, 'VM_ALT_NM_TYP_ID'));
        ihook.setColumnValue(row,'NM_DESC', ihook.getColumnValue(row_ori, 'VM_ALT_NM'));
        ihook.setColumnValue(row,'CNTXT_ITEM_ID',nvl(ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_ITEM_ID'), ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID') ));
        ihook.setColumnValue(row,'CNTXT_VER_NR',nvl(ihook.getColumnValue(row_ori, 'VM_ALT_NM_CNTXT_VER_NR'),ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')) );
        ihook.setColumnValue(row,'LANG_ID', nci_11179_2.getLangID(ihook.getColumnValue(row_ori, 'VM_ALT_NM_LANG')));
      
        ihook.setColumnValue(row,'NM_ID',-1);
            rowaltnms.extend;
            rowaltnms(rowaltnms.last) := row;
    
           end if;

        end if;
        
    --PV/VM association update
        row_pvvms.extend;
        row_pvvms(row_pvvms.last) := row_pvvm;
    
        ihook.setColumnValue(row_ori, 'ITEM_1_ID', v_item_id);
        --raise_application_error(-20000, ihook.getColumnValue(row_ori, 'ITEM_1_ID'));
        ihook.setColumnValue(row_ori,'CTL_VAL_STUS',  'PROCESSED');
         ihook.setColumnValue(row_ori,'CTL_VAL_MSG',  'PV/VM created successfully.');
       
       -- Jira 1889 Remove VM ID from Validation message
       -- ihook.setColumnValue(row_ori,'CTL_VAL_MSG', 'Value Meaning ID: ' || v_item_id );

-- Jira 1889 The code below removes the VM ID from the ITEM_1_ID column if it already exists. They now want to have only one column that always has whatever the VM ID is, so comment it out.
       -- if (v_item_id <= v_cur_item_id) then
       --             ihook.setColumnValue(row_ori, 'ITEM_1_ID', '');
       --             ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', '');
    --  end if; 
        -- end if




END;

procedure spValPVVMImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
    
    copyInput t_hookInput;

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
   v_btch_ref_str varchar2(128);
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    copyInput := ihook.getHookInput(v_data_in);
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
                v_str := FormatConceptString(v_str);
                ConceptParseDEC(v_str,1, row_ori);
                ihook.setColumnValue(row_ori,'CTL_VAL_STUS','VALIDATED');   
                
            end if;           
--            if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) then
--                ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'ITEM_1_NM'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Permissible Value missing.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                --v_val_ind := false;
--            end if;
            if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VM Type missing or invalid.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                v_val_ind := false;
            end if;
  
       -- if ( ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') = v_val_dom_id and  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')= v_val_dom_ver  and v_val_ind = true) then
       v_btch_ref_str := '';
            for k in 1..hookinput.originalrowset.rowset.count loop
                row_to_comp := hookinput.originalrowset.rowset(k);
                if (ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
                and ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') 
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                --    v_val_ind := false;
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') = ihook.getColumnValue(row_ori, 'PERM_VAL_NM') or (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') is null and ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) ) then
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr ); 
                        v_val_ind := false;
    -- jira 1962
    --                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: PV shares VM with Batch Number: ' || v_batch_nbr || chr(13) || 'Run Create PV/VM for Seq ' || ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') || ', then Validate again.'  );       
                    --jira 3805: build ref string to parse over
                    elsif (ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then
                        v_btch_ref_str := v_btch_ref_str || to_char(v_batch_nbr) || ',';
                   -- raise_application_error(-20000, v_batch_nbr);
--                    elsif (ihook.getColumnValue(row_ori, 'REF_BTCH_STR') is null and ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then
--
--                        if (ihook.getColumnValue(row_to_comp, 'REF_BTCH_STR') is null) then
--                            update nci_stg_pv_vm_import set REF_BTCH_NBR = ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')
--                            where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
--                            commit;
--                        end if;
                    end if;
               --jira 3595 
                elsif (ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') --no vd id check
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then
                        v_btch_ref_str := v_btch_ref_str || to_char(v_batch_nbr) || ',';
                       
                  --      raise_application_error(-20000, 'here');
--                        if (ihook.getColumnValue(row_to_comp, 'REF_BTCH_NBR') is null) then
--                            update nci_stg_pv_vm_import set REF_BTCH_NBR = ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')
--                            where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
--                            commit;
--                            --raise_application_error(-20000, v_batch_nbr);
--                        end if;
                    end if;
                end if;
            end loop;
            --raise_application_error(-20000, v_btch_ref_str);
            if (v_btch_ref_str is not null) then
          --  raise_application_error(-20000, v_btch_ref_str);
          v_btch_ref_str := substr(v_btch_ref_str, 1, length(v_btch_ref_str)-1);
            ihook.setColumnValue(row_ori, 'REF_BTCH_STR', v_btch_ref_str);
                update nci_stg_pv_vm_import set REF_BTCH_STR = v_btch_ref_str 
                where 
                btch_nm = ihook.getColumnValue(row_ori, 'BTCH_NM') and btch_seq_nbr = ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR');
                
                --stg_ai_id = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                commit;
            end if;
     --   end if;
  
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else 
         rows.extend; rows(rows.last) := row_ori;
         spPVVMValidate(row_ori, 'I');
        end if;
        --jira 3595
--        if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) then
--            ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'ITEM_1_NM'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Permissible Value missing.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                --v_val_ind := false;
--        end if;
            
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
   CNCPT_2_ITEM_ID_1= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_1'),
        CNCPT_2_VER_NR_1= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_1'),
   CNCPT_2_ITEM_ID_2= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_2'),
        CNCPT_2_VER_NR_2= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_2'),
    CNCPT_2_ITEM_ID_3= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_3'),
        CNCPT_2_VER_NR_3= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_3'),
   CNCPT_2_ITEM_ID_4= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_4'),
        CNCPT_2_VER_NR_4= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_4'),
   CNCPT_2_ITEM_ID_5= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_5'),
        CNCPT_2_VER_NR_5= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_5'),
   CNCPT_2_ITEM_ID_6= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_6'),
        CNCPT_2_VER_NR_6= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_6'),
   CNCPT_2_ITEM_ID_7= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_7'),
        CNCPT_2_VER_NR_7= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_7'),
   CNCPT_2_ITEM_ID_8= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_8'),
        CNCPT_2_VER_NR_8= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_8'),
   CNCPT_2_ITEM_ID_9= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_9'),
        CNCPT_2_VER_NR_9= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_9'),
   CNCPT_2_ITEM_ID_10= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_10'),
        CNCPT_2_VER_NR_10= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_10'),
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
CTL_VAL_MSG=ihook.getColumnValue(row_ori,'CTL_VAL_MSG')--,
--PERM_VAL_NM=ihook.getColumnValue(row_ori, 'PERM_VAL_NM')
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

--first procedure called by PV VM Update - Validate command
procedure spValPVVMUpdate (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
    
    copyInput t_hookInput;

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
   v_btch_ref_str varchar2(128);
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    copyInput := ihook.getHookInput(v_data_in);
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
                v_str := FormatConceptString(v_str);
                ConceptParseDEC(v_str,1, row_ori);
                ihook.setColumnValue(row_ori,'CTL_VAL_STUS','VALIDATED');   
                
            end if;           

            if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VM Type missing or invalid.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                v_val_ind := false;
            end if;

       v_btch_ref_str := '';
            for k in 1..hookinput.originalrowset.rowset.count loop
                row_to_comp := hookinput.originalrowset.rowset(k);
                if (ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
                and ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') 
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                --    v_val_ind := false;
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') = ihook.getColumnValue(row_ori, 'PERM_VAL_NM') or (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') is null and ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) ) then
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr ); 
                        v_val_ind := false;
    -- jira 1962
    --                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: PV shares VM with Batch Number: ' || v_batch_nbr || chr(13) || 'Run Create PV/VM for Seq ' || ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') || ', then Validate again.'  );       
                    --jira 3805: build ref string to parse over
                    elsif (ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then
                        v_btch_ref_str := v_btch_ref_str || to_char(v_batch_nbr) || ',';
                   -- raise_application_error(-20000, v_batch_nbr);

                    end if;
               --jira 3595 
                elsif (ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') --no vd id check
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then
                        v_btch_ref_str := v_btch_ref_str || to_char(v_batch_nbr) || ',';
                       
 
                    end if;
                end if;
            end loop;
            --raise_application_error(-20000, v_btch_ref_str);
            if (v_btch_ref_str is not null) then
          --  raise_application_error(-20000, v_btch_ref_str);
          v_btch_ref_str := substr(v_btch_ref_str, 1, length(v_btch_ref_str)-1);
            ihook.setColumnValue(row_ori, 'REF_BTCH_STR', v_btch_ref_str);
                update nci_stg_pv_vm_import set REF_BTCH_STR = v_btch_ref_str 
                where 
                btch_nm = ihook.getColumnValue(row_ori, 'BTCH_NM') and btch_seq_nbr = ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR');
                
                --stg_ai_id = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                commit;
            end if;
     --   end if;
  
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else 
         rows.extend; rows(rows.last) := row_ori;
         spPVVMValidate(row_ori, 'U');
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
   CNCPT_2_ITEM_ID_1= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_1'),
        CNCPT_2_VER_NR_1= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_1'),
   CNCPT_2_ITEM_ID_2= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_2'),
        CNCPT_2_VER_NR_2= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_2'),
    CNCPT_2_ITEM_ID_3= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_3'),
        CNCPT_2_VER_NR_3= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_3'),
   CNCPT_2_ITEM_ID_4= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_4'),
        CNCPT_2_VER_NR_4= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_4'),
   CNCPT_2_ITEM_ID_5= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_5'),
        CNCPT_2_VER_NR_5= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_5'),
   CNCPT_2_ITEM_ID_6= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_6'),
        CNCPT_2_VER_NR_6= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_6'),
   CNCPT_2_ITEM_ID_7= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_7'),
        CNCPT_2_VER_NR_7= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_7'),
   CNCPT_2_ITEM_ID_8= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_8'),
        CNCPT_2_VER_NR_8= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_8'),
   CNCPT_2_ITEM_ID_9= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_9'),
        CNCPT_2_VER_NR_9= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_9'),
   CNCPT_2_ITEM_ID_10= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_10'),
        CNCPT_2_VER_NR_10= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_10'),
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
CTL_VAL_MSG=ihook.getColumnValue(row_ori,'CTL_VAL_MSG')--,
--PERM_VAL_NM=ihook.getColumnValue(row_ori, 'PERM_VAL_NM')
        where STG_AI_ID= ihook.getColumnValue(row_ori,'STG_AI_ID');
        commit;
   end if; -- only if not processed 
end loop;
    action := t_actionrowset(rows, 'PV VM Update', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
      --  hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 --nci_util.debugHook('GENERAL',v_data_out);

end;
/*
procedure spValPVVMImportOLD (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
    
    copyInput t_hookInput;

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
    copyInput := ihook.getHookInput(v_data_in);
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
--            if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) then
--                ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'ITEM_1_NM'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Permissible Value missing.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                --v_val_ind := false;
--            end if;
            if (ihook.getColumnValue(row_ori, 'VM_STR_TYP') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: VM Type missing or invalid.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
                ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                v_val_ind := false;
            end if;
  
       -- if ( ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') = v_val_dom_id and  ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')= v_val_dom_ver  and v_val_ind = true) then
            for k in i+1..hookinput.originalrowset.rowset.count loop
                row_to_comp := hookinput.originalrowset.rowset(k);
                if (ihook.getColumnValue(row_to_comp, 'VAL_DOM_ITEM_ID') = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and ihook.getColumnValue(row_to_comp, 'VAL_DOM_VER_NR') = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
                and ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') 
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                --    v_val_ind := false;
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') = ihook.getColumnValue(row_ori, 'PERM_VAL_NM') or (ihook.getColumnValue(row_to_comp, 'PERM_VAL_NM') is null and ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) ) then
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Duplicate found in the same import file. Batch Number: ' || v_batch_nbr ); 
                        v_val_ind := false;
    -- jira 1962
    --                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: PV shares VM with Batch Number: ' || v_batch_nbr || chr(13) || 'Run Create PV/VM for Seq ' || ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR') || ', then Validate again.'  );       
                    elsif (ihook.getColumnValue(row_ori, 'REF_BTCH_NBR') is null and ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then

                        if (ihook.getColumnValue(row_to_comp, 'REF_BTCH_NBR') is null) then
                            update nci_stg_pv_vm_import set REF_BTCH_NBR = ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')
                            where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                            commit;
                        end if;
                    end if;
               --jira 3595 
                elsif (ihook.getColumnValue(row_to_comp, 'CNCPT_CONCAT_STR_1') = ihook.getColumnValue(row_ori, 'CNCPT_CONCAT_STR_1') --no vd id check
                and ihook.getColumnValue(row_to_comp, 'VM_STR_TYP') = ihook.getColumnValue(row_ori, 'VM_STR_TYP')
                and ihook.getColumnValue(row_ori, 'BTCH_SEQ_NBR') <> ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')) then
                    v_batch_nbr := ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR');
                    if (ihook.getColumnValue(row_ori, 'REF_BTCH_NBR') is null and ihook.getColumnValue(row_ori, 'VM_STR_TYP') <> 'ID') then

                        if (ihook.getColumnValue(row_to_comp, 'REF_BTCH_NBR') is null) then
                            update nci_stg_pv_vm_import set REF_BTCH_NBR = ihook.getColumnValue(row_to_comp, 'BTCH_SEQ_NBR')
                            where STG_AI_ID = ihook.getColumnValue(row_ori, 'STG_AI_ID');
                            commit;
                            --raise_application_error(-20000, v_batch_nbr);
                        end if;
                    end if;
                end if;
            end loop;
     --   end if;
  
       if (v_val_ind = false) then 
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else 
         rows.extend; rows(rows.last) := row_ori;
         spPVVMValidate(row_ori, 'I');
        end if;
        --jira 3595
--        if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) then
--            ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'ITEM_1_NM'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Permissible Value missing.' || chr(13) || ihook.getColumnValue(row_ori, 'CTL_VAL_MSG'));
--                --ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
--                --v_val_ind := false;
--        end if;
            
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
   CNCPT_2_ITEM_ID_1= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_1'),
        CNCPT_2_VER_NR_1= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_1'),
   CNCPT_2_ITEM_ID_2= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_2'),
        CNCPT_2_VER_NR_2= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_2'),
    CNCPT_2_ITEM_ID_3= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_3'),
        CNCPT_2_VER_NR_3= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_3'),
   CNCPT_2_ITEM_ID_4= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_4'),
        CNCPT_2_VER_NR_4= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_4'),
   CNCPT_2_ITEM_ID_5= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_5'),
        CNCPT_2_VER_NR_5= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_5'),
   CNCPT_2_ITEM_ID_6= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_6'),
        CNCPT_2_VER_NR_6= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_6'),
   CNCPT_2_ITEM_ID_7= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_7'),
        CNCPT_2_VER_NR_7= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_7'),
   CNCPT_2_ITEM_ID_8= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_8'),
        CNCPT_2_VER_NR_8= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_8'),
   CNCPT_2_ITEM_ID_9= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_9'),
        CNCPT_2_VER_NR_9= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_9'),
   CNCPT_2_ITEM_ID_10= ihook.getColumnValue(row_ori,'CNCPT_2_ITEM_ID_10'),
        CNCPT_2_VER_NR_10= ihook.getColumnValue(row_ori,'CNCPT_2_VER_NR_10'),
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
CTL_VAL_MSG=ihook.getColumnValue(row_ori,'CTL_VAL_MSG')--,
--PERM_VAL_NM=ihook.getColumnValue(row_ori, 'PERM_VAL_NM')
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
*/
/*
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
*/
procedure ConceptParseDEC(v_str in varchar2, idx in integer, row_ori in out t_row)
as
i integer;
cnt integer;
v_cncpt_nm varchar2(255);
v_count integer;
v_str1 varchar2(4000);
begin

   cnt := nci_11179.getwordcount(v_str);
 -- raise_application_error(-20000, cnt);
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
                --jira 4227: function to clean concept string
                v_str := FormatConceptString(v_str);
                ConceptParseDEC(v_str,idx, row_ori);
             
         ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');   
         ihook.setColumnValue(row_ori, 'CNCPT_CONCAT_STR_' || idx, v_str);

        
          rows := t_rows();
    rows.extend; rows(rows.last) := row_ori;
    
    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
    actions.extend;
    actions(actions.last) := action;
    hookoutput.actions := actions;
    end if;
--    if (upper(nvl(ihook.getColumnValue(row_ori, 'VM_STR_TYP'),'XX')) <> 'CONCEPTS' and nvl(ihook.getColumnValue(row_ori,'CTL_VAL_STUS'),'XX') ='IMPORTED') then
--             ihook.setColumnValue(row_ori,'CTL_VAL_STUS','IMPORTED');
--          rows := t_rows();
--    rows.extend; rows(rows.last) := row_ori;
--    
--    action := t_actionrowset(rows, 'PV VM Import', 2,10,'update');
--    actions.extend;
--    actions(actions.last) := action;
--    hookoutput.actions := actions;
--    
--    end if;
   end if;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);



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
   
    spPVVMValidate(row_ori, 'I');      
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

function FormatConceptString (v_str in varchar2) return varchar2
is
    i integer;
    j integer;
    v_cnt integer;
    v_pos integer;
    in_str varchar2(4000);
    out_str varchar2(4000) := '';
    tmp_str varchar2(4000);
begin
    in_str := v_str;
    v_cnt := regexp_count(in_str, 'C');
    if (v_cnt < 2) then
        return v_str;
    else
        for i in 1..v_cnt loop
            if (i <> v_cnt) then
                v_pos := instr(substr(in_str,2),'C');
                tmp_str := rtrim(substr(in_str,1,v_pos));
                out_str := out_str || ' ' || tmp_str;
                in_str := substr(in_str, v_pos+1, length(in_str) - length(tmp_str));
            else
                tmp_str := rtrim(substr(in_str,1,v_pos));
                out_str := out_str || ' ' || tmp_str;
            end if;
        end loop;
        return trim(out_str);
    end if;

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

--v_mode should be set to 'I' or 'U'
-- 'I' = PV VM Import
-- 'U' = PV VM Update
procedure spPVVMValidate (row_ori in out t_row, v_mode in varchar2)
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
    v_pv_fnd number;
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
       --nci_dec_mgmt.createValAIWithConcept(row_ori, 1,53,'V', 'STRING', actions) ;
    -- return from combo for VM has an ERROR. Need to translate into v_val_ind = false;
       if(instr(ihook.getColumnValue(row_ori,'CTL_VAL_MSG'),'ERROR') > 0) then 
          v_val_ind := false;
       end if;
       
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
    --jira 3595
--    if (ihook.getColumnValue(row_ori, 'PERM_VAL_NM') is null) then
--        ihook.setColumnValue(row_ori, 'PERM_VAL_NM', ihook.getColumnValue(row_ori, 'ITEM_1_NM'));
--    end if;
    
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

--Unique validations for PV VM Update
if (v_mode = 'U') then
    v_pv_fnd := 0;
    --check that PV exists in the VD for update
    if (v_val_ind = true) then
        for cur in (select * from perm_val where val_dom_item_id = ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') and val_dom_ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR')
                    and upper(perm_val_nm) = upper(ihook.getColumnValue(row_ori, 'PERM_VAL_NM'))) loop
                --ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || '. PV found.' || chr(13));
                v_pv_fnd := v_pv_fnd + 1;
        end loop;
        if (v_pv_fnd > 1) then
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Duplicate PVs found in the VD.' || chr(13));
        elsif (v_pv_fnd = 1) then
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || ' PV found.' || chr(13));
        else --PV not found
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: PV not found in the VD. Please use PV VM Import.' || chr(13));
        end if;
    end if;
    
end if;
--end unique validations for PV VM Update
    
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

/*
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
*/
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
    
     if ( v_val_ind = true and v_mode = 'V') then
            nci_vd.spVDValCreateImport(row_ori, 'V', actions, v_val_ind);
    end if;
     --   if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null and v_val_ind = true and v_mode = 'C') then -- only go thru creating new if not specified
         if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null and  v_mode = 'C') then -- only go thru creating new if not specified
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


procedure spUpdateValVDImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
    
     if ( v_val_ind = true and v_mode = 'V') then
            nci_vd.spVDValUpdateImport(row_ori, 'V', actions, v_val_ind);
    end if;
     --   if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is null and v_val_ind = true and v_mode = 'C') then -- only go thru creating new if not specified
         if (ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') is not null and  v_mode = 'C') then -- only go thru creating new if not specified
           nci_vd.spVDValUpdateImport(row_ori, 'C', actions, v_val_ind);
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
 action := t_actionrowset(rows, 'VD Update', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spUpdValRTImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
            nci_vd.spRTValUpdImport(row_ori, 'V', actions, v_val_ind);
  
        if (v_val_ind = true and v_mode = 'U') then -- only go thru creating new if not specified
            ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
            nci_vd.spRTValUpdImport(row_ori, 'U', actions, v_val_ind);
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
 action := t_actionrowset(rows, 'Rep Term Import', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spCreateValDefImport (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode varchar2)
as
    hookInput           t_hookInput;
    hookOutput           t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;

    rows      t_rows;
    rowins  t_rows;
    rowalt t_rows;
    row          t_row;
    row_ori t_row;
    row_cur t_row;
    v_item_id number;
    v_ver_nr number(4,2);
    v_typ_id number;
 action t_actionRowset;
 v_temp integer;
 v_val_ind  boolean;
   actions t_actions := t_actions();
   row_to_comp t_row;
   v_batch_nbr number;
    nw_cntxt varchar2(64);
    v_long_nm varchar2(128);
    q_typ_id number;
    q_long_nm varchar2(128);
    v_alt_def varchar2(4000);
    v_alt_def_typ number;
    v_alt_ind boolean;
    v_pref_def_ind boolean;
begin


    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
  rows := t_rows();
  rowins := t_rows();
  rowalt := t_rows();

for i in 1..hookinput.originalRowset.rowset.count loop

    row_ori := hookInput.originalRowset.rowset(i);
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','' );                      
    v_val_ind := true;
    v_alt_ind := false;
    v_pref_def_ind := false;
    
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') <> 'PROCESSED') then
        if (ihook.getColumnValue(row_ori, 'ITEM_ID')  is null or ihook.getColumnValue(row_ori, 'VER_NR')  is null or ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') is null) then
            v_val_ind := false;   
            if (ihook.getColumnValue(row_ori, 'ITEM_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID is missing.' || chr(13) );           
            end if;
            if (ihook.getColumnValue(row_ori, 'VER_NR')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Version is missing.' || chr(13) );           
            end if;
            if (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID')  is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Type is missing.' || chr(13) );
            elsif (ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID') not in (2,3,4,53)) then --DEC, VD, DE, VM
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Type is invalid.' || chr(13) );
            end if;
        else
            v_item_id := ihook.getColumnValue(row_ori, 'ITEM_ID');
            v_ver_nr := ihook.getColumnValue(row_ori, 'VER_NR');
            v_typ_id := ihook.getColumnValue(row_ori, 'ADMIN_ITEM_TYP_ID');
            v_long_nm := ihook.getColumnValue(row_ori, 'SPEC_LONG_NM');
            if (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF') is not null) then
                v_alt_ind := true;
                if (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_TYP') is null) then
                    v_val_ind := false;
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'ERROR: Alternate Definition Type must be specified.' || chr(13)); 
                end if;
                if (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_ID') is null) then
                    v_val_ind := false;
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alternate Definition Context must be specified.' || chr(13));
                end if;
                if (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_LANG_ID') is null) then
                    ihook.setColumnValue(row_ori, 'IMP_ALT_DEF_LANG_ID', 1000);
                end if;
                if (v_val_ind = true) then
                    v_alt_def := ihook.getColumnValue(row_ori, 'IMP_ALT_DEF');
                    v_alt_def_typ := ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_TYP');
                end if;
            end if;
            if (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF') is null and (ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_TYP') is not null or ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_ID') is not null or ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_LANG_ID') is not null)) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Alternate Definition not specified.' || chr(13));
            end if;
            
            select count(*) into v_temp from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
            
            if (v_temp < 1) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item ID/Version is invalid.' || chr(13) );
            else 
                select admin_item_typ_id, item_nm into q_typ_id, q_long_nm from admin_item where item_id = v_item_id and ver_nr = v_ver_nr;
                
                --check that types match
                if (v_typ_id != q_typ_id) then
                    v_val_ind := false;
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Type does not match.' || chr(13) );
                end if;
                
                --check that definition is not null or blank
                if ((ihook.getColumnValue(row_ori, 'IMP_DEF') is null or ihook.getColumnValue(row_ori, 'IMP_DEF') = '') and v_alt_ind = false) then
                    v_val_ind := false;
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Please enter a Preferred Definition.' || chr(13) );
                    --raise_application_error(-20000, 'inside');
                elsif (ihook.getColumnValue(row_ori, 'IMP_DEF') is not null) then
                    --raise_application_error(-20000, 'inside');
                    v_pref_def_ind := true;
                end if;

               --check that imported long name matches if not null
                if (v_long_nm is not null or v_long_nm != '') then
                    if (v_long_nm != q_long_nm) then
                        v_val_ind := false;
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Item Long Name does not match.' || chr(13) );
                    end if;
                end if;
 
                -- raise_application_error(-20000, 'Passed validation check.');                   
                if (v_val_ind = false) then 
                    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                elsif (v_mode = 'V') then
                    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'No errors.');
                    rowins.extend; rowins(rowins.last) := row_ori;
                else
                    --add command to update the definition via admin item import
                    if (v_pref_def_ind = true) then
                        update admin_item set item_desc = ihook.getColumnValue(row_ori, 'IMP_DEF') where item_id = v_item_id and ver_nr = v_ver_nr;
                        update onedata_ra.admin_item set item_desc = ihook.getColumnValue(row_ori, 'IMP_DEF') where item_id = v_item_id and ver_nr = v_ver_nr;
                        commit;
                    end if;
                    if (v_alt_ind = true) then
            
                        insert into alt_def (item_id, ver_nr, def_desc, nci_def_typ_id, cntxt_item_id, cntxt_ver_nr, lang_id) 
                        values (v_item_id, v_ver_nr, ihook.getColumnValue(row_ori, 'IMP_ALT_DEF'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_TYP'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_ID'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_VER'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_LANG_ID'));
                        commit;
                        insert into onedata_ra.alt_def select * from onedata_wa.alt_def where onedata_wa.alt_def.def_id not in (select onedata_ra.alt_def.def_id from onedata_ra.alt_def);
                        --insert into onedata_ra.alt_def (item_id, ver_nr, def_desc, nci_def_typ_id, cntxt_item_id, cntxt_ver_nr, lang_id) 
                        --values (v_item_id, v_ver_nr, ihook.getColumnValue(row_ori, 'IMP_ALT_DEF'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_TYP'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_ID'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_CNTXT_VER'), ihook.getColumnValue(row_ori, 'IMP_ALT_DEF_LANG_ID'));
                        commit;
                    end if;
                    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'PROCESSED');
                    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', '');
                    rowins.extend; rowins(rowins.last) := row_ori;
                end if;
                rows.extend; rows(rows.last) := row_ori;
            end if;
        
        end if;
    end if;
end loop;
action := t_actionrowset(rows, 'Definition Import', 2,11,'update');
actions.extend;
actions(actions.last) := action;

action := t_actionrowset(rowins, 'Administered Item (For Import)', 2,11,'update');
actions.extend;
actions(actions.last) := action;

hookoutput.actions := actions;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


-- CDE Update object Mode V or U
procedure spUpdateValCDEUpdate (v_data_in in clob, v_data_out out clob, v_usr_id in varchar2, v_mode in varchar2)
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
       cde_long_nm_ind boolean;
    cde_def_ind boolean;
    cde_nm_ind boolean;
    v_cnt integer;
     tmp_dec_id number;
    tmp_dec_ver_nr number(4,2);
    tmp_vd_id number;
    tmp_vd_ver_nr number(4,2);
     v_dec_item_id number;
    v_dec_ver_nr number(4,2);
    v_vd_item_id number;
    v_vd_ver_nr number(4,2);
     v_retired boolean := false;
      v_de_nm varchar2(255);
    v_de_def varchar2(4000);
    v_cde_nm varchar2(255);
    v_cde_def varchar2(4000);
     v_vd_nm varchar2(255);
    v_vd_def varchar2(4000);
     v_cde_long_nm varchar2(255);
    v_dec_item_nm varchar2(255);
    v_dec_item_def varchar2(4000);
    v_vd_item_nm varchar2(255);
    v_vd_item_def  varchar2(4000);
      v_item_def varchar2(4000);
    v_item_long_nm varchar2(255);
  row_to_comp t_row;
  
 v_batch_nbr number;
begin
    hookInput := ihook.getHookInput(v_data_in);
    hookOutput.invocationNumber := hookInput.invocationNumber;
    hookOutput.originalRowset := hookInput.originalRowset;
    rows := t_rows();
  
for i in 1..hookinput.originalRowset.rowset.count loop
    row_ori := hookInput.originalRowset.rowset(i);
  
    if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS')<> 'PROCESSED') then -- A
        v_val_ind := true;
        ihook.setColumnValue(row_ori,'CTL_VAL_MSG', '');
        v_item_id := ihook.getColumnValue(row_ori, 'CREAT_CDE_ID');
        v_ver_nr := ihook.getColumnValue(row_ori, 'IMP_UPD_DEC_VER'); --reusing existing column instead of creating new one
        cde_def_ind := false;
        cde_nm_ind := false;
        cde_long_nm_ind := false;
      -- START CDE ID/Version validation
      
        if v_mode in ('U', 'N') then
            if (ihook.getColumnValue(row_ori, 'IMP_UPD_DEC_VER') is null or ihook.getColumnValue(row_ori, 'IMP_UPD_DEC_VER') = '') then
                if (ihook.getColumnValue(row_ori, 'IMP_UPD_DEC_VER') is null and ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') is not null) then
                    select ver_nr into v_ver_nr from admin_item where admin_item_typ_id = 4 and item_id = ihook.getColumnValue(row_ori, 'CREAT_CDE_ID') and CURRNT_VER_IND = 1;
                    if (v_ver_nr is not null) then
                        ihook.setColumnValue(row_ori, 'IMP_UPD_DEC_VER', v_ver_nr);
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') || 'WARNING: CDE Version not specified. Set to latest version: ' || v_ver_nr || chr(13));
                    else
                        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
                        v_val_ind := false;
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',ihook.getColumnValue(row_ori,'CTL_VAL_MSG') || 'CDE ID or Version missing.' || chr(13));  
                    end if;
                end if;   
            end if;
            select count(*) into v_cnt from admin_item where admin_item_typ_id = 4 and item_id = v_item_id and ver_nr = v_ver_nr and currnt_ver_ind = 1;
            if (v_cnt < 1) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori,'CTL_VAL_MSG') ||'Invalid CDE Public ID or Version. Or specified version is not the latest version'|| chr(13));
            end if;
        end if;
 -- END CDE ID/VERSION validation
 
        if (v_mode =  'N' and ihook.getColumnValue(row_ori, 'NEW_VER_NR') is null) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'New Version Number not specified' || chr(13));
        end if;
        
           if (v_mode =  'N' and ihook.getColumnValue(row_ori, 'NEW_VER_NR') is  not null and ihook.getColumnValue(row_ori, 'NEW_VER_NR') <= v_ver_nr) then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'New Version Number has to be greater than current version.' || chr(13));
        end if;
 ---- START DEC VALIDATION
 
    if (ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') is null and ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null) then
        select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and admin_item_typ_id = 2;
        if (v_cnt < 1) then
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid DEC ID/Ver combination.');
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
            select ver_nr into v_dec_ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_1_ID') and CURRNT_VER_IND = 1;
            ihook.setColumnValue(row_ori, 'ITEM_1_VER_NR', v_dec_ver_nr);
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'WARNING: DEC Version not specified. Latest version will be used.');
        end if;
    end if;
    for cur in (select * from admin_item where admin_item_typ_id = 2 and item_id = nvl(ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID'),ihook.getColumnValue(row_ori,'ITEM_1_ID'))
    and ver_nr =  nvl(ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'),ihook.getColumnValue(row_ori,'ITEM_1_VER_NR'))  and nvl(fld_delete,0) = 0) loop
--  raise_application_error(-20000, cur.admin_stus_nm_dn);
        v_dec_item_id :=cur.item_id ;
        v_dec_ver_nr := cur.ver_nr;
     
        if (upper(cur.admin_stus_nm_dn) like '%RETIRED%') then
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'ERROR: DEC is Retired.' || chr(13));
        else
            ihook.setColumnValue(row_ori, 'DE_CONC_ITEM_ID',cur.item_id);
            ihook.setColumnValue(row_ori, 'DE_CONC_VER_NR', cur.ver_nr);
            v_dec_item_id := ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID');
            v_dec_ver_nr := ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR');
            if (upper(cur.admin_stus_nm_dn) not like '%RELEASED%') then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'WARNING: DEC is not Released.' || chr(13));
            end if;
        end if;
    end loop;
    if (v_dec_item_id is null or v_dec_ver_nr is null) then
        v_val_ind := false;
        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG')|| 'ERROR: DEC not found.'|| chr(13));
    end if;
 --- END DEC VALIDATION
 
 --- START VD VALIDATION
    v_retired := false;
--default vd version to latest if not specified
    if (ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR') is null and ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null) then
        select count(*) into v_cnt from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and admin_item_typ_id = 3;
        if (v_cnt < 1) then
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'Invalid VD ID/Ver combination.');
            ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
            select ver_nr into v_vd_ver_nr from admin_item where item_id = ihook.getColumnValue(row_ori, 'ITEM_2_ID') and CURRNT_VER_IND = 1;
            ihook.setColumnValue(row_ori, 'ITEM_2_VER_NR', v_vd_ver_nr);
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || chr(13) || 'WARNING: VD Version not specified. Latest version will be used.');
        end if;
    end if;
    for cur in (select * from admin_item where admin_item_typ_id = 3  and item_id = nvl(ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID'),ihook.getColumnValue(row_ori,'ITEM_2_ID'))
    and ver_nr =  nvl(ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'),ihook.getColumnValue(row_ori,'ITEM_2_VER_NR')) and nvl(fld_delete,0) = 0 ) loop
   --  raise_application_error(-20000, 'HErer');
        v_vd_item_id :=  cur.item_id ;
        v_vd_ver_nr := cur.ver_nr ;
     
        if (upper(cur.admin_stus_nm_dn) like '%RETIRED%') then
            v_val_ind := false;
            ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: VD is Retired.' || chr(13));
            v_retired := true;
        else
            ihook.setColumnValue(row_ori, 'VAL_DOM_ITEM_ID', cur.item_id);
            ihook.setColumnValue(row_ori, 'VAL_DOM_VER_NR', cur.ver_nr);
            if (upper(cur.admin_stus_nm_dn) not like '%RELEASED%') then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  cur.admin_stus_nm_dn || chr(13));
            end if;
        end if;
    end loop;
    if (v_vd_item_id is null or v_vd_ver_nr is null ) then
        v_val_ind := false;
          ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',ihook.getColumnValue(row_ori,'CTL_VAL_MSG') || 'ERROR: VD not found.'|| chr(13));
    end if;
    ---- END VD VALIDATION
    
        if (v_val_ind = true and v_mode='U') then -- X
        
            for cur in (select * from admin_item where admin_item_typ_id = 4 and item_id = v_item_id and ver_nr = v_ver_nr) loop
            if (upper(cur.admin_stus_nm_dn) like '%RETIRED%') then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: CDE is RETIRED ARCHIVED. Update cannot be performed.' || chr(13));
            end if;
            if (upper(cur.admin_stus_nm_dn) = 'RELEASED') then
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: CDE is RELEASED. Update cannot be performed.' || chr(13));
            end if;
            end loop;
            if (ihook.getColumnValue(row_ori, 'ADMIN_STUS_ID') = 77 and ihook.getColumnValue(row_ori, 'UNTL_DT') is null) then 
                v_val_ind := false;
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'ERROR: Provide End Date when setting CDE to Retire.' || chr(13));
            end if;
      
      
        end if; -- X

    if (ihook.getColumnValue(row_ori, 'IMP_ORIGIN') is not null and   ihook.getColumnValue(row_ori, 'ORIGIN_ID') is null) then
                ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') || 'ERROR: Specified Origin is invalid.' || chr(13));
        v_val_ind  := false;
    end if;
  
    if (v_val_ind = true) then 
        if (v_mode ='U') then
    
            select de_conc_item_id, de_conc_ver_nr, val_dom_item_id, val_dom_ver_nr into tmp_dec_id, tmp_dec_ver_nr, tmp_vd_id, tmp_vd_ver_nr from de where item_id = v_item_id and ver_nr = v_ver_nr;
            select item_nm, item_desc into v_dec_item_nm, v_dec_item_def from admin_item where item_id = tmp_dec_id and ver_nr = tmp_dec_ver_nr;
            select item_nm, item_desc into v_vd_item_nm, v_vd_item_def from admin_item where item_id = tmp_vd_id and ver_nr = tmp_vd_ver_nr;
            if (ihook.getColumnValue(row_ori, 'ITEM_1_ID') is not null) then
                if (ihook.getColumnValue(row_ori, 'ITEM_1_ID') != tmp_dec_id or ihook.getColumnValue(row_ori, 'ITEM_1_VER_NR') != tmp_dec_ver_nr) then
                    cde_nm_ind := true;
                end if;
            end if;
            if (ihook.getColumnValue(row_ori, 'ITEM_2_ID') is not null) then
                if (ihook.getColumnValue(row_ori, 'ITEM_2_ID') != tmp_vd_id or ihook.getColumnValue(row_ori, 'ITEM_2_VER_NR') != tmp_vd_ver_nr) then
                    cde_nm_ind := true;
                end if;
            end if;
            if (v_cde_long_nm is not null) then
                select count(*) into v_cnt from admin_item where item_id = v_item_id and ver_nr = v_ver_nr and regexp_like(item_long_nm, '(.*)v(.*):(.*)v(.*)');
                if (v_cnt > 0) then
                    cde_long_nm_ind := true;
                end if;
            end if;
        end if; -- v_mode = 'U'
        if (v_mode = 'N') then 
            cde_long_nm_ind := true;
            cde_nm_ind := true;
            select item_nm, item_desc into v_dec_item_nm, v_dec_item_def from admin_item where item_id = ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID')
            and ver_nr = ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR');
            select item_nm, item_desc into v_vd_item_nm, v_vd_item_def from admin_item where item_id =ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID')
            and ver_nr = ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR');
            
        end if;
        end if; -- Val ind
        
        if (ihook.getColumnValue(row_ori, 'CDE_ITEM_NM') is not null) then
            ihook.setColumnValue(row_ori, 'ITEM_NM',ihook.getColumnValue(row_ori, 'CDE_ITEM_NM'));
        elsif (cde_nm_ind = true) then
            ihook.setColumnValue(row_ori, 'ITEM_NM',substr(v_dec_item_nm || ' ' || v_vd_item_nm, 1, 255));
        end if;
        -- jira 1870
        if (ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') is not null) then
            ihook.setColumnValue(row_ori, 'ITEM_LONG_NM',ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM'));
        elsif (cde_long_nm_ind = true) then
            --v_item_long_nm := v_dec_item_id || 'v' || to_char(v_dec_ver_nr,'fm99D00') || ':' || v_vd_item_id || 'v' || to_char(v_vd_ver_nr,'fm99D00');
            v_item_long_nm := ihook.getColumnValue(row_ori, 'DE_CONC_ITEM_ID') || 'v' || trim(to_char(ihook.getColumnValue(row_ori, 'DE_CONC_VER_NR'), '9999.99')) || ':' || 
                              ihook.getColumnValue(row_ori, 'VAL_DOM_ITEM_ID') || 'v' || trim(to_char(ihook.getColumnValue(row_ori, 'VAL_DOM_VER_NR'), '9999.99'));
           -- raise_application_error(-20000, v_item_long_nm);
            ihook.setColumnValue(row_ori, 'CDE_ITEM_LONG_NM', v_item_long_nm);
            ihook.setColumnValue(row_ori, 'ITEM_LONG_NM',ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM'));
        end if;
        ihook.setColumnValue(row_ori,'GEN_DE_NM', ihook.getColumnValue(row_ori,'ITEM_NM'));
        -- Generated dte
      --    ihook.setColumnValue(rowform,'PROCESS_DT',to_char(sysdate, DEFAULT_TS_FORMAT) );
      ihook.setColumnValue(row_ori,'PROCESS_DT_CHAR',TO_CHAR(SYSDATE, 'MM/DD/YY HH24:MI:SS') );
    
        if (ihook.getColumnValue(row_ori, 'CDE_ITEM_DESC') is not null) then
            ihook.setColumnValue(row_ori, 'ITEM_DESC',ihook.getColumnValue(row_ori, 'CDE_ITEM_DESC'));
        elsif (cde_nm_ind = true) then
          ihook.setColumnValue(row_ori, 'ITEM_DESC',substr(v_dec_item_def || ':' || v_vd_item_def,1,4000));
          end if;
   -- end if; ---- if v_val_ind = true
    
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and de.de_conc_item_id = v_dec_item_id
            and de.de_conc_ver_nr =  v_dec_ver_nr
            and de.val_dom_item_id =  v_vd_item_id
            and de.val_dom_ver_nr =  v_vd_ver_nr
            and ai.cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')
            and ai.admin_stus_nm_dn not like '%RETIRED%'
            and ai.item_id != v_item_id) loop
                v_val_ind := false;
                        ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'ERROR: Duplicate CDE found : ' || cur.item_id || chr(13));

            end loop;
         --end if;

        if (ihook.getColumnValue(row_ori, 'CDE_ITEM_LONG_NM') is not null ) then  --- check if CDE short name specified
       -- raise_application_Error(-20000, ihook.getColumnValue(rowform, 'CDE_ITEM_LONG_NM'));
            for cur in (select ai.item_id item_id from admin_item ai, de de
            where ai.item_id = de.item_id and ai.ver_nr = de.ver_nr
            and ai.ITEM_LONG_NM=ihook.getColumnValue(row_ori,'CDE_ITEM_LONG_NM')
            --and ai.ver_nr = 1
            and ai.cntxt_item_id = ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID')
            and  ai.cntxt_ver_nr = ihook.getColumnValue(row_ori, 'CNTXT_VER_NR')
            and ai.item_id != v_item_id) loop
                v_val_ind := false;
                         ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', ihook.getColumnValue(row_ori, 'CTL_VAL_MSG') ||  'ERROR: Duplicate CDE found based on context/short name: ' || cur.item_id || chr(13));
            end loop;
        end if;
       
      --  raise_application_error(-20000, v_err_Str);
        if (v_val_ind = false) then
        ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'ERRORS');
        else
          ihook.setColumnValue(row_ori, 'CTL_VAL_STUS', 'VALIDATED');
        end if;
        
    
        if ( v_mode  in ('U', 'N') and v_val_ind = true) then  
            nci_chng_mgmt.spCDEValUpdate(row_ori, v_mode, actions, v_val_ind, v_item_id, v_ver_nr, v_usr_id);
        end if;
        
   else
    ihook.setColumnValue(row_ori, 'CTL_VAL_MSG', 'Row already PROCESSED');
   end if;    
end loop;
    rows.extend; rows(rows.last) := row_ori;
   
action := t_actionrowset(rows, 'CDE Update', 2,10,'update');
actions.extend;
actions(actions.last) := action;
hookoutput.actions := actions;
V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
nci_util.debugHook('GENERAL',v_data_out);
end;

end;
/
