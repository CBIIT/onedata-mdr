ALTER TABLE SAG_LOAD_CONCEPTS_EVS ADD (
ITEM_ID NUMBER, 
VER_NR NUMBER(4,2),
EXISTED NUMBER DEFAULT 0 NOT NULL
);
ALTER TABLE SAG_LOAD_CONCEPTS_EVS MODIFY 
(CODE VARCHAR2(120 BYTE), 
DEFINITION VARCHAR2(32000 BYTE));