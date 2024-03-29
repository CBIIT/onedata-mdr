--DSRMWS-2725
CREATE TABLE SAG_CONCEPT_RETIRED_BY_YEAR (
YEAR_ID NUMBER NOT NULL ENABLE,
CODE_RETIRED VARCHAR2(120 BYTE) NOT NULL ENABLE,
YEAR_DESC VARCHAR2(50 BYTE),
CREAT_DT DATE DEFAULT sysdate, 
CREAT_USR_ID VARCHAR2(50 BYTE) DEFAULT user,
LST_UPD_DT DATE DEFAULT sysdate,
LST_UPD_USR_ID VARCHAR2(50 BYTE) DEFAULT user, 
FLD_DELETE NUMBER(1,0) DEFAULT 0,
CONSTRAINT XPK_RETIRED_BY_YEAR PRIMARY KEY (YEAR_ID)
);
truncate TABLE SAG_CONCEPT_RETIRED_BY_YEAR; -- this allows to run the script multiple times
-- EVS provided list - parents of retired concepts
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (1999, 'C83485', 'Retired Concept Current Year');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2022, 'C192094', 'Retired Concept 2022');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2021, 'C185140', 'Retired Concept 2021');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2020, 'C176957', 'Retired Concept 2020');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2019, 'C167277', 'Retired Concept 2019');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2018, 'C157491', 'Retired Concept 2018');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2017, 'C143136', 'Retired Concept 2017');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2016, 'C131742', 'Retired Concept 2016');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2015, 'C125190', 'Retired Concept 2015');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2014, 'C120167', 'Retired Concept 2014');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2013, 'C113462', 'Retired Concept 2013');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2012, 'C104171', 'Retired Concept 2012');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2011, 'C99526', 'Retired Concept 2011');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2010, 'C95421', 'Retired Concept 2010');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2009, 'C85834', 'Retired Concept 2009');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2008, 'C83484', 'Retired Concept 2008');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2007, 'C83483', 'Retired Concept 2007');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2006, 'C83482', 'Retired Concept 2006');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2005, 'C83481', 'Retired Concept 2005');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2004, 'C83480', 'Retired Concept 2004');
INSERT INTO SAG_CONCEPT_RETIRED_BY_YEAR(YEAR_ID, CODE_RETIRED, YEAR_DESC)
Values (2003, 'C83479', 'Retired Concept 2003');
commit;
GRANT READ ON SAG_CONCEPT_RETIRED_BY_YEAR TO ONEDATA_RO; 
GRANT READ ON SAG_LOAD_CONCEPTS_EVS TO ONEDATA_RO; 
--retired concepts codes are taken from SAG_CONCEPT_RETIRED_BY_YEAR. 
--The previous version had a hardcoded retired concepts parents list.
create or replace Procedure SAG_LOAD_CONCEPT_RETIRE (p_END_DATE IN date default sysdate)
AS
v_end_date DATE;
v_updated_by2 varchar2(64) := '. Updated by caDSR II Monthly Concept Load.';
v_updated_by1 varchar2(256) := 'Updated caDSR information to match EVS retirement status, concept was retired on ';
v_updated_by varchar2(512);
BEGIN
	v_end_date := p_END_DATE;
	v_updated_by := v_updated_by1 || to_char(v_end_date, 'MON DD, YYYY HH:MI AM') || v_updated_by2;
update admin_item set admin_stus_id = 77, --WFS to 'RETIRED ARCHIVED'
	ADMIN_STUS_NM_DN = 'RETIRED ARCHIVED',
	LST_UPD_USR_ID = 'ONEDATA', 
	LST_UPD_DT = v_end_date,
	UNTL_DT = v_end_date,
	CHNG_DESC_TXT = substrb(v_updated_by || DECODE(CHNG_DESC_TXT, NULL, '', ' ' || CHNG_DESC_TXT), 1, 2000),
	REGSTR_STUS_ID = 11, -- 'Retired'
	REGSTR_STUS_NM_DN = 'Retired'
	where admin_item_typ_id = 49  -- Concept
	and admin_stus_id <> 77 -- not retired
	and CNTXT_ITEM_ID = 20000000024 --NCIP
	and CNTXT_VER_NR = 1
	and item_long_nm in ( -- EVS provided list - parents of retired concepts
	select code from sag_load_concepts_evs where parents in(
        select CODE_RETIRED from SAG_CONCEPT_RETIRED_BY_YEAR)
    );
commit;
exception
 when OTHERS then
  DBMS_OUTPUT.PUT_LINE('SAG_LOAD_CONCEPT_RETIRE error, code ' || SQLCODE || ': ' || SUBSTR(SQLERRM, 1 , 512));
  rollback;
END;
/


