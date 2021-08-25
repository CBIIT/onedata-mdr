--trigger is mutatimg

alter trigger MDSR_BIROW_QC_FOOTER_TR disable;

create or replace TRIGGER SBREXT.QC_BIU_ROW_ASSIGN
 BEFORE INSERT OR UPDATE
 ON sbrext.QUEST_CONTENTS_EXT
 REFERENCING OLD AS OLD NEW AS NEW
 FOR EACH ROW
-- PL/SQL Block
BEGIN

:new.created_by := upper(:new.created_by);
:new.modified_by := upper(:new.modified_by);
  if INSERTING then
    if  :new.latest_version_ind is null then
       :new.latest_version_ind:='Yes';
    end if;
    if  :new.deleted_ind is null then
      :new.deleted_ind:='No';
    end if;
    if :new.qc_idseq is null Then
      :new.qc_idseq :=admincomponent_crud.cmr_guid;
    end if;
	if :new.deleted_ind is null then
        :new.deleted_ind := 'No';
    end if;
    if :new.asl_name is null then
      :new.asl_name := 'DRAFT NEW'; --'QUEST_CONTENT';
    end if;
    if :new.created_by is null Then
      :new.created_by:=admin_security_util.effective_user;
    end if;
    if :new.date_created is null Then
      :new.date_created:=sysdate;
    end if;
    if  :new.begin_date is null then
      :new.begin_date:= sysdate;
    end if;
--commenting for reverse
--if nvl(meta_global_pkg.transaction_type,'null') <> 'VERSION' then
--	  select cde_id_seq.nextval into :new.qc_id
--	  from dual;
--	end if;
  elsif UPDATING then
    -- 19-Apr-2004, W. Ver Hoef - replaced commented out assignment of modified_by/date_modified
	--                            with conditional assignment based on instructions from Ram

    /*:new.modified_by := admin_security_util.effective_user;
       :new.date_modified := sysdate;*/
     if :new.modified_by is null Then
        :new.modified_by:= admin_security_util.effective_user;
     end if;
   --  if :new.date_modified is null Then
        :new.date_modified:=sysdate;
  --   end if;
  end if;
END;




