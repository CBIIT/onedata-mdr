create or replace trigger TR_NCI_REF
BEFORE INSERT
on REF
for each row
declare
v_count integer;
BEGIN
if (:new.NCI_IDSEQ is null) then
:new.NCI_IDSEQ := nci_11179.cmr_guid();
end if;
select count(*) into v_count from obj_key where obj_key_id = :new.ref_typ_id and upper(obj_key_Desc) like '%QUESTION%';
if (v_count = 1) then
:new.mtch_scr := 1;
else
:new.mtch_scr := null;

end if;
END;
/

create or replace TRIGGER OD_TR_DS_HDR_BTCH_INS  BEFORE INSERT  on  NCI_DS_BTCH_HDR 
for each row

         BEGIN    

      :new.DESC_COL := :new.BTCH_USR_NM || ' | ' || :new.BTCH_NM;

      END ;
      /
