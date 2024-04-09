create table SAG_LOAD_NCIt_TERM
(
 Subset_Code	varchar2(100) not null,
 Subset_Name	varchar2(4000) null,
 Concept_Code	varchar2(100) null,
 NCIT_PT	varchar2(4000) null,
 Rel_to_Target  varchar2(100) null,
 Target_Code	varchar2(100) not null,
 Target_Term	varchar2(4000) null,
 Target_Term_type	varchar2(100) null,
 Target_Terminology  	varchar2(100) not null,
 Target_Terminology_Version  	varchar2(100) null,Target_term_Definition varchar2(8000),
 Target_Synonym varchar2(8000));

delete from nci_admin_item_xmap where dt_src='ICDO';
commit;


delete from onedata_Ra.NCI_MDL_ELMNT_CHAR;
commit;

insert into onedata_Ra.NCI_MDL_ELMNT_CHAR select * from NCI_MDL_ELMNT_CHAR;
commit;


create or replace TRIGGER TR_VD_POST
  AFTER  UPDATE
  on VALUE_DOM
  for each row
BEGIN
    update ADMIN_ITEM set LST_UPD_DT = sysdate, LST_UPD_USR_ID = :new.LST_UPD_USR_ID where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
if (:new.VAL_DOM_TYP_ID <> 16 and :new.TERM_CNCPT_ITEM_ID is not null) then -- nullify Ref Term and Ref Term Usage
   update valUe_dom set term_cncpt_item_id = null, term_cncpt_ver_nr = null, TERM_USE_TYP=null where ITEM_ID = :new.item_id and VER_NR = :new.VER_NR;
 end if;

END;
/


