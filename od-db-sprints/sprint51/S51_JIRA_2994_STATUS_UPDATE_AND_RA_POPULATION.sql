
--STEP 1: UPDATE REGSTR STATUS FOR BACKFILLED RETIRED CONCEPTS
UPDATE  onedata_wa.admin_item wa
SET     REGSTR_STUS_ID = 11,
        REGSTR_STUS_NM_DN = 'Retired'
WHERE NOT EXISTS
         (select     1
        from        onedata_ra.admin_item  ra
        where       wa.item_id = ra.item_id
        and         wa.ver_nr =ra.ver_nr)
and     wa.ADMIN_STUS_NM_DN LIKE '%RETIRED%'


--STEP 2: INSERT ADMIN ITEMS INTO RA TABLE
INSERT INTO onedata_ra.admin_item
select *
from    onedata_wa.admin_item  wa
where not exists
        (select     1
        from        onedata_ra.admin_item  ra
        where       wa.item_id = ra.item_id
        and         wa.ver_nr =ra.ver_nr)

--STEP 3: INSERT CNCPT INTO RA TABLE 
INSERT INTO onedata_ra.cncpt ra
select *
from    onedata_wa.cncpt wa
where not exists
        (select     1
        from        onedata_ra.cncpt ra
        where       wa.item_id = ra.item_id
        and         wa.ver_nr =ra.ver_nr)
        
COMMIT

