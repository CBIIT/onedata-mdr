create or replace trigger od_tr_ds_upd before
   update on nci_ds_hdr
   for each row
begin
   :new.dt_last_modified := to_char(
      sysdate,
      'MM/DD/YY HH24:MI:SS'
   );
   :new.dt_sort := systimestamp();
   :new.lst_upd_dt := sysdate;
   if (
      :new.cde_item_id is null
      and :new.rule_desc is not null
   ) then
      :new.rule_desc := null;
      :new.mtch_desc_txt := null;
   end if;

   :new.desc_col := :new.entty_nm
                    || ' | '
                    || :new.btch_nm;

end;
/

create or replace trigger od_tr_ds_hdr before
   insert on nci_ds_hdr
   for each row
begin
   if ( :new.hdr_id <= 0
   or :new.hdr_id is null ) then
      select od_seq_ds_hdr.nextval
        into :new.hdr_id
        from dual;   end if;

   :new.dt_last_modified := to_char(
      sysdate,
      'MM/DD/YY HH24:MI:SS'
   );
   :new.dt_sort := systimestamp();
   :new.desc_col := :new.entty_nm
                    || ' | '
                    || :new.btch_nm;

end;
/
