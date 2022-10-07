-- ’ replace in AI long names
update admin_item set item_nm = replace (item_nm, '’', '''')
where item_nm like '%’%';
commit;
-- ’ replace in AI definitions
update admin_item set ITEM_DESC = replace (ITEM_DESC, '’', '''')
where ITEM_DESC like '%’%';
commit;
--’ replace in Document Name 
update REF set REF_NM = replace(REF_NM, '’', '''')
where REF_NM like '%’%';
commit;
-- ’ replace in Document Text
update REF set REF_DESC = replace(REF_DESC, '’', '''')
where REF_DESC like '%’%';
commit;
