alter table DATA_TYP add  (NCI_DTTYPE_MAP_ID integer);

update data_TYP a set NCI_DTTYPE_MAP_ID = (select DTTYPE_ID from DATA_TYP where 	NCI_DTTYPE_TYP_ID = 2 and DTTYPE_NM = a.NCI_DTTYPE_MAP)
where NCI_DTTYPE_TYP_ID = 1 and NCI_DTTYPE_MAP is not null;

commit;
