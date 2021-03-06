insert into obj_typ (obj_typ_id, obj_typ_desc) values (1, 'Reference Document Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (2, 'Glossary Term Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (3, 'Classification Scheme Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (4, 'Administrative Object Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (5, 'Registration Status');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (6, 'Workflow Status');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (7, 'Conceptual Domain Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (8, 'Relationship Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (9, 'Value Domain Formats');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (10, 'Audit Change Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (11, 'Designation/Name Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (12, 'Reference Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (13, 'Classification Scheme Item Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (14, 'NCI Program Areas');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (15, 'NCI Definition Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (16, 'NCI Standard Data Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (17, 'NCI Item Relationships');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (18, 'Origin');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (19, 'NCI Protocol Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (20, 'NCI CSI Types');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (21, 'NCI Derivation Types');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (22, 'Form Category');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (23, 'Concept Source');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (24, 'Form Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (25, 'Address Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (26, 'Communication Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (27, 'Entity Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (31, 'Download Format');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (32, 'Download Component Type');
insert into obj_typ (obj_typ_id, obj_typ_desc) values (33, 'ALS PV-VM type');
commit;

insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (1,'Conceptual Domain',4,'','','CONCEPTUALDOMAIN' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (2,'Data Element Concept',4,'','','DE_CONCEPT' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (3,'Value Domain',4,'','','VALUEDOMAIN' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (4,'Data Element',4,'','','DATAELEMENT' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (5,'Object Class',4,'','','OBJECTCLASS' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (6,'Property',4,'','','PROPERTY' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (7,'Representation Term',4,'','','REPRESENTATION' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (8,'Context',4,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (9,'Classification Scheme',4,'','','CLASSIFICATION' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (10,'Derivation Rule',4,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (11,'Recorded',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (12,'Candidate',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (13,'Incomplete',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (14,'Standard',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (15,'Preferred Standard',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (16,'Retired',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (17,'Enumerated',7,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (18,'Non-enumerated',7,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (19,'Candidate',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (20,'Interim',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (21,'Review',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (22,'Final',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (23,'Request Recorded',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (24,'Not Registered',5,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (25,'Unassigned',6,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (28,'Standard',2,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (29,'Customer Defined',2,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (33,'YYYY',9,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (34,'A..A(1..30)',9,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (35,'A..A(31..100)',9,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (36,'nn',9,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (41,'A(12)',9,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (43,'Examples',12,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (44,'Comments',12,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (45,'Creation',10,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (46,'Registration Status Change',10,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (47,'Administrative Status Change',10,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (48,'Version Created',10,'','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (49,'Concept',4,'','','CONCEPT' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (50,'Protocol',4,'Protocol for Cancer Trials','A named collection of questionnaires used on a specific trial or study','PROTOCOL' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (51,'Classification Scheme Item',4,'Classification Scheme Item','','CS_ITEM' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (52,'Module',4,'Module ','Module','MODULE' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (53,'Value Meaning',4,'Value Meaning','','VALUEMEANING' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (54,'Form',4,'Form','Form','CRF' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (55,'Template',4,'Template','Template','TEMPLATE' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (56,'Object Recs',4,'OBJECTRECS','OBJECTRECS','OBJECTRECS' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (60,'Protocol-Form Relationship',17,'NCI Protocol-Form Relationship','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (61,'Form-Module Relationship',17,'NCI Form-Module Relationship','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (63,'Module-DE Relationship',17,'NCI Question','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (64,'CSI-CSI-CS',17,'CSI Node relationship','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (65,'CSI-DE Reationship',17,'CSI-DE Relationship','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (66,'Derived DE Children',17,'Derived DE children','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (70,'CRF',24,'Form','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (71,'Template',24,'Template','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (72,'Organization',27,'Organization','','' );
insert into obj_key (OBJ_KEY_ID, OBJ_KEY_DESC, OBJ_TYP_ID, OBJ_KEY_DEF, OBJ_KEY_CMNTS, NCI_CD) values (73,'Person',27,'Person','','' );
commit;
