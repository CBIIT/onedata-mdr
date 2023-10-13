BEGIN
  
--INSERT INTO ADMIN_ITEM
    INSERT INTO /*+ APPEND */ admin_item (--NCI_IDSEQ,
         ADMIN_ITEM_TYP_ID,
         ADMIN_STUS_ID, --75 
         ADMIN_STUS_NM_DN, -- compound trigger RELEASED
         EFF_DT,
          CHNG_DESC_TXT,
         CNTXT_ITEM_ID, -- trigger 20000000024 
         CNTXT_VER_NR, --1
         CNTXT_NM_DN, --NCIP
         UNTL_DT,
         -- CURRNT_VER_IND, default
         ITEM_LONG_NM,
         ORIGIN_ID, -- default by trigger from obj_key 1466
         ORIGIN_ID_DN, -- NCI Thesaurus
         ITEM_DESC, 
         --ITEM_ID,
         ITEM_NM,
         VER_NR,
         CREAT_USR_ID,
         CREAT_DT,
         LST_UPD_DT,
         LST_UPD_USR_ID,
         DEF_SRC)
    select 
        49, 
        77, 
        'RETIRED', 
        sysdate,
        SYSDATE || ' OneData has added and retired this missing concept.',
        20000000024, 
        1, 
        'NCIP',
        sysdate, --untl_dt
        code, -- ITEM_LONG_NM
        1466,
        'NCI Thesaurus',
        substr(NVL(definition, 'No value exists.'), 1, 4000), 
        EVS_PREF_NAME, 
        1, 
        'ONEDATA', 
        sysdate, 
        sysdate, 
        'ONEDATA', 'NCI'
    FROM    onedata_wa.SAG_LOAD_CONCEPTS_EVS e
    WHERE   e.concept_status in 
    (
    'Retired_Concept',
    'Obsolete_Concept',
    'Header_Concept|Retired_Concept',
    'Header_Concept|Obsolete_Concept'
    )
    and not exists (select  1 
                    from    onedata_wa.cncpt c, 
                            onedata_wa.admin_item i 
                    where   i.item_long_nm = e.code 
                    and     c.item_id = i.item_id
                    and     admin_item_typ_id = 49);
                    
        --update status code to 77 as trigger updates it to 75

        UPDATE  ADMIN_ITEM
        SET     ADMIN_STUS_ID = 77
        WHERE    ADMIN_STUS_ID = 75 
        AND     to_date(creat_dt,'dd-mon-yy') = to_date(SYSDATE,'dd-mon-yy')
        AND     to_date(UNTL_dt,'dd-mon-yy') = to_date(SYSDATE,'dd-mon-yy')
        AND     CREAT_USR_ID = 'ONEDATA'
        AND     LST_UPD_USR_ID = 'ONEDATA';
        

    --Add concept table records based on AI table
    insert into /*+ APPEND */ cncpt (item_id,
         ver_nr,
         evs_src_id,
         CREAT_USR_ID,
         CREAT_DT,
         LST_UPD_DT,
         LST_UPD_USR_ID)
    SELECT item_id,
         ver_nr,
         218,-- NCI_CONCEPT_CODE
         CREAT_USR_ID,
         CREAT_DT,
         LST_UPD_DT,
         LST_UPD_USR_ID from admin_item where (item_id, ver_nr) in
    (select item_id, ver_nr from admin_item where admin_item_typ_id = 49 minus select item_id, ver_nr from cncpt);
    commit; 
   
END;
