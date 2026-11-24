create or replace TRIGGER OD_TR_DS_HDR_RSLT_CDE  BEFORE INSERT  on  NCI_DS_RSLT for each row
BEGIN
    :new.ITEM_ID_2 := :new.ITEM_ID;
    :new.VER_NR_2 := :new.VER_NR;
END ;
/


--- ONEDATA_WA
create or replace TRIGGER TR_NCI_MDL_INS
AFTER INSERT
   ON NCI_MDL
   FOR EACH ROW
DECLARE
   v_username varchar2(100);
   v_temp integer;
   v_text CLOB := '';
   v_cur_email_id varchar2(1000);
   v_text_tbl clob := '';
BEGIN
select count(*) into v_temp from admin_item where item_id = :new.item_id;
if (v_temp > 1) then -- version
v_text := 'Model ' || :new.item_id || ' was versioned. New version number: ' || :new.ver_nr || '<br>';
v_text := v_text || 'Please verify if you need to update your model mappings: <br> <br> <table> <tr><th>Model Map ID</th><th>Model Map Version</th></tr>';

for cur in (select distinct item_id, ver_nr, email_id, e.usr_nm from nci_mdl_map m, vw_usr_email e  where (src_mdl_item_id = :new.item_id or tgt_mdl_item_id = :new.item_id)
and m.creat_usr_id = e.usr_nm and e.email_id is not null order by e.email_id) loop
if (v_cur_email_id is null) then v_cur_email_id := cur.email_id; end if;
if cur.email_id = v_cur_email_id then
v_text_tbl := '<tr><td>' || cur.item_id || '</td><td>' || cur.ver_nr || '</td></tr>';
else
v_text_tbl := '</table>';
begin
nci_api.sendEmail(v_cur_email_id,'Model used in your Model Mapping Versioned',v_text || v_text_tbl);
end;
v_text_tbl := '';
v_cur_email_id := cur.email_id;
end if;
end loop;
v_text_tbl := v_text_tbl || '</table>';
--raise_application_error(-20000,v_text || v_text_tbl);
begin
nci_api.sendEmail(v_cur_email_id,'Model used in your Model Mapping Versioned',v_text || v_text_tbl);
--nci_api.sendEmail('deepali.manathara@nih.gov','Test','Validate');
end;
end if;
end;
/

