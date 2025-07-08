create or replace PACKAGE            nci_codemap AS
  procedure updStatsModel (v_item_id in number, v_ver_nr in number) ;
    procedure spGenerateModelView ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number);
  procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spUpdateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);-- not used
  procedure spValidateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2); -- Validate Import
  procedure spVersionModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);-- not used. Create Version is used.
  procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number);
 procedure getModelElementCharAction ( row_ori in out t_row, rowscharins in out t_rows,rowscharupd in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure getModelElementCharActionDirect ( row_ori in out t_row, rowscharins in out t_rows,rowscharupd in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure getModelElementCharUpdateAction ( row_ori in out t_row, rowschar in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure spCreateModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spDeleteModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValidateModelAI ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2); -- Validate model from model maintenance
 procedure spUpdateModelCDEAssoc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateModelCDEAssocSub ( v_mdl_id in number, v_mdl_ver_nr in number, v_cnt in out integer, v_mode in varchar2, v_msg in out varchar2);
procedure spShowImportModelCount ( v_data_in in clob, v_data_out out clob); -- show summarized import model count
 procedure spDeleteModel( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure spDeleteModelElement  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2);
 procedure spDeleteModelElementChar(v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id in varchar2);
 procedure spUpdStatsModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 
 
END;
/
create or replace PACKAGE BODY            nci_codemap AS
c_long_nm_len  integer := 30;
c_nm_len integer := 255;
c_ver_suffix varchar2(5) := 'v1.00';
v_dflt_txt    varchar2(100) := 'Enter text or auto-generated.';
--v_reg_str varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}';
--  v_reg_str_adv varchar2(255) := '\(|\)|\;|\-|\_|\||\:|\$|\[|\]|\''|\"|\%|\*|\&|\#|\@|\{|\}|\s';
  v_reg_str_adv varchar2(255) := '[^A-Za-z0-9]';
v_reg_str varchar2(255) := '[^ A-Za-z0-9]';
  
  
  
  procedure updStatsModel (v_item_id in number, v_ver_nr in number) as
  i integer;
  begin
  --INT_1 - total char, INT_2 - with CDE, INT_3 - %
        update ADMIN_ITEM set (INT_1, INT_2, INT_3) =
        (Select count(*), 
        sum(decode(mec.cde_item_id, null,0,1)) ,
        round(sum(decode(mec.cde_item_id, null,0,1)) /count(*) *100)
        from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.mdl_item_id = v_item_id and me.mdl_item_ver_nr = v_ver_nr
        and me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr)
        where item_id = v_item_id and ver_nr = v_ver_nr;
        commit;
  end;
  
procedure spUpdStatsModel( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    row_ori t_row;
 v_item_id number;
v_ver_nr number(4,2);


BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori :=  hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
    UpdStatsModel(v_item_id, v_ver_nr);

    end loop;

hookoutput.message :=  'Model Mapping Statistics updated.';


  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);


END;

  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number)
  as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
  begin
 

select count(*) into v_temp from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM') )
and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_MDL_VER') ;
rows := t_rows();
row := t_row();
nci_11179_2.setStdAttr(row);
ihook.setColumnValue(row,'ADMIN_ITEM_TYP_ID', 57);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'ITEM_NM',ihook.getColumnvalue(row_ori, 'SRC_MDL_NM'));
ihook.setColumnValue(row,'PRMRY_MDL_LANG_ID',ihook.getColumnvalue(row_ori, 'PRMRY_MDL_LANG_ID'));
ihook.setColumnValue(row,'MDL_TYP_ID',ihook.getColumnvalue(row_ori, 'MDL_TYP_ID'));
ihook.setColumnValue(row,'ITEM_LONG_NM',v_mdl_hdr_id);
ihook.setColumnValue(row,'CNTXT_ITEM_ID',ihook.getColumnvalue(row_ori, 'CNTXT_ITEM_ID'));
ihook.setColumnValue(row,'CNTXT_VER_NR',ihook.getColumnvalue(row_ori, 'CNTXT_VER_NR'));
ihook.setColumnValue(row,'ITEM_DESC',nvl(ihook.getColumnvalue(row_ori, 'SRC_MDL_DESC'),ihook.getColumnvalue(row_ori, 'SRC_MDL_NM')));

if (v_temp = 0) then -- new model
v_mdl_hdr_id := nci_11179.getItemId;
ihook.setColumnValue(row,'ITEM_ID',v_mdl_hdr_id);
     rows.extend;
                                            rows(rows.last) := row;
            action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'insert');
        actions.extend;
        actions(actions.last) := action;

else
select max(item_id) into v_mdl_hdr_id from admin_item where admin_item_typ_id = 57 and upper(item_nm) = upper(ihook.getColumnvalue(row_ori, 'SRC_MDL_NM'))
and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_MDL_VER') ;
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
ihook.setColumnValue(row, 'ITEM_ID', v_mdl_hdr_id);
     rows.extend;
                                            rows(rows.last) := row;
     action := t_actionrowset(rows, 'Administered Item (No Sequence)', 2,2,'update');
        actions.extend;
        actions(actions.last) := action;
      action := t_actionrowset(rows, 'Model', 2,4,'update');
        actions.extend;
        actions(actions.last) := action;

end if;

 
 end;
 
 
 procedure getModelElementCharActionDirect ( row_ori in out t_row, rowscharins in out t_rows, rowscharupd in out t_rows,  v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2)
 as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
 v_mdl_elmnt_char_id number;
 v_mec_id number;
 v_ver number(4,2);
 v_temp_str varchar2(4000);
  begin

for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(v_mdl_elmnt_long_nm)) loop
--raise_application_error(-20000,v_mdl_elmnt_long_nm);

select count(*) into v_temp from NCI_MDL_ELMNT_CHAR where upper(MEC_PHY_NM) = upper(cur.MEC_PHY_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;

select nvl(cur.SRC_DEFLT_VAL,decode(nvl(cur.src_mand_ind,'X'),'EXPECTED',case upper(cur.SRC_DTTYPE) when 'INT' then '0' when 'BIGINT' then '0' when 'NUM' then '0'  when 'INTEGER' then '0' when 'FLOAT' then '0' when 'REAL' then '0'  else 'Null' end )) into v_temp_str from dual;

if (v_temp = 0) then -- insert
select NCI_SEQ_MEC.nextval into v_mec_id from dual;
v_ver := ihook.getColumnvalue(row_ori, 'SRC_MDL_VER');
insert into NCI_MDL_ELMNT_CHAR (MEC_ID, MDL_ELMNT_ITEM_ID, MDL_ELMNT_VER_NR,SRC_DTTYPE,STD_DTTYPE_ID,SRC_MAX_CHAR,SRC_MIN_CHAR,SRC_UOM,UOM_ID,
SRC_DEFLT_VAL,SRC_ENUM_SRC,MEC_LONG_NM,MEC_PHY_NM,MEC_DESC,CDE_ITEM_ID,CDE_VER_NR,DE_CONC_ITEM_ID,DE_CONC_VER_NR,VAL_DOM_ITEM_ID,
CHAR_ORD,VAL_DOM_VER_NR,MDL_ELMNT_CHAR_TYP_ID, PK_IND,FK_IND,
REQ_IND,FK_ELMNT_PHY_NM,FK_ELMNT_CHAR_PHY_NM, MDL_PK_IND)
values (v_mec_id, v_mdl_elmnt_id, v_ver, cur.SRC_DTTYPE, cur.STD_DTTYPE_ID,cur.SRC_MAX_CHAR,cur.SRC_MIN_CHAR, cur.SRC_UOM, cur.UOM_ID,
v_temp_str, cur.SRC_ENUM_SRC,cur.MEC_LONG_NM, cur.MEC_PHY_NM, cur.MEC_DESC, cur.CDE_ITEM_ID, cur.CDE_VER_NR,cur.DE_CONC_ITEM_ID, cur.DE_CONC_VER_NR,cur.VAL_DOM_ITEM_ID,
cur.CHAR_ORD,cur.VAL_DOM_VER_NR, cur.MDL_ELMNT_CHAR_TYP_ID,decode(nvl(upper(cur.PK_IND),'NO'),'YES',1,0),decode(nvl(upper(cur.FK_IND_TXT),'NO'),'YES',1,0),
decode(nvl(upper(cur.SRC_MAND_IND),'NO'),'YES',132,'MANDATORY',132,'NO',133,'EXPECTED', 134,'NOT MANDATORY',133,133),cur.FK_ELMNT_PHY_NM, cur.FK_ELMNT_CHAR_PHY_NM,decode(nvl(upper(cur.MDL_PK_IND),'NO'),'YES',1,0));

insert into onedata_Ra.NCI_MDL_ELMNT_CHAR (MEC_ID, MDL_ELMNT_ITEM_ID, MDL_ELMNT_VER_NR,SRC_DTTYPE,STD_DTTYPE_ID,SRC_MAX_CHAR,SRC_MIN_CHAR,SRC_UOM,UOM_ID,
SRC_DEFLT_VAL,SRC_ENUM_SRC,MEC_LONG_NM,MEC_PHY_NM,MEC_DESC,CDE_ITEM_ID,CDE_VER_NR,DE_CONC_ITEM_ID,DE_CONC_VER_NR,VAL_DOM_ITEM_ID,
CHAR_ORD,VAL_DOM_VER_NR,MDL_ELMNT_CHAR_TYP_ID, PK_IND,FK_IND,
REQ_IND,FK_ELMNT_PHY_NM,FK_ELMNT_CHAR_PHY_NM)
select v_mec_id, v_mdl_elmnt_id, v_ver, cur.SRC_DTTYPE, cur.STD_DTTYPE_ID,cur.SRC_MAX_CHAR,cur.SRC_MIN_CHAR, cur.SRC_UOM, cur.UOM_ID,
v_temp_str, cur.SRC_ENUM_SRC,cur.MEC_LONG_NM, cur.MEC_PHY_NM, cur.MEC_DESC, cur.CDE_ITEM_ID, cur.CDE_VER_NR,cur.DE_CONC_ITEM_ID, cur.DE_CONC_VER_NR,cur.VAL_DOM_ITEM_ID,
cur.CHAR_ORD,cur.VAL_DOM_VER_NR, cur.MDL_ELMNT_CHAR_TYP_ID,decode(nvl(upper(cur.PK_IND),'NO'),'YES',1,0),decode(nvl(upper(cur.FK_IND_TXT),'NO'),'YES',1,0),
decode(nvl(upper(cur.SRC_MAND_IND),'NO'),'YES',132,'MANDATORY',132,'NO',133,'EXPECTED', 134,'NOT MANDATORY',133,133),cur.FK_ELMNT_PHY_NM, cur.FK_ELMNT_CHAR_PHY_NM from dual;
end if;
if (v_temp = 1) then
select mec_id into v_mec_id from NCI_MDL_ELMNT_CHAR where upper(MEC_PHY_NM) = upper(cur.MEC_PHY_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');

update NCI_MDL_ELMNT_CHAR set 
SRC_DTTYPE = cur.SRC_DTTYPE,
STD_DTTYPE_ID = cur.STD_DTTYPE_ID,
SRC_MAX_CHAR=cur.SRC_MAX_CHAR,
SRC_MIN_CHAR= cur.SRC_MIN_CHAR,
SRC_UOM = cur.SRC_UOM,
UOM_ID = cur.UOM_ID,
SRC_DEFLT_VAL = v_temp_str,
SRC_ENUM_SRC = cur.SRC_ENUM_SRC,
MEC_LONG_NM= cur.MEC_LONG_NM,
MEC_PHY_NM = cur.MEC_PHY_NM,
MEC_DESC = cur.MEC_DESC,
CDE_ITEM_ID = cur.CDE_ITEM_ID,
CDE_VER_NR = cur.CDE_VER_NR,
DE_CONC_ITEM_ID = cur.DE_CONC_ITEM_ID,
DE_CONC_VER_NR = cur.DE_CONC_VER_NR,
VAL_DOM_ITEM_ID = cur.VAL_DOM_ITEM_ID,
CHAR_ORD = cur.CHAR_ORD,
VAL_DOM_VER_NR = cur.VAL_DOM_VER_NR,
MDL_ELMNT_CHAR_TYP_ID = cur.MDL_ELMNT_CHAR_TYP_ID,
PK_IND = decode(nvl(upper(cur.PK_IND),'NO'),'YES',1,0),
FK_IND = decode(nvl(upper(cur.FK_IND_TXT),'NO'),'YES',1,0),
MDL_PK_IND = decode(nvl(upper(cur.MDL_PK_IND),'NO'),'YES',1,0),
REQ_IND = decode(nvl(upper(cur.SRC_MAND_IND),'NO'),'YES',132,'MANDATORY',132,'NO',133,'EXPECTED', 134,'NOT MANDATORY',133,133),
FK_ELMNT_PHY_NM = cur.FK_ELMNT_PHY_NM,
FK_ELMNT_CHAR_PHY_NM = cur.FK_ELMNT_CHAR_PHY_NM
where MEC_ID = v_mec_id;
--ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
end if;

end loop;
 commit;
 end;


 procedure getModelElementCharAction ( row_ori in out t_row, rowscharins in out t_rows, rowscharupd in out t_rows,  v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2)
 as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp integer;
 v_mdl_elmnt_char_id number;
 v_mec_id number;
  begin
 


for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(v_mdl_elmnt_long_nm)) loop

select count(*) into v_temp from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;

--if (v_temp = 1) then -- update



row := t_row();

--ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'MDL_ELMNT_ITEM_ID',v_mdl_elmnt_id);
ihook.setColumnValue(row,'MDL_ELMNT_VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
--ihook.setColumnValue(row,'MEC_TYP_ID',v_mdl_elmnt_id);
ihook.setColumnValue(row,'SRC_DTTYPE',cur.SRC_DTTYPE);
ihook.setColumnValue(row,'STD_DTTYPE_ID',cur.STD_DTTYPE_ID);
ihook.setColumnValue(row,'SRC_MAX_CHAR',cur.SRC_MAX_CHAR);
ihook.setColumnValue(row,'SRC_MIN_CHAR',cur.SRC_MIN_CHAR);
ihook.setColumnValue(row,'SRC_UOM',cur.SRC_UOM);
ihook.setColumnValue(row,'UOM_ID',cur.UOM_ID);
ihook.setColumnValue(row,'SRC_DEFLT_VAL',cur.SRC_DEFLT_VAL);
ihook.setColumnValue(row,'SRC_ENUM_SRC',cur.SRC_ENUM_SRC);
ihook.setColumnValue(row,'MEC_LONG_NM',cur.MEC_LONG_NM);
ihook.setColumnValue(row,'MEC_PHY_NM',cur.MEC_PHY_NM);
ihook.setColumnValue(row,'MEC_DESC',cur.MEC_DESC);
ihook.setColumnValue(row,'CDE_ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'CDE_VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'DE_CONC_ITEM_ID',cur.DE_CONC_ITEM_ID);
ihook.setColumnValue(row,'DE_CONC_VER_NR',cur.DE_CONC_VER_NR);
ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',cur.VAL_DOM_ITEM_ID);
ihook.setColumnValue(row,'VAL_DOM_VER_NR',cur.VAL_DOM_VER_NR);
ihook.setColumnValue(row,'CHAR_ORD',cur.CHAR_ORD);
ihook.setColumnValue(row,'MDL_ELMNT_CHAR_TYP_ID',cur.MDL_ELMNT_CHAR_TYP_ID);
ihook.setColumnValue(row,'ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'NM_TYP_ID',ihook.getColumnValue(row_ori, 'ASSOC_NM_TYP_ID'));

ihook.setColumnValue(row,'NM_DESC',upper(v_mdl_elmnt_long_nm ||'.' || cur.mec_phy_nm));

ihook.setColumnValue(row,'CNTXT_ITEM_ID',ihook.getColumnValue(row_ori, 'CNTXT_ITEM_ID'));

ihook.setColumnValue(row,'CNTXT_VER_NR',ihook.getColumnValue(row_ori, 'CNTXT_VER_NR'));
if(upper(nvl(cur.PK_IND,'NO')) = 'YES') then
ihook.setColumnValue(row,'PK_IND',1);
end if;
ihook.setColumnValue(row,'FK_IND',0);
if(upper(nvl(cur.FK_IND_TXT,'NO')) = 'YES') then
ihook.setColumnValue(row,'FK_IND',1);
end if;
ihook.setColumnValue(row,'REQ_IND',0);
if(upper(nvl(cur.SRC_MAND_IND,'NO')) = 'YES') then
ihook.setColumnValue(row,'REQ_IND',1);
end if;
ihook.setColumnValue(row,'FK_ELMNT_PHY_NM',cur.FK_ELMNT_PHY_NM);
ihook.setColumnValue(row,'FK_ELMNT_CHAR_PHY_NM',cur.FK_ELMNT_CHAR_PHY_NM );
if (v_temp = 0) then -- new characteristics
ihook.setColumnValue(row,'MEC_ID', -1);
  rowscharins.extend;
    rowscharins(rowscharins.last) := row;

else
select mec_id into v_mec_id from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
ihook.setColumnValue(row,'MEC_ID', v_mec_id);
 rowscharupd.extend;
    rowscharupd(rowscharupd.last) := row;
end if;



end loop;
 
 end;


 procedure getModelElementCharUpdateAction ( row_ori in out t_row, rowschar in out t_rows,   v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2)
 as
  action t_actionRowset;
  row t_row;
  rows  t_rows;
 v_temp number;
 v_mdl_elmnt_char_id number;
  begin
 


for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(v_mdl_elmnt_long_nm)) loop
v_temp := 0;
select MEC_ID into v_temp from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
if (v_temp <> 0) then -- new characteristics
row := t_row();
ihook.setColumnValue(row,'MEC_ID', v_temp);
ihook.setColumnValue(row,'CDE_ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'CDE_VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'DE_CONC_ITEM_ID',cur.DE_CONC_ITEM_ID);
ihook.setColumnValue(row,'DE_CONC_VER_NR',cur.DE_CONC_VER_NR);
ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',cur.VAL_DOM_ITEM_ID);
ihook.setColumnValue(row,'VAL_DOM_VER_NR',cur.VAL_DOM_VER_NR);
ihook.setColumnValue(row,'CHAR_ORD',cur.CHAR_ORD);
if(upper(nvl(cur.PK_IND,'NO')) = 'YES') then
ihook.setColumnValue(row,'PK_IND',1);
end if;
ihook.setColumnValue(row,'FK_IND',0);
if(upper(nvl(cur.FK_IND_TXT,'NO')) = 'YES') then
ihook.setColumnValue(row,'FK_IND',1);
end if;
ihook.setColumnValue(row,'FK_ELMNT_PHY_NM',cur.FK_ELMNT_PHY_NM);
ihook.setColumnValue(row,'FK_ELMNT_CHAR_PHY_NM',cur.FK_ELMNT_CHAR_PHY_NM );
  rowschar.extend;
 rowschar(rowschar.last) := row;

end if;
end loop;
 
 end;
  
  
 procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number)
  as
  action t_actionRowset;
  row t_row;
  rowsmeins  t_rows;
   rowsmeupd  t_rows;
 v_temp integer;
  rowscharins  t_rows;
  rowscharupd t_rows;
  rowsaltnm t_rows;
  v_me_typ_id integer;
  begin
 

rowsmeins := t_rows();
rowsmeupd := t_rows();
rowsaltnm := t_rows();
rowscharins := t_rows();
rowscharupd := t_rows();
select obj_key_id into v_me_typ_Id from obj_key where obj_typ_id = 41 and upper(obj_key_desc) ='TABLE';

for cur in (select * from NCI_STG_MDL_ELMNT where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') ) loop

select count(*) into v_temp from NCI_MDL_ELMNT where upper(ITEM_PHY_OBJ_NM) = upper(cur.ITEM_PHY_OBJ_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
row := t_row();
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'MDL_ITEM_ID',v_mdl_hdr_id);
ihook.setColumnValue(row,'MDL_ITEM_VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));
ihook.setColumnValue(row,'ITEM_LONG_NM',cur.ITEM_LONG_NM);
ihook.setColumnValue(row,'ITEM_PHY_OBJ_NM',cur.ITEM_PHY_OBJ_NM);
ihook.setColumnValue(row,'ITEM_DESC',cur.ITEM_DESC);
ihook.setColumnValue(row,'ME_TYP_ID',cur.me_typ_id); -- temporary
ihook.setColumnValue(row,'ME_GRP_ID',cur.me_grp_Id);

if (v_temp = 0) then -- new characteristics
v_mdl_elmnt_id := nci_11179.getItemId;
ihook.setColumnValue(row,'ITEM_ID', v_mdl_elmnt_id);


     rowsmeins.extend;
                                            rowsmeins(rowsmeins.last) := row;


else
select item_id into v_mdl_elmnt_id from NCI_MDL_ELMNT where upper(item_PHY_OBJ_nm) = upper(cur.ITEM_PHY_OBJ_NM) and mdl_item_id = v_mdl_hdr_id and mdl_item_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
ihook.setColumnValue(row,'ITEM_ID', v_mdl_elmnt_id);
ihook.setColumnValue(row,'VER_NR',ihook.getColumnvalue(row_ori, 'SRC_MDL_VER'));

     rowsmeupd.extend;
                                            rowsmeupd(rowsmeupd.last) := row;
end if;
--getModelElementCharAction ( row_ori, rowscharins , rowscharupd, v_mdl_elmnt_id, cur.item_long_nm);

-- even though the column nae in NCI_STG_MMDL_ELMNT_CHAR is ME_ITEM_LONG_NM, the actual value is Physical Name
--raise_application_error (-20000,'here');
getModelElementCharActionDirect ( row_ori, rowscharins , rowscharupd, v_mdl_elmnt_id, cur.item_phy_obj_nm);

end loop;
if (rowsmeins.count > 0) then
            action := t_actionrowset(rowsmeins, 'Model Element (No Sequence)', 2,5,'insert');
        actions.extend;
        actions(actions.last) := action;
end if;
if (rowsmeupd.count > 0) then
            action := t_actionrowset(rowsmeupd, 'Model Element (No Sequence)', 2,5,'update');
        actions.extend;
        actions(actions.last) := action;
end if;

/*if (rowscharins.count > 0) then
 
           action := t_actionrowset(rowscharins, 'Model Element Characteristics', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
end if;
if (rowscharupd.count > 0) then
 
           action := t_actionrowset(rowscharupd, 'Model Element Characteristics', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
end if; */
--raise_application_error(-20000,'1' || rowsmeins.count  ||' : ' || rowsmeupd.count || ' , ' ||rowscharins.count || ' : ' || rowscharupd.count );
--raise_application_error(-20000,'1' || rowsmeins.count  );
   /*  
     -- Altenrate name 
     for i in 1..rowschar.count loop
     row := rowschar(i);
     ihook.setColumnValue(row,'NM_ID',-1);
     
     if (ihook.getColumnValue(row,'NM_TYP_ID') is not null) then
     
     select count(*) into v_temp from alt_nms where nm_typ_id = ihook.getColumnValue(row,'NM_TYP_ID') and upper(nm_desc) = upper(ihook.getColumnValue(row,'NM_DESC'))
     and cntxt_item_id = ihook.getColumnValue(row,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row,'CNTXT_VER_NR');
     
     if (v_temp = 0) then 
            rowsaltnm.extend;                       
            rowsaltnm(rowsaltnm.last) := row;

     end if;
     end if;
    end loop;
    
    if (rowsaltnm.count > 0) then 
           action := t_actionrowset(rowsaltnm, 'Alternate Names', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
     */  
 
 end;
 

procedure spDeleteModel  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
     row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
 
  rowform t_row;
v_found boolean;
 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
 v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
 
 
 if (hookinput.invocationnumber = 0) then 
 -- verfiy no model mapping exist
 for cur in (Select * from nci_mdl_map where (SRC_MDL_ITEM_ID = v_item_id and SRC_MDL_VER_NR=v_ver_nr) or 
 (TGT_MDL_ITEM_ID = v_item_id and TGT_MDL_VER_NR=v_ver_nr)) loop
   hookoutput.message := 'Model cannot be deleted. Associated with Model Mapping ID: ' ||cur.item_id;
     V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     return;
 end loop;
 -- verify that this is either the only version or is not a current version
 if (ihook.getColumnValue(row_Ori, 'CURRNT_VER_IND')=1) then
 for cur in (Select count(*) from admin_item where item_id= v_item_id group by item_id having count(*) > 1) loop
   hookoutput.message := 'Model cannot be deleted as it is the latest version. Use ''Select Latest Version'' to change latest version first.';
     V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     return;
 end loop;
 end if;
 hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model: ' || ihook.getColumnValue (row_ori,'ITEM_NM') || ' (' ||v_item_id || 'v' || v_ver_nr || ')');
 end if;
 
if (hookinput.invocationnumber = 1) then 
delete from nci_mdl_elmnt_char where (mdl_elmnt_item_id, mdl_elmnt_ver_nr) in (select item_id, ver_nr from nci_mdl_elmnt 
where mdl_item_id = v_item_id and mdl_item_ver_nr = v_ver_nr);

delete from onedata_ra.nci_mdl_elmnt_char where (mdl_elmnt_item_id, mdl_elmnt_ver_nr) in (select item_id, ver_nr from nci_mdl_elmnt 
where mdl_item_id = v_item_id and mdl_item_ver_nr = v_ver_nr);

delete from nci_mdl_elmnt where  mdl_item_id = v_item_id and mdl_item_ver_nr = v_ver_nr;
delete from onedata_ra.nci_mdl_elmnt where  mdl_item_id = v_item_id and mdl_item_ver_nr = v_ver_nr;


delete from nci_mdl where  item_id = v_item_id and ver_nr = v_ver_nr;
delete from onedata_ra.nci_mdl where  item_id = v_item_id and ver_nr = v_ver_nr;


delete from admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
delete from onedata_ra.admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
commit;

hookoutput.message :=  'Model deleted successfully: ' || v_item_id || 'v'|| v_ver_Nr;
end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spDeleteModelElement  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
     row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
 v_mdl_id number;
 v_mdl_ver_nr number(4,2);
 
  rowform t_row;
v_found boolean :=false;
v_mdl_nm varchar2(255);
tmp_mdl_str varchar(2000) := ' ' ;
v_map_ind boolean;
 
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  tmp_mdl_str := ' ';
  
  if (hookinput.invocationnumber = 0) then 
 -- verfiy no model mapping exist
            for i in 1..hookInput.originalRowset.rowset.count loop
                row_ori :=  hookInput.originalRowset.rowset(i);
                v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
                v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR'); 
                tmp_mdl_str := tmp_mdl_str || chr(13) || 'Element: ' || ihook.getColumnValue(row_ori,'ITEM_LONG_NM') || ' used in: ' ;
              v_map_ind := false;
                for cur in (select distinct mdl_map_item_id, mdl_map_ver_nr from nci_mec_map where 
                             (nci_mec_map.src_mec_id in (select mec_id from nci_mdl_elmnt_char where mdl_elmnt_item_id = v_item_id and mdl_elmnt_ver_nr = v_ver_nr) OR
                                nci_mec_map.tgt_mec_id in (select mec_id from nci_mdl_elmnt_char where mdl_elmnt_item_id = v_item_id and mdl_elmnt_ver_nr = v_ver_nr))) loop
              --  raise_application_error(-20000,tmp_mdl_str || '-'|| cur.item_id);
                    v_map_ind := true;
                    v_found := true;
                             tmp_mdl_str := tmp_mdl_str || to_char(cur.mdl_map_item_id) || 'v' || to_char(cur.mdl_map_ver_nr) || '; ';
                    --hookoutput.message := 'Model Element cannot be deleted. Its characteristics are associated with Model Mapping ID: ' || cur.item_id || ' - ' || v_mdl_nm;
                   -- V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
                    --return;
                end loop;
                   if (v_map_ind = false) then
                tmp_mdl_str := tmp_mdl_str || ' None';
                end if;
    
            end loop;
            
                 
        if (v_found = true) then
            hookoutput.message := 'Model Element cannot be deleted as its characteristics are used in mapping. ' || tmp_mdl_str;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
        end if;
        hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model Elements.');
    end if;
if (hookinput.invocationnumber = 1) then
  
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori :=  hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
        v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
        v_mdl_id := ihook.getColumnValue(row_ori, 'MDL_ITEM_ID');
        v_mdl_ver_nr := ihook.getColumnValue(row_ori, 'MDL_ITEM_VER_NR');
 
 
--delete from nci_mdl_elmnt_char where (mdl_elmnt_item_id, mdl_elmnt_ver_nr) in (select item_id, ver_nr from nci_mdl_elmnt 
--where mdl_item_id = v_mdl_id and mdl_item_ver_nr = v_mdl_ver_nr and item_id = v_item_id and ver_nr = v_ver_nr);
--
--delete from onedata_ra.nci_mdl_elmnt_char where (mdl_elmnt_item_id, mdl_elmnt_ver_nr) in (select item_id, ver_nr from nci_mdl_elmnt 
--where mdl_item_id = v_mdl_id and mdl_item_ver_nr = v_mdl_ver_nr and item_id = v_item_id and ver_nr = v_ver_nr);

        delete from nci_mdl_elmnt_char where mdl_elmnt_item_id = v_item_id and mdl_elmnt_ver_nr = v_ver_nr;
        delete from onedata_ra.nci_mdl_elmnt_char where mdl_elmnt_item_id = v_item_id and mdl_elmnt_ver_nr = v_ver_nr;

        delete from nci_mdl_elmnt where  mdl_item_id = v_mdl_id and mdl_item_ver_nr = v_mdl_ver_nr and item_id = v_item_id and ver_nr = v_ver_nr;
        delete from onedata_ra.nci_mdl_elmnt where  mdl_item_id = v_mdl_id and mdl_item_ver_nr = v_mdl_ver_nr and item_id = v_item_id and ver_nr = v_ver_nr;

        commit;
    end loop;

hookoutput.message :=  'Model Element(s) and Characteristic(s) deleted successfully.';
end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

procedure spValidateModelAI  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
     showRowset     t_showableRowset;

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
     row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
 v_assoc_tbl_nm_typ_id integer;
 v_assoc_nm_typ_id integer;
  rowform t_row;
v_found boolean;
msg1 varchar2(4000);
v_valid boolean := true;
 j integer;
 msg varchar2(8000);
 v_temp integer;
 v_cs_item_id number;
 v_cs_ver_nr number(4,2);
  v_item_user_name VARCHAR2(100);
  v_item_long_nm   VARCHAR2(255);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
 row_ori :=  hookInput.originalRowset.rowset(1);
 v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
 v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
 
 j:= 0;
 msg :='ERROR: Model cannot be Released.' ;
 
 rows := t_rows();
   for curmodel in (select * from nci_mdl where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
        if (curmodel.assoc_nm_typ_id is null or curmodel.assoc_nm_typ_id='' ) then
            msg := msg || chr(13) || 'Model Characteristic Alternate Name Type not set.';
            row := t_row();
            ihook.setColumnValue(row,'Issue', 'Model Characteristic Alternate Name Type not set.');
            rows.extend; rows(rows.last) := row;
            v_valid := false; 
        else
            v_assoc_nm_typ_id := curmodel.assoc_nm_typ_id;
        end if;
    
        if (curmodel.ASSOC_TBL_NM_TYP_ID is null) then
            msg :=msg || chr(13) || 'Model Element Alternate Name Type not set.';
            row := t_row();
            ihook.setColumnValue(row,'Issue', 'Model Element Alternate Name Type not set.');
            rows.extend; rows(rows.last) := row;
            v_valid := false; 
        else
            v_assoc_tbl_nm_typ_id := curmodel.assoc_tbl_nm_typ_id;
        end if;
  
        if (curmodel.ASSOC_CS_ITEM_ID is null) then
            msg :=substr(msg || chr(13) || 'Model Classification Scheme not set.',1,4000);
                      row := t_row();
            ihook.setColumnValue(row,'Issue', 'Model Classification Scheme not set.');
            rows.extend; rows(rows.last) := row;
  
            v_valid := false; 
        else
            v_cs_item_id := curmodel.ASSOC_CS_ITEM_ID;
            v_cs_ver_nr := curmodel.ASSOC_CS_VER_NR;
        end if;
  
    end loop;
    -- model - do not allow released if max length is missing.
    for cur in (select me.ITEM_PHY_OBJ_NM ME_PHY_NM, MEC_PHY_NM from nci_mdl_elmnt_char mec, nci_mdl_elmnt me where me.mdl_item_id = v_item_id and me.mdl_item_ver_nr = v_ver_nr 
    and mec.mdl_elmnt_item_id =me.item_id and mec.mdl_elmnt_ver_nr = me.ver_nr and nvl(mec.SRC_MAX_CHAR,0) = 0
    and (upper(mec.SRC_DTTYPE) like '%CHAR%' or upper(mec.SRC_DTTYPE) like '%TEXT%' or upper(mec.SRC_DTTYPE) like '%STRING%')) loop
        j:= j+1;
        if (j < 11) then
        msg1 := substr(msg1 || cur.ME_PHY_NM || '.' || cur.MEC_PHY_NM || ', ',1,4000) ;
        end if;
    end loop;
        
    
    if (j > 0) then
       -- msg := substr(msg || j || ' Characteristics with Character/Text/String datatype do not have a required Max Length. Examples: ' || substr(msg1, 1, length(msg1)-1),1,4000);
            row := t_row();
        --    ihook.setColumnValue(row,'Issue', 'Some Characteristics with Character/Text/String datatype do not have a required Max Length: ' || substr(msg1, 1, length(msg1)-1));
            ihook.setColumnValue(row,'Issue', 'Max length missing for ' || j || ' Character/Text/String datatypes. First 10 are listed in Details.');
            ihook.setColumnValue(row,'Details',  substr(msg1, 1, length(msg1)-2));
            rows.extend; rows(rows.last) := row;
        
        v_valid := false;
    end if;
    
    -- model - do not allow released if alternate names and classification is missing.
  
    -- check alternate names
  --  if (v_valid = true) then
        j:= 0;
        msg1 := '';
        for curchar in (select cde_item_id, cde_ver_nr, me.ITEM_PHY_OBJ_NM ME_PHY_NM, mec.MEC_PHY_NM  
        from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr and mec.cde_item_id is not null
        and me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
     
            select count(*) into v_temp from alt_nms where nm_typ_id = v_assoc_NM_TYP_ID and upper(nm_desc) = upper(curchar.MEC_PHY_NM)
            and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
            and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr;
     
            if (v_temp = 0) then 
                j:= j+1;
      --          msg1 := substr(msg1 || curchar.ME_PHY_NM || '.' || curchar.MEC_PHY_NM || ', ',1,4000) ;
                   msg1 := substr(msg1 ||curchar.me_phy_nm || '.'||curchar.mec_phy_nm || ':'|| curchar.cde_item_id || 'v' || curchar.cde_ver_nr || ', ',1,4000) ;
            else
                select count(*) into v_temp from alt_nms where nm_typ_id = v_assoc_tbl_NM_TYP_ID and upper(nm_desc) = upper(curchar.ME_PHY_NM)
                and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
                and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr;
                if (v_temp = 0) then 
                    j:= j+1;
                 --   msg1 := substr(msg1 || curchar.ME_PHY_NM || '.' || curchar.MEC_PHY_NM || ', ',1,4000) ;
                   msg1 := substr(msg1  ||curchar.me_phy_nm || '.'||curchar.mec_phy_nm || ':'|| curchar.cde_item_id || 'v' || curchar.cde_ver_nr || ', ',1,4000) ;
                end if;
            end if;
        end loop;
    
        if (j > 0) then
            msg := substr(msg || chr(13) || 'Alternate Names missing for some elements/characteristics. ' || msg1,1,4000);
            row := t_row();
       --     ihook.setColumnValue(row,'Issue', 'Alternate Names missing for some elements/characteristics. Please use create Alternate Name command first: ' || msg1);
            ihook.setColumnValue(row,'Issue', 'Alternate Names missing for Element. Characteristics'' CDEs. See Details.' );
            ihook.setColumnValue(row,'Details',  substr(msg1, 1, length(msg1)-2));
            rows.extend; rows(rows.last) := row;
            
            v_valid := false;
        end if;
  --  end if;
    -- check classification
   -- if (v_valid = true) then
        msg1 := '';
        j :=0;
        for curchar in (select distinct cde_item_id, cde_ver_nr 
        from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr and mec.cde_item_id is not null
        and me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
        and (cde_item_id, cde_ver_nr) not in (Select r.c_item_id, r.c_item_ver_nr from nci_admin_item_rel r, vw_clsfctn_schm_item csi 
        where csi.cs_item_id = v_cs_item_id 
  and csi.cs_item_ver_nr = v_cs_ver_nr and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr and r.rel_typ_id = 65)) loop
            v_valid := false;
            j:= j+1;
                msg1 := substr(msg1 || curchar.cde_item_id || 'v' || curchar.cde_ver_nr || ', ',1,4000) ;
            
        end loop;
    
        if (j > 0) then
            msg := substr(msg || chr(13) || 'Missing classifications for CDE: ' || msg1,1,4000);
             row := t_row();
        --    ihook.setColumnValue(row,'Issue', 'Missing classifications for CDE: ' || msg1);
            ihook.setColumnValue(row,'Issue', 'Classifications missing for Element. Characteristics'' CDEs. See Details');
            ihook.setColumnValue(row,'Details',  substr(msg1, 1, length(msg1)-2));
            rows.extend; rows(rows.last) := row;
            v_valid := false;
        end if;
   -- end if;
    msg := '';
    select listagg(me.ITEM_PHY_OBJ_NM,',') within group (order by me.ITEM_PHY_OBJ_NM) into msg from nci_mdl_elmnt me where 
    me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
    and (item_id, ver_nr) in (select mec.mdl_elmnt_item_id, mec.mdl_elmnt_ver_nr 
    from nci_mdl_elmnt_char mec, nci_mdl_elmnt me1 where me1.item_id = mec.mdl_elmnt_item_id 
    and me1.ver_nr = mec.mdl_elmnt_ver_nr and 
    me1.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me1.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
    group by mec.mdl_elmnt_item_id, mec.mdl_elmnt_ver_nr
    having sum(PK_IND) =0);
   -- raise_application_error(-20000, nvl(msg,'Is Null'));
    if (msg is not null) then
       v_valid := false;
         row := t_row();
        --    ihook.setColumnValue(row,'Issue', 'Missing classifications for CDE: ' || msg1);
            ihook.setColumnValue(row,'Issue', 'Natural Key missing for the elements:');
            ihook.setColumnValue(row,'Details', msg);
            rows.extend; rows(rows.last) := row;
    end if;
    msg := '';
    select listagg(me.ITEM_PHY_OBJ_NM,',') within group (order by me.ITEM_PHY_OBJ_NM) into msg from nci_mdl_elmnt me where 
    me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
    and (item_id, ver_nr) in (select mec.mdl_elmnt_item_id, mec.mdl_elmnt_ver_nr 
    from nci_mdl_elmnt_char mec, nci_mdl_elmnt me1 where me1.item_id = mec.mdl_elmnt_item_id 
    and me1.ver_nr = mec.mdl_elmnt_ver_nr and 
    me1.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me1.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')
    group by mec.mdl_elmnt_item_id, mec.mdl_elmnt_ver_nr
    having sum(MDL_PK_IND) =0);
   -- raise_application_error(-20000, nvl(msg,'Is Null'));
    if (msg is not null) then
       v_valid := false;
         row := t_row();
        --    ihook.setColumnValue(row,'Issue', 'Missing classifications for CDE: ' || msg1);
            ihook.setColumnValue(row,'Issue', 'Primary Key missing for the elements:');
            ihook.setColumnValue(row,'Details', msg);
            rows.extend; rows(rows.last) := row;
    end if;
    
    -- { 07/07/25 (RV Tracker DSRMWS-4066) 
    -- Add Model User Name, Model Long Name, Public ID and Version to the popup
        BEGIN
            SELECT creat_usr_id_x, item_long_nm
            INTO v_item_user_name, v_item_long_nm
            FROM admin_item 
            WHERE item_id = v_item_id
              AND ver_nr = v_ver_nr
              AND ROWNUM = 1;
        EXCEPTION  -- this should never happen unless for a bad data
            WHEN NO_DATA_FOUND THEN
                v_item_user_name := 'null';
                v_item_long_nm := 'null';
        END;

        IF ( v_valid = false ) THEN
            -- raise_application_error(-20000, msg);
            -- showRowset := t_showableRowset(rows, 'Issues with Model Validation for: ' || ihook.getColumnValue(row_ori, 'ITEM_NM') || ';' || ihook.getColumnValue(row_ori,'ITEM_ID') || 'v' || ihook.getColumnValue(row_ori,'VER_NR'),4, 'unselectable');
            showrowset := t_showablerowset(
                              rows,
                              'Issues with Model Validation for: '
                              || v_item_user_name || ';'
                              || v_item_long_nm || ';'
                              || v_item_id || 'v' || v_ver_nr,
                              4,
                              'unselectable');
            hookoutput.showrowset := showrowset;
            -- } 07/07/25 (RV Tracker DSRMWS-4066) 
        ELSE

       /*     -- change status
            row := t_row();
            rows := t_rows();
            ihook.setcolumnvalue(row, 'ITEM_ID', v_item_id);
            ihook.setcolumnvalue(row, 'VER_NR', v_ver_nr);
            ihook.setcolumnvalue(row, 'ADMIN_STUS_ID', 75);
            
    rows.EXTEND;
            rows (rows.LAST) := row;
    --        raise_application_erro20000,ihook.getColumnValue(row_ori,'ITEM_NM_CURATED');
            action :=
                t_actionrowset (rows,
                                'Model AI',
                                2,
                                0,
                                'update');
            actions.EXTEND;
            actions (actions.LAST) := action;
             hookoutput.actions := actions;*/
           hookoutput.message := 'Model is valid. No issues found.';
           
   end if;
   
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;

   procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  getModelAction(row_ori,actions, v_mdl_hdr_id);
--  raise_application_error(-20000,v_mdl_hdr_id);
 
  for cur in (select p.item_id prnt_item_id, p.ver_nr prnt_item_ver_nr, c.item_id chld_item_id, c.ver_nr  chld_item_ver_nr, r.PRNT_MDL_ELMNT_LONG_NM,
  r.CHLD_MDL_ELMNT_LONG_NM from NCI_STG_MDL_ELMNT_REL r, nci_mdl_elmnt p,  nci_mdl_elmnt c
  where r.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and p.mdl_item_id = v_mdl_hdr_id and c.mdl_item_id = v_mdl_hdr_id 
 -- and p.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')and c.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')
  and p.ITEM_LONG_NM=r.PRNT_MDL_ELMNT_LONG_NM and c.item_long_nm = r.chld_MDL_ELMNT_LONG_NM
  and (p.item_id , p.ver_nr , c.item_id , c.ver_nr) not in (select prnt_item_id, prnt_item_ver_nr, chld_item_id, chld_item_ver_nr from NCI_MDL_ELMNT_REL)) loop
    row := t_row();
    ihook.setColumnValue(row,'REL_TYP_ID',77);
    ihook.setColumnValue(row,'PRNT_ITEM_ID',cur.PRNT_ITEM_ID);
    ihook.setColumnValue(row,'PRNT_ITEM_VER_NR',cur.PRNT_ITEM_VER_NR);
     ihook.setColumnValue(row,'CHLD_ITEM_ID',cur.CHLD_ITEM_ID);
    ihook.setColumnValue(row,'CHLD_ITEM_VER_NR',cur.CHLD_ITEM_VER_NR);
    ihook.setColumnValue(row,'REL_ID',-1);
    
    rows.extend;   rows(rows.last) := row;
  end loop;
 -- raise_application_error (-20000,'Here');
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Element Relationship', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_dflt_typ integer;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') != 'VALIDATED') then
  raise_application_error(-20000, 'Please validate model first.');
  end if;
 
   update nci_stg_mdl_elmnt set item_long_nm = item_phy_obj_nm where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ITEM_LONG_NM is null;
  commit;
   update nci_stg_mdl_elmnt_char set mec_long_nm = mec_phy_nm where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and mec_LONG_NM is null;
  commit;
 -- validate ME type id else default Semantic Model - Class. Physical Model - Table
 
 /* select obj_key_id into v_dflt_typ from obj_key where obj_typ_id = 52 and upper(obj_key_desc) = 'COLUMN';
 
 update nci_stg_mdl_elmnt_char set MDL_ELMNT_CHAR_TYP_ID	=v_dflt_typ where MDL_ELMNT_CHAR_TYP_ID	is null and mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
 commit;
  select obj_key_id into v_dflt_typ from obj_key where obj_typ_id = 41 and upper(obj_key_desc) = 'TABLE';
 
 update nci_stg_mdl_elmnt set ME_TYP_ID	=v_dflt_typ where ME_TYP_ID	is null and mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
 commit;
 */
 update nci_stg_mdl_elmnt_char set (val_dom_item_id, val_dom_ver_nr) = (select val_dom_item_id, val_dom_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;

 update nci_stg_mdl_elmnt_char set (de_conc_item_id, de_conc_ver_nr) = (select de_conc_item_id, de_conc_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;
 
  
  --getModelAction(row_ori,actions, v_mdl_hdr_id);
  v_mdl_hdr_id := ihook.getColumnValue(row_ori,'CREATED_MDL_ITEM_ID');
getModelElementAction ( row_ori ,actions , v_mdl_hdr_id , v_mdl_elmnt_id );
 
 -- raise_application_error(-20000,v_mdl_hdr_id);
 
 
  for cur in (select p.item_id prnt_item_id, p.ver_nr prnt_item_ver_nr, c.item_id chld_item_id, c.ver_nr  chld_item_ver_nr, r.PRNT_MDL_ELMNT_LONG_NM,
  r.CHLD_MDL_ELMNT_LONG_NM from NCI_STG_MDL_ELMNT_REL r, nci_mdl_elmnt p,  nci_mdl_elmnt c
  where r.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and p.mdl_item_id = v_mdl_hdr_id and c.mdl_item_id = v_mdl_hdr_id 
 -- and p.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')and c.mdl_item_ver_nr  = ihook.getColumnValue(row_ori,'SRC_VER_NR')
  and p.ITEM_LONG_NM=r.PRNT_MDL_ELMNT_LONG_NM and c.item_long_nm = r.chld_MDL_ELMNT_LONG_NM
  and (p.item_id , p.ver_nr , c.item_id , c.ver_nr) not in (select prnt_item_id, prnt_item_ver_nr, chld_item_id, chld_item_ver_nr from NCI_MDL_ELMNT_REL)) loop
    row := t_row();
    ihook.setColumnValue(row,'REL_TYP_ID',77);
    ihook.setColumnValue(row,'PRNT_ITEM_ID',cur.PRNT_ITEM_ID);
    ihook.setColumnValue(row,'PRNT_ITEM_VER_NR',cur.PRNT_ITEM_VER_NR);
     ihook.setColumnValue(row,'CHLD_ITEM_ID',cur.CHLD_ITEM_ID);
    ihook.setColumnValue(row,'CHLD_ITEM_VER_NR',cur.CHLD_ITEM_VER_NR);
    ihook.setColumnValue(row,'REL_ID',-1);
    
    rows.extend;   rows(rows.last) := row;
  end loop;
 -- raise_application_error (-20000,'Here');
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Element Relationship', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
    
    rows := t_rows();
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','UPDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Model updated - ' || sysdate || '.');
  --ihook.setColumnValue(row_ori, 'CREATED_MDL_ITEM_ID',v_mdl_hdr_id);
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  
 
    
      hookoutput.actions := actions;
      
      --jira 4065: set model element validation message to show update was successful
      UPDATE nci_stg_mdl_elmnt
      SET ctl_val_msg = 'Update Command Successful'
      WHERE mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
      COMMIT;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
 --  raise_application_error(-20000,'Here');
end;



   procedure spCreateModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  
 /*  if (ihook.getColumnValue(row_ori,'ADMIN_STUS_ID') <> 75) then
   hookoutput.message :='Model needs to be released first.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    return;
   --  raise_application_error(-20000,'Model needs to be released first.');
    end if;*/
  
  for curmodel in (select * from nci_mdl where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
   if (curmodel.assoc_nm_typ_id is null) then
   hookoutput.message :='Model Characteristic Alternate Name Type not set.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    return;
     end if;
    if (curmodel.ASSOC_TBL_NM_TYP_ID is null) then
   hookoutput.message :='Model Element Alternate Name Type not set.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    return;
     end if;

    row := t_row();
    
     ihook.setColumnValue(row,'NM_ID',-1);
     ihook.setColumnValue(row,'CNTXT_ITEM_ID',ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID'));
     ihook.setColumnValue(row,'CNTXT_VER_NR',ihook.getColumnValue(row_ori,'CNTXT_VER_NR'));
     
     for curchar in (select cde_item_id, cde_ver_nr, me.ITEM_PHY_OBJ_NM ME_PHY_NM, mec.MEC_PHY_NM  from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr and mec.cde_item_id is not null
     and me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
     
     select count(*) into v_temp from alt_nms where nm_typ_id = curmodel.assoc_NM_TYP_ID and upper(nm_desc) = upper(curchar.MEC_PHY_NM)
     and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
     and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr;
     
--raise_application_error(-20000,v_temp || curchar.cde_item_id);
    
     if (v_temp = 0) then 
     ihook.setColumnValue(row,'VER_NR',curchar.cde_VER_NR);
     ihook.setColumnValue(row,'ITEM_ID',curchar.cde_ITEM_ID);
     ihook.setColumnValue(row,'NM_TYP_ID',curmodel.assoc_nm_typ_id);
     ihook.setColumnValue(row,'NM_DESC',upper(curchar.mec_PHY_NM));
     
            rows.extend;                       
            rows(rows.last) := row;

     end if;
    
     select count(*) into v_temp from alt_nms where nm_typ_id = curmodel.assoc_tbl_NM_TYP_ID and upper(nm_desc) = upper(curchar.ME_PHY_NM)
     and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
     and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr;
     
--raise_application_error(-20000,v_temp || curchar.cde_item_id);
    
     if (v_temp = 0) then 
     ihook.setColumnValue(row,'VER_NR',curchar.cde_VER_NR);
     ihook.setColumnValue(row,'ITEM_ID',curchar.cde_ITEM_ID);
     ihook.setColumnValue(row,'NM_TYP_ID',curmodel.assoc_tbl_nm_typ_id);
     ihook.setColumnValue(row,'NM_DESC',upper(curchar.me_phy_nm));
     
            rows.extend;                       
            rows(rows.last) := row;

     end if;
    
     end loop;
    end loop;
    
    if (rows.count > 0) then 
           action := t_actionrowset(rows, 'Alternate Names', 2,10,'insert');
        actions.extend;
        actions(actions.last) := action;
       hookoutput.actions := actions;
   
    end if;
        hookoutput.message := rows.count || ' alternate names were created.';
     
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spDeleteModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  for curmodel in (select * from nci_mdl where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
   if (curmodel.assoc_nm_typ_id is null) then
   hookoutput.message :='Alternate Name Type not set.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
    return;
     end if;
     
     for curchar in (select cde_item_id, cde_ver_nr, me.ITEM_PHY_OBJ_NM || '.' || mec.MEC_PHY_NM nm_desc from nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.item_id = mec.mdl_elmnt_item_id and me.ver_nr = mec.mdl_elmnt_ver_nr and mec.cde_item_id is not null
     and me.mdl_item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and me.mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'VER_NR')) loop
     
     for curan in (select nm_id from  alt_nms where nm_typ_id = curmodel.assoc_NM_TYP_ID and upper(nm_desc) = upper(curchar.nm_desc)
     and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
     and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr) loop
        row := t_row();
    
        ihook.setColumnValue(row,'NM_ID',curan.nm_id);
     
            rows.extend;                       
            rows(rows.last) := row;

     end loop;
     end loop;
    end loop;
    
    if (rows.count > 0) then 
           action := t_actionrowset(rows, 'Alternate Names', 2,10,'delete');
        actions.extend;
        actions(actions.last) := action;
           action := t_actionrowset(rows, 'Alternate Names', 2,10,'purge');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.message := rows.count || ' alternate names were deleted.';
       hookoutput.actions := actions;
 
    end if;
     
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spUpdateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)--not used
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
rowschar t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  
  if (ihook.getColumnValue(row_ori,'CTL_VAL_STUS') not in  ('CREATED','UPDATED')) then
  raise_application_error(-20000, 'Please create model first.');
  end if;
  
  rows := t_rows();
  rowschar := t_rows();
  
  
 update nci_stg_mdl_elmnt_char set (val_dom_item_id, val_dom_ver_nr) = (select val_dom_item_id, val_dom_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;

 update nci_stg_mdl_elmnt_char set (de_conc_item_id, de_conc_ver_nr) = (select de_conc_item_id, de_conc_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;
 
 
for curelmnt in (Select * from NCI_MDL_ELMNT where mdl_item_id = ihook.getColumnValue(row_ori, 'CREATED_MDL_ITEM_ID') and mdl_item_ver_nr = ihook.getColumnValue(row_ori, 'SRC_MDL_VER') ) loop
--for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(curelmnt.item_long_nm)) loop

update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, char_ord, PK_IND, FK_IND, FK_ELMNT_PHY_NM, FK_ELMNT_CHAR_PHY_NM)
= (select CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_Id, VAL_DOM_VER_NR,char_ord,
decode(upper(PK_IND),'YES',1,0), decode(upper(FK_IND_TXT),'YES',1,0), FK_ELMNT_PHY_NM, FK_ELMNT_CHAR_PHY_NM from nci_stg_mdl_elmnt_char s where 
s.mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(s.me_item_long_nm) = upper(curelmnt.item_long_nm) and upper(s.MEC_PHY_NM) =upper(c.MEC_PHY_NM))
where  mdl_elmnt_item_id = curelmnt.item_id and mdl_elmnt_ver_nr = curelmnt.ver_nr;
commit;
row := t_row();
/*for cur1 in (select * from NCI_MDL_ELMNT_CHAR where  mdl_elmnt_item_id = curelmnt.item_id and mdl_elmnt_ver_nr = curelmnt.ver_nr) loop
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;
row := t_row();
ihook.setColumnValue(row,'MEC_ID',cur1.MEC_ID);
ihook.setColumnValue(row,'CDE_ITEM_ID',cur.CDE_ITEM_ID);
ihook.setColumnValue(row,'CDE_VER_NR',cur.CDE_VER_NR);
ihook.setColumnValue(row,'DE_CONC_ITEM_ID',cur.DE_CONC_ITEM_ID);
ihook.setColumnValue(row,'DE_CONC_VER_NR',cur.DE_CONC_VER_NR);
ihook.setColumnValue(row,'VAL_DOM_ITEM_ID',cur.VAL_DOM_ITEM_ID);
ihook.setColumnValue(row,'VAL_DOM_VER_NR',cur.VAL_DOM_VER_NR);
  rowschar.extend;
                                           rowschar(rowschar.last) := row;
end loop;*/
--end loop;
end loop;
         action := t_actionrowset(rowschar, 'Model Element Characteristics', 2,10,'update');
        actions.extend;
        actions(actions.last) := action;
  
    
    rows := t_rows();
    ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','UPDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Model updated - ' || sysdate);
  --ihook.setColumnValue(row_ori, 'CREATED_MDL_ITEM_ID',v_mdl_hdr_id);
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
  
 
    
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
end;

procedure spUpdateModelCDEAssocSub ( v_mdl_id in number, v_mdl_ver_nr in number, v_cnt in out integer, v_mode in varchar2, v_msg in out varchar2)
as
 v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
-- v_cnt integer :=0;
 v_cs_item_id number;
 v_cs_ver_nr number(4,2);
 v_alt_nm_typ integer;
 v_tbl_alt_nm_typ integer;
 v_temp integer;
 v_err integer :=0;
 BEGIN
  
  v_msg := '';
   for cur in (select * from nci_mdl where item_id = v_mdl_id and  ver_nr = v_mdl_ver_nr) loop
   v_cs_item_id := cur.ASSOC_CS_ITEM_ID;
   v_cs_ver_nr := cur.ASSOC_CS_VER_NR;
   v_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
   v_tbl_alt_nm_typ := cur.ASSOC_TBL_NM_TYP_ID;
       if (cur.ASSOC_NM_TYP_ID is null or cur.ASSOC_TBL_NM_TYP_ID is null or cur.ASSOC_CS_ITEM_ID is null ) then 
            if (v_mode = 'F') then -- front-end
                raise_application_error(-20000, 'For this functionality, please make sure Model Alternate Name Type, Table Alternate Name Type and CS is specified.');
            end if;
       end if;
    end loop;
  
 -- rows := t_rows();
  -- raise_application_Error(-20000, v_cs_item_id || ' ' || v_alt_nm_typ || ' ' || v_tbl_alt_nm_typ);
 
  for curchar in (select mec_id, MEC_PHY_NM, me.ITEM_PHY_OBJ_NM me_phy_nm,me.ITEM_LONG_NM me_long_nm,  mec.cde_item_id 
  from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.MDL_ITEM_ID =v_mdl_id
  and me.MDL_ITEM_VER_NR= v_mdl_ver_nr and me.item_id = mec.MDL_ELMNT_ITEM_ID and me.ver_nr =mec.MDL_ELMNT_VER_NR) loop
  
  select count(*) into v_temp from de where
  (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_alt_nm_typ and upper(nm_desc) = upper(curchar.mec_phy_nm))
  and  (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_tbl_alt_nm_typ and upper(nm_desc) = upper(curchar.me_phy_nm))
  and  (item_id, ver_nr) in (Select r.c_item_id, r.c_item_ver_nr from nci_admin_item_rel r, vw_clsfctn_schm_item csi where csi.cs_item_id = v_cs_item_id 
  and csi.cs_item_ver_nr = v_cs_ver_nr and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr and r.rel_typ_id = 65);
    if (v_temp = 1) then
      for curcde in (select item_id, ver_nr, de_conc_item_id,de_conc_ver_nr, val_dom_item_id, val_dom_ver_nr from de where
      (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_alt_nm_typ and upper(nm_desc) = upper(curchar.mec_phy_nm))
      and  (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_tbl_alt_nm_typ and upper(nm_desc) = upper(curchar.me_phy_nm))
      and  (item_id, ver_nr) in (Select r.c_item_id, r.c_item_ver_nr from nci_admin_item_rel r, vw_clsfctn_schm_item csi where csi.cs_item_id = v_cs_item_id 
      and csi.cs_item_ver_nr = v_cs_ver_nr and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr and r.rel_typ_id = 65)) loop
          if (curchar.cde_item_id != curcde.item_id and curchar.cde_item_id is not null and curcde.item_id is not null) then
            update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, chng_desc_txt)
            = (select curcde.ITEM_ID, curcde.VER_NR, curcde.DE_CONC_ITEM_ID, curcde.DE_CONC_VER_NR, curcde.VAL_DOM_ITEM_Id, curcde.VAL_DOM_VER_NR, 'Updated CDE from ' || curchar.cde_item_id from dual)
            where  mec_id = curchar.mec_id;
         --raise_application_Error(-20000, curchar.mec_phy_nm ||curchar.cde_item_id  || curcde.item_id);
             v_cnt := v_cnt + 1;
          end if;
          if ( curchar.cde_item_id is null and curcde.item_id is not null) then
            update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR)
            = (select curcde.ITEM_ID, curcde.VER_NR, curcde.DE_CONC_ITEM_ID, curcde.DE_CONC_VER_NR, curcde.VAL_DOM_ITEM_Id, curcde.VAL_DOM_VER_NR from dual)
            where  mec_id = curchar.mec_id;
            v_cnt := v_cnt + 1;
          end if;         
        end loop;
    end if;
    if (v_temp > 1) then
    -- error message
        v_msg :=   v_msg || '  ' || curchar.me_phy_nm || '.' || curchar.mec_phy_nm || ';';
        v_err := v_err + 1;
    end if;
  end loop;
  commit;
  
  if (v_err > 0) then
  v_msg := 'Duplicate CDEs found for the following. No CDE was attached. ' || v_msg;
  end if;
  /*
update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR)
= (select CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_Id, VAL_DOM_VER_NR
where  mdl_elmnt_item_id = curelmnt.item_id and mdl_elmnt_ver_nr = curelmnt.ver_nr;
commit;
 */
 end;
 


   procedure spUpdateModelCDEAssoc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    v_cnt integer :=0;
    v_msg  varchar2(4000);
    
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  
  spUpdateModelCDEAssocSub (ihook.getColumnValue(row_ori,'ITEM_ID'),ihook.getColumnValue(row_ori,'VER_NR'), v_cnt,'F', v_msg);
  
 hookoutput.message := 'CDE refresh complete. ' || v_cnt || ' characteristics updated. ' || v_msg;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

   procedure spValidateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
  v_temp integer;
 i integer;
 v_typ integer;
 v_dflt_typ integer;
 v_char_val_stus_msg varchar2(2000);
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_valid := true;
  v_val_stus_msg := '';
  rows := t_rows();
  
 /*if (ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'CREATED' or ihook.getColumnValue(row_ori, 'CTL_VAL_STUS') = 'UPDATED') then
  hookoutput.message := 'Created models cannot be validated';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  return;
  end if;
  */
  /*
 -- validate Primary Language and Model Type is set.
 if (ihook.getColumnValue(row_ori, 'SRC_PRMRY_LANG') is not null and ihook.getColumnValue(row_ori, 'PRMRY_MDL_LANG_ID')is null) then
    v_valid := false;
    v_val_stus_msg := v_val_stus_msg || 'Model: Modeling Language is not valid.' || chr(13);
end if;
*/
update nci_stg_mdl_elmnt_char set ctl_val_msg = '' where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
commit;
update nci_stg_mdl_elmnt set ctl_val_msg = '' where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
commit;

select count(*) into v_temp  from admin_item where item_id = ihook.getColumnValue(row_ori,'CREATED_MDL_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
if (v_temp = 0) then
    v_valid := false;
    v_val_stus_msg := v_val_stus_msg || 'Model: Specified Model ID/Version does not exist.' || chr(13);
end if;


for cur in (select * from admin_item where item_id = ihook.getColumnValue(row_ori,'CREATED_MDL_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER')) loop
 if (upper(cur.item_nm) <> upper(ihook.getColumnValue(row_ori, 'SRC_MDL_NM'))) then
    v_valid := false;
    v_val_stus_msg := v_val_stus_msg || 'Model: Specified Model Name does not match the long name of the model retrieved based on Public Id.' || chr(13);
end if;
end loop;

 -- validate ME type id else default Semantic Model - Class. Physical Model - Table
 /* select obj_key_id into v_dflt_typ from obj_key where obj_typ_id = 41 and upper(obj_key_desc) = 'TABLE';
 
 update nci_stg_mdl_elmnt set ME_TYP_ID	=v_dflt_typ where ME_TYP_ID	is null and mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
 commit;
 */
   update nci_stg_mdl_elmnt set item_long_nm = item_phy_obj_nm where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ITEM_LONG_NM is null;
  commit;
   update nci_stg_mdl_elmnt_char set mec_long_nm = mec_phy_nm where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and mec_LONG_NM is null;
  commit;
  update nci_stg_mdl_elmnt_char set ctl_val_msg = null where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') ;
  commit;
  -- update nci_stg_mdl_elmnt_char set ctl_val_msg = null where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
  --commit;
     update nci_stg_mdl_elmnt_char set ctl_val_msg = 'ERROR: CDE ID/Version not valid. '|| cde_item_id || 'v' || cde_ver_nr || '.' where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID')
     and (cde_item_id, cde_ver_nr) not in (select item_id, ver_nr from de);
  commit;
  -- update nci_stg_mdl_elmnt_char set ctl_val_msg = nvl(ctl_val_msg,'ERROR: ') || ' Max lenght cannot be null. ' where SRC_MAX_CHAR is null and mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
     
 -- commit;
   update nci_stg_mdl_elmnt set ctl_val_msg = 'ERROR: Issues found at Characteristic level. ' where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID')
     and (ITEM_PHY_OBJ_NM) in (select ME_ITEM_LONG_NM from nci_stg_mdl_elmnt_char where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ctl_val_msg is not null);
  commit;
  
  --jira 4065: set validation message at model element level to show the command was run successfully if no errors
    UPDATE nci_stg_mdl_elmnt
    SET ctl_val_msg = 'Validate Command Successful'
    WHERE mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') AND ctl_val_msg IS NULL;
    COMMIT;
  --jira 3846- set error message at characteristic level
--        update nci_stg_mdl_elmnt_char set ctl_val_msg = 'ERROR: Characteristic name not in the Model Element.' 
--        where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') 
--        and (ME_ITEM_LONG_NM) not in (select ITEM_PHY_OBJ_NM from nci_stg_mdl_elmnt where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID'));-- and ctl_val_msg is not null);
--        commit;
  
  
  select count(*) into v_temp from nci_stg_mdl_elmnt_char where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ctl_val_msg is not null;
  
  if (v_temp > 0) then -- error
    v_valid := false;
    for i in (select seq_nbr from nci_stg_mdl_elmnt_char where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ctl_val_msg is not null) loop
        v_char_val_stus_msg := v_char_val_stus_msg || ', ' || i.seq_nbr;
    end loop;
    v_char_val_stus_msg := substr(v_char_val_stus_msg, 2, length(v_char_val_stus_msg));
   -- v_val_stus_msg := v_val_stus_msg || 'Characteristic: ' || v_temp || ' error(s) found in specified CDE Item Id/Version or max character is blank.' || chr(13);
    v_val_stus_msg := v_val_stus_msg || 'Characteristic: ' || v_temp || ' error(s) found in specified CDE Item Id/Version.' || chr(13) || 'Check the following: ' || v_char_val_stus_msg;

end if;
 -- validate ME type id else default Semantic Model - Class. Physical Model - Table
 
 /* select obj_key_id into v_dflt_typ from obj_key where obj_typ_id = 52 and upper(obj_key_desc) = 'COLUMN';
 
 update nci_stg_mdl_elmnt_char set MDL_ELMNT_CHAR_TYP_ID	=v_dflt_typ where MDL_ELMNT_CHAR_TYP_ID	is null and mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
 commit;
 */
 
 update nci_stg_mdl_elmnt_char set (val_dom_item_id, val_dom_ver_nr) = (select val_dom_item_id, val_dom_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;

 update nci_stg_mdl_elmnt_char set (de_conc_item_id, de_conc_ver_nr) = (select de_conc_item_id, de_conc_ver_nr from de where 
 item_id = nci_stg_mdl_elmnt_char.cde_item_id and ver_nr = nci_stg_mdl_elmnt_char.cde_ver_nr )
  where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and cde_item_id is not null; 
  commit;
  if (v_valid = false) then 
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','ERROR');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG',v_val_stus_msg);
  else
  ihook.setColumnValue(row_ori, 'CTL_VAL_STUS','VALIDATED');
  ihook.setColumnValue(row_ori, 'CTL_VAL_MSG','Valid');
  end if;
     rows.extend;   rows(rows.last) := row_ori;
 
   action := t_actionrowset(rows, 'Model Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;


   procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  
  
  
  -- check if invalid Mapping degree/Mapping Type
  
 -- Derive Mapping cardinality
 -- for cur in (select * from obj_key where obj_typ_id = 47  and upper(obj_key_desc) = nvl(upper(ihook.getColumnValue(row_ori, 'IMP_CRDNLITY')),'XX')) loop
 --   ihook.setColumnValue(row_ori, 'CRDNLITY_ID', cur.obj_key_id);
-- end loop;

-- Validate that the source elemnt/char and target element/char belong to the current source and target model
-- validate that both ME and MEC are specified. May be blank.
if ((ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is not null ) or
(ihook.getColumnValue(row_ori, 'SRC_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'SRC_MEC_PHY_NM') is  null)) then
v_valid := false;
v_val_stus_msg := 'Both Source Element and Characteristics have to be specified; ';
end if;

if (((ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is not null ) or
(ihook.getColumnValue(row_ori, 'TGT_ME_PHY_NM') is not null and  ihook.getColumnValue(row_ori, 'TGT_MEC_PHY_NM') is  null)) and v_valid= true) then
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

if (ihook.getColumnValue(row_ori, 'IMP_MAP_DEG') is not null and  ihook.getColumnValue(row_ori, 'MAP_DEG') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Mapping Type is incorrect; '|| chr(13);
end if;

if (ihook.getColumnValue(row_ori, 'IMP_CRDNLITY') is not null and  ihook.getColumnValue(row_ori, 'CRDNLITY_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Cardinaliy is incorrect; '|| chr(13);
end if;


if (ihook.getColumnValue(row_ori, 'IMP_SRC_FUNC') is not null and  ihook.getColumnValue(row_ori, 'SRC_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Source Function is incorrect; '|| chr(13);
end if;

if (ihook.getColumnValue(row_ori, 'IMP_TGT_FUNC') is not null and  ihook.getColumnValue(row_ori, 'TGT_FUNC_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Target Function is incorrect; '|| chr(13);
end if;
 
if (ihook.getColumnValue(row_ori, 'IMP_TRANS_RUL_NOT') is not null and  ihook.getColumnValue(row_ori, 'TRANS_RUL_NOT') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Transformation Notation Type is incorrect; '|| chr(13);
end if;
 
if (ihook.getColumnValue(row_ori, 'IMP_OP_TYP') is not null and  ihook.getColumnValue(row_ori, 'OP_TYP') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Comparator is incorrect; '|| chr(13);
end if;
 
 
if (ihook.getColumnValue(row_ori, 'IMP_FLOW_CNTRL') is not null and  ihook.getColumnValue(row_ori, 'FLOW_CNTRL') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Condition is incorrect; '|| chr(13);
end if;
 
 
 
if (ihook.getColumnValue(row_ori, 'IMP_PAREN') is not null and  ihook.getColumnValue(row_ori, 'PAREN') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Parenthesis is incorrect; '|| chr(13);
end if;
 
 
if (ihook.getColumnValue(row_ori, 'IMP_PROV_ORG') is not null and  ihook.getColumnValue(row_ori, 'PROV_ORG_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Organization is incorrect; '|| chr(13);
end if;


 
if (ihook.getColumnValue(row_ori, 'IMP_PROV_CNTCT') is not null and  ihook.getColumnValue(row_ori, 'PROV_CNTCT_ID') is null ) then
v_valid := false;
v_val_stus_msg := v_val_stus_msg ||'Imported Provenance Contact is incorrect; '|| chr(13);
end if;
 	
    
for cur in (select * from nci_mdl_map mm where mm.item_id  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mm.ver_nr = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR')) loop
    ihook.setColumnValue(row_ori, 'SRC_MDL_ITEM_ID', cur.SRC_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'TGT_MDL_ITEM_ID', cur.TGT_MDL_ITEM_ID);
    ihook.setColumnValue(row_ori, 'SRC_MDL_VER_NR', cur.SRC_MDL_VER_NR);
    ihook.setColumnValue(row_ori, 'TGT_MDL_VER_NR', cur.TGT_MDL_VER_NR);
    
    end loop;

-- Rules id provided is incorrect.
 
if (ihook.getColumnValue(row_ori, 'IMP_RULE_ID') is not null) then
    select count(*) into v_temp from NCI_MEC_MAP where  MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and MECM_ID=ihook.getColumnValue(row_ori, 'IMP_RULE_ID') and nvl(fld_Delete,0) = 0;
    if (v_temp = 0) then
        v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Imported Rule ID is incorrect or does not exist; '|| chr(13);

    end if;    
end if;
 
 -- duplicae based on src/tgt/op/src func/tgt func/condition/operator
 if (v_valid = true) then -- check for duplicate
    for cur in (select * from nci_mec_map where mdl_map_item_id = ihook.getColumnValue(row_ori, 'MDL_MAP_ITEM_ID')
    and mdl_map_ver_nr =  ihook.getColumnValue(row_ori, 'MDL_MAP_VER_NR') and nvl(src_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'SRC_MEC_ID'),0)
    and nvl(tgt_mec_id,0) = nvl( ihook.getColumnValue(row_ori, 'TGT_MEC_ID'),0)
    and nvl(OP_id,0) = nvl( ihook.getColumnValue(row_ori, 'OP_ID'),0)
     and nvl(SRC_FUNC_ID,0) = nvl( ihook.getColumnValue(row_ori, 'SRC_FUNC_ID'),0)
    and nvl(TGT_FUNC_id,0) = nvl( ihook.getColumnValue(row_ori, 'TGT_FUNC_ID'),0)
    and nvl(FLOW_CNTRL,0) = nvl( ihook.getColumnValue(row_ori, 'FLOW_CNTRL'),0)
    and  ihook.getColumnValue(row_ori, 'IMP_RULE_ID') is null) loop
       v_valid := false;
        v_val_stus_msg := v_val_stus_msg ||'Duplicate found with Rule ID: '|| cur.MECM_ID ||  chr(13);
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
 
   action := t_actionrowset(rows, 'Model Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        
       hookoutput.actions := actions;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;


 procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
 i integer;
 v_max integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
 
  row_ori :=  hookInput.originalRowset.rowset(1);
  
 select max(nvl(MEC_GRP_RUL_NBR,0))+1  into v_max from nci_mec_map where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori,'MDL_MAP_ITEM_ID') and MDL_MAP_VER_NR= ihook.getColumnValue(row_ori,'MDL_MAP_VER_NR');
 
 for i in 1..hookinput.originalrowset.rowset.count loop 
  row_ori :=  hookInput.originalRowset.rowset(i);
  update nci_mec_map set MEC_GRP_RUL_NBR= v_max, DIRECT_TYP=119 where MECM_ID = ihook.getColumnValue(row_ori,'MECM_ID');
 end loop;
 commit;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
  -- nci_util.debugHook('GENERAL',v_data_out);
end;

   procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 v_src_hdr_id integer;
 v_tgt_item_id number;
 v_tgt_ver_nr number(4,2);
 question    t_question;
answer     t_answer;
answers     t_answers;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  
  v_src_hdr_id := ihook.getColumnValue(row_ori,'MDL_IMP_ID');
  
  v_tgt_item_id := 60008955;
  v_tgt_ver_nr := 5.31;
  if (hookinput.invocationnumber = 0) then
 	 showrowset := t_showablerowset (rows, 'Models', 2, 'single');
       	 hookoutput.showrowset := showrowset;

       	 answers := t_answers();
  	   	 answer := t_answer(1, 1, 'Select Model');
  	   	 answers.extend; answers(answers.last) := answer;

	   	 question := t_question('Select Model To Compare', answers);
       	 hookOutput.question := question;

 end if;
  if (hookinput.invocationnumber = 1) then
   row_sel := hookInput.selectedRowset.rowset(1);
         
  v_tgt_item_id := ihook.getColumnValue(row_sel,'ITEM_ID');
  v_tgt_ver_nr := ihook.getColumnValue(row_sel,'VER_NR');
  for cur in (select ime.item_long_nm ME_ITEM_NM, ime.ITEM_PHY_OBJ_NM ME_ITEM_PHY_NM, imec.MEC_LONG_NM MEC_ITEM_NM, imec.MEC_PHY_NM  MEC_ITEM_PHY_NM from nci_stg_mdl_elmnt ime,
                   nci_stg_mdl_elmnt_char imec where ime.mdl_imp_id = imec.mdl_imp_id and ime.item_long_nm = imec.me_item_long_nm
                   and ime.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and
                   (upper(ime.ITEM_PHY_OBJ_NM),  upper(imec.MEC_PHY_NM) ) not in (select upper(me.ITEM_PHY_OBJ_NM), upper(mec.MEC_PHY_NM) from NCI_MDL_ELMNT me, NCI_MDL_ELMNT_CHAR mec 
                   where me.item_id = mec.MDL_ELMNT_ITEM_ID 
                   and me.ver_nr = mec.MDL_ELMNT_VER_NR and me.mdl_item_id = v_tgt_item_id  and me.mdl_item_ver_nr = v_tgt_ver_nr) ) loop
                   row := t_row();
                   ihook.setColumnValue(row, 'Source Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Source Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Element', '');
                   ihook.setColumnValue(row, 'Target Element Physical Name', '');
                   ihook.setColumnValue(row, 'Target Characteristics', '');
                   ihook.setColumnValue(row, 'Target Characteristics Physical Name', '');
                     rows.extend;   rows(rows.last) := row;
                   end loop;
  
  for cur in (select me.item_long_nm ME_ITEM_NM, me.ITEM_PHY_OBJ_NM ME_ITEM_PHY_NM, mec.MEC_LONG_NM MEC_ITEM_NM, mec.MEC_PHY_NM  MEC_ITEM_PHY_NM from NCI_MDL_ELMNT me, NCI_MDL_ELMNT_CHAR mec 
                   where me.item_id = mec.MDL_ELMNT_ITEM_ID 
                   and me.ver_nr = mec.MDL_ELMNT_VER_NR and me.mdl_item_id = v_tgt_item_id  and me.mdl_item_ver_nr = v_tgt_ver_nr
                   and (upper(me.ITEM_PHY_OBJ_NM), upper(mec.MEC_PHY_NM)) not in (select upper(ime.ITEM_PHY_OBJ_NM),  upper(imec.MEC_PHY_NM)
                   from nci_stg_mdl_elmnt ime,
                   nci_stg_mdl_elmnt_char imec where ime.mdl_imp_id = imec.mdl_imp_id and ime.item_long_nm = imec.me_item_long_nm
                   and ime.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') )) loop
                   row := t_row();
                   ihook.setColumnValue(row, 'Target Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                     rows.extend;   rows(rows.last) := row;
                   end loop;
  for cur in (select ime.item_long_nm ME_ITEM_NM, ime.ITEM_PHY_OBJ_NM ME_ITEM_PHY_NM, imec.MEC_LONG_NM MEC_ITEM_NM, imec.MEC_PHY_NM  MEC_ITEM_PHY_NM 
  from nci_stg_mdl_elmnt ime, 
                   nci_stg_mdl_elmnt_char imec where ime.mdl_imp_id = imec.mdl_imp_id and ime.item_long_nm = imec.me_item_long_nm
                   and ime.mdl_imp_id = ihook.getColumnValue(row_ori,'MDL_IMP_ID') and
                   (upper(ime.ITEM_PHY_OBJ_NM),  upper(imec.MEC_PHY_NM) )  in (select upper(me.ITEM_PHY_OBJ_NM), upper(mec.MEC_PHY_NM) from NCI_MDL_ELMNT me, NCI_MDL_ELMNT_CHAR mec 
                   where me.item_id = mec.MDL_ELMNT_ITEM_ID 
                   and me.ver_nr = mec.MDL_ELMNT_VER_NR and me.mdl_item_id = v_tgt_item_id  and me.mdl_item_ver_nr = v_tgt_ver_nr) ) loop
                   row := t_row();
                   ihook.setColumnValue(row, 'Source Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Source Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Source Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Element', cur.ME_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Element Physical Name', cur.ME_ITEM_PHY_NM);
                   ihook.setColumnValue(row, 'Target Characteristics', cur.MEC_ITEM_NM);
                   ihook.setColumnValue(row, 'Target Characteristics Physical Name', cur.MEC_ITEM_PHY_NM);
                     rows.extend;   rows(rows.last) := row;
                   end loop;
           
if (rows.count > 0) then
    showRowset := t_showableRowset(rows, 'Model Compare',4, 'unselectable');
    hookOutput.showRowset := showRowset;
else
  hookoutput.message := 'No difference found';
end if;
 end if;
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


   procedure spVersionModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
    showRowset     t_showableRowset;
row t_row;
  rows  t_rows;
    row_ori t_row;
    row_sel t_row;
    v_id integer;
    v_id integer;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
  v_mdl_hdr_id number;
 i integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  rows := t_rows();
  
 raise_application_error (-20000,'Work in progress');

    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

  PROCEDURE spGenerateModelView
  (
    v_data_in IN CLOB,
    v_data_out OUT CLOB,
    v_user_id in varchar2)
AS
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
 question    t_question;
answer     t_answer;
answers     t_answers;
showrowset	t_showablerowset;
forms     t_forms;
formGroup    t_form;
v_itemid     integer;
v_found boolean;
  v_temp integer;
  v_stg_ai_id number;
  i integer := 0;
  column  t_column;
  msg varchar2(4000);
  v_item_typ  integer;
  v_mod_specified boolean;
  v_cart_nm varchar2(255);
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  row_ori :=  hookInput.originalRowset.rowset(1);


	    rows :=         t_rows();
		v_found := false;

	/*    for cur in (select c.item_id, c.ver_nr from NCI_USR_CART c, admin_item ai where c.fld_delete= 0 and cntct_secu_id = v_user_id and ai.item_id = c.item_id and ai.ver_nr = c.ver_nr and
        ai.admin_item_typ_id in (52, 54 ) and cart_nm = v_cart_nm order by admin_item_typ_id) loop
		   row := t_row();
	   	   iHook.setcolumnvalue (ROW, 'ITEM_ID', cur.ITEM_ID);
		   iHook.setcolumnvalue (ROW, 'VER_NR', cur.VER_NR);
		   iHook.setcolumnvalue (ROW, 'CNTCT_SECU_ID', v_user_id);
		   iHook.setcolumnvalue (ROW, 'CART_NM', v_cart_nm);
		   rows.extend;
		   rows (rows.last) := row;
		   v_found := true;
	    end loop;
*/

row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');

 rows.extend;
		   rows (rows.last) := row;
row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');
ihook.setColumnValue(row, 'Level 2','Test Level 2');

 rows.extend;
		   rows (rows.last) := row;
row := t_row();
ihook.setColumnValue(row, 'Level 1','Test');
ihook.setColumnValue(row, 'Level 2','Test Level 2');
ihook.setColumnValue(row, 'Level 3','Test Level 3');

 rows.extend;
		   rows (rows.last) := row;

	      showRowset := t_showableRowset(rows, 'Model View',4, 'unselectable');
    hookOutput.showRowset := showRowset;

   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end; 

procedure spShowImportModelCount ( v_data_in in clob, v_data_out out clob) -- show summarized import model count
as
 showRowset     t_showableRowset;
 hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
   
    rows      t_rows;
    row          t_row;
    row_ori  t_row;
    v_me_cnt integer;
    v_mec_cnt integer;
begin
hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
row_ori := hookInput.originalRowset.rowset (1);

select count(*) into v_me_cnt from nci_stg_mdl_elmnt where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');
select count(*) into v_mec_cnt from nci_stg_mdl_elmnt_char where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID');

rows:= t_rows();
row := t_row();
ihook.setColumnValue(row,'Element Count', v_me_cnt);
ihook.setColumnValue(row,'Characteristic Count', v_mec_cnt);
 rows.extend;
 rows(rows.last) := row;
 showRowset := t_showableRowset(rows, 'Imported Stats',4, 'unselectable');
    hookOutput.showRowset := showRowset;
  hookoutput.message := 'Items imported.';
   V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

end;
     
procedure spDeleteModelElementChar  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
     row_sel t_row;
    rows  t_rows;
    row_ori t_row;
  action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
 v_mdl_id number;
 v_mdl_ver_nr number(4,2);
 v_mdl_nm varchar(255);
 
  rowform t_row;

tmp_mdl_str varchar(4000) := ' ';
v_map_ind boolean;
 v_found boolean := false;
BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  select mdl_item_id, mdl_item_ver_nr into v_mdl_id, v_mdl_ver_nr 
  from nci_mdl_elmnt where item_id = ihook.getColumnValue(row_ori, 'MDL_ELMNT_ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori, 'MDL_ELMNT_VER_NR');
    v_map_ind := false;
  
  if (hookinput.invocationnumber = 0) then 
 -- verfiy no model mapping exist
   /*     for cur in (Select * from nci_mdl_map mdlm where (mdlm.SRC_MDL_ITEM_ID = v_mdl_id and mdlm.SRC_MDL_VER_NR=v_mdl_ver_nr) or 
            (mdlm.TGT_MDL_ITEM_ID = v_mdl_id and mdlm.TGT_MDL_VER_NR=v_mdl_ver_nr)) loop
            for i in 1..hookInput.originalRowset.rowset.count loop
                row_ori :=  hookInput.originalRowset.rowset(i);
                v_item_id := ihook.getColumnValue(row_ori,'MEC_ID');
                
                --v_ver_nr := ihook.getColumnValue(row_ori,'MDL_ELMNT_VER_NR'); 
                for elm in (select * from nci_mec_map where nci_mec_map.mdl_map_item_id = cur.item_id and nci_mec_map.mdl_map_ver_nr = cur.ver_nr 
                            and (nci_mec_map.src_mec_id = v_item_id  OR
                                nci_mec_map.tgt_mec_id = v_item_id )) loop
--                            and (nci_mec_map.src_mec_id = nci_mdl_elmnt_char.mec_id or nci_mec_map.tgt_mec_id = nci_mdl_elmnt_char.mec_id) 
--                            and nci_mdl_elmnt_char.mdl_elmnt_item_id = v_item_id and nci_mdl_elmnt_char.mdl_elmnt_ver_nr = v_ver_nr) loop
                    v_map_ind := true;
                    if (instr(tmp_mdl_str, to_char(cur.item_id) || 'v' || to_char(cur.ver_nr),1,1) = 0) then
                tmp_mdl_str := tmp_mdl_str || to_char(cur.item_id) || 'v' || to_char(cur.ver_nr) || ' ';
                end if;
                exit;
                    --select item_nm into v_mdl_nm from admin_item where item_id = cur.item_id and ver_nr = cur.ver_nr;
                    --hookoutput.message := 'Model Element Characteristic cannot be deleted. It is associated with Model Mapping ID: ' || cur.item_id  || ' - ' || v_mdl_nm;
                    --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
                    --return;
                end loop;
            end loop;
        end loop;*/
         for i in 1..hookInput.originalRowset.rowset.count loop
                row_ori :=  hookInput.originalRowset.rowset(i);
                v_map_ind := false;
                v_item_id := ihook.getColumnValue(row_ori,'MEC_ID');
                tmp_mdl_str := tmp_mdl_str || chr(13) || 'Characteristic: ' || ihook.getColumnValue(row_ori,'MEC_LONG_NM') || ' used in: ' ;
                --v_ver_nr := ihook.getColumnValue(row_ori,'MDL_ELMNT_VER_NR'); 
                for cur in (select distinct mdl_map_item_id, mdl_map_ver_nr from nci_mec_map where 
                            nci_mec_map.src_mec_id = v_item_id  OR
                                nci_mec_map.tgt_mec_id = v_item_id ) loop
--                            and (nci_mec_map.src_mec_id = nci_mdl_elmnt_char.mec_id or nci_mec_map.tgt_mec_id = nci_mdl_elmnt_char.mec_id) 
--                            and nci_mdl_elmnt_char.mdl_elmnt_item_id = v_item_id and nci_mdl_elmnt_char.mdl_elmnt_ver_nr = v_ver_nr) loop
                    v_map_ind := true;
                    v_found := true;
                    tmp_mdl_str := tmp_mdl_str || to_char(cur.mdl_map_item_id) || 'v' || to_char(cur.mdl_map_ver_nr) || '; ';
                end loop;
                if (v_map_ind = false) then
                tmp_mdl_str := tmp_mdl_str || ' None';
                end if;
                    --select item_nm into v_mdl_nm from admin_item where item_id = cur.item_id and ver_nr = cur.ver_nr;
                    --hookoutput.message := 'Model Element Characteristic cannot be deleted. It is associated with Model Mapping ID: ' || cur.item_id  || ' - ' || v_mdl_nm;
                    --V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
                    --return;
                end loop;
            
        if (v_found = true) then
            hookoutput.message := 'Model Element Characteristic cannot be deleted. ' || tmp_mdl_str;
            V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
            return;
        end if;
        hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model Element Characteristics.');
    end if;
if (hookinput.invocationnumber = 1) then
  
    for i in 1..hookInput.originalRowset.rowset.count loop
        row_ori :=  hookInput.originalRowset.rowset(i);
        v_item_id := ihook.getColumnValue(row_ori,'MEC_ID');
        --v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
        --v_mdl_id := ihook.getColumnValue(row_ori, 'MDL_ITEM_ID');
        --v_mdl_ver_nr := ihook.getColumnValue(row_ori, 'MDL_ITEM_VER_NR');
 

        delete from nci_mdl_elmnt_char where mec_id = v_item_id; 
        delete from onedata_ra.nci_mdl_elmnt_char where mec_id = v_item_id;


        commit;
    end loop;

hookoutput.message :=  'Model Characteristic(s) deleted successfully.';
end if;

  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;
     

END;
/
