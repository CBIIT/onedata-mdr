create or replace PACKAGE            nci_codemap_vm AS
 procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number,v_user_id in varchar2, v_chk_ind in integer);

  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spGenerateValueMapAll ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  
  
procedure spDeleteValueMapping  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--procedure dervTgtMECTemp; 
 
procedure spValidateValueMapImport ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateValueMapImport( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
END;
/
create or replace PACKAGE BODY            nci_codemap_vm AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
--v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
--  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  v_reg_str_adv varchar2(255) := '[^A-Za-z0-9]';
v_reg_str varchar2(255) := '[^ A-Za-z0-9]';

procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    input_rows t_rows;
    output_rows t_rows;
    v_src_alt_nm_typ integer;
    v_tgt_alt_nm_typ integer;
    v_temp integer;
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        
        if (ihook.getColumnValue(row_ori,'SRC_MEC_ID') is null or ihook.getColumnValue(row_ori,'TGT_MEC_ID') is null) then
          raise_application_error(-20000,'Both Source Characteristics and Target Characteristics have to be specified for Value Mapping Generation.');
        end if;
    
    for cur in (select * from nci_mdl_elmnt_char where mec_id in ( ihook.getColumnValue(row_ori,'SRC_MEC_ID'),
     ihook.getColumnValue(row_ori,'TGT_MEC_ID')) and CDE_ITEM_ID is null ) loop
           raise_application_error(-20000,'Both Source and Target Characteristics should have CDE specified for Value Mapping Generation.');
     end loop;
     
    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.SRC_MDL_ITEM_ID = m.item_id and mm.SRC_MDL_VER_NR = m.VER_NR) loop
    
    v_src_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') and mm.TGT_MDL_ITEM_ID = m.item_id and mm.TGT_MDL_VER_NR = m.VER_NR) loop
    
    v_tgt_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
  --  raise_application_error(-20000, v_src_alt_nm_typ);
    
    input_rows := t_rows();
    output_rows := t_rows();
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID') and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
 
 
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID')  and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr and v.val_dom_typ_id = 17) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    
  --    raise_application_error(-20000, input_rows.count);
  
   
    nci_11179_2.spCreateValueMap(input_rows, output_rows, v_src_alt_nm_typ, v_tgt_alt_nm_typ);
    
    delete from NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and 
 nvl(map_deg,0) <> 120 and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where 
    src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') 
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
    commit;
    
    rows := t_rows();
    for i in 1..output_rows.count loop
        row := row_ori;
 --   raise_application_error(-20000,output_rows.count);
        
        select count(*) into v_temp from nci_mec_val_map where src_mec_id =ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
        and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
        and nvl(src_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'1'),0)
        and nvl(tgt_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'2'),0)
        and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') ;
        if (v_temp = 0) then -- insert
        insert into nci_mec_val_map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
        SRC_LBL, TGT_LBL, MAP_DEG, MECM_ID)
        select ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID'),
        ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR'),ihook.getColumnValue(output_rows(i),'1'),ihook.getColumnValue(output_rows(i),'2'),
        ihook.getColumnValue(output_rows(i),'VM Concept Codes'),ihook.getColumnValue(output_rows(i),'VM Name'),
        ihook.getColumnValue(output_rows(i),'LBL_1'),ihook.getColumnValue(output_rows(i),'LBL_2'),
        decode(ihook.getColumnValue(output_rows(i),'1'),null,decode(ihook.getColumnValue(output_rows(i),'2'),null,130,86),130),
        ihook.getColumnValue(row_ori, 'MECM_ID') from dual;
       /*
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
        -- Semantic map if both source and target pv present.
        if (ihook.getColumnValue(row,'SRC_PV') is not null and ihook.getColumnValue(row,'TGT_PV') is not null) then 
            ihook.setColumnValue(row,'MAP_DEG',86);
        else
                ihook.setColumnValue(row,'MAP_DEG',130);-- not mapped yet.
        end if;
        ihook.setColumnValue(row,'MECVM_ID',-1); 
        rows.extend;     rows(rows.last) := row;*/
        
        end if;

    end loop;
    commit;
    
    insert into  onedata_ra.NCI_MEC_VAL_MAP 
    select * from nci_mec_val_map where  
    src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') 
    and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
    commit;
    
    
   -- raise_application_Error(-20000,rows.count);
      --      action := t_actionrowset(rows, 'Model Map Characteristic Values', 2,2,'insert');
       -- actions.extend;
        --actions(actions.last) := action;
        
        row:= t_row();
        ihook.setColumnValue(row, 'MECM_ID',ihook.getColumnValue(row_ori, 'MECM_ID'));
        ihook.setColumnValue(row,'VAL_MAP_CREATE_IND',1);
        rows := t_rows();
        rows.extend;     rows(rows.last) := row;
       
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,3,'update');
        actions.extend;
        actions(actions.last) := action; 
        
  hookoutput.actions := actions;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL', v_data_out);
  
end;



procedure spGenerateValueMapAll ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    input_rows t_rows;
    output_rows t_rows;
    v_src_alt_nm_typ integer;
    v_tgt_alt_nm_typ integer;
    rows_v t_rows := t_rows();
    rows_x t_rows := t_rows();
    v_temp integer;
    
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        
        
     delete from NCI_MEC_VAL_MAP where map_deg <> 120 and mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where  mdl_map_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'VER_NR');
    commit;
    
         for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and mm.SRC_MDL_ITEM_ID = m.item_id and mm.SRC_MDL_VER_NR = m.VER_NR) loop
    
    v_src_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    for cur in (Select m.* from nci_mdl m, nci_mdl_map mm where mm.item_id = ihook.getColumnValue(row_ori,'ITEM_ID') 
    and mm.ver_nr = ihook.getColumnValue(row_ori,'VER_NR') and mm.TGT_MDL_ITEM_ID = m.item_id and mm.TGT_MDL_VER_NR = m.VER_NR) loop
    
    v_tgt_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
    end loop;
    -- Semantically similar
    for outercur in (select * from VW_MDL_MAP_IMP_TEMPLATE where MODEL_MAP_ID=ihook.getColumnValue(row_ori,'ITEM_ID')  and MODEL_MAP_VERSION=ihook.getColumnValue(row_ori,'VER_NR')
  --  and (upper(SOURCE_DOMAIN_TYPE)= 'ENUMERATED' or upper(TARGET_DOMAIN_TYPE)='ENUMERATED')and src_mec_id is not null and tgt_mec_id is not null) loop
    and (upper(SOURCE_DOMAIN_TYPE)= 'ENUMERATED' and upper(TARGET_DOMAIN_TYPE)='ENUMERATED')and src_mec_id is not null and tgt_mec_id is not null) loop
    --and upper(MAPPING_DEGREE)='SEMANTIC SIMILAR') loop
   
  --  raise_application_error(-20000, v_src_alt_nm_typ);
    
    input_rows := t_rows();
    output_rows := t_rows();
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = outercur.SRC_MEC_ID and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      ihook.setColumnValue(row,'MECM_ID', outercur.MECM_ID);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = outercur.TGT_MEC_ID  and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
      if(input_rows.count = 0) then
      -- insert dummy row
      
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', 1);
      ihook.setColumnValue (row, 'VER_NR', 1);
      input_rows.extend;  input_rows(input_rows.last) := row;
      end if;
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
      input_rows.extend;  input_rows(input_rows.last) := row;

    end loop;
    
    
   
    nci_11179_2.spCreateValueMap(input_rows, output_rows, v_src_alt_nm_typ, v_tgt_alt_nm_typ);
    
    
    
    rows := t_rows();
    for i in 1..output_rows.count loop
             select count(*) into v_temp from nci_mec_val_map where src_mec_id =ihook.getColumnValue(row_ori, 'SRC_MEC_ID')
        and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID')
        and nvl(src_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'1'),0)
        and nvl(tgt_pv,0) = nvl(ihook.getColumnValue(output_rows(i),'2'),0)
        and mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR') ;
        if (v_temp = 0) then -- insert
        insert into nci_mec_val_map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
        SRC_LBL, TGT_LBL, MAP_DEG, MECM_ID)
        select outercur.SRC_MEC_ID,outercur.TGT_MEC_ID,ihook.getColumnValue(row_ori, 'ITEM_ID'),
        ihook.getColumnValue(row_ori, 'VER_NR'),ihook.getColumnValue(output_rows(i),'1'),ihook.getColumnValue(output_rows(i),'2'),
        ihook.getColumnValue(output_rows(i),'VM Concept Codes'),ihook.getColumnValue(output_rows(i),'VM Name'),
        ihook.getColumnValue(output_rows(i),'LBL_1'),ihook.getColumnValue(output_rows(i),'LBL_2'),
        decode(ihook.getColumnValue(output_rows(i),'1'),null,decode(ihook.getColumnValue(output_rows(i),'2'),null,130,86),130),
        ihook.getColumnValue(row_ori, 'MECM_ID') from dual;
   
/*    row := t_row();
         ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
      ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));
    
        ihook.setColumnValue(row,'SRC_MEC_ID',outercur.src_mec_id);
        ihook.setColumnValue(row,'TGT_MEC_ID',outercur.TGT_mec_id);
    
       ihook.setColumnValue(row,'MECM_ID',ihook.getColumnValue(output_rows(i),'MECM_ID'));
     
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
        -- source pv and target pv are both present then mapping - sematic else not yet mapped
        if (ihook.getColumnValue(row,'SRC_PV') is not null and ihook.getColumnValue(row,'TGT_PV') is not null) then 
         ihook.setColumnValue(row,'MAP_DEG',86);
        else
                ihook.setColumnValue(row,'MAP_DEG',130);
        end if;
        ihook.setColumnValue(row,'MECVM_ID',-1);
        
                                     rows_v.extend;
                                            rows_v(rows_v.last) := row;*/
                    end if;

    end loop;
   -- raise_application_Error(-20000,rows.count);
     commit;
     
        row:= t_row();
        ihook.setColumnValue(row, 'MECM_ID',outercur.MECM_ID);
        ihook.setColumnValue(row,'VAL_MAP_CREATE_IND',1);
        rows_x.extend;     rows_x(rows_x.last) := row;
       
         
    end loop;
     --action := t_actionrowset(rows_v, 'Model Map Characteristic Values', 2,2,'insert');
     --   actions.extend;
      ---  actions(actions.last) := action;
           action := t_actionrowset(rows_x, 'Model Map - Characteristics', 2,3,'update');
        actions.extend;
        actions(actions.last) := action; 
  hookoutput.actions := actions;
  
    insert into  onedata_ra.NCI_MEC_VAL_MAP 
    select * from nci_mec_val_map where  
     mdl_map_item_id = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') 
    and mdl_map_ver_nr = ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
    commit;
    
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL', v_data_out);
  
end;


  procedure spCopyVM ( v_src_mm_id in number, v_src_mm_ver_nr in number, v_tgt_mm_id in number, v_tgt_mm_ver_nr in number, v_user_id in varchar2,v_chk_ind in integer)
  as
i integer;
begin
if (v_chk_ind = 0) then -- no check
insert into nci_mec_val_Map (SRC_MEC_ID, TGT_MEC_ID, MDL_MAP_ITEM_ID, MDL_MAP_VER_NR, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEG,CREAT_USR_ID, LST_UPD_USR_ID)
select SRC_MEC_ID, TGT_MEC_ID, v_tgt_mm_id, v_tgt_mm_ver_nr, 
SRC_PV, TGT_PV, VM_CNCPT_CD, VM_CNCPT_NM,
PROV_ORG_ID, PROV_CNTCT_ID, PROV_RSN_TXT, PROV_TYP_RVW_TXT, PROV_RVW_DT, PROV_APRV_DT, SRC_LBL, TGT_LBL, PROV_NOTES, MAP_DEg, v_user_id, v_user_id
from nci_mec_val_map where mdl_map_item_id = v_src_mm_id and mdl_map_ver_nr = v_src_mm_ver_nr;
commit;

insert into onedata_Ra.nci_mec_val_map (MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR) select MECVM_ID,
SRC_MEC_ID,
TGT_MEC_ID,
MDL_MAP_ITEM_ID,
MDL_MAP_VER_NR from onedata_wa.nci_mec_val_map where  mdl_map_item_id = v_tgt_mm_id and mdl_map_ver_nr = v_tgt_mm_ver_nr;
commit;
end if;
end;
  
procedure spDeleteValueMapping  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rowrel t_row;
    row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;

  rowform t_row;
v_found boolean;
 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 
 for i in 1..hookInput.originalRowset.rowset.count loop
 row_ori :=  hookInput.originalRowset.rowset(i);
 delete from nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
 delete from onedata_ra.nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
 
end loop;
commit;
hookoutput.message := hookInput.originalRowset.rowset.count ||  ' Value Mapping(s) deleted.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;



   procedure spUpdateValueMapImport( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rowsadd  t_rows;
  rowsupd  t_rows;
  rows t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_add boolean;
  v_temp integer;
  i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  rowsadd := t_rows();
  rowsupd := t_rows();
  rows := t_rows();
  
  for i in 1..hookinput.originalRowset.rowset.count loop
  row_ori :=  hookInput.originalRowset.rowset(i);
  
    if ( nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_STUS'),'IMPORTED') = 'VALIDATED') then
  
        ihook.setcolumnValue(row_ori, 'MECVM_ID', nvl(ihook.getColumnValue(row_ori,'MECVM_ID'),ihook.getColumnValue(row_ori,'STG_MECVM_ID')));
        Select count(*) into v_temp  from nci_mec_VAL_map where mecvm_id = ihook.getcolumnValue(row_ori,'MECVM_ID');
 
        if (v_temp= 0) then
            rowsadd.extend;   rowsadd(rowsadd.last) := row_ori;
 --   raise_application_error(-20000,' Add');
        else
        row := t_row();
        ihook.setColumnValue(row, 'MECVM_ID',ihook.getColumnValue(row_ori, 'MECVM_ID'));
        ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID'));
        ihook.setColumnValue(row, 'MDL_MAP_VER_NR',ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR'));
        ihook.setColumnValue(row, 'SRC_MEC_ID', ihook.getColumnValue(row_ori, 'SRC_MEC_ID'));
        ihook.setColumnValue(row, 'TGT_MEC_ID', ihook.getColumnValue(row_ori, 'TGT_MEC_ID'));
        ihook.setColumnValue(row, 'SRC_PV', ihook.getColumnValue(row_ori, 'SRC_PV'));
        ihook.setColumnValue(row, 'TGT_PV', ihook.getColumnValue(row_ori, 'TGT_PV'));
        ihook.setColumnValue(row, 'MAP_DEG', 120);
        
        
        rowsupd.extend;   rowsupd(rowsupd.last) := row;
     --   raise_application_error(-20000,' Update');
    end if;
 
    ihook.setColumnValue(row_ori,'CTL_VAL_STUS','UPDATED');
     rows.extend;   rows(rows.last) := row_ori;
 
    end if; 
 end loop;
 
  if (rowsadd.count>0) then
   action := t_actionrowset(rowsadd, 'Value Map (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
    
 if (rowsupd.count>0) then
   action := t_actionrowset(rowsupd, 'Value Map (Hook)', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
    end if;
  
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Value Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  --  raise_application_error(-20000,' Actions');
        hookoutput.actions := actions;
    end if;
    
 hookoutput.message:= 'New mapping inserted: ' || rowsadd.count || ' Mapping updated: ' || rowsupd.count;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spValidateValueMapImport ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 j integer;
 k integer;
 v_nm varchar2(4000);
 v_typ integer;
 v_dflt_typ integer;
 v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  rows := t_rows();

  for i in 1..hookinput.originalRowset.rowset.count loop
  row_ori :=  hookInput.originalRowset.rowset(i);
  v_valid := true;
  v_val_stus_msg := '';
  
 if ( nvl(ihook.getColumnValue(row_ori, 'CTL_VAL_STUS'),'IMPORTED') in ( 'IMPORTED','ERROR','VALIDATED')) then
  
  
  
-- Validate that the source elemnt/char and target element/char belong to the current source and target model
-- validate that both ME and MEC are specified. May be blank.
if (ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is null or  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is  null )  then
v_valid := false;
v_val_stus_msg := 'Both Source Element and Characteristics have to be specified; ';
end if;

if (ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is null or  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is  null )  then
v_valid := false;
v_val_stus_msg := 'Both Target Element and Characteristics have to be specified; ';
end if;

if ( ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is not null) then 
ihook.setColumnValue(row_ori, 'SRC_MEC_ID','');
   for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.src_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.src_mdl_ver_Nr
    and mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  me.ITEM_PHY_OBJ_NM =ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM')
    and MEC.MEC_PHY_NM=ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'SRC_MEC_ID', cur.mec_id);
    end loop;
    
    if (ihook.getColumnValue(row_ori, 'SRC_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Source Characteristics; '|| chr(13);
    end if;
end if;    

if ( ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is not null) then 
    for cur in (
    select mec.mec_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec, nci_mdl_map mm where me.MDL_ITEM_ID = mm.tgt_mdl_item_id 
    and me.MDL_ITEM_VER_NR = mm.tgt_mdl_ver_Nr
    and mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and  me.ITEM_PHY_OBJ_NM =ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM')
    and MEC.MEC_PHY_NM=ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') and me.ITEM_ID = mec.MDL_ELMNT_ITEM_ID and me.ver_nr = mec.MDL_ELMNT_VER_NR) loop
      ihook.setColumnValue(row_ori, 'TGT_MEC_ID', cur.mec_id);
    end loop;
    if (ihook.getColumnValue(row_ori, 'TGT_MEC_ID') is null) then 
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg || 'Invalid Target Characteristics; '|| chr(13);
    end if;
end if;    

if (ihook.getColumnValue(row_ori, 'IMP_PROV_ORG') is not null and  ihook.getColumnValue(row_ori, 'PROV_ORG_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Organization is incorrect; '|| chr(13);
end if;


 
if (ihook.getColumnValue(row_ori, 'IMP_PROV_CNTCT') is not null and  ihook.getColumnValue(row_ori, 'PROV_CNTCT_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Contact is incorrect; '|| chr(13);
end if;
 
 -- Rules id provided is incorrect.
 
if (ihook.getColumnValue(row_ori, 'IMP_MECVM_ID') is not null) then
    select count(*) into v_temp from NCI_MEC_VAL_MAP where  MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and MECVM_ID=ihook.getColumnValue(row_ori, 'IMP_MECVM_ID') and nvl(fld_Delete,0) = 0
    and src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID');
    if (v_temp = 0) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported VM Rule ID or Source/Target element/characteristic information is incorrect or does not exist. '|| chr(13);

    end if;    
end if;
 
 -- duplicae based on src/tgt/op/src func/tgt func/condition/operator
 if (v_valid = true) then -- check for duplicate
    for cur in (select * from nci_mec_val_map where mdl_map_item_id = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mdl_map_ver_nr =  ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and nvl(src_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),0)
    and  ihook.getColumnValue(row_ori, 'MECVM_ID') is null and src_pv = ihook.getColumnValue(row_ori, 'SRC_PV') 
    ) loop
       v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Duplicate found with Value Map Rule ID: '|| cur.MECVM_ID ||  chr(13);
   end loop;
 end if;
 	
    -- if enumerated, then check PV values
  if (v_Valid = true) then 
  for cur in (Select * from vw_nci_mec where mec_id = ihook.getColumnValue(row_ori,'SRC_MEC_ID') and  val_dom_typ_desc= 'Enumerated' and ihook.getColumnValue(row_ori,'SRC_PV') is not null) loop
  j := nci_11179.getWordCountDelim(ihook.getColumnValue(row_ori,'SRC_PV'),'\|');
  for k in 1..j loop
  v_nm :=upper(nci_11179.getWordDelim(ihook.getColumnValue(row_ori,'SRC_PV'),k,j,'|'));
  select count(*) into v_temp from perm_Val where val_dom_item_id = cur.val_dom_item_id and val_dom_Ver_nr = cur.val_dom_ver_nr and 
  upper(perm_val_nm) = v_nm;
  if (v_temp = 0) then
       v_valid := false;
     
  End if;
  end loop;
if (v_valid = false) then
    v_val_stus_msg := v_val_stus_msg ||'Source PV specified is not valid.' ||  chr(13);
end if;
  end loop;
  v_valid := true;
  for cur in (Select * from vw_nci_mec where mec_id = ihook.getColumnValue(row_ori,'TGT_MEC_ID') and val_dom_typ_desc = 'Enumerated' and ihook.getColumnValue(row_ori,'TGT_PV') is not null) loop
  j := nci_11179.getWordCountDelim(ihook.getColumnValue(row_ori,'TGT_PV'),'\|');
   for k in 1..j Loop
  v_nm :=upper(nci_11179.getWordDelim(ihook.getColumnValue(row_ori,'TGT_PV'),k,j,'|'));
  --raise_application_error(-20000,  j || '- ' || ihook.getColumnValue(row_ori,'TGT_PV') || '- ' || v_nm);
 select count(*) into v_temp from perm_Val where val_dom_item_id = cur.val_dom_item_id and val_dom_Ver_nr = cur.val_dom_ver_nr and 
  upper(perm_val_nm) = v_nm;
  if (v_temp = 0) then
       v_valid := false;
  
  End if;
  end loop;
  if (v_valid = false) then
        v_val_stus_msg := v_val_stus_msg ||'Target PV specified is not valid.' ||  chr(13);
        end if;
  end loop;
  
  end if;
    
  if (v_valid = false) then 
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','ERROR');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',v_val_stus_msg);
  else
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','VALIDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Valid');
  end if;
     rows.extend;   rows(rows.last) := row_ori;
 end if;
 end loop;
 
   action := t_actionrowset(rows, 'Value Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

END;
/
