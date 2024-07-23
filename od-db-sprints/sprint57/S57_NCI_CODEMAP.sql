create or replace PACKAGE            nci_codemap AS
procedure   getStdMMComment(row in out t_row,row_ori in t_row);

  procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateMapDECOnly ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spAddManualMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spGenerateValueMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
   procedure spGenerateValueMapAll ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
    procedure spGenerateModelView ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateEntityRel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in out number);
  procedure spCreateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spUpdateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValidateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVersionModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spVersionModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCompareModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spCreateMapGroup ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure getModelElementAction ( row_ori in out t_row, actions in out t_actions, v_mdl_hdr_id in number, v_mdl_elmnt_id in out number);
 procedure getModelElementCharAction ( row_ori in out t_row, rowscharins in out t_rows,rowscharupd in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure getModelElementCharActionDirect ( row_ori in out t_row, rowscharins in out t_rows,rowscharupd in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure getModelElementCharUpdateAction ( row_ori in out t_row, rowschar in out t_rows, v_mdl_elmnt_id in number, v_mdl_elmnt_long_nm in varchar2);
 procedure spCreateModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spDeleteModelAltNm ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValidateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spReleaseModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
 procedure spUpdateModelCDEAssoc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
  procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);
procedure dervTgtMEC( v_data_in in clob, v_data_out out clob); 
procedure spDeleteValueMapping  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_usr_id  IN varchar2);
--procedure dervTgtMECTemp; 
 procedure spDeleteModel( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

 procedure spDeleteModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2);

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
  begin

for cur in (select * from NCI_STG_MDL_ELMNT_CHAR where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and upper(me_item_long_nm) = upper(v_mdl_elmnt_long_nm)) loop
--raise_application_error(-20000,v_mdl_elmnt_long_nm);

select count(*) into v_temp from NCI_MDL_ELMNT_CHAR where upper(MEC_PHY_NM) = upper(cur.MEC_PHY_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');
--and ver_nr = ihook.getColumnvalue(row_ori, 'SRC_VER_NR') ;


if (v_temp = 0) then -- insert
select NCI_SEQ_MEC.nextval into v_mec_id from dual;
v_ver := ihook.getColumnvalue(row_ori, 'SRC_MDL_VER');
insert into NCI_MDL_ELMNT_CHAR (MEC_ID, MDL_ELMNT_ITEM_ID, MDL_ELMNT_VER_NR,SRC_DTTYPE,STD_DTTYPE_ID,SRC_MAX_CHAR,SRC_MIN_CHAR,SRC_UOM,UOM_ID,
SRC_DEFLT_VAL,SRC_ENUM_SRC,MEC_LONG_NM,MEC_PHY_NM,MEC_DESC,CDE_ITEM_ID,CDE_VER_NR,DE_CONC_ITEM_ID,DE_CONC_VER_NR,VAL_DOM_ITEM_ID,
CHAR_ORD,VAL_DOM_VER_NR,MDL_ELMNT_CHAR_TYP_ID, PK_IND,FK_IND,
REQ_IND,FK_ELMNT_PHY_NM,FK_ELMNT_CHAR_PHY_NM)
values (v_mec_id, v_mdl_elmnt_id, v_ver, cur.SRC_DTTYPE, cur.STD_DTTYPE_ID,cur.SRC_MAX_CHAR,cur.SRC_MIN_CHAR, cur.SRC_UOM, cur.UOM_ID,
cur.SRC_DEFLT_VAL, cur.SRC_ENUM_SRC,cur.MEC_LONG_NM, cur.MEC_PHY_NM, cur.MEC_DESC, cur.CDE_ITEM_ID, cur.CDE_VER_NR,cur.DE_CONC_ITEM_ID, cur.DE_CONC_VER_NR,cur.VAL_DOM_ITEM_ID,
cur.CHAR_ORD,cur.VAL_DOM_VER_NR, cur.MDL_ELMNT_CHAR_TYP_ID,decode(nvl(upper(cur.PK_IND),'NO'),'YES',1,0),decode(nvl(upper(cur.FK_IND_TXT),'NO'),'YES',1,0),
decode(nvl(upper(cur.SRC_MAND_IND),'NO'),'YES',132,'MANDATORY',132,'NO',133,'EXPECTED', 134,'NOT MANDATORY',133,133),cur.FK_ELMNT_PHY_NM, cur.FK_ELMNT_CHAR_PHY_NM);

insert into onedata_Ra.NCI_MDL_ELMNT_CHAR (MEC_ID, MDL_ELMNT_ITEM_ID, MDL_ELMNT_VER_NR,SRC_DTTYPE,STD_DTTYPE_ID,SRC_MAX_CHAR,SRC_MIN_CHAR,SRC_UOM,UOM_ID,
SRC_DEFLT_VAL,SRC_ENUM_SRC,MEC_LONG_NM,MEC_PHY_NM,MEC_DESC,CDE_ITEM_ID,CDE_VER_NR,DE_CONC_ITEM_ID,DE_CONC_VER_NR,VAL_DOM_ITEM_ID,
CHAR_ORD,VAL_DOM_VER_NR,MDL_ELMNT_CHAR_TYP_ID, PK_IND,FK_IND,
REQ_IND,FK_ELMNT_PHY_NM,FK_ELMNT_CHAR_PHY_NM)
values (v_mec_id, v_mdl_elmnt_id, v_ver, cur.SRC_DTTYPE, cur.STD_DTTYPE_ID,cur.SRC_MAX_CHAR,cur.SRC_MIN_CHAR, cur.SRC_UOM, cur.UOM_ID,
cur.SRC_DEFLT_VAL, cur.SRC_ENUM_SRC,cur.MEC_LONG_NM, cur.MEC_PHY_NM, cur.MEC_DESC, cur.CDE_ITEM_ID, cur.CDE_VER_NR,cur.DE_CONC_ITEM_ID, cur.DE_CONC_VER_NR,cur.VAL_DOM_ITEM_ID,
cur.CHAR_ORD,cur.VAL_DOM_VER_NR, cur.MDL_ELMNT_CHAR_TYP_ID,decode(nvl(upper(cur.PK_IND),'NO'),'YES',1,0),decode(nvl(upper(cur.FK_IND_TXT),'NO'),'YES',1,0),
decode(nvl(upper(cur.SRC_MAND_IND),'NO'),'YES',132,'MANDATORY',132,'NO',133,'EXPECTED', 134,'NOT MANDATORY',133,133),cur.FK_ELMNT_PHY_NM, cur.FK_ELMNT_CHAR_PHY_NM);
end if;
if (v_temp = 1) then
select mec_id into v_mec_id from NCI_MDL_ELMNT_CHAR where upper(mec_LONG_nm) = upper(cur.MEC_LONG_NM) and mdl_elmnt_item_id = v_mdl_elmnt_id and mdl_elmnt_ver_nr = ihook.getColumnValue(row_ori,'SRC_MDL_VER');

update NCI_MDL_ELMNT_CHAR set 
SRC_DTTYPE = cur.SRC_DTTYPE,
STD_DTTYPE_ID = cur.STD_DTTYPE_ID,
SRC_MAX_CHAR=cur.SRC_MAX_CHAR,
SRC_MIN_CHAR= cur.SRC_MIN_CHAR,
SRC_UOM = cur.SRC_UOM,
UOM_ID = cur.UOM_ID,
SRC_DEFLT_VAL = cur.SRC_DEFLT_VAL,
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
hookoutput.message := hookInput.originalRowset.rowset.count ||  ' Value Mappings deleted.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


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


procedure spReleaseModel  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
        if (curmodel.assoc_nm_typ_id is null) then
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
        msg := substr(msg || j || ' Characteristics with Character/Text/String datatype do not have a required Max Length. Examples: ' || substr(msg1, 1, length(msg1)-1),1,4000);
            row := t_row();
        --    ihook.setColumnValue(row,'Issue', 'Some Characteristics with Character/Text/String datatype do not have a required Max Length: ' || substr(msg1, 1, length(msg1)-1));
            ihook.setColumnValue(row,'Issue', j || 'Some Characteristics with Character/Text/String datatype do not have a required Max Length. Examples in Detail Section.');
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
                msg1 := substr(msg1 || curchar.ME_PHY_NM || '.' || curchar.MEC_PHY_NM || ', ',1,4000) ;
            else
                select count(*) into v_temp from alt_nms where nm_typ_id = v_assoc_tbl_NM_TYP_ID and upper(nm_desc) = upper(curchar.ME_PHY_NM)
                and cntxt_item_id = ihook.getColumnValue(row_ori,'CNTXT_ITEM_ID') and cntxt_ver_nr = ihook.getColumnValue(row_ori,'CNTXT_VER_NR')
                and item_id = curchar.cde_item_id and ver_nr = curchar.cde_ver_nr;
                if (v_temp = 0) then 
                    j:= j+1;
                    msg1 := substr(msg1 || curchar.ME_PHY_NM || '.' || curchar.MEC_PHY_NM || ', ',1,4000) ;
                end if;
            end if;
        end loop;
    
        if (j > 0) then
            msg := substr(msg || chr(13) || 'Alternate Names missing for some elements/characteristics. ' || msg1,1,4000);
            row := t_row();
       --     ihook.setColumnValue(row,'Issue', 'Alternate Names missing for some elements/characteristics. Please use create Alternate Name command first: ' || msg1);
            ihook.setColumnValue(row,'Issue', 'Alternate Names missing for some elements/characteristics. ' );
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
            ihook.setColumnValue(row,'Issue', 'Missing classifications for CDE.');
            ihook.setColumnValue(row,'Details',  substr(msg1, 1, length(msg1)-2));
            rows.extend; rows(rows.last) := row;
            v_valid := false;
        end if;
   -- end if;
    
    if (v_valid = false) then
         --   raise_application_error(-20000, msg);
              showRowset := t_showableRowset(rows, 'Issues with Model Release',4, 'unselectable');
    hookOutput.showRowset := showRowset;

    else
            -- change status
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
           hookoutput.message := 'Model status Released.';
            hookoutput.actions := actions;
   end if;
   
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
END;


procedure spDeleteModelMap  ( v_data_in IN CLOB, v_data_out OUT CLOB, v_user_id  IN varchar2)
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
 
 -- verify that this is either the only version or is not a current version
 
 
 if (hookinput.invocationnumber = 0) then 
 if (ihook.getColumnValue(row_Ori, 'CURRNT_VER_IND')=1) then
 for cur in (Select count(*) from admin_item where item_id= v_item_id group by item_id having count(*) > 1) loop
   hookoutput.message := 'Model mapping cannot be deleted as it is the latest version. Use ''Select Latest Version'' to change latest version first.';
     V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
     return;
 end loop;
 end if;
  hookoutput.question := nci_form_curator.getProceedQuestion('Confirm', 'Please confirm deletion of Model: ' || ihook.getColumnValue (row_ori,'ITEM_NM') || ' (' ||v_item_id || 'v' || v_ver_nr || ')');
 end if;

 --delete from nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
 --delete from onedata_ra.nci_mec_val_map where mecvm_id = ihook.getColumnValue(row_ori,'MECVM_ID');
 if (hookinput.invocationnumber = 1) then 
 
delete from nci_mec_val_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
delete from onedata_ra.nci_mec_val_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;

delete from nci_mec_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;
delete from onedata_ra.nci_mec_map where  mdl_map_item_id = v_item_id and mdl_map_ver_nr = v_ver_nr;


delete from nci_mdl_map where  item_id = v_item_id and ver_nr = v_ver_nr;
delete from onedata_ra.nci_mdl_map where  item_id = v_item_id and ver_nr = v_ver_nr;


delete from admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
delete from onedata_ra.admin_item where  item_id = v_item_id and ver_nr = v_ver_nr;
commit;

hookoutput.message :=  'Model Mapping deleted successfully: ' || v_item_id || 'v'|| v_ver_Nr;
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
 
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --nci_util.debugHook('GENERAL',v_data_out);
 --  raise_application_error(-20000,'Here');
end;



   procedure spUpdateModelMap( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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
  
        ihook.setcolumnValue(row_ori, 'MECM_ID', nvl(ihook.getColumnValue(row_ori,'IMP_RULE_ID'),ihook.getColumnValue(row_ori,'STG_MECM_ID')));
        Select count(*) into v_temp  from nci_mec_map where mecm_id = ihook.getcolumnValue(row_ori,'MECM_ID');
 
        if (v_temp= 0) then
            rowsadd.extend;   rowsadd(rowsadd.last) := row_ori;
 --   raise_application_error(-20000,' Add');
        else
        rowsupd.extend;   rowsupd(rowsupd.last) := row_ori;
    end if;
 
    ihook.setColumnValue(row_ori,'CTL_VAL_STUS','UPDATED');
     rows.extend;   rows(rows.last) := row_ori;
 
    end if; 
 end loop;
 
  if (rowsadd.count>0) then
   action := t_actionrowset(rowsadd, 'Model Map - Characteristics (Hook)', 2,6,'insert');
        actions.extend;
        actions(actions.last) := action;
    end if;
    
 if (rowsupd.count>0) then
   action := t_actionrowset(rowsupd, 'Model Map - Characteristics (Hook)', 2,1,'update');
        actions.extend;
        actions(actions.last) := action;
    end if;
  
  if (rows.count>0) then
   action := t_actionrowset(rows, 'Model Map Import', 2,6,'update');
        actions.extend;
        actions(actions.last) := action;
        hookoutput.actions := actions;
    end if;
    
 hookoutput.message:= 'New mapping inserted: ' || rowsadd.count || ' Mapping updated: ' || rowsupd.count;
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
 nci_util.debugHook('GENERAL',v_data_out);
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


   procedure spUpdateModel ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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


   procedure spUpdateModelCDEAssoc ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
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
  v_mdl_hdr_id number;
  v_mdl_elmnt_id number;
 v_cnt integer :=0;
 v_cs_item_id number;
 v_cs_ver_nr number(4,2);
 v_alt_nm_typ integer;
 v_tbl_alt_nm_typ integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  
   for cur in (select * from nci_mdl where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and  ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
   v_cs_item_id := cur.ASSOC_CS_ITEM_ID;
   v_cs_ver_nr := cur.ASSOC_CS_VER_NR;
   v_alt_nm_typ := cur.ASSOC_NM_TYP_ID;
   v_tbl_alt_nm_typ := cur.ASSOC_TBL_NM_TYP_ID;
   if (cur.ASSOC_NM_TYP_ID is null or cur.ASSOC_TBL_NM_TYP_ID is null or cur.ASSOC_CS_ITEM_ID is null ) then 
  raise_application_error(-20000, 'For this functionality, please make sure Model Alternate Name Type, Table Alternate Name Type and CS is specified.');
  end if;
  end loop;
  
  rows := t_rows();
  -- raise_application_Error(-20000, v_cs_item_id || ' ' || v_alt_nm_typ || ' ' || v_tbl_alt_nm_typ);
 
  for curchar in (select mec_id, MEC_PHY_NM, me.ITEM_PHY_OBJ_NM me_phy_nm,me.ITEM_LONG_NM me_long_nm,  mec.cde_item_id from  nci_mdl_elmnt me, nci_mdl_elmnt_char mec where me.MDL_ITEM_ID =ihook.getColumnValue(row_ori,'ITEM_ID') 
  and me.MDL_ITEM_VER_NR=ihook.getColumnValue(row_ori,'VER_NR') and me.item_id = mec.MDL_ELMNT_ITEM_ID and me.ver_nr =mec.MDL_ELMNT_VER_NR) loop
  
  for curcde in (select item_id, ver_nr, de_conc_item_id,de_conc_ver_nr, val_dom_item_id, val_dom_ver_nr from de where
  (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_alt_nm_typ and upper(nm_desc) = upper(curchar.mec_phy_nm))
  and  (item_id, ver_nr) in (Select item_id, ver_nr from alt_nms where nm_typ_id = v_tbl_alt_nm_typ and upper(nm_desc) = upper(curchar.me_phy_nm))
  and  (item_id, ver_nr) in (Select r.c_item_id, r.c_item_ver_nr from nci_admin_item_rel r, vw_clsfctn_schm_item csi where csi.cs_item_id = v_cs_item_id 
  and csi.cs_item_ver_nr = v_cs_ver_nr and csi.item_id = r.p_item_id and csi.ver_nr = r.p_item_ver_nr and r.rel_typ_id = 65)) loop
 -- raise_application_Error(-20000, curchar.mec_phy_nm);
  if (curchar.cde_item_id != curcde.item_id and curchar.cde_item_id is not null) then
    update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR, chng_desc_txt)
= (select curcde.ITEM_ID, curcde.VER_NR, curcde.DE_CONC_ITEM_ID, curcde.DE_CONC_VER_NR, curcde.VAL_DOM_ITEM_Id, curcde.VAL_DOM_VER_NR, 'Updated CDE from ' || curchar.cde_item_id from dual)
where  mec_id = curchar.mec_id;
v_cnt := v_cnt + 1;
  end if;
  if ( curchar.cde_item_id is null) then
    update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR)
= (select curcde.ITEM_ID, curcde.VER_NR, curcde.DE_CONC_ITEM_ID, curcde.DE_CONC_VER_NR, curcde.VAL_DOM_ITEM_Id, curcde.VAL_DOM_VER_NR from dual)
where  mec_id = curchar.mec_id;
v_cnt := v_cnt + 1;
  end if;
  
  end loop;
  end loop;
  commit;
  /*
update nci_mdl_elmnt_char c set (CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_ID, VAL_DOM_VER_NR)
= (select CDE_ITEM_ID, CDE_VER_NR, DE_CONC_ITEM_ID, DE_CONC_VER_NR, VAL_DOM_ITEM_Id, VAL_DOM_VER_NR
where  mdl_elmnt_item_id = curelmnt.item_id and mdl_elmnt_ver_nr = curelmnt.ver_nr;
commit;
 */
 hookoutput.message := 'CDE refresh complete. ' || v_cnt || ' characteristics updated.';
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
    
  
  
  select count(*) into v_temp from nci_stg_mdl_elmnt_char where mdl_imp_id = ihook.getColumnValue(row_ori, 'MDL_IMP_ID') and ctl_val_msg is not null;
  
  if (v_temp > 0) then -- error
  v_valid := false;
   -- v_val_stus_msg := v_val_stus_msg || 'Characteristic: ' || v_temp || ' error(s) found in specified CDE Item Id/Version or max character is blank.' || chr(13);
    v_val_stus_msg := v_val_stus_msg || 'Characteristic: ' || v_temp || ' error(s) found in specified CDE Item Id/Version.' || chr(13);
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

   procedure spValDeriveModelMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
   as
   hookInput t_hookInput;
  hookOutput t_hookOutput := t_hookOutput();
   actions t_actions := t_actions();
  action t_actionRowset;
  row t_row;
  rows  t_rows;
    row_ori t_row;
    v_id integer;
    action_rows       t_rows := t_rows();
  action_row		    t_row;
  rowset            t_rowset;
 v_item_id number;
 v_ver_nr number(4,2);
  v_valid boolean;
  v_val_stus_msg varchar2(2000);
 i integer;
 
 v_temp integer;
 BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;
  
  row_ori :=  hookInput.originalRowset.rowset(1);
  v_valid := true;
  v_val_stus_msg := '';
  v_item_id := ihook.getColumnValue(row_ori,'ITEM_ID');
  v_ver_nr := ihook.getColumnValue(row_ori,'VER_NR');
  /*
  *..*	Many-To-Many
TBD 0..1	Zero-To-One. Used to show the default value of a target model characteristic.
1..0	One-To-Zero. Used to indicate that the source characteristic has no mapping in the target model, or must be ignored.
0..*	Zero-To-Many
1..1	One-To-One = 121
*..1	Many-To-One = 119
1..*	One-To-Many = 118
*/
  
 
  -- Derive Mapping cardinality
  
  update nci_mec_map set  CRDNLITY_ID = null where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr;
  commit;
  
 
  
  -- 1..0
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..0';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	SRC_MEC_ID is  not null and 
  TGT_MEC_ID is null and SRC_FUNC_ID is null and 	SRC_VAL is  null and 
  CRDNLITY_ID is null and upper(mec_map_nm) like '%IGNORE%';
  commit;
  
  -- 1..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..1';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and CRDNLITY_ID is null and ( MEC_MAP_NM) in
  (select  MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	SRC_MEC_ID is  not null and 
  TGT_MEC_ID is not null  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(*) =1)
;
  
  commit;
  
 -- 0..* 
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '0..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 
  CRDNLITY_ID is null and ( MEC_MAP_NM) in
  (select  MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr  and nvl(fld_Delete,0) = 0 
  group by MEC_MAP_NM having count(distinct src_mec_id) =0 and count(distinct tgt_mec_id) > 0);
  commit;
  
  -- 1..*
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '1..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and CRDNLITY_ID is null  and ( MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
 -- TGT_MEC_ID is not null  
 and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) =1 and count(distinct tgt_mec_id) > 1);
  
  commit;
  
  -- *..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '*..1';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	CRDNLITY_ID is null  and (MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
  --TGT_MEC_ID is not null  
  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) >1 and count(distinct tgt_mec_id) = 1);
  
  commit;
  
  -- *..1
  select obj_key_id into v_id from obj_Key where obj_typ_id = 47 and obj_key_desc = '*..*';
  update nci_mec_map set  CRDNLITY_ID = v_id where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr and 	 CRDNLITY_ID is null and 
   ( MEC_MAP_NM) in (
  select MEC_MAP_NM from nci_mec_map where MDL_MAP_ITEM_ID = v_item_id and MDL_MAP_VER_NR = v_ver_nr 
  --and 	SRC_MEC_ID is  not null and 
  --TGT_MEC_ID is not null  
  and nvl(fld_Delete,0) = 0
  group by MEC_MAP_NM having count(distinct src_mec_id) >1 and count(distinct tgt_mec_id) > 1);
  
  commit;


hookoutput.message := 'Derivation of Cardinality completed.'; 
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


   procedure spVersionModelMapping ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)
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

procedure spGenerateMap ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--hookoutput.message := 'Work in progress.';
        row_ori := hookInput.originalRowset.rowset(1);
  
    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
    and nvl(MAP_DEG,1)<>120;
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') 
    and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR') and nvl(MAP_DEG,1)<>120;
    commit;
    
    rows := t_rows();
    
    -- semantically equivalent
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id,me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr , mec1.de_conc_item_id src_DE_CONC_ITEM_ID, mec2.DE_CONC_ITEM_ID tgt_DE_CONC_ITEM_ID
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.ME_GRP_ID = me2.ME_GRP_ID (+) 
and 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id (+)= mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr (+)= mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID (+) and me2.ver_nr = mec2.MDL_ELMNT_VER_NR (+)
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID (+) and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR (+)
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        if (cur.src_DE_CONC_ITEM_ID = cur.TGT_DE_CONC_ITEM_ID) then
        ihook.setColumnValue(row,'MAP_DEG',86);
        end if;
        ihook.setColumnValue(row,'MECM_ID',-1);
       ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
         
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;


procedure spGenerateMapDECOnly ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_func integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
    v_nmtyp integer;
    v_nm_desc varchar2(4000);
    v_term_src  varchar2(255);
    v_src_nm_desc varchar2(4000);
    v_equals_func  integer;
    
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--hookoutput.message := 'Work in progress.';
        row_ori := hookInput.originalRowset.rowset(1);
  select obj_key_id into v_func from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
  select obj_key_id into v_equals_func from obj_key where obj_key_desc = 'EQUALS' and obj_typ_id = 51;
  select obj_key_id into v_nmtyp from obj_key where obj_key_desc = 'Ref Term Short Name' and obj_typ_id = 11;
        
    delete from NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131);
    commit;
    delete from onedata_ra.NCI_MEC_MAP where MDL_MAP_ITEM_ID = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue(row_ori, 'VER_NR')
     and nvl(MAP_DEG,1) not in (120,131);
    commit;
    rows := t_rows();
   for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr 
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID = mec2.CDE_ITEM_ID and mec1.CDE_VER_NR = mec2.CDE_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MAP_DEG',86);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        	
            
        ihook.setColumnValue(row,'MECM_ID',-1);
                 

                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
 -- Semantically similar
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr 
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID != mec2.CDE_ITEM_ID -- and nvl(mec1.CDE_VER_NR,1) != nvl(mec2.CDE_VER_NR,2)
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MAP_DEG',87);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MECM_ID',-1);
        --  Enumerated by Reference
        -- Set Target function to xlookup, source and target parameters
        for cursrc in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.src_mec_id) loop

        for curtgt in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.tgt_mec_id) loop

        --  src is enum, target is enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 17) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|TARGET PV'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
        --enum/non-enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 18) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|SOURCE LABEL'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
     -- non-enum/enum then 2 rows - use case 3
     
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 17) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
            --    ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
            
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
        -- non-enum/Enum by Ref - use case 4
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                     ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
          -- ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
         -- enum/Enum by Ref
         if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/Enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 17) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
               
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/non-enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 18) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc), upper(o.obj_key_Desc)  into v_nm_desc,  v_term_src from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            -- use case 8
                if (v_term_src= 'CODE') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|TERM'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
                
                if (v_term_src= 'TERM') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
        
        end if;
        
        -- use case 5 - non-enum/non-enum
            if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 18) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
          end if;
            -- Enum by Ref/Enum by Ref
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 16) then
         select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_src_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
                
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_src_nm_desc || '|' || v_nm_desc); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
               
        end if;
        /*
            for curc in (select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL',curc.nm_desc);
            end loop;*/
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
  
  -- Not mapped
  
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.TGT_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MECM_ID',-1);
     ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Target DEC Found.');
       
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL', curc.nm_desc);
            end loop;
            end loop;
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.SRC_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.SRC_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MECM_ID',-1);
        ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Source DEC Found.');
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr  and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id   (+)= v_nmtyp)
            loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM', curc.nm_desc);
              ihook.setColumnValue(row,'TGT_VAL',curc.nm_desc);
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

-- no CDE moved to not mapped


    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MECM_ID',-1);
     ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
       
      
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
        ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        ihook.setColumnValue(row,'MECM_ID',-1);
        ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
      
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

 --  raise_application_error(-20000,rows.count);
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  hookoutput.message := 'Semantic mapping generated.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --   nci_util.debugHook('GENERAL', v_data_out);

end;

procedure   getStdMMComment(row in out t_row,row_ori in t_row)
as
i integer;
begin

ihook.setColumnValue(row, 'CMNTS_DESC_TXT','New generated mapping created on ' || sysdate||' due to a change in CDE assignment to either the source or target characteristic.');
      ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori, 'ITEM_ID'));
        ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue (row_ori,'VER_NR'));
      ihook.setColumnValue(row,'MECM_ID',-1);
      
end;
            

procedure spGenerateMapIncrement ( v_data_in in clob, v_data_out out clob, v_user_id in varchar2)

AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();

    actions t_actions := t_actions();
    action t_actionRowset;
    row t_row;
    rows  t_rows;
    row_ori t_row;
    v_val_dom_typ integer;
    v_ver_nr number(4,2);
    v_temp integer;
    v_func integer;
    v_hdr_id number;
    v_already integer :=0;
    i integer := 0;
    v_flt_str  varchar2(1000);
    v_sql varchar2(4000);
    v_entty_nm varchar2(255);
    v_entty_nm_like varchar2(255);
    v_cntxt_str varchar2(255);
    v_cnt integer;
    v_str varchar2(255);
    v_minlen integer;
    v_entty_nm_with_space varchar2(255);
    v_nmtyp integer;
    v_nm_desc varchar2(4000);
    v_term_src  varchar2(255);
    v_src_nm_desc varchar2(4000);
    v_equals_func  integer;
    
--    v_reg_str varchar2(255);
 -- v_entty_nm varchar2(4000);
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;
   
--hookoutput.message := 'Work in progress.';
        row_ori := hookInput.originalRowset.rowset(1);
  select obj_key_id into v_func from obj_key where obj_key_desc = 'QUERY' and obj_typ_id = 51;
  select obj_key_id into v_equals_func from obj_key where obj_key_desc = 'EQUALS' and obj_typ_id = 51;
  select obj_key_id into v_nmtyp from obj_key where obj_key_desc = 'Ref Term Short Name' and obj_typ_id = 11;
        -- no deletes
    rows := t_rows();
   for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr 
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID = mec2.CDE_ITEM_ID and mec1.CDE_VER_NR = mec2.CDE_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (mec1.mec_id , mec2.mec_id) not in (select src_mec_id, tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null 
and tgt_mec_id is not null)) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MAP_DEG',86);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
        getStdMMComment(row,row_ori);
            
               

                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
 -- Semantically similar
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mec2.MEC_LONG_NM TGT_MEC_LONG_NM, mec2.mec_id TGT_MEC_ID, me1.mdl_item_id src_mdl_item_id,
    me1.mdl_item_ver_nr src_mdl_ver_nr ,me2.mdl_item_id tgt_mdl_item_id, me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM,
    me2.mdl_item_ver_nr tgt_mdl_ver_nr 
from nci_mdl_elmnt me1, nci_mdl_elmnt me2, nci_mdl_elmnt_char mec1, nci_mdl_elmnt_char mec2, NCI_MDL_MAP mm
where 
--nvl(me1.DOM_ITEM_ID,1) = nvl(me2.DOM_ITEM_ID,1)  and nvl(me1.DOM_VER_NR,1) = nvl(me2.DOM_VER_NR,1)
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR and me2.mdl_item_id = mm.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and mec1.CDE_ITEM_ID != mec2.CDE_ITEM_ID -- and nvl(mec1.CDE_VER_NR,1) != nvl(mec2.CDE_VER_NR,2)
and mec1.DE_CONC_ITEM_ID = mec2.DE_CONC_ITEM_ID and mec1.DE_CONC_VER_NR = mec2.DE_CONC_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR')
and (mec1.mec_id , mec2.mec_id) not in (select src_mec_id, tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null 
and tgt_mec_id is not null)) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.tgt_mec_id);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
       ihook.setColumnValue(row,'MAP_DEG',87);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
              getStdMMComment(row,row_ori);
  
        --  Enumerated by Reference
        -- Set Target function to xlookup, source and target parameters
        for cursrc in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.src_mec_id) loop

        for curtgt in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and c.mec_id = cur.tgt_mec_id) loop

        --  src is enum, target is enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 17) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|TARGET PV'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
        --enum/non-enum
        if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 18) then
             ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|SOURCE LABEL'); 
           ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
     end if;
     -- non-enum/enum then 2 rows - use case 3
     
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 17) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
            --    ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
            
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
        -- non-enum/Enum by Ref - use case 4
         if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                     ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt TERM|NCIt CODE'); 
          -- ihook.setColumnValue(row,'TGT_FUNC_PARAM','NCIt|NCIt TERM|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
         -- enum/Enum by Ref
         if (cursrc.val_dom_typ_id =17 and curtgt.val_dom_typ_id = 16) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|SOURCE PV|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
                select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|NCIt CODE|' || v_nm_Desc); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/Enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 17) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|NCIt CODE'); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                rows.extend;   rows(rows.last) := row;
                -- get ref term name
               
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','VALUE MAP|NCIt CODE|TARGET PV'); 
            ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',2);
            
        end if;
        
           -- Enum by Ref/non-enum
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 18) then
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc), upper(o.obj_key_Desc)  into v_nm_desc,  v_term_src from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            -- use case 8
                if (v_term_src= 'CODE') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_nm_desc || '|TERM'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
                
                if (v_term_src= 'TERM') then
                    ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
                end if;
        
        end if;
        
        -- use case 5 - non-enum/non-enum
            if (cursrc.val_dom_typ_id =18 and curtgt.val_dom_typ_id = 18) then
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_equals_func);
                    ihook.setColumnValue(row,'TGT_FUNC_PARAM','SOURCE'); 
                    ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
          end if;
            -- Enum by Ref/Enum by Ref
         if (cursrc.val_dom_typ_id =16 and curtgt.val_dom_typ_id = 16) then
         select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_src_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = cursrc.term_use_typ and c.item_id = cursrc.TERM_CNCPT_ITEM_ID and c.ver_nr = cursrc.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
                
            select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) into v_nm_desc from vw_cncpt c, alt_nms a, obj_key o 
                where o.obj_key_id = curtgt.term_use_typ and c.item_id = curtgt.TERM_CNCPT_ITEM_ID and c.ver_nr = curtgt.TERM_CNCPT_VER_NR
                and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp;
            
                ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
                ihook.setColumnValue(row,'TGT_FUNC_PARAM','XWALK|' || v_src_nm_desc || '|' || v_nm_desc); 
                ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',1);
               
        end if;
        /*
            for curc in (select  nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc) nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL',curc.nm_desc);
            end loop;*/
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
  
  -- Not mapped
  
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.TGT_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.TGT_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
             getStdMMComment(row,row_ori);
    ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Target DEC Found.');
       
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id  (+)= v_nmtyp)
             loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'SRC_VAL', curc.nm_desc);
            end loop;
            end loop;
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mec1.cde_item_id is not null
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and nvl(mec1.de_conc_item_id,333) not in (select distinct mec2.de_conc_item_id from 
nci_mdl_elmnt me2,  nci_mdl_elmnt_char mec2,  NCI_MDL_MAP mm2
where me2.ITEM_ID = mec2.MDL_ELMNT_ITEM_ID and me2.ver_nr = mec2.MDL_ELMNT_VER_NR
and me2.mdl_item_id = mm2.SRC_MDL_ITEM_ID and me2.mdl_item_ver_nr = mm2.SRC_MDL_VER_NR 
and mm2.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm2.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') and mec2.de_conc_item_id is not null)
and (mec1.mec_id ) not in (select tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and tgt_mec_id is not null )) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MAP_DEG',130); -- not mapped
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
               getStdMMComment(row,row_ori);
      ihook.setColumnValue(row,'MEC_MAP_NOTES','No Matching Source DEC Found.');
        for curvd in (select val_dom_item_id, val_dom_ver_nr, vd.val_dom_typ_id,TERM_CNCPT_ITEM_ID, TERM_CNCPT_VER_NR, TERM_USE_TYP  
        from nci_mdl_elmnt_char c, value_dom vd
        where c.val_dom_item_id = vd.item_id and c.val_dom_ver_nr = vd.ver_nr  and vd.val_dom_typ_id = 16 and c.mec_id = cur.src_mec_id) loop

            for curc in (select nvl(a.nm_desc,c.item_nm) || ' ' || upper(o.obj_key_desc)  nm_desc from vw_cncpt c, alt_nms a, obj_key o 
            where o.obj_key_id = curvd.term_use_typ and c.item_id = curvd.TERM_CNCPT_ITEM_ID and c.ver_nr = curvd.TERM_CNCPT_VER_NR
            and c.item_id = a.item_id (+) and c.ver_nr = a.ver_nr (+) and a.nm_typ_id   (+)= v_nmtyp)
            loop
              ihook.setColumnValue(row,'TGT_FUNC_ID',v_func);
              ihook.setColumnValue(row,'TGT_FUNC_PARAM', curc.nm_desc);
              ihook.setColumnValue(row,'TGT_VAL',curc.nm_desc);
            end loop;
            end loop;
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

-- no CDE moved to not mapped


    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, me1.mdl_item_id src_mdl_item_id,  
    me1.mdl_item_ver_nr src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.SRC_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.SRC_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
and (mec1.mec_id ) not in (select src_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and src_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'SRC_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
        ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
         ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
          ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
            getStdMMComment(row,row_ori);
     ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
       
      
           
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
    
    for cur in (select  mec1.MEC_LONG_NM SRC_MEC_LONG_NM, mec1.mec_id SRC_MEC_ID, mm.src_mdl_item_id,  
    mm.src_mdl_ver_nr , me1.ITEM_LONG_NM SRC_ME_ITEM_LONG_NM, mm.TGT_MDL_ITEM_ID, mm.TGT_MDL_VER_NR
from nci_mdl_elmnt me1,  nci_mdl_elmnt_char mec1,  NCI_MDL_MAP mm
where 
me1.mdl_item_id =mm.TGT_MDL_ITEM_ID and me1.mdl_item_ver_nr = mm.TGT_MDL_VER_NR 
and me1.ITEM_ID = mec1.MDL_ELMNT_ITEM_ID and me1.ver_nr = mec1.MDL_ELMNT_VER_NR
and mm.item_id  = ihook.getColumnValue(row_ori, 'ITEM_ID') and mm.ver_nr = ihook.getColumnValue (row_ori,'VER_NR') 
and mec1.cde_item_id is null
and (mec1.mec_id ) not in (select tgt_mec_id from nci_mec_map where 
MDL_MAP_ITEM_ID  = ihook.getColumnValue(row_ori, 'ITEM_ID') and MDL_MAP_VER_NR = ihook.getColumnValue (row_ori,'VER_NR') and tgt_mec_id is not null )
) loop

        row := t_row();
        ihook.setColumnValue(row,'TGT_MEC_ID',cur.src_MEC_ID);
        ihook.setColumnValue(row,'SRC_MDL_ITEM_ID',cur.src_MDL_ITEM_ID);
        ihook.setColumnValue(row,'SRC_MDL_VER_NR',cur.src_MDL_VER_NR);
        ihook.setColumnValue(row,'TGT_MDL_ITEM_ID',cur.TGT_MDL_ITEM_ID);
        ihook.setColumnValue(row,'TGT_MDL_VER_NR',cur.TGT_MDL_VER_NR);
         ihook.setColumnValue(row,'MAP_DEG',129); -- no CDE
         ihook.setColumnValue(row,'MEC_SUB_GRP_NBR',0);
        ihook.setColumnValue(row,'MEC_MAP_NM',cur.SRC_ME_ITEM_LONG_NM  ||'.'  || cur.SRC_MEC_LONG_NM);
                getStdMMComment(row,row_ori);
    ihook.setColumnValue(row,'MEC_MAP_NOTES','No CDE attached.');
      
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;

 --  raise_application_error(-20000,rows.count);
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
  hookoutput.actions := actions;
  hookoutput.message := 'Semantic mapping generated.';
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
   --   nci_util.debugHook('GENERAL', v_data_out);

end;

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
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
        
        if (ihook.getColumnValue(row_ori,'SRC_MEC_ID') is null or ihook.getColumnValue(row_ori,'TGT_MEC_ID') is null) then
          raise_application_error(-2000,'Both Source Characteristics and Target Characteristics have to be specified for Value Mapping Generation.');
        end if;
    
    for cur in (select * from nci_mdl_elmnt_char where mec_id in ( ihook.getColumnValue(row_ori,'SRC_MEC_ID'),
     ihook.getColumnValue(row_ori,'TGT_MEC_ID')) and CDE_ITEM_ID is null ) loop
           raise_application_error(-2000,'Both Source and Target Characteristics should have CDE specified for Value Mapping Generation.');
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
    
    delete from NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and nvl(map_deg,87) = 87;
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where src_mec_id = ihook.getColumnValue(row_ori, 'SRC_MEC_ID') and tgt_mec_id = ihook.getColumnValue(row_ori, 'TGT_MEC_ID') and nvl(map_deg,87) = 87;
    commit;
    
    rows := t_rows();
    for i in 1..output_rows.count loop
        row := row_ori;
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
                ihook.setColumnValue(row,'MAP_DEG',87);
 
        ihook.setColumnValue(row,'MECVM_ID',-1);
        
                                     rows.extend;
                                            rows(rows.last) := row;

    end loop;
   -- raise_application_Error(-20000,rows.count);
            action := t_actionrowset(rows, 'Model Map Characteristic Values', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
        
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
    
begin
    hookinput := ihook.gethookinput (v_data_in);
    hookoutput.invocationnumber  := hookinput.invocationnumber;
    hookoutput.originalrowset    := hookinput.originalrowset;

        row_ori := hookInput.originalRowset.rowset(1);
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
    and (upper(SOURCE_DOMAIN_TYPE)= 'ENUMERATED' or upper(TARGET_DOMAIN_TYPE)='ENUMERATED') and upper(MAPPING_DEGREE)='SEMANTIC SIMILAR') loop
   
  --  raise_application_error(-20000, v_src_alt_nm_typ);
    
    input_rows := t_rows();
    output_rows := t_rows();
    
    for cur in (select val_dom_item_id, val_dom_ver_nr from nci_mdl_elmnt_char c, value_dom v where mec_id = outercur.SRC_MEC_ID and
    c.val_dom_item_id = v.item_id and c.val_dom_ver_Nr = v.ver_nr ) loop
      row := t_row();
      ihook.setColumnValue (row, 'ITEM_ID', cur.val_dom_item_id);
      ihook.setColumnValue (row, 'VER_NR', cur.val_dom_ver_nr);
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
    
    delete from NCI_MEC_VAL_MAP where src_mec_id = outercur.SRC_MEC_ID  and tgt_mec_id = outercur.tgt_MEC_ID  and nvl(map_deg,87) = 87;
    commit;
    delete from onedata_ra.NCI_MEC_VAL_MAP where src_mec_id = outercur.SRC_MEC_ID  and tgt_mec_id = outercur.tgt_MEC_ID  and nvl(map_deg,87) = 87;
    commit;
    
    rows := t_rows();
    for i in 1..output_rows.count loop
    row := t_row();
         ihook.setColumnValue(row,'MDL_MAP_ITEM_ID',ihook.getColumnValue(row_ori,'ITEM_ID'));
      ihook.setColumnValue(row,'MDL_MAP_VER_NR',ihook.getColumnValue(row_ori,'VER_NR'));
    
        ihook.setColumnValue(row,'SRC_MEC_ID',outercur.src_mec_id);
        ihook.setColumnValue(row,'TGT_MEC_ID',outercur.TGT_mec_id);
    
        ihook.setColumnValue(row,'SRC_PV',ihook.getColumnValue(output_rows(i),'1'));
        ihook.setColumnValue(row,'TGT_PV',ihook.getColumnValue(output_rows(i),'2'));
        ihook.setColumnValue(row,'SRC_LBL',ihook.getColumnValue(output_rows(i),'LBL_1'));
        ihook.setColumnValue(row,'TGT_LBL',ihook.getColumnValue(output_rows(i),'LBL_2'));
        ihook.setColumnValue(row,'VM_CNCPT_CD',ihook.getColumnValue(output_rows(i),'VM Concept Codes'));
        ihook.setColumnValue(row,'VM_CNCPT_NM',ihook.getColumnValue(output_rows(i),'VM Name'));
         ihook.setColumnValue(row,'MAP_DEG',87);
        ihook.setColumnValue(row,'MECVM_ID',-1);
        
                                     rows_v.extend;
                                            rows_v(rows_v.last) := row;

    end loop;
   -- raise_application_Error(-20000,rows.count);
           
        row:= t_row();
        ihook.setColumnValue(row, 'MECM_ID',outercur.MECM_ID);
        ihook.setColumnValue(row,'VAL_MAP_CREATE_IND',1);
        rows_x.extend;     rows_x(rows_x.last) := row;
       
         
    end loop;
     action := t_actionrowset(rows_v, 'Model Map Characteristic Values', 2,2,'insert');
        actions.extend;
        actions(actions.last) := action;
           action := t_actionrowset(rows_x, 'Model Map - Characteristics', 2,3,'update');
        actions.extend;
        actions(actions.last) := action; 
  hookoutput.actions := actions;
  
    V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
-- nci_util.debugHook('GENERAL', v_data_out);
  
end;


PROCEDURE spAddManualMap (v_data_in IN CLOB,    v_data_out OUT CLOB, v_user_id  IN varchar2)
AS
    hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
    rowmap t_row;
    forms t_forms;
    form1 t_form;
    row t_row;
    rows  t_rows;
    rowset            t_rowset;
    rowsetmap            t_rowset;
  
    actions t_actions := t_actions();
    action t_actionRowset;
   row_ori t_row;
  
 question t_question;
  answer t_answer;
  answers t_answers;

BEGIN
  hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

  row_ori := hookInput.originalRowset.rowset(1);
  
    if hookInput.invocationNumber = 0 then

 ANSWERS                    := T_ANSWERS();
    ANSWER                     := T_ANSWER(1, 1, 'Add New Mapping');
    ANSWERS.EXTEND;
    ANSWERS(ANSWERS.LAST) := ANSWER;
    QUESTION               := T_QUESTION('Add Manual Mapping', ANSWERS);
HOOKOUTPUT.QUESTION    := question;

          row := t_row();
          rows := t_rows();
         
          ihook.setColumnValue(row, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(row, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
          
          for cur in ( select * from nci_mdl_map where item_id = ihook.getColumnValue(row_ori,'ITEM_ID') and ver_nr = ihook.getColumnValue(row_ori,'VER_NR')) loop
          ihook.setColumnValue(row, 'SRC_MDL_ITEM_ID', cur.src_mdl_item_id);
          ihook.setColumnValue(row, 'SRC_MDL_VER_NR', cur.src_mdl_ver_nr);
          ihook.setColumnValue(row, 'TGT_MDL_ITEM_ID', cur.tgt_mdl_item_id);
          ihook.setColumnValue(row, 'TGT_MDL_VER_NR', cur.tgt_mdl_ver_nr);
            ihook.setColumnValue(row, 'MECM_ID', -1);
          end loop;
          rows.extend;
          rows(rows.last) := row;
          rowsetmap := t_rowset(rows, 'Model Map - Characteristics', 1, 'NCI_MEC_MAP');
        forms                  := t_forms();
    form1                  := t_form('Model Map - Characteristics', 2,1);
    form1.rowset :=rowsetmap;
    forms.extend;    forms(forms.last) := form1;
 
    hookOutput.forms := forms;


  ELSE
      forms              := hookInput.forms;
      form1              := forms(1);
      rowmap := form1.rowset.rowset(1);
      
      ihook.setColumnValue(rowmap, 'MDL_MAP_ITEM_ID', ihook.getColumnValue(row_ori,'ITEM_ID'));
          ihook.setColumnValue(rowmap, 'MDL_MAP_VER_NR', ihook.getColumnValue(row_ori,'VER_NR'));
    
            rows := t_rows();
            rows.extend;    rows(rows.last) := rowmap;
            action := t_actionrowset(rows, 'Model Map - Characteristics', 2,1,'insert');
            actions.extend;
            actions(actions.last) := action;

            hookoutput.message := 'Manual Map created successfully.';
                hookoutput.actions := actions;
    
 end if;
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
--  nci_util.debugHook('GENERAL', v_data_out);
END;

procedure dervTgtMEC(v_data_in IN CLOB,    v_data_out OUT CLOB)
as
v_temp integer;
   hookInput t_hookInput;
    hookOutput t_hookOutput := t_hookOutput();
 begin
     hookinput                    := Ihook.gethookinput (v_data_in);
  hookoutput.invocationnumber  := hookinput.invocationnumber;
  hookoutput.originalrowset    := hookinput.originalrowset;

    execute immediate 'ALTER TABLE NCI_MEC_MAP DISABLE ALL TRIGGERS';
   
update nci_mec_map set tgt_mec_id_derv = null;
commit;
update nci_mec_map set tgt_mec_id_derv = tgt_mec_id where src_mec_id is not null and tgt_mec_id is not null;
commit;
update nci_mec_map set tgt_mec_id_derv = tgt_mec_id where src_mec_id is null and tgt_mec_id is not null and (upper(TGT_VAL) <> 'NULL' or OP_ID is not null);
commit;
for cur in (Select * from nci_mec_map where tgt_mec_id is null and (src_func_id is not null or RIGHT_OP is not null or LEFT_OP is not null or 	FLOW_CNTRL is not null ) order by MEC_MAP_NM,MEC_SUB_GRP_NBR) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id) from nci_mec_map 
where mec_map_nm = cur.mec_map_nm and MDL_MAP_ITEM_ID=cur.MDL_MAP_ITEM_ID and MDL_MAP_VER_NR = cur.MDL_MAP_VER_NR
and tgt_mec_id is not null and mec_sub_grp_nbr < cur.mec_sub_grp_nbr )
where mecm_id = cur.mecm_id;

for cux in (Select * from nci_mec_map where mecm_id = cur.mecm_id and tgt_mec_id_derv is null) loop
update nci_mec_map set tgt_mec_id_derv = (select min(tgt_mec_id) from nci_mec_map where mec_map_nm = cur.mec_map_nm and MDL_MAP_ITEM_ID=cur.MDL_MAP_ITEM_ID and MDL_MAP_VER_NR = cur.MDL_MAP_VER_NR
and tgt_mec_id is not null and mec_sub_grp_nbr > cur.mec_sub_grp_nbr )
where mecm_id = cur.mecm_id;
end loop;

end loop;

update nci_mec_map set tgt_mec_id_derv =tgt_mec_id where tgt_mec_id_derv is null and tgt_mec_id is not null;
commit;

     execute immediate 'ALTER TABLE NCI_MEC_MAP ENABLE ALL TRIGGERS';
     
                 hookoutput.message := 'Derivation of Target Characteristic completed.';
  V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);

     end;
     

END;
/
