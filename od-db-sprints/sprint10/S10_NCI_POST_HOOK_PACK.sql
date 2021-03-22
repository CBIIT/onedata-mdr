CREATE OR REPLACE PACKAGE ONEDATA_WA.nci_post_hook AS

procedure spRefDocInsUpd ( v_data_in in clob, v_data_out out clob, v_user_id varchar2);

END;
/

CREATE OR REPLACE PACKAGE BODY ONEDATA_WA.NCI_POST_HOOK AS

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
  if (ihook.getColumnValue(row_ori,'REF_TYP_ID') = 80) then
    raise_application_error(-20000,'You cannot insert or update Preferred Question Text from Reference Documents. Please use Section 4 - Relational/Representation Attributes.');
 end if;
 
 V_DATA_OUT := IHOOK.GETHOOKOUTPUT (HOOKOUTPUT);
end;

END;
/
