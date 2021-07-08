update OBJ_KEY set FLD_DELETE = 1 WHERE OBJ_KEY_DESC ='Template' and OBJ_TYP_ID = 4 and FLD_DELETE <> 1;
commit;