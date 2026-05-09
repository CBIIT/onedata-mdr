alter table CNCPT add (PRMRY_RT_ORI_NM varchar2(255));

alter table cncpt disable all triggers;
update CNCPT set PRMRY_RT_ORI_NM = (select ITEM_NM from ADMIN_ITEM ai where ai.item_id = cncpt.item_id and ai.ver_nr = cncpt.ver_nr)
where cncpt.PRMRY_CNCPT_IND = 1;
commit;
alter table cncpt enable all triggers;
