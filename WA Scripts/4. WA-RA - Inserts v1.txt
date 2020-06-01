update OBJ_KEY set NCI_CD =  'DATAELEMENT' where OBJ_KEY_ID=4;
update OBJ_KEY set NCI_CD =  'DE_CONCEPT' where OBJ_KEY_ID=2;
update OBJ_KEY set NCI_CD =  'VALUEDOMAIN' where OBJ_KEY_ID=3;
update OBJ_KEY set NCI_CD =  'CONCEPTUALDOMAIN' where OBJ_KEY_ID=1;
update OBJ_KEY set NCI_CD =  'CLASSIFICATION' where OBJ_KEY_ID=9;
update OBJ_KEY set NCI_CD =  'OBJECTCLASS' where OBJ_KEY_ID=5;
update OBJ_KEY set NCI_CD =  'PROPERTY' where OBJ_KEY_ID=6;
update OBJ_KEY set NCI_CD =  'REPRESENTATION' where OBJ_KEY_ID=7;
update OBJ_KEY set NCI_CD =  'CONCEPT' where OBJ_KEY_ID=49;

commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (53,4,'Value Meaning', 'Value Meaning', '', 'VALUEMEANING');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (51,4,'Classification Scheme Item', 'Classification Scheme Item', '', 'CS_ITEM');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (50,4,'Protocol', 'Protocol for Cancer Trials', 'A named collection of questionnaires used on a specific trial or study', 'PROTOCOL');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (52,4,'Module', 'Module ', 'Module', 'MODULE');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (54,4,'Form', 'Form', 'Form', 'CRF');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (55,4,'Template', 'Template', 'Template', 'TEMPLATE');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (56,4,'Object Recs', 'OBJECTRECS', 'OBJECTRECS', 'OBJECTRECS');

commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (14, 'NCI Program Areas');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (15, 'NCI Definition Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (16, 'NCI Standard Data Type');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (17, 'NCI Item Relationships');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (18, 'NCI Origin');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (19, 'NCI Protocol Type'); 
commit;


insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (20, 'NCI CSI Types');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (21, 'NCI Derivation Types');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (22, 'Form Category');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (23, 'Concept Source');
commit;

insert into OBJ_TYP (OBJ_TYP_ID, OBJ_TYP_DESC) values (24, 'Form Type');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (60,17,'Protocol-Form Relationship', 'NCI Protocol-Form Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (61,17,'Form-Module Relationship', 'NCI Form-Module Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (63,17,'Module-DE Relationship', 'NCI Question');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (64,17,'CSI-CSI-CS', 'CSI Node relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (65,17,'CSI-DE Reationship', 'CSI-DE Relationship');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (66,17,'Derived DE Children', 'Derived DE children');
commit;

insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (70,24,'Form', 'Form');
insert into OBJ_KEY (OBJ_KEY_ID, OBJ_TYP_ID, OBJ_KEY_DESC, OBJ_KEY_DEF) values (71,24,'Template', 'Template');
commit;
