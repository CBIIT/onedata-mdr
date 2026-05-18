create or replace TRIGGER TR_NCI_MEC_VAL_MAP_CODE
  BEFORE  UPDATE
  on NCI_MEC_VAL_MAP
  for each row
BEGIN
   
   if ((:new.SRC_PV is null or trim(:new.src_pv)='') and :new.SRC_VM_CNCPT_CD is not null) then
   :new.SRC_LBL := null;
   :new.SRC_VM_CNCPT_CD := null;
   :new.SRC_VM_CNCPT_NM := null;
   end if;
   if ((:new.TGT_PV is null or trim(:new.TGT_pv)='') and :new.TGT_VM_CNCPT_CD is not null) then
   :new.TGT_LBL := null;
   :new.TGT_VM_CNCPT_CD := null;
   :new.TGT_VM_CNCPT_NM := null;
   end if;
   
END;

/
